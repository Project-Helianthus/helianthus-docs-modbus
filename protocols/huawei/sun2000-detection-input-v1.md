# SUN2000 detector input and result evidence V1

## Status and native authority

This is a proposed, implementable offline interface, not an executable detector
or a successful device tuple. The current native
[SUN2000 disposition](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/inverter-battery-readonly-v1.md)
comes first: `NO_ADMISSIBLE_PROFILE`, no covered model family or firmware range,
no register map, no decoder, and no acquisition. Its decision rows remain
current; the field names, validation and detailed reasons below are proposed.
The historical V1 name conveys no stability before Helianthus 1.0.

The [evidence checklist](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/qualification-evidence-checklist.md)
separates Proven, Hypothesis and Unknown from admission and qualification.
The [qualification cards](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/qualification-readiness-v1.md)
keep gateway, inverter and battery evidence independent. This page adds no wire
addresses, read procedure, positive profile, supported model, or firmware rule.
The inspection-only vendor document has no pinned exact version here; its name
alone supplies no publishable map. K34 is evidence intake, not this interface.

## Input envelope and references

Notation uses JSON types. All objects are closed: unlisted fields are invalid.
All listed fields are required unless marked optional. Missing a required field
is malformed input; explicit absence uses the presence wrapper below. Empty
strings, duplicate identifiers and dangling references are invalid. Arrays are
ordered only for serialization; ordering never chooses a winner.

| Field | Type and rule |
| --- | --- |
| `contract` | String, exactly `sun2000-detection-input-v1` |
| `subject` | Nonempty opaque string identifying one caller-local endpoint/unit context, without coordinates or device identifiers |
| `evidence` | Array of reference records; empty allowed |
| `candidates` | Array of candidate records; empty allowed; unique `id` values |

A reference record has required strings `id`, `source`, `locator` and
`context`, plus `claim_level` in `Proven`, `Hypothesis`, `Unknown`.
`source` is one of `native_identity`, `gateway_inventory`, `map_document`,
`synthetic`. `locator` is a publishable document path and section label, or a
self-contained synthetic record label; it must resolve to retained evidence,
not a caller assertion. `context` identifies the evidence's subject or its
explicit documentary applicability scope. Native bytes/text, interpretation,
and document revision context are retained at that locator; normalization must
not replace the original evidence. Public records contain no private captures,
serials, coordinates, capture times or contributor identities. Production
references require separately controlled retention, not publication of private
material. A claim level describes only the referenced claim: even Proven does
not confer admission, acquisition, qualification or support.

Each candidate has required `id` (opaque string), `family`, `model`, `firmware`,
`unit`, and `map`. The last five fields are presence wrappers. All model tokens
in public examples below are synthetic placeholders, not published device models.

| Wrapper field | Type and rule |
| --- | --- |
| `state` | `missing`, `unavailable`, `present`, or `contradictory` |
| `value` | Typed value below when `present`; exactly null otherwise |
| `refs` | Unique reference ID array; empty only for `missing` |
| `alternatives` | Array of `{value, refs}` with typed values and nonempty unique reference IDs; at least two incompatible alternatives only when `contradictory`, otherwise empty |
| `detail` | Optional nonempty explanatory string; never supplies an identity discriminator |

`missing` means no evidence supplied; it requires empty `refs` and alternatives.
`unavailable` means evidence records an unavailable observation or read exception;
it requires references and does not mean absent hardware. `present` requires
nonempty references supporting that exact field value. `contradictory` retains
all conflicting alternatives and their references; wrapper `refs` must equal
the union of alternative references. No majority vote or most-recent rule
repairs a contradiction. Null never means wildcard, zero, empty identity or
permission to inherit another candidate's evidence.

