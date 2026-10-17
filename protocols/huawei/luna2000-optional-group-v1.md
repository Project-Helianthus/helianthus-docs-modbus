# LUNA2000 Optional-Group Retention Contract V1

## Scope and evidence basis

This page proposes retention transitions for the optional LUNA2000 battery
family attached to a SUN2000 inverter. It specifies a documentation contract,
not an implemented state machine, register map, decoder, or acquisition path.
It is independent of proposed registry types and requires no other proposed
page to interpret its fields. The historical V1 name does not imply stability;
nothing is stable before Helianthus 1.0.

The public native contract comes first:

- [Inverter and battery disposition](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/inverter-battery-readonly-v1.md)
  establishes the separate classes, exact identity requirements, optional-group
  absence and exception rules, and current `NO_ADMISSIBLE_PROFILE` outcome.
- [Gateway read-only contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md)
  establishes that gateway inventory is not battery qualification and that
  Huawei classes do not inherit capabilities from one another.
- [Applicability and licensing](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/applicability-and-licensing.md)
  establishes the publication boundary and fail-closed profile admission.

| Evidence label | Meaning here | Qualification consequence |
| --- | --- | --- |
| Proven | The cited public contracts state default denial and no covered LUNA2000 family or firmware range; no battery behavior is proven by this page | None; current outcome remains `NO_ADMISSIBLE_PROFILE` |
| Hypothesis | The proposed transitions below describe how a future implementation should retain evidence | Synthetic examples demonstrate intended decisions only |
| Unknown | Battery registers, presence/absence encoding, monitoring values, scales, units, exact applicability, and live behavior | No capability or current value may be inferred |

These labels describe evidence strength, separately from observation state,
qualification, acquisition success, and admission. Inventory presence, successful
register readability, and an identified parent are never battery qualification.
No SUN2000, SmartLogger, EMMA, S-Dongle, or SunSpec capability is borrowed.

## Current disposition and conditional reopening

All states in this revision have `NO_ADMISSIBLE_PROFILE`, with
`catalog_registered=false`, `automatic_runtime_admission=false`,
`support_claim=false`, and `write_authority=false`. No new native facts, requests,
or runtime support follow from this page. FC0x41 and FC0x17 remain `NO_SEND` for
these classes. Unknown or absent values are never numeric zero.

The future `qualified` transition is **conditional/unmet**. It requires accepted
exact evidence and a revision of the native inverter/battery disposition to an
exact applicability contract. That contract must first satisfy its reopening
requirements: a pinned vendor document name and version, sanitized identity and
monitoring fixtures, and executable negative overlap against SmartLogger,
EMMA, and S-Dongle. Exact battery family applicability, model identity, firmware
identity, unit identity, pinned register map, and positively identified parent
must all agree with the accepted evidence. Serial numbers, ESNs, aliases,
prefixes, wildcards, and inventory-only observations cannot satisfy this step.

Even future evidence qualification does not grant catalog registration,
automatic runtime admission, successful acquisition, write authority, or a
support claim. Each remains a separate downstream decision under existing
trust and admission rules. No new authorization gate is introduced here.

## Independent inputs and retention bindings

The following are conceptual fields, not new API or registry types. Missing
bindings are unknown, never inferred from history or registration order.

| Input | Required binding and use |
| --- | --- |
| Parent evidence | Separate SUN2000 exact model, firmware, unit identity, evidence reference, applicability revision, source epoch, and positive-identity result; parent identity alone grants no battery capability |
| Group identity | Battery exact model, firmware, unit identity, and explicit attachment relation to the parent evidence; a routing address or inventory label alone is insufficient |
| Group history | Prior observations and any permitted last-known-good fields, each retaining its original parent/group binding, native evidence reference, applicability revision, source epoch, validity, and freshness status |
| Current eligibility | Independently evaluated permission to use each field as current under the exact accepted profile; never copied from historical qualification or from a sibling field |
| Source epochs | Parent and battery acquisition epochs retained separately; an explicit coherent association is required, not equal numeric tokens; reconnect retires the prior association |
| Evidence revision | Exact public source/version and accepted applicability contract; changing it invalidates prior qualification until re-evaluated |
| Observation result | Unknown, explicit absence, presence, optional exception, transport failure, malformed/partial evidence, or conflicting identity; retain native result and its scope without collapsing them |
| Budgets | Explicit finite input-size, processing, retry, freshness, and retention bounds described below; none is inferred from a gateway profile |

