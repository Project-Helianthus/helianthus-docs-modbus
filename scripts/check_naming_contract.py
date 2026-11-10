#!/usr/bin/env python3
"""Validate the bounded public naming correspondence."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NAMES = ('pv_string_voltage', 'pv_string_current', 'energy_accumulated',
         'energy_current_hour', 'energy_current_day', 'input_power',
         'active_power', 'device_status')


def validate(data, page, monitoring, changelog):
    rows = data['rows']
    assert [r['current'] for r in rows] == list(NAMES), 'decoded inventory differs'
    for row in rows:
        name = row['current']
        expected = ('status', 'supported_rename') if name == 'device_status' else (name, 'unchanged_provisional')
        assert (row['target'], row['status']) == expected, f'wrong disposition: {name}'
        assert row['open_question'] and row['consumer'], f'missing proof: {name}'
        assert f'`{name}`' in page and f'`{row["target"]}`' in page, f'missing page row: {name}'
    assert data['native_identity'] == ['W', 'WH', 'V_SF', 'TEDAPI method and field spellings']
    assert data['remaining_exports'] and data['consumer_matches']
    for required in ('never a runtime fallback', 'lexical candidates', 'grid_connected',
                     'Unknown', 'Hypothesis', 'last-known-good', 'GraphQL parity', 'issue 393'):
        assert required in page, f'missing boundary: {required}'
    for required in ('`device_status` to `status`', '`energy_total`', 'Hypothesis', 'not adopted'):
        assert required in monitoring, f'missing monitoring boundary: {required}'
    for required in ('`device_status` to `status`', 'no alias', 'migration step'):
        assert required in changelog, f'missing changelog boundary: {required}'


def main():
    data = json.loads((ROOT / 'architecture/naming-contract.json').read_text())
    validate(data, (ROOT / 'architecture/naming-contract.md').read_text(),
             (ROOT / 'protocols/huawei/monitoring-readonly-v1.md').read_text(),
             (ROOT / 'CHANGELOG.md').read_text())
    print('naming contract: OK')


if __name__ == '__main__':
    main()
