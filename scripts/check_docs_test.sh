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
nested_layout_document="$repo_root/protocols/sunspec/nested-layout-contract-v1.md"
nested_layout_fixture="$fixture_root/sunspec-nested-layout-contract-v1.md"
der_trip_lv_template_document="$repo_root/protocols/sunspec/der-trip-lv-template-v2.md"
der_trip_lv_template_fixture="$fixture_root/sunspec-der-trip-lv-template-v2.md"
der_trip_lv_projection_document="$repo_root/protocols/sunspec/der-trip-lv-typed-fact-projection-v2.md"
der_trip_lv_projection_fixture="$fixture_root/sunspec-der-trip-lv-typed-fact-projection-v2.md"
dynamic_structural_selection_document="$repo_root/protocols/sunspec/dynamic-structural-selection-v2.md"
dynamic_structural_selection_fixture="$fixture_root/sunspec-dynamic-structural-selection-v2.md"
private_function_document="$repo_root/protocols/modbus/private-function-codes.md"
private_function_fixture="$fixture_root/private-function-codes.md"

cp "$source_document" "$fixture_document"
"$repo_root/scripts/check_docs.sh" --check-sdongle-admission "$fixture_document"
grep -Fq 'Each retry began after at least five seconds of idle time.' "$source_document"

tesla_document="$repo_root/protocols/tesla/tedapi.md"
tesla_fixture="$fixture_root/tesla-tedapi.md"
"$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_document"
for mutation in \
  's/payload exactly, together with its function, compatibility version, and/payload only as a digest, without its function or compatibility version,/' \
  's/digest-only format does not limit the native HSC record projection/digest-only format replaces the native HSC record projection/' \
  's/Fixtures and documentation examples use synthetic values/Fixtures and documentation examples may use operator captures/' \
  's/It does not infer a configuration value or control action/It infers a configuration value and control action/'; do
  sed "$mutation" "$tesla_document" > "$tesla_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
    echo "Tesla native-record boundary mutation was accepted: $mutation" >&2
    exit 1
  fi