History is partitioned by parent identity and group identity, evidence revision,
and source-epoch association. It never migrates to a replacement parent or
battery. A new epoch may refer to old history for diagnostics, but cannot relabel
old observations as new. Delayed evidence from a retired epoch cannot overwrite
the current state or last-known-good fields. An unbound input cannot refresh
freshness, repair identity, or extend retention.

Native evidence retains its bounded payload, unknown fields, provenance,
version context, and outcome where supported; this contract does not prescribe
masking runtime observations. Public examples contain only synthetic symbols.
Partial last-known-good state survives a failed group update where a future
profile permits: replace only independently validated successful fields with
matching bindings, retain the other fields with their original validity and
age. Never turn a partial response into whole-group success or refresh all
fields from one successful sibling.

## Explicit input budgets

A future caller must supply the following finite bounds before evaluating new
evidence. This page assigns no numerical defaults or device-derived values.
Currently there is no admitted acquisition; the request count remains zero.

| Budget input | Required meaning | Missing, invalid, or exhausted outcome |
| --- | --- | --- |
| Read-only allowlist | Exact evidence operations and extents authorized by an accepted native contract; no discovery scan or fallback | No acquisition; unknown/unreadable evidence cannot qualify |
| Input extent | Maximum records, fields, and aggregate native payload bytes per evaluation | Reject the incomplete evaluation; retain bounded prior history without refresh |
| Processing deadline | Finite overall deadline, including any permitted retries | Late results cannot commit or refresh current eligibility |
| Retry budget | Explicit finite maximum attempts and per-attempt timeout within that deadline | Stop at exhaustion; never infer absence from failure |
| Freshness budget | Explicit maximum age per retained field and evidence result, with a defined monotonic age basis | Unknown age or exceeded bound makes that field ineligible as current |
| Retention budget | Finite maximum history entries, bytes, and age plus an explicit eviction policy | Evict within bounds; never reconstruct evicted evidence or continue eligibility from its label |

An absent policy rejects new evaluation without destroying history still
permitted by the last accepted retention policy; it does not extend that policy.
If retained data cannot be shown to remain within accepted bounds, it cannot be
used and must be evicted as required by those bounds. Gateway enumeration bounds
are not battery defaults. No operation, offset, payload, retry interval, or
freshness duration is invented here.

## Proposed states and transition precedence

`unknown` means there is no usable current presence result. `observed absent`
means an explicit absence result interpreted under an accepted exact native
contract, not a timeout or missing inventory entry. `present-unqualified` means
presence evidence exists but exact qualification is missing. `qualified` is the
conditional/unmet future state described above. `temporarily unreadable` means
current group evidence is unavailable while prior identity/history may survive.
`identity changed` fences the former binding; it does not identify or qualify a
replacement.

Evaluate in this order: reject retired-epoch results; fence an explicit identity
or parent mismatch; reject invalid, incomplete, or over-budget evidence; then
interpret presence/absence and optional failures. A contradictory absence and
presence result in one evaluation is invalid evidence, never a priority winner.
Freshness is checked independently for every field after each transition.
Reasons below are descriptive contract reasons, not new registry error codes.
The profile disposition remains `NO_ADMISSIBLE_PROFILE` in every executable
case today.

