# EMMA local provider-port composition contract

This Helianthus application architecture guidance is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.
Nothing is stable before Helianthus 1.0.

## Authority, evidence and scope

The [public Huawei native read-only contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md)
first owns native identity predicates, encoding, extents and family limits.
The [native qualification contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/qualification-readiness-v1.md)
owns missing qualification evidence. This page changes neither contract and
introduces no register mapping, capability inheritance or acquisition recipe.

| Evidence status | Basis and boundary |
| --- | --- |
| Proven, source inspection | The merged [EmmaOfflineProvider source](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/emma_offline_provider.go) has `NewEmmaOfflineProvider`, `SetContext`, `Latest` and `Cycle`. It calls a supplied reader synchronously outside its publication lock, checks finite work/byte bounds, fences completion, and retains identity separately from attempt diagnostics. This is inspected source behavior, not executed integration evidence. |
| Hypothesis, required wrapper behavior | The I19 interface and concrete lifecycle adapter specified below are proposed. Their signatures, cancellation translation, frozen configuration and view publication require implementation agreement and review. No sibling implementation is evidence or a prerequisite here. |
| Unknown | Qualified optional inventory-guard acquisition, live correlation, capabilities, transport behavior and physical acceptance remain unknown. |

The [existing cycle contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/emma-offline-provider-cycle.md)
provides earlier cycle requirements; its proposed API language is not proof that
every requirement is implemented. The merged source establishes the actual
`Cycle` signature. The [identity component boundary](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/emma-identity-transaction-implementation.md)
describes the consumed native value transitions. This new layer owns adapter
lifecycle and views, rather than duplicating either component or cycle.

This is a family-local offline port for future production composition. It is
neither the absent common production `Provider` interface nor the M02 gateway
registry. There is no registration, socket, device, active acquisition,
background scheduler, inventory sender or native qualification. Identity
success leaves admission denied and qualification evidence blocked: overall
production readiness is NO_GO. Network/device work is zero.

## Proposed typed surface and frozen configuration

The following Go-shaped specification consumes existing native API names.
Every new API identifier uses the I19/i19 prefix. Exact spelling must be
reconciled with I19 at code merge; the signatures are contract proposals, not
claims about available exports. The interface and concrete adapter belong in
the same new implementation file, with no import of an I sibling.

```go
type I19EmmaProviderPort interface {
    I19Refresh(i19Refresh I19EmmaRefresh) (EmmaIdentityResult, error)
    I19SetContext(i19Epoch uint64, i19Current EmmaIdentityContext) (uint64, error)
    I19Cancel(i19Refresh I19EmmaRefresh) error
    I19Retire() error
    I19Identity() (EmmaIdentityResult, bool)
    I19RetainedView() EmmaIdentityResult
}

type I19EmmaConfig struct {
    I19InitialContext EmmaIdentityContext
    I19Bounds EmmaOfflineBounds
    I19MaxContextBytes int
    I19MaxErrorBytes int
    I19MaxHorizon time.Duration
    I19Reader EmmaOfflineIdentityReader
    I19Now func() time.Time
}

type I19EmmaRefresh struct {
    I19Epoch uint64
    I19Context EmmaIdentityContext
    I19InventoryRequested bool
}

type I19EmmaAdapter struct { /* private i19-prefixed lifecycle state */ }

func I19NewEmmaAdapter(i19Config I19EmmaConfig) (*I19EmmaAdapter, error)
```

`I19EmmaAdapter` implements `I19EmmaProviderPort` using one privately owned
`*EmmaOfflineProvider`; callers cannot access it. The constructor creates it
with `NewEmmaOfflineProvider` and starts adapter epoch 1. Construction performs
no reader call. It copies validated configuration by value, including bounds
and initial context. Later caller mutation cannot alter it. Functions are
frozen references, not frozen closure storage: their supplier must keep captured
state safe, bounded and offline. The adapter must not be copied after use.

