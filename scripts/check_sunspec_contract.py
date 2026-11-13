#!/usr/bin/env python3
"""Validate the public SunSpec contract pages against the maintained rule table.

Usage: check_sunspec_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...

Each rule names its contract, the repository page it governs, the section that
must hold it (null for the whole page), its kind, the statement or pattern, and
why it is required. Every contract governs exactly one page. Every rule kind is
evaluated fail-closed:

  heading    the exact heading line exists inside the section
  row        the exact table row line exists inside the section
  statement  the statement exists inside the section; whitespace runs in the
             page match one space, and <pin:C> matches a hexadecimal token
             whose commitment is C
  forbidden  the case-insensitive pattern matches no line of the section

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
KINDS = ('heading', 'row', 'statement', 'forbidden')
CONTRACT_PAGES = {
    'v2_contract': 'protocols/sunspec/read-only-core-v2.md',
    'v2_licensing': 'protocols/applicability-and-licensing.md',
    'licensing_page': 'protocols/applicability-and-licensing.md',
    'v1_core_page': 'protocols/sunspec/read-only-core-v1.md',
    'v1_model_families': 'protocols/sunspec/read-only-core-v1-model-families.md',
    'nested_layout': 'protocols/sunspec/nested-layout-contract-v1.md',
    'der_trip_lv_template': 'protocols/sunspec/der-trip-lv-template-v2.md',
    'der_trip_lv_projection': 'protocols/sunspec/der-trip-lv-typed-fact-projection-v2.md',
    'dynamic_structural_selection': 'protocols/sunspec/dynamic-structural-selection-v2.md',
}
EXPECTED = {
    ('v2_contract', 'heading'): 8,
    ('v2_contract', 'row'): 18,
    ('v2_contract', 'statement'): 85,
    ('v2_contract', 'forbidden'): 1,
    ('v2_licensing', 'row'): 1,
    ('v2_licensing', 'statement'): 2,
    ('licensing_page', 'heading'): 2,
    ('licensing_page', 'row'): 1,
    ('v1_core_page', 'heading'): 1,
    ('v1_model_families', 'heading'): 7,
    ('v1_model_families', 'statement'): 7,
    ('v1_model_families', 'forbidden'): 1,
    ('nested_layout', 'heading'): 9,
    ('nested_layout', 'statement'): 11,
    ('der_trip_lv_template', 'heading'): 6,
    ('der_trip_lv_template', 'statement'): 9,
    ('der_trip_lv_template', 'forbidden'): 1,
    ('der_trip_lv_projection', 'heading'): 6,
    ('der_trip_lv_projection', 'statement'): 26,
    ('der_trip_lv_projection', 'forbidden'): 1,
    ('dynamic_structural_selection', 'heading'): 5,
    ('dynamic_structural_selection', 'statement'): 14,
    ('dynamic_structural_selection', 'forbidden'): 1,
}
CONTRACTS = frozenset(CONTRACT_PAGES)
HEADING = re.compile(r'(#{1,6}) \S(?:.*\S)?')
PIN = re.compile(r'<pin:([^>\s]*)>')
PIN_TOKEN = '([0-9A-Fa-f]{7,64})'
FENCE = re.compile(r' {0,3}(`{3,}|~{3,})(.*)')


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


def pinned_pattern(value):
    """Compile a statement with <pin:C> tokens into a pattern and its commitments."""
    pins = []
    words = []
    for word in value.split(' '):
        parts = []
        position = 0
        for pin in PIN.finditer(word):
            if not valid_commitment(pin.group(1)):
                raise RuleError('invalid pin commitment in: ' + value)
            parts.append(re.escape(word[position:pin.start()]))
            parts.append(PIN_TOKEN)
            pins.append(pin.group(1))
            position = pin.end()
        parts.append(re.escape(word[position:]))
        words.append(''.join(parts))
    if '<pin:' in PIN.sub('', value):
        raise RuleError('malformed pin in: ' + value)
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
    if page != CONTRACT_PAGES[contract]:
        raise RuleError('page %s is not the page of contract %s' % (page, contract))
    if section is not None and (type(section) is not str or not HEADING.fullmatch(section)):
        raise RuleError('section must be null or one heading line')
    compiled = {'contract': contract, 'page': page, 'section': section, 'kind': kind,
                'value': value, 'pins': ()}
    if kind == 'heading':
        if not HEADING.fullmatch(value):
            raise RuleError('heading rule is not a heading line: ' + value)
    elif kind == 'row':
        if '\n' in value or len(value) < 3 or value[0] != '|' or value[-1] != '|':
            raise RuleError('row rule is not a table row: ' + value)
        if '<pin:' in value:
            raise RuleError('row rules hold no pin: ' + value)
    elif kind == 'statement':
        if value != ' '.join(value.split()):
            raise RuleError('statement is not whitespace-normalized: ' + value)
        compiled['pattern'], compiled['pins'] = pinned_pattern(value)
    elif kind == 'forbidden':
        try:
            compiled['pattern'] = re.compile(value, re.IGNORECASE)
        except re.error as exc:
            raise RuleError('invalid forbidden pattern: ' + str(exc)) from exc
    if kind != 'statement' and '<pin:' in value:
        raise RuleError('only statements hold pins: ' + value)
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
    fence = None
    for index, line in enumerate(lines):
        opening = FENCE.match(line)
        if fence is not None:
            if (opening and opening.group(1)[0] == fence[0] and len(opening.group(1)) >= len(fence)
                    and not opening.group(2).strip()):
                fence = None
        elif opening and not (opening.group(1)[0] == '`' and '`' in opening.group(2)):
            fence = opening.group(1)
        elif HEADING.fullmatch(line):
            found.append((index, len(line) - len(line.lstrip('#')), line))
    return found


def section_bounds(lines, section):
    if section is None:
        return 0, len(lines)
    found = headings(lines)
    matches = [position for position, (_, _, line) in enumerate(found) if line == section]
    if len(matches) != 1:
        raise LookupError('section is not present exactly once: ' + section)
    start, level, _ = found[matches[0]]
    end = next((index for index, other, _ in found[matches[0] + 1:] if other <= level), len(lines))
    return start, end


def pinned_match(pins, match):
    return match is not None and tuple(commitment(token) for token in match.groups()) == pins


def evaluate(rule, scope):
    """Return a failure message for one rule, or None."""
    kind = rule['kind']
    if kind == 'heading':
        if rule['value'] not in (line for _, _, line in headings(scope)):
            return 'missing heading'
    elif kind == 'row':
        if rule['value'] not in scope:
            return 'missing table row'
    elif kind == 'statement':
        text = '\n'.join(scope)
        if not any(pinned_match(rule['pins'], match)
                   for match in rule['pattern'].finditer(text)):
            return 'missing statement'
    elif kind == 'forbidden':
        for number, line in enumerate(scope, 1):
            if rule['pattern'].search(line):
                return 'forbidden material at section line %d' % number
    return None


def check_page(rules, lines):
    failures = []
    for rule in rules:
        try:
            start, end = section_bounds(lines, rule['section'])
        except LookupError as exc:
            failures.append((rule, str(exc)))
            continue
        failure = evaluate(rule, lines[start:end])
        if failure:
            failures.append((rule, failure))
    return failures


def run(argv):
    if len(argv) < 3:
        raise RuleError('usage: check_sunspec_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...')
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
    if set(documents) != {CONTRACT_PAGES[contract] for contract in selected}:
        raise RuleError('page mappings must name exactly the pages of the selected contracts')
    failed = False
    for page, document in sorted(documents.items()):
        lines = Path(document).read_text(encoding='utf-8').split('\n')
        for contract in selected:
            if CONTRACT_PAGES[contract] != page:
                continue
            group = [rule for rule in rules if rule['contract'] == contract]
            for rule, failure in check_page(group, lines):
                failed = True
                print('SunSpec contract check failed: %s %s %s %s: %s' % (
                    contract, page, rule['kind'], rule['section'] or '(page)', failure),
                    file=sys.stderr)
                if rule['kind'] != 'forbidden':
                    print('  required: ' + rule['value'], file=sys.stderr)
    return not failed


def main(argv):
    try:
        return 0 if run(argv) else 1
    except (OSError, UnicodeError, ValueError, TypeError, KeyError) as exc:
        print('SunSpec contract check failed: ' + str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
