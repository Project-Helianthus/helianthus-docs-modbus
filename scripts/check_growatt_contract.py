#!/usr/bin/env python3
"""Validate the public Growatt contract pages against the maintained rule table.

Usage: check_growatt_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...

Each rule names its contract, the repository page it governs, the section that
must hold it (null for the whole page), its kind, the statement or pattern, and
why it is required. Every rule kind is evaluated fail-closed:

  heading         the exact heading line exists inside the section
  row             the exact table row line exists inside the section; <pin:C>
                  matches a hexadecimal token whose commitment is C
  statement       the statement exists inside the section; whitespace runs in
                  the page match one space, and <pin:C> works as for rows
  forbidden       the case-insensitive pattern matches no line of the section
  source_locator  the https locators of the page are exactly the committed set
  slice           the `- offset 0x..., quantity N` items of the section are
                  exactly the slice rules of that section, in rule order, and
                  the page holds no such item outside a slice section
  matrix_row      the table body rows of the section are exactly the matrix
                  rows of that section, in rule order, and no other table line
                  of the page starts with the common prefix of those rows

A commitment is the unpadded standard Base64 SHA-256 of the UTF-8 text.
"""
import base64
import hashlib
import json
import os
import re
import sys
from collections import Counter
from pathlib import Path

FIELDS = ('contract', 'page', 'section', 'kind', 'value', 'reason')
KINDS = ('heading', 'row', 'statement', 'forbidden', 'source_locator', 'slice', 'matrix_row')
EXPECTED = {
    ('x2_page', 'heading'): 5,
    ('x2_page', 'statement'): 1,
    ('x2_contract', 'statement'): 9,
    ('bms_page', 'heading'): 4,
    ('bms_page', 'statement'): 2,
    ('bms_contract', 'heading'): 2,
    ('bms_contract', 'statement'): 41,
    ('bms_contract', 'slice'): 7,
    ('bms_contract', 'forbidden'): 2,
    ('bms_contract', 'source_locator'): 7,
    ('protocol_ii_identity', 'heading'): 3,
    ('protocol_ii_identity', 'statement'): 8,
    ('protocol_ii_fc04', 'heading'): 2,
    ('protocol_ii_fc04', 'statement'): 14,
    ('protocol_ii_fc04', 'row'): 10,
    ('protocol_ii_source_matrix', 'heading'): 1,
    ('protocol_ii_source_matrix', 'row'): 27,
    ('protocol_ii_source_matrix', 'statement'): 3,
    ('protocol_ii_source_matrix', 'forbidden'): 1,
    ('wit_matrix', 'matrix_row'): 11,
    ('wit_matrix', 'statement'): 11,
    ('wit_matrix', 'forbidden'): 1,
}
CONTRACTS = frozenset(contract for contract, _ in EXPECTED)
PAGE = re.compile(r'protocols/growatt/[a-z0-9]+(?:-[a-z0-9]+)*\.md')
HEADING = re.compile(r'(#{1,6}) \S(?:.*\S)?')
PIN = re.compile(r'<pin:([^>\s]*)>')
PIN_TOKEN = '([0-9A-Fa-f]{7,64})'
FENCE = re.compile(r' {0,3}(`{3,}|~{3,})(.*)')
LOCATOR = re.compile(r'https://[^)]+')
SLICE_VALUE = re.compile(r'offset 0x[0-9A-F]{4}, quantity [1-9][0-9]*')
SLICE_ITEM = re.compile(r'- (offset 0x[0-9A-Fa-f]+, quantity [0-9]+)')
DELIMITER = re.compile(r'\|(?:\s*:?-{3,}:?\s*\|)+')
GROUPED = ('source_locator', 'slice', 'matrix_row')


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


