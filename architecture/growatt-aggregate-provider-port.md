# Growatt aggregate provider-port composition contract

This Helianthus application architecture contract is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.
Nothing is stable before Helianthus 1.0.

## Authority, scope and evidence status

The [public native family contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/growatt/bms-rs485-1xsxxp-v202.md)
comes first: it owns revision applicability, complete base and diagnostic
extents, native meanings and denied outbound authority for the Growatt
`1xSxxP ESS` RS-485 battery family. This application contract adds no protocol
facts. The [aggregate cycle contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/growatt-aggregate-offline-provider-cycle.md)
and [diagnostic check contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/growatt-diagnostic-commit-check-implementation.md)
provide the existing composition inputs. The
[aggregate retention component](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/growatt-aggregate-cycle-retention-implementation.md)
and [group lifecycle authority](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/growatt-battery-group-retention.md)
remain distinct owners. Source evidence is the merged
[offline provider](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/growatt_aggregate_offline_provider.go)
and [diagnostic checker](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/growatt_diagnostic_commit.go).
These supplied sources establish existing behavior even where the older cycle
page describes its proposed acceptance; they do not establish this wrapper.

| Status | Evidence and limit |
| --- | --- |
| Proven by supplied source inspection | Existing `GrowattAggregateOfflineProvider` calls one supplied reader through `Cycle`, exposes `Advance` and detached `Snapshot`, and owns aggregate retention. Existing `NewGrowattDiagnosticCommitBase` and `CheckGrowattDiagnosticCommit` revalidate a frozen base and return a detached all-or-nothing diagnostic candidate. The checker owns no store or lifecycle. |
| Hypothesis / proposed acceptance | The I23 interface and concrete adapter specified below compose those merged components, adding lifecycle generation, receipt linkage, diagnostic publication and retirement fences. These are requirements, not an implemented API claim. |
| Unknown | Final implementation spelling, concurrency proof, acquisition simultaneity, restart persistence, freshness policy, production integration and physical acceptance. |

Evidence status is separate from qualification, freshness, runtime admission
and support. This is the RS-485 aggregate path, not an inverter FC04 provider.
Exact FC04 automatic admission remains denied / `NO_GO`. This port performs
zero network or device work: no sockets, device opening, active acquisition,
background scheduler, retries, registration or native qualification. An
injected reader may only return supplied offline records. No common production
`Provider` interface or M02 gateway registry is supplied or completed here.

## Proposed family-local API and bounded inputs

The following Go-shaped declaration is the proposed local contract, not code
that currently exists. All new names use the I23 prefix. Native names are
consumed unchanged. Both interface and concrete adapter belong in one new
family-local implementation file; neither imports an I sibling. Reconcile
final spelling with I23 at code merge; this companion consumes no sibling code
or PR and has no special merge hold.

```go
type I23GrowattAggregateProvider interface {
    I23Refresh(context.Context, I23RefreshInput, func() uint64) (I23View, error)
    I23Advance(uint64) (I23View, error)
    I23Retire() I23View
    I23Snapshot() I23View
}

type I23Bounds struct {
    I23MaxCycleTicks, I23MaxBaseSlices, I23MaxBaseWords uint64
    I23MaxReaderWork uint64
}

type I23BaseLink struct {
    I23Generation, I23Receipt, I23SuccessRevision uint64
    I23Context GrowattDiagnosticCommitContext
}

type I23DiagnosticSubmission struct {
    I23Base I23BaseLink
    I23ExpectedReportedGroup uint16
    I23Input GrowattBMSMultiGroupDiagnosticInput
}

type I23RefreshInput struct {
    I23Cycle GrowattAggregateOfflineCycle
    I23Receipt uint64
    I23Diagnostic *I23DiagnosticSubmission
}

type I23View struct {
    I23Generation uint64
    I23Retired, I23Applicable bool
    I23Aggregate GrowattAggregateSnapshot
    I23Base *I23BaseLink
    I23DiagnosticOutcome string
    I23DiagnosticRejection GrowattDiagnosticCommitRejection
    I23DiagnosticBase *I23BaseLink
    I23Diagnostic *GrowattDiagnosticCommitCandidate
}

type I23GrowattAggregatePort struct { /* private lifecycle state */ }

func I23NewGrowattAggregatePort(
    i23Generation uint64, i23Bounds I23Bounds,
    i23Reader GrowattAggregateOfflineReader,
) (*I23GrowattAggregatePort, error)
```

