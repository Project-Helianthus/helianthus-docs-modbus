#!/usr/bin/env python3
"""Validate the public OutBack contract against the maintained rule table."""
import base64
import json
import sys
from collections import Counter
from pathlib import Path

EXPECTED = {('document', 'heading'): 7, ('document', 'literal'): 8,
            ('matrix', 'heading'): 6, ('matrix', 'literal'): 7,
            ('matrix', 'commitment'): 2}


def check(document, matrix, rule_path):
    try:
        data = json.loads(Path(rule_path).read_text(encoding='utf-8'),
                          object_pairs_hook=unique_object)
        if set(data) != {'version', 'rules'} or type(data['version']) is not int or data['version'] != 1:
            raise ValueError('invalid rule table')
        rules = data['rules']
        if not isinstance(rules, list):
            raise ValueError('invalid rules')
        counts = Counter()
        seen = set()
        texts = {'document': Path(document).read_text(encoding='utf-8'),
                 'matrix': Path(matrix).read_text(encoding='utf-8')}
        for rule in rules:
            if not isinstance(rule, dict) or set(rule) != {'target', 'kind', 'value'}:
                raise ValueError('invalid rule')
            target, kind, value = (rule[k] for k in ('target', 'kind', 'value'))
            if not all(isinstance(x, str) and x for x in (target, kind, value)):
                raise ValueError('invalid rule fields')
            if (target, kind) not in EXPECTED or (target, kind, value) in seen:
                raise ValueError('unknown or duplicate rule')
            seen.add((target, kind, value))
            counts[target, kind] += 1
            if kind == 'commitment':
                raw = base64.b64decode(value + '=', validate=True)
                if len(raw) != 32 or base64.b64encode(raw).decode().rstrip('=') != value:
                    raise ValueError('invalid commitment')
                value = raw.hex()
            if kind == 'heading':
                if '## ' + value not in texts[target].splitlines():
                    raise ValueError('missing heading')
            elif value not in texts[target]:
                raise ValueError('missing required text')
        if counts != EXPECTED:
            raise ValueError('incomplete rules')
        return True
    except (OSError, UnicodeError, ValueError, TypeError, KeyError) as exc:
        print('OutBack contract check failed: ' + str(exc), file=sys.stderr)
        return False


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('duplicate JSON key')
        result[key] = value
    return result


if __name__ == '__main__':
    sys.exit(0 if len(sys.argv) == 4 and check(*sys.argv[1:]) else 1)