def pinned_pattern(value, separator):
    """Compile text with <pin:C> tokens into a pattern and its commitments."""
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
    return re.compile(separator.join(words)), tuple(pins)


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
    elif kind in ('row', 'matrix_row'):
        if '\n' in value or len(value) < 3 or value[0] != '|' or value[-1] != '|':
            raise RuleError(kind + ' rule is not a table row: ' + value)
        if kind == 'row':
            compiled['pattern'], compiled['pins'] = pinned_pattern(value, ' ')
        elif '<pin:' in value:
            raise RuleError('matrix_row rules hold no pin: ' + value)
    elif kind == 'statement':
        if value != ' '.join(value.split()):
            raise RuleError('statement is not whitespace-normalized: ' + value)
        compiled['pattern'], compiled['pins'] = pinned_pattern(value, r'\s+')
    elif kind == 'forbidden':
        try:
            compiled['pattern'] = re.compile(value, re.IGNORECASE)
        except re.error as exc:
            raise RuleError('invalid forbidden pattern: ' + str(exc)) from exc
    elif kind == 'source_locator':
        if section is not None:
            raise RuleError('source_locator rules govern the whole page')
        if not valid_commitment(value):
            raise RuleError('invalid commitment in source_locator rule')
    if kind in ('slice', 'matrix_row') and section is None:
        raise RuleError(kind + ' rules need a section')
    if kind == 'slice' and not SLICE_VALUE.fullmatch(value):
        raise RuleError('slice rule is not an offset and quantity: ' + value)
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
    """Return a failure message for one single rule, or None."""
    kind = rule['kind']
    if kind == 'heading':
        if rule['value'] not in (line for _, _, line in headings(scope)):
            return 'missing heading'
    elif kind == 'row':
        if not any(pinned_match(rule['pins'], rule['pattern'].fullmatch(line))
                   for line in scope):
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


def body_rows(scope):
    """Return the table lines that are neither a delimiter nor a header row."""
    rows = []
    for index, line in enumerate(scope):
        if not line.startswith('|') or DELIMITER.fullmatch(line):
            continue
        if index + 1 < len(scope) and DELIMITER.fullmatch(scope[index + 1]):
            continue
        rows.append(line)
    return rows


def grouped(rules, kind):
    groups = {}
    for rule in rules:
        if rule['kind'] == kind:
            groups.setdefault(rule['section'], []).append(rule['value'])
    return groups


def check_groups(rules, lines):
    failures = []

    def fail(kind, section, message):
        failures.append(({'kind': kind, 'value': '', 'section': section}, message))

    locators = {rule['value'] for rule in rules if rule['kind'] == 'source_locator'}
    if locators:
        found = {commitment(url) for line in lines for url in LOCATOR.findall(line)}
        if found - locators:
            fail('source_locator', None, 'unapproved source locator')
        if locators - found:
            fail('source_locator', None, 'missing required source locator')
    covered = set()
    for section, values in grouped(rules, 'slice').items():
        start, end = section_bounds(lines, section)
        covered.update(range(start, end))
        items = [m.group(1) for m in map(SLICE_ITEM.match, lines[start:end]) if m]
        if items != values:
            fail('slice', section, 'slice list is not exact')
    if covered and any(SLICE_ITEM.match(line) for index, line in enumerate(lines)
                       if index not in covered):
        fail('slice', None, 'slice item outside its section')
    for section, values in grouped(rules, 'matrix_row').items():
        start, end = section_bounds(lines, section)
        if body_rows(lines[start:end]) != values:
            fail('matrix_row', section, 'matrix rows are not exact')
        prefix = os.path.commonprefix(values)
        if [line for line in lines if line.startswith(prefix)] != values:
            fail('matrix_row', section, 'matrix row family outside its matrix')
    return failures


def check_page(rules, lines):
    failures = []
    for rule in rules:
        if rule['kind'] in GROUPED:
            continue
        try:
            start, end = section_bounds(lines, rule['section'])
        except LookupError as exc:
            failures.append((rule, str(exc)))
            continue
        failure = evaluate(rule, lines[start:end])
        if failure:
            failures.append((rule, failure))
    try:
        failures.extend(check_groups(rules, lines))
    except LookupError as exc:
        failures.append(({'kind': 'section', 'value': '', 'section': None}, str(exc)))
    return failures


def run(argv):
    if len(argv) < 3:
        raise RuleError('usage: check_growatt_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...')
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
                print('Growatt contract check failed: %s %s %s %s: %s' % (
                    contract, page, rule['kind'], rule['section'] or '(page)', failure),
                    file=sys.stderr)
                if rule['kind'] in ('heading', 'row', 'statement'):
                    print('  required: ' + rule['value'], file=sys.stderr)
    return not failed


def main(argv):
    try:
        return 0 if run(argv) else 1
    except (OSError, UnicodeError, ValueError, TypeError, KeyError) as exc:
        print('Growatt contract check failed: ' + str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