`I23GrowattAggregatePort` must implement `I23GrowattAggregateProvider`. Creation
validates positive generation and every bound, a nonnil cooperative reader,
and base capacity of at least four slices and 50 total words, then calls
`NewGrowattAggregateOfflineProvider`. Larger capacities never extend the exact
native read set. The existing constructor checks positive capacities, not that
minimum: this stronger preflight is proposed wrapper behavior. Initial view
has absent aggregate, no base or diagnostic, and diagnostic outcome `absent`.

| Input | Required bound and refusal |
| --- | --- |
| Generation, receipt, epoch, cycle, success revision | Positive unsigned counters. Generation is fixed for an instance; replacement requires a strictly newer caller-owned generation. Receipt strictly increases across admitted refreshes, including failed ones; cycle/epoch follow native ordering. Exhaustion refuses rather than wraps. Preflight refusal consumes no receipt. |
| Context and strings | `SourceInstance` is a nonempty opaque internal token, at most 128 bytes. Every revision string is at most 64 bytes; `MCUSoftwareVersion` at most 32. All identity members must be coherently known, including native zeros. Unsupported unit/function/revision or unknown identity must never invoke the reader; native `Begin`/failure still owns invalidation when an admitted attempt has unknown or changed continuity. |
| Native selection | Explicit unicast `UnitID`, FC03 and the exact four-part revision from the native contract; no discovery, fallback or revision inference. |
| Ticks | One caller-owned monotonic logical domain. Positive maximum span; `deadline > now`, with subtraction bounded by `I23MaxCycleTicks`. At the deadline work is late. Backward ticks refuse; snapshot reads do not advance time. |
| Reader and clock | Nonnil context and clock; cancellation checked before work and publication. One reader call at most per admitted refresh, zero retries; no queued refresh. Reader work is limited by declared `I23MaxReaderWork` and cooperative cancellation/deadline. Clock must return promptly and safely, with at most four calls per refresh. No wrapper can forcibly bound an arbitrary callback. |
| Base storage | Existing provider checks configured total slices/words before retention decoding. The native decoder still requires exactly four ordered slices / 50 words. Never truncate or merge partial input. |
| Optional diagnostic | Nil means absent. Before copying/decoding, bound strings as above and require exactly three ordered diagnostic slices / 33 total words, with native offsets and lengths. The five retained raw records include two base-derived records; five is not the input slice count. One submission only; invalid or oversized diagnostics refuse independently after base handling. No arbitrary extra payload or diagnostic bank. |
| Receipt token and errors | Derive `BaseRecordID` as `i23-<generation>-<receipt>` using canonical unsigned decimal, with no leading zeros. Its maximum length is 45 bytes. Never use an installation identity or payload digest. Public error classification is finite; arbitrary reader error text must not enter deterministic consumer envelopes. |

## Refresh, cancellation, retirement and retained view

The adapter exclusively owns its native provider. It permits one in-flight
refresh, refuses overlap without queueing, and serializes publication,
`I23Advance`, snapshot and retirement decisions with a private lifecycle lock.
It must not hold that lock while executing the reader. It owns a cancellation
signal joined with the caller context. The existing native provider permits
concurrent cycles; this narrower wrapper policy is new. A detached published
envelope is a visibility fence, not a second aggregate retention algorithm.

1. Validate wrapper preconditions, receipt ordering and supplied bounds before
   admitting a refresh. A retired instance, overlap, invalid callbacks or
   cancellation already observed refuses with no reader call and no new native
   attempt. Reserve the receipt and active generation/cycle when admitted.
   Before exposing a changed or unknown continuity context, withhold prior
   aggregate and diagnostic applicability in the published view. Invalidation
   cannot be reversed by returning to an old key; only complete new success
   restores applicability. Native retention remains authoritative on closure.
2. Run the existing `Cycle` exactly once, using its original context, cycle,
   deadline and injected clock. Its `Begin`, cancellation/error handling,
   native validation and `Complete`/`Fail` own aggregate state. Unsupported
   context after begin closes without reading; unknown/changed continuity
   retains the component's fail-closed invalidation. Do not substitute the
   diagnostic checker for base decoding or bypass a native closure error.