done
for mutation in \
  's/1 through 536870911/1 through 536870912/' \
  's/wire type is 0 through 5/wire type is 0 through 6/' \
  's/Invalid, truncated, overflowed, or out-of-range keys are rejected/Invalid keys are retained/' \
  's/at most 64 entries/at most 65 entries/' \
  's/total FC100 envelope length/total FC100 envelope bytes and values/' \
  's/Values are consumed only to validate wire boundaries and/Values are retained while validating wire boundaries and/' \
  's/group boundaries with the same field number/group boundaries without matching field numbers/' \
  's/oversized, unpaired, or over-count summary is rejected/oversized summaries are retained/' \
  's/only from an injected, locally/without an injected provider/' \
  's/qualification (`framing_only` or/qualification (`unbounded` or/' \
  's/`qualified_read_only`), total envelope length/`qualified_read_only`), total envelope bytes and values/' \
  's/count, ordered numeric field-number and wire-type entries, and payload digest/count and field names/' \
  's/`outbound_allowed` value is always `false`/`outbound_allowed` value may be `true`/' \
  's/an unavailable result with no summary data/a successful summary result/' \
  's/exposes raw bytes, values, field names/exposes raw bytes and values/' \
  's/a qualified operation/an unqualified operation/' \
  's/`wc3_24_44_3` operation version/any operation version/' \
  's/missing replay-safe declaration, or unknown response shape must cause no send/missing replay-safe declaration may send/' \
  's/exactly `04 32 02 0a 00`/any FC100 PDU/' \
  's/is an FC100 intermediate/is a successful terminal/' \
  's/tag-`2` body is a bounded opaque terminal body/contains a required inner member/' \
  's/This version defines no member,/This version defines a member,/' \
  's/zero, an empty repeated value, or an empty nested member./zero is always available./' \
  's/does not claim that the responder has no/claims that the responder has no/' \
  's/only by an injected provider/through an unqualified generic provider/' \
  's/`wc3_24_44_3`\. It exposes only the operation/any operation version. It exposes only the operation/' \
  's/always `false`/may be `true`/' \
  's/produces no data/produces successful data/' \
  's/The compact view never creates a request/The compact view creates a request/' \
  's/falls back to FC101 or FC102/falls back to FC100/' \
  's/This version defines a qualified operation/This version defines no qualified operation/' \
  's/terminal body. This version defines no member/terminal body. This version defines an inner member/' \
  's/unknown response shape must cause no send/unknown response shape may send/' \
  's/An echoed PDU exactly equal to this request PDU is an FC100 intermediate/An echoed PDU exactly equal to this request PDU is a terminal result/' \
  's/field-presence contract within that body/field-presence contract is defined within that body/'; do
  sed "$mutation" "$tesla_document" > "$tesla_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
    echo "Tesla replay metadata mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for mutation in \
  's/qualified Common system-information operation/unqualified Common system-information operation/' \
  's/`tesla.hsc.fc100.common_system_info.v1`/`tesla.hsc.fc100.any_common_operation.v1`/' \
  's/exactly `04 22 02 12 00`/any FC100 PDU/' \
  's/tag-`3` body is a bounded opaque terminal body/contains a required inner member/' \
  's/unknown response shape must cause no send/unknown response shape may send/'; do
  sed "$mutation" "$tesla_document" > "$tesla_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
    echo "Tesla common system-information mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for mutation in \
  's/qualified WC lifetime operation/unqualified WC lifetime operation/' \
  's/`tesla.hsc.fc100.wc_lifetime.v1`/`tesla.hsc.fc100.any_wc_operation.v1`/' \
  's/exactly `04 32 02 1a 00`/any FC100 PDU/' \
  's/may occur no more than once/may occur without bound/' \
  's/must be quarantined and fail this operation/may remain in flight/' \
  's/WC family `6` and one response tag `4`/WC family `4` and one response tag `4`/' \
  's/tag-`4` body is a bounded opaque terminal body/contains a required inner member/' \
  's/Common family `4` and error tag `1`/Common family `6` and error tag `4`/' \
  's/unknown response shape must cause no send/unknown response shape may send/'; do
  sed "$mutation" "$tesla_document" > "$tesla_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
    echo "Tesla WC lifetime mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for mutation in \
  's/qualified WC system-information operation/unqualified WC system-information operation/' \
  's/`tesla.hsc.fc100.wc_system_info.v1`/`tesla.hsc.fc100.any_wc_operation.v1`/' \
  's/exactly `04 32 02 4a 00`/any FC100 PDU/' \
  '/^### Qualified WC system-information operation$/,/^### Qualified Common system-information operation$/s/`wc3_24_44_3` operation version/any operation version/' \
  '/^### Qualified WC system-information operation$/,/^### Qualified Common system-information operation$/s/unknown response shape must cause no send/unknown response shape may send/' \
  '/^### Qualified WC system-information operation$/,/^### Qualified Common system-information operation$/s/may occur no more than once/may occur without bound/' \
  '/^### Qualified WC system-information operation$/,/^### Qualified Common system-information operation$/s/must be quarantined and fail this operation/may remain in flight/' \
  '/^### Qualified WC system-information operation$/,/^### Qualified Common system-information operation$/s/WC family `6` and one response tag `10`/WC family `6` and one response tag `9`/' \
  '/^### Qualified WC system-information operation$/,/^### Qualified Common system-information operation$/s/tag-`10` body is a bounded opaque terminal body/contains a required inner member/' \
  '/^### Qualified WC system-information operation$/,/^### Qualified Common system-information operation$/s/Common family `4` and error tag `1`/Common family `6` and error tag `10`/'; do
  sed "$mutation" "$tesla_document" > "$tesla_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
    echo "Tesla WC system-information mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for mutation in \
  's/qualified WC load-sharing-state operation/unqualified WC load-sharing-state operation/' \
  's/`tesla.hsc.fc100.wc_load_sharing_state.v1`/`tesla.hsc.fc100.any_wc_operation.v1`/' \
  's/exactly `04 32 02 5a 00`/any FC100 PDU/' \
  '/^### Qualified WC load-sharing-state operation$/,/^### Qualified WC system-information operation$/s/`wc3_24_44_3` operation version/any operation version/' \
  '/^### Qualified WC load-sharing-state operation$/,/^### Qualified WC system-information operation$/s/unknown response shape must cause no send/unknown response shape may send/' \
  '/^### Qualified WC load-sharing-state operation$/,/^### Qualified WC system-information operation$/s/may occur no more than once/may occur without bound/' \
  '/^### Qualified WC load-sharing-state operation$/,/^### Qualified WC system-information operation$/s/must be quarantined and fail this operation/may remain in flight/' \
  '/^### Qualified WC load-sharing-state operation$/,/^### Qualified WC system-information operation$/s/WC family `6` and one response tag `12`/WC family `6` and one response tag `11`/' \
  '/^### Qualified WC load-sharing-state operation$/,/^### Qualified WC system-information operation$/s/tag-`12` body is a bounded opaque terminal body/contains a required inner member/' \
  '/^### Qualified WC load-sharing-state operation$/,/^### Qualified WC system-information operation$/s/Common family `4` and error tag `1`/Common family `6` and error tag `12`/'; do
  sed "$mutation" "$tesla_document" > "$tesla_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
    echo "Tesla WC load-sharing-state mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for mutation in \
  's/qualified WC PPU settings operation/unqualified WC PPU settings operation/' \
  's/`tesla.hsc.fc100.wc_ppu_settings.v1`/`tesla.hsc.fc100.any_wc_operation.v1`/' \
  's/read-only configuration operation/mutating configuration operation/' \
  's/exactly `05 32 03 ba 01 00`/any FC100 PDU/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/`wc3_24_44_3` operation version/any operation version/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/unknown response shape must cause no send/unknown response shape may send/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/may occur no more than once/may occur without bound/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/must be quarantined and fail this operation/may remain in flight/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/exactly one WC family `6` member and exactly one response tag `24`, with no additional terminal member/one WC family `6` member and one response tag `23`/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/tag-`24` body is a bounded opaque terminal body/contains a required inner member/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/no field, identifier, configuration value, or field-presence contract within that body/a configuration value is projected from that body/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s|The native HSC record projection may retain this terminal body without creating|The native HSC record projection creates gateway automatic dispatch|' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/A real device exchange requires separate action-time laboratory confirmation/A real device exchange is automatically enabled/' \
  '/^### Qualified WC PPU settings operation$/,/^### Qualified WC system-information operation$/s/Common family `4` and error tag `1`/Common family `6` and error tag `24`/'; do
  sed "$mutation" "$tesla_document" > "$tesla_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
    echo "Tesla WC PPU settings mutation was accepted: $mutation" >&2
    exit 1
  fi
