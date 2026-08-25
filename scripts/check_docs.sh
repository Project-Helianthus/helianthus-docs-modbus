#!/usr/bin/env bash
set -euo pipefail

check_sdongle_admission() {
  local document="$1"
  local forbidden='https?://|/[Uu]sers/|([0-9]{1,3}\.){3}[0-9]{1,3}|([[:alnum:]][[:alnum:].-]*):([0-9]{1,5}|[[:alpha:]][[:alnum:].-]*)|[Pp]ort[[:space:]]+[0-9]{1,5}|(^|[^[:xdigit:]])[[:xdigit:]]{40}([^[:xdigit:]]|$)|(^|[^[:xdigit:]])[[:xdigit:]]{64}([^[:xdigit:]]|$)|TCP reachability was established'

  if grep -Ein "$forbidden" "$document"; then
    echo 'S-Dongle admission record contains private or provenance material' >&2
    return 1
  fi
}

check_public_protocol() {
  local document="$1"
  local forbidden='https?://|/[Uu]sers/|sha(-?256)?[-:]?[0-9a-f]{8,}|(source|vendor material) (is|are) public domain|sunspec\.inverter\.|canonical facts'

  if grep -Ein "$forbidden" "$document"; then
    echo 'public protocol specification contains a source locator, hash, or public-domain declaration' >&2
    return 1
  fi
}

check_x2_publication() {
  local document="$1"
  local bare_revision='(^|[^[:xdigit:]])[[:xdigit:]]{40}([^[:xdigit:]]|$)|(^|[^[:xdigit:]])[[:xdigit:]]{64}([^[:xdigit:]]|$)'
  local private_endpoint='([0-9]{1,3}\.){3}[0-9]{1,3}|([[:alnum:]][[:alnum:].-]*):([0-9]{1,5}|[[:alpha:]][[:alnum:].-]*)|[Pp]ort[[:space:]]+[0-9]{1,5}'

  check_public_protocol "$document"
  if grep -Ein "$bare_revision|$private_endpoint" "$document"; then
    echo 'X2 protocol specification contains a bare revision or private endpoint' >&2
    return 1
  fi
}

check_x2_contract() {
  local document="$1"

  grep -Fq 'MBAP Unit Identifier as the downstream Modbus RTU unit address and forwards' "$document"
  grep -Fq 'without changing its function code, register offset, quantity,' "$document"
  grep -Fq 'or payload.' "$document"
  grep -Fq 'The MBAP Protocol Identifier must be 0x0000.' "$document"
  grep -Fq 'The MBAP Length must equal one' "$document"
  grep -Fq 'Only Unit Identifiers 1 through 247 are admitted' "$document"
  grep -Fq 'Unit Identifier 0 is RTU broadcast and is `NO_SEND`' "$document"
  grep -Fq 'not infer a unit, scan unit addresses' "$document"
  grep -Fq 'The read-only candidate surface consists of FC03 holding-register reads and' "$document"
  grep -Fq 'FC04 input-register reads.' "$document"
  grep -Fq 'The bridge has no semantic registry profile of its own.' "$document"
}

if [[ $# -gt 0 ]]; then
  if [[ $# -ne 2 ]]; then
    echo 'usage: check_docs.sh [--check-sdongle-admission|--check-public-protocol|--check-x2-publication|--check-x2-contract document]' >&2
    exit 2
  fi
  case "$1" in
    --check-sdongle-admission) check_sdongle_admission "$2" ;;
    --check-public-protocol) check_public_protocol "$2" ;;
    --check-x2-publication) check_x2_publication "$2" ;;
    --check-x2-contract) check_x2_contract "$2" ;;
    *)
      echo 'usage: check_docs.sh [--check-sdongle-admission|--check-public-protocol|--check-x2-publication|--check-x2-contract document]' >&2
      exit 2
      ;;
  esac
  exit 0
fi

spec='protocols/tesla/tedapi.md'
test -f "$spec"
private_spec='protocols/modbus/private-function-codes.md'
test -f "$private_spec"
sdongle_admission='architecture/sdongle-qualification-disposition-v1.md'
test -f "$sdongle_admission"

multivendor_specs=(
  'protocols/applicability-and-licensing.md'
  'protocols/sunspec/read-only-core-v1.md'
  'protocols/fronius/sunspec-float-v1.md'
  'protocols/huawei/gateway-readonly-v1.md'
  'protocols/growatt/protocol-ii-readonly-v1.md'
  'protocols/growatt/shinewilan-x2-bridge-v1.md'
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
grep -Fq 'A gateway-unit timeout never authorizes a child-unit scan' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq '`EMMA-A01` and' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq '`EMMA-A02` are the only admitted exact model values.' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq 'EMMA-A01 never inherits an EMMA-A02-only capability.' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq 'Basic and extended MEI are optional enrichment, never initial EMMA identification.' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fqx '## Identity tuple' 'protocols/growatt/protocol-ii-readonly-v1.md'
grep -Fqx '## Request mapping' 'protocols/growatt/shinewilan-x2-bridge-v1.md'
grep -Fqx '## Response mapping' 'protocols/growatt/shinewilan-x2-bridge-v1.md'
grep -Fqx '## Read-only boundary' 'protocols/growatt/shinewilan-x2-bridge-v1.md'
grep -Fqx '## Identity and admission' 'protocols/growatt/shinewilan-x2-bridge-v1.md'
grep -Fqx '## Transparency limits' 'protocols/growatt/shinewilan-x2-bridge-v1.md'
grep -Fq 'The bridge has no semantic registry profile of its own.' 'protocols/growatt/shinewilan-x2-bridge-v1.md'
grep -Fq 'Unsupported or undocumented operations are' 'protocols/growatt/shinewilan-x2-bridge-v1.md'
grep -Fq 'Unit Identifier 0 is RTU broadcast and is `NO_SEND`' 'protocols/growatt/shinewilan-x2-bridge-v1.md'
check_x2_contract 'protocols/growatt/shinewilan-x2-bridge-v1.md'
check_x2_publication 'protocols/growatt/shinewilan-x2-bridge-v1.md'

sdongle_admission_required=(
  'Scope' 'Sanitized qualification boundary' 'Disposition' 'Requalification gate'
  'Gateway-unit and child boundary' 'Publication boundary'
)
for heading in "${sdongle_admission_required[@]}"; do
  grep -Fqx "## $heading" "$sdongle_admission"
done
grep -Fq 'The matrix order was basic Read Device' "$sdongle_admission"
grep -Fq 'and FC03 Device Search Status.' "$sdongle_admission"
grep -Fq 'expired. No subsequent Modbus request was sent.' "$sdongle_admission"
grep -Fq 'Each retry began after at least five seconds of idle time.' "$sdongle_admission"

check_sdongle_admission "$sdongle_admission"

for multivendor_spec in "${multivendor_specs[@]}"; do
  check_public_protocol "$multivendor_spec"
done