3. Under the publication fence, recheck active generation, receipt and cycle,
   cancellation and retirement. A diagnostic base is eligible only if `Cycle`
   succeeded and `Snapshot` has `Value`, `State == "current"`, successful latest
   attempt, exact requested attempt/success contexts and cycle, and a new
   `SuccessRevision`. A retained earlier success is never this refresh's base.
   Publish a valid aggregate independently of later diagnostic results.
   Cancellation observed after native success withholds diagnostics and reports
   cancellation separately; it cannot discard that success. Retirement still
   fences publication as specified below.
4. Construct `I23BaseLink` from that accepted snapshot: wrapper generation and
   receipt, native `SuccessRevision`, and `GrowattDiagnosticCommitContext`
   carrying derived `BaseRecordID`, exact source, `Epoch = OwnerEpoch`, cycle,
   unit, function, revision and raw native continuity words. Extract raw
   `MCUVersion`, `BMS`, `Pack`, full `Topology`, `CellSeries` from the preserved
   native base; never reconstruct raw MCU evidence from a formatted version
   string. `NewGrowattDiagnosticCommitBase` must succeed on that exact value.
5. If diagnostics are supplied, independently compare every `I23BaseLink`
   member with this link, then call `CheckGrowattDiagnosticCommit` with the
   frozen base, submitted context, explicit expected reported-group word and
   complete input. The caller supplies truthful same-cycle provenance: matching
   tokens cannot prove acquisition simultaneity. Do not derive the expected
   group from the received group to manufacture continuity. Compare a complete
   candidate's `Identity()` with any retained diagnostic lineage. Changed
   battery ID or reported-group word invalidates the old diagnostic lineage;
   only a complete coherent candidate may start a new one, with no inherited
   cells or balance. A checker `diagnostic_lineage_changed` rejection also
   withholds prior diagnostic applicability while lineage is unresolved;
   aggregate applicability is unaffected.
6. Immediately before diagnostic publication, recheck generation, receipt,
   success revision, full base context, active cycle, cancellation, retirement
   and injected tick strictly before the original deadline. Commit the entire
   candidate atomically or none. Optional absence, malformed input, changed
   lineage, checker rejection, cancellation or expiry cannot roll back an
   already accepted aggregate. Expose diagnostic outcome separately.

`I23Advance(now)` calls native `Advance` and expires an open diagnostic window
at its deadline without invoking the reader. During an in-flight refresh it
may publish pending/failure/expiry metadata, but must not expose an inner native
success before the refresh publication fence approves it. An expired pending attempt
is `incomplete`; a base already successful stays successful when only the
optional diagnostic window expires. An old callback must pass its fence before
its tick can affect active work. No background timer is implied.

Cancellation before native commit follows existing failure/expiry behavior and
preserves earlier applicable aggregate success. Cancellation after native
commit cannot undo it; it withholds diagnostics not yet committed. If the
native call reports success during a cancellation race, expose the accepted
base and cancellation separately. An operation error never means that retained
content became a fresh success. Report a native closure refusal as a refusal,
not as proof that a failed attempt was recorded.

`I23Retire` is permanent and idempotent. At its serialization point, mark the
instance retired, close its diagnostic window, cancel in-flight work and freeze
the last published detached envelope for inspection with `I23Applicable=false`.
No further refresh or advance mutates it; return a retirement refusal. Late
reader or checker results cannot publish, even if the private native provider
finishes internally. Do not wait unboundedly for a noncooperative reader. The
retired owner is never reused; a new instance needs a newer generation. This
publication fence, cancellation and retirement do not exist in the merged
native provider and must be demonstrated by wrapper implementation tests.

`I23Snapshot` returns detached copies of all published typed/raw storage and
links, without ticking. During refresh it returns the latest published
inspection envelope with conservative applicability and any explicit advance
metadata, never uncommitted reader input. For a live instance, `I23Applicable` is true only
when the native aggregate view exposes an applicable value; it never grants
admission. Diagnostic applicability additionally requires coherent continuity
and its own preserved base link. Each completed refresh publishes the native
latest attempt and applicability, including failure/invalidation. There is only one
aggregate last success and one latest attempt. Optional diagnostic retention
is bounded to one entire last-good candidate with its original
`I23DiagnosticBase`; it never renews on failure, absence or snapshot reads.
Retain it only while source/epoch/native continuity remains coherent; expose
it as `retained`, never attached to a newer base link. Continuity invalidation
withholds the candidate; return to an old key cannot revive it. Retirement
keeps inspection evidence but denies applicability for both components.

