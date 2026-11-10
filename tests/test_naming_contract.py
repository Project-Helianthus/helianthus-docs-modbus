import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('naming', ROOT / 'scripts/check_naming_contract.py')
naming = importlib.util.module_from_spec(spec)
spec.loader.exec_module(naming)


def inputs():
    return (json.loads((ROOT / 'architecture/naming-contract.json').read_text()),
            (ROOT / 'architecture/naming-contract.md').read_text(),
            (ROOT / 'protocols/huawei/monitoring-readonly-v1.md').read_text(),
            (ROOT / 'CHANGELOG.md').read_text())


class NamingContractTests(unittest.TestCase):
    def test_contract(self):
        naming.validate(*inputs())

    def assert_rejects_mutated_row(self, field, value):
        data, page, monitoring, changelog = inputs()
        data = copy.deepcopy(data)
        data['rows'][-1][field] = value
        with self.assertRaises(AssertionError):
            naming.validate(data, page, monitoring, changelog)

    def test_rejects_invalid_current(self):
        self.assert_rejects_mutated_row('current', 'invented')

    def test_rejects_invalid_target(self):
        self.assert_rejects_mutated_row('target', 'invented')

    def test_rejects_empty_status(self):
        self.assert_rejects_mutated_row('status', '')

    def test_rejects_empty_open_question(self):
        self.assert_rejects_mutated_row('open_question', '')

    def test_rejects_empty_consumer(self):
        self.assert_rejects_mutated_row('consumer', '')

    def test_rejects_missing_native_identity(self):
        data, page, monitoring, changelog = inputs()
        data['native_identity'].pop()
        with self.assertRaises(AssertionError):
            naming.validate(data, page, monitoring, changelog)
