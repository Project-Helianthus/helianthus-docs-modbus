# LUNA optional-group provider-port composition contract

This Helianthus application architecture guidance is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope, evidence and native authority

The public [native optional-group contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/luna2000-optional-group-v1.md)
comes first, together with the [inverter/battery disposition](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/inverter-battery-readonly-v1.md).
This page proposes one family-local offline composition port for the LUNA2000
optional battery family and its independently identified SUN2000 parent. It
adds no protocol mapping, register, decoder or absence encoding.

| Evidence label | Claim and limit |
| --- | --- |
| Proven | The supplied merged [reducer source](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/luna_optional_state.go) and [component contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/luna-optional-state-reducer-implementation.md) define native documentary reduction, bounded retention and denied admission. This is source evidence, not battery behavior. |
| Hypothesis | The I15 interface, concrete adapter and lifecycle below are proposed acceptance for implementation. No wrapper implementation or executed wrapper tests are established here. |
| Unknown | Native presence/absence encoding, covered firmware applicability, numerical monitoring, connected provenance, production acquisition and physical behavior remain unknown. |

Evidence strength, observation status, freshness, qualification, admission,
runtime acceptance and physical acceptance are independent. All results retain
`NO_ADMISSIBLE_PROFILE` and denied/`NO_GO` composition disposition. `NO_GO` here
is a documentary disposition, not a new native enum. `Qualified()`,
`CatalogRegistered()`, `AutomaticRuntimeAdmission()`, `SupportClaim()` and
`WriteAuthority()` remain false. Nothing is stable before Helianthus 1.0.

## Proposed local API and concrete adapter

The following is a proposed Go-shaped API contract, not a claim that these
symbols already exist. All new symbols and fields use the I15/i15 prefix;
existing native API names are consumed unchanged. Interface and adapter belong
together in one implementation file. No I sibling import, code artifact or PR
is a dependency. Reconcile final spelling with I15 at code merge.

```go
type I15LunaProvider interface {
    I15Refresh(context.Context, I15LunaRefreshInput) (I15LunaReceipt, error)
    I15Cancel() (I15LunaReceipt, bool)
    I15Latest() I15LunaView
    I15Retire() I15LunaView
}

type I15LunaSupplier func(context.Context, I15LunaPlan) (I15LunaSupply, error)
type I15LunaClock func() int64

func I15NewLunaProvider(I15LunaConfig) (*I15LunaAdapter, error)
```

`I15LunaAdapter` is the proposed concrete implementation of `I15LunaProvider`.
It owns a zero-initialized `LunaOptionalState`, one immutable generation, one
active-refresh slot, one terminal receipt slot and detached latest/history
views. It invokes `ReduceLunaOptionalState` at most once per accepted successful
supplier completion. It implements no common production `Provider` interface
and no M02 gateway registry. This page supplies no production implementation.

The proposed data shapes are as follows; every listed field is new unless
qualified as a field of an existing native type.

| Proposed type | Fields and ownership |
| --- | --- |
| `I15LunaConfig` | `I15Generation` (nonempty opaque local token), `I15Binding` (`LunaOptionalBinding`), `I15ParentIdentified`, `I15EpochsAssociated`, `I15PolicyRevision` (nonempty exact token), `I15Limits` (`I15LunaLimits`), `I15Supplier`, `I15Clock`. Copy at creation; never infer identity or association. |
| `I15LunaLimits` | Positive finite `I15MaxTokenBytes`, `I15MaxReceiptBytes`, `I15MaxWorkSteps`; these bound every identity/revision/error/category string, the single receipt and supplier traversal/copying respectively. Native policy limits below apply additionally. |
| `I15LunaRefreshInput` | `I15Policy` (`LunaOptionalPolicy`), `I15PolicyRevision` matching config. Refresh cannot replace binding or generation. |
| `I15LunaPlan` | Frozen config generation, binding, identity/association assertions, policy revision and limits, plus constructor-minted `I15Owner` (unique instance token), `I15Attempt` (unique nonreused local token), `I15Started` and `I15Policy`. The supplier gets a detached value. |
| `I15LunaSupply` | `I15Plan` (exact plan echo), `I15Kind` (one of the categories below), `I15Event` (`LunaOptionalEvent`), `I15Evidence` (`[]LunaOptionalEvidence`), `I15ObservationParentEpoch`, `I15ObservationGroupEpoch`. The adapter constructs `LunaOptionalInput`; the supplier cannot set evaluation time, policy or identity assertions independently of the plan. |
| `I15LunaReceipt` | `I15Plan`, `I15Terminal` (complete, refused-event, supplier-error, cancelled, expired, invalid or retired), `I15Kind`, `I15Completed` and bounded `I15Error`. These are documentary values; Go errors carry the same category without unbounded supplier text. `I15Kind` is empty if no validated supplier category was available when termination won; a late return cannot fill it in. |
| `I15LunaView` | `I15Generation`, `I15Retired`, `I15Pending`, `I15AsOf`, `I15ClockValid`, `I15State` (`LunaOptionalStatus`), `I15ParentIdentified`, `I15History` (`[]LunaOptionalHistory`), optional `I15Receipt`. No synthetic current battery values. |

