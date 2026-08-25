#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
fixture_root=$(mktemp -d)
trap 'rm -rf "$fixture_root"' EXIT

source_document="$repo_root/architecture/sdongle-qualification-disposition-v1.md"
fixture_document="$fixture_root/admission.md"
x2_document="$repo_root/protocols/growatt/shinewilan-x2-bridge-v1.md"
x2_fixture="$fixture_root/shinewilan-x2.md"
bms_document="$repo_root/protocols/growatt/bms-rs485-1xsxxp-v202.md"
bms_fixture="$fixture_root/bms-rs485.md"
wit_document="$repo_root/protocols/growatt/wit-family-protocol-matrix-v1.md"
wit_fixture="$fixture_root/wit-family-matrix.md"
sunspec_v2_document="$repo_root/protocols/sunspec/read-only-core-v2.md"
sunspec_v2_fixture="$fixture_root/sunspec-read-only-core-v2.md"
sunspec_v2_licensing_document="$repo_root/protocols/applicability-and-licensing.md"
sunspec_v2_licensing_fixture="$fixture_root/sunspec-v2-licensing.md"
sunspec_v1_families_document="$repo_root/protocols/sunspec/read-only-core-v1-model-families.md"
sunspec_v1_families_fixture="$fixture_root/sunspec-read-only-core-v1-model-families.md"
private_function_document="$repo_root/protocols/modbus/private-function-codes.md"
private_function_fixture="$fixture_root/private-function-codes.md"

cp "$source_document" "$fixture_document"
"$repo_root/scripts/check_docs.sh" --check-sdongle-admission "$fixture_document"
grep -Fq 'Each retry began after at least five seconds of idle time.' "$source_document"

"$repo_root/scripts/check_docs.sh" --check-private-function-contract "$private_function_document"
for mutation in \
  's/FC100, FC101, and FC102 may be reused/FC100, FC101, and FC102 are globally reserved/' \
  's/FC0x41 is profile-qualified and is not globally reserved/FC0x41 is globally reserved/' \
  's/FC23 is a standard Modbus function code, not a private-function operation/FC23 is a private-function operation/' \
  's/requires a separately admitted standard-function operation and a typed standard-function codec/requires only a private-function request/' \
  's/A function-code byte never identifies a vendor, vendor profile, or operation/A function-code byte identifies the vendor profile/'; do
  sed "$mutation" "$private_function_document" > "$private_function_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-private-function-contract "$private_function_fixture"; then
    echo "private-function boundary mutation was accepted: $mutation" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-sunspec-v1-model-families-contract "$sunspec_v1_families_document"
for mutation in \
  's/29 exact decoder tuples/30 exact decoder tuples/' \
  's/length 65 is a compatibility tuple/length 65 is a current product tuple/' \
  's/Models 101, 102, and 103/Models 101, 102, and 104/' \
  's/Models 111, 112, and 113 use IEEE FLOAT values/Models 111, 112, and 113 use integer values/' \
  's/Models 123 and 124 are observed state only/Models 123 and 124 are writable operations/' \
  's/identifiers or lengths remain opaque blocks/identifiers or lengths are decoded best-effort/' \
  's/does not create a product, profile, or support/creates a product, profile, and support/'; do
  sed "$mutation" "$sunspec_v1_families_document" > "$sunspec_v1_families_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-v1-model-families-contract "$sunspec_v1_families_fixture"; then
    echo "SunSpec V1 model-families mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for contradiction in \
  'sunspec.models.candidate.v2' \
  'Model 123 creates write authority.'; do
  cp "$sunspec_v1_families_document" "$sunspec_v1_families_fixture"
  printf '\n%s\n' "$contradiction" >> "$sunspec_v1_families_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-v1-model-families-contract "$sunspec_v1_families_fixture"; then
    echo "SunSpec V1 model-families contradiction was accepted: $contradiction" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-sunspec-v2-contract "$sunspec_v2_document"
