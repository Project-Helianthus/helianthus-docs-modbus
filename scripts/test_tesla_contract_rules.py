#!/usr/bin/env python3
"""Prove that every Tesla contract rule is load-bearing and that bad rule tables fail closed."""
import importlib.util
import json
import re
import string
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parent.parent
RULES = ROOT / 'scripts/tesla_contract_rules.json'
CHECKER = ROOT / 'scripts/check_tesla_contract.py'
GATE = ROOT / 'scripts/check_docs.sh'

sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location('check_tesla_contract', CHECKER)
ENGINE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ENGINE)

# One synthetic line per contract that carries forbidden rules.
PROBES = {
    'legacy_public_protocol': 'These canonical facts are synthetic.',
    'gen3_public_protocol': 'A private capture is synthetic.',
    'generation': 'Minimum version 24.28.3 qualifies this profile.',
    'current_limit_operation': 'gateway.example.internal:1502',
    'read_acquisition': '192.0.2.1',
    'evse_scope': 'Pairing is available.',
}


class TeslaContractRules(unittest.TestCase):
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

    def run_table(self, data, contract='tedapi'):
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
        for rule in self.rules:
            self.assertEqual(list(rule), list(ENGINE.FIELDS))

    def test_each_positional_rule_is_load_bearing(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['kind'] not in ('heading', 'row', 'statement'):
                continue
            with self.subTest(contract=rule['contract'], kind=rule['kind'], value=rule['value'][:40]):
                path = self.copies[rule['page']]
                original = path.read_text(encoding='utf-8')
                if rule['kind'] == 'statement':
                    mutated, count = rule['pattern'].subn('[removed]', original)
                else:
                    lines = original.split('\n')
                    count = lines.count(rule['value'])
                    mutated = '\n'.join('[removed]' if line == rule['value'] else line
                                        for line in lines)
                self.assertGreater(count, 0)
                path.write_text(mutated, encoding='utf-8')
                self.assertNotEqual(self.run_contract(rule['contract']).returncode, 0)
                self.restore(rule['page'])

    def test_each_sectioned_rule_is_scoped_to_its_section(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['section'] is None or rule['kind'] not in ('heading', 'row', 'statement'):
                continue
            with self.subTest(contract=rule['contract'], kind=rule['kind'], value=rule['value'][:40]):
                path = self.copies[rule['page']]
                original = path.read_text(encoding='utf-8')
                if rule['kind'] == 'statement':
                    moved = rule['pattern'].search(original).group(0)
                    body = rule['pattern'].sub('[moved]', original)
                else:
                    moved = rule['value']
                    body = '\n'.join('[moved]' if line == moved else line
                                     for line in original.split('\n'))
                title, rest = body.split('\n', 1)
                path.write_text(title + '\n\n' + moved + '\n' + rest, encoding='utf-8')
                self.assertNotEqual(self.run_contract(rule['contract']).returncode, 0)
                self.restore(rule['page'])

    def test_each_pin_binds_its_exact_token(self):
        pinned = [rule for rule in ENGINE.load_rules(RULES) if rule.get('pins')]
        self.assertEqual(len(pinned), 4)
        digits = string.hexdigits[:16]
        swap = str.maketrans(digits, digits[1:] + digits[0])
        for rule in pinned:
            with self.subTest(contract=rule['contract'], value=rule['value'][:40]):
                path = self.copies[rule['page']]
                original = path.read_text(encoding='utf-8')
                match = rule['pattern'].search(original)
                tokens = match.groups()
                for index in range(len(tokens)):
                    altered = match.group(0)
                    start = match.start(index + 1) - match.start(0)
                    end = match.end(index + 1) - match.start(0)
                    altered = altered[:start] + tokens[index].translate(swap) + altered[end:]
                    path.write_text(original.replace(match.group(0), altered), encoding='utf-8')
                    self.assertNotEqual(self.run_contract(rule['contract']).returncode, 0)
                self.restore(rule['page'])

    def test_each_forbidden_rule_rejects_its_probe(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['kind'] != 'forbidden':
                continue
            with self.subTest(contract=rule['contract']):
                probe = PROBES[rule['contract']]
                self.assertTrue(rule['pattern'].search(probe))
                path = self.copies[rule['page']]
                path.write_text(path.read_text(encoding='utf-8') + '\n' + probe + '\n',
                                encoding='utf-8')
                self.assertNotEqual(self.run_contract(rule['contract']).returncode, 0)
                self.restore(rule['page'])

    def test_evse_scope_exempts_only_the_lowercase_current_limit_phrases(self):
        rule = next(r for r in ENGINE.load_rules(RULES)
                    if r['contract'] == 'evse_scope' and r['kind'] == 'forbidden')
        self.assertIsNone(rule['pattern'].search('| WC provisional current limit |'))
        self.assertIsNone(rule['pattern'].search('| WC provisional readback |'))
        for line in ('A provisional mode is available.', 'Provisional current is available.',
                     'Network provisioning is available.'):
            self.assertTrue(rule['pattern'].search(line), line)

    def test_allowed_digests_admit_only_committed_values(self):
        page = self.copies['protocols/tesla/gen3-hsc-rtu.md']
        original = page.read_text(encoding='utf-8')
        known = re.search(r'[0-9a-f]{64}', original).group(0)
        page.write_text(original + '\nRepeated: `' + known + '`.\n', encoding='utf-8')
        self.assertEqual(self.run_contract('gen3_public_protocol').returncode, 0)
        page.write_text(original + '\nSynthetic: `' + 'd' * 64 + '`.\n', encoding='utf-8')
        self.assertNotEqual(self.run_contract('gen3_public_protocol').returncode, 0)

    def test_source_locators_are_exactly_the_committed_set(self):
        page = self.copies['protocols/tesla/legacy-wall-connector-rs485.md']
        original = page.read_text(encoding='utf-8')
        locators = re.findall(r'https://[^)\n]+', original)
        self.assertEqual(len(set(locators)), 4)
        for locator in locators:
            with self.subTest(locator=ENGINE.commitment(locator)):
                page.write_text(original.replace(locator, ''), encoding='utf-8')
                self.assertNotEqual(self.run_contract('legacy_public_protocol').returncode, 0)
        page.write_text(original + '\n[synthetic](https://example.invalid/legacy)\n', encoding='utf-8')
        self.assertNotEqual(self.run_contract('legacy_public_protocol').returncode, 0)

    def test_missing_empty_and_malformed_tables_fail_closed(self):
        missing = self.run_contract('tedapi', self.work / 'missing.json')
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
            'kind outside contract': lambda d: d['rules'][0].update(kind='allowed_digest'),
            'unknown contract': lambda d: d['rules'][0].update(contract='unknown'),
            'other known contract': lambda d: d['rules'][0].update(contract='read_acquisition'),
            'page outside the family': lambda d: d['rules'][0].update(page='protocols/other.md'),
            'section not a heading': lambda d: d['rules'][0].update(section='Scope'),
            'empty value': lambda d: d['rules'][0].update(value=''),
            'non-string value': lambda d: d['rules'][0].update(value=7),
            'empty reason': lambda d: d['rules'][0].update(reason=''),
            'padded reason': lambda d: d['rules'][0].update(reason=' why'),
            'duplicate rule': lambda d: d['rules'].append(dict(d['rules'][0])),
            'removed rule': lambda d: d['rules'].pop(),
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
            ('evse_scope', 'heading'): 'FC100 EVSE operation registry',
            ('evse_scope', 'row'): 'Common system information | 4',
            ('evse_scope', 'statement'): '| GetVitals  |',
            ('evse_scope', 'forbidden'): 'wifi|(',
            ('gen3_public_protocol', 'allowed_digest'): 'not-a-commitment',
            ('legacy_public_protocol', 'source_locator'): 'https://example.invalid/',
        }
        for (contract, kind), value in cases.items():
            with self.subTest(kind=kind):
                data = self.edited(lambda d: first(d, contract, kind).update(value=value))
                self.assertNotEqual(self.run_table(data, contract), 0)
        for value in ('at revision `<pin:short>` of its branch.',
                      'at revision `<pin:' + 'A' * 42 + '>` of its branch.',
                      'at revision `<pin:` of its branch.'):
            with self.subTest(pin=value):
                data = self.edited(lambda d: next(
                    r for r in d['rules'] if '<pin:' in r['value']).update(value=value))
                self.assertNotEqual(self.run_table(data, 'read_acquisition'), 0)
        data = self.edited(lambda d: first(d, 'gen3_public_protocol', 'allowed_digest').update(
            section='## Qualification'))
        self.assertNotEqual(self.run_table(data, 'gen3_public_protocol'), 0)

    def test_loader_rejects_bad_rules_even_when_the_counts_would_match(self):
        """Isolate the loader checks that the count table would otherwise mask."""
        path = self.work / 'rules.json'
        first = self.rules[0]
        cases = {
            'unknown kind': ({(first['contract'], 'unknown'): 1},
                             lambda d: d['rules'].append(dict(
                                 first, kind='unknown', section=None,
                                 value=ENGINE.commitment('synthetic')))),
            'duplicate rule': ({(first['contract'], first['kind']): 2},
                               lambda d: d['rules'].append(dict(first))),
            'non-normalized statement': ({}, lambda d: next(
                r for r in d['rules'] if r['kind'] == 'statement').update(value='No  mutation path.')),
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
        sections = {rule['section'] for rule in self.rules}
        for rule in self.rules:
            if rule['kind'] != 'heading' or rule['value'] in sections:
                continue
            with self.subTest(contract=rule['contract'], heading=rule['value']):
                path = self.copies[rule['page']]
                original = path.read_text(encoding='utf-8')
                fenced = '```text\n' + rule['value'] + '\n```'
                lines = original.split('\n')
                self.assertEqual(lines.count(rule['value']), 1)
                path.write_text('\n'.join(fenced if line == rule['value'] else line
                                          for line in lines), encoding='utf-8')
                self.assertNotEqual(self.run_contract(rule['contract']).returncode, 0)
                self.restore(rule['page'])

    def test_each_rule_key_field_changes_the_outcome(self):
        """Vary contract, page, section, kind and value of one rule; each must fail."""
        target = next(i for i, r in enumerate(self.rules)
                      if r['contract'] == 'legacy_evse_current' and r['kind'] == 'statement')
        variations = {
            'contract': 'gen3_evse_current_limit',
            'page': 'protocols/tesla/gen3-hsc-rtu.md',
            'section': '## Compatibility',
            'kind': 'row',
            'value': self.rules[target]['value'] + ' Synthetic.',
        }
        for field, value in variations.items():
            with self.subTest(field=field):
                data = self.edited(lambda d, f=field, v=value: d['rules'][target].update({f: v}))
                self.assertNotEqual(self.run_table(data, 'legacy_evse_current'), 0)

    def test_command_line_selection_fails_closed(self):
        tedapi = {'protocols/tesla/tedapi.md': self.copies['protocols/tesla/tedapi.md']}
        self.assertEqual(self.run_checker(['tedapi'], tedapi).returncode, 0)
        self.assertNotEqual(self.run_checker(['unknown'], tedapi).returncode, 0)
        self.assertNotEqual(self.run_checker(['tedapi', 'tedapi'], tedapi).returncode, 0)
        self.assertNotEqual(self.run_checker(['tedapi'], {}).returncode, 0)
        extra = dict(tedapi)
        extra['protocols/tesla/gen3-hsc-rtu.md'] = self.copies['protocols/tesla/gen3-hsc-rtu.md']
        self.assertNotEqual(self.run_checker(['tedapi'], extra).returncode, 0)
        malformed = subprocess.run(['python3', '-B', str(CHECKER), str(RULES), 'tedapi',
                                    'protocols/tesla/tedapi.md'], capture_output=True, timeout=30)
        self.assertNotEqual(malformed.returncode, 0)
        missing = {'protocols/tesla/tedapi.md': self.work / 'absent.md'}
        self.assertNotEqual(self.run_checker(['tedapi'], missing).returncode, 0)

    def test_gate_options_keep_their_contract_scope(self):
        legacy = self.copies['protocols/tesla/legacy-wall-connector-rs485.md']
        gen3 = self.copies['protocols/tesla/gen3-hsc-rtu.md']

        def gate(*args):
            return subprocess.run(['bash', str(GATE), *map(str, args)], stdout=subprocess.DEVNULL,
                                  stderr=subprocess.DEVNULL, timeout=60).returncode

        original = gen3.read_text(encoding='utf-8')
        gen3.write_text(original.replace('Each object is validated independently.', ''),
                        encoding='utf-8')
        self.assertNotEqual(gate('--check-tesla-gen3-evse-current-limit-mcp-projection', gen3), 0)
        self.assertEqual(gate('--check-tesla-gen3-evse-current-limit-wire-evidence', gen3), 0)
        self.assertEqual(gate('--check-tesla-gen3-evse-current-limit-contract', gen3), 0)
        self.assertEqual(gate('--check-tesla-generation-contracts', legacy, gen3), 0)
        self.assertNotEqual(gate('--check-tesla-generation-contracts', legacy), 0)


if __name__ == '__main__':
    unittest.main()
