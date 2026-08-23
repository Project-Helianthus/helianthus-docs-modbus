#!/usr/bin/env bash
set -euo pipefail

spec='protocols/tesla/tedapi.md'
test -f "$spec"
private_spec='protocols/modbus/private-function-codes.md'
test -f "$private_spec"

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