Diagnostic outcomes are `absent`, `current`, `retained`, `refused`, `expired`,
`cancelled` or `invalidated`; a retained candidate may accompany `refused`,
`expired` or `cancelled` with its old link. `I23DiagnosticRejection` preserves
an actual native checker rejection unchanged; wrapper refusals use the
separate outcome/error and must not invent native rejection constants.
A base failure leaves diagnostic checking unattempted and returns the native
aggregate error; a diagnostic-only failure returns a separately classified
error alongside the successful aggregate. Nil error requires all requested
work to succeed; an omitted optional diagnostic is not an error.

## Synthetic transitions and independent identity review

All examples are invented logical counters and family-level supplied records;
none is a capture or qualification fixture. A complete base means the entire
canonical native base, not default-filled telemetry. Let generation 4, source
`i23-source-a`, epoch 2, receipt 8, cycle 3 succeed at tick 12 before deadline
20 with success revision 1 and base token `i23-4-8`. Call this base link
`i23-link-a`. Diagnostics use that exact link and an independently supplied
expected group word, including a legitimate zero.

| Transition | Aggregate result | Optional diagnostic result |
| --- | --- | --- |
| First complete base and matching complete diagnostic | `current`, cycle 3 / revision 1 / tick 12 | Entire candidate `current`, linked to `i23-link-a`; no admission change. |
| Same base; missing cell slice or wrong group expectation | Base still `current` at revision 1 | Refused, no partial sibling or balance commit; native rejection preserved. |
| Next receipt 9 / cycle 4 succeeds at tick 24, deadline 30; diagnostics still name receipt 8 / revision 1 | New aggregate revision 2 at tick 24 | Refuse wrong base association even when telemetry is equal; prior whole diagnostic may remain retained under `i23-link-a`. |
| Complete diagnostic reports a changed group word | Valid aggregate remains applicable | Invalidate old diagnostic lineage; rejection cannot retain old cells as belonging to the new group. Only complete resolved evidence may establish new lineage. |
| Next complete base has valid zero telemetry | Atomic native replacement and new success revision | Zero remains present; no synthesized SOC, rack or module facts. |
| Next base reader errors or returns partial input, continuity unchanged | `retained`, original success tick/revision unchanged | Do not check against old success as if it were the new base; keep applicable old bundle under its old link. |
| Owner advances pending base to deadline 30; reader returns at 31 | `incomplete`, applicable previous base retained | No new base link or candidate; late work cannot renew either success. |
| Base succeeds at 24; diagnostic publication tick is 30 | Base success at 24 remains | `expired`; whole earlier applicable bundle may remain retained. |
| Cancellation before begin / after reader before native commit | No attempt / native failure or expiry with earlier last-good | No new diagnostic; errors and native attempt remain distinct. |
| Cancellation after accepted base, before diagnostic commit | Valid base remains published | `cancelled`, no new candidate. |
| Newer epoch/source or any contradictory native continuity | Prior aggregate becomes inapplicable under native rules | Prior diagnostic invalidated; equal telemetry or restoring an old key cannot revive it. |
| Retirement while reader is blocked; late successful return | Frozen pre-retirement publication, applicability false | No late publication; newer-generation instance alone may refresh. |

The following is a manual acceptance matrix, not executed mutation testing.
Each listed field needs its own otherwise-identical variant in future wrapper
tests; combined changes cannot prove the individual fences. Expected outcomes
must be independent of production equality helpers.