Creation requires a nonnil supplier/clock, valid complete binding, true explicit
parent-identification and epoch-association assertions, finite positive limits
and bounded tokens. An unidentified parent is a creation refusal; identified
parent success still proves no optional-group presence. Creation calls no
supplier and starts at `LunaUnknown` with empty history and no receipt. The
clock must provide nonnegative nondecreasing ticks on one caller-defined
monotonic basis; it is a bounded offline dependency, not a device clock. The
constructor mints `I15Owner` locally; caller generation tokens alone cannot
identify an instance. A regressing clock refuses publication and cannot extend freshness or retention.
The adapter must be constructed through the constructor; nil or uninitialized
adapters refuse refresh with an error and cancel with false; view/retire return
an empty unknown view with `I15ClockValid=false`, without supplier work.

Policy revision binds an immutable policy contract. Within it a refresh can
advance only the absolute `Deadline`; changing any other policy field or any
config field requires retirement and a fresh generation. No old history is
imported as the new generation's current evidence. The first accepted refresh
fixes those policy fields; a refused refresh cannot fix or extend them.

## Bounds and one-cycle ordering

There is at most one synchronous bounded fake-supplier call per accepted
refresh, zero retries, zero queued work and zero network/device operations.
No socket, active acquisition, background scheduler, registration or native
qualification is present. Caller and supplier must not mutate transferred
values concurrently. Copy and validate extents before retaining any input.

| Bounded input | Required rule |
| --- | --- |
| Native records and bytes | Positive `MaxRecords` and `MaxBytes`; evidence length and total charge fit. Each record charge is the reducer's fixed scalar allowance plus all parent/group identity, attachment, epoch and evidence-revision strings plus `Reference` and `NativeOutcome`. Bound enumeration and copying before materialization; use overflow-safe subtraction. |
| Binding and wrapper metadata | Complete binding fits `MaxBytes` even with no records; each token fits `I15MaxTokenBytes`. The entire single retained receipt, including plan/error, fits `I15MaxReceiptBytes`. Preflight space for the frozen plan and every possible bounded terminal receipt before accepting an attempt. No raw payload or unbounded error store is added. |
| Evaluation time | `Started` is frozen by the adapter; completion `Now` comes from its clock. Require `0 <= Started <= Now < Deadline`; equality is expired. Context must be nonnil, uncancelled and have a finite deadline; honor whichever context cancellation or native deadline expires first, without inventing a conversion between clock bases. |
| Freshness and retention | Positive `FreshnessAge`, `RetentionAge`, `HistoryRecords`, `HistoryBytes`; each retained record ages from its own `ObservedAt`. No implied device defaults or numerical telemetry. |
| Work | Supplier must cooperate with cancellation and finish within `I15MaxWorkSteps` and deadline. Bound traversal, strings and allocations; one call cannot hide internal retries. Do not run arbitrary blocking code in a goroutine and call its abandonment a finite bound. |
| Native evidence | Nonempty bounded references and native outcomes; `0 <= ObservedAt <= Now`. References are opaque and never dereferenced. Clock basis and evidence provenance must be declared by the supplier, not inferred from an inventory label. |

