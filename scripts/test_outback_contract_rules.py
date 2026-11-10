#!/usr/bin/env python3
"""Compare the extracted gate with its saved predecessor and reject bad rules."""
import base64
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent
NEW = ROOT / 'scripts/check_docs.sh'
DOC = ROOT / 'protocols/outback/axs-port-sunspec-readonly-v1.md'
MATRIX = ROOT / 'protocols/outback/axs-port-source-profile-matrix-v1.md'
RULES = ROOT / 'scripts/outback_contract_rules.json'
CHECKER = ROOT / 'scripts/check_outback_contract.py'


class ContractRules(unittest.TestCase):
    def setUp(self):
        (ROOT / '.tmp').mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=ROOT / '.tmp')
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.doc = self.work / 'document.md'
        self.matrix = self.work / 'matrix.md'
        self.doc.write_bytes(DOC.read_bytes())
        self.matrix.write_bytes(MATRIX.read_bytes())
        self.rules = json.loads(RULES.read_text())

    def shell(self, script, matrix=None):
        env = dict(os.environ, OUTBACK_AXS_MATRIX=str(matrix or self.matrix))
        return subprocess.run(['bash', str(script), '--check-outback-axs-contract',
                               str(self.doc)], env=env, stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL, timeout=15).returncode

    def compare(self, expected, matrix=None):
        self.assertEqual(self.shell(NEW, matrix) == 0, expected)

    def direct(self, rules):
        path = self.work / 'rules.json'
        path.write_text(rules)
        return subprocess.run(['python3', str(CHECKER), str(self.doc), str(self.matrix),
                               str(path)], stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL, timeout=15).returncode

    def test_public_override_and_missing_matrix(self):
        self.compare(True)
        self.compare(True, MATRIX)
        self.compare(False, self.work / 'missing')

    def test_each_required_rule(self):
        for rule in self.rules['rules']:
            with self.subTest(target=rule['target'], kind=rule['kind'], value=rule['value'][:10]):
                path = self.doc if rule['target'] == 'document' else self.matrix
                original = path.read_text()
                value = rule['value']
                if rule['kind'] == 'commitment':
                    value = base64.b64decode(value + '=').hex()
                if rule['kind'] == 'heading':
                    value = '## ' + value
                self.assertIn(value, original)
                path.write_text(original.replace(value, '[removed]'))
                self.compare(False)
                path.write_text(original)

    def test_privacy_violation(self):
        self.doc.write_text(self.doc.read_text() + '\nhttps://example.invalid/\n')
        self.compare(False)

    def test_missing_malformed_duplicate_and_unknown_rules_fail_closed(self):
        self.assertNotEqual(subprocess.run(['python3', str(CHECKER), str(self.doc),
            str(self.matrix), str(self.work / 'missing')], capture_output=True, timeout=15).returncode, 0)
        for bad in ('{', '{}', '{"version":1,"version":1,"rules":[]}'):
            self.assertNotEqual(self.direct(bad), 0)
        for mutation in ('missing', 'duplicate', 'unknown', 'corrupted'):
            data = json.loads(json.dumps(self.rules))
            if mutation == 'missing': data['rules'].pop()
            if mutation == 'duplicate': data['rules'][-1] = data['rules'][0]
            if mutation == 'unknown': data['rules'][0]['kind'] = 'unknown'
            if mutation == 'corrupted':
                next(r for r in data['rules'] if r['kind'] == 'commitment')['value'] = '!'
            with self.subTest(mutation=mutation):
                self.assertNotEqual(self.direct(json.dumps(data)), 0)


if __name__ == '__main__':
    unittest.main()