done

awk '
  /^### Qualified WC PPU settings operation$/ { in_ppu = 1 }
  /^### Qualified WC system-information operation$/ { in_ppu = 0 }
  { print }
  in_ppu && /A real device exchange requires separate action-time laboratory confirmation\./ {
    print "This operation exposes configuration values, enables a setter, may fall back to FC101 or FC102, and creates gateway automatic dispatch."
  }
' "$tesla_document" > "$tesla_fixture"
if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
  echo 'Tesla WC PPU settings additive scope expansion was accepted' >&2
  exit 1
fi

awk '
  /^### Qualified WC PPU settings operation$/ { in_ppu = 1 }
  /^### Qualified WC system-information operation$/ { in_ppu = 0 }
  { print }
  in_ppu && /A real device exchange requires separate action-time laboratory confirmation\./ {
    print "This operation may fall back to FC101 or FC102."
  }
' "$tesla_document" > "$tesla_fixture"
if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
  echo 'Tesla WC PPU settings fallback expansion was accepted' >&2
  exit 1
fi

awk '
  /^### Qualified WC PPU settings operation$/ { in_ppu = 1 }
  /^### Qualified WC system-information operation$/ { in_ppu = 0 }
  { print }
  in_ppu && /A real device exchange requires separate action-time laboratory confirmation\./ {
    print "An additional terminal member of response tag 25 is permitted."
    print "A second WC family 6 member is permitted."
  }
' "$tesla_document" > "$tesla_fixture"
if "$repo_root/scripts/check_docs.sh" --check-tesla-tedapi-contract "$tesla_fixture"; then
  echo 'Tesla WC PPU settings terminal-shape expansion was accepted' >&2
  exit 1