"$repo_root/scripts/check_docs.sh" --check-sunspec-v2-licensing "$sunspec_v2_licensing_document"
for mutation in \
  's/| 701 | 153 |/| 701 | 152 |/' \
  's/| 703 | 17 |/| 703 | 18 |/' \
	's/| 715 | 7 |/| 715 | 8 |/' \
	's/| 802 | 62 |/| 802 | 61 |/' \
	's/| 803 | `26 + 32\*NStr` |/| 803 | `26 + 31*NStr` |/' \
	's/| 804 | `46 + 16\*NMod` |/| 804 | `46 + 15*NMod` |/' \
	's/| 805 | 42 |/| 805 | 41 |/' \
	's/18 + 25\*NPrt/18 + 24*NPrt/g' \
  's/Models 703 and 715 are control-observability only/Models 703 and 715 create operations/' \
  's/Models 704 through 712 remain outside this V2 wave and remain opaque/Models 704 through 712 are decoded/' \
	's/Every Model 802 field is observed state only and is `NO_SEND`/Model 802 fields permit sends/' \
	's/Model 801 remains excluded as deprecated/Model 801 is admitted/' \
	's/Models 806 through 809 remain excluded pending separate family and substructure decisions/Models 806 through 809 are admitted/' \
	's/offset 0\. It is bounded/offset 1. It is bounded/' \
	's/bounded from 0 through 2047/bounded from 0 through 2048/' \
	's/Model 803 does not infer Model 804 child occurrences/Model 803 infers Model 804 child occurrences/' \
	's/offset 1\. It is bounded/offset 0. It is bounded/' \
	's/bounded from 0 through 4093/bounded from 0 through 4094/' \
	's/isolated synthetic offline occurrence/terminal-qualified live chain/' \
	's/fragmented bounded source spans/one unbounded source span/' \
	's/Model 804 does not infer a Model 803 parent/Model 804 infers a Model 803 parent/' \
	's/Neither establishes any inferred relationship to Model 803 or Model 804/Model 805 establishes an inferred relationship/' \
	's/Every Model 805 field is observed state only and is `NO_SEND`/Model 805 fields permit sends/' \
	's/zero decoded facts/decoded best-effort facts/' \
  's/0 through 2620/0 through 2621/' \
  's/zero is a valid value/zero means not implemented/' \
  's/truncate, or round/round to a float/' \
  's/are data and are not trimmed/are padding and are trimmed/' \
  's/V1 outputs remain unchanged/V1 outputs are revised/' \
  's/catalog registration, vendor admission/catalog admission, vendor admission/' \
  's/raw-only opaque block/decoded best-effort/' \
  's/all-zero string extent is unavailable/all-zero string extent is empty/'; do
  sed "$mutation" "$sunspec_v2_document" > "$sunspec_v2_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-v2-contract "$sunspec_v2_fixture"; then
    echo "SunSpec V2 mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for mutation in \
  's/sunspec\.der\.readonly\.v2/sunspec.der.readonly.v2-candidate/' \
  's/Common 1\/66 plus Models 701\/153/Common 1\/65 plus Models 701\/153/' \
	's/703\/17/703\/18/' \
	's/802\/62/802\/61/' \
	's/803 variable geometry/803 fixed geometry/' \
	's/804 variable geometry/804 fixed geometry/' \
  's/offline decoder contract; runtime, vendor, and catalog admission default denied/runtime catalog approved/' \
  's/90b4a331dcca1d6eac69c1bead952fddcc5852e0/0000000000000000000000000000000000000000/'; do
  sed "$mutation" "$sunspec_v2_licensing_document" > "$sunspec_v2_licensing_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-v2-licensing "$sunspec_v2_licensing_fixture"; then
    echo "SunSpec V2 licensing mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for contradiction in \
  'sunspec.models.candidate.v2' \
  'Common 1/65 is accepted by the V2 decoder.' \
  'V2 runtime catalog registration is enabled.' \
  'V2 automatic acquisition is enabled.'; do
  cp "$sunspec_v2_document" "$sunspec_v2_fixture"
  printf '\n%s\n' "$contradiction" >> "$sunspec_v2_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-v2-contract "$sunspec_v2_fixture"; then
    echo "SunSpec V2 contradiction was accepted: $contradiction" >&2
    exit 1
  fi
done

for leak in \
  'gateway.example.internal:1502' \
  'a:1502' \
  'gateway.internal:modbus' \
  'port 1502' \
  '192.0.2.1' \
  'TCP reachability was established' \
  '0123456789abcdef0123456789abcdef01234567' \
  '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'; do
  cp "$source_document" "$fixture_document"
  printf '\n%s\n' "$leak" >> "$fixture_document"
  if "$repo_root/scripts/check_docs.sh" --check-sdongle-admission "$fixture_document"; then
    echo "admission leak was accepted: $leak" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-wit-matrix-contract "$wit_document"
grep -Fq '| `WIT 50-100K-HU-US` | US branch; product context not established | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' "$wit_document"
grep -Fq '| `WIT 50-100K-AU-US` | US branch; product context not established | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |' "$wit_document"

for mutation in \
  '/WIT 4-25K-HU/s/`UNKNOWN`/`V2.01`/' \
  '/WIT 50-100K-AU/s/`INSUFFICIENT_EVIDENCE`/`PROFILE_ADMITTED`/' \
  's/WIT 4-25K-HU/WIT 4-25K-HU2/' \
  's/WIT 50-100K-AU/WIT 50-100K-HU\/AU/' \
  's/DTC `5601`/DTC `5602`/' \
  's/the only WIT tuple/one WIT tuple/' \
  's/does not admit `WIT 50-100K-HU`/also admits `WIT 50-100K-HU`/' \
  's/no qualified firmware gate/a qualified firmware gate/' \
  's/does not apply to a WIT row/applies to a WIT row/' \
  's/Every VPP read, control, and write remains `NO_SEND`/VPP reads and controls are permitted/' \
  's/No decoder, fixture, catalog registration/Decoder, fixture, and catalog registration/' \
  's/produces `INSUFFICIENT_EVIDENCE`, no match, and no send/chooses the first matching profile/'; do
  sed "$mutation" "$wit_document" > "$wit_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-wit-matrix-contract "$wit_fixture"; then
    echo "WIT matrix mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for contradiction in \
  'VPP reads are permitted.' \
  'Growatt Protocol II applies to a WIT family.' \
  '`WIT 4-25K-HU` firmware version is `1.2.3`.'; do
  cp "$wit_document" "$wit_fixture"
  printf '\n%s\n' "$contradiction" >> "$wit_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-wit-matrix-contract "$wit_fixture"; then
    echo "WIT contract contradiction was accepted: $contradiction" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-bms-contract "$bms_document"

