#!/usr/bin/env python3
"""Prove that every Huawei, Fronius, private-function and S-Dongle rule is load-bearing and that bad rule tables fail closed."""
import importlib.util
import json
import re
from collections import Counter
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parent.parent
RULES = ROOT / 'scripts/vendor_contract_rules.json'
CHECKER = ROOT / 'scripts/check_vendor_contract.py'
GATE = ROOT / 'scripts/check_docs.sh'
PRIVATE = 'protocols/modbus/private-function-codes.md'
FRONIUS = 'protocols/fronius/qualification-readiness-v1.md'
HUAWEI = 'protocols/huawei/qualification-readiness-v1.md'
DISPOSITION = 'protocols/huawei/inverter-battery-readonly-v1.md'
SUN2000 = '### SUN2000 decision rows'
LUNA2000 = '### LUNA2000 decision rows'

sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location('check_vendor_contract', CHECKER)
ENGINE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ENGINE)

# Synthetic lines that each forbidden rule of a contract must reject.
PROBES = {
    'fronius_qualification': ('live_qualified=true', 'automatic_runtime_admission: true',
                              'write_authority = true', 'A support claim is established.',
                              'A partial positive result is permitted.'),
    'huawei_qualification': ('automatic_runtime_admission=true', 'live_qualified: true',
                             'support_claim=true', 'write_authority  true', 'automatic_request_count=3',
                             'fallback_attempted=true',
                             'Missing or unavailable native values are reported as numeric zero.'),
    'huawei_disposition': ('Registers are inferred from SmartLogger.', 'SUN2000 is supported.',
                           'LUNA2000 is qualified.', 'Both classes are admitted.', 'FC0x41 is permitted.',
                           'FC0x17 is enabled.', 'An absent group yields zero.',
                           'An absent group reports numeric zero.'),
}

# The extended regular expressions the gate used before the rule table; a line
# they reject must stay rejected by the rule that replaced them.
ORIGINAL_FORBIDDEN = {
    'fronius_qualification': (
        'live_qualified[=: ]+true|automatic_runtime_admission[=: ]+true|write_authority[=: ]+true'
        '|support claim is established|partial positive result is permitted',),
    'huawei_qualification': (
        'automatic_runtime_admission[=: ]+true|live_qualified[=: ]+true|support_claim[=: ]+true'
        '|write_authority[=: ]+true|automatic_request_count[=: ]+[1-9]|fallback_attempted[=: ]+true'
        '|missing or unavailable native values.*numeric zero',),
    'huawei_disposition': (
        r'registers? (is|are) (inferred|assumed) from|(is|are) (supported|qualified|admitted)\.'
        '|FC0x(41|17) (is|are) (permitted|allowed|enabled)|absent group (yields|reports) (numeric )?zero',),
}

# The shell pipeline that compared the decision rows before the rule table.
ORIGINAL_DECISION_ROWS = (
    "sed -n '/^### SUN2000 decision rows$/,/^### LUNA2000 decision rows$/p' \"$1\" "
    "| sed -n 's/^\\(| `[a-z_]*` | `[A-Z_]*` |\\).*/\\1/p'",
    "sed -n '/^### LUNA2000 decision rows$/,/^## Optional groups$/p' \"$1\" "
    "| sed -n 's/^\\(| `[a-z_]*` | `[A-Z_]*` |\\).*/\\1/p'",
)

# The gate option of each contract that the former shell functions answered.
GATE_OPTIONS = {
    'private_function': '--check-private-function-contract',
    'fronius_qualification': '--check-fronius-qualification-readiness',
    'huawei_qualification': '--check-huawei-qualification-readiness',
    'huawei_disposition': '--check-huawei-inverter-battery-disposition',
}


