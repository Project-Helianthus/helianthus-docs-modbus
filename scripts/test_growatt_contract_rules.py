#!/usr/bin/env python3
"""Prove that every Growatt contract rule is load-bearing and that bad rule tables fail closed."""
import importlib.util
import json
import re
import string
from collections import Counter
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parent.parent
RULES = ROOT / 'scripts/growatt_contract_rules.json'
CHECKER = ROOT / 'scripts/check_growatt_contract.py'
GATE = ROOT / 'scripts/check_docs.sh'
X2 = 'protocols/growatt/shinewilan-x2-bridge-v1.md'
BMS = 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
P2 = 'protocols/growatt/protocol-ii-readonly-v1.md'
MATRIX = 'protocols/growatt/protocol-ii-source-profile-matrix-v1.md'
WIT = 'protocols/growatt/wit-family-protocol-matrix-v1.md'

sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location('check_growatt_contract', CHECKER)
ENGINE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ENGINE)

# Synthetic lines that each forbidden rule of a contract must reject.
PROBES = {
    'bms_contract': ('/Users/example/private-capture', 'sha256-deadbeef01234567',
                     'The vendor material is public domain.', 'canonical facts',
                     'gateway.example.internal:1502', '192.0.2.1', 'port 1502',
                     '0123456789abcdef' * 2 + '01234567', '0123456789abcdef' * 4),
    'protocol_ii_source_matrix': ('https://example.invalid/', '/Users/example', '192.0.2.1',
                                  'gateway.example.internal:1502', 'Port 502'),
    'wit_matrix': ('VPP reads are permitted.', 'Growatt Protocol II applies to a WIT family.',
                   '`WIT 4-25K-HU` firmware version is `1.2.3`.'),
}

# The extended regular expressions the gate used before the rule table; a line
# they reject must stay rejected by the rule that replaced them.
ORIGINAL_FORBIDDEN = {
    'bms_contract': (
        '(/[Uu]sers/|sha(-?256)?[-:]?[0-9a-f]{8,}|(source|vendor material) (is|are) public domain'
        r'|sunspec\.inverter\.|canonical facts)',
        '(^|[^[:xdigit:]])[[:xdigit:]]{40}([^[:xdigit:]]|$)|(^|[^[:xdigit:]])[[:xdigit:]]{64}'
        r'([^[:xdigit:]]|$)|([0-9]{1,3}\.){3}[0-9]{1,3}|([[:alnum:]][[:alnum:].-]*):([0-9]{1,5}'
        '|[[:alpha:]][[:alnum:].-]*)|[Pp]ort[[:space:]]+[0-9]{1,5}'),
    'protocol_ii_source_matrix': (
        r'https?://|/[Uu]sers/|([0-9]{1,3}\.){3}[0-9]{1,3}|([[:alnum:]][[:alnum:].-]*):([0-9]{1,5}'
        '|[[:alpha:]][[:alnum:].-]*)|[Pp]ort[[:space:]]+[0-9]{1,5}',),
    'wit_matrix': (
        'VPP (read|reads|control|controls|write|writes) (is|are) (permitted|allowed|enabled|supported)'
        '|Protocol II[^.]*(applies|is applicable)[[:space:]]+to[[:space:]]+(a[[:space:]]+|the[[:space:]]+'
        '|any[[:space:]]+)?WIT|`WIT [^`]+` firmware (version |gate )?(is|=)',),
}


