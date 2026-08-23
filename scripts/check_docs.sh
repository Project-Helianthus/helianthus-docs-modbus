#!/usr/bin/env bash
set -euo pipefail

spec='protocols/tesla/tedapi.md'
test -f "$spec"
private_spec='protocols/modbus/private-function-codes.md'
test -f "$private_spec"

multivendor_specs=(
  'protocols/applicability-and-licensing.md'
  'protocols/sunspec/read-only-core-v1.md'
  'protocols/fronius/sunspec-float-v1.md'
  'protocols/huawei/gateway-readonly-v1.md'
  'protocols/growatt/protocol-ii-readonly-v1.md'
)
for multivendor_spec in "${multivendor_specs[@]}"; do
  test -f "$multivendor_spec"
done

required=(
  'Scope and non-goals' 'Terminology' 'Endpoint roles' 'Serial settings'
  'Frame structure' 'Byte order and CRC' 'Frame and payload limits'
  'Node addressing and configuration' 'Function 100' 'Functions 101 and 102'
  'Exception responses' 'Timing, deadlines, and frame separation'
  'Concurrency and arbitration' 'Request and response state machine'
  'Fail-closed validation rules' 'Unknown payload and field retention'
  'Runtime provenance' 'Security, privacy, and redaction'
  'Capability and version gates' 'Conformance vectors and sanitized examples'
  'Interoperability levels' 'Compatibility and versioning'
)
for heading in "${required[@]}"; do
  grep -Fqx "## $heading" "$spec"
done

private_required=(
  'Scope and non-goals' 'Selection and ownership' 'Transport exchange'
  'Function-code isolation' 'Ambiguity and no-send'
  'Response correlation and exceptions' 'RTU serialization'
  'Validation and compatibility'
)
for heading in "${private_required[@]}"; do
  grep -Fqx "## $heading" "$private_spec"
done

forbidden='https?://|/[Uu]sers/|\.md`|sha-?[0-9a-f]{8,}|0x[0-9A-Fa-f]{6,}|reverse engineering|static-confirmed|conform sursei|am observat'
if grep -Ein "$forbidden" "$spec"; then
  echo 'normative Tesla specification contains forbidden provenance material' >&2
  exit 1
fi

grep -Fqx '## Publication boundary' 'protocols/applicability-and-licensing.md'
grep -Fqx '## Admission rules' 'protocols/applicability-and-licensing.md'
grep -Fqx '## Initial model catalog' 'protocols/sunspec/read-only-core-v1.md'
grep -Fqx '## Exact chain geometry' 'protocols/fronius/sunspec-float-v1.md'
grep -Fqx '## SmartLogger candidate' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fqx '## S-Dongle candidate' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fqx '## EMMA candidate' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fqx '## Private function codes' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fqx '## Identity tuple' 'protocols/growatt/protocol-ii-readonly-v1.md'

if grep -Ein 'https?://|/[Uu]sers/|sha-?[0-9a-f]{8,}|(source|vendor material) (is|are) public domain|sunspec\.inverter\.|canonical facts' "${multivendor_specs[@]}"; then
  echo 'multivendor protocol specification contains a source locator, hash, or public-domain declaration' >&2
  exit 1
fi
