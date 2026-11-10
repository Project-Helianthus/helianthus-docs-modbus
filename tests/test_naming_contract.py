import copy
import importlib.util
import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('naming', ROOT / 'scripts/check_naming_contract.py')
naming = importlib.util.module_from_spec(spec)
spec.loader.exec_module(naming)


def inputs():
    return (json.loads((ROOT / 'architecture/naming-contract.json').read_text()),
            (ROOT / 'architecture/naming-contract.md').read_text(),
            (ROOT / 'protocols/huawei/monitoring-readonly-v1.md').read_text(),
            (ROOT / 'CHANGELOG.md').read_text())


def test_contract():
    naming.validate(*inputs())


@pytest.mark.parametrize('field,value', [
    ('current', 'invented'), ('target', 'invented'), ('status', ''),
    ('open_question', ''), ('consumer', '')])
def test_rejects_mutated_row(field, value):
    data, page, monitoring, changelog = inputs()
    data = copy.deepcopy(data)
    data['rows'][-1][field] = value
    with pytest.raises(AssertionError):
        naming.validate(data, page, monitoring, changelog)


def test_rejects_missing_native_identity():
    data, page, monitoring, changelog = inputs()
    data['native_identity'].pop()
    with pytest.raises(AssertionError):
        naming.validate(data, page, monitoring, changelog)
