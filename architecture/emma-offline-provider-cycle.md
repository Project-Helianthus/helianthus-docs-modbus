# EMMA offline provider-cycle contract

This Helianthus application architecture guidance is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.
Nothing is stable before Helianthus 1.0.

## Authority and evidence status

The [canonical Huawei native read-only contract](../protocols/huawei/gateway-readonly-v1.md)
owns the EMMA identity predicates, native encoding and limits. The separate
[native qualification contract](../protocols/huawei/qualification-readiness-v1.md)
owns qualification and missing capability evidence. Neither is replaced here.
The [provider transaction architecture](emma-provider-transactions.md) supplies
the broader application boundary. The merged
[identity transaction component page](emma-identity-transaction-implementation.md)
describes the existing detached component (ZD), rather than this proposed cycle.

| Status | Basis and limit |
| --- | --- |
| Proven, source inspection | The existing component exposes `NewEmmaIdentityAttempt` and `Commit`, separates attempt evidence from retained identity, and leaves inventory blocked and admission denied. The component page reports synthetic verification; this page does not rerun it. |
| Hypothesis, fixed acceptance requirement | All cycle composition, callback ordering, validation, bounds, ownership and publication behavior below is proposed behavior awaiting implementation evidence and review. No new exported provider API name or exact signature is claimed Proven. |
| Unknown | Qualified inventory-guard acquisition, live correlation, concrete persistence, transport behavior and hardware capabilities remain unknown. |

This is a family-local offline provider seam over supplied native records. It
adds composition around the component, not a global provider API, acquisition
owner, transport adapter or replacement for the future gateway Provider
registry M02. It neither registers a provider nor grants automatic admission.
The contract can merge before its implementation; implementation merge requires
behavior and signature agreement with the reviewed contract. No other proposed
cycle implementation is a prerequisite or current evidence for this page.

## Existing values and proposed cycle inputs

Reuse these component names and meanings without adding native predicates:

| Existing value | Meaning at the cycle boundary |
| --- | --- |
| `EmmaIdentityContext` | `ParentSource`, `SourceRevision`, `ConnectionGeneration`, `Attempt`, `Deadline`, `Cancelled`; opaque caller-owned correlation, never a native identifier or credential. |
| `EmmaIdentityInput` | `Status`, `Offering`, `Model`, `Firmware`, `Request`, `Response`; one supplied FC03 tuple with acquisition status and native evidence. `Model` carries the family variant; examples below use symbols, not model literals. |
| `EmmaFC03Status` | `EmmaFC03Missing`, `EmmaFC03Failed`, `EmmaFC03Complete`; only complete, validated FC03 input can establish a match. |
| `EmmaMEIStatus` | `EmmaMEINotRequested`, `EmmaMEIFailed`, `EmmaMEISucceeded`; optional diagnostics independent of identity. |
| `EmmaIdentityAttempt` | Detached candidate constructed by `NewEmmaIdentityAttempt(context, input, mei, inventoryRequested)`. |
| `EmmaIdentityResult` | Pure result from `attempt.Commit(current, now, previous)`; latest attempt diagnostics plus separately retained history. |

The proposed cycle receives the expected context, explicit inventory-request
selection, finite caller work/input limits and a nonnil injected reader. That
one callback returns `EmmaIdentityInput`, diagnostic `EmmaMEIStatus` and an
explicit error outcome. This describes its semantic shape, not an approved Go
signature. The reader consumes supplied records only; it must not perform wire
requests, register probing, guard acquisition or inventory enumeration. There
is no inventory-reader callback, guard algorithm or inventory-parser invocation.
`inventoryRequested` represents intent only: false yields `not_requested`, true
yields `blocked`, and `InventoryComplete()` remains false in every outcome.

The supplier validates the native target, request/response extents, encoding and
complete tuple against the canonical native contract before claiming
`EmmaFC03Complete`. The cycle does not decode wire data or certify that claim.
Never combine tuple fields or bytes across attempts. Missing responses stay
missing; no synthetic reply bytes may be manufactured to repair an attempt.

## Proposed validation, callback and commit order

1. Validate the whole invocation before calling the reader: nonempty parent and
   revision, nonzero connection generation and attempt, nonzero caller time and
   deadline, time strictly before deadline, no cancellation, positive finite
   work and input bounds, and nonnil callback. Reject a context already replaced
   by the owner. Invalid invocation returns a validation failure, calls the
   reader zero times and leaves retained identity and latest published attempt
   unchanged. It must not panic or supply an unbounded default.