1. Validate adapter, context, clock, policy, revision and bounds before accepting
   an attempt. Busy, retired, malformed or over-budget requests refuse with an
   error, zero supplier calls and no new receipt. Existing history continues to
   age under the last accepted policy; refusal never renews it.
2. Freeze one plan and reserve its unique attempt. Recheck cancellation before
   the supplier. Do not hold a lock across supplier code that prevents cancel or
   retire. Cancellation here terminates the attempt without invoking the supplier.
3. Invoke the supplier once with a derived cancellable context. `I15Cancel` and
   `I15Retire` signal that context as well as fencing publication. Native deadline
   expiry is checked on return; no background clock poller is introduced. On return, a terminal attempt keeps its original
   receipt. Otherwise cancellation or retirement that wins publication fencing
   takes precedence over returned data/error. Error plus data is supplier-error;
   discard the data. An error alone invents no native observation.
4. Check completion clock/deadline, complete plan echo, input limits and every
   identity axis below. The adapter constructs native `Started`, `Now`, `Policy`,
   binding and identity assertions from the frozen plan and clock. Supplier
   plan substitution is rejected rather than silently repaired. Observation epochs
   must match the plan. Validate all returned evidence before reduction.
5. Classify the supplied event using the table below. Only supported documentary
   categories call the reducer. Serialize the final cancellation/retirement
   check with publication of the new native state and immutable receipt. Do not
   publish provisional evidence. A complete receipt means documentary processing
   completed, including failure or unknown state; it is never qualification.
6. Release only that attempt's slot. Repeated cancellation and late return are
   idempotent; an old attempt cannot clear a successor refresh's slot. A commit
   that wins before cancellation remains historical complete. `I15Cancel`
   returns the active attempt's original terminal receipt and true when it wins;
   with no active attempt it returns a zero receipt and false, without changing
   the last receipt. Cancellation does not itself call the reducer.

`I15Retire` is permanent and idempotent: terminate a pending attempt as retired,
fence late completion and mark retained views historical. No future refresh is
accepted. A successor needs a new adapter and generation; no token reuse or
restamping. Retirement after an already complete attempt preserves that receipt.
`I15Latest` calls no supplier and advances only the view's age/eviction under the
last accepted retention policy. It leaves the reducer observation label as-of
its original reduction; do not feed `LunaNoObservation` merely to age history,
since that would change the label. Fresh/Applicable flags are recomputed without
reviving fenced records; retirement makes wrapper applicability false. A failed
clock reading sets `I15ClockValid=false`, preserves the last valid `I15AsOf`,
and exposes no current eligibility (`Fresh=false`, `Applicable=false` in returned
history). It must not renew or falsely age stored data. A valid view sets
`I15ClockValid=true`.

## Native transitions, wrapper loss and identity fences

Supplier categories are proposed constants `I15DocumentaryPresence`,
`I15InventoryOnly`, `I15Unattempted`, `I15Timeout`, `I15IllegalAddress`,
`I15Malformed` and `I15ExplicitAbsence`. They are documentary classifications,
not requests or native wire decoders. Native outcome text and references remain
in their original evidence records. No response code or absence marker is invented.

| Supplier category | Native event consumed / wrapper action | Native result with matching valid binding |
| --- | --- | --- |
| `I15DocumentaryPresence` | `LunaDocumentaryPresence`, with at least one valid record | `present-unqualified`; parent alone never supplies this event |
| `I15InventoryOnly` | `LunaInventoryOnly` | `unknown`; not presence or absence |
| `I15Unattempted` | `LunaNoObservation`, no newly supplied evidence | `unknown`; retain prior bounded history without restamping |
| `I15Timeout` | `LunaOptionalFailure` | `temporarily unreadable` after established presence/unreadability, otherwise `unknown` |
| `I15IllegalAddress` | `LunaOptionalFailure` | Same coarse state as timeout, distinct receipt category and native outcome; never absence |
| `I15Malformed` | `LunaMalformedEvidence`, retaining only structurally valid bounded diagnostic references | Same failure rule; malformed input itself is refused before reduction |
| `I15ExplicitAbsence` | refused-event; no reducer call, retain prior state/history | Accepted absence encoding is Unknown. Preserve bounded receipt category, never claim `observed absent`, numeric zero or current presence |
| Unrecognized category, event/category mismatch or attempted qualified event | invalid; no reducer call | No new evidence or authority |
| Supplier error, cancellation, expired completion or invalid bounds | Terminal wrapper failure; no reducer call | Prior native label retained as historical; failure receipt does not refresh it |