| Field | Exact `present` value shape | Evidence/applicability rule |
| --- | --- | --- |
| `family` | String `SUN2000` | Exact native family claim for this subject; another Huawei family is a mismatch, not fallback |
| `model` | Nonempty exact string | Full native model token; no prefix, wildcard, alias, serial or writable name substitution |
| `firmware` | Nonempty exact string | Exact native firmware identity, no guessed ordering or inherited gateway version |
| `unit` | `{context: string, binding: string}`; both nonempty | `context` must equal envelope `subject`; `binding` locates retained native unit-binding evidence for the same model and firmware observations, not merely a caller routing choice |
| `map` | `{document: string, revision: string, applicability: string}`; all nonempty | Exact document/revision and locator for explicit family, model, firmware and unit applicability; no inferred cross-family or cross-version applicability |

An unrecognized family string is a schema error. A well-formed but other-family
observation is retained as an incompatible alternative to a SUN2000 claim, or
as a referenced mismatch diagnostic, never relabeled SUN2000. For contradictions,
the family alternative type permits other native family strings solely to
retain the mismatch. Map applicability references must identify the exact
candidate tuple, including unit binding, rather than assert that a map exists.
A public map locator requires publishable facts under the native contract;
restricted source inspection does not satisfy this requirement.

`map_pinned`, `admitted`, or any caller boolean is not an input field. Map
identity and applicability must be independently resolved against authoritative
native disposition and registry admission evidence by the future consumer.
This revision resolves every map as unadmitted, including synthetic exact maps.
A synthetic reference may establish an example's structure but cannot establish
a real native identity or map applicability.

## Evaluation, reasons and transitions

Evaluation consumes one immutable input snapshot and performs zero I/O. The
consumer validates structure and reference resolution first, then checks each
field's exactness, provenance, subject binding and applicability independently.
A gateway child inventory or readability alone is insufficient, even if its
strings look exact. Evidence from different subjects cannot be spliced into a
tuple. A `present` wrapper is a claim to check, not an accepted discriminator.

A documentary candidate is complete only if all five fields pass these checks
within the supplied evidence domain. A candidate with `missing`, `unavailable`,
ineligible provenance, or failed applicability is incomplete. Contradictory
observations of one asserted tuple are different from two internally coherent
candidate hypotheses: the former conflict within a candidate, the latter
compete without any priority. Duplicate IDs are invalid; different IDs with an
identical tuple cannot manufacture ambiguity and are malformed duplicates.
Synthetic completeness is only a hypothetical input property.

Apply the first matching row. Compute all applicable diagnostics as well as the
primary reason; lower-ranked reasons must not hide stronger failures.

| Priority | Condition | Outcome | Primary reason |
| --- | --- | --- | --- |
| 1 | Invalid structure, unresolved reference, duplicate tuple or invalid field type | `INSUFFICIENT_EVIDENCE` | `INVALID_INPUT` |
| 2 | Any candidate contains conflicting field observations for this subject | `INSUFFICIENT_EVIDENCE` | `CONTRADICTORY_EVIDENCE` |
| 3 | More than one distinct documentary complete candidate | `AMBIGUOUS` | `MULTIPLE_CANDIDATES` |
| 4 | Zero complete candidates, or one complete candidate plus any incomplete candidate | `INSUFFICIENT_EVIDENCE` | First applicable field reason below |
| 5 | Exactly one complete candidate, with no incomplete or contradictory candidates | `NO_ADMISSIBLE_PROFILE` | `MAP_NOT_ADMITTED` |

The mixed complete/incomplete case cannot select around a failed candidate.
No candidate order, model preference or map revision ordering breaks a tie.
Within priority 4 the fixed field-reason order is `NO_CANDIDATES`,
`FAMILY_EVIDENCE_INSUFFICIENT`, `MODEL_EVIDENCE_INSUFFICIENT`,
`FIRMWARE_EVIDENCE_INSUFFICIENT`, `UNIT_EVIDENCE_INSUFFICIENT`,
`MAP_EVIDENCE_INSUFFICIENT`. `NO_CANDIDATES` applies only to an empty array.
Missing, unavailable, inventory-only, cross-subject and applicability failures
remain distinguishable diagnostics under the applicable field reason.
Within each priority, diagnostics sort by candidate ID, then field order
family/model/firmware/unit/map, then reference ID; sorting is presentation only.