2. Reserve one attempt for that parent and freeze its expected context. The
   owner permits at most one in-flight callback per parent. Invoke the reader
   exactly once for an accepted invocation; no nested retry, MEI fallback,
   inventory call or retry after error. A later invocation has a new attempt
   token and uses the caller's remaining finite work allowance.
3. On callback return, preserve its detached diagnostic evidence and error.
   An error takes precedence over any apparent complete FC03 status: normalize
   the candidate to `EmmaFC03Failed`, retaining supplied fields/bytes only as
   diagnostics within bounds. Missing or failed FC03 with successful MEI stays
   unavailable. MEI failure with complete valid FC03 and no reader error can
   still commit. An unsupported status or oversized return is an input failure,
   never a match; do not truncate it into a valid tuple.
4. Obtain the current context and caller-supplied completion time. Cancellation,
   expiry or replacement wins over callback success or error. Construct a
   detached `NewEmmaIdentityAttempt` with the frozen context and accepted input,
   then use `Commit(current, now, previous)` within the owner's publication
   boundary. Rejected/oversized input uses a bounded failed diagnostic candidate,
   not its oversized buffers. Keep reader/input errors distinct from native
   mismatch in the cycle outcome; do not invent new component reason constants.
5. Serialize current-context inspection, `Commit` and publication against
   disconnect, replacement and a new attempt. Publish only if this is still the
   owner's latest attempt. A late rejected completion may return diagnostics to
   its caller but must not overwrite a newer latest-attempt record or retained
   identity. No callback runs under the publication lock.

The ordering is therefore invocation validation, one callback, bounded result
validation/error handling, then context fence before identity evaluation and
publication. The component's `context_rejected` reason takes precedence at the
commit fence; otherwise unavailable FC03 yields `identity_unavailable`, a
complete native mismatch yields `identity_mismatch`, and a fenced match yields
`identity_committed`. A false `IdentityMatch()` alone does not distinguish
unknown/unavailable identity from a native mismatch: preserve `Reason()` and
acquisition status, together with the cycle error.

## Finite work and detached ownership

The caller must supply finite positive limits for total callback work, total
retained input bytes (including strings and request/response evidence) and
bounded diagnostic errors. Context tokens and error representations also need
finite size limits. Validate limits before callback and enforce returned sizes
before copying into retained storage. Native limits remain ceilings; caller
limits cannot widen them. Deadline equality is expired; neither reader nor
cycle may reset the deadline, replenish work or spin on malformed records.

The callback contract must cooperate with cancellation/deadline and work limits.
A post-return size check alone cannot bound reader allocation or execution.
Do not detach a timed-out callback into an unbounded background task or claim
that the pure component can forcibly stop it. Bounded reader implementation and
owner cancellation behavior require production verification.

The family-local owner keeps at most one retained identity and one latest
attempt per parent, plus the bounded in-flight candidate. Readers, caller
buffers and returned views must not share mutable evidence storage. Freeze
native request/response evidence, decoded fields, status and context before
publication. Retain partial failed-attempt evidence only within the latest
diagnostic record; it cannot fill gaps in retained identity or a future tuple.
Deterministic envelopes preserve field meanings and reason ordering, with no
map-order or wall-clock-generated identifiers. Caller-supplied time is used for
the component transition, not acquisition-time evidence.

Use only that parent's previous `EmmaIdentityResult` as `previous`; never pass
another parent's history to the component. On parent replacement, retire the
old slot and start a separate slot without importing its history. Same-parent
revision or connection changes may keep the single old identity as explicitly
historical until a valid replacement commits. Failed attempts preserve its
original `Context()`, `Input()` and `ObservedAt()`; they neither erase nor
refresh it. Concrete storage/eviction is future work.

## Fence axes and identity replacement

| Axis | Required acceptance behavior |
| --- | --- |
| `ParentSource` | Expected and current must agree. Foreign history is excluded by the owner; replacing a parent cannot transfer or publish its identity into another slot. |
| `SourceRevision` | A changed revision rejects the in-flight completion. Old evidence remains historical with its old revision. |
| `ConnectionGeneration` | Disconnect/reconnect invalidates the old attempt even if revision text is reused; fresh input is required. |
| `Attempt` | Supersession rejects older completion and prevents it replacing the latest attempt. |
| `Deadline` | Compare as instants, including expected/current equality; missing time or deadline, changed deadline, and completion at or beyond deadline reject. |
| `Cancelled` | Cancellation in frozen or current context rejects; an error or late success cannot clear cancellation. |
| `Offering`, `Model`, `Firmware` | Preserve every field independently. A successful replacement changing any one signals `InventoryAssociationInvalidated()`; native matching still comes only from the evaluator. Offering is contextual, not a family discriminator. |