For `I15ExplicitAbsence`, require an empty `I15Event`; its category alone
records the unsupported claim and is never cast to a native event.

The native contract describes a conditional absence transition, but the merged
reducer exposes neither absence nor qualified event constants. The wrapper must
not manufacture these through string casts. Explicit absence remains a distinct
refusal, not a timeout, unattempted result or proven absence. Native failure
reduction may append separately timed valid diagnostics; it never refreshes an
older successful record. A missing/invalid native policy uses last accepted
retention without extension; wrapper validation ordinarily refuses it earlier.

The native reducer additionally rejects retired observation epochs before
binding/event interpretation (age maintenance only), fences binding changes as
`identity changed`, and fences missing/incoherent identity as `unknown`. The
wrapper's fixed-generation prevalidation prevents supplier substitution from
reaching those transitions. These existing reducer behaviors are not a wrapper
rebind API. Fenced native history never becomes applicable again when tokens recur.

Each row below varies only the stated field against an otherwise identical
synthetic plan. A missing value is also invalid. These are review expectations,
not executed mutation tests; the last column names the production mutation a
future independent variant must catch.

| Independent axis | Expected wrapper fence | Mutation the variant must catch |
| --- | --- | --- |
| `Binding.Parent.Model` | Reject completion; retain original binding/history | Omit exact parent-model comparison |
| `Binding.Parent.Firmware` | Same | Omit exact parent-firmware comparison |
| `Binding.Parent.Unit` | Same | Omit exact parent-unit comparison |
| `Binding.Group.Model` | Same | Omit exact group-model comparison |
| `Binding.Group.Firmware` | Same | Omit exact group-firmware comparison |
| `Binding.Group.Unit` | Same | Omit exact group-unit comparison |
| `Binding.Attachment` | Same | Omit attachment comparison |
| `Binding.ParentEpoch` | Same | Omit current parent-epoch comparison |
| `Binding.GroupEpoch` | Same | Omit current group-epoch comparison |
| `Binding.EvidenceRevision` | Same | Omit native evidence-revision comparison |
| `ParentIdentified` | Reject false assertion; parent success proves no group | Trust supplier parent assertion |
| `EpochsAssociated` | Reject false association even with equal epoch strings | Infer association from token equality |
| `ObservationParentEpoch` | Reject retired/mismatching source epoch | Omit originating parent-epoch check |
| `ObservationGroupEpoch` | Reject retired/mismatching source epoch | Omit originating group-epoch check |
| `I15Generation`, `I15Owner` (separate variants) | Reject cross-instance result, even with equal binding | Drop generation comparison or owner comparison, respectively |
| `I15Attempt` | Reject completion for a different refresh | Drop active-attempt comparison |
| `I15PolicyRevision` | Refuse stale/different policy contract | Drop policy-revision comparison |
| Every `LunaOptionalPolicy` field | Reject supplier substitution independently for `MaxRecords`, `MaxBytes`, `Deadline`, `FreshnessAge`, `RetentionAge`, `HistoryRecords`, `HistoryBytes` | Drop the corresponding frozen-field comparison, one variant per field |
| `I15MaxTokenBytes`, `I15MaxReceiptBytes`, `I15MaxWorkSteps` | Reject each substituted limit independently | Drop the corresponding limit comparison, one variant per field |
| `I15Started` / native `Started` | Reject changed plan start; construct native start from frozen plan | Trust changed plan start |
| Native `Now` (adapter-owned) | Reject negative, regressing or expired completion tick independently | Omit each clock/deadline check, one variant per condition |

No identity is established by alias, route, registration order or a sibling
family. Exact model fields are opaque synthetic identity tokens here, not a
published supported-model list. Policy revision is wrapper metadata absent from
`LunaOptionalBinding`; it cannot be hidden in `EvidenceRevision` or inferred by
comparing policy numbers.

