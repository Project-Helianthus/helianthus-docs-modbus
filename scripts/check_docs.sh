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

check_tesla_tedapi_contract() {
	local document="$1"
	local evse_required=(
    'Scope and non-goals' 'Terminology' 'Endpoint roles' 'Serial settings'
    'Frame structure' 'Function 100' 'Functions 101 and 102'
    'Fail-closed validation rules' 'Unknown payload and field retention'
    'Capability and version gates' 'Compatibility and versioning'
	)
	for heading in "${evse_required[@]}"; do grep -Fqx "## $heading" "$document"; done
	grep -Fqx '### FC100 EVSE operation registry' "$document"
	grep -Fq 'Records retain complete native EVSE payload with version, function, direction, and outcome.' "$document"
	check_tesla_evse_scope "$document"
}

check_tesla_generation_contracts() {
	local legacy="$1"
	local gen3="$2"

	check_public_protocol "$legacy"
	check_public_protocol "$gen3"

	for heading in \
		'Scope and identification' \
		'Serial and framing' \
		'Checksum' \
		'Command-family boundary' \
		'Qualification' \
		'Native retention' \
		'Safety boundary' \
		'Compatibility'; do
		grep -Fqx "## $heading" "$legacy"
	done
	grep -Fq 'The legacy profile is a pre-Gen3 candidate and is not an assertion that every Wall Connector Gen2 implements this protocol.' "$legacy"
	grep -Fq 'A legacy command byte `FC` is not a Modbus function code.' "$legacy"
	grep -Fq 'FC100, FC101, and FC102 are not part of this contract.' "$legacy"
	grep -Fq '9600 baud, eight data bits, no parity, and one stop bit' "$legacy"
	grep -Fq 'C0 | escaped(message) | C0' "$legacy"
	grep -Fq 'C0 -> DB DC' "$legacy"
	grep -Fq 'DB -> DB DD' "$legacy"
	grep -Fq 'sum(message_without_checksum[1:]) & 0xff' "$legacy"
	grep -Fq 'The family-compatible tier accepts a locally declared legacy protocol family without claiming a firmware build.' "$legacy"
	grep -Fq 'Native runtime records retain bounded decoded frames and unknown command payloads exactly.' "$legacy"

	for heading in \
		'Scope and separation' \
		'Serial and activation' \
		'RTU framing' \
		'Function boundary' \
		'Exact version profiles' \
		'Qualification' \
		'Native retention' \
		'Safety boundary' \
		'Compatibility'; do
		grep -Fqx "## $heading" "$gen3"
	done
	grep -Fq 'It must not use the legacy SLIP framing, checksum, command vocabulary, or qualification predicate.' "$gen3"
	grep -Fq '115200 baud, eight data bits, no parity, and one stop bit' "$gen3"
	grep -Fq '`TESLA` followed by NUL and then `PASS` followed by NUL' "$gen3"
	grep -Fq 'FC100, FC101, and FC102 are private function-code values selected only by this Gen3 profile.' "$gen3"
	grep -Fq '`wc3_24_28_3` and `wc3_24_44_3` are known HSC observations, not a version whitelist.' "$gen3"
	grep -Fq '`compatible_candidate` retains an unenumerated Gen3 version with its native payloads.' "$gen3"
	grep -Fq 'No numeric minimum version is asserted by this contract.' "$gen3"
	grep -Fq 'otherwise it is `unknown`.' "$gen3"
	grep -Fq 'The version label alone does not grant a HSC operation or live exchange.' "$gen3"
	grep -Fq 'Native runtime records retain bounded payloads, including unknown fields, exactly.' "$gen3"
	grep -Fqx '## Native operation records' "$gen3"
	grep -Fq 'record retains its selected Gen3 profile, operation version, private function' "$gen3"
	grep -Fq 'complete bounded native payload for each retained request or response.' "$gen3"
	grep -Fq 'The FC100 catalog applies only to the Gen3 profile; it does not select or reinterpret' "$gen3"
	grep -Fq 'FC101 and FC102 retain the same native record context, while their normal payloads remain' "$gen3"
	grep -Fq 'opaque unless a separate version-scoped operation contract assigns a named' "$gen3"
	if grep -Eqi '([0-9]+\.[0-9]+\.[0-9]+)[^.]*\b(minimum|or newer|and later|qualifies)\b|\bminimum version\b[^.]*[0-9]' "$gen3"; then
		echo 'Tesla Gen3 contract introduces a numeric version threshold' >&2
		return 1
	fi
}