fi

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

for mutation in \
  's/It must not discover endpoints, select a vendor profile, infer a/It may discover endpoints, select a vendor profile, infer a/' \
  's/makes transport available; it does not make any vendor/makes transport available and makes every vendor/' \
  's/a raw external-operation bypass/a raw external-operation entry point/' \
  's/must quarantine and recover before it accepts a successor request/may continue before it accepts a successor request/' \
  's/classifying itself as a failed exchange/classifying itself as a normal operation/'; do
  sed "$mutation" "$private_function_document" > "$private_function_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-private-function-contract "$private_function_fixture"; then
    echo "configured serial boundary mutation was accepted: $mutation" >&2
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

"$repo_root/scripts/check_docs.sh" --check-sunspec-nested-layout-contract "$nested_layout_document"
for mutation in \
  's/only by the exact schema revision and model identifier/by model identifier and declared length/' \
  's/A declared length never selects a template and is never an expanded-layout cache key/A declared length selects the expanded-layout cache/' \
  's/after every documented count and its declared length validate together/from the declared length alone/' \
  's/must not infer counts/may infer counts/' \
  's/`Crv\[2\]\.MustTrip\.Pt\[5\]\.Hz` is a hierarchical path, not a flattened repeat index/`Crv[2].MustTrip.Pt[5].Hz` is a flattened repeat index/' \
  's/map each decoded point to exact source spans/map each decoded point to one synthetic span/' \
  's/Checked arithmetic applies before every extent, aggregate, fact-count, or/Unchecked arithmetic applies before every extent, aggregate, fact-count, or/' \
  's/Invalid geometry remains raw-only with zero typed facts/Invalid geometry emits partial typed facts/' \
  's/V1 templates, caches, and outputs remain isolated and unchanged/V1 templates and V2 caches are shared/' \
  's/Models 707, 708, and 709 are bounded examples only and do not define Model 710 or any other model/Models 707, 708, and 709 define Model 710/'; do
  sed "$mutation" "$nested_layout_document" > "$nested_layout_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-nested-layout-contract "$nested_layout_fixture"; then
    echo "SunSpec nested-layout mutation was accepted: $mutation" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-sunspec-der-trip-lv-template-v2 "$der_trip_lv_template_document"
for mutation in \
  's/occurrence-word offsets 5 and 6/occurrence-word offsets 4 and 5/' \
  's/L = 7 + C\*(4 + 9\*P)/L = 7 + C*(4 + 8*P)/' \
  's/L <= 65534/L <= 65535/' \
  's/Invalid geometry remains raw-only with zero typed facts/Invalid geometry emits partial typed facts/' \
  's/Every field is observed state only and is `NO_SEND`/Every field creates a write operation/' \
  's/Model 707/Model 708/' \
  's/does not create live acquisition or operational behavior/does not create live acquisition; 708 uses this template/'; do
  sed "$mutation" "$der_trip_lv_template_document" > "$der_trip_lv_template_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-der-trip-lv-template-v2 "$der_trip_lv_template_fixture"; then
    echo "SunSpec Model 707 template mutation was accepted: $mutation" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-sunspec-der-trip-lv-typed-fact-projection-v2 "$der_trip_lv_projection_document"
