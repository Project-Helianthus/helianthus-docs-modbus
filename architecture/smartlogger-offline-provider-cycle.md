# SmartLogger offline provider-cycle contract

This Helianthus application architecture guidance is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page specifies acceptance for one explicitly invoked offline cycle in the
Huawei SmartLogger family. The cycle composes the existing inventory commit
owner around one injected callback over supplied native records. It adds cycle
composition to the merged component; it does not replace that component.

| Evidence label | Claim and limit |
| --- | --- |
| Proven | The public native contract defines the evidence predicates. The merged component page documents the reviewed offline commit owner and its reported synthetic verification. Those sources establish component boundaries, not an implemented cycle. |
| Hypothesis | The cycle behavior below is proposed acceptance for implementation and independent review. Its exact new API signature, callback integration and cancellation behavior are not established as implemented. |
| Unknown | Production acquisition, connected identity, transport isolation, live qualification, persistence and end-to-end consumer replay remain unestablished. |

Evidence labels are separate from qualification, freshness and admission.
`DefaultDenied()` remains true for every `SmartloggerInventoryResult`, including
`complete`. No catalog registration, automatic runtime admission, support claim,
write authority or child capability follows from a successful cycle. Nothing is
stable before Helianthus 1.0.

## Sources and precedence

The [canonical native lifecycle contract](../protocols/huawei/smartlogger-provider-lifecycle-v1.md)
and its [read-only native predicates](../protocols/huawei/gateway-readonly-v1.md)
and [qualification bounds](../protocols/huawei/qualification-readiness-v1.md)
are authoritative for encoding, exact family/firmware tuples, coherent counter
bracketing, pagination and parser ceilings. This page adds no protocol facts or
live-read procedure.

The distinct [merged inventory commit component page](smartlogger-inventory-commit-implementation.md)
documents `SmartloggerInventoryCommitOwner`, its reviewed API, detached history
and publication fences. Reuse that component and its native parser. The rules
below are acceptance for a composition above it, not evidence of a current cycle
implementation. This contract can merge before corresponding code; code merge
requires behavior and signature agreement with the reviewed contract.

## Proposed seam and finite work

The seam is family-local and offline. It accepts a nonnil inventory callback
whose logical input is a frozen `SmartloggerInventoryPlan` value and whose
logical return is `HuaweiSmartLoggerOfflineInventoryInput` or an error.
Cancellation signaling and the exact Go signature require implementation review;
this is not a declaration that a new exported API exists. The callback consumes
caller-supplied records only, with no transport, discovery, acquisition owner or
implicit I/O. A cycle invokes it at most once, without polling, retries, queuing
or fallback. A caller must explicitly request any later independent cycle.

Before invoking the callback, require a usable owner, nonnil callback, valid
caller context, a finite absolute deadline and explicit finite work/input bounds.
Invalid inputs fail before callback invocation and cannot replace history. Use
`Begin(deadline)` only after these composition inputs have passed validation;
its own context/deadline validation remains authoritative. Busy or closed refusal
invokes no callback and creates no accepted attempt or fabricated terminal result.

Bounds must cover caller work and materialization as well as parser input:

- The deadline is strictly after begin and no later than the native fifteen
  second ceiling, shortened by any earlier caller deadline. It is never renewed.
- Caller limits for pages, objects, aggregate native response bytes and children
  are positive, finite and no greater than the canonical native ceilings. Bound
  traversal, allocation and copying before materializing input; parser rejection
  after unbounded allocation is insufficient.
- The callback must finish or cooperate with cancellation within the finite work
  budget. A deadline cannot forcibly interrupt an arbitrary function. Reject an
  unbounded callback contract; do not claim preemption or abandon unbounded
  background work as a successful bound.
- Zero, missing, overflowing, inconsistent or above-ceiling limits are invalid,
  not an instruction to use unlimited defaults. Exhaustion is failure even if
  earlier pages were valid. No extra page or second callback is allowed.

