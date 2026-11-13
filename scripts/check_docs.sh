#!/usr/bin/env bash
set -euo pipefail

check_license_texts() {
  local root="$1"
  local relative_path expected_hash actual_hash
  if [[ -L "$root/LICENSES" ]]; then
    echo 'LICENSES: license directory must not be a symlink' >&2
    return 1
  fi
  while read -r expected_hash relative_path; do
    if [[ ! -f "$root/$relative_path" || -L "$root/$relative_path" ]]; then
      echo "$relative_path: missing regular license file" >&2
      return 1
    fi
    # Store SHA-256 digests in standard unpadded Base64 for publication.
    actual_hash=$(perl -MDigest::SHA -e 'print Digest::SHA->new(256)->addfile($ARGV[0])->b64digest' "$root/$relative_path") || return 1
    if [[ "$actual_hash" != "$expected_hash" ]]; then
      echo "$relative_path: content differs from the pinned license text or policy" >&2
      return 1
    fi
  done <<'LICENSE_HASHES'
dkCcMcpw4krqkp3bVc9/F7lSqWeBW8NAtT0vzWV9vLM LICENSE
4EVsurT3tecgPmePr/N+rb3+8C6CLbO3pSod2dPcUUo LICENSES/CC0-1.0.txt
2KbMMavBa2dIx6IfIWEfWh7DP2fSLKI9faHBm5VJa+4 LICENSES/AGPL-3.0-only.txt
LICENSE_HASHES
}

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

tesla_tedapi_page='protocols/tesla/tedapi.md'
tesla_legacy_page='protocols/tesla/legacy-wall-connector-rs485.md'
tesla_gen3_page='protocols/tesla/gen3-hsc-rtu.md'
tesla_current_limit_page='protocols/tesla/gen3-current-limit-operation-v1.md'
tesla_read_acquisition_page='protocols/tesla/gen3-read-acquisition-v1.md'

# The Tesla contract rules live in scripts/tesla_contract_rules.json. The first
# argument selects comma-separated contracts; each further argument maps a
# repository page to the document checked in its place.
check_tesla_contract() {
  local contracts="$1"
  shift
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  python3 "$root/scripts/check_tesla_contract.py" "$root/scripts/tesla_contract_rules.json" "$contracts" "$@"
}

check_tesla_current_limit_operation() {
  check_public_protocol "$1" || return 1
  check_tesla_contract current_limit_operation "$tesla_current_limit_page=$1"
}

