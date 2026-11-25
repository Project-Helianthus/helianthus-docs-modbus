#!/usr/bin/env python3
"""Prove that every Tesla contract rule is load-bearing and that bad rule tables fail closed."""
import hashlib
import importlib.util
import json
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
TESLA = 'protocols/tesla/'
TEDAPI = TESLA + 'tedapi-specification.md'
RS485 = TESLA + 'rs485-site-controller-protocol.md'

sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location('check_tesla_contract', CHECKER)
ENGINE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ENGINE)

# One synthetic line per contract that carries forbidden rules.
PROBES = {
    'legacy_public_protocol': 'These canonical facts are synthetic.',
    'generation': 'Minimum version 24.28.3 qualifies this profile.',
    'current_limit_operation': 'gateway.example.internal:1502',
    'read_acquisition': '192.0.2.1',
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

    def test_each_forbidden_rule_rejects_its_probe(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['kind'] != 'forbidden':
                continue
            with self.subTest(contract=rule['contract'], page=rule['page']):
                if rule['value'].startswith('(?:https?|ftp)'):
                    probe = 'A private capture is synthetic.'
                else:
                    probe = PROBES[rule['contract']]
                self.assertTrue(rule['pattern'].search(probe))
                path = self.copies[rule['page']]
                path.write_text(path.read_text(encoding='utf-8') + '\n' + probe + '\n',
                                encoding='utf-8')
                result = self.run_contract(rule['contract'])
                self.assertEqual(result.returncode, 1)
                self.assertIn(' forbidden ', result.stderr)
                self.restore(rule['page'])

    def test_publication_rejects_non_protocol_material(self):
        digest = hashlib.sha256(b'synthetic publication fixture').hexdigest()
        probes = (
            '[fixture](https://example.invalid/specimen)',
            digest,
            '/Users/example/work/specimen',
            r'C:\Users\example\work\specimen',
            'The field was derived by disassembly.',
            'Reproduced from a firmware dump.',
        )
        pages = ((RS485, 'rs485_specification'), (TEDAPI, 'tedapi'),
                 (TESLA + 'gen3-hsc-rtu.md', 'generation'), (TESLA + 'tedapi.md', 'tedapi_landing'))
        for page, contract in pages:
            document = self.copies[page]
            original = document.read_text(encoding='utf-8')
            for probe in probes:
                with self.subTest(page=page, probe=probe):
                    document.write_text(original + '\n' + probe + '\n', encoding='utf-8')
                    result = self.run_contract(contract)
                    self.assertEqual(result.returncode, 1)
                    self.assertIn(' forbidden ', result.stderr)
            self.restore(page)

    def test_schema_and_access_vocabulary_is_permitted(self):
        path = self.copies[TEDAPI]
        with path.open('a', encoding='utf-8') as page:
            page.write('\nHTTP, service access point, installation settings, Wi-Fi configuration, '
                       'authentication, protobuf schema and SHA256_ECDSA_ASN1.\n')
        result = self.run_contract('tedapi')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_default_invocation_checks_all_pages_from_another_directory(self):
        result = subprocess.run(['python3', '-B', str(CHECKER)], cwd=self.work,
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(ENGINE.pages_for(ENGINE.CONTRACTS), set(self.pages))

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
            'kind outside contract': lambda d: d['rules'][0].update(kind='heading'),
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
            ('tedapi', 'heading'): 'Transports and envelopes',
            ('tedapi', 'row'): 'Family/tag | Request',
            ('tedapi', 'statement'): 'The  request',
            ('tedapi', 'forbidden'): 'example|(',
        }
        for (contract, kind), value in cases.items():
            with self.subTest(kind=kind):
                data = self.edited(lambda d: first(d, contract, kind).update(value=value))
                self.assertNotEqual(self.run_table(data, contract), 0)
        data = self.edited(lambda d: first(d, 'tedapi', 'row').update(section=None))
        self.assertNotEqual(self.run_table(data, 'tedapi'), 0)

    def test_loader_rejects_bad_rules_even_when_the_counts_would_match(self):
        path = self.work / 'rules.json'
        first = self.rules[0]
        contract = first['contract']
        for kind in ('unknown', 'allowed_digest', 'source_locator'):
            with self.subTest(kind=kind):
                changed = self.edited(lambda d: d['rules'].append(dict(first, kind=kind)))
                path.write_text(json.dumps(changed), encoding='utf-8')
                with mock.patch.dict(ENGINE.EXPECTED, {(contract, kind): 1}):
                    with self.assertRaisesRegex(ENGINE.RuleError, 'unknown rule kind'):
                        ENGINE.load_rules(path)

    def test_loader_requires_both_generation_pages_even_with_matching_counts(self):
        path = self.work / 'rules.json'
        for name in (ENGINE.LEGACY, ENGINE.HSC):
            with self.subTest(page=name):
                data = self.edited(lambda d: d.update(rules=[
                    dict(rule, page=TESLA + name, value=rule['value'] + ' Alternate')
                    if rule['contract'] == 'generation' and rule['page'] != TESLA + name
                    and rule['kind'] != 'heading' else rule for rule in d['rules']]))
                for i, rule in enumerate(data['rules']):
                    if (rule['contract'], rule['kind']) == ('generation', 'heading'):
                        rule.update(page=TESLA + name, value=f'## Synthetic heading {i}')
                path.write_text(json.dumps(data), encoding='utf-8')
                with self.assertRaisesRegex(ENGINE.RuleError, 'every required contract page'):
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

    def test_fence_types_hide_headings_and_close_only_on_a_matching_fence(self):
        hidden = ('~~~', '~~~~text', '```', '````', '  ```text', '   ~~~')
        for opener in hidden:
            with self.subTest(opener=opener):
                lines = [opener, '## A', opener.strip()[:3] * 2 + opener.strip()[0], '## B']
                self.assertEqual([line for _, _, line in ENGINE.headings(lines)], ['## B'])
        # A different fence character, or a shorter run, does not close the block.
        self.assertEqual(ENGINE.headings(['~~~', '```', '## A', '~~', '~~~', '## B']),
                         [(5, 2, '## B')])
        self.assertEqual(ENGINE.headings(['````', '```', '## A', '````', '## B']),
                         [(4, 2, '## B')])
        # A backtick fence cannot carry backticks in its info string; four spaces is code.
        self.assertEqual([line for _, _, line in ENGINE.headings(['``` a`b', '## A'])], ['## A'])
        self.assertEqual([line for _, _, line in ENGINE.headings(['    ```', '## A'])], ['## A'])

    def test_tilde_fenced_sections_do_not_satisfy_rules(self):
        rule = next(rule for rule in ENGINE.load_rules(RULES)
                    if rule['kind'] == 'heading' and rule['section'] is None)
        path = self.copies[rule['page']]
        lines = path.read_text(encoding='utf-8').split('\n')
        self.assertEqual(lines.count(rule['value']), 1)
        path.write_text('\n'.join('~~~\n' + line + '\n~~~' if line == rule['value'] else line
                                  for line in lines), encoding='utf-8')
        self.assertNotEqual(self.run_contract(rule['contract']).returncode, 0)

    def test_duplicate_identity_uses_each_key_field_but_not_reason(self):
        path = self.work / 'rules.json'
        first = dict(contract='generation', page=TESLA + ENGINE.LEGACY, section='## One',
                     kind='statement', value='## Synthetic', reason='Test rule identity.')
        changes = dict(contract='legacy_evse_current', page=TESLA + ENGINE.HSC,
                       section='## Two', kind='heading', value='## Different',
                       reason='A different explanation is not a distinct rule.')
        for field, value in changes.items():
            with self.subTest(field=field):
                second = dict(first, **{field: value})
                rules = [first, second]
                # Keep mandatory pages present, independently of the two rule keys.
                if field != 'page':
                    rules.append(dict(first, page=TESLA + ENGINE.HSC, value='Unique filler.'))
                expected = {}
                for rule in rules:
                    key = rule['contract'], rule['kind']
                    expected[key] = expected.get(key, 0) + 1
                path.write_text(json.dumps(dict(version=1, rules=rules)), encoding='utf-8')
                with mock.patch.object(ENGINE, 'EXPECTED', expected), mock.patch.object(
                        ENGINE, 'CONTRACTS', frozenset(c for c, _ in expected)):
                    if field == 'reason':
                        with self.assertRaisesRegex(ENGINE.RuleError, 'duplicate rule'):
                            ENGINE.load_rules(path)
                    else:
                        self.assertEqual(len(ENGINE.load_rules(path)), len(rules))

    def test_command_line_selection_fails_closed(self):
        tedapi = {TEDAPI: self.copies[TEDAPI]}
        self.assertEqual(self.run_checker(['tedapi'], tedapi).returncode, 0)
        self.assertNotEqual(self.run_checker(['unknown'], tedapi).returncode, 0)
        self.assertNotEqual(self.run_checker(['tedapi', 'tedapi'], tedapi).returncode, 0)
        self.assertNotEqual(self.run_checker(['tedapi'], {}).returncode, 0)
        extra = dict(tedapi)
        extra['protocols/tesla/gen3-hsc-rtu.md'] = self.copies['protocols/tesla/gen3-hsc-rtu.md']
        self.assertNotEqual(self.run_checker(['tedapi'], extra).returncode, 0)
        malformed = subprocess.run(['python3', '-B', str(CHECKER), str(RULES), 'tedapi',
                                    TEDAPI], capture_output=True, timeout=30)
        self.assertNotEqual(malformed.returncode, 0)
        missing = {TEDAPI: self.work / 'absent.md'}
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
        self.assertEqual(gate('--check-tesla-gen3-evse-current-limit-wire-evidence', self.copies[TEDAPI]), 0)
        self.assertEqual(gate('--check-tesla-gen3-evse-current-limit-contract', gen3), 0)
        self.assertEqual(gate('--check-tesla-generation-contracts', legacy, gen3), 0)
        self.assertEqual(gate('--check-tesla-rs485-specification', self.copies[RS485]), 0)
        self.assertEqual(gate('--check-tesla-tedapi-contract', self.copies[TEDAPI]), 0)
        self.assertEqual(gate('--check-tesla-tedapi-landing', self.copies[TESLA + 'tedapi.md']), 0)
        self.assertNotEqual(gate('--check-tesla-generation-contracts', legacy), 0)

    def test_qualified_provisional_set_needs_no_action_time_confirmation(self):
        """A qualified explicit set or withdrawal is admitted without action-time confirmation.

        Restoring an action-time confirmation requirement fails the contract.
        Separate operator approval stays only for an agent or test on a real
        installation. The bench confirmation sentence stays a bench fact.
        """
        cases = (
            ('protocols/tesla/gen3-current-limit-operation-v1.md', 'current_limit_operation'),
            ('protocols/tesla/gen3-hsc-rtu.md', 'generation'),
            ('protocols/tesla/gen3-semreg-mapping-v1.md', 'gen3_semreg_mapping'),
        )
        blocked = (
            'still requires explicit operator confirmation at action time',
            'an ordinary live caller, including a gateway or MCP caller, is not exempt',
            'A live-device write requires explicit operator confirmation at action time',
        )
        for page, contract in cases:
            with self.subTest(page=page):
                text = self.copies[page].read_text(encoding='utf-8')
                normalized = ' '.join(text.split())
                self.assertIn('admitted without explicit operator confirmation at action time', normalized)
                self.assertIn('only for an agent or test acting on a real installation', normalized)
                for phrase in blocked:
                    self.assertNotIn(phrase, text)
                unsafe = text.replace('explicit operator confirmation at action time',
                                      'cached permission at action time')
                self.assertNotEqual(unsafe, text)
                self.copies[page].write_text(unsafe, encoding='utf-8')
                self.assertNotEqual(self.run_contract(contract).returncode, 0)
                self.restore(page)


if __name__ == '__main__':
    unittest.main()
