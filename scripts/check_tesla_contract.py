#!/usr/bin/env python3
"""Validate the public Tesla contract pages against the maintained rule table.

Usage: check_tesla_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...

Each rule names its contract, the repository page it governs, the section that
must hold it (null for the whole page), its kind, the statement or pattern, and
why it is required. Every rule kind is evaluated fail-closed:

  heading         the exact heading line exists inside the section
  row             the exact table row line exists inside the section
  statement       the statement exists inside the section; whitespace runs in
                  the page match one space, and <pin:C> matches a hexadecimal
                  token whose commitment is C
  forbidden       the case-insensitive pattern matches no line of the section
  allowed_digest  every 64-digit hexadecimal run of the page has a commitment
                  listed by one of these rules
  source_locator  the https locators of the page are exactly the committed set

A commitment is the unpadded standard Base64 SHA-256 of the UTF-8 text.
"""
import base64
import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path

FIELDS = ('contract', 'page', 'section', 'kind', 'value', 'reason')
KINDS = ('heading', 'row', 'statement', 'forbidden', 'allowed_digest', 'source_locator')
EXPECTED = {
    ('legacy_public_protocol', 'forbidden'): 1,
    ('legacy_public_protocol', 'source_locator'): 4,
    ('gen3_public_protocol', 'forbidden'): 1,
    ('gen3_public_protocol', 'allowed_digest'): 16,
    ('generation', 'heading'): 19,
    ('generation', 'statement'): 24,
    ('generation', 'forbidden'): 1,
    ('legacy_evse_current', 'heading'): 1,
    ('legacy_evse_current', 'statement'): 7,
    ('gen3_evse_current_limit', 'heading'): 1,
    ('gen3_evse_current_limit', 'statement'): 9,
    ('gen3_wire_evidence', 'heading'): 1,
    ('gen3_wire_evidence', 'statement'): 12,
    ('gen3_mcp_projection', 'heading'): 1,
    ('gen3_mcp_projection', 'statement'): 11,
    ('current_limit_operation', 'heading'): 9,
    ('current_limit_operation', 'statement'): 25,
    ('current_limit_operation', 'forbidden'): 1,
    ('read_acquisition', 'heading'): 13,
    ('read_acquisition', 'row'): 5,
    ('read_acquisition', 'statement'): 42,
    ('read_acquisition', 'forbidden'): 1,
    ('tedapi', 'heading'): 11,
    ('tedapi', 'statement'): 1,
    ('evse_scope', 'heading'): 2,
    ('evse_scope', 'row'): 8,
    ('evse_scope', 'statement'): 11,
    ('evse_scope', 'forbidden'): 1,
}
CONTRACTS = frozenset(contract for contract, _ in EXPECTED)
PAGE = re.compile(r'protocols/tesla/[a-z0-9]+(?:-[a-z0-9]+)*\.md')
HEADING = re.compile(r'(#{1,6}) \S(?:.*\S)?')
PIN = re.compile(r'<pin:([^>\s]*)>')
PIN_TOKEN = '([0-9A-Fa-f]{7,64})'
DIGEST = re.compile(r'[0-9A-Fa-f]{64}')
LOCATOR = re.compile(r'https://[^)]+')


class RuleError(ValueError):
    """The rule table or the command line cannot be trusted."""


def commitment(text):
    digest = hashlib.sha256(text.encode('utf-8')).digest()
    return base64.b64encode(digest).decode('ascii').rstrip('=')


def valid_commitment(value):
    try:
        raw = base64.b64decode(value + '=', validate=True)
    except ValueError:
        return False
    return len(raw) == 32 and base64.b64encode(raw).decode('ascii').rstrip('=') == value


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise RuleError('duplicate JSON key: ' + key)
        result[key] = value
    return result