check_tesla_read_acquisition() {
  check_public_protocol "$1" || return 1
  check_tesla_contract read_acquisition "$tesla_read_acquisition_page=$1"
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
		'Configured serial boundary' \
		'Configured production read and private-function endpoint' \
    'Validation and compatibility'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq 'A function-code byte never identifies a vendor, vendor profile, or operation.' "$document"
  grep -Fq 'FC100, FC101, and FC102 may be reused by different qualified vendor profiles.' "$document"
  grep -Fq 'FC0x41 is profile-qualified and is not globally reserved by this contract.' "$document"
  grep -Fq 'FC23 is a standard Modbus function code, not a private-function operation.' "$document"
  grep -Fq 'A vendor-specific allocation interpretation for FC23 requires a separately admitted standard-function operation and a typed standard-function codec.' "$document"
  grep -Fq 'This contract makes no claim about the meaning, sendability, or allocation workflow of such an operation.' "$document"
	grep -Fq 'It must not discover endpoints, select a vendor profile, infer a' "$document"
	grep -Fq 'Opening a serial stream makes transport available; it does not make any vendor' "$document"
	grep -Fq 'preconditions at the registry boundary. A serial stream must not be exposed as' "$document"
	grep -Fq 'a raw external-operation bypass.' "$document"
	grep -Fq 'in-flight exchange boundary: after an uncertain transmission, the endpoint' "$document"
	grep -Fq 'must quarantine and recover before it accepts a successor request.' "$document"
	grep -Fq 'lifecycle close ends the local stream without creating a successor request or' "$document"
	grep -Fq 'classifying itself as a failed exchange.' "$document"
	grep -Fq 'The standard read path admits only FC03 and FC04 requests' "$document"
	grep -Fq 'that have already passed the standard read-operation admission boundary.' "$document"
	grep -Fq 'Each endpoint instance has a nonzero lifecycle generation, incremented before' "$document"
	grep -Fq 'a replacement or recovery successor admits a request.' "$document"
	grep -Fq 'Accepted baud rates are 9600, 19200, 38400, 57600, 115200, and 230400; data bits are exactly eight; parity is none, even, or odd; and stop bits are one or two.' "$document"
	grep -Fq 'The response timeout is greater than zero and no more than 30 seconds.' "$document"
	grep -Fq 'Recovery has one bounded attempt and completes within the response timeout plus t3.5, with an absolute maximum of 60 seconds.' "$document"
	grep -Fq 'An exchange has exactly one send attempt; no retry is admitted by this contract.' "$document"
	grep -Fq 'FC03 and FC04 permit a zero-based offset from 0 through 65535 and a quantity from 1 through 125 registers.' "$document"
	grep -Fq 'Admission must calculate offset + quantity without 16-bit wrap and require it to be no greater than 65536; otherwise it is NO_SEND before transmission.' "$document"
	grep -Fq 'Offset 65535 with quantity 1 and offset 65411 with quantity 125 are admitted exact-boundary requests; offset 65535 with quantity 2 is NO_SEND.' "$document"
	grep -Fq 'The normal response byte-count is exactly two times the requested quantity; its RTU ADU is exactly 5 + (2 × quantity) bytes and never exceeds 255 bytes.' "$document"
	grep -Fq 'The correlation identity binds endpoint generation, request identifier, unit' "$document"
	grep -Fq 'unfenced generation and has the matching unit, function, valid RTU integrity,' "$document"
	grep -Fq 'or prior-generation frames enter quarantine and never satisfy a later request.' "$document"
	grep -Fq 'A structurally valid, correlated Modbus exception is terminal evidence for its request but does not fence the endpoint generation or require recovery.' "$document"
	grep -Fq 'A malformed, CRC-failed, late, unrelated, or prior-generation exception is a transport fault and enters quarantine.' "$document"
	grep -Fq 'Every terminal exchange retains immutable request and response ADU bytes,' "$document"
	grep -Fq 'integrity result, endpoint generation, correlation identifier, unit identifier,' "$document"
	grep -Fq 'function, monotonic send and receipt bounds, retry disposition, and terminal' "$document"
	grep -Fq 'outcome. Failed exchanges retain their available request and transport evidence' "$document"
	grep -Fq 'stable configured endpoint label, never a local serial path.' "$document"
	grep -Fq 'closed, replaced, fenced, or quarantined generation is historical only and' "$document"
	grep -Fq 'cannot authorize, correlate, or be rebound to a successor request.' "$document"
  for required in \
    '`RTUProductionConfig.PrivateFunction`' \
    '`RTUPrivateFunctionAdmission` and `MaxResponses` from 1 through 8, both or' \
    'neither. The zero value (no admission and zero maximum responses) disables' \
    'the policy allows exactly one attempt, the unit is not broadcast' \
    'function code is in the user-defined ranges 65–72 or 100–110' \
    'exchange, shared by FC03/FC04 reads and private-function exchanges.' \
    'first-byte receipt and the t3.5 frame end.' \
    'CRC before unit, function, and exception-shape correlation.' \
    'Without a classifier, the first good normal frame is terminal.' \
    'a terminal frame at the bound is accepted.' \
    'transport does not bound classifier' \
    'without fencing. Every other failure of a started private exchange fences the' \
    'generation until `Recover` succeeds' \
    'including a failing final frame or partial bytes' \
    '`RTUPrivateFunctionEvidence` receipt, not an FC03/FC04 read receipt.' \
    'It reports `Current=false` once its generation is fenced, recovered, or closed.' \
    'Success at receipt time is recorded by `TerminalOutcome=success`, not by `Current`.' \
    'Cancellation observed after a frame is classified `Terminal` still fences the endpoint and returns no responses.' \
    'Unit identifiers above 247 are also rejected before transmission.' \
    'order, terminal rule, and read-only classification remain registry-owned.'; do
    grep -Fq "$required" "$document" || return 1
  done
}

sunspec_v2_page='protocols/sunspec/read-only-core-v2.md'
sunspec_licensing_page='protocols/applicability-and-licensing.md'
sunspec_v1_core_page='protocols/sunspec/read-only-core-v1.md'
sunspec_v1_families_page='protocols/sunspec/read-only-core-v1-model-families.md'
sunspec_nested_layout_page='protocols/sunspec/nested-layout-contract-v1.md'
sunspec_der_trip_lv_template_page='protocols/sunspec/der-trip-lv-template-v2.md'
sunspec_der_trip_lv_projection_page='protocols/sunspec/der-trip-lv-typed-fact-projection-v2.md'
sunspec_dynamic_selection_page='protocols/sunspec/dynamic-structural-selection-v2.md'
sunspec_contracts='v2_contract,v2_licensing,licensing_page,v1_core_page,v1_model_families,nested_layout,der_trip_lv_template,der_trip_lv_projection,dynamic_structural_selection'

# The SunSpec contract rules live in scripts/sunspec_contract_rules.json, with
# the former top-level lines of the applicability and V1 core pages. The first
# argument selects comma-separated contracts; each further argument maps a
# repository page to the document checked in its place.
check_sunspec_contract() {
  local contracts="$1"
  shift
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  python3 "$root/scripts/check_sunspec_contract.py" "$root/scripts/sunspec_contract_rules.json" "$contracts" "$@"
}