| Bounded input | Validation and ownership |
| --- | --- |
| `I19InitialContext`, refresh context, replacement context | Nonempty `ParentSource` and `SourceRevision`, nonzero `ConnectionGeneration` and `Attempt`, nonzero deadline and caller time; uncancelled for creation/new refresh. Bound the combined context string bytes by positive finite `I19MaxContextBytes` before retaining them. Tokens are opaque metadata, never native device identity. |
| `I19Bounds.MaxReaderWork` | Positive finite caller allowance, passed unchanged to the single cooperative reader; no replenishment, retry or implicit default. A return check cannot bound a noncooperative callback's execution. |
| `I19Bounds.MaxInputBytes` | Positive finite total of `Offering`, `Model`, `Firmware`, `Request` and `Response` bytes, matching the existing cycle accounting. Native limits remain ceilings. Oversize is failure, never a truncated valid tuple. |
| `I19MaxHorizon`, context `Deadline`, `I19Now` | Positive finite horizon and nonnil logical clock. At entry require time strictly before deadline and remaining duration within horizon. Recheck completion through `Cycle`; equality is expired. Clock values must be nonzero and nondecreasing; no new deadline or wall-clock-generated identity. |
| `I19Reader` | Nonnil, injected supplier of already validated FC03 records and independent diagnostic `EmmaMEIStatus`. It must honor deadline/work bounds and leave returned buffers unchanged until `Cycle` returns. No acquisition, guard procedure, inventory parser or extra callback. |
| `I19MaxErrorBytes` | Positive finite ceiling for adapter-retained error text. Return a bounded refusal category and bounded diagnostic text without treating it as native evidence. The supplier must bound error construction; formatting an arbitrary error is not an execution bound. |
| `I19Epoch` and context updates | Nonzero adapter lifecycle epoch, compared independently of native context. Each accepted `I19SetContext` advances it; refuse exhaustion rather than wrap. Reject wrong epoch, stale context and refresh reuse; all context updates and new attempts require new, nonreused native `Attempt` tokens, even when other native fields stay equal. |
| `I19InventoryRequested` | Explicit boolean intent per refresh, frozen before callback. False means `not_requested`; true means `blocked`. `InventoryComplete()` stays false in both cases. It never permits a second callback or sender. |

The adapter keeps one active slot, at most one in-flight refresh, one latest
bounded attempt and one retained identity. A busy refresh fails immediately,
with zero reader calls. No unbounded parent map, task queue or retired archive
is introduced. Context tokens are not reused within an adapter lifecycle;
callers needing a distinct parent create or replace the slot explicitly.

## Lifecycle, cancellation and publication

1. **Create.** Validate the entire frozen configuration and initial context
   before constructing the native provider. Invalid input returns a bounded
   error and no usable adapter. The initial views are empty and denied.
2. **Refresh.** Under adapter synchronization, reject retirement, busy state,
   wrong epoch, invalid/stale context, duplicate attempt or invalid bounds/time.
   Reserve the refresh and freeze its epoch, context and inventory intent.
   Invoke the actual merged `Cycle(context, bounds, inventoryRequested, reader,
   now)` once, with a fake/supplied offline FC03 reader. Do not reproduce its
   evaluator or fabricate a successful result. Neither callback nor arbitrary
   reader work runs under the adapter lifecycle lock.
3. **Cancel.** `I19Cancel` targets the exact reserved epoch/context, including
   parent, revision, connection, attempt and deadline. Under lifecycle
   synchronization mark that refresh cancelled and immediately call
   `SetContext` with a copy of its current native context whose `Cancelled`
   is true. This translates explicit refresh cancellation into the existing
   context fence *before commit*, not into a post-return error alone. A stale
   cancel must refuse without cancelling a successor. Repeated cancellation of
   the same still-reserved refresh is idempotent. Cancellation cannot forcibly
   stop reader code; do not spawn a goroutine to abandon it.
4. **Replace context.** `I19SetContext` compares the expected epoch, validates
   the bounded replacement, advances epoch and calls `SetContext` atomically
   with the adapter state change. A changed parent starts empty history;
   same-parent revision/connection changes may retain old evidence only as
   labelled history. The busy reservation remains until its callback returns.
   Never restore an earlier uncancelled context to let old work commit.
