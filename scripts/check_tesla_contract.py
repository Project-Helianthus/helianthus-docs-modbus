#!/usr/bin/env python3
"""Validate the public Tesla contract pages against the maintained rule table.

Usage: check_tesla_contract.py [RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...]

Each rule names its contract, the repository page it governs, the section that
must hold it (null for the whole page), its kind, the statement or pattern, and
why it is required. Every rule kind is evaluated fail-closed:

With no arguments, check every required page in this repository.

  heading         the exact heading line exists once inside the section
  row             the exact table row line exists inside the section
  statement       the statement exists inside the section; whitespace may wrap
  forbidden       the case-insensitive pattern matches no line of the section
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

FIELDS = ('contract', 'page', 'section', 'kind', 'value', 'reason')
KINDS = ('heading', 'row', 'statement', 'forbidden')
LEGACY = 'legacy-wall-connector-rs485.md'
HSC = 'gen3-hsc-rtu.md'
TEDAPI = 'tedapi-specification.md'
PAGE_PREFIX = 'protocols/tesla/'
CONTRACT_PAGES = {
    'legacy_public_protocol': (LEGACY,),
    'generation': (LEGACY, HSC),
    'legacy_evse_current': (LEGACY,),
    'gen3_evse_current_limit': (HSC,),
    'gen3_mcp_projection': (HSC,),
    'current_limit_operation': ('gen3-current-limit-operation-v1.md',),
    'read_acquisition': ('gen3-read-acquisition-v1.md',),
    'gen3_semreg_mapping': ('gen3-semreg-mapping-v1.md',),
    'rs485_specification': ('rs485-site-controller-protocol.md',),
    'tedapi': (TEDAPI,),
    'gen3_wire_messages': (TEDAPI,),
    'tedapi_landing': ('tedapi.md',),
}
EXPECTED = {
    ('legacy_public_protocol', 'forbidden'): 1,
    ('generation', 'heading'): 11,
    ('generation', 'statement'): 21,
    ('generation', 'forbidden'): 2,
    ('legacy_evse_current', 'heading'): 1,
    ('legacy_evse_current', 'statement'): 7,
    ('gen3_evse_current_limit', 'heading'): 1,
    ('gen3_evse_current_limit', 'statement'): 7,
    ('gen3_mcp_projection', 'heading'): 1,
    ('gen3_mcp_projection', 'statement'): 11,
    ('current_limit_operation', 'heading'): 10,
    ('current_limit_operation', 'statement'): 44,
    ('current_limit_operation', 'forbidden'): 1,
    ('read_acquisition', 'heading'): 12,
    ('read_acquisition', 'row'): 6,
    ('read_acquisition', 'statement'): 49,
    ('read_acquisition', 'forbidden'): 1,
    ('gen3_semreg_mapping', 'heading'): 3,
    ('gen3_semreg_mapping', 'statement'): 10,
    ('rs485_specification', 'heading'): 29,
    ('rs485_specification', 'row'): 23,
    ('rs485_specification', 'statement'): 4,
    ('rs485_specification', 'forbidden'): 1,
    ('tedapi', 'heading'): 27,
    ('tedapi', 'row'): 7,
    ('tedapi', 'statement'): 9,
    ('tedapi', 'forbidden'): 1,
    ('gen3_wire_messages', 'heading'): 6,
    ('gen3_wire_messages', 'row'): 6,
    ('gen3_wire_messages', 'statement'): 7,
    ('tedapi_landing', 'heading'): 2,
    ('tedapi_landing', 'statement'): 4,
    ('tedapi_landing', 'forbidden'): 1,
}
CONTRACTS = frozenset(CONTRACT_PAGES)
HEADING = re.compile(r'(#{1,6}) \S(?:.*\S)?')
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


def pages_for(contracts):
    return {PAGE_PREFIX + name for contract in contracts for name in CONTRACT_PAGES[contract]}


def compile_rule(rule):
    if type(rule) is not dict or set(rule) != set(FIELDS):
        raise RuleError('a rule must have exactly the fields ' + ', '.join(FIELDS))
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
    if page not in pages_for((contract,)):
        raise RuleError('unexpected page for %s: %s' % (contract, page))
    if section is not None and (type(section) is not str or not HEADING.fullmatch(section)):
        raise RuleError('section must be null or one heading line')
    compiled = {field: rule[field] for field in FIELDS[:-1]}
    if kind == 'heading' and not HEADING.fullmatch(value):
        raise RuleError('heading rule is not a heading line: ' + value)
    if kind == 'row' and (section is None or not re.fullmatch(r'\|[^\r\n]+\|', value)):
        raise RuleError('row rule requires a section and one table row: ' + value)
    if kind == 'statement':
        if value != ' '.join(value.split()):
            raise RuleError('statement is not whitespace-normalized: ' + value)
        compiled['pattern'] = re.compile(r'\s+'.join(map(re.escape, value.split(' '))))
    if kind == 'forbidden':
        try:
            compiled['pattern'] = re.compile(value, re.IGNORECASE)
        except re.error as exc:
            raise RuleError('invalid forbidden pattern: ' + str(exc)) from exc
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
    covered = set()
    for rule in data['rules']:
        compiled = compile_rule(rule)
        key = tuple(compiled[field] for field in FIELDS[:5])
        if key in seen:
            raise RuleError('duplicate rule: ' + compiled['value'])
        seen.add(key)
        counts[compiled['contract'], compiled['kind']] += 1
        covered.add((compiled['contract'], compiled['page']))
        rules.append(compiled)
    if counts != Counter(EXPECTED):
        raise RuleError('rule table does not hold the expected rule counts')
    if covered != {(contract, page) for contract in CONTRACTS for page in pages_for((contract,))}:
        raise RuleError('rule table does not cover every required contract page')
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


def section_lines(lines, section, found):
    if section is None:
        return lines
    matches = [position for position, (_, _, line) in enumerate(found) if line == section]
    if len(matches) != 1:
        raise LookupError('section is not present exactly once: ' + section)
    start, level, _ = found[matches[0]]
    end = next((index for index, other, _ in found[matches[0] + 1:] if other <= level), len(lines))
    return lines[start:end]


def evaluate(rule, lines, found):
    """Return a failure message for one rule, or None."""
    try:
        scope = section_lines(lines, rule['section'], found)
    except LookupError as exc:
        return str(exc)
    kind = rule['kind']
    if kind == 'heading':
        count = sum(line == rule['value'] for _, _, line in headings(scope))
        if not count:
            return 'missing heading'
        if count > 1:
            return 'duplicate heading'
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
    else:
        raise RuleError('unknown rule kind: ' + kind)
    return None


def check_page(rules, lines):
    found = headings(lines)
    results = ((rule, evaluate(rule, lines, found)) for rule in rules)
    return [(rule, failure) for rule, failure in results if failure]


def default_arguments():
    root = Path(__file__).resolve().parent.parent
    return [str(root / 'scripts/tesla_contract_rules.json'), ','.join(sorted(CONTRACTS)),
            *(f'{page}={root / page}' for page in sorted(pages_for(CONTRACTS)))]


def document_mappings(mappings, selected):
    documents = {}
    for mapping in mappings:
        page, separator, document = mapping.partition('=')
        if not separator or not document or page in documents:
            raise RuleError('invalid page mapping: ' + mapping)
        documents[page] = document
    if set(documents) != pages_for(selected):
        raise RuleError('page mappings must name exactly the pages of the selected contracts')
    return documents


def run(argv):
    argv = argv or default_arguments()
    if len(argv) < 3:
        raise RuleError('usage: check_tesla_contract.py RULES CONTRACT[,CONTRACT...] PAGE=DOCUMENT...')
    rules = load_rules(argv[0])
    selected = argv[1].split(',')
    if len(set(selected)) != len(selected) or not set(selected) <= CONTRACTS:
        raise RuleError('unknown or repeated contract selection: ' + argv[1])
    documents = document_mappings(argv[2:], selected)
    failed = False
    for page, document in sorted(documents.items()):
        lines = Path(document).read_text(encoding='utf-8').split('\n')
        for contract in selected:
            group = [rule for rule in rules
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