| Input transition on a new snapshot | Result change allowed |
| --- | --- |
| Missing to referenced exact field | Reevaluate all fields; no automatic promotion |
| Exact to unavailable or contradictory | Reevaluate fail-closed; retain native evidence and unrelated last-known-good observations |
| One complete candidate to two complete candidates | `NO_ADMISSIBLE_PROFILE` to `AMBIGUOUS`; selection stays null |
| Two complete candidates to one | Reevaluate; at most `NO_ADMISSIBLE_PROFILE` today |
| Caller supplies a pinned-map boolean | `INVALID_INPUT`; cannot change admission |

These transitions do not schedule reads, retries, scans or fallback. Invalid
inventory never admits a partial child list. Failure of this attempt does not
erase unrelated valid last-known-good state. Optional battery absence remains
Unknown, never numeric zero; an optional-group exception cannot negate an
already identified inverter. Battery detection is outside this input contract.

## Result contract and invariants

Every result has all fields below, including on malformed input. Diagnostics
may describe invalid fields without echoing unsafe input. No success variant
exists in this revision.

| Field | Type and invariant |
| --- | --- |
| `contract` | Exactly `sun2000-detection-input-v1` |
| `outcome` | One of the three outcomes in the precedence table |
| `primary_reason` | Exactly the first applicable reason from that table |
| `candidate_ids` | Sorted unique structurally valid input candidate IDs; empty if IDs cannot be safely validated |
| `complete_candidate_ids` | Sorted subset passing documentary checks; empty when structure cannot be evaluated |
| `diagnostics` | Array of `{candidate_id, field, reason, refs}`; candidate ID and field are null for envelope-level errors; otherwise name the candidate and field; reason is a nonempty diagnostic string, refs are validated input reference IDs |
| `selected_profile` | Null for every outcome, including ambiguity and exact-but-unadmitted input |
| `native_fact_count` | Integer 0, including when identity evidence is retained |
| `automatic_request_count` | Integer 0 |
| `fallback_attempted` | False |
| `catalog_registered`, `automatic_runtime_admission`, `live_qualified`, `support_claim`, `write_authority` | Each false |

`candidate_ids` retain hypotheses, not selections. Evidence records and diagnostic
counts are not native telemetry facts. Unknown values are not emitted as zero
telemetry, an empty telemetry record, or fabricated successes. No partial
profile or partial admission exists. An application projection must preserve
outcome, reasons, null selection and zero facts; if references or native detail
are omitted, report that projection loss explicitly. This contract changes no
existing eBUS MCP envelope or GraphQL surface; any later adapter must preserve
the same denial and evidence meaning on both surfaces.

## Four synthetic examples

The following compact construction notation expands to the field tables above;
it is not executable detector code or a real device tuple. All example records
are self-contained here. `M` means `{state: missing, value: null, refs: [],
alternatives: []}`. `P(v,r)` means `{state: present, value: v, refs: [r],
alternatives: []}`. `C(v,r,w,s)` means the contradictory wrapper with null value,
refs `[r,s]` and alternatives `[{value:v,refs:[r]},{value:w,refs:[s]}]`.
All envelopes have the required contract string and subject `synthetic-subject`.
All results include the fixed null/zero/false invariants above.

1. **Missing.** Evidence is `[]`; candidate `missing-case` has all five fields
   `M`. Outcome `INSUFFICIENT_EVIDENCE`, primary `FAMILY_EVIDENCE_INSUFFICIENT`,
   diagnostics identify all five missing fields, complete IDs `[]`. An empty
   candidates array instead produces `NO_CANDIDATES`.
2. **Inventory-only.** Reference `inventory` has source `gateway_inventory`,
   locator `synthetic inventory record`, context `synthetic-gateway`, level
   Hypothesis; its entire content is a child listing claiming SUN2000 and token
   `synthetic-model-a`. Candidate `inventory-case` has family
   `P(SUN2000,inventory)`, model `P(synthetic-model-a,inventory)`, and firmware,
   unit and map `M`. Outcome `INSUFFICIENT_EVIDENCE`, primary
   `FAMILY_EVIDENCE_INSUFFICIENT`; family/model provenance and the three missing
   fields are diagnostics. Complete IDs `[]`; a listing supplies no unit identity.