| Previous state | Evidence/event | Next state | Retained history | Current eligibility | Reason |
| --- | --- | --- | --- | --- | --- |
| Any | Result from retired source epoch | Unchanged | Unchanged within bounds; record rejected result separately if permitted | Cannot be restored or refreshed by this result | Obsolete source association |
| Any | Explicit parent mismatch or changed battery model, firmware, unit, attachment, or accepted evidence revision | identity changed | Fence old partition; retain it only as bounded history | None for the old binding | Identity/applicability changed; never transfer qualification |
| Any | Parent identity missing or no coherent parent/group epoch association | unknown | Preserve separately bound prior history within bounds | None | Parent binding unproven; inventory cannot fill it |
| unknown / observed absent / identity changed | No usable presence evidence, including inventory-only evidence | unknown | Preserve old partition separately if any | None | Insufficient native evidence |
| present-unqualified / qualified / temporarily unreadable | Disconnect, timeout, malformed/partial group evidence, missing budgets, or exhausted budget | temporarily unreadable | Preserve permitted last-known-good fields without refreshing failed fields | No fresh group result; historical fields require independent future-profile freshness/retention permission | Failed acquisition/evaluation is not absence |
| unknown / observed absent / identity changed | Same failure without a currently established group binding | unknown | Preserve old history without attaching it to a replacement | None | Failure cannot establish presence or absence |
| Any, after binding checks | Explicit absence interpreted by accepted exact evidence | observed absent | Preserve historical values with absence marker within retention bounds | No current group values; unknown, never zero | Absence is a distinct observation; encoding remains unknown today |
| Any, after binding checks | Valid presence, but missing exact qualification | present-unqualified | Retain bounded observation; old values remain historical | No qualified current values | Presence is not qualification; `NO_ADMISSIBLE_PROFILE` today |
| present-unqualified / temporarily unreadable / qualified | Complete fresh exact evidence accepted under the revised native contract and coherent current parent binding | qualified, conditional/unmet | Retain evidence and independently valid fields under their exact bindings | Only covered fresh fields, conditional on separate admission; none admitted today | Future qualification requirements are unmet |
| present-unqualified / qualified / temporarily unreadable | Optional-group exception with unchanged positively identified parent and group binding | temporarily unreadable | Retain permitted partial last-known-good state and the native exception | No new group result; permitted history stays explicitly historical and freshness is evaluated per field | Optional failure does not negate identified parent or unit |
| Any | Freshness or retention age expires without a new presence result | Unchanged observation state | Mark stale or evict as budget requires | Expired fields ineligible; state label cannot refresh them | History is not current evidence |
| Any | Reconnect opens a new source association | unknown | Prior epoch history remains separately bounded | None until new parent and group evidence is accepted | Reconnect is not requalification |

An explicit absence cannot be reached by this revision's unknown battery
encoding. Its row is a future decision rule, not a claim of implemented absence
detection. On reappearance after absence, evaluate presence and qualification
anew; old qualified history does not bypass either step. From `identity changed`,
new valid presence starts `present-unqualified` under a new partition; only a
subsequent complete accepted exact evaluation could take the conditional step.

## Synthetic decision examples

Symbols P, Q, G, E, and F are artificial labels, not device identifiers, firmware
values, addresses, or evidence of live qualification. Each example is a reasoned
contract review, not an executed runtime test. References to prior qualified
state assume a future revised native contract; that prerequisite is unmet today.

| Case | Minimal evidence/event | Expected retention and decision |
| --- | --- | --- |
| Parent mismatch | History for group G bound to parent P; new observation binds G to Q | `identity changed`; fence P/G history, no eligibility carried to Q/G even if group fields look equal |
| Disappearance | Prior presence for P/G; a later explicit absence under a future accepted encoding | `observed absent`; retain bounded historical fields, publish no current group values and no numeric zero; a missing inventory listing alone cannot produce this result |
| Optional exception | P/G identity unchanged; only the optional group read fails | `temporarily unreadable`; keep parent identity and permitted partial last-known-good state; no new successful group result and no age refresh |
| Stale history | P/G remains identified; one retained field exceeds its explicit freshness budget while another remains within it | Expired field is ineligible; other field stays separately historical under future policy; no whole-group freshness from the younger field |
| Reconnect | P/G evidence belongs to epoch E; a new association F opens | `unknown`; E history remains historical; reject a late E result, then require fresh coherent parent/group evidence in F; identical identity text alone does not restore qualification |
| Inventory only | A gateway lists the LUNA2000 family but no native exact battery/parent evidence exists | `unknown`; no qualification, facts, or eligibility; retain listing only as bounded contextual evidence |
| Reappearance | Explicit absence followed by native presence with incomplete exact identity | `present-unqualified`; prior history cannot supply missing current identity or evidence revision |
| Partial monitoring | Future accepted P/G profile; one field is validated, another fails within the same bounded evaluation | Update only the independently valid field; retain the failed field's prior value and age if permitted; no complete-group success |

## Ownership and remaining acceptance

This is a partial documentation slice of the battery optional-group contract.
It does not close registry implementation, acquisition, transport conformance,
physical qualification, integration, or parent acceptance. No runtime success is
inferred. No receipts, idempotency ledger, principal boundary, or recovery
redesign is specified; those remain with their existing owners.

There are no changes to eBUS MCP envelopes, GraphQL surfaces, protocol-neutral
semantics, or consumer bindings. Any later projection must preserve the native
state, per-field history validity, source association, and reason, and explicitly
identify projection loss rather than flatten absent, stale, or unreadable values
to zero. MCP compatibility and GraphQL parity remain separate integration
acceptance obligations. This page grants no writes or live-device access.