class GrowattContractRules(unittest.TestCase):
    def setUp(self):
        (ROOT / '.tmp').mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=ROOT / '.tmp')
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.data = json.loads(RULES.read_text(encoding='utf-8'))
        self.rules = self.data['rules']
        self.pages = sorted({rule['page'] for rule in self.rules})
        self.copies = {}
        for page in self.pages:
            copy = self.work / Path(page).name
            copy.write_bytes((ROOT / page).read_bytes())
            self.copies[page] = copy

    def run_checker(self, contracts, mapping=None, rules=RULES):
        mapping = self.copies if mapping is None else mapping
        args = ['python3', '-B', str(CHECKER), str(rules), ','.join(contracts)]
        args += ['%s=%s' % (page, path) for page, path in sorted(mapping.items())]
        return subprocess.run(args, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE,
                              text=True, timeout=30)

    def contract_pages(self, contract):
        return {rule['page'] for rule in self.rules if rule['contract'] == contract}

    def run_contract(self, contract, rules=RULES, pages=None):
        pages = self.contract_pages(contract) if pages is None else pages
        mapping = {page: self.copies[page] for page in pages}
        return self.run_checker([contract], mapping, rules)

    def run_table(self, data, contract='x2_page'):
        path = self.work / 'rules.json'
        pages = None
        if not isinstance(data, str):
            pages = {rule['page'] for rule in data['rules'] if isinstance(rule, dict)
                     and rule.get('contract') == contract and rule.get('page') in self.copies}
            data = json.dumps(data)
        path.write_text(data, encoding='utf-8')
        return self.run_contract(contract, path, pages or None).returncode

    def edited(self, mutate):
        data = json.loads(json.dumps(self.data))
        mutate(data)
        return data

    def restore(self, page):
        self.copies[page].write_bytes((ROOT / page).read_bytes())

    def page_text(self, page):
        return self.copies[page].read_text(encoding='utf-8')

    def write(self, page, text):
        self.copies[page].write_text(text, encoding='utf-8')

    def assert_contract_fails(self, contract, kind):
        result = self.run_contract(contract)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(' %s ' % kind, result.stderr)

    def test_public_pages_pass_every_contract(self):
        contracts = sorted(ENGINE.CONTRACTS)
        result = self.run_checker(contracts)
        self.assertEqual(result.returncode, 0, result.stderr)
        for contract in contracts:
            with self.subTest(contract=contract):
                self.assertEqual(self.run_contract(contract).returncode, 0)

    def test_rule_table_matches_the_expected_counts(self):
        rules = ENGINE.load_rules(RULES)
        self.assertEqual(len(rules), sum(ENGINE.EXPECTED.values()))
        self.assertEqual(set(ENGINE.KINDS), {rule['kind'] for rule in rules})
        for rule in self.rules:
            self.assertEqual(list(rule), list(ENGINE.FIELDS))

    def test_each_positional_rule_is_load_bearing(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['kind'] not in ('heading', 'row', 'statement'):
                continue
            with self.subTest(contract=rule['contract'], kind=rule['kind'], value=rule['value'][:40]):
                original = self.page_text(rule['page'])
                if rule['kind'] in ('statement', 'row'):
                    flags = re.MULTILINE if rule['kind'] == 'row' else 0
                    pattern = rule['pattern'].pattern
                    if rule['kind'] == 'row':
                        pattern = '^' + pattern + '$'
                    mutated, count = re.subn(pattern, '[removed]', original, flags=flags)
                else:
                    lines = original.split('\n')
                    count = lines.count(rule['value'])
                    mutated = '\n'.join('[removed]' if line == rule['value'] else line
                                        for line in lines)
                self.assertGreater(count, 0)
                self.write(rule['page'], mutated)
                self.assert_contract_fails(rule['contract'], rule['kind'])
                self.restore(rule['page'])

    def test_each_sectioned_rule_is_scoped_to_its_section(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['section'] is None or rule['kind'] not in ('heading', 'row', 'statement'):
                continue
            with self.subTest(contract=rule['contract'], kind=rule['kind'], value=rule['value'][:40]):
                original = self.page_text(rule['page'])
                if rule['kind'] == 'statement':
                    moved = rule['pattern'].search(original).group(0)
                    body = rule['pattern'].sub('[moved]', original)
                else:
                    lines = original.split('\n')
                    moved = next(line for line in lines if rule['pattern'].fullmatch(line))
                    body = '\n'.join('[moved]' if line == moved else line for line in lines)
                title, rest = body.split('\n', 1)
                self.write(rule['page'], title + '\n\n' + moved + '\n' + rest)
                self.assertNotEqual(self.run_contract(rule['contract']).returncode, 0)
                self.restore(rule['page'])

    def test_a_repeated_or_missing_section_fails_closed(self):
        original = self.page_text(WIT)
        for text in (original.replace('## Protocol isolation', '## Protocol isolation\n\n## Protocol isolation'),
                     original.replace('## Protocol isolation', '### Protocol isolation')):
            self.write(WIT, text)
            result = self.run_contract('wit_matrix')
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('section is not present exactly once', result.stderr)

    def test_each_pin_binds_its_exact_token(self):
        pinned = [rule for rule in ENGINE.load_rules(RULES) if rule.get('pins')]
        self.assertEqual(len(pinned), 1)
        digits = string.hexdigits[:16]
        swap = str.maketrans(digits, digits[1:] + digits[0])
        for rule in pinned:
            with self.subTest(contract=rule['contract'], value=rule['value'][:40]):
                original = self.page_text(rule['page'])
                line = next(line for line in original.split('\n') if rule['pattern'].fullmatch(line))
                match = rule['pattern'].fullmatch(line)
                for index, token in enumerate(match.groups()):
                    for altered in (token.translate(swap), token[:-1], token + '0'):
                        start, end = match.span(index + 1)
                        changed = line[:start] + altered + line[end:]
                        self.write(rule['page'], original.replace(line, changed))
                        self.assert_contract_fails(rule['contract'], 'row')
                self.restore(rule['page'])

    def test_each_forbidden_rule_rejects_its_probes(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['kind'] != 'forbidden':
                continue
            probes = [probe for probe in PROBES[rule['contract']] if rule['pattern'].search(probe)]
            self.assertTrue(probes, rule['value'])
            for probe in probes:
                with self.subTest(contract=rule['contract'], probe=probe):
                    self.write(rule['page'], self.page_text(rule['page']) + '\n' + probe + '\n')
                    self.assert_contract_fails(rule['contract'], 'forbidden')
                    self.restore(rule['page'])

    def test_forbidden_rules_reject_every_line_the_original_expressions_rejected(self):
        corpus = [probe for probes in PROBES.values() for probe in probes]
        corpus += ['host-é:ñame', 'é1:2', 'Ünit:Ä', 'PORT\t80', 'x' + 'A' * 40 + 'y',
                   'vpp WRITES ARE ENABLED', 'protocol ii here applies to any WIT']
        for page in self.pages:
            corpus += (ROOT / page).read_text(encoding='utf-8').split('\n')
        corpus_path = self.work / 'corpus.txt'
        corpus_path.write_text('\n'.join(corpus) + '\n', encoding='utf-8')
        rules = ENGINE.load_rules(RULES)
        for contract, expressions in ORIGINAL_FORBIDDEN.items():
            patterns = [rule['pattern'] for rule in rules
                        if rule['contract'] == contract and rule['kind'] == 'forbidden']
            self.assertEqual(len(patterns), len(expressions))
            for locale in ('C', 'en_US.UTF-8'):
                for expression in expressions:
                    found = subprocess.run(['grep', '-Ei', expression, str(corpus_path)],
                                           capture_output=True, text=True, timeout=30,
                                           env={'LC_ALL': locale, 'PATH': '/usr/bin:/bin'})
                    self.assertIn(found.returncode, (0, 1), found.stderr)
                    for line in found.stdout.split('\n')[:-1]:
                        with self.subTest(contract=contract, locale=locale, line=line[:60]):
                            self.assertTrue(any(p.search(line) for p in patterns))

    def test_source_locators_are_exactly_the_committed_set(self):
        original = self.page_text(BMS)
        locators = sorted(set(re.findall(r'https://[^)\n]+', original)))
        self.assertEqual(len(locators), 7)
        for locator in locators:
            with self.subTest(locator=ENGINE.commitment(locator)):
                self.write(BMS, original.replace('(' + locator + ')', '(#removed)'))
                self.assert_contract_fails('bms_contract', 'source_locator')
        self.write(BMS, original + '\n[synthetic](https://example.invalid/bms)\n')
        self.assert_contract_fails('bms_contract', 'source_locator')
        self.write(BMS, original + '\nSee [page 1](' + locators[0] + ') again.\n')
        self.assertEqual(self.run_contract('bms_contract').returncode, 0)

    def test_slices_are_exact_ordered_and_bounded_to_their_sections(self):
        original = self.page_text(BMS)
        extra = '- offset 0x0200, quantity 1, for a synthetic extra slice;'
        mutations = {
            'removed': original.replace('- offset 0x0100, quantity 12,', '- removed,'),
            'widened': original.replace('offset 0x0071, quantity 16', 'offset 0x0071, quantity 17'),
            'reordered': original.replace('- offset 0x0001, quantity 7,', '- offset 0x000X,').replace(
                '- offset 0x000D, quantity 29,', '- offset 0x0001, quantity 7,').replace(
                '- offset 0x000X,', '- offset 0x000D, quantity 29,'),
            'added in section': original.replace('- offset 0x010D, quantity 2,', extra + '\n- offset 0x010D, quantity 2,'),
            'added after the diagnostic list': original.replace(
                '- offset 0x0081, quantity 16,', '- offset 0x0081, quantity 16,\n- offset 0x0091, quantity 16,'),
            'added in another section': original.replace('## Offline identity tuple\n', '## Offline identity tuple\n\n' + extra + '\n'),
        }
        for name, text in mutations.items():
            with self.subTest(mutation=name):
                self.assertNotEqual(text, original)
                self.write(BMS, text)
                self.assert_contract_fails('bms_contract', 'slice')
        self.write(BMS, original.replace('## Offline identity tuple\n', '## Offline identity tuple\n\n- offset 0x0029 is cell-series count context.\n'))
        self.assertEqual(self.run_contract('bms_contract').returncode, 0)

    def test_matrix_rows_are_exact_ordered_and_bounded_to_their_section(self):
        original = self.page_text(WIT)
        lines = original.split('\n')
        rows = [line for line in lines if line.startswith('| `WIT ')]
        self.assertEqual(len(rows), 11)
        first, second = rows[0], rows[1]
        synthetic = '| `WIT 1-2K-ZZ` | synthetic | synthetic | `UNKNOWN` | `UNKNOWN` | `NO_SEND` |'
        mutations = {
            'removed': original.replace(first + '\n', ''),
            'duplicated': original.replace(first + '\n', first + '\n' + first + '\n'),
            'reordered': original.replace(first + '\n' + second, second + '\n' + first),
            'added family row': original.replace(rows[-1], rows[-1] + '\n' + synthetic),
            'added other body row': original.replace(rows[-1], rows[-1] + '\n| other | x | x | x | x | x |'),
            'family row under a new heading': original.replace(
                '## Explicit VPP V2.01 tuple', '## Extra\n\n' + synthetic + '\n\n## Explicit VPP V2.01 tuple'),
            'family row as a second header': original.replace(rows[-1], rows[-1] + '\n\n' + synthetic + '\n| --- |'),
            'cell changed': original.replace(first, first.replace('`UNKNOWN`', '`V2.01`', 1)),
        }
        for name, text in mutations.items():
            with self.subTest(mutation=name):
                self.assertNotEqual(text, original)
                self.write(WIT, text)
                self.assert_contract_fails('wit_matrix', 'matrix_row')
        unrelated = '\n| Term | Meaning |\n| --- | --- |\n| branch | one family row |\n'
        self.write(WIT, original + unrelated)
        self.assertEqual(self.run_contract('wit_matrix').returncode, 0)

    def test_missing_empty_and_malformed_tables_fail_closed(self):
        missing = self.run_contract('x2_page', self.work / 'missing.json')
        self.assertNotEqual(missing.returncode, 0)
        for bad in ('', ' \n', '{', '[]', '{}', 'null', '{"version":1}',
                    '{"version":1,"version":1,"rules":[]}', '{"version":1,"rules":[]}',
                    '{"version":2,"rules":[]}', '{"version":true,"rules":[]}',
                    '{"version":1,"rules":{}}'):
            with self.subTest(table=bad):
                self.assertNotEqual(self.run_table(bad), 0)

    def test_every_rule_field_is_required_and_validated(self):
        for field in ENGINE.FIELDS:
            with self.subTest(missing=field):
                self.assertNotEqual(self.run_table(self.edited(
                    lambda data, f=field: data['rules'][0].pop(f))), 0)
        mutations = {
            'extra field': lambda d: d['rules'][0].update(note='x'),
            'duplicate key': None,
            'unknown kind': lambda d: d['rules'][0].update(kind='unknown'),
            'kind outside contract': lambda d: d['rules'][0].update(kind='slice'),
            'unknown contract': lambda d: d['rules'][0].update(contract='unknown'),
            'other known contract': lambda d: d['rules'][0].update(contract='bms_page'),
            'page outside the family': lambda d: d['rules'][0].update(page='protocols/tesla/tedapi.md'),
            'section not a heading': lambda d: d['rules'][0].update(section='Scope'),
            'empty value': lambda d: d['rules'][0].update(value=''),
            'non-string value': lambda d: d['rules'][0].update(value=7),
            'empty reason': lambda d: d['rules'][0].update(reason=''),
            'padded reason': lambda d: d['rules'][0].update(reason=' why'),
            'duplicate rule': lambda d: d['rules'].append(dict(d['rules'][0])),
            'removed rule': lambda d: d['rules'].pop(0),
            'rule not an object': lambda d: d['rules'].__setitem__(0, []),
        }
        for name, mutate in mutations.items():
            with self.subTest(mutation=name):
                if mutate is None:
                    text = json.dumps(self.data).replace('"kind"', '"kind": "heading", "kind"', 1)
                    self.assertNotEqual(self.run_table(text), 0)
                else:
                    self.assertNotEqual(self.run_table(self.edited(mutate)), 0)

    def test_each_kind_rejects_a_malformed_value(self):
        def first(data, contract, kind):
            return next(r for r in data['rules'] if r['contract'] == contract and r['kind'] == kind)
        cases = {
            ('x2_page', 'heading', 'value'): 'Request mapping',
            ('protocol_ii_fc04', 'row', 'value'): '| 37 | grid frequency',
            ('x2_page', 'statement', 'value'): 'Unsupported  operations',
            ('wit_matrix', 'forbidden', 'value'): 'VPP|(',
            ('bms_contract', 'source_locator', 'value'): 'https://example.invalid/',
            ('bms_contract', 'source_locator', 'section'): '## Scope',
            ('bms_contract', 'slice', 'value'): 'offset 0x1, quantity 7',
            ('bms_contract', 'slice', 'section'): None,
            ('wit_matrix', 'matrix_row', 'value'): '| `WIT 4-25K-HU`',
            ('wit_matrix', 'matrix_row', 'section'): None,
        }
        for (contract, kind, field), value in cases.items():
            with self.subTest(kind=kind, field=field):
                data = self.edited(lambda d: first(d, contract, kind).update({field: value}))
                self.assertNotEqual(self.run_table(data, contract), 0)
        for value in ('| `growatt-rtu-v1.24` | `<pin:short>` |',
                      '| `growatt-rtu-v1.24` | `<pin:' + 'A' * 42 + '>` |',
                      '| `growatt-rtu-v1.24` | `<pin:` |'):
            with self.subTest(pin=value):
                data = self.edited(lambda d: next(
                    r for r in d['rules'] if '<pin:' in r['value']).update(value=value))
                self.assertNotEqual(self.run_table(data, 'protocol_ii_source_matrix'), 0)
        pinned = next(r for r in self.rules if '<pin:' in r['value'])['value']
        data = self.edited(lambda d: first(d, 'wit_matrix', 'matrix_row').update(
            value='| ' + pinned.split('| ', 1)[1]))
        self.assertNotEqual(self.run_table(data, 'wit_matrix'), 0)

    def test_loader_rejects_bad_rules_even_when_the_counts_would_match(self):
        """Isolate the loader checks that the count table would otherwise mask."""
        path = self.work / 'rules.json'
        first = self.rules[0]
        cases = {
            'unknown kind': ({(first['contract'], 'unknown'): 1},
                             lambda d: d['rules'].append(dict(first, kind='unknown', value='x'))),
            'duplicate rule': ({(first['contract'], first['kind']): 6},
                               lambda d: d['rules'].append(dict(first))),
            'non-normalized statement': ({}, lambda d: next(
                r for r in d['rules'] if r['kind'] == 'statement').update(value='No  send.')),
        }
        for name, (extra, mutate) in cases.items():
            with self.subTest(case=name):
                path.write_text(json.dumps(self.edited(mutate)), encoding='utf-8')
                expected = dict(ENGINE.EXPECTED)
                expected.update(extra)
                with mock.patch.object(ENGINE, 'EXPECTED', expected), \
                        mock.patch.object(ENGINE, 'CONTRACTS', frozenset(c for c, _ in expected)):
                    with self.assertRaises(ENGINE.RuleError):
                        ENGINE.load_rules(path)

    def test_heading_rules_require_a_real_heading(self):
        for rule in self.rules:
            if rule['kind'] != 'heading':
                continue
            with self.subTest(contract=rule['contract'], heading=rule['value']):
                original = self.page_text(rule['page'])
                fenced = '```text\n' + rule['value'] + '\n```'
                lines = original.split('\n')
                self.assertEqual(lines.count(rule['value']), 1)
                self.write(rule['page'], '\n'.join(fenced if line == rule['value'] else line
                                                   for line in lines))
                self.assert_contract_fails(rule['contract'], 'heading')
                self.restore(rule['page'])

    def test_fence_types_hide_headings_and_close_only_on_a_matching_fence(self):
        for opener in ('~~~', '~~~~text', '```', '````', '  ```text', '   ~~~'):
            with self.subTest(opener=opener):
                lines = [opener, '## A', opener.strip()[:3] * 2 + opener.strip()[0], '## B']
                self.assertEqual([line for _, _, line in ENGINE.headings(lines)], ['## B'])
        self.assertEqual(ENGINE.headings(['~~~', '```', '## A', '~~', '~~~', '## B']),
                         [(5, 2, '## B')])
        self.assertEqual(ENGINE.headings(['````', '```', '## A', '````', '## B']),
                         [(4, 2, '## B')])
        self.assertEqual([line for _, _, line in ENGINE.headings(['``` a`b', '## A'])], ['## A'])
        self.assertEqual([line for _, _, line in ENGINE.headings(['    ```', '## A'])], ['## A'])

    def test_each_rule_key_field_changes_the_outcome(self):
        """Vary contract, page, section, kind and value of one rule; each change is caught."""
        target = next(i for i, r in enumerate(self.rules) if r['contract'] == 'wit_matrix'
                      and r['value'] == 'The VPP tuple has no qualified firmware gate in this contract.')
        variations = {
            'contract': ('x2_contract', 'loader'),
            'page': (X2, 'statement'),
            'section': ('## Protocol isolation', 'statement'),
            'kind': ('forbidden', 'forbidden'),
            'value': (self.rules[target]['value'] + ' Synthetic.', 'statement'),
        }
        path = self.work / 'rules.json'
        for field, (value, caught_by) in variations.items():
            with self.subTest(field=field):
                data = self.edited(lambda d, f=field, v=value: d['rules'][target].update({f: v}))
                self.assertNotEqual(self.run_table(data, 'wit_matrix'), 0)
                path.write_text(json.dumps(data), encoding='utf-8')
                counts = Counter((r['contract'], r['kind']) for r in data['rules'])
                with mock.patch.object(ENGINE, 'EXPECTED', dict(counts)), \
                        mock.patch.object(ENGINE, 'CONTRACTS', frozenset(c for c, _ in counts)):
                    rules = ENGINE.load_rules(path)
                if caught_by == 'loader':
                    with self.assertRaises(ENGINE.RuleError):
                        ENGINE.load_rules(path)
                    continue
                failures = []
                for page in {rule['page'] for rule in rules}:
                    lines = self.page_text(page).split('\n')
                    failures += ENGINE.check_page([r for r in rules if r['page'] == page], lines)
                self.assertEqual([rule['kind'] for rule, _ in failures], [caught_by])

    def test_command_line_selection_fails_closed(self):
        wit = {WIT: self.copies[WIT]}
        self.assertEqual(self.run_checker(['wit_matrix'], wit).returncode, 0)
        self.assertNotEqual(self.run_checker(['unknown'], wit).returncode, 0)
        self.assertNotEqual(self.run_checker(['wit_matrix', 'wit_matrix'], wit).returncode, 0)
        self.assertNotEqual(self.run_checker(['wit_matrix'], {}).returncode, 0)
        self.assertNotEqual(self.run_checker(['wit_matrix'], dict(wit, **{X2: self.copies[X2]})).returncode, 0)
        malformed = subprocess.run(['python3', '-B', str(CHECKER), str(RULES), 'wit_matrix', WIT],
                                   capture_output=True, timeout=30)
        self.assertNotEqual(malformed.returncode, 0)
        self.assertNotEqual(self.run_checker(['wit_matrix'], {WIT: self.work / 'absent.md'}).returncode, 0)

    def test_gate_options_keep_their_contract_scope(self):
        def gate(*args):
            return subprocess.run(['bash', str(GATE), *map(str, args)], stdout=subprocess.DEVNULL,
                                  stderr=subprocess.DEVNULL, timeout=60).returncode

        x2 = self.copies[X2]
        self.write(X2, self.page_text(X2).replace('## Transparency limits', '## Limits'))
        self.assertEqual(gate('--check-x2-contract', x2), 0)
        self.assertNotEqual(self.run_contract('x2_page').returncode, 0)
        self.restore(X2)
        self.write(X2, self.page_text(X2).replace('scan unit addresses', 'scan units'))
        self.assertNotEqual(gate('--check-x2-contract', x2), 0)
        protocol_ii = self.copies[P2]
        self.write(P2, self.page_text(P2).replace('0.01 Hz', '0.1 Hz'))
        self.assertNotEqual(gate('--check-growatt-protocol-ii-fc04-contract', protocol_ii), 0)
        self.assertEqual(gate('--check-growatt-protocol-ii-identity-projection', protocol_ii), 0)
        self.write(P2, self.page_text(P2) + '\nhttps://example.invalid/\n')
        self.assertNotEqual(gate('--check-growatt-protocol-ii-identity-projection', protocol_ii), 0)
        self.assertEqual(gate('--check-growatt-protocol-ii-source-matrix', self.copies[MATRIX]), 0)


if __name__ == '__main__':
    unittest.main()
