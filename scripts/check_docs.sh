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

vendor_private_function_page='protocols/modbus/private-function-codes.md'
vendor_fronius_qualification_page='protocols/fronius/qualification-readiness-v1.md'
vendor_fronius_float_page='protocols/fronius/sunspec-float-v1.md'
vendor_huawei_qualification_page='protocols/huawei/qualification-readiness-v1.md'
vendor_huawei_disposition_page='protocols/huawei/inverter-battery-readonly-v1.md'
vendor_huawei_gateway_page='protocols/huawei/gateway-readonly-v1.md'
vendor_sdongle_page='architecture/sdongle-qualification-disposition-v1.md'
vendor_contracts='private_function,fronius_qualification,fronius_float_page,huawei_qualification,huawei_disposition,huawei_gateway_page,sdongle_page'

# The Huawei, Fronius, private-function and S-Dongle contract rules live in
# scripts/vendor_contract_rules.json, with the former top-level lines of the
# Fronius float, Huawei gateway and S-Dongle pages. The first argument selects
# comma-separated contracts; each further argument maps a repository page to
# the document checked in its place.
check_vendor_contract() {
  local contracts="$1"
  shift
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  python3 "$root/scripts/check_vendor_contract.py" "$root/scripts/vendor_contract_rules.json" "$contracts" "$@"
}

check_private_function_contract() {
  check_public_protocol "$1" || return 1
  check_vendor_contract private_function "$vendor_private_function_page=$1"
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
  check_public_protocol "$1" || return 1
  check_vendor_contract fronius_qualification "$vendor_fronius_qualification_page=$1"
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

# Coordinates, fingerprints, register numbers and port numbers stay
# publication checks of the page; its statements live in the rule table.
check_huawei_disposition_publication() {
  local document="$1"

  check_public_protocol "$document" || return 1
  if grep -Ein '([0-9]{1,3}\.){3}[0-9]{1,3}|[[:alnum:].-]+:[0-9]{1,5}|0x[0-9A-Fa-f]{4,}|(^|[^[:xdigit:]])[[:xdigit:]]{40}([^[:xdigit:]]|$)|(^|[^[:xdigit:]])[[:xdigit:]]{64}([^[:xdigit:]]|$)' "$document"; then
    echo 'Huawei inverter and battery disposition contains coordinates, fingerprints, or register numbers' >&2
    return 1
  fi
  if grep -Ein '(register|address|holding|input)[[:alpha:]]*[[:space:]:#=]+([[:alpha:]]+[[:space:]]+){0,2}[0-9]{3,}|(^|[^[:alpha:]])port[[:space:]]*[:=#]?[[:space:]]*[0-9]{2,5}' "$document"; then
    echo 'Huawei inverter and battery disposition contains a decimal register address or port number' >&2
    return 1
  fi
}

check_huawei_inverter_battery_disposition() {
  check_huawei_disposition_publication "$1" || return 1
  check_vendor_contract huawei_disposition "$vendor_huawei_disposition_page=$1"
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
  check_public_protocol "$1" || return 1
  check_vendor_contract huawei_qualification "$vendor_huawei_qualification_page=$1"
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

check_public_protocol "$private_spec"

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
check_huawei_disposition_publication "$vendor_huawei_disposition_page"
check_vendor_contract "$vendor_contracts" \
  "$vendor_private_function_page=$private_spec" \
  "$vendor_fronius_qualification_page=$fronius_qualification_spec" \
  "$vendor_fronius_float_page=$vendor_fronius_float_page" \
  "$vendor_huawei_qualification_page=$huawei_qualification_spec" \
  "$vendor_huawei_disposition_page=$vendor_huawei_disposition_page" \
  "$vendor_huawei_gateway_page=$vendor_huawei_gateway_page" \
  "$vendor_sdongle_page=$sdongle_admission"
check_growatt_contract "$growatt_contracts" \
  "$growatt_x2_page=$growatt_x2_page" "$growatt_bms_page=$growatt_bms_page" \
  "$growatt_protocol_ii_page=$growatt_protocol_ii_page" \
  "$growatt_protocol_ii_matrix_page=$growatt_protocol_ii_matrix_page" \
  "$growatt_wit_page=$growatt_wit_page"
check_x2_publication "$growatt_x2_page"
check_outback_axs_contract 'protocols/outback/axs-port-sunspec-readonly-v1.md'

check_sdongle_admission "$sdongle_admission"

for multivendor_spec in "${multivendor_specs[@]}"; do
  if [[ "$multivendor_spec" == 'protocols/growatt/bms-rs485-1xsxxp-v202.md' ]]; then
    continue
  fi
  check_public_protocol "$multivendor_spec"
done