5. **Retire.** `I19Retire` is terminal and idempotent. It marks the current
   native context cancelled through `SetContext`, fences adapter publication
   and invalidates the current-identity flag. All later refresh/update/cancel
   requests refuse. Detached history may still be read; callbacks already in
   flight may finish but cannot resurrect the adapter or replace its view.
6. **Complete.** After `Cycle`, recheck epoch, cancellation and retirement
   under adapter synchronization before exposing a new view. The native
   provider's publication lock orders its own commit against `SetContext`;
   cancellation that wins that lock rejects the native commit. Cancellation
   after native commit cannot undo it retroactively: that completed observation
   may remain history, but current success is suppressed. A retirement that
   wins during the callback instead preserves the pre-refresh published view.
   Keep a detached public view; do not expose the private provider's `Latest`
   blindly. Report lifecycle refusal
   separately from the native result rather than rewriting native reasons.

`Cycle` already normalizes a reader error to `EmmaFC03Failed`, rejects oversized
input and checks the context before/after its callback. A stale completion can
still be stored by its private latest-result path in some same-parent cases;
that does not authorize adapter publication. The adapter's epoch fence and
pre-refresh snapshot therefore remain necessary. The existing source does not
provide an explicit refresh-cancellation method, frozen adapter configuration,
adapter retirement or an adapter single-flight guarantee.

Wrap the injected clock to validate both readings before native commit. An
invalid completion reading must set the native current context cancelled before
returning to `Cycle`; a check only after `Cycle` returns is too late. Bound that
clock callback as well as the reader. A cancelled context stays fenced until
an explicit update with a fresh native attempt token.

Invalid entry leaves both published views untouched. A reader/input failure
within an accepted, still-current refresh publishes bounded attempt diagnostics
and preserves the last valid identity. Unavailable FC03 is not a proven native
mismatch. Preserve the native `Reason()`, FC03 status, `MEIStatus()`, inventory
status, `Committed()` and `InventoryAssociationInvalidated()` independently
from adapter errors. Unsupported diagnostic enum values must be refused rather
than treated as successful identity evidence; no new native reason is invented.

## Identity, retained history and projection loss

`I19Identity` returns a detached successful committed result and true only while
it is the latest successful current refresh under the active epoch/context,
uncancelled, unretired and unexpired at the supplied logical clock. After a
failed refresh or lifecycle change it returns an empty result and false.
`I19RetainedView` returns the detached latest published attempt whose
`RetainedIdentity()` exposes separately labelled history, even after failure
or retirement. Context replacement must invalidate the current flag even when
the native `Latest()` still describes a successful earlier attempt. Neither
view initiates refresh or changes observation time.

History preserves its original `Context()`, `Input()` and `ObservedAt()`.
Failed/partial input stays in `AttemptInput()` and never patches the old tuple
or a future attempt. Native byte-slice accessors provide detached copies;
adapter views must preserve that ownership. On parent replacement, discard
that slot's published history, excluding foreign-parent history from both views.
Retirement preserves only the slot's previously published history. Bounds and
cancellation do not manufacture request/response bytes.

A current-identity boolean loses native failure reasons, raw FC03 evidence,
optional diagnostic status, inventory intent, association invalidation and age.
It is therefore not a substitute for the retained/attempt envelope. Future MCP
and GraphQL projections must expose the same deterministic envelope, explicit
unknowns, age and reasons, with projection loss recorded. Preserve eBUS MCP
compatibility, GraphQL parity and unchanged G5 D1-D5/O8. eeBUS output remains
in `helianthus-eebusreg`. No consumer binding is implemented here.

## Synthetic transitions and independent identity axes

These are manual acceptance cases, not executed tests, parser fixtures or
physical observations. P/Q, R/S, C/D, A/B, E/F and T represent synthetic parent,
revision, connection, attempt, adapter epoch and logical time symbols. A valid
FC03 tuple means one validated against the linked native contract; no model
literal or synthetic reply bytes stand in for that validation.