The existing owner accepts a deadline rather than these additional caller
limits. Enforcing the composition's work/input limits remains new acceptance;
it must not be attributed to the merged owner alone.

## Ordering and terminal transitions

1. Validate composition inputs and cancellation before `Begin`. Freeze the plan
   with `Begin`, then obtain its value through `SmartloggerInventoryAttempt.Plan()`.
   Recheck cancellation before calling the callback. Cancellation here uses
   `Cancel()` and performs no callback work.
2. Invoke the callback once with that frozen value. Do not hold a composition
   lock across caller code if it would prevent cancellation, `Close` or
   retirement. The callback cannot mutate owner state, select another identity,
   append work to the plan or publish partial inventory.
3. On return, first honor an already terminal attempt: cancellation, closure or
   retirement must keep its original result. Otherwise check caller cancellation
   before processing a returned error or accepting data. Cancellation observed at
   completion must call `Cancel()` before any commit attempt. If error and data
   are returned together, the error wins over data; the data cannot be committed.
4. A callback error or composition-bound failure must terminate the accepted
   attempt and release only its slot, retaining history. The component has no
   exported reader-error failure method: implementation review must choose an
   explicit failure path that yields `failed`, without calling the callback again,
   leaving the slot busy, inventing a successful empty inventory or mislabeling a
   reader error as caller cancellation. The exact error/result return shape and
   failure mechanism remain proposed, not Proven API.
5. Before commit, revalidate caller cancellation, the returned completion's
   association with the frozen context and deadline, and input/work bounds.
   The native input is evidence, not a new plan: keep the original plan separately
   and reject any substituted context/deadline. Do not imply that native input
   carries context fields absent from its actual type. Supplied records cannot
   attest their own acquisition time or connected provenance.
6. Only a successful callback with valid bounded input may call
   `Commit(originalPlan, input)`. Native parsing, self-entry validation, detachment
   and the final identity/deadline fence remain in the component. A check made
   before the callback is insufficient. Deadline equality is expired. Serialize
   cancellation and publication so cancellation that wins the terminal transition
   prevents publication; a completed commit remains historical success if
   cancellation arrives afterward.

Each accepted attempt yields exactly one immutable `SmartloggerInventoryResult`
with its original plan, `Outcome` and `CompletedAt`. Error propagation must retain
the callback failure category without inventing native observations; precise
error wrapping is implementation review work. Terminal results and late callbacks
cannot release a successor attempt's slot. Refusals before an accepted attempt
remain distinct from accepted terminal outcomes.

## Identity, native validation and retention

Every identity axis is independently significant; equality of other fields cannot
compensate for one mismatch. No wildcard or version-order inference is added.

| Frozen axis | Required check at completion |
| --- | --- |
| `OwnerToken` | Exact owning instance; another owner's evidence cannot publish. |
| `ConnectionGeneration` | Exact generation; reconnect or retirement invalidates the old authority. |
| `RoutingContext` | Exact opaque caller context; no real routing coordinates in public examples. |
| `UnitID` | Exact frozen logical unit, subject to native context validation. |
| `ParentProfile` | Exact native parent context; no inferred profile admission. |
| `SourceRevision` | Exact source context; no relabeling older evidence. |
| `SelfModel` | Exact native family predicate and equality with parsed self entry. |
| `Firmware` | Exact native tuple and equality with parsed self entry; no ordered fallback. |
| `AttemptToken` | Exact accepted attempt; a successor's token cannot complete it. |
| `Deadline` | Exact frozen absolute deadline, still unexpired after validation and copying. |

Reuse `ParseHuaweiSmartLoggerOfflineInventory` through the owner. Wrong next
object IDs, cursor loops, late pages with `More` still set beyond the bounds,
duplicate or out-of-order objects, malformed attributes, count mismatch,
counter mismatch and invalid self evidence fail the whole cycle. Valid earlier
pages are never a partial child list. A reader error after gathering pages
likewise publishes nothing. Do not reinterpret native rejection to salvage
success or add probes.

