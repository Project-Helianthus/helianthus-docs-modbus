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

check_private_function_contract() {
  local document="$1"

  check_public_protocol "$document"
  for heading in \
    'Scope and non-goals' \
    'Selection and ownership' \
    'Transport exchange' \
    'Function-code isolation' \
    'Standard and private function boundary' \
    'Ambiguity and no-send' \
    'Response correlation and exceptions' \
    'RTU serialization' \
    'Validation and compatibility'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq 'A function-code byte never identifies a vendor, vendor profile, or operation.' "$document"
  grep -Fq 'FC100, FC101, and FC102 may be reused by different qualified vendor profiles.' "$document"
  grep -Fq 'FC0x41 is profile-qualified and is not globally reserved by this contract.' "$document"
  grep -Fq 'FC23 is a standard Modbus function code, not a private-function operation.' "$document"
  grep -Fq 'A vendor-specific allocation interpretation for FC23 requires a separately admitted standard-function operation and a typed standard-function codec.' "$document"
  grep -Fq 'This contract makes no claim about the meaning, sendability, or allocation workflow of such an operation.' "$document"
}

check_sunspec_v2_contract() {
  local document="$1"
  local contradiction='sunspec\.models\.candidate\.v2|Common[[:space:]]+1/65[^.]*V2 decoder|V2 runtime catalog registration is enabled|V2 automatic acquisition is enabled|trailing spaces[^.]*trimmed'

  check_public_protocol "$document"
  grep -Fqx '## Schema revision' "$document"
  grep -Fqx '## Model scope' "$document"
  grep -Fqx '## Model 714 geometry' "$document"
  grep -Fqx '## Value interpretation boundary' "$document"
  grep -Fqx '## Offline implementation boundary' "$document"
  grep -Fq '`sunspec.models@90b4a331-v2`' "$document"
  grep -Fq 'Common Model 1 with declared length 66 is the' "$document"
  grep -Fq 'only V2 Common tuple.' "$document"
  grep -Fq 'Common Model 1 length 65 is a V1 compatibility tuple and' "$document"
  grep -Fq 'remains opaque under V2.' "$document"
  grep -Fq 'Models 701, 702, 703,' "$document"
	grep -Fq '713, 714, 715, 802, 803, 804, 805, 806, and 807' "$document"
  grep -Fq '| 1 | 66 | Common device information |' "$document"
  grep -Fq '| 701 | 153 | DER AC measurement |' "$document"
  grep -Fq '| 702 | 50 | DER capacity |' "$document"
  grep -Fq '| 703 | 17 | DER enter-service observed state |' "$document"
  grep -Fq '| 713 | 7 | DER storage capacity |' "$document"
  grep -Fq '| 714 | `18 + 25*NPrt` | DER DC measurement with repeated ports |' "$document"
	grep -Fq '| 715 | 7 | DER controller observed state |' "$document"
	grep -Fq '| 802 | 62 | BESS base observed state |' "$document"
	grep -Fq '| 803 | `26 + 32*NStr` | BESS bank observed state with repeated strings |' "$document"
	grep -Fq '| 804 | `46 + 16*NMod` | BESS string observed state with repeated modules |' "$document"
	grep -Fq '| 805 | 42 | BESS module observed state |' "$document"
	grep -Fq '| 806 | 1 | Flow battery structural observed state |' "$document"
	grep -Fq '| 807 | 34 | Flow battery string observed state |' "$document"
  grep -Fq 'Models 703 and 715 are control-observability only.' "$document"
  grep -Fq 'No point in either model creates a write method, send authority, operation admission,' "$document"
	grep -Fq 'Models 704 through 712 remain outside this V2 wave and remain opaque.' "$document"
	grep -Fq 'Model 802 is a fixed-geometry battery base block with declared length 62.' "$document"
	grep -Fq 'It occupies 64 total words including its header and has no repeated group.' "$document"
	grep -Fq 'Every Model 802 field is observed state only and is `NO_SEND`.' "$document"
	grep -Fq 'No Model 802 field creates a write method, operation dispatch, control behavior,' "$document"
	grep -Fq 'Model 801 remains excluded as deprecated.' "$document"
	grep -Fq 'Models 808 through 809 remain excluded pending separate family and substructure decisions.' "$document"
  grep -Fq 'Model 714 has data-register length `18 + 25*NPrt`' "$document"
  grep -Fq 'bounded from 0 through 2620' "$document"
  grep -Fq 'unavailable, an unavailable sentinel, overflows, or does not match' "$document"
  grep -Fq 'the declared length, Model 714 is a raw-only opaque block.' "$document"
	grep -Fqx '## BESS bank and string geometry' "$document"
	grep -Fq 'Model 803 has data-register length `26 + 32*NStr`.' "$document"
	grep -Fq '`NStr` is at payload-register' "$document"
	grep -Fq 'offset 0. It is bounded from 0 through 2047' "$document"
	grep -Fq 'bounded from 0 through 2047' "$document"
	grep -Fq 'Each repeated string consumes' "$document"
	grep -Fq 'exactly 32 data registers.' "$document"
	grep -Fq 'Model 804 has data-register length `46 + 16*NMod`.' "$document"
	grep -Fq '`NMod` is at payload-register' "$document"
	grep -Fq 'offset 1. It is bounded from 0 through 4093' "$document"
	grep -Fq 'bounded from 0 through 4093' "$document"
	grep -Fq 'Each repeated module consumes' "$document"
	grep -Fq 'exactly 16 data registers.' "$document"
	grep -Fq 'At NMod=4093, Model 804 has declared data-register length 65534 and occupies' "$document"
	grep -Fq '65536 words including header.' "$document"
	grep -Fq 'The maximum is valid only for an isolated synthetic offline occurrence.' "$document"
	grep -Fq 'It must not be used as a terminal-qualified live chain or acquisition map.' "$document"
	grep -Fq 'Maximum provenance retains fragmented bounded source spans whose cumulative extent is exactly' "$document"
	grep -Fq '65536 words.' "$document"
	grep -Fq 'source-span extent overrun makes the' "$document"
	grep -Fq 'block raw-only opaque with zero decoded facts.' "$document"
	grep -Fq 'No count is inferred from trailing' "$document"
	grep -Fq 'model-local stable index and its exact raw' "$document"
	grep -Fq 'Model 803 does not infer Model 804 child occurrences' "$document"
	grep -Fq 'Model 804 does not infer a Model 803 parent' "$document"
	grep -Fq 'including `SetEna`, `SetCon`, and any upstream read/write field, is observed' "$document"
	grep -Fq 'No Model 803 or Model 804 field creates a write method, send authority,' "$document"
	grep -Fq 'Model 805 has fixed data-register length 42 and has no repeated group.' "$document"
	grep -Fq '`StrIdx` and `ModIdx` are observed fields only.' "$document"
	grep -Fq 'Neither establishes any inferred relationship to Model 803 or Model 804.' "$document"
	grep -Fq 'Every Model 805 field is observed state only and is `NO_SEND`.' "$document"
	grep -Fq 'No Model 805 field creates a write method, send authority, operation admission,' "$document"
	grep -Fq 'Model 806 has fixed data-register length 1 and no effective repeated group.' "$document"
	grep -Fq '`BatTBD` remains uninterpreted structural observed state.' "$document"
	grep -Fq 'Model 806 does not infer a relationship to Models 803, 804, 805, or 807 through 809.' "$document"
	grep -Fq 'Every Model 806 field is observed state only and is `NO_SEND`.' "$document"
	grep -Fq 'No Model 806 field creates a write method, send authority, operation admission,' "$document"
	grep -Fq 'Model 807 has fixed data-register length 34 and no effective repeated group.' "$document"
	grep -Fq '`Idx` and `NMod` remain observed structural fields only.' "$document"
	grep -Fq 'Model 807 does not infer a relationship to Models 806, 808, or 809.' "$document"
	grep -Fq 'Every Model 807 field, including control-adjacent zero-count group names, is observed state only and is `NO_SEND`.' "$document"
	grep -Fq 'No Model 807 field creates a write method, send authority, operation admission,' "$document"
  grep -Fq 'raw-only opaque block' "$document"
  grep -Fq 'four big-endian words' "$document"
  grep -Fq 'uses four big-endian words; zero is a valid value and all one-bits means not' "$document"
  grep -Fq 'implemented. Exact unsigned scaling must not pass through an `int64` or' "$document"
  grep -Fq 'Exact unsigned scaling must not pass through an `int64` or' "$document"
  grep -Fq 'floating-point representation, truncate, or round.' "$document"
  grep -Fq 'with word `0x0080` followed only by zero padding is a valid empty string.' "$document"
  grep -Fq 'all-zero string extent is unavailable. Otherwise, the first NUL requires a' "$document"
  grep -Fq 'zero-only tail.' "$document"
  grep -Fq 'Spaces before the terminator are data and are not trimmed' "$document"
  grep -Fq 'This key is separate from `sunspec.models@7abdf898-v1`. V1 and V2 decoder' "$document"
  grep -Fq 'definitions and caches are revision-isolated.' "$document"
  grep -Fq 'V1 outputs remain unchanged.' "$document"
  grep -Fq 'synthetic, non-vendor fixtures' "$document"
  grep -Fq 'This contract permits a separate offline registry implementation to use the V2' "$document"
  grep -Fq 'No standard profile admission, runtime' "$document"
  grep -Fq 'catalog registration, vendor admission, automatic acquisition, telemetry' "$document"
  grep -Fq 'publication, capability admission, or consumer exposure may be derived from' "$document"
  if grep -Ein "$contradiction" "$document"; then
    echo 'SunSpec V2 contract contradicts its offline-only boundary' >&2
    return 1
  fi
}