check_sunspec_v2_contract() {
  check_public_protocol "$1" || return 1
  check_sunspec_contract v2_contract "$sunspec_v2_page=$1"
}

check_sunspec_v2_licensing() {
  check_sunspec_contract v2_licensing "$sunspec_licensing_page=$1"
}

check_sunspec_v1_model_families_contract() {
  check_public_protocol "$1" || return 1
  check_sunspec_contract v1_model_families "$sunspec_v1_families_page=$1"
}

check_fronius_qualification_readiness() {
  local document="$1"
  local contradiction='live_qualified[=: ]+true|automatic_runtime_admission[=: ]+true|write_authority[=: ]+true|support claim is established|partial positive result is permitted'

  check_public_protocol "$document"
  for heading in \
    'Scope and evidence state' \
    'Qualification card' \
    'Complete-chain replay matrix' \
    'Typed native facts and retention' \
    'Sanitized expected result' \
    'Failure and requalification boundary'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq '`sunspec.qualification.fronius.gen24.float.readonly@1.0.0`' "$document"
  grep -Fq '`sunspec.flavor.fronius.gen24.float.observed@1.1.0`' "$document"
  grep -Fq '`1.41.11-1`' "$document"
  grep -Fq 'The generic three-phase SunSpec monitoring capability is evaluated separately' "$document"
  grep -Fq 'The initial base-candidate' "$document"
  grep -Fq 'set is exactly `[40000]`; the maximum chain is 512 words and 64 model' "$document"
  grep -Fq 'adapter to at most 125 words.' "$document"
  grep -Fq '| Structurally valid unknown model | retain the opaque occurrence, raw words, order, and source spans; generic capability may remain admitted; exact flavor does not match |' "$document"
  grep -Fq '| Duplicate known model | retain each occurrence separately; exact flavor does not match |' "$document"
  grep -Fq '| Known model with an unsupported length | retain it as `unsupported_length`; exact flavor does not match |' "$document"
  grep -Fq '| Missing payload chunk or terminal chunk | remain incomplete and produce no qualification observation |' "$document"
  grep -Fq '| Unavailable sentinel in a required Model 113 fact | retain the raw value; reject the generic capability and exact flavor |' "$document"
  grep -Fq '| Different manufacturer, model, or firmware | generic standard capability may remain admitted; exact Fronius flavor does not match |' "$document"
  for field in \
    inverter.ac.current.total inverter.ac.current.phase_a inverter.ac.current.phase_b inverter.ac.current.phase_c \
    inverter.ac.voltage.phase_a inverter.ac.voltage.phase_b inverter.ac.voltage.phase_c \
    inverter.ac.power.active inverter.ac.frequency inverter.ac.energy_lifetime \
    inverter.temperature.cabinet inverter.operating_state inverter.events.1 inverter.events.2; do
    grep -Fq "\`$field\`" "$document"
  done
  grep -Fq 'it is not a promotion or publication decision.' "$document"
  grep -Fq '`raw_words`, `occurrence_order`, `source_spans`, and' "$document"
  grep -Fq '"live_qualified": false' "$document"
  grep -Fq '"automatic_runtime_admission": false' "$document"
  grep -Fq '"write_authority": false' "$document"
  grep -Fq 'It does not prove a currently reachable device, a product support claim, a' "$document"
  if grep -Ein "$contradiction" "$document"; then
    echo 'Fronius qualification readiness contract exceeds its offline read-only boundary' >&2
    return 1
  fi
}

check_sunspec_nested_layout_contract() {
  check_public_protocol "$1" || return 1
  check_sunspec_contract nested_layout "$sunspec_nested_layout_page=$1"
}

check_sunspec_der_trip_lv_template_v2() {
  check_public_protocol "$1" || return 1
  check_sunspec_contract der_trip_lv_template "$sunspec_der_trip_lv_template_page=$1"
}

check_sunspec_der_trip_lv_typed_fact_projection_v2() {
  check_public_protocol "$1" || return 1
  check_sunspec_contract der_trip_lv_projection "$sunspec_der_trip_lv_projection_page=$1"
}