The callback transfers stable input for validation: no concurrent mutation of
`Pages`, objects or native bytes during commit. The stored snapshot and
`LastComplete()` views must remain detached from callback buffers and caller
copies. Retain native counter/page evidence, identity, source context and original
observation/completion markers; a semantic summary cannot replace them. The
component's failure outcome is coarse and adds no failed-response diagnostic
store. Any later projection must describe omitted native evidence or failure
detail explicitly.

Failures and cancellation retain the entire original last-complete inventory;
unrelated valid last-known-good observations also remain intact. Its age keeps
increasing from original `ObservedAt`, never from the newest attempt or error.
Without a prior snapshot, inventory remains Unknown rather than zero or an empty
successful inventory. A successful replacement gets its own original begin
observation and completion markers; old history is never restamped as fresh.

`Close()` permanently closes this owner and fences late completion.
`Retire(newContext)` requires a valid strictly newer connection generation and
retires the active attempt before installing the successor. Old inventory stays
historical with `Current=false`; it cannot become the successor's inventory by
relabeling. A late old callback cannot alter history, the successor slot or its
evidence. `Current` expresses matching open local context only, not connected
identity, freshness qualification or admission.

## Synthetic acceptance examples

These are independent expected transitions, not executed runtime fixtures.
`S`, `T`, `A` and `B` are synthetic local labels. Elapsed durations are relative,
not capture times. Every row retains denied admission and `DefaultDenied()=true`.

| Scenario | Expected outcome, history and age |
| --- | --- |
| Existing S observed at elapsed zero; A begins at five seconds; one valid bounded callback returns and commit wins at six seconds | `complete`; detached T replaces S with A's begin observation, so T is one second old. S is not restamped; admission remains denied. |
| Existing S; callback returns an error after one valid page, or returns both data and error | `failed`; no commit, no partial children, S's original markers unchanged and age still increasing; admission denied. |
| Existing S; callback returns wrong-next evidence, or a late page requires more beyond the finite limit | `failed`; retain S and its age; no additional callback, retry or partial success; admission denied. |
| Existing S; cancellation is observed as otherwise valid callback data returns, before commit wins | `cancelled`; S and original age retained. Later completion cannot publish; admission denied. |
| Existing S; commit wins before later cancellation | Original `complete` result remains immutable; T's age uses its original observation, never the cancellation; admission denied. |
| Existing S; close wins while A is completing | `closed`; S remains history with `Current=false`, original age increases, late data cannot commit; admission denied. |
| Existing S under generation A; retirement installs B while A's callback is pending | A is `retired`; S remains historical and ages. Late A cannot release B's slot. Only B's independently complete callback can replace S with its own observation markers; admission denied throughout. |
| No S; missing callback or invalid finite bounds/deadline | No callback and no accepted attempt; inventory remains Unknown, with no invented age or admission. |
| Complete T returned; callback buffers or a caller's detached view later change | Stored T's native evidence and original markers remain unchanged; its age advances normally and admission stays denied. |

## Remaining production work and compatibility

Implement and independently review the cycle signature, finite callback contract,
reader-error terminal path and cancellation/publication ordering against this
acceptance. Review every identity axis independently, including cancellation at
completion, detached pages, wrong-next/late-more rejection, close and retirement.
No runtime test or implementation claim is supplied by this documentary slice.

This family-local offline seam does not replace the future gateway Provider
registry M02 and defines no global provider API, scheduler, transport adapter,
acquisition owner, persistence scheme or automatic admission. Registration,
production acquisition, concrete persistence, connected qualification and hardware
acceptance remain separate work. Existing native trust/admission, eBUS MCP
compatibility, GraphQL parity, deterministic consumer envelopes and G5 D1-D5/O8
remain unchanged; eeBUS output remains driver-owned. No consumer binding or new
authorization gate is introduced.

This contract is an independently mergeable partial slice for
[docs issue #213](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/213).
It advances [registry issue #206](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/206)
and references [registry issue #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201)
without closing either parent. It depends on the merged native/component
contracts above, not on an unmerged cycle implementation or another batch output.