check_sunspec_v2_licensing() {
  local document="$1"

	grep -Fq '| `sunspec.der.readonly.v2` | Common 1/66 plus Models 701/153, 702/50, 703/17, 713/7, 714 variable geometry, 715/7, 802/62, 803 variable geometry, and 804 variable geometry at the exact pinned V2 schema revision | public Apache-2.0 model catalogue and independently stated interoperability facts | offline decoder contract; runtime, vendor, and catalog admission default denied |' "$document"
  grep -Fq '`90b4a331dcca1d6eac69c1bead952fddcc5852e0`' "$document"
  grep -Fq 'That upstream license applies to' "$document"
  grep -Fq 'the catalogue input.' "$document"
}

check_sunspec_v1_model_families_contract() {
  local document="$1"

  check_public_protocol "$document"
  grep -Fqx '## Scope' "$document"
  grep -Fqx '## Decoder Catalog Boundary' "$document"
  grep -Fqx '## Inverter Families' "$document"
  grep -Fqx '## Inverter Extensions' "$document"
  grep -Fqx '## Meter Families' "$document"
  grep -Fqx '## Environmental Families' "$document"
  grep -Fqx '## Safety and Non-Claims' "$document"
  grep -Fq 'identifiers and 29 exact decoder tuples' "$document"
  grep -Fq 'length 65 is a compatibility tuple' "$document"
  grep -Fq 'Models 101, 102, and 103 use integer values with declared scale factors.' "$document"
  grep -Fq 'Models 111, 112, and 113 use IEEE FLOAT values.' "$document"
  grep -Fq 'Models 123 and 124 are observed state only.' "$document"
  grep -Fq 'identifiers or lengths remain opaque blocks.' "$document"
  grep -Fq 'does not create a product, profile, or support' "$document"
  if grep -Ein 'sunspec\.models\.candidate\.v2|V2 registry|PROFILE_ADMITTED|write authority' "$document"; then
    echo 'SunSpec V1 model-families reference exceeds the V1 docs-only boundary' >&2
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

check_bms_contract() {
  local document="$1"
  local private_material='(^|[^[:xdigit:]])[[:xdigit:]]{40}([^[:xdigit:]]|$)|(^|[^[:xdigit:]])[[:xdigit:]]{64}([^[:xdigit:]]|$)|([0-9]{1,3}\.){3}[0-9]{1,3}|([[:alnum:]][[:alnum:].-]*):([0-9]{1,5}|[[:alpha:]][[:alnum:].-]*)|[Pp]ort[[:space:]]+[0-9]{1,5}'
  local expected_slices actual_slices

  expected_slices=$(printf '%s\n' \
    'offset 0x0001, quantity 7' \
    'offset 0x000D, quantity 29' \
    'offset 0x0100, quantity 12' \
    'offset 0x010D, quantity 2')
  actual_slices=$(sed -n \
    '/An offline fixture may contain these/,/The two extension slices remain/p' \
    "$document" | sed -nE 's/^- (offset 0x[[:xdigit:]]+, quantity [0-9]+).*/\1/p')
  if [[ "$actual_slices" != "$expected_slices" ]]; then
    echo 'BMS FC03 slice allowlist is not exact' >&2
    return 1
  fi

  check_public_protocol "$document"
  if grep -Ein "$private_material" "$document"; then
    echo 'BMS protocol specification contains private endpoint or source revision material' >&2
    return 1
  fi
  grep -Fq 'protocol family label `1xSxxP ESS`' "$document"
  grep -Fq 'file revision family `Rev2.01`' "$document"
  grep -Fq 'document header version `V2.0`' "$document"
  grep -Fq 'cumulative change record through revision `2.02`' "$document"
  grep -Fq 'Unit 0 is broadcast and is always `NO_SEND`.' "$document"
  grep -Fq 'function is FC03 Read Holding Registers.' "$document"
  grep -Fq 'offset 0x0001, quantity 7' "$document"
  grep -Fq 'offset 0x000D, quantity 29' "$document"
  grep -Fq 'offset 0x0100, quantity 12' "$document"
  grep -Fq 'offset 0x010D, quantity 2' "$document"
  grep -Fq 'The two extension slices remain opaque words until an exact clean-room fixture' "$document"
  grep -Fq 'Offsets 0x0009 through 0x000C contain barcode material and are not read' "$document"
  grep -Fq 'FC10 Preset Multiple Registers, address allocation' "$document"
  grep -Fq 'every field marked' "$document"
  grep -Fq 'W or WR are unconditional `NO_SEND`.' "$document"
  grep -Fq 'Registry implementation is `NO_GO` until an exact, permitted, sanitized' "$document"
  grep -Fq 'A synthetic identity assembled from the document is not a substitute.' "$document"
  grep -Fq 'does not automatically apply the contract to any commercial battery' "$document"
  grep -Fq 'are forbidden identity inputs.' "$document"
  grep -Fq 'negative-overlap records against Growatt Protocol II, SunSpec/Fronius, and' "$document"
  grep -Fq 'Without that fixture, catalog registration' "$document"
  grep -Fq 'is ambiguous and produces no match.' "$document"
  grep -Fq 'produces `insufficient_evidence`, no send, and no partial' "$document"
}

check_wit_matrix_contract() {
  local document="$1"
  local expected_rows actual_rows
  local contradiction

  expected_rows=$(printf '%s\n' \
    '| `WIT 4-25K-HU` | worldwide, 380/400 Vac, low-voltage battery | Modbus TCP available; ShineWiLAN-X2 listed | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 4-25K-XHU` | worldwide, 380/400 Vac, high-voltage battery | Modbus TCP available; ShineWiLAN-X2 listed | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 29.9-50K-XHU` | worldwide, 380/400 Vac, high-voltage battery | ShineWiLan-X2 and ShineSEM-XA-R listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 50-100K-HU` | APAC, 380/400/415 Vac, high-voltage battery | ShineWiLan-X2 and ShineSEM-XA-R listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 50-100K-AU` | APAC, 380/400/415 Vac, high-voltage battery | ShineWiLan-X2 and ShineSEM-XA-R listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 50-100K-HU-US` | US branch; product context not established | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 50-100K-AU-US` | US branch; product context not established | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 63-125K-XHU` | worldwide, 380/400 Vac, high-voltage battery | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 28-55K-HU-US L2` | US L2, 208/220 Vac, high-voltage battery | ShineMaster listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 28-55K-AU-US L2` | US L2, 208/220 Vac, high-voltage battery | ShineMaster listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' \
    '| `WIT 50-150K-XHU-US` | US, 277/480 Vac, high-voltage battery | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |')
  actual_rows=$(sed -n \
    '/^## Family qualification matrix$/,/^## Explicit VPP V2.01 tuple$/p' \
    "$document" | sed -n '/^| `WIT /p')
  if [[ "$actual_rows" != "$expected_rows" ]]; then
    echo 'WIT family matrix is not exact' >&2
    return 1
  fi

  contradiction='VPP (read|reads|control|controls|write|writes) (is|are) (permitted|allowed|enabled|supported)|Protocol II[^.]*(applies|is applicable)[[:space:]]+to[[:space:]]+(a[[:space:]]+|the[[:space:]]+|any[[:space:]]+)?WIT|`WIT [^`]+` firmware (version |gate )?(is|=)'
  if grep -Ein "$contradiction" "$document"; then
    echo 'WIT protocol specification contains a contradictory admission statement' >&2
    return 1
  fi

  check_public_protocol "$document"
  grep -Fq 'Each row is an independent, case-sensitive family branch.' "$document"
  grep -Fq 'A combined marketing page does not make HU, AU, XHU, worldwide, or US branches protocol aliases.' "$document"
  grep -Fq 'Modbus TCP availability and a listed logger or bridge are transport facts only.' "$document"
  grep -Fq 'They do not establish a register map, firmware gate, identity tuple, or semantic profile.' "$document"
  grep -Fq '`WIT 100KTL3-H` with DTC `5601` is the only WIT tuple explicitly associated with VPP protocol `V2.01`.' "$document"
  grep -Fq 'It does not admit `WIT 50-100K-HU`, `WIT 50-100K-AU`, or any other WIT row.' "$document"
  grep -Fq 'The VPP tuple has no qualified firmware gate in this contract.' "$document"
  grep -Fq 'Growatt Protocol II v1.24 TL3-X does not apply to a WIT row by vendor or name similarity.' "$document"
  grep -Fq 'Every VPP read, control, and write remains `NO_SEND`.' "$document"
  grep -Fq 'No decoder, fixture, catalog registration, runtime admission, telemetry publication, or support claim is created.' "$document"
  grep -Fq 'Missing or conflicting evidence produces `INSUFFICIENT_EVIDENCE`, no match, and no send.' "$document"
}

if [[ $# -gt 0 ]]; then
  if [[ $# -ne 2 ]]; then
    echo 'usage: check_docs.sh [--check-sdongle-admission|--check-public-protocol|--check-private-function-contract|--check-sunspec-v1-model-families-contract|--check-sunspec-v2-contract|--check-sunspec-v2-licensing|--check-x2-publication|--check-x2-contract|--check-bms-contract|--check-wit-matrix-contract document]' >&2
    exit 2
  fi
  case "$1" in
    --check-sdongle-admission) check_sdongle_admission "$2" ;;
    --check-public-protocol) check_public_protocol "$2" ;;
    --check-private-function-contract) check_private_function_contract "$2" ;;
    --check-sunspec-v1-model-families-contract) check_sunspec_v1_model_families_contract "$2" ;;
    --check-sunspec-v2-contract) check_sunspec_v2_contract "$2" ;;
    --check-sunspec-v2-licensing) check_sunspec_v2_licensing "$2" ;;
    --check-x2-publication) check_x2_publication "$2" ;;
    --check-x2-contract) check_x2_contract "$2" ;;
    --check-bms-contract) check_bms_contract "$2" ;;
    --check-wit-matrix-contract) check_wit_matrix_contract "$2" ;;
    *)
      echo 'usage: check_docs.sh [--check-sdongle-admission|--check-public-protocol|--check-private-function-contract|--check-sunspec-v1-model-families-contract|--check-sunspec-v2-contract|--check-sunspec-v2-licensing|--check-x2-publication|--check-x2-contract|--check-bms-contract|--check-wit-matrix-contract document]' >&2
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
  'protocols/sunspec/read-only-core-v1-model-families.md'
  'protocols/sunspec/read-only-core-v2.md'
  'protocols/fronius/sunspec-float-v1.md'
  'protocols/huawei/gateway-readonly-v1.md'
  'protocols/growatt/protocol-ii-readonly-v1.md'
  'protocols/growatt/shinewilan-x2-bridge-v1.md'
  'protocols/growatt/bms-rs485-1xsxxp-v202.md'
  'protocols/growatt/wit-family-protocol-matrix-v1.md'
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