The wrapper retains one bounded terminal receipt, not an unbounded attempt log;
a later accepted terminal result replaces that slot. During an attempt, the
previous receipt remains intact. Native history retains its insertion order,
original binding, event, reference, native outcome and `ObservedAt`; newest
insertions win within native count/byte/age bounds. Eviction is irreversible.
Returned views and supplier buffers cannot mutate stored state. Raw native
payload and unknown fields stay with their supplying owner: this reducer stores
references, not raw payload or per-field numerical last-known-good values.
Partial last-known-good evidence remains individually bound and aged. No whole
group success, freshness renewal, zero fill or payload reconstruction follows
from one successful sibling. Any consumer projection must declare loss of raw
payload, receipt distinctions, history, binding or age rather than discard it silently.

## Synthetic examples and remaining acceptance

All labels and ticks below are synthetic; ticks are relative monotonic values,
not capture times. Assume positive finite budgets sufficient for these records,
`FreshnessAge=5`, `RetentionAge=20`, `Started <= Now < Deadline`, and a single
unchanged binding/revision unless stated. Every row remains denied/`NO_GO` with
all admission, qualification, support and write predicates false.

| Scenario | Independent expected state, receipt and retention |
| --- | --- |
| Create; parent identified, no refresh | `unknown`, empty history, no receipt; zero supplier calls |
| Documentary presence record at tick 2; completion at 3 | `present-unqualified`, complete receipt at 3; record retains `ObservedAt=2`, age 1 |
| Same record; timeout at 6 with a separately observed valid failure record | `temporarily unreadable`; timeout receipt; successful record stays at 2, age 4; failure record has its own tick |
| Same prior record; illegal-address at 6 | Same native state/age, illegal-address receipt distinct from timeout; parent remains identified |
| Same prior record; unattempted at 6 | `unknown`, unattempted receipt; history still at 2, not an absent result |
| Same prior record; explicit absence at 6 | refused-event receipt; prior native label retained historically, original record age 4; no accepted absence or current eligibility inferred |
| Presence at 2; latest view at 8 and then 23 | At 8 record is stale (age 6); at 23 evicted (age 21); label alone supplies no current value |
| Presence at 2; cancel wins while supplier returns at 6 | cancelled receipt at its original terminal tick; no reduction, record stays at 2; late completion cannot replace receipt or evidence |
| Reduction wins at 6; cancel arrives later | Original complete receipt at 6 survives; no reclassification or restamping |
| Retire wins while attempt A is pending; new adapter B created | A retired, retained evidence historical with original receipt/ticks; late A cannot publish into B or release B's slot |
| Supplier returns error plus valid data | supplier-error receipt; discard data, preserve prior native evidence/age; no fabricated optional-failure observation |
| Change one identity/revision/limit/time field from the identity table | Refuse or terminate invalid before reduction; no new evidence, generation migration or freshness extension |
| Mutate returned history/receipt or supplier buffers after completion | Stored history/receipt unchanged; views detached; concurrent mutation during transfer is outside the supplier contract |

Manual acceptance must compare the public native contract and supplied source
against every API/transition/identity/loss/example claim above. No implementation
test discovery or executed mutation kills are supplied by this documentary
slice. Future implementation review must exercise every identity and policy field
independently, cancellation/retirement versus late return, receipt immutability,
bounds before allocation and explicit absence versus timeout. Finite watchdogs
provide hang diagnostics only, not timing or ordering proof.

This independently mergeable companion addresses [docs issue #226](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/226)
and references [docs issue #199](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/199)
and [registry issue #199](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/199)
as partial contributions; parents remain open. There is no special merge hold
and no dependency on I15 code or any unmerged sibling. Ordinary review and
applicable gates remain.

Production common Provider composition, M02 registry integration, acquisition,
persistence, transport conformance, passive capture evidence, native
qualification, smoke/runtime integration and physical acceptance are unrun and
unclaimed. Existing eBUS MCP compatibility, GraphQL parity, deterministic
consumer envelopes and G5 D1-D5/O8 remain unchanged. eeBUS output remains in
helianthus-eebusreg. No consumer/output binding, authorization gate, new namespace
or stability claim is introduced.