class VendorContractRules(unittest.TestCase):
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
            copy = self.work / page.replace('/', '-')
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

    def run_table(self, data, contract='huawei_disposition'):
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

    def decision_failures(self, text):
        rules = [rule for rule in ENGINE.load_rules(RULES) if rule['kind'] == 'decision_rows']
        return {rule['section'] for rule, _ in ENGINE.check_page(rules, text.split('\n'))}

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

    def test_the_full_gate_selects_every_contract_and_holds_no_literal_check(self):
        gate = GATE.read_text(encoding='utf-8')
        selected = re.search(r"^vendor_contracts='([a-z0-9_,]+)'$", gate, re.MULTILINE).group(1)
        self.assertEqual(sorted(selected.split(',')), sorted(ENGINE.CONTRACTS))
        self.assertEqual(len(selected.split(',')), len(ENGINE.CONTRACTS))
        self.assertEqual(re.findall(r'grep -[a-zA-Z]*F', gate), [])

    def test_each_positional_rule_is_load_bearing(self):
        for rule in ENGINE.load_rules(RULES):
            if rule['kind'] == 'forbidden':
                continue
            with self.subTest(contract=rule['contract'], kind=rule['kind'], value=rule['value'][:40]):
                original = self.page_text(rule['page'])
                if rule['kind'] == 'statement':
                    mutated, count = rule['pattern'].subn('[removed]', original)
                else:
                    targets = rule['rows'][:1] if rule['kind'] == 'decision_rows' else [rule['value']]
                    lines = original.split('\n')
                    hits = [i for i, line in enumerate(lines)
                            if any(line == t or line.startswith(t + ' ') for t in targets)]
                    if rule['kind'] == 'decision_rows':
                        start, end = ENGINE.section_bounds(lines, rule['section'])
                        hits = [i for i in hits if start <= i < end]
                    count = len(hits)
                    for index in hits:
                        lines[index] = '[removed]'
                    mutated = '\n'.join(lines)
                self.assertGreater(count, 0)
                self.write(rule['page'], mutated)
                self.assert_contract_fails(rule['contract'], rule['kind'])
                self.restore(rule['page'])

    def test_each_sectioned_rule_is_scoped_to_its_section(self):
        sectioned = [rule for rule in ENGINE.load_rules(RULES)
                     if rule['section'] is not None and rule['kind'] in ('row', 'statement')]
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

    def test_decision_rows_are_bound_to_their_own_table(self):
        original = self.page_text(DISPOSITION)
        lines = original.split('\n')
        sun_start, sun_end = ENGINE.section_bounds(lines, SUN2000)
        luna_start, luna_end = ENGINE.section_bounds(lines, LUNA2000)
        sun, luna = lines[sun_start + 1:sun_end], lines[luna_start + 1:luna_end]
        swapped = lines[:sun_start + 1] + luna + [lines[luna_start]] + sun + lines[luna_end:]
        self.assertEqual(self.decision_failures('\n'.join(swapped)), {SUN2000, LUNA2000})
        self.assertEqual(self.decision_failures(original), set())

    def test_decision_rows_agree_with_the_original_pipeline(self):
        original = self.page_text(DISPOSITION)
        first = '| `serial_or_esn_only` | `INSUFFICIENT_EVIDENCE` |'
        mutations = {
            'unchanged': lambda t: t,
            'reason cell changed': lambda t: t.replace('no winner is chosen by order or priority', 'none'),
            'outcome changed': lambda t: t.replace('| `multiple_positive_candidates` | `AMBIGUOUS` |',
                                                   '| `multiple_positive_candidates` | `INSUFFICIENT_EVIDENCE` |', 1),
            'row removed': lambda t: t.replace('| `firmware_without_model` |', '| firmware_without_model |'),
            'row added': lambda t: t.replace(first, first + ' x |\n| `extra_row` | `AMBIGUOUS` |', 1),
            'row duplicated': lambda t: t.replace(first, first + ' x |\n' + first, 1),
            'rows swapped': lambda t: t.replace(
                '| `no_identity_evidence` |', '| `swap_marker` |', 1).replace(
                '| `gateway_inventory_child_model_only` |', '| `no_identity_evidence` |', 1).replace(
                '| `swap_marker` |', '| `gateway_inventory_child_model_only` |', 1),
            'row renamed': lambda t: t.replace('`parent_inverter_unidentified`', '`parent_unidentified`'),
            'row indented': lambda t: t.replace('\n| `battery_group_absent`', '\n | `battery_group_absent`', 1),
            'extra cell after the outcome': lambda t: t.replace(
                '| `battery_group_exception` | `INSUFFICIENT_EVIDENCE` | an',
                '| `battery_group_exception` | `INSUFFICIENT_EVIDENCE` | extra | an', 1),
        }
        script = self.work / 'pipeline.sh'
        for name, mutate in mutations.items():
            with self.subTest(mutation=name):
                text = mutate(original)
                self.write(DISPOSITION, text)
                failed = set()
                for section, (pipeline, rule) in zip((SUN2000, LUNA2000), zip(ORIGINAL_DECISION_ROWS, (
                        r for r in ENGINE.load_rules(RULES) if r['kind'] == 'decision_rows'))):
                    script.write_text(pipeline + '\n', encoding='utf-8')
                    found = subprocess.run(['bash', str(script), str(self.copies[DISPOSITION])],
                                           capture_output=True, text=True, timeout=30,
                                           env={'LC_ALL': 'C', 'PATH': '/usr/bin:/bin'})
                    self.assertEqual(found.returncode, 0, found.stderr)
                    self.assertEqual(rule['section'], section)
                    if found.stdout.split('\n')[:-1] != rule['rows']:
                        failed.add(section)
                self.assertEqual(self.decision_failures(text), failed)
                if name in ('unchanged', 'reason cell changed', 'extra cell after the outcome'):
                    self.assertEqual(failed, set())
                else:
                    self.assertTrue(failed)
        self.restore(DISPOSITION)

    def test_a_repeated_or_missing_section_fails_closed(self):
        original = self.page_text(DISPOSITION)
        heading = '## Optional groups'
        for text in (original.replace(heading, heading + '\n\n' + heading),
                     original.replace(heading, '#' + heading)):
            self.write(DISPOSITION, text)
            result = self.run_contract('huawei_disposition')
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('section is not present exactly once', result.stderr)

    def test_each_forbidden_rule_rejects_its_probes(self):
        forbidden = [rule for rule in ENGINE.load_rules(RULES) if rule['kind'] == 'forbidden']
        self.assertEqual({rule['contract'] for rule in forbidden}, set(PROBES))
        for rule in forbidden:
            for probe in PROBES[rule['contract']]:
                with self.subTest(contract=rule['contract'], probe=probe):
                    self.assertTrue(rule['pattern'].search(probe))
                    self.write(rule['page'], self.page_text(rule['page']) + '\n' + probe + '\n')
                    self.assert_contract_fails(rule['contract'], 'forbidden')
                    self.restore(rule['page'])

    def test_forbidden_rules_reject_every_line_the_original_expressions_rejected(self):
        corpus = [probe for probes in PROBES.values() for probe in probes]
        corpus += ['LIVE_QUALIFIED:TRUE', 'Write_Authority =  True', 'automatic_request_count=0',
                   'automatic_request_count: 12', 'SUPPORT CLAIM IS ESTABLISHED', 'register is assumed from',
                   'Registers are inferred from', 'is supported', 'are admitted.', 'fc0x41 are allowed',
                   'FC0x42 is permitted', 'absent group yields numeric zero', 'Absent Group Reports Zero',
                   'missing or unavailable native values stay unknown, never numeric zero']
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
        missing = self.run_contract('huawei_disposition', self.work / 'missing.json')
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
                r for r in d['rules'] if r['contract'] == 'fronius_float_page').update(kind='statement'),
            'unknown contract': lambda d: d['rules'][0].update(contract='unknown'),
            'other contract of another page': lambda d: d['rules'][0].update(contract='huawei_qualification'),
            'page outside the family': lambda d: d['rules'][0].update(page='protocols/tesla/tedapi.md'),
            'page of another contract': lambda d: d['rules'][0].update(page=FRONIUS),
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
        rows = next(r for r in self.rules if r['kind'] == 'decision_rows')['value']
        cases = {
            ('huawei_disposition', 'heading', 'value'): 'Scope',
            ('huawei_disposition', 'row', 'value'): '| SUN2000 | `unknown`',
            ('huawei_disposition', 'row', 'section'): 'Evidence status',
            ('huawei_disposition', 'statement', 'value'): 'Both classes  have the outcome.',
            ('huawei_disposition', 'forbidden', 'value'): 'supported|(',
            ('huawei_disposition', 'decision_rows', 'section'): None,
            ('huawei_disposition', 'decision_rows', 'value'): rows + '\n' + rows.split('\n')[0],
        }
        for value in ('| no_identity_evidence | `INSUFFICIENT_EVIDENCE` |',
                      '| `no_identity_evidence` | `INSUFFICIENT_EVIDENCE` | reason |',
                      '| `No_identity` | `INSUFFICIENT_EVIDENCE` |', rows + '\n', rows.replace('\n', '\n\n', 1)):
            cases[('huawei_disposition', 'decision_rows', 'value', value)] = value
        for key, value in cases.items():
            contract, kind, field = key[:3]
            with self.subTest(kind=kind, field=field, value=str(value)[:40]):
                data = self.edited(lambda d: first(d, contract, kind).update({field: value}))
                self.assertNotEqual(self.run_table(data, contract), 0)

    def test_loader_rejects_bad_rules_even_when_the_counts_would_match(self):
        """Isolate the loader checks that the count table would otherwise mask."""
        path = self.work / 'rules.json'
        first = self.rules[0]
        statement = next(r for r in self.rules if r['kind'] == 'statement')
        cases = {
            'unknown kind': ({(first['contract'], 'unknown'): 1},
                             lambda d: d['rules'].append(dict(first, kind='unknown', value='x'))),
            'duplicate rule': ({(first['contract'], first['kind']): 12},
                               lambda d: d['rules'].append(dict(first))),
            'non-normalized statement': ({}, lambda d: next(
                r for r in d['rules'] if r['value'] == statement['value']).update(value='No  send.')),
            'page of a sibling contract': ({}, lambda d: next(
                r for r in d['rules'] if r['value'] == statement['value']).update(page=FRONIUS)),
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
        target = next(i for i, r in enumerate(self.rules) if r['contract'] == 'huawei_disposition'
                      and r['value'] == 'They are never inferred from another Huawei class.')
        variations = {
            'contract': ('huawei_qualification', 'loader'),
            'page': (HUAWEI, 'loader'),
            'section': ('## Optional groups', 'statement'),
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
                lines = self.page_text(DISPOSITION).split('\n')
                group = [r for r in rules if r['contract'] == 'huawei_disposition']
                failures = ENGINE.check_page(group, lines)
                self.assertEqual([rule['kind'] for rule, _ in failures], [caught_by])

    def test_each_decision_rows_key_field_changes_the_outcome(self):
        """Vary every key field of one decision_rows rule; each change is caught.

        contract: moving the rule to a contract without decision rows is rejected by the loader.
        page: pointing the rule at another page is rejected by the loader.
        section: the SUN2000 rows bound to the LUNA2000 table are not exact.
        kind: the rows read as a statement are rejected by the loader; a statement is one normalized line.
        value: a changed outcome in the listed rows is not exact.
        """
        target = next(i for i, r in enumerate(self.rules)
                      if r['kind'] == 'decision_rows' and r['section'] == SUN2000)
        rows = self.rules[target]['value']
        variations = {
            'contract': ('huawei_qualification', 'loader'),
            'page': (HUAWEI, 'loader'),
            'section': (LUNA2000, 'decision_rows'),
            'kind': ('statement', 'loader'),
            'value': (rows.replace('`AMBIGUOUS`', '`INSUFFICIENT_EVIDENCE`'), 'decision_rows'),
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
                lines = self.page_text(DISPOSITION).split('\n')
                group = [r for r in rules if r['contract'] == 'huawei_disposition']
                failures = ENGINE.check_page(group, lines)
                self.assertEqual([rule['kind'] for rule, _ in failures], [caught_by])

    def test_command_line_selection_fails_closed(self):
        disposition = {DISPOSITION: self.copies[DISPOSITION]}
        contract = 'huawei_disposition'
        self.assertEqual(self.run_checker([contract], disposition).returncode, 0)
        self.assertNotEqual(self.run_checker(['unknown'], disposition).returncode, 0)
        self.assertNotEqual(self.run_checker([contract, contract], disposition).returncode, 0)
        self.assertNotEqual(self.run_checker([contract], {}).returncode, 0)
        self.assertNotEqual(self.run_checker(
            [contract], dict(disposition, **{HUAWEI: self.copies[HUAWEI]})).returncode, 0)
        malformed = subprocess.run(['python3', '-B', str(CHECKER), str(RULES), contract, DISPOSITION],
                                   capture_output=True, timeout=30)
        self.assertNotEqual(malformed.returncode, 0)
        self.assertNotEqual(self.run_checker([contract], {DISPOSITION: self.work / 'absent.md'}).returncode, 0)

    def test_gate_options_keep_their_contract_scope(self):
        for contract, option in GATE_OPTIONS.items():
            page = ENGINE.CONTRACT_PAGES[contract]
            with self.subTest(option=option):
                self.assertEqual(self.gate(option, self.copies[page]), 0)
                self.write(page, self.page_text(page) + '\nSee https://example.invalid/.\n')
                self.assertEqual(self.run_contract(contract).returncode, 0)
                self.assertNotEqual(self.gate(option, self.copies[page]), 0)
                self.restore(page)
        for leak in ('register 0x7530', 'Register address 30000.', 'port: 1502', '192.0.2.1'):
            with self.subTest(publication=leak):
                self.write(DISPOSITION, self.page_text(DISPOSITION) + '\n' + leak + '\n')
                self.assertEqual(self.run_contract('huawei_disposition').returncode, 0)
                self.assertNotEqual(self.gate(GATE_OPTIONS['huawei_disposition'],
                                              self.copies[DISPOSITION]), 0)
                self.restore(DISPOSITION)
        self.write(PRIVATE, self.page_text(PRIVATE).replace('## RTU serialization', '## Serialization'))
        self.assertNotEqual(self.gate(GATE_OPTIONS['private_function'], self.copies[PRIVATE]), 0)
        self.restore(PRIVATE)


if __name__ == '__main__':
    unittest.main()