check_private_function_contract "$private_spec"

forbidden='https?://|/[Uu]sers/|\.md`|sha-?[0-9a-f]{8,}|0x[0-9A-Fa-f]{6,}|reverse engineering|static-confirmed|conform sursei|am observat'
if grep -Ein "$forbidden" "$spec"; then
  echo 'normative Tesla specification contains forbidden provenance material' >&2
  exit 1
fi

grep -Fqx '## Publication boundary' 'protocols/applicability-and-licensing.md'
grep -Fqx '## Admission rules' 'protocols/applicability-and-licensing.md'
grep -Fqx '## Initial model catalog' 'protocols/sunspec/read-only-core-v1.md'
check_sunspec_v1_model_families_contract 'protocols/sunspec/read-only-core-v1-model-families.md'
check_sunspec_v2_contract 'protocols/sunspec/read-only-core-v2.md'
check_sunspec_v2_licensing 'protocols/applicability-and-licensing.md'
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
grep -Fqx '## Exact applicability and revision' 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
grep -Fqx '## FC03 read-only boundary' 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
grep -Fqx '## Writes and controls' 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
grep -Fqx '## Fixture and admission gate' 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
check_bms_contract 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
check_wit_matrix_contract 'protocols/growatt/wit-family-protocol-matrix-v1.md'

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