| Transition using actual `Cycle` with fake FC03 supply | Expected port outcome and retained state |
| --- | --- |
| Create E/P/R/C/A, then fenced valid FC03 with MEI failure | Commit identity at T; diagnostic MEI failure retained. Admission denied, qualification blocked, NO_GO. |
| Next attempt B has missing/failed FC03 but successful MEI | Current identity false; previous identity stays at T with unchanged evidence; B diagnostics remain separate. |
| B returns complete tuple plus reader error, or oversized input | Failed/unavailable, bounded diagnostics, no identity refresh or silent truncation. |
| Valid B requests inventory after prior identity success | Identity may commit; inventory `blocked`, incomplete; zero guard/inventory calls. Omitted inventory stays `not_requested`. |
| Explicit cancellation during callback, followed by valid FC03 | Cancelled native context before commit yields rejection; old identity at T remains history, not current. |
| Retirement during callback, followed by late success/error | No adapter publication, current identity false, old view/history unchanged. Later calls refuse with zero reader calls. |
| Epoch/context replacement during callback; late old completion | Refuse stale adapter publication even if private latest changes. Preserve the replacement slot and any unrelated parent's valid identity. |
| Clock reaches deadline or moves backwards before publication | Refuse current success; do not refresh retained observation or invent capture time. |
| Invalid creation/refresh, busy refresh or stale cancellation | Bounded refusal; zero reader calls for refused refresh; no damage to a valid unrelated slot. |

Each row below changes only that field from an otherwise identical valid
baseline. Required future tests must use independently expected results and
fail the named production mutation; these are reasoned mutation mappings,
not executed mutant kills. For same-parent rejection, the previous valid
identity remains historical at T; a separate Q adapter stays unchanged.

| Independently varied field | Expected result | Production mutation the variant must catch |
| --- | --- | --- |
| `ParentSource` P to Q in current context | Reject P completion; Q gets no P history; unrelated valid Q adapter unchanged | Remove parent fence or import previous-parent history. |
| `SourceRevision` R to S | Reject old completion, retain old revision as history | Omit revision equality. |
| `ConnectionGeneration` C to D | Reject old connection, retain old evidence without refreshing it | Omit connection-generation equality. |
| `Attempt` A to B | Reject superseded completion; do not overwrite newer diagnostics | Omit attempt equality/publication fence. |
| `Deadline` changed, all else equal | Reject changed deadline even if both are future instants | Omit deadline equality. |
| Completion time equals unchanged `Deadline` | Expired, not current identity | Replace strict expiry with an inclusive success boundary. |
| `Cancelled` false to true | Reject before matching | Drop cancellation translation or native cancellation check. |
| Submitted `I19Epoch` E to F with native fields unchanged | Refuse before callback; current native context cannot rescue a wrong wrapper epoch | Remove adapter epoch comparison. |
| `Offering` alone in a valid replacement | Preserve new field; propagate inventory-association invalidation | Omit offering comparison or discard invalidation signal. |
| `Model` alone in a valid native family variant replacement | Preserve variant; invalidate association without inheriting capabilities | Omit model comparison. |
| `Firmware` alone in a valid native replacement | Preserve firmware; invalidate association | Omit firmware comparison. |

Attempt/deadline changes alone do not change native identity association.
Revision, connection or parent changes on a later valid identity replacement
also carry the native invalidation semantics; wrapper slot isolation does not
supply an inventory. Raw request/response bytes must also be independently
mutated in future ownership tests to prove detached preservation, with the
expected bytes fixed before caller/view mutation. No identity field can be
assembled from a previous partial attempt.

## Acceptance and companion disposition

This partial architecture contract addresses
[docs-modbus #228](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/228)
and advances [modbusreg #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201)
and [modbusreg #199](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/199).
It can merge first with no special merge hold and no dependency on an I19 PR or
unmerged file. Reconcile final API spelling and implementation behavior at code
merge. Parents remain open.

Documentation acceptance consists of manual source/API, transition, independent
identity, loss, example and public-link review against the merged anchors.
Future implementation acceptance must exercise actual `Cycle` with a bounded
fake FC03 supplier, every axis independently, cancellation and retirement inside
the callback, late completion isolation, retained history and default denial.
No runtime integration, full CI, transport/smoke, passive acquisition, native
qualification or hardware PASS follows from this document. Independent review,
common production Provider/gateway composition, qualified acquisition and
physical acceptance remain separate work. No authorization gate is introduced.