check_sunspec_dynamic_structural_selection_v2() {
  check_public_protocol "$1" || return 1
  check_sunspec_contract dynamic_structural_selection "$sunspec_dynamic_selection_page=$1"
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

growatt_x2_page='protocols/growatt/shinewilan-x2-bridge-v1.md'
growatt_bms_page='protocols/growatt/bms-rs485-1xsxxp-v202.md'
growatt_protocol_ii_page='protocols/growatt/protocol-ii-readonly-v1.md'
growatt_protocol_ii_matrix_page='protocols/growatt/protocol-ii-source-profile-matrix-v1.md'
growatt_wit_page='protocols/growatt/wit-family-protocol-matrix-v1.md'
growatt_contracts='x2_page,x2_contract,bms_page,bms_contract,protocol_ii_identity,protocol_ii_fc04,protocol_ii_source_matrix,wit_matrix'

# The Growatt contract rules live in scripts/growatt_contract_rules.json. The
# first argument selects comma-separated contracts; each further argument maps
# a repository page to the document checked in its place.
check_growatt_contract() {
  local contracts="$1"
  shift
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  python3 "$root/scripts/check_growatt_contract.py" "$root/scripts/growatt_contract_rules.json" "$contracts" "$@"
}

check_x2_contract() {
  check_growatt_contract x2_contract "$growatt_x2_page=$1"
}

check_bms_contract() {
  check_growatt_contract bms_contract "$growatt_bms_page=$1"
}

check_growatt_protocol_ii_identity_projection() {
  check_public_protocol "$1" || return 1
  check_growatt_contract protocol_ii_identity "$growatt_protocol_ii_page=$1"
}

check_growatt_protocol_ii_fc04_contract() {
  check_public_protocol "$1" || return 1
  check_growatt_contract protocol_ii_fc04 "$growatt_protocol_ii_page=$1"
}

check_growatt_protocol_ii_source_matrix() {
  check_growatt_contract protocol_ii_source_matrix "$growatt_protocol_ii_matrix_page=$1"
}

check_wit_matrix_contract() {
  check_public_protocol "$1" || return 1
  check_growatt_contract wit_matrix "$growatt_wit_page=$1"
}

check_huawei_inverter_battery_disposition() {
  local document="$1"
  local heading required row actual expected

  check_public_protocol "$document" || return 1
  if grep -Ein '([0-9]{1,3}\.){3}[0-9]{1,3}|[[:alnum:].-]+:[0-9]{1,5}|0x[0-9A-Fa-f]{4,}|(^|[^[:xdigit:]])[[:xdigit:]]{40}([^[:xdigit:]]|$)|(^|[^[:xdigit:]])[[:xdigit:]]{64}([^[:xdigit:]]|$)' "$document"; then
    echo 'Huawei inverter and battery disposition contains coordinates, fingerprints, or register numbers' >&2
    return 1
  fi
  if grep -Ein '(register|address|holding|input)[[:alpha:]]*[[:space:]:#=]+([[:alpha:]]+[[:space:]]+){0,2}[0-9]{3,}|(^|[^[:alpha:]])port[[:space:]]*[:=#]?[[:space:]]*[0-9]{2,5}' "$document"; then
    echo 'Huawei inverter and battery disposition contains a decimal register address or port number' >&2
    return 1
  fi
  for heading in 'Scope' 'Evidence status' 'Disposition' 'Reopen requirements' \
    'Detection contract' 'SUN2000 decision rows' 'LUNA2000 decision rows' \
    'Optional groups' 'Safety'; do
    grep -Eq "^#{2,3} $heading$" "$document" || return 1
  done
  for required in \
    '| SUN2000 | `unknown`; nothing is observed, inferred, or qualified | none covered; all unsupported | none covered; all unsupported | all unknown |' \
    '| LUNA2000 | `unknown`; nothing is observed, inferred, or qualified | none covered; all unsupported | none covered; all unsupported | all unknown |' \
    'ordering or priority rule. Every row selects no profile and emits zero native' \
    'facts. The table is a decision contract only; it is not executable detection.' \
    'The existence of this page satisfies only the registry'"'"'s companion-page' \
    'requirement. It satisfies none of the four requirements above, and reopening' \
    'also requires a revision of this page that replaces the disposition with an' \
    'exact applicability contract.' \
    'Both classes have the outcome `NO_ADMISSIBLE_PROFILE` in this revision.' \
    '`Huawei SUN2000 MODBUS Interface Definitions`. It is' \
    '`vendor-copyright-inspection-only` and no exact version is pinned, so no' \
    'register address, scale, unit, access mode, or string is published here or in' \
    'the registry. No model family and no firmware range is covered.' \
    '`catalog_registered=false`,' \
    '`automatic_runtime_admission=false`, `support_claim=false`, and' \
    '`write_authority=false`. No live qualification has been performed.' \
    'They are not SunSpec' \
    'profiles and do not fall back to SmartLogger, EMMA, S-Dongle, or each other.' \
    'They are never inferred from another Huawei class.' \
    '- a pinned vendor document name and version;' \
    '- a clean-room sanitized identity fixture;' \
    '- a clean-room sanitized monitoring fixture; and' \
    '- executable negative overlap against SmartLogger, EMMA, and S-Dongle.' \
    'A future profile selection requires all of: exact model identity, exact' \
    'firmware identity, unit identity, and a pinned register map.' \
    'Not identity: serial number, ESN, writable alias, register readability, a model' \
    'string in a SmartLogger or EMMA child inventory, or a prefix or wildcard model' \
    'The default outcome is `INSUFFICIENT_EVIDENCE`. More than one positive' \
    'candidate for one endpoint and unit is `AMBIGUOUS` with no selection and no' \
    'ordering or priority rule. Every row selects no profile and emits zero native' \
    'does not make either class a candidate of that gateway and does not select' \
    'optional groups. An absent group yields unknown values, never numeric zero. A' \
    'read exception on an optional group does not negate an already identified unit' \
    'and retains last-known-good values where a future profile permits.' \
    'All writes and control paths are default denied. Huawei FC0x41 and FC0x17 are' \
    '`NO_SEND` for both classes, consistent with the profile-scoped rule in'; do
    grep -Fq -- "$required" "$document" || return 1
  done

  expected=$(printf '%s\n' \
    '| `no_identity_evidence` | `INSUFFICIENT_EVIDENCE` |' \
    '| `gateway_inventory_child_model_only` | `INSUFFICIENT_EVIDENCE` |' \
    '| `model_without_firmware` | `INSUFFICIENT_EVIDENCE` |' \
    '| `serial_or_esn_only` | `INSUFFICIENT_EVIDENCE` |' \
    '| `firmware_without_model` | `INSUFFICIENT_EVIDENCE` |' \
    '| `register_readability_only` | `INSUFFICIENT_EVIDENCE` |' \
    '| `battery_group_absent` | `INSUFFICIENT_EVIDENCE` |' \
    '| `battery_group_exception` | `INSUFFICIENT_EVIDENCE` |' \
    '| `multiple_positive_candidates` | `AMBIGUOUS` |' \
    '| `exact_identity_with_pinned_register_map` | `NO_ADMISSIBLE_PROFILE` |')
  actual=$(sed -n '/^### SUN2000 decision rows$/,/^### LUNA2000 decision rows$/p' "$document" \
    | sed -n 's/^\(| `[a-z_]*` | `[A-Z_]*` |\).*/\1/p')
  if [[ "$actual" != "$expected" ]]; then
    echo 'Huawei SUN2000 decision rows are not exact' >&2
    return 1
  fi
  expected=$(printf '%s\n' \
    '| `no_identity_evidence` | `INSUFFICIENT_EVIDENCE` |' \
    '| `gateway_inventory_child_model_only` | `INSUFFICIENT_EVIDENCE` |' \
    '| `parent_inverter_unidentified` | `INSUFFICIENT_EVIDENCE` |' \
    '| `model_without_firmware` | `INSUFFICIENT_EVIDENCE` |' \
    '| `serial_or_esn_only` | `INSUFFICIENT_EVIDENCE` |' \
    '| `register_readability_only` | `INSUFFICIENT_EVIDENCE` |' \
    '| `battery_group_absent` | `INSUFFICIENT_EVIDENCE` |' \
    '| `battery_group_exception` | `INSUFFICIENT_EVIDENCE` |' \
    '| `multiple_positive_candidates` | `AMBIGUOUS` |' \
    '| `exact_identity_with_pinned_register_map` | `NO_ADMISSIBLE_PROFILE` |')
  actual=$(sed -n '/^### LUNA2000 decision rows$/,/^## Optional groups$/p' "$document" \
    | sed -n 's/^\(| `[a-z_]*` | `[A-Z_]*` |\).*/\1/p')
  if [[ "$actual" != "$expected" ]]; then
    echo 'Huawei LUNA2000 decision rows are not exact' >&2
    return 1
  fi

  if grep -Ein 'registers? (is|are) (inferred|assumed) from|(is|are) (supported|qualified|admitted)\.|FC0x(41|17) (is|are) (permitted|allowed|enabled)|absent group (yields|reports) (numeric )?zero' "$document"; then
    echo 'Huawei inverter and battery disposition contradicts its fail-closed boundary' >&2
    return 1
  fi
}

check_outback_axs_contract() {
  local document="$1"
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local default_matrix="$root/protocols/outback/axs-port-source-profile-matrix-v1.md"
  local matrix="${OUTBACK_AXS_MATRIX:-$default_matrix}"

  check_public_protocol "$document" || return 1
  python3 "$root/scripts/check_outback_contract.py" "$document" "$matrix" "$root/scripts/outback_contract_rules.json"
}

check_huawei_qualification_readiness() {
  local document="$1"
  local contradiction='automatic_runtime_admission[=: ]+true|live_qualified[=: ]+true|support_claim[=: ]+true|write_authority[=: ]+true|automatic_request_count[=: ]+[1-9]|fallback_attempted[=: ]+true|missing or unavailable native values.*numeric zero'

  check_public_protocol "$document"
  for heading in \
    'Scope and class outcomes' \
    'SmartLogger qualification card' \
    'EMMA qualification card' \
    'S-Dongle evidence-blocked card' \
    'Shared resolution and negative overlap' \
    'Sanitized expected result' \
    'Integration and hardware boundary'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq '| SmartLogger | `QUALIFICATION_TEST_READY` |' "$document"
  grep -Fq '| EMMA | `QUALIFICATION_EVIDENCE_BLOCKED` |' "$document"
  grep -Fq '| S-Dongle | `QUALIFICATION_EVIDENCE_BLOCKED` |' "$document"
  grep -Fq 'No class is `HARDWARE_TEST_READY`.' "$document"
  grep -Fq '`huawei.qualification.smartlogger.readonly@1.0.0`' "$document"
  grep -Fq 'PDU offset 65521, quantity 1' "$document"
  grep -Fq '15 seconds, 248' "$document"
  grep -Fq 'pages, 248 objects, 65536 response bytes, and 247 children.' "$document"
  grep -Fq 'The first record is the self entry and its model must be exactly' "$document"
  grep -Fq 'counter change, count mismatch, cursor loop, second wrap, or any exhausted limit rejects' "$document"
  grep -Fq 'An EMMA self entry is a SmartLogger negative control and produces no SmartLogger' "$document"
  grep -Fq '`huawei.qualification.emma.readonly@1.0.0`' "$document"
  grep -Fq 'offset 30000' "$document"
  grep -Fq 'quantity 15 for offering, offset 30222 quantity 20 for model, and offset 30035' "$document"
  grep -Fq 'R024C00 requires SPC100 or' "$document"
  grep -Fq 'R025C00 requires SPC102 or greater within R025C00.' "$document"
  grep -Fq 'No comparison crosses branches.' "$document"
  grep -Fq 'does not invent a capability acquisition map.' "$document"
  for evidence in sanitized_readonly_capability_fixture negative_overlap_with_smartlogger model_specific_capability_fixture; do
    grep -Fq "\`$evidence\`" "$document"
  done
  grep -Fq '`huawei.qualification.sdongle.evidence-blocked@1.0.0`' "$document"
  grep -Fq '`LIVE_STOPPED_PERSISTENT_NON_RESPONSE` at logical unit 100.' "$document"
  for evidence in gateway_unit_100_topology sanitized_basic_mei_product_model_fixture exact_protocol_version_encoding_fixture completed_search_stable_sequence_capacity_fixture separately_qualified_child_unit_inventory_fixture; do
    grep -Fq "\`$evidence\`" "$document"
  done
  grep -Fq 'Further I/O remains a hard stop.' "$document"
  grep -Fq 'More than one positive result produces `AMBIGUOUS`,' "$document"
  grep -Fq 'retains the candidate class names, and selects no class.' "$document"
  grep -Fq 'A mixed resolution set containing one positive class and any failed class stays' "$document"
  grep -Fq 'downgrade that hard stop or select another class around it.' "$document"
  grep -Fq 'zero automatic requests, and `fallback_attempted=false`.' "$document"
  grep -Fq 'they are never emitted as numeric zero, an empty' "$document"
  grep -Fq '"automatic_runtime_admission": false' "$document"
  grep -Fq '`automatic_request_count=0`' "$document"
  grep -Fq '`native_fact_count=0`' "$document"
  if grep -Ein "$contradiction" "$document"; then
    echo 'Huawei qualification readiness contract exceeds its default-denied offline boundary' >&2
    return 1
  fi
}

if [[ $# -gt 0 ]]; then
  if [[ "$1" == '--check-license-texts' ]]; then
    if [[ $# -ne 2 ]]; then
      echo 'usage: check_docs.sh --check-license-texts repository-directory' >&2
      exit 2
    fi
    check_license_texts "$2"
    exit $?
  fi
  if [[ $# -ne 2 ]] && [[ "$1" != '--check-tesla-generation-contracts' || $# -ne 3 ]]; then
    echo 'usage: check_docs.sh [--check-tesla-current-limit-operation|--check-tesla-read-acquisition|--check-sdongle-admission|--check-public-protocol|--check-tesla-tedapi-contract|--check-tesla-generation-contracts|--check-private-function-contract|--check-sunspec-v1-model-families-contract|--check-fronius-qualification-readiness|--check-huawei-qualification-readiness|--check-huawei-inverter-battery-disposition|--check-sunspec-nested-layout-contract|--check-sunspec-der-trip-lv-template-v2|--check-sunspec-der-trip-lv-typed-fact-projection-v2|--check-sunspec-dynamic-structural-selection-v2|--check-sunspec-v2-contract|--check-sunspec-v2-licensing|--check-x2-publication|--check-x2-contract|--check-bms-contract|--check-growatt-protocol-ii-identity-projection|--check-growatt-protocol-ii-fc04-contract|--check-growatt-protocol-ii-source-matrix|--check-wit-matrix-contract document]' >&2
    exit 2
  fi
  case "$1" in
    --check-tesla-current-limit-operation) check_tesla_current_limit_operation "$2" ;;
    --check-tesla-read-acquisition) check_tesla_read_acquisition "$2" ;;
    --check-sdongle-admission) check_sdongle_admission "$2" ;;
    --check-public-protocol) check_public_protocol "$2" ;;
    --check-tesla-tedapi-contract) check_tesla_contract tedapi,evse_scope "$tesla_tedapi_page=$2" ;;
    --check-tesla-generation-contracts)
      if [[ $# -ne 3 ]]; then
        exit 2
      fi
      check_tesla_contract legacy_public_protocol,gen3_public_protocol,generation \
        "$tesla_legacy_page=$2" "$tesla_gen3_page=$3"
      ;;
		--check-tesla-legacy-evse-current-contract)
			check_tesla_contract legacy_evse_current "$tesla_legacy_page=$2"
			;;
		--check-tesla-gen3-evse-current-limit-contract)
			check_tesla_contract gen3_evse_current_limit "$tesla_gen3_page=$2"
			;;
		--check-tesla-gen3-evse-current-limit-wire-evidence)
			check_tesla_contract gen3_wire_evidence "$tesla_gen3_page=$2"
			;;
		--check-tesla-gen3-evse-current-limit-mcp-projection)
			check_tesla_contract gen3_mcp_projection "$tesla_gen3_page=$2"
			;;
    --check-private-function-contract) check_private_function_contract "$2" ;;
    --check-sunspec-v1-model-families-contract) check_sunspec_v1_model_families_contract "$2" ;;
    --check-fronius-qualification-readiness) check_fronius_qualification_readiness "$2" ;;
    --check-huawei-qualification-readiness) check_huawei_qualification_readiness "$2" ;;
    --check-huawei-inverter-battery-disposition) check_huawei_inverter_battery_disposition "$2" ;;
    --check-sunspec-nested-layout-contract) check_sunspec_nested_layout_contract "$2" ;;
    --check-sunspec-der-trip-lv-template-v2) check_sunspec_der_trip_lv_template_v2 "$2" ;;
    --check-sunspec-der-trip-lv-typed-fact-projection-v2) check_sunspec_der_trip_lv_typed_fact_projection_v2 "$2" ;;
    --check-sunspec-dynamic-structural-selection-v2) check_sunspec_dynamic_structural_selection_v2 "$2" ;;
    --check-sunspec-v2-contract) check_sunspec_v2_contract "$2" ;;
    --check-sunspec-v2-licensing) check_sunspec_v2_licensing "$2" ;;
    --check-x2-publication) check_x2_publication "$2" ;;
    --check-x2-contract) check_x2_contract "$2" ;;
    --check-bms-contract) check_bms_contract "$2" ;;
    --check-growatt-protocol-ii-identity-projection) check_growatt_protocol_ii_identity_projection "$2" ;;
    --check-growatt-protocol-ii-fc04-contract) check_growatt_protocol_ii_fc04_contract "$2" ;;
    --check-growatt-protocol-ii-source-matrix) check_growatt_protocol_ii_source_matrix "$2" ;;
    --check-wit-matrix-contract) check_wit_matrix_contract "$2" ;;
    --check-outback-axs-contract) check_outback_axs_contract "$2" ;;
    *)
    echo 'usage: check_docs.sh [--check-tesla-current-limit-operation|--check-tesla-read-acquisition|--check-sdongle-admission|--check-public-protocol|--check-tesla-tedapi-contract|--check-private-function-contract|--check-sunspec-v1-model-families-contract|--check-fronius-qualification-readiness|--check-huawei-qualification-readiness|--check-huawei-inverter-battery-disposition|--check-sunspec-nested-layout-contract|--check-sunspec-der-trip-lv-template-v2|--check-sunspec-der-trip-lv-typed-fact-projection-v2|--check-sunspec-dynamic-structural-selection-v2|--check-sunspec-v2-contract|--check-sunspec-v2-licensing|--check-x2-publication|--check-x2-contract|--check-bms-contract|--check-growatt-protocol-ii-identity-projection|--check-wit-matrix-contract document]' >&2
      exit 2
      ;;
  esac
  exit $?