for mutation in \
  's/1xSxxP ESS/any Growatt battery/' \
  's/Rev2\.01/Rev2.xx/' \
  's/V2\.0/V2.1/' \
  's/revision `2\.02`/revision `2.03`/' \
  's/Unit 0 is broadcast and is always `NO_SEND`/Unit 0 is unicast and is always permitted/' \
  's/function is FC03/function is FC10/' \
  's/offset 0x0001, quantity 7/offset 0x0001, quantity 9/' \
  's/offset 0x000D, quantity 29/offset 0x000D, quantity 30/' \
  's/offset 0x0100, quantity 12/offset 0x0100, quantity 13/' \
  's/offset 0x010D, quantity 2/offset 0x010D, quantity 3/' \
  's/extension slices remain opaque words/extension slices are decoded telemetry/' \
  's/are not read/are read when needed/' \
  's/FC10 Preset Multiple Registers/FC10 Read Multiple Registers/' \
  's/W or WR are unconditional `NO_SEND`/W or WR require operator approval/' \
  's/Registry implementation is `NO_GO`/Registry implementation is `GO`/' \
  's/A synthetic identity assembled from the document is not a substitute/A synthetic identity assembled from the document is sufficient/'; do
  sed "$mutation" "$bms_document" > "$bms_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-bms-contract "$bms_fixture"; then
    echo "BMS contract mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for mutation in \
  's/does not automatically apply the contract/automatically applies the contract/' \
  's/are forbidden identity inputs/are permitted identity inputs/' \
  's/negative-overlap records/optional overlap records/' \
  's/Without that fixture/Without that document/' \
  's/is ambiguous and produces no match/is ranked and selects the first match/' \
  's/no partial/partial/'; do
  sed "$mutation" "$bms_document" > "$bms_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-bms-contract "$bms_fixture"; then
    echo "BMS admission mutation was accepted: $mutation" >&2
    exit 1
  fi
done

awk '
  /^The two extension slices remain/ {
    print "- offset 0x0200, quantity 1, for an unqualified extra slice;"
  }
  { print }
' "$bms_document" > "$bms_fixture"
if "$repo_root/scripts/check_docs.sh" --check-bms-contract "$bms_fixture"; then
  echo 'BMS additive FC03 slice was accepted' >&2
  exit 1
fi

for leak in \
  'gateway.example.internal:1502' \
  '192.0.2.1' \
  'port 1502' \
  '0123456789abcdef0123456789abcdef01234567' \
  '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'; do
  cp "$bms_document" "$bms_fixture"
  printf '\n%s\n' "$leak" >> "$bms_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-bms-contract "$bms_fixture"; then
    echo "BMS private material was accepted: $leak" >&2
    exit 1
  fi
done

cp "$x2_document" "$x2_fixture"
"$repo_root/scripts/check_docs.sh" --check-x2-publication "$x2_fixture"

for leak in \
  'https://example.invalid/vendor-manual' \
  '/Users/example/private-capture' \
  'sha256-deadbeef01234567' \
  'gateway.example.internal:1502' \
  '192.0.2.1' \
  'port 1502' \
  '0123456789abcdef0123456789abcdef01234567' \
  '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'; do
  cp "$x2_document" "$x2_fixture"
  printf '\n%s\n' "$leak" >> "$x2_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-x2-publication "$x2_fixture"; then
    echo "X2 protocol leak was accepted: $leak" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-x2-contract "$x2_document"

for mutation in \
  's/downstream Modbus RTU unit address/downstream default Modbus RTU unit address/' \
  's/Protocol Identifier must be 0x0000/Protocol Identifier may be nonzero/' \
  's/Length must equal one/Length may differ by one/' \
  's/Unit Identifiers 1 through 247/Unit Identifiers 1 through 246/' \
  's/Unit Identifier 0 is RTU broadcast/Unit Identifier 0 is downstream unicast/' \
  's/scan unit addresses/scan a bounded unit range/' \
  's/without changing its function code/after changing its function code/' \
  's/or payload\./or transformed payload./' \
  's/FC03 holding-register reads/FC06 holding-register writes/' \
  's/FC04 input-register reads/FC06 holding-register writes/' \
  's/no semantic registry profile of its own/a semantic registry profile of its own/'; do
  sed "$mutation" "$x2_document" > "$x2_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-x2-contract "$x2_fixture"; then
    echo "X2 contract mutation was accepted: $mutation" >&2
    exit 1
  fi
done