| Independently varied field | Required refusal / production mutation to catch |
| --- | --- |
| Wrapper generation | Reject cross-instance diagnostics or late publication; removal of generation comparison must fail. |
| Receipt and derived `BaseRecordID`, separately | Reject a previous refresh's diagnostic; omission of receipt comparison or of native base-token comparison must each fail independently. |
| `SuccessRevision` | Reject equal-valued replacement under the old revision; dropping the success-revision check must fail. |
| `SourceInstance`; `OwnerEpoch` / diagnostic `Epoch`; cycle | Three separate variants reject incorrect continuity or base association; omission of each corresponding comparison must fail. |
| `UnitID`; `Function` | Separate variants refuse wrong unit or non-FC03 input; removal of each native-selection / linkage check must fail. No FC04 fallback. |
| Revision `Family`; `FileRevision`; `HeaderVersion`; `CumulativeRevision` | Four separate variants refuse; omission of any individual revision comparison must fail. |
| `IdentityKnown` | False prevents reader success and invalidates applicability; treating unknown as known must fail. |
| `MCUSoftwareVersion`; `BMSCompany`; `BMSGeneration`; `PackCompany`; `PackGeneration`; `Topology`; `CellSeriesCount` | Seven separate native aggregate variants refuse contradictory continuity; dropping any corresponding aggregate identity comparison must fail. |
| Diagnostic raw `MCUVersion`; `BMS`; `Pack`; `Topology`; `CellSeries` | Five separate constructor/checker variants refuse; omitting each native raw-word comparison must fail. Full topology variation must include bits outside Battery ID. |
| Retained diagnostic `BatteryID`; `ReportedGroupWord` | Two separate complete-candidate variants invalidate old diagnostic lineage; omitting either prior-identity comparison must fail. Aggregate success remains independent. |
| Explicit expected reported-group word | Complete diagnostic with a different reported word refuses, including zero versus nonzero; removal of the lineage check must fail. |
| Diagnostic input unit, function, each revision field, each slice offset/length/order | Separate variants reject malformed input under the existing decoder; removal of the corresponding validation must fail. Reordering and partial siblings cannot be committed. |

The raw/typed identity axes are not interchangeable: company and generation
bytes independently map to the raw BMS/pack words; formatted MCU identity does
not replace raw MCU evidence. Native battery ID and reported group word remain
diagnostic evidence, never selectors, discovery keys or synthesized topology.

## Native preservation, loss and consumer boundaries

Preserve aggregate opaque words, original selected unit, exact revision,
ordered offsets, success context/cycle/tick/revision and latest attempt outcome.
Preserve diagnostic raw order and source offsets, both fixed cell-block
positions, present zeros, full topology, raw balance word and native off/on
states, plus original base association. Detach input at bounded handoff and
output at every snapshot; callers must not mutate during copying. Reject a
partial bundle rather than silently dropping a malformed member.

No SOC, rack, module, pack count, cell topology, health or control synthesis is
permitted. Diagnostic blocks do not become aggregate telemetry. `current`
means cycle membership, not wall-clock freshness. Retained last-good state
keeps its original success tick and revision; there is no persistence, history
ledger or physical continuity proof. Diagnostic validation cannot promote a
base, and base success cannot promote an optional diagnostic or authorize reads.
Native outbound authority remains false; denied / `NO_GO` remains unchanged.

Future deterministic envelopes must distinguish absent, invalidated, retained,
zero, failure, cancellation and retirement, keeping aggregate and diagnostic
outcomes and their links separate. Any MCP/GraphQL projection must preserve
equivalent presence, provenance, applicability and refusal meaning; document
and withhold unsupported projections instead of flattening old evidence into
fresh telemetry. eBUS MCP compatibility, GraphQL parity, driver-owned eeBUS
output and gateway G5 D1–D5/O8 are unchanged. This page supplies no consumer
schema or output binding.

## Acceptance and companion disposition

This independent contract is a partial slice for [issue #230](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/230),
Project #2, Connect all drivers and native acquisition into the gateway
composition, and [modbusreg #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201).
The parent stays open. This companion may merge first: no I23 dependency or
special merge hold is introduced. Ordinary review and applicable gates remain.

Acceptance here is manual supplied-source/API, transition, independent identity,
loss, example and public-link review. Wrapper test cases above are proposed;
no executed test or mutation-kill claim is made. Remaining implementation
acceptance includes exact API agreement, bounded cooperative callbacks,
cancellation/publication races, independently varied identity fences, injected
tick expiry, retirement and detached ownership. Common Provider integration,
M02 registration, committed-head CI, transport/smoke execution, native
qualification, runtime and hardware acceptance remain unrun and unproven.
Documentation approval cannot satisfy them.