fi

check_license_texts '.'

spec='protocols/tesla/tedapi.md'
test -f "$spec"
tesla_legacy_spec='protocols/tesla/legacy-wall-connector-rs485.md'
tesla_gen3_spec='protocols/tesla/gen3-hsc-rtu.md'
tesla_current_limit_spec='protocols/tesla/gen3-current-limit-operation-v1.md'
test -f "$tesla_legacy_spec"
test -f "$tesla_gen3_spec"
test -f "$tesla_current_limit_spec"
tesla_read_acquisition_spec='protocols/tesla/gen3-read-acquisition-v1.md'
test -f "$tesla_read_acquisition_spec"
nested_layout_spec='protocols/sunspec/nested-layout-contract-v1.md'
test -f "$nested_layout_spec"
der_trip_lv_template_spec='protocols/sunspec/der-trip-lv-template-v2.md'
test -f "$der_trip_lv_template_spec"
der_trip_lv_projection_spec='protocols/sunspec/der-trip-lv-typed-fact-projection-v2.md'
test -f "$der_trip_lv_projection_spec"
dynamic_structural_selection_spec='protocols/sunspec/dynamic-structural-selection-v2.md'
test -f "$dynamic_structural_selection_spec"
fronius_qualification_spec='protocols/fronius/qualification-readiness-v1.md'
test -f "$fronius_qualification_spec"
huawei_qualification_spec='protocols/huawei/qualification-readiness-v1.md'
test -f "$huawei_qualification_spec"
private_spec='protocols/modbus/private-function-codes.md'
test -f "$private_spec"
sdongle_admission='architecture/sdongle-qualification-disposition-v1.md'
test -f "$sdongle_admission"