for mutation in \
  's/## Public offline projection API/## Public projection API/' \
  's/snapshot SunSpecChainSnapshot/decoded SunSpecDecodedChain/' \
  's/has no `DecoderKey()`, admission/has a `DecoderKey()`, admission/' \
  's/Only a complete V2 Model 707 `structural_candidate` may produce a projection/Every V2 model may produce a projection/' \
  's/must not accept or derive a projection/may accept or derive a projection/' \
  's/must not recompute structural state/recomputes structural state/' \
  's/produces no projection and zero facts/produces partial facts/' \
  's/does not modify an occurrence, chain snapshot, or qualification-observation JSON/modifies qualification-observation JSON/' \
  's/Repeated Model 707 occurrences produce independent projections/Repeated Model 707 occurrences share one projection/' \
  's/V1, Model 708, and Model 709 produce no projection/V1, Model 708, and Model 709 produce projections/' \
  's/does not change acquisition, queueing, retry, deadline, limit, or terminal behavior/changes retry behavior/' \
  's/sunspec\.der\.v2\.707\.Crv\.MustTrip\.Pt\.V/sunspec.der.v2.707.Crv.Pt.V/' \
  's/Crv\[i\]\.MayTrip\.Pt\[j\]\.V/Crv[i].MustTrip.Pt[j].V/' \
  's/`VNomPct`; a nested `Tms` has unit `Secs`/`V`; a nested `Tms` has unit `s`/' \
  's/`Required=false`/`Required=true`/' \
  's/accept zero and reject `0xffff` as unavailable/accept zero and accept `0xffff`/' \
  's/no substituted symbol/a default symbol/' \
  's/but produces no scaled value/and produces a scaled default/' \
  's/Malformed geometry produces zero typed facts/Malformed geometry produces partial typed facts/' \
  's/Every observation in this contract is `NO_SEND`/Every observation in this contract can send/'; do
  sed "$mutation" "$der_trip_lv_projection_document" > "$der_trip_lv_projection_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-der-trip-lv-typed-fact-projection-v2 "$der_trip_lv_projection_fixture"; then
    echo "SunSpec Model 707 typed-fact projection mutation was accepted: $mutation" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-sunspec-dynamic-structural-selection-v2 "$dynamic_structural_selection_document"
for mutation in \
  's/post-payload observation state/header observation state/' \
  's/It is not `admitted`, has no decoder key/It is `admitted` and has a decoder key/' \
  's/offset 5 and `C` from occurrence-word offset 6/offset 4 and `C` from occurrence-word offset 5/' \
  's/7 + C\*(4 + 9\*P)/7 + C*(4 + 8*P)/' \
  's/does not enumerate Model/uses a Model/' \
  's/complete occurrence remains raw-only/complete occurrence is admitted/' \
  's/A `structural_candidate` does not cause a/A `structural_candidate` causes a/' \
  's/does not terminate a chain/terminates a chain/' \
  's/V1 selection, keys, raw outputs, and behavior remain unchanged/V1 selection shares V2 behavior/' \
  's/do not become candidates/become candidates/' \
  's/This contract creates no operation, write, send authority/This contract creates write authority/'; do
  sed "$mutation" "$dynamic_structural_selection_document" > "$dynamic_structural_selection_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-sunspec-dynamic-structural-selection-v2 "$dynamic_structural_selection_fixture"; then
    echo "SunSpec dynamic structural selection mutation was accepted: $mutation" >&2
    exit 1
  fi
done

