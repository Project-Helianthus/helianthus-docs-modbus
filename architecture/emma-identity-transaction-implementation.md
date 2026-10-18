# EMMA identity transaction implementation boundary

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page describes the reviewed offline identity component for the Huawei EMMA
provider family in modbusreg PR #314, a partial implementation slice for issues
#201 and #199. Nothing is stable before Helianthus 1.0.

| Evidence status | Basis and limit |
| --- | --- |
| Proven | Reported synthetic focused tests establish detached values, independent optional status, context fencing and last valid identity retention; this is offline implementation evidence. |
| Hypothesis | A later coordinator can compose the pure transition within an atomic per-parent publication boundary; that integration is not implemented or tested here. |
| Unknown | Qualified inventory-guard acquisition, live correlation, capabilities and hardware behavior remain unknown. |

Qualification and admission are separate axes that this component does not
change: qualification remains evidence blocked, and admission remains default
denied independently of identity matching. Catalog registration, automatic
runtime admission, live qualification, support claim and write authority remain
false.

## Native authority

The [canonical EMMA provider transaction contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/emma-provider-transactions.md)
defines the evidence boundary and links the native Huawei read-only and
qualification contracts that own native predicates. This companion describes
application API and lifecycle behavior; it adds no native protocol facts.

## Reviewed API and implementation boundary

`NewEmmaIdentityAttempt(context, input, mei, inventoryRequested)` constructs a
detached, immutable `EmmaIdentityAttempt`. Its `EmmaIdentityContext` freezes
`ParentSource`, `SourceRevision`, `ConnectionGeneration`, `Attempt`, `Deadline`
and cancellation; source keys are opaque correlation metadata.

The caller supplies an `EmmaIdentityInput` containing one complete, already
validated FC03 tuple, native request/response evidence and explicit acquisition
status. The caller must validate native target, extents and encoding and must
never assemble a tuple across attempts. The component evaluates decoded fields
with `EvaluateHuaweiEMMAOfflineIdentity`; it performs neither wire decoding nor
acquisition validation. Successful optional MEI cannot rescue missing or failed
FC03 input.

`attempt.Commit(current, now, previous)` returns an `EmmaIdentityResult` as a
pure value transition. The caller supplies time and the deadline; the component
reads no clock. A zero context/attempt, cancellation, absent time, expiry
(including deadline equality), or a difference in parent source, source
revision, connection generation, attempt or deadline rejects replacement;
deadlines are compared as instants. The owning coordinator must serialize
obtaining `current`, calling `Commit` and publishing its result against changes
to that parent's context. This component owns no lock or shared store and
cannot independently guarantee atomic publication.

`IdentityMatch` reports a validated match eligible within the current fence;
`Committed` reports whether this call replaced retained identity. `Reason`
distinguishes context rejection, unavailable FC03, complete mismatch and identity
commit. `AttemptInput` and `AttemptContext` expose diagnostic evidence even on
failure, while `RetainedIdentity` exposes history separately. Returned byte
slices are detached copies.

## Retained state and loss states

| State or outcome | Evidence and retention boundary |
| --- | --- |
| Unavailable or rejected attempt | No current match is established; unavailability or rejection does not prove a native mismatch. |
| Current identity commit | A validated match within the current fence replaces retained identity. |
| Retained identity | History keeps its original context, raw evidence and `ObservedAt` commit time; a later failure neither erases nor refreshes it, nor turns it into a current match. The caller must distinguish history from current availability. |
| Inventory omitted or requested | `InventoryStatus` is `not_requested` when omitted and `blocked` when requested; `InventoryComplete` is always false. `MEIStatus` independently records optional diagnostic outcome. |
| Prior inventory association invalidated | On successful replacement, `InventoryAssociationInvalidated` signals retirement when offering, family variant, firmware, parent source, source revision or connection generation changes. Attempt/deadline changes alone do not change identity. |
| Unknown | Qualified inventory-guard acquisition remains unknown; successful MEI does not establish that procedure. |

No guard-qualified flag, page input, guard read or inventory parser is accepted
by this component. It stores no inventory association or child data; later
composition must consume the invalidation signal.

## Synthetic verification

The component's reported focused tests establish detached values, independent
optional status, context fencing and last valid identity retention. This is
synthetic proof of the offline component, not native qualification or hardware
acceptance. Mutation-control execution and results are Unknown in the reported
verification basis.

## Boundaries and remaining acceptance

This component adds no registration, transport acquisition, scheduling, retry,
gateway integration, consumer binding or authorization gate. MCP and GraphQL
are unchanged; later composition must expose the same committed envelope and
freshness. eBUS MCP compatibility remains unchanged, and eeBUS output binding
stays driver-owned.

This is a partial slice: parent issues #201 and #199 remain open. Remaining
parent acceptance includes coordinator serialization, lifecycle/race validation,
bounded acquisition/retries, qualified inventory acquisition, capability and
negative-overlap evidence, transport replay, consumer parity, independent
review and separate hardware acceptance. No hardware acceptance is claimed.