3. **Contradictory.** References `left` and `right` have source `synthetic`,
   context `synthetic-subject`, level Hypothesis and locators `synthetic left
   identity record` and `synthetic right identity record`. Their contents assert
   model tokens `synthetic-model-a` and `synthetic-model-b`, respectively, for
   the same candidate `conflict-case`. Model is
   `C(synthetic-model-a,left,synthetic-model-b,right)`; other fields are `M`.
   Outcome `INSUFFICIENT_EVIDENCE`, primary `CONTRADICTORY_EVIDENCE`; both model
   references survive alongside missing-field diagnostics. Complete IDs `[]`.
4. **Exact but unadmitted, with ambiguity variant.** Reference `tuple-a` has
   source `synthetic`, context `synthetic-subject`, level Hypothesis, locator
   `synthetic tuple a record`. Its entire content is family SUN2000, exact model
   token `synthetic-model-a`, firmware token `synthetic-firmware-a`, and native
   unit-binding placeholder `synthetic-binding-a` for that subject. Reference
   `map-a` has source `synthetic`, context `synthetic-subject`, level Hypothesis,
   locator `synthetic map a record`; its content names document `synthetic-map`,
   revision `synthetic-revision-a`, and applicability `synthetic tuple a record`
   for precisely those four values. Candidate `exact-a` has all fields `P`,
   with tuple fields referencing `tuple-a` and map referencing `map-a`; unit is
   `{context: synthetic-subject, binding: synthetic-binding-a}`. This is one
   complete hypothetical candidate: outcome `NO_ADMISSIBLE_PROFILE`, primary
   `MAP_NOT_ADMITTED`, complete IDs `[exact-a]`. No real applicability is proven.
   For the ambiguity variant, add candidate `exact-b` and separate references
   `tuple-b`/`map-b` constructed identically but replacing every `-a` token with
   `-b` (subject and family stay the same). They are distinct coherent
   hypotheses, not conflicting observations asserted for one tuple. Outcome
   `AMBIGUOUS`, primary `MULTIPLE_CANDIDATES`, complete IDs `[exact-a,exact-b]`.
   Both maps remain unadmitted; neither variant selects a profile or emits facts.

## Independent falsifiers and remaining acceptance

These are reasoned contract checks, not executed mutations or runtime tests.
Starting with synthetic candidate `exact-a`, change only the named field and
retain the other four exact fields and their evidence:

| Field varied alone | Minimal falsifier | Required outcome; consumer defect caught |
| --- | --- | --- |
| Model | Replace exact token with a prefix while retained evidence stays exact | `INSUFFICIENT_EVIDENCE`, `MODEL_EVIDENCE_INSUFFICIENT`; prefix/wildcard acceptance |
| Firmware | Replace exact token with an unreferenced version | `INSUFFICIENT_EVIDENCE`, `FIRMWARE_EVIDENCE_INSUFFICIENT`; ignored or ordered firmware match |
| Unit | Change only `unit.value.context` away from the envelope subject | `INSUFFICIENT_EVIDENCE`, `UNIT_EVIDENCE_INSUFFICIENT`; cross-unit evidence splice |
| Map | Change only revision to a different nonempty token with unchanged applicability evidence | `INSUFFICIENT_EVIDENCE`, `MAP_EVIDENCE_INSUFFICIENT`; document-only pin acceptance |

Family exactness, unit binding, map document and applicability must also be
checked independently by a future implementation; the four reasoned cases are
not an exhaustive executable identity suite. Resolving evidence intake does
not implement this interface. Native contract revision, publishable pinned
facts, separate identity/monitoring fixtures, executable gateway negative
overlap, registry implementation/admission, acquisition and physical
qualification remain separate acceptance. This page closes none of those and
does not close the parent integration work.