check_tesla_evse_scope() {
	local document="$1"
	local forbidden='wifi|wi-fi|(^|[^[:alnum:]])AP([^[:alnum:]]|$)|pairing|provision|registration|activat(e|ion)|credential|password|auth(entication|orization)?|OCPP|(^|[^[:alnum:]])LED([^[:alnum:]]|$)|service|debug|eCAN|mailbox|(^|[^[:alnum:]])reset([^[:alnum:]]|$)|factory[[:space:]-]?reset|perform[[:space:]-]?reset|perform[[:space:]-]?update|check[[:space:]-]?for[[:space:]-]?update|clear[[:space:]-]?update|reboot|firmware[[:space:]-]?update|AccessControl|ChargeSchedule|SecurityParameter|CountryCode|Neurio'

	grep -Fqx '### FC100 EVSE operation registry' "$document"
	grep -Fq 'GetVitals' "$document"
	grep -Fq 'GetLifetimeStats' "$document"
	grep -Fq 'GetLoadSharingNetworkState' "$document"
	grep -Fq 'GetSystemInfo' "$document"
	grep -Fq 'EVSE charging-current limit control' "$document"
	if grep -Eqi "$forbidden" "$document"; then
		echo 'Tesla TEDAPI document exceeds the EVSE interoperability scope' >&2
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
		'Configured serial boundary' \
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
	grep -Fq '707, 708, 709, 713, 714, 715, 802, 803, 804, 805, 806, 807, 808, and 809, and the terminal block.' "$document"
	grep -Fq '708, 709, 713, 714, 715, 802, 803, 804, 805, 806, 807, 808, and 809.' "$document"
  grep -Fq '| 1 | 66 | Common device information |' "$document"
  grep -Fq '| 701 | 153 | DER AC measurement |' "$document"
  grep -Fq '| 702 | 50 | DER capacity |' "$document"
	grep -Fq '| 703 | 17 | DER enter-service observed state |' "$document"
	grep -Fq '| 707 | `7 + NCrvSet*(4 + 9*NPt)` | DER Trip LV nested geometry, raw-only quarantine |' "$document"
	grep -Fq '| 708 | `7 + NCrvSet*(4 + 9*NPt)` | DER Trip HV nested geometry, raw-only quarantine |' "$document"
	grep -Fq '| 709 | `7 + NCrvSet*(4 + 12*NPt)` | DER Trip LF nested geometry, raw-only quarantine |' "$document"
  grep -Fq '| 713 | 7 | DER storage capacity |' "$document"
  grep -Fq '| 714 | `18 + 25*NPrt` | DER DC measurement with repeated ports |' "$document"
	grep -Fq '| 715 | 7 | DER controller observed state |' "$document"
	grep -Fq '| 802 | 62 | BESS base observed state |' "$document"
	grep -Fq '| 803 | `26 + 32*NStr` | BESS bank observed state with repeated strings |' "$document"
	grep -Fq '| 804 | `46 + 16*NMod` | BESS string observed state with repeated modules |' "$document"
	grep -Fq '| 805 | 42 | BESS module observed state |' "$document"
	grep -Fq '| 806 | 1 | Flow battery structural observed state |' "$document"
	grep -Fq '| 807 | 34 | Flow battery string observed state |' "$document"
	grep -Fq '| 808 | 1 | Flow battery module structural observed state |' "$document"
	grep -Fq '| 809 | 1 | Flow battery stack structural observed state |' "$document"
  grep -Fq 'Models 703 and 715 are control-observability only.' "$document"
  grep -Fq 'No point in either model creates a write method, send authority, operation admission,' "$document"
	grep -Fq 'Models 704 through 706 and 710 through 712 remain outside this V2 wave and remain opaque.' "$document"
	grep -Fqx '## DER Trip nested geometry' "$document"
	grep -Fq '`NPt` is at payload-register offset' "$document"
	grep -Fq '3 and absolute model word 5.' "$document"
	grep -Fq '`NCrvSet` is at payload-register offset 4 and' "$document"
	grep -Fq 'absolute model word 6.' "$document"
	grep -Fq 'are each 0 through 65534; zero is valid.' "$document"
	grep -Fq '`Crv[i].MustTrip.Pt[j]`, `Crv[i].MayTrip.Pt[j]`, and' "$document"
	grep -Fq '`Crv[i].MomCess.Pt[j]` are distinct nested paths.' "$document"
	grep -Fq 'must not infer `P` or `C` from' "$document"
	grep -Fq '`L`, `ActPt`, or trailing words.' "$document"
	grep -Fq 'For a model-specific point span `S`, the zero-based payload offset of' "$document"
	grep -Fq '`Crv[i]` is `7 + (i-1)*(4 + 3*S*P)`.' "$document"
	grep -Fq '`MustTrip.ActPt`, `MayTrip.ActPt`, and `MomCess.ActPt` are respectively at' "$document"
	grep -Fq 'offsets `+1`, `+2 + S*P`, and `+3 + 2*S*P`.' "$document"
	grep -Fq '`Pt[j]` begins one data register after `ActPt` plus `(j-1)*S`.' "$document"
	grep -Fq 'Models 707, 708, and 709 are inventory-known raw-only quarantine blocks.' "$document"
	grep -Fq 'separate occurrence-aware nested-layout contract is required before any typed' "$document"
	grep -Fq 'Every field in Models 707, 708, and 709, including `Ena`, `AdptCrvReq`,' "$document"
	grep -Fq 'No field creates a write method, send authority, operation admission,' "$document"
	grep -Fqx '## DER Trip model-specific observed fields' "$document"
	grep -Fq 'Model 707 has `V_SF` and `Tms_SF`. Every nested `Pt[j]` is `V:uint16` scaled by' "$document"
	grep -Fq '`V_SF` followed by `Tms:uint32` scaled by `Tms_SF`, consuming three data' "$document"
	grep -Fq '`L = 7 + C*(4 + 9*P)`.' "$document"
	grep -Fq 'Model 708 has the same source-derived point spans as Model 707:' "$document"
	grep -Fq 'consuming three data registers per `Pt[j]`. Its exact declared data-register' "$document"
	grep -Fq 'Model 709 has `Hz_SF` and `Tms_SF`. Every nested `Pt[j]` is `Hz:uint32` scaled' "$document"
	grep -Fq 'by `Hz_SF` followed by `Tms:uint32` scaled by `Tms_SF`, consuming four data' "$document"
	grep -Fq '`L = 7 + C*(4 + 12*P)`.' "$document"
	grep -Fq 'For Models 707 and 708, `S` is 3; for Model 709, `S` is 4.' "$document"
	grep -Fq 'Model 802 is a fixed-geometry battery base block with declared length 62.' "$document"
	grep -Fq 'It occupies 64 total words including its header and has no repeated group.' "$document"
	grep -Fq 'Every Model 802 field is observed state only and is `NO_SEND`.' "$document"
	grep -Fq 'No Model 802 field creates a write method, operation dispatch, control behavior,' "$document"
	grep -Fq 'Model 801 remains excluded as deprecated.' "$document"
	grep -Fq 'Models 806 through 809 remain separately bounded flow battery structural leaves.' "$document"
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
	grep -Fq 'Model 808 has fixed data-register length 1 and no effective repeated group.' "$document"
	grep -Fq '`ModuleTBD` remains uninterpreted structural observed state.' "$document"
	grep -Fq 'The declared stack group has count zero and is not materialized.' "$document"
	grep -Fq 'Model 808 does not infer a relationship to Models 803 through 807 or 809.' "$document"
	grep -Fq 'Every Model 808 field, including the zero-count `StackTBD` group name, is observed state only and is `NO_SEND`.' "$document"
	grep -Fq 'No Model 808 field creates a write method, send authority, operation admission,' "$document"
	grep -Fq 'Model 809 has fixed data-register length 1 and no effective repeated group.' "$document"
	grep -Fq '`StackTBD` remains uninterpreted structural observed state.' "$document"
	grep -Fq 'The declared cell group has count zero and is not materialized.' "$document"
	grep -Fq 'Model 809 does not infer a relationship to Models 803 through 808.' "$document"
	grep -Fq 'Every Model 809 field, including the zero-count `CellTBD` group name, is observed state only and is `NO_SEND`.' "$document"
	grep -Fq 'No Model 809 field creates a write method, send authority, operation admission,' "$document"
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

check_sunspec_nested_layout_contract() {
  local document="$1"

  check_public_protocol "$document"
  for heading in \
    'Scope' \
    'Template selection' \
    'Per-occurrence validation' \
    'Hierarchical paths and offsets' \
    'Bounds and allocation' \
    'Failure and isolation' \
    'No-send boundary' \
    'Bounded examples' \
    'Compatibility'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq 'An immutable schema template is selected only by the exact schema revision and model identifier.' "$document"
  grep -Fq 'A declared length never selects a template and is never an expanded-layout cache key.' "$document"
  grep -Fq 'A layout is instantiated for one occurrence only after every documented count and its declared length validate together.' "$document"
  grep -Fq 'It must not infer counts from a declared length, an activation point, or trailing words.' "$document"
  grep -Fq '`Crv[2].MustTrip.Pt[5].Hz` is a hierarchical path, not a flattened repeat index.' "$document"
  grep -Fq 'Offsets are relative to the occurrence and map each decoded point to exact source spans.' "$document"
  grep -Fq 'Checked arithmetic applies before every extent, aggregate, fact-count, or allocation decision.' "$document"
  grep -Fq 'Invalid geometry remains raw-only with zero typed facts.' "$document"
  grep -Fq 'V1 templates, caches, and outputs remain isolated and unchanged.' "$document"
  grep -Fq 'This contract creates no runtime, vendor, transport, gateway, live-I/O, write, send, or operation behavior.' "$document"
  grep -Fq 'Models 707, 708, and 709 are bounded examples only and do not define Model 710 or any other model.' "$document"
}

check_sunspec_der_trip_lv_template_v2() {
  local document="$1"
  local contradiction='decoder|catalog|admission|support|runtime|(^|[^0-9])708([^0-9]|$)|(^|[^0-9])709([^0-9]|$)'

  check_public_protocol "$document"
  for heading in \
    'Scope and isolation' \
    'Template identity and top-level map' \
    'Nested curve layout' \
    'Per-occurrence validation and bounds' \
    'Failure boundary' \
    'Observed-state boundary'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq 'The template identity is exactly schema revision `sunspec.models@90b4a331-v2` and Model 707.' "$document"
  grep -Fq '`NPt` and `NCrvSet` are at occurrence-word offsets 5 and 6.' "$document"
  grep -Fq '`P` and `C` each accept 0 through 65534; `0xffff` is unavailable and zero is valid.' "$document"
  grep -Fq '`L = 7 + C*(4 + 9*P)`.' "$document"
  grep -Fq 'The current isolated offline boundary requires `L <= 65534`.' "$document"
  grep -Fq '`Crv[i].MustTrip.Pt[j].V` and `Crv[i].MustTrip.Pt[j].Tms` are separate paths.' "$document"
  grep -Fq '`V` is one `uint16` word scaled by `V_SF`; `Tms` is two big-endian `uint32` words scaled by `Tms_SF`.' "$document"
  grep -Fq 'Invalid geometry remains raw-only with zero typed facts and exact raw spans.' "$document"
  grep -Fq 'Every field is observed state only and is `NO_SEND`.' "$document"
  if grep -Ein "$contradiction" "$document"; then
    echo 'SunSpec Model 707 template contract exceeds its docs-only boundary' >&2
    return 1
  fi
}

check_sunspec_der_trip_lv_typed_fact_projection_v2() {
  local document="$1"
  local contradiction='projection is admitted|projection has a decoder key|projection is a `SunSpecDecodedChain`|projection authorizes a profile|projection permits sends|projection writes to a device|projection creates an operation|projection creates live-system behavior'

  check_public_protocol "$document"
  for heading in \
    'Scope and non-emission' \
    'Public offline projection API' \
    'Stable identity and nested paths' \
    'Requiredness and observation state' \
    'Types, units, and symbols' \
    'Geometry, provenance, and isolation'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq 'It does not change the current raw-only behavior,' "$document"
  grep -Fq 'Every observation in this contract is `NO_SEND`' "$document"
  grep -Fq '`ProjectSunSpecStructuralFacts(snapshot SunSpecChainSnapshot)` accepts exactly one immutable' "$document"
  grep -Fq '`SunSpecChainSnapshot` and returns zero or more immutable' "$document"
  grep -Fq '`SunSpecStructuralProjection` records.' "$document"
  grep -Fq '`WireKey()`, `SchemaRevision()`, `Ordinal()`, `RawWords()`,' "$document"
  grep -Fq '`SourceSpans()`, and `Facts()`.' "$document"
  grep -Fq 'It has no `DecoderKey()`, admission, qualification, topology, or' "$document"
  grep -Fq '`SunSpecDecodedChain` identity.' "$document"
  grep -Fq 'Only a complete V2 Model 707 `structural_candidate` may produce a projection.' "$document"
  grep -Fq 'It must not accept or derive a projection from `SunSpecDecodedChain` or' "$document"
  grep -Fq '`SunSpecQualificationObservation`.' "$document"
  grep -Fq 'It must not recompute structural state from a wire key, words, spans, or' "$document"
  grep -Fq 'declared length; it uses only the retained private candidate sidecar.' "$document"
  grep -Fq 'Candidate absence or malformed structural geometry produces no projection and zero facts.' "$document"
  grep -Fq 'does not modify an occurrence, chain snapshot, or qualification-observation JSON.' "$document"
  grep -Fq 'Repeated Model 707 occurrences produce independent projections.' "$document"
  grep -Fq 'V1, Model 708, and Model 709 produce no projection.' "$document"
  grep -Fq 'does not change acquisition, queueing, retry, deadline, limit, or terminal behavior.' "$document"
  grep -Fq 'A FieldID names a field template and never embeds an occurrence, curve, or' "$document"
  grep -Fq '`sunspec.der.v2.707.Crv.MustTrip.Pt.V` and' "$document"
  grep -Fq '`Crv[i].MustTrip.Pt[j].V` and `Crv[i].MustTrip.Pt[j].Tms`.' "$document"
  grep -Fq '`sunspec.der.v2.707.Crv.MayTrip.Pt.V` and' "$document"
  grep -Fq '`Crv[i].MayTrip.Pt[j].V` and `Crv[i].MayTrip.Pt[j].Tms`.' "$document"
  grep -Fq '`sunspec.der.v2.707.Crv.MomCess.Pt.V` and' "$document"
  grep -Fq '`Crv[i].MomCess.Pt[j].V` and `Crv[i].MomCess.Pt[j].Tms`.' "$document"
  grep -Fq 'For a valid occurrence, every listed template field is an observed fact with' "$document"
  grep -Fq '`Required=false`.' "$document"
  grep -Fq '`NPt` and `NCrvSet` accept zero and reject `0xffff` as unavailable.' "$document"
  grep -Fq 'makes the entire occurrence raw-only with zero typed facts.' "$document"
  grep -Fq 'A nested `V` has unit' "$document"
  grep -Fq '`VNomPct`; a nested `Tms` has unit `Secs`.' "$document"
  grep -Fq '`Ena`: `0=DISABLED`, `1=ENABLED`; `AdptCrvRslt`: `0=IN_PROGRESS`,' "$document"
  grep -Fq 'An otherwise valid' "$document"
  grep -Fq 'enum number remains its numeric observation with no substituted symbol.' "$document"
  grep -Fq 'A missing scale binding, unavailable scale, or invalid' "$document"
  grep -Fq 'but produces no scaled value.' "$document"
  grep -Fq 'possibly fragmented raw source spans for that range.' "$document"
  grep -Fq 'Malformed geometry produces zero typed facts and preserves the complete' "$document"
  if grep -Ein "$contradiction" "$document"; then
    echo 'SunSpec Model 707 typed-fact projection contract exceeds its docs-only boundary' >&2
    return 1
  fi
}

check_sunspec_dynamic_structural_selection_v2() {
  local document="$1"
  local contradiction='candidate creates a decoder key|candidate is admitted|candidate emits a typed fact|candidate causes a new request|candidate terminates a chain|Model 708[^.]*candidate|Model 709[^.]*candidate'

  check_public_protocol "$document"
  for heading in \
    'Scope and classification' \
    'Post-payload candidate rule' \
    'Failure and raw retention' \
    'Acquisition and terminal boundary' \
    'Isolation and no activation'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq 'A `structural_candidate` is a' "$document"
  grep -Fq 'post-payload observation state.' "$document"
  grep -Fq 'It is not `admitted`, has no decoder key,' "$document"
  grep -Fq 'A `structural_candidate` is considered only after the complete occurrence' "$document"
  grep -Fq 'It must never be selected' "$document"
  grep -Fq '`P` from occurrence-word offset 5 and `C` from occurrence-word offset 6;' "$document"
  grep -Fq '`P` and `C` each in the inclusive range 0 through 65534, excluding' "$document"
  grep -Fq 'checked `L = 7 + C*(4 + 9*P)`' "$document"
  grep -Fq 'The candidate rule does not enumerate Model' "$document"
  grep -Fq 'and does not create decoder keys for those lengths.' "$document"
  grep -Fq 'The complete occurrence remains raw-only with its' "$document"
  grep -Fq 'A `structural_candidate` does not cause a' "$document"
  grep -Fq 'A candidate does not terminate a chain.' "$document"
  grep -Fq 'V1 selection, keys, raw outputs, and behavior remain unchanged.' "$document"
  grep -Fq 'Models 708 and' "$document"
  grep -Fq '709 remain outside this contract' "$document"
  grep -Fq 'do not become candidates through Model' "$document"
  grep -Fq 'This contract creates no operation, write, send authority,' "$document"
  if grep -Ein "$contradiction" "$document"; then
    echo 'SunSpec dynamic structural selection contract exceeds its docs-only boundary' >&2
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
  grep -Fq 'Only the typed extension words listed below are decoded.' "$document"
  grep -Fq '## Typed read-only fields' "$document"
  grep -Fq 'The typed subset is limited to the fields listed below.' "$document"
  grep -Fq 'Company and generation occupy the low and high bytes, respectively,' "$document"
  grep -Fq 'SOC is the low byte at `0x0015` and must be in the inclusive range 0 through' "$document"
  grep -Fq "Current at \`0x0017\` is signed two's-complement and uses 10 mA units." "$document"
  grep -Fq 'Only `0x0100`, `0x0101`, `0x0102`, `0x0104`, `0x0105`, and `0x0106` have typed' "$document"
  grep -Fq '`0x0103`, `0x0107`' "$document"
  grep -Fq 'through `0x010B`, and both `0x010D` slice words remain opaque.' "$document"
  grep -Fq 'Offsets 0x0009 through 0x000C contain barcode material and are not read' "$document"
  grep -Fq 'FC10 Preset Multiple Registers, address allocation' "$document"
  grep -Fq 'every field marked' "$document"
  grep -Fq 'W or WR require an exact operation contract that names function, address,' "$document"
  grep -Fq 'A bounded decoder is permitted only for an externally declared' "$document"
  grep -Fqx '## MCP native observation projection' "$document"
  grep -Fq 'For a qualified observation, an MCP status result must return the selected' "$document"
  grep -Fq 'observation. It must preserve every retained word at its native offset, in the' "$document"
  grep -Fq 'No bounded decoder creates catalog registration, executable detection,' "$document"
  grep -Fq 'synthetic identity assembled from the document is not a substitute for a' "$document"
  grep -Fq 'does not automatically apply the contract to any commercial battery' "$document"
  grep -Fq 'revision-declared tuple remains required.' "$document"
  grep -Fq 'An observation that also satisfies Growatt Protocol II, SunSpec/Fronius, or a' "$document"
  grep -Fq 'automatic runtime admission, telemetry publication, or a support claim.' "$document"
  grep -Fq 'is ambiguous and produces no match.' "$document"
  grep -Fq 'produces `insufficient_evidence`, no send, and no partial' "$document"
}

check_growatt_protocol_ii_identity_projection() {
  local document="$1"

  check_public_protocol "$document"
  grep -Fqx '## Identity tuple' "$document"
  grep -Fqx '## Native identity capability' "$document"
  grep -Fqx '## MCP native identity projection' "$document"
  grep -Fq 'offsets 23 through 27, five words, for native serial text;' "$document"
  grep -Fq 'A qualified runtime identity contains the selected family, unicast unit,' "$document"
  grep -Fq 'model-build pair, Modbus protocol version, and the five exact FC03 identity' "$document"
  grep -Fq 'The runtime API may carry its configured endpoint and transport context with' "$document"
  grep -Fq 'this native observation. Public documentation and fixtures use synthetic' "$document"
  grep -Fq 'identity values and do not publish installation-specific identifiers, captures,' "$document"
  grep -Fq '`native_identity` without a redaction marker or a substitute digest.' "$document"
  grep -Fq 'identity projection. The identity projection does not authorize an FC06, FC16,' "$document"
  grep -Fq 'The currently enumerated operation is FC03 identity acquisition. This contract' "$document"
  grep -Fq 'does not define an FC06 or FC16 control operation, so no control command is' "$document"
  grep -Fq 'partial publication. This version enumerates no control operation.' "$document"
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

check_outback_axs_contract() {
  local document="$1"

  check_public_protocol "$document"
  for heading in 'Scope' 'Chain selection' 'Observed state' 'Excluded fields and operations' 'Failure and ambiguity'; do
    grep -Fqx "## $heading" "$document"
  done
  grep -Fq 'vendor Model 64110 with declared length 282' "$document"
  grep -Fq 'OutBack charge-controller Model 64111 with declared' "$document"
  grep -Fq 'length 23.' "$document"
  grep -Fq 'Its values remain vendor-scoped observed state under this contract.' "$document"
  grep -Fq 'does not convert an OutBack device into a generic inverter profile.' "$document"
  grep -Fq 'All other Model 64110 words, all unknown models, and every wrong-length model' "$document"
  grep -Fq 'An implementation may expose the complete caller-supplied Model 64110 raw word' "$document"
  grep -Fq 'block and its exact source spans as native observation data.' "$document"
  grep -Fq 'preserves its supplied order and must not acquire typed field labels, a profile' "$document"
  grep -Fq 'Configuration-like, network, address, hardware-address, credential, password,' "$document"
  grep -Fq 'mail, time, logging-control, and other untyped raw words remain native' "$document"
  grep -Fq 'observation data when supplied; they do not become typed facts or an operation' "$document"
  grep -Fq 'Every write or control operation remains `NO_SEND` until an operation-specific' "$document"
  grep -Fq 'function in this contract writes a register' "$document"
  grep -Fq 'does not identify a network endpoint, unit identifier, installation,' "$document"
  if grep -Ein 'write method is enabled|automatic acquisition is enabled|runtime activation is enabled|converts an OutBack device into a generic inverter profile|control capability is derived|raw word block is excluded from output' "$document"; then
    echo 'OutBack AXS protocol specification exceeds the read-only boundary' >&2
    return 1
  fi
}

if [[ $# -gt 0 ]]; then
  if [[ $# -ne 2 ]] && [[ "$1" != '--check-tesla-generation-contracts' || $# -ne 3 ]]; then
    echo 'usage: check_docs.sh [--check-sdongle-admission|--check-public-protocol|--check-tesla-tedapi-contract|--check-tesla-generation-contracts|--check-private-function-contract|--check-sunspec-v1-model-families-contract|--check-sunspec-nested-layout-contract|--check-sunspec-der-trip-lv-template-v2|--check-sunspec-der-trip-lv-typed-fact-projection-v2|--check-sunspec-dynamic-structural-selection-v2|--check-sunspec-v2-contract|--check-sunspec-v2-licensing|--check-x2-publication|--check-x2-contract|--check-bms-contract|--check-growatt-protocol-ii-identity-projection|--check-wit-matrix-contract document]' >&2
    exit 2
  fi
  case "$1" in
    --check-sdongle-admission) check_sdongle_admission "$2" ;;
    --check-public-protocol) check_public_protocol "$2" ;;
    --check-tesla-tedapi-contract) check_tesla_tedapi_contract "$2" ;;
    --check-tesla-generation-contracts)
      if [[ $# -ne 3 ]]; then
        exit 2
      fi
      check_tesla_generation_contracts "$2" "$3"
      ;;
    --check-private-function-contract) check_private_function_contract "$2" ;;
    --check-sunspec-v1-model-families-contract) check_sunspec_v1_model_families_contract "$2" ;;
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
    --check-wit-matrix-contract) check_wit_matrix_contract "$2" ;;
    --check-outback-axs-contract) check_outback_axs_contract "$2" ;;
    *)
    echo 'usage: check_docs.sh [--check-sdongle-admission|--check-public-protocol|--check-tesla-tedapi-contract|--check-private-function-contract|--check-sunspec-v1-model-families-contract|--check-sunspec-nested-layout-contract|--check-sunspec-der-trip-lv-template-v2|--check-sunspec-der-trip-lv-typed-fact-projection-v2|--check-sunspec-dynamic-structural-selection-v2|--check-sunspec-v2-contract|--check-sunspec-v2-licensing|--check-x2-publication|--check-x2-contract|--check-bms-contract|--check-growatt-protocol-ii-identity-projection|--check-wit-matrix-contract document]' >&2
      exit 2
      ;;
  esac
  exit $?
