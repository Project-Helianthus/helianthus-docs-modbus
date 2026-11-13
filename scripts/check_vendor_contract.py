#!/usr/bin/env python3
"""Validate the Huawei, Fronius, private-function and S-Dongle pages against the maintained rule table.

Usage: check_vendor_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...

Each rule names its contract, the repository page it governs, the section that
must hold it (null for the whole page), its kind, the statement or pattern, and
why it is required. Every contract governs exactly one page. Every rule kind is
evaluated fail-closed:

  heading        the exact heading line exists inside the section
  row            the exact table row line exists inside the section
  statement      the statement exists inside the section; whitespace runs in
                 the page match one space
  forbidden      the case-insensitive pattern matches no line of the section
  decision_rows  the leading row and outcome cells of the section's decision
                 rows are exactly the listed rows, in order
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

FIELDS = ('contract', 'page', 'section', 'kind', 'value', 'reason')
KINDS = ('heading', 'row', 'statement', 'forbidden', 'decision_rows')
CONTRACT_PAGES = {
    'private_function': 'protocols/modbus/private-function-codes.md',
    'fronius_qualification': 'protocols/fronius/qualification-readiness-v1.md',
    'fronius_float_page': 'protocols/fronius/sunspec-float-v1.md',
    'huawei_qualification': 'protocols/huawei/qualification-readiness-v1.md',
    'huawei_disposition': 'protocols/huawei/inverter-battery-readonly-v1.md',
    'huawei_gateway_page': 'protocols/huawei/gateway-readonly-v1.md',
    'sdongle_page': 'architecture/sdongle-qualification-disposition-v1.md',
}
EXPECTED = {
    ('private_function', 'heading'): 11,
    ('private_function', 'statement'): 45,
    ('fronius_qualification', 'heading'): 6,
    ('fronius_qualification', 'row'): 6,
    ('fronius_qualification', 'statement'): 24,
    ('fronius_qualification', 'forbidden'): 1,
    ('fronius_float_page', 'heading'): 1,
    ('huawei_qualification', 'heading'): 7,
    ('huawei_qualification', 'statement'): 33,
    ('huawei_qualification', 'forbidden'): 1,
    ('huawei_disposition', 'heading'): 9,
    ('huawei_disposition', 'row'): 2,
    ('huawei_disposition', 'statement'): 16,
    ('huawei_disposition', 'forbidden'): 1,
    ('huawei_disposition', 'decision_rows'): 2,
    ('huawei_gateway_page', 'heading'): 4,
    ('huawei_gateway_page', 'statement'): 5,
    ('sdongle_page', 'heading'): 6,
    ('sdongle_page', 'statement'): 3,
}
CONTRACTS = frozenset(CONTRACT_PAGES)
HEADING = re.compile(r'(#{1,6}) \S(?:.*\S)?')
DECISION_ROW = re.compile(r'(\| `[a-z_]*` \| `[A-Z_]*` \|)')
FENCE = re.compile(r' {0,3}(`{3,}|~{3,})(.*)')


class RuleError(ValueError):
    """The rule table or the command line cannot be trusted."""


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise RuleError('duplicate JSON key: ' + key)
        result[key] = value
    return result


def statement_pattern(value):
    return re.compile(r'\s+'.join(re.escape(word) for word in value.split(' ')))


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
                'value': value}
    if kind == 'heading':
        if not HEADING.fullmatch(value):
            raise RuleError('heading rule is not a heading line: ' + value)
    elif kind == 'row':
        if '\n' in value or len(value) < 3 or value[0] != '|' or value[-1] != '|':
            raise RuleError('row rule is not a table row: ' + value)
    elif kind == 'statement':
        if value != ' '.join(value.split()):
            raise RuleError('statement is not whitespace-normalized: ' + value)
        compiled['pattern'] = statement_pattern(value)
    elif kind == 'forbidden':
        try:
            compiled['pattern'] = re.compile(value, re.IGNORECASE)
        except re.error as exc:
            raise RuleError('invalid forbidden pattern: ' + str(exc)) from exc
    elif kind == 'decision_rows':
        if section is None:
            raise RuleError('decision rows need a section: ' + value)
        rows = value.split('\n')
        if not all(DECISION_ROW.fullmatch(row) for row in rows) or len(set(rows)) != len(rows):
            raise RuleError('decision rows are not distinct row and outcome cells: ' + value)
        compiled['rows'] = rows
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


def decision_rows(scope):
    return [match.group(1) for match in map(DECISION_ROW.match, scope) if match]


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
        if not rule['pattern'].search('\n'.join(scope)):
            return 'missing statement'
    elif kind == 'forbidden':
        for number, line in enumerate(scope, 1):
            if rule['pattern'].search(line):
                return 'forbidden material at section line %d' % number
    elif kind == 'decision_rows':
        if decision_rows(scope) != rule['rows']:
            return 'decision rows are not exact'
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
        raise RuleError('usage: check_vendor_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...')
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
                print('Vendor contract check failed: %s %s %s %s: %s' % (
                    contract, page, rule['kind'], rule['section'] or '(page)', failure),
                    file=sys.stderr)
                if rule['kind'] != 'forbidden':
                    print('  required: ' + rule['value'].replace('\n', '\n            '),
                          file=sys.stderr)
    return not failed


def main(argv):
    try:
        return 0 if run(argv) else 1
    except (OSError, UnicodeError, ValueError, TypeError, KeyError) as exc:
        print('Vendor contract check failed: ' + str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