multivendor_specs=(
  'protocols/applicability-and-licensing.md'
  'protocols/sunspec/read-only-core-v1.md'
  'protocols/sunspec/read-only-core-v1-model-families.md'
  'protocols/sunspec/read-only-core-v2.md'
  'protocols/sunspec/nested-layout-contract-v1.md'
  'protocols/fronius/sunspec-float-v1.md'
  'protocols/fronius/qualification-readiness-v1.md'
  'protocols/huawei/gateway-readonly-v1.md'
  'protocols/huawei/qualification-readiness-v1.md'
  'protocols/huawei/inverter-battery-readonly-v1.md'
  'protocols/growatt/protocol-ii-readonly-v1.md'
  'protocols/growatt/shinewilan-x2-bridge-v1.md'
  'protocols/growatt/bms-rs485-1xsxxp-v202.md'
  'protocols/growatt/wit-family-protocol-matrix-v1.md'
  'protocols/outback/axs-port-sunspec-readonly-v1.md'
)
for multivendor_spec in "${multivendor_specs[@]}"; do
  test -f "$multivendor_spec"
done

check_tesla_contract \
  tedapi,evse_scope,legacy_public_protocol,gen3_public_protocol,generation,legacy_evse_current,gen3_evse_current_limit,gen3_wire_evidence,gen3_mcp_projection \
  "$tesla_tedapi_page=$spec" "$tesla_legacy_page=$tesla_legacy_spec" "$tesla_gen3_page=$tesla_gen3_spec"