fi

spec='protocols/tesla/tedapi.md'
test -f "$spec"
tesla_legacy_spec='protocols/tesla/legacy-wall-connector-rs485.md'
tesla_gen3_spec='protocols/tesla/gen3-hsc-rtu.md'
test -f "$tesla_legacy_spec"
test -f "$tesla_gen3_spec"
nested_layout_spec='protocols/sunspec/nested-layout-contract-v1.md'
test -f "$nested_layout_spec"
der_trip_lv_template_spec='protocols/sunspec/der-trip-lv-template-v2.md'
test -f "$der_trip_lv_template_spec"
der_trip_lv_projection_spec='protocols/sunspec/der-trip-lv-typed-fact-projection-v2.md'
test -f "$der_trip_lv_projection_spec"
dynamic_structural_selection_spec='protocols/sunspec/dynamic-structural-selection-v2.md'
test -f "$dynamic_structural_selection_spec"
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
  'protocols/huawei/gateway-readonly-v1.md'
  'protocols/growatt/protocol-ii-readonly-v1.md'
  'protocols/growatt/shinewilan-x2-bridge-v1.md'
  'protocols/growatt/bms-rs485-1xsxxp-v202.md'
  'protocols/growatt/wit-family-protocol-matrix-v1.md'
  'protocols/outback/axs-port-sunspec-readonly-v1.md'
)
for multivendor_spec in "${multivendor_specs[@]}"; do
  test -f "$multivendor_spec"