def statement_pattern(value):
    """Compile a statement into a whitespace-tolerant pattern and its pins."""
    if value != ' '.join(value.split()):
        raise RuleError('statement is not whitespace-normalized: ' + value)
    pins = []
    words = []
    for word in value.split(' '):
        parts = []
        position = 0
        for pin in PIN.finditer(word):
            if not valid_commitment(pin.group(1)):
                raise RuleError('invalid pin commitment in statement: ' + value)
            parts.append(re.escape(word[position:pin.start()]))
            parts.append(PIN_TOKEN)
            pins.append(pin.group(1))
            position = pin.end()
        parts.append(re.escape(word[position:]))
        words.append(''.join(parts))
    if '<pin:' in PIN.sub('', value):
        raise RuleError('malformed pin in statement: ' + value)
    return re.compile(r'\s+'.join(words)), tuple(pins)


def compile_rule(rule):
    contract, page, section, kind, value, reason = (rule[field] for field in FIELDS)
    for field, item in (('contract', contract), ('page', page), ('kind', kind),
                        ('value', value), ('reason', reason)):
        if type(item) is not str or not item or item != item.strip():
            raise RuleError('invalid rule field: ' + field)
    if kind not in KINDS:
        raise RuleError('unknown rule kind: ' + kind)
    if contract not in CONTRACTS:
        raise RuleError('unknown contract: ' + contract)
    if (contract, kind) not in EXPECTED:
        raise RuleError('kind %s is not part of contract %s' % (kind, contract))
    if not PAGE.fullmatch(page):
        raise RuleError('invalid page: ' + page)
    if section is not None and (type(section) is not str or not HEADING.fullmatch(section)):
        raise RuleError('section must be null or one heading line')
    compiled = {'contract': contract, 'page': page, 'section': section, 'kind': kind,
                'value': value}
    if kind == 'heading':
        if not HEADING.fullmatch(value):
            raise RuleError('heading rule is not a heading line: ' + value)
    elif kind == 'row':
        if '\n' in value or len(value) < 3 or value[0] != '|' or value[-1] != '|':
            raise RuleError('row rule is not a table row: ' + value)
    elif kind == 'statement':
        compiled['pattern'], compiled['pins'] = statement_pattern(value)
    elif kind == 'forbidden':
        try:
            compiled['pattern'] = re.compile(value, re.IGNORECASE)
        except re.error as exc:
            raise RuleError('invalid forbidden pattern: ' + str(exc)) from exc
    else:
        if section is not None:
            raise RuleError(kind + ' rules govern the whole page')
        if not valid_commitment(value):
            raise RuleError('invalid commitment in ' + kind + ' rule')
    return compiled


def load_rules(path):
    data = json.loads(Path(path).read_text(encoding='utf-8'), object_pairs_hook=unique_object)
    if (type(data) is not dict or set(data) != {'version', 'rules'}
            or type(data['version']) is not int or data['version'] != 1):
        raise RuleError('invalid rule table')
    if type(data['rules']) is not list or not data['rules']:
        raise RuleError('rule table has no rules')
    rules = []
    seen = set()
    counts = Counter()
    for rule in data['rules']:
        if type(rule) is not dict or set(rule) != set(FIELDS):
            raise RuleError('a rule must have exactly the fields ' + ', '.join(FIELDS))
        compiled = compile_rule(rule)
        key = tuple(compiled[field] for field in FIELDS[:5])
        if key in seen:
            raise RuleError('duplicate rule: ' + compiled['value'])
        seen.add(key)
        counts[compiled['contract'], compiled['kind']] += 1
        rules.append(compiled)
    if counts != Counter(EXPECTED):
        raise RuleError('rule table does not hold the expected rule counts')
    return rules


def headings(lines):
    """Return (index, level, line) for every heading outside fenced blocks."""
    found = []
    fenced = False
    for index, line in enumerate(lines):
        if line.startswith('```'):
            fenced = not fenced
        elif not fenced and HEADING.fullmatch(line):
            found.append((index, len(line) - len(line.lstrip('#')), line))
    return found