"$repo_root/scripts/check_docs.sh" --check-sunspec-v2-contract "$sunspec_v2_document"
"$repo_root/scripts/check_docs.sh" --check-sunspec-v2-licensing "$sunspec_v2_licensing_document"
for mutation in \
  's/| 701 | 153 |/| 701 | 152 |/' \
	's/| 703 | 17 |/| 703 | 18 |/' \
	's/| 707 | `7 + NCrvSet\*(4 + 9\*NPt)` |/| 707 | `8 + NCrvSet*(4 + 9*NPt)` |/' \
	's/| 708 | `7 + NCrvSet\*(4 + 9\*NPt)` |/| 708 | `8 + NCrvSet*(4 + 9*NPt)` |/' \
	's/| 709 | `7 + NCrvSet\*(4 + 12\*NPt)` |/| 709 | `8 + NCrvSet*(4 + 12*NPt)` |/' \
	's/| 715 | 7 |/| 715 | 8 |/' \
	's/| 802 | 62 |/| 802 | 61 |/' \
	's/| 803 | `26 + 32\*NStr` |/| 803 | `26 + 31*NStr` |/' \
	's/| 804 | `46 + 16\*NMod` |/| 804 | `46 + 15*NMod` |/' \
	's/| 805 | 42 |/| 805 | 41 |/' \
	's/| 806 | 1 |/| 806 | 2 |/' \
	's/| 807 | 34 |/| 807 | 33 |/' \
	's/| 808 | 1 |/| 808 | 2 |/' \
	's/| 809 | 1 |/| 809 | 2 |/' \
	's/18 + 25\*NPrt/18 + 24*NPrt/g' \
  's/Models 703 and 715 are control-observability only/Models 703 and 715 create operations/' \
	's/Models 704 through 706 and 710 through 712 remain outside this V2 wave and remain opaque/Models 704 through 712 are decoded/' \
	's/`L = 7 + C\*(4 + 9\*P)`/`L = 7 + C*(4 + 8*P)`/' \
	's/`L = 7 + C\*(4 + 12\*P)`/`L = 7 + C*(4 + 11*P)`/' \
	's/absolute model word 6/absolute model word 7/' \
	's/are each 0 through 65534; zero is valid/are each 0 through 65535; zero is invalid/' \
	's/`Crv\[i\]\.MomCess\.Pt\[j\]` are distinct nested paths/`Crv[i].MomCess.Pt[j]` is inferred from MustTrip/' \
	's/must not infer `P` or `C` from/may infer `P` or `C` from/' \
	's/`Crv\[i\]` is `7 + (i-1)\*(4 + 3\*S\*P)`/`Crv[i]` is inferred from trailing words/' \
	's/offsets `+1`, `+2 + S\*P`, and `+3 + 2\*S\*P`/offsets are implementation-defined/' \
	's/For Models 707 and 708, `S` is 3; for Model 709, `S` is 4/Every model uses `S` 3/' \
	's/Models 707, 708, and 709 are inventory-known raw-only quarantine blocks/Models 707, 708, and 709 emit typed facts/' \
	's/Every field in Models 707, 708, and 709, including `Ena`, `AdptCrvReq`,/Models 707, 708, and 709 permit sends, including `Ena`,/' \
	's/Model 707 has `V_SF` and `Tms_SF`/Model 707 has `Hz_SF` and `Tms_SF`/' \
	's/Model 708 has the same source-derived point spans as Model 707/Model 708 infers its point spans from Model 707/' \
	's/Model 709 has `Hz_SF` and `Tms_SF`/Model 709 has `V_SF` and `Tms_SF`/' \
	's/Every Model 802 field is observed state only and is `NO_SEND`/Model 802 fields permit sends/' \
	's/Model 801 remains excluded as deprecated/Model 801 is admitted/' \
	's/Models 806 through 809 remain separately bounded flow battery structural leaves/Models 806 through 809 are interchangeable/' \
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
	's/Model 806 has fixed data-register length 1 and no effective repeated group/Model 806 has a repeated group/' \
	's/`BatTBD` remains uninterpreted structural observed state/`BatTBD` is a semantic telemetry value/' \
	's/Model 806 does not infer a relationship to Models 803, 804, 805, or 807 through 809/Model 806 infers a relationship to Model 807/' \
	's/Every Model 806 field is observed state only and is `NO_SEND`/Model 806 fields permit sends/' \
	's/No Model 806 field creates a write method, send authority, operation admission,/Model 806 creates an operation admission,/' \
	's/Model 807 has fixed data-register length 34 and no effective repeated group/Model 807 has a repeated group/' \
	's/`Idx` and `NMod` remain observed structural fields only/`Idx` and `NMod` infer a hierarchy/' \
	's/Model 807 does not infer a relationship to Models 806, 808, or 809/Model 807 infers a relationship to Model 808/' \
	's/Every Model 807 field, including control-adjacent zero-count group names, is observed state only and is `NO_SEND`/Model 807 control-adjacent fields permit sends/' \
	's/No Model 807 field creates a write method, send authority, operation admission,/Model 807 creates an operation admission,/' \
	's/Model 808 has fixed data-register length 1 and no effective repeated group/Model 808 has a repeated group/' \
	's/`ModuleTBD` remains uninterpreted structural observed state/`ModuleTBD` is a semantic telemetry value/' \
	's/The declared stack group has count zero and is not materialized/The stack group is materialized/' \
	's/Model 808 does not infer a relationship to Models 803 through 807 or 809/Model 808 infers a relationship to Model 809/' \
	's/Every Model 808 field, including the zero-count `StackTBD` group name, is observed state only and is `NO_SEND`/Model 808 fields permit sends/' \
	's/No Model 808 field creates a write method, send authority, operation admission,/Model 808 creates an operation admission,/' \
	's/Model 809 has fixed data-register length 1 and no effective repeated group/Model 809 has a repeated group/' \
	's/`StackTBD` remains uninterpreted structural observed state/`StackTBD` is a semantic telemetry value/' \
	's/The declared cell group has count zero and is not materialized/The cell group is materialized/' \
	's/Model 809 does not infer a relationship to Models 803 through 808/Model 809 infers a relationship to Model 808/' \
	's/Every Model 809 field, including the zero-count `CellTBD` group name, is observed state only and is `NO_SEND`/Model 809 fields permit sends/' \
	's/No Model 809 field creates a write method, send authority, operation admission,/Model 809 creates an operation admission,/' \
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