done

check_tesla_tedapi_contract "$spec"
check_tesla_generation_contracts "$tesla_legacy_spec" "$tesla_gen3_spec"
check_tesla_evse_scope "$spec"

check_private_function_contract "$private_spec"

grep -Fqx '## Publication boundary' 'protocols/applicability-and-licensing.md'
grep -Fqx '## Admission rules' 'protocols/applicability-and-licensing.md'
grep -Fqx '## Initial model catalog' 'protocols/sunspec/read-only-core-v1.md'
check_sunspec_v1_model_families_contract 'protocols/sunspec/read-only-core-v1-model-families.md'
check_sunspec_v2_contract 'protocols/sunspec/read-only-core-v2.md'
check_sunspec_nested_layout_contract "$nested_layout_spec"
check_sunspec_der_trip_lv_template_v2 "$der_trip_lv_template_spec"
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
check_growatt_protocol_ii_identity_projection 'protocols/growatt/protocol-ii-readonly-v1.md'
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
grep -Fq 'Runtime observations retain the selected unit, transport context, and exact' 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
grep -Fq 'Public fixtures use synthetic values and do not publish installation data.' 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
grep -Fqx '## Decoder and runtime boundary' 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
check_bms_contract 'protocols/growatt/bms-rs485-1xsxxp-v202.md'
check_wit_matrix_contract 'protocols/growatt/wit-family-protocol-matrix-v1.md'
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
  check_public_protocol "$multivendor_spec"
done