def section_lines(lines, section):
    if section is None:
        return lines
    found = headings(lines)
    matches = [position for position, (_, _, line) in enumerate(found) if line == section]
    if len(matches) != 1:
        raise LookupError('section is not present exactly once: ' + section)
    start, level, _ = found[matches[0]]
    end = next((index for index, other, _ in found[matches[0] + 1:] if other <= level), len(lines))
    return lines[start:end]


def evaluate(rule, lines):
    """Return a failure message for one positional rule, or None."""
    try:
        scope = section_lines(lines, rule['section'])
    except LookupError as exc:
        return str(exc)
    kind = rule['kind']
    if kind == 'heading':
        if rule['value'] not in (line for _, _, line in headings(scope)):
            return 'missing heading'
    elif kind == 'row':
        if rule['value'] not in scope:
            return 'missing table row'
    elif kind == 'statement':
        text = '\n'.join(scope)
        for match in rule['pattern'].finditer(text):
            if tuple(commitment(token) for token in match.groups()) == rule['pins']:
                return None
        return 'missing statement'
    elif kind == 'forbidden':
        for number, line in enumerate(scope, 1):
            if rule['pattern'].search(line):
                return 'forbidden material at section line %d' % number
    return None


def check_page(rules, lines):
    failures = []
    for rule in rules:
        if rule['kind'] in ('allowed_digest', 'source_locator'):
            continue
        failure = evaluate(rule, lines)
        if failure:
            failures.append((rule, failure))
    allowed = {rule['value'] for rule in rules if rule['kind'] == 'allowed_digest'}
    if allowed:
        for token in DIGEST.findall('\n'.join(lines)):
            if commitment(token) not in allowed:
                failures.append(({'kind': 'allowed_digest', 'value': '', 'section': None},
                                 'unapproved evidence digest'))
    locators = {rule['value'] for rule in rules if rule['kind'] == 'source_locator'}
    if locators:
        found = {commitment(url) for line in lines for url in LOCATOR.findall(line)}
        if found - locators:
            failures.append(({'kind': 'source_locator', 'value': '', 'section': None},
                             'unapproved source locator'))
        if locators - found:
            failures.append(({'kind': 'source_locator', 'value': '', 'section': None},
                             'missing required source locator'))
    return failures


def run(argv):
    if len(argv) < 3:
        raise RuleError('usage: check_tesla_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...')
    rules = load_rules(argv[0])
    selected = argv[1].split(',')
    if len(set(selected)) != len(selected) or not set(selected) <= CONTRACTS:
        raise RuleError('unknown or repeated contract selection: ' + argv[1])
    documents = {}
    for mapping in argv[2:]:
        page, separator, document = mapping.partition('=')
        if not separator or not document or page in documents:
            raise RuleError('invalid page mapping: ' + mapping)
        documents[page] = document
    selected_rules = [rule for rule in rules if rule['contract'] in selected]
    if set(documents) != {rule['page'] for rule in selected_rules}:
        raise RuleError('page mappings must name exactly the pages of the selected contracts')
    failed = False
    for page, document in sorted(documents.items()):
        lines = Path(document).read_text(encoding='utf-8').split('\n')
        for contract in selected:
            group = [rule for rule in selected_rules
                     if rule['contract'] == contract and rule['page'] == page]
            for rule, failure in check_page(group, lines):
                failed = True
                print('Tesla contract check failed: %s %s %s %s: %s' % (
                    contract, page, rule['kind'], rule['section'] or '(page)', failure),
                    file=sys.stderr)
                if rule['kind'] in ('heading', 'row', 'statement'):
                    print('  required: ' + rule['value'], file=sys.stderr)
    return not failed


def main(argv):
    try:
        return 0 if run(argv) else 1
    except (OSError, UnicodeError, ValueError, TypeError, KeyError) as exc:
        print('Tesla contract check failed: ' + str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