protocol_ii_document="$repo_root/protocols/growatt/protocol-ii-readonly-v1.md"
protocol_ii_fixture="$(mktemp)"
for mutation in \
  's/offsets 23 through 27, five words/offsets 23 through 27, four words/' \
  's/## Native identity capability/## Sanitized identity projection/' \
  's/unicast unit,/an inferred unit,/' \
  's/model-build pair, Modbus protocol version, and the five exact FC03 identity/model-build pair, Modbus protocol version, and inferred data/' \
  's/does not define an FC06 or FC16 control operation/defines generic FC16 control/' \
  's/This version enumerates no control operation/This version enables generic control/' ; do
  sed "$mutation" "$protocol_ii_document" > "$protocol_ii_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-growatt-protocol-ii-identity-projection "$protocol_ii_fixture"; then
    echo "Growatt Protocol II projection mutation was accepted: $mutation" >&2
    exit 1
  fi
done
rm -f "$protocol_ii_fixture"

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
  's/Only the typed extension words listed below are decoded/Every extension word is decoded telemetry/' \
  's/are not read/are read when needed/' \
  's/FC10 Preset Multiple Registers/FC10 Read Multiple Registers/' \
  's/W or WR require an exact operation contract that names function, address,/W or WR require operator approval/' \
  's/A bounded decoder is permitted only/A bounded decoder is permitted without/' \
  's/No bounded decoder creates catalog registration/Bounded decoder creates catalog registration/' \
  's/synthetic identity assembled from the document is not a substitute/synthetic identity assembled from the document is sufficient/'; do
  sed "$mutation" "$bms_document" > "$bms_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-bms-contract "$bms_fixture"; then
    echo "BMS contract mutation was accepted: $mutation" >&2
    exit 1
  fi
done

for mutation in \
  's/does not automatically apply the contract/automatically applies the contract/' \
  's/revision-declared tuple remains required/revision-declared tuple is optional/' \
  's/is ambiguous and produces no match/is ranked and selects the first match/' \
  's/no partial/partial/'; do
  sed "$mutation" "$bms_document" > "$bms_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-bms-contract "$bms_fixture"; then
    echo "BMS admission mutation was accepted: $mutation" >&2
    exit 1
  fi
done

awk '
  /^Only the typed extension words listed below are decoded/ {
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

test -f "$repo_root/protocols/outback/axs-port-sunspec-readonly-v1.md"

outback_document="$repo_root/protocols/outback/axs-port-sunspec-readonly-v1.md"
outback_fixture="$fixture_root/outback-axs.md"
"$repo_root/scripts/check_docs.sh" --check-outback-axs-contract "$outback_document"

for mutation in \
  's/declared length 282/declared length 281/' \
  's/length 23\./length 24./' \
  's/vendor-scoped observed state/standard observed state/' \
  's/does not convert an OutBack device into a generic inverter profile./converts an OutBack device into a generic inverter profile./' \
  's/complete caller-supplied Model 64110 raw word/selected raw word/' \
  's/observation data when supplied; they do not become typed facts or an operation/observation data becomes typed facts and an operation/' \
  's/Every write or control operation remains `NO_SEND` until an operation-specific/Every write or control operation is enabled/' \
  's/function in this contract writes a register/function in this contract permits a register write/' \
  's/does not identify a network endpoint, unit identifier, installation,/identifies a network endpoint, unit identifier, installation,/'; do
  sed "$mutation" "$outback_document" > "$outback_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-outback-axs-contract "$outback_fixture"; then
    echo "OutBack AXS mutation was accepted: $mutation" >&2
    exit 1
  fi
done

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