check_tesla_current_limit_operation "$tesla_current_limit_spec"
check_tesla_read_acquisition "$tesla_read_acquisition_spec"

check_private_function_contract "$private_spec"

check_public_protocol "$der_trip_lv_template_spec"
check_public_protocol "$der_trip_lv_projection_spec"
check_public_protocol "$dynamic_structural_selection_spec"
check_sunspec_contract "$sunspec_contracts" \
  "$sunspec_v2_page=$sunspec_v2_page" "$sunspec_licensing_page=$sunspec_licensing_page" \
  "$sunspec_v1_core_page=$sunspec_v1_core_page" "$sunspec_v1_families_page=$sunspec_v1_families_page" \
  "$sunspec_nested_layout_page=$nested_layout_spec" \
  "$sunspec_der_trip_lv_template_page=$der_trip_lv_template_spec" \
  "$sunspec_der_trip_lv_projection_page=$der_trip_lv_projection_spec" \
  "$sunspec_dynamic_selection_page=$dynamic_structural_selection_spec"
grep -Fqx '## Exact chain geometry' 'protocols/fronius/sunspec-float-v1.md'
check_fronius_qualification_readiness "$fronius_qualification_spec"
check_huawei_qualification_readiness "$huawei_qualification_spec"
check_huawei_inverter_battery_disposition 'protocols/huawei/inverter-battery-readonly-v1.md'
grep -Fqx '## SmartLogger candidate' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fqx '## S-Dongle candidate' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fqx '## EMMA candidate' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fqx '## Private function codes' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq 'A gateway-unit timeout never authorizes a child-unit scan' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq '`EMMA-A01` and' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq 'admitted by family, through the editions and model rows that the gateway' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq '`EMMA-A02` are the observed models of this contract' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq 'EMMA-A01 never inherits an EMMA-A02-only capability.' 'protocols/huawei/gateway-readonly-v1.md'
grep -Fq 'Basic and extended MEI are optional enrichment, never initial EMMA identification.' 'protocols/huawei/gateway-readonly-v1.md'
check_growatt_contract "$growatt_contracts" \
  "$growatt_x2_page=$growatt_x2_page" "$growatt_bms_page=$growatt_bms_page" \
  "$growatt_protocol_ii_page=$growatt_protocol_ii_page" \
  "$growatt_protocol_ii_matrix_page=$growatt_protocol_ii_matrix_page" \
  "$growatt_wit_page=$growatt_wit_page"
check_x2_publication "$growatt_x2_page"
check_outback_axs_contract 'protocols/outback/axs-port-sunspec-readonly-v1.md'

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
  if [[ "$multivendor_spec" == 'protocols/growatt/bms-rs485-1xsxxp-v202.md' ]]; then
    continue
  fi
  check_public_protocol "$multivendor_spec"
done