The existing component also signals inventory-association invalidation on a
successful identity replacement changing parent, revision or connection.
Attempt/deadline changes alone do not change identity. The cycle must preserve
this signal without claiming an inventory exists or acquiring one. It neither
stores child data nor promotes an old inventory association.

## Synthetic transition examples

These are manual acceptance examples, not executed tests or device evidence.
P/Q, R/S, C/D, A/B and O/V/F are abstract parent, revision, connection, attempt
and tuple symbols. A valid tuple means one satisfying the linked native
contract; these symbols are not parser fixtures. T and T+delta are logical
commit instants, not capture times. In every row, `DefaultDenied()` is true;
`CatalogRegistered()`, `AutomaticRuntimeAdmission()`, `LiveQualified()`,
`SupportClaim()` and `WriteAuthority()` are false. `Qualification()` remains
evidence blocked, independently of freshness, identity and inventory status.

| Event | Attempt outcome | Retention, age and inventory |
| --- | --- | --- |
| P/R/C/A returns valid O/V/F; MEI fails; fence holds at T | Match and commit, despite optional diagnostic failure | Retain the detached tuple at `ObservedAt=T`; not requested inventory stays incomplete. Admission denied. |
| Later B returns failed or missing FC03 but MEI succeeds at T+delta | Unavailable, no match or commit | Keep A's identity at T, now age delta; record B's bounded partial diagnostics separately. No refresh or admission. |
| B returns complete input plus reader error | Normalize failed; unavailable, no commit | Same retained identity and age; raw evidence does not cancel the error. |
| Valid B with inventory requested | Identity may commit if fenced | Inventory blocked and incomplete; zero inventory-reader calls, guard acquisition Unknown. Only the identity's observation is refreshed. |
| B is cancelled during callback, which returns valid input | Context rejected before matching | A remains at T with age delta; B's rejected diagnostics cannot imply freshness or admission. |
| Revision R becomes S or connection C becomes D before B finishes | Reject old completion | Retain A with its original context and T as historical; no use as current evidence. A new fenced success can replace it. |
| Attempt B supersedes A while A's completion arrives late | Late A cannot publish over B | Current latest attempt and retained observation are unchanged by A, even if A's tuple matches. |
| P is replaced by Q, or a distinct Q has its own slot | Reject P's late publication; Q starts without P history | P history remains retired, not imported; neither Q's age nor its denial flags are changed by P. |
| A later valid success changes only O, V or F | Evaluate the whole new tuple, then commit only if valid and fenced | Any one changed field invalidates the old inventory association; replace identity at the new logical commit time, with admission still denied. |
| Complete tuple is a native mismatch | No commit; explicit mismatch reason | Keep previous identity at T and its increasing age; do not call unavailable input a proven mismatch. |
| Invalid bounds/nil callback at entry, or oversized callback result | Entry: zero calls and no publication; return: input failure, never success | No retained refresh. Oversized evidence is rejected, not silently truncated into complete input. |

## Non-admission and remaining production work

No cycle result changes qualification, support, registration or write authority.
No telemetry or capability is inferred from identity, MEI, retention or inventory
intent. Later MCP and GraphQL projections must use the same committed envelope,
age, reasons and explicit unknown values; preserve eBUS MCP compatibility and
G5 D1-D5/O8. Report projection loss rather than replacing native evidence with
a summary. eeBUS output remains driver-owned.

This partial contract advances
[docs-modbus #214](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/214),
[modbusreg #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201)
and [modbusreg #199](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/199);
the parents remain open. Remaining production work includes reviewed API and
implementation agreement, callback/error/cancellation and every-axis lifecycle
tests, bounded allocation/work evidence, atomic owner publication, registration
discovery, concrete persistence, qualified acquisition, capability and negative
overlap evidence, transport replay, consumer parity and independent review.
Offline composition is not physical qualification. Full runtime and separate
hardware acceptance remain outstanding. No protocol facts, live-read recipe or
authorization gate are introduced here.
