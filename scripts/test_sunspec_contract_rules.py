#!/usr/bin/env python3
"""Prove that every SunSpec contract rule is load-bearing and that bad rule tables fail closed."""
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
RULES = ROOT / 'scripts/sunspec_contract_rules.json'
CHECKER = ROOT / 'scripts/check_sunspec_contract.py'
GATE = ROOT / 'scripts/check_docs.sh'
V2 = 'protocols/sunspec/read-only-core-v2.md'
LICENSING = 'protocols/applicability-and-licensing.md'
NESTED = 'protocols/sunspec/nested-layout-contract-v1.md'
DYNAMIC = 'protocols/sunspec/dynamic-structural-selection-v2.md'

sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location('check_sunspec_contract', CHECKER)
ENGINE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ENGINE)

# Synthetic lines that each forbidden rule of a contract must reject.
PROBES = {
    'v2_contract': ('sunspec.models.candidate.v2', 'Common 1/65 is accepted by the V2 decoder.',
                    'V2 runtime catalog registration is enabled.', 'V2 automatic acquisition is enabled.',
                    'Trailing spaces before the terminator are trimmed.'),
    'v1_model_families': ('sunspec.models.candidate.v2', 'The V2 registry decodes Model 103.',
                          'Model 103 is PROFILE_ADMITTED.', 'Model 123 creates write authority.'),
    'der_trip_lv_template': ('The decoder emits typed facts.', 'A catalog entry exists.',
                             'Profile admission is granted.', 'Product support is claimed.',
                             'The runtime registers it.', 'Model 708 uses this template.',
                             '709 shares the layout.'),
    'der_trip_lv_projection': ('The projection is admitted.', 'The projection has a decoder key.',
                               'The projection is a `SunSpecDecodedChain`.',
                               'The projection authorizes a profile.', 'The projection permits sends.',
                               'The projection writes to a device.', 'The projection creates an operation.',
                               'The projection creates live-system behavior.'),
    'dynamic_structural_selection': ('The candidate creates a decoder key.', 'The candidate is admitted.',
                                     'The candidate emits a typed fact.', 'The candidate causes a new request.',
                                     'The candidate terminates a chain.', 'Model 708 data can form a candidate.',
                                     'Model 709 is a candidate.'),
}

# The extended regular expressions the gate used before the rule table; a line
# they reject must stay rejected by the rule that replaced them.
ORIGINAL_FORBIDDEN = {
    'v2_contract': (
        r'sunspec\.models\.candidate\.v2|Common[[:space:]]+1/65[^.]*V2 decoder'
        '|V2 runtime catalog registration is enabled|V2 automatic acquisition is enabled'
        '|trailing spaces[^.]*trimmed',),
    'v1_model_families': (r'sunspec\.models\.candidate\.v2|V2 registry|PROFILE_ADMITTED|write authority',),
    'der_trip_lv_template': (
        'decoder|catalog|admission|support|runtime|(^|[^0-9])708([^0-9]|$)|(^|[^0-9])709([^0-9]|$)',),
    'der_trip_lv_projection': (
        'projection is admitted|projection has a decoder key|projection is a `SunSpecDecodedChain`'
        '|projection authorizes a profile|projection permits sends|projection writes to a device'
        '|projection creates an operation|projection creates live-system behavior',),
    'dynamic_structural_selection': (
        'candidate creates a decoder key|candidate is admitted|candidate emits a typed fact'
        '|candidate causes a new request|candidate terminates a chain|Model 708[^.]*candidate'
        '|Model 709[^.]*candidate',),
}

# The gate option of each contract that the former shell functions answered.
GATE_OPTIONS = {
    'v2_contract': '--check-sunspec-v2-contract',
    'v2_licensing': '--check-sunspec-v2-licensing',
    'v1_model_families': '--check-sunspec-v1-model-families-contract',
    'nested_layout': '--check-sunspec-nested-layout-contract',
    'der_trip_lv_template': '--check-sunspec-der-trip-lv-template-v2',
    'der_trip_lv_projection': '--check-sunspec-der-trip-lv-typed-fact-projection-v2',
    'dynamic_structural_selection': '--check-sunspec-dynamic-structural-selection-v2',
}


class SunSpecContractRules(unittest.TestCase):
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

    def run_contract(self, contract, rules=RULES):
        page = ENGINE.CONTRACT_PAGES[contract]
        return self.run_checker([contract], {page: self.copies[page]}, rules)

    def run_table(self, data, contract='dynamic_structural_selection'):
        path = self.work / 'rules.json'
        if not isinstance(data, str):
            data = json.dumps(data)
        path.write_text(data, encoding='utf-8')
        return self.run_contract(contract, path).returncode

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

    def gate(self, *args):
        return subprocess.run(['bash', str(GATE), *map(str, args)], stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL, timeout=60).returncode

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
        self.assertEqual(ENGINE.CONTRACTS, {contract for contract, _ in ENGINE.EXPECTED})
        for rule in self.rules:
            self.assertEqual(list(rule), list(ENGINE.FIELDS))
            self.assertEqual(rule['page'], ENGINE.CONTRACT_PAGES[rule['contract']])

    def test_the_full_gate_selects_every_contract(self):
        gate = GATE.read_text(encoding='utf-8')
        selected = re.search(r"^sunspec_contracts='([a-z0-9_,]+)'$", gate, re.MULTILINE).group(1)
        self.assertEqual(sorted(selected.split(',')), sorted(ENGINE.CONTRACTS))
        self.assertEqual(len(selected.split(',')), len(ENGINE.CONTRACTS))

    def test_each_positional_rule_is_load_bearing(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['kind'] == 'forbidden':
                continue
            with self.subTest(contract=rule['contract'], kind=rule['kind'], value=rule['value'][:40]):
                original = self.page_text(rule['page'])
                if rule['kind'] == 'statement':
                    mutated, count = rule['pattern'].subn('[removed]', original)
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
        sectioned = [rule for rule in ENGINE.load_rules(RULES)
                     if rule['section'] is not None and rule['kind'] != 'forbidden']
        self.assertEqual({rule['kind'] for rule in sectioned}, {'row', 'statement'})
        for rule in sectioned:
            with self.subTest(contract=rule['contract'], kind=rule['kind'], value=rule['value'][:40]):
                original = self.page_text(rule['page'])
                if rule['kind'] == 'statement':
                    moved = rule['pattern'].search(original).group(0)
                    body = rule['pattern'].sub('[moved]', original)
                else:
                    moved = rule['value']
                    body = '\n'.join('[moved]' if line == moved else line
                                     for line in original.split('\n'))
                title, rest = body.split('\n', 1)
                self.write(rule['page'], title + '\n\n' + moved + '\n' + rest)
                self.assert_contract_fails(rule['contract'], rule['kind'])
                self.restore(rule['page'])

    def test_a_repeated_or_missing_section_fails_closed(self):
        original = self.page_text(DYNAMIC)
        heading = '## Isolation and no activation'
        for text in (original.replace(heading, heading + '\n\n' + heading),
                     original.replace(heading, '#' + heading)):
            self.write(DYNAMIC, text)
            result = self.run_contract('dynamic_structural_selection')
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('section is not present exactly once', result.stderr)

    def test_each_pin_binds_its_exact_token(self):
        pinned = [rule for rule in ENGINE.load_rules(RULES) if rule['pins']]
        self.assertEqual(len(pinned), 4)
        digits = string.hexdigits[:16]
        swap = str.maketrans(digits, digits[1:] + digits[0])
        for rule in pinned:
            with self.subTest(contract=rule['contract'], value=rule['value'][:40]):
                original = self.page_text(rule['page'])
                match = rule['pattern'].search(original)
                self.assertTrue(ENGINE.pinned_match(rule['pins'], match))
                for index, token in enumerate(match.groups()):
                    for altered in (token.translate(swap), token[:-1], token + '0', token.upper()):
                        start, end = match.span(index + 1)
                        self.write(rule['page'], original[:start] + altered + original[end:])
                        self.assert_contract_fails(rule['contract'], 'statement')
                self.restore(rule['page'])

    def test_each_forbidden_rule_rejects_its_probes(self):
        forbidden = [rule for rule in ENGINE.load_rules(RULES) if rule['kind'] == 'forbidden']
        self.assertEqual({rule['contract'] for rule in forbidden}, set(PROBES))
        for rule in forbidden:
            probes = PROBES[rule['contract']]
            for probe in probes:
                with self.subTest(contract=rule['contract'], probe=probe):
                    self.assertTrue(rule['pattern'].search(probe))
                    self.write(rule['page'], self.page_text(rule['page']) + '\n' + probe + '\n')
                    self.assert_contract_fails(rule['contract'], 'forbidden')
                    self.restore(rule['page'])

    def test_forbidden_rules_reject_every_line_the_original_expressions_rejected(self):
        corpus = [probe for probes in PROBES.values() for probe in probes]
        corpus += ['COMMON\t1/65 then the v2 DECODER', 'common  1/65, v2 decoder', 'x708y', '1708', '7080',
                   'é709', 'model 709 – CANDIDATE', 'Model 708. A candidate', 'TRAILING SPACES ARE TRIMMED',
                   'Decoders', 'write authority', 'Projection Is Admitted']
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
                    self.assertTrue(found.stdout)
                    for line in found.stdout.split('\n')[:-1]:
                        with self.subTest(contract=contract, locale=locale, line=line[:60]):
                            self.assertTrue(any(p.search(line) for p in patterns))

    def test_missing_empty_and_malformed_tables_fail_closed(self):
        missing = self.run_contract('dynamic_structural_selection', self.work / 'missing.json')
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
            'kind outside contract': lambda d: next(
                r for r in d['rules'] if r['contract'] == 'v1_core_page').update(kind='statement'),
            'unknown contract': lambda d: d['rules'][0].update(contract='unknown'),
            'other contract of another page': lambda d: d['rules'][0].update(contract='nested_layout'),
            'page outside the family': lambda d: d['rules'][0].update(page='protocols/tesla/tedapi.md'),
            'page of another contract': lambda d: d['rules'][0].update(page=NESTED),
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
            ('nested_layout', 'heading', 'value'): 'Scope',
            ('v2_contract', 'row', 'value'): '| 701 | 153',
            ('v2_contract', 'row', 'section'): 'Model scope',
            ('v2_contract', 'statement', 'value'): 'Model 801 remains  excluded as deprecated.',
            ('v2_contract', 'forbidden', 'value'): 'candidate|(',
        }
        for (contract, kind, field), value in cases.items():
            with self.subTest(kind=kind, field=field):
                data = self.edited(lambda d: first(d, contract, kind).update({field: value}))
                self.assertNotEqual(self.run_table(data, contract), 0)
        pinned = next(r for r in self.rules if '<pin:' in r['value'])
        commitment = re.search(r'<pin:([^>]+)>', pinned['value']).group(1)
        for value in ('`sunspec.models@<pin:short>-v2`', '`sunspec.models@<pin:' + 'A' * 42 + '>-v2`',
                      '`sunspec.models@<pin:-v2`', '`sunspec.models@<pin:' + commitment + '=>-v2`'):
            with self.subTest(pin=value):
                data = self.edited(lambda d: next(
                    r for r in d['rules'] if r['value'] == pinned['value']).update(value=value))
                self.assertNotEqual(self.run_table(data, pinned['contract']), 0)
        for kind in ('row', 'heading', 'forbidden'):
            with self.subTest(pin_in=kind):
                rule = next(r for r in self.rules if r['contract'] == 'v2_contract' and r['kind'] == kind)
                value = {'row': '| <pin:%s> | 66 | x |', 'heading': '## <pin:%s>',
                         'forbidden': '<pin:%s>'}[kind] % commitment
                data = self.edited(lambda d: next(
                    r for r in d['rules'] if r['value'] == rule['value']).update(value=value))
                self.assertNotEqual(self.run_table(data, 'v2_contract'), 0)

    def test_loader_rejects_bad_rules_even_when_the_counts_would_match(self):
        """Isolate the loader checks that the count table would otherwise mask."""
        path = self.work / 'rules.json'
        first = self.rules[0]
        statement = next(r for r in self.rules if r['kind'] == 'statement')
        cases = {
            'unknown kind': ({(first['contract'], 'unknown'): 1},
                             lambda d: d['rules'].append(dict(first, kind='unknown', value='x'))),
            'duplicate rule': ({(first['contract'], first['kind']): 9},
                               lambda d: d['rules'].append(dict(first))),
            'non-normalized statement': ({}, lambda d: next(
                r for r in d['rules'] if r['value'] == statement['value']).update(value='No  send.')),
            'page of a sibling contract': ({}, lambda d: next(
                r for r in d['rules'] if r['value'] == statement['value']).update(page=LICENSING)),
        }
        for name, (extra, mutate) in cases.items():
            with self.subTest(case=name):
                path.write_text(json.dumps(self.edited(mutate)), encoding='utf-8')
                expected = dict(ENGINE.EXPECTED)
                expected.update(extra)
                with mock.patch.object(ENGINE, 'EXPECTED', expected):
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
        """Vary every key field of one rule; each change is caught.

        contract: moving the rule to another contract (another page) is rejected by the loader.
        page: pointing the rule at another page is rejected by the loader.
        section: a rule bound to the wrong section reports a missing statement.
        kind: the statement read as a forbidden pattern rejects the page.
        value: a changed statement is missing from the page.
        """
        target = next(i for i, r in enumerate(self.rules) if r['contract'] == 'dynamic_structural_selection'
                      and r['value'] == 'A candidate does not terminate a chain.')
        variations = {
            'contract': ('nested_layout', 'loader'),
            'page': (V2, 'loader'),
            'section': ('## Isolation and no activation', 'statement'),
            'kind': ('forbidden', 'forbidden'),
            'value': (self.rules[target]['value'] + ' Synthetic.', 'statement'),
        }
        self.assertEqual(set(variations), set(ENGINE.FIELDS[:5]))
        path = self.work / 'rules.json'
        for field, (value, caught_by) in variations.items():
            with self.subTest(field=field):
                data = self.edited(lambda d, f=field, v=value: d['rules'][target].update({f: v}))
                self.assertNotEqual(self.run_table(data), 0)
                path.write_text(json.dumps(data), encoding='utf-8')
                counts = Counter((r['contract'], r['kind']) for r in data['rules'])
                with mock.patch.object(ENGINE, 'EXPECTED', dict(counts)):
                    if caught_by == 'loader':
                        with self.assertRaises(ENGINE.RuleError):
                            ENGINE.load_rules(path)
                        continue
                    rules = ENGINE.load_rules(path)
                lines = self.page_text(DYNAMIC).split('\n')
                group = [r for r in rules if r['contract'] == 'dynamic_structural_selection']
                failures = ENGINE.check_page(group, lines)
                self.assertEqual([rule['kind'] for rule, _ in failures], [caught_by])

    def test_contracts_sharing_a_page_keep_their_rules_apart(self):
        """Moving a rule between the two contracts of the applicability page is caught."""
        target = next(i for i, r in enumerate(self.rules) if r['contract'] == 'v2_licensing'
                      and r['kind'] == 'statement' and not ENGINE.PIN.search(r['value']))
        data = self.edited(lambda d: d['rules'][target].update(contract='licensing_page'))
        self.assertNotEqual(self.run_table(data, 'licensing_page'), 0)
        self.assertNotEqual(self.run_table(data, 'v2_licensing'), 0)

    def test_command_line_selection_fails_closed(self):
        dynamic = {DYNAMIC: self.copies[DYNAMIC]}
        contract = 'dynamic_structural_selection'
        self.assertEqual(self.run_checker([contract], dynamic).returncode, 0)
        self.assertNotEqual(self.run_checker(['unknown'], dynamic).returncode, 0)
        self.assertNotEqual(self.run_checker([contract, contract], dynamic).returncode, 0)
        self.assertNotEqual(self.run_checker([contract], {}).returncode, 0)
        self.assertNotEqual(self.run_checker([contract], dict(dynamic, **{V2: self.copies[V2]})).returncode, 0)
        malformed = subprocess.run(['python3', '-B', str(CHECKER), str(RULES), contract, DYNAMIC],
                                   capture_output=True, timeout=30)
        self.assertNotEqual(malformed.returncode, 0)
        self.assertNotEqual(self.run_checker([contract], {DYNAMIC: self.work / 'absent.md'}).returncode, 0)
        licensing = {LICENSING: self.copies[LICENSING]}
        self.assertEqual(self.run_checker(['v2_licensing', 'licensing_page'], licensing).returncode, 0)

    def test_gate_options_keep_their_contract_scope(self):
        for contract, option in GATE_OPTIONS.items():
            with self.subTest(option=option):
                self.assertEqual(self.gate(option, self.copies[ENGINE.CONTRACT_PAGES[contract]]), 0)
        licensing = self.copies[LICENSING]
        self.write(LICENSING, self.page_text(LICENSING).replace('## Admission rules', '## Rules'))
        self.assertEqual(self.gate('--check-sunspec-v2-licensing', licensing), 0)
        self.assertNotEqual(self.run_contract('licensing_page').returncode, 0)
        self.restore(LICENSING)
        self.write(LICENSING, self.page_text(LICENSING).replace(
            'That upstream license applies to', 'The upstream license covers'))
        self.assertNotEqual(self.gate('--check-sunspec-v2-licensing', licensing), 0)
        for contract in ('v2_contract', 'v1_model_families', 'nested_layout', 'der_trip_lv_template',
                         'der_trip_lv_projection', 'dynamic_structural_selection'):
            with self.subTest(public_protocol=contract):
                page = ENGINE.CONTRACT_PAGES[contract]
                self.write(page, self.page_text(page) + '\nSee https://example.invalid/.\n')
                self.assertEqual(self.run_contract(contract).returncode, 0)
                self.assertNotEqual(self.gate(GATE_OPTIONS[contract], self.copies[page]), 0)
                self.restore(page)


if __name__ == '__main__':
    unittest.main()
