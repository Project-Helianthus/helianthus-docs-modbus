# SmartLogger local provider-port composition contract

This Helianthus application architecture guidance is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This is the independent I17 composition contract for the Huawei SmartLogger
family. It specifies a typed local port and a concrete lifecycle adapter over
`NewSmartloggerOfflineProvider`. It adds ownership of explicit refresh calls;
inventory parsing, pagination, cycle execution and inventory retention stay with
the existing native components. It is not the common production `Provider`
interface or the M02 gateway registry.

| Evidence label | Claim and limit |
| --- | --- |
| Proven | The supplied merged source exposes `NewSmartloggerOfflineProvider`, `Cycle`, `LastComplete`, `Close` and `Retire` over native inventory types. The component contract documents detached history and exact publication fences. This is source evidence, not execution evidence from this page. |
| Hypothesis | The I17 interface, adapter and transitions below are proposed implementation acceptance. Reconcile final spelling and behavior with I17 at code merge; no I17 implementation or sibling output is a dependency of this page. |
| Unknown | Connected identity, acquisition provenance, production composition, persistence, runtime integration, qualification and physical acceptance remain unestablished. |

Evidence labels are separate from qualification, freshness and admission.
`DefaultDenied()` stays true, including after inventory completion. Denied
admission and `NO_GO` remain unchanged; inventory completion is not native
qualification, profile admission, registration or child capability promotion.
Nothing is stable before Helianthus 1.0.

## Native authority and source boundary

The [native lifecycle contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/smartlogger-provider-lifecycle-v1.md)
is authoritative first, with its linked
[read-only evidence](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md)
and [qualification bounds](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/qualification-readiness-v1.md).
This page adds no protocol fact, read recipe or wire operation.

The [merged offline provider source](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/smartlogger_offline_provider.go)
establishes the consumed API. The
[cycle contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/smartlogger-offline-provider-cycle.md)
records earlier proposed acceptance, while the
[inventory commit component](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/smartlogger-inventory-commit-implementation.md)
owns publication and retention. The cycle page still labels implementation
details as proposed: do not infer those details from its prose when the supplied
source differs. In particular, the reader has no context parameter, caller
cancellation is checked after its synchronous return, reader errors are returned
unchanged, and deadline expiry is not necessarily a `cancelled` outcome.

## Proposed typed port and concrete adapter

These Go declarations specify proposed API shape in the registry package; they
are not a declaration that these symbols already exist. Every new symbol uses
the I17/i17 prefix. Existing native names are consumed unchanged.

```go
type I17SmartloggerProviderPort interface {
    I17Refresh(i17Context context.Context, i17Deadline time.Time) (SmartloggerInventoryResult, error)
    I17LastComplete() (SmartloggerInventorySnapshot, bool)
    I17Close()
    I17Retire(i17Successor SmartloggerInventoryContext) error
}

type I17SmartloggerProviderAdapter struct {
    i17Mu      sync.Mutex
    i17Native  *SmartloggerOfflineProvider
    i17Limits  SmartloggerOfflineInventoryLimits
    i17Busy    bool
    i17Closed  bool
    i17Retired bool
}

// Proposed constructor signature, not an implemented function declaration.
// I17NewSmartloggerProviderAdapter(
//     i17Identity SmartloggerInventoryContext,
//     i17Limits SmartloggerOfflineInventoryLimits,
//     i17Clock func() time.Time,
//     i17Reader SmartloggerOfflineInventoryReader,
// ) (*I17SmartloggerProviderAdapter, error)
```

`I17SmartloggerProviderAdapter` is the concrete implementation of
`I17SmartloggerProviderPort`. Keep interface and adapter together in the
implementation's new I17 file, without importing an I sibling. The constructor
validates fixed bounds and calls `NewSmartloggerOfflineProvider` exactly once.
On error it returns no usable adapter. Store limits by value and give the native
constructor the supplied identity by value; never retain caller pointers to
mutable configuration. The reader and clock function choices are fixed for the
instance. A nil clock retains the native `time.Now` convention. An injected
clock must remain monotonic and nonblocking; freezing the function does not
freeze time or make mutable closure state safe. Reader buffers must remain
stable during validation and copying. Do not copy an adapter or native owner.
Nil and zero adapters refuse refresh and retirement, expose no history and
allow harmless close; they never construct a native owner lazily.

The concrete method algorithms are:

1. `I17Refresh` takes the short lifecycle mutex, rejects nil/zero, closed,
   retired or busy state, claims `i17Busy`, and releases the mutex. It calls
   `i17Native.Cycle(i17Context, i17Deadline, i17Limits)` once and returns its
   native result and error without fabricating a terminal result. On return,
   release only this refresh's busy slot, without clearing terminal flags.
   Concurrent refresh refuses immediately, with no queue or deferred retry.
2. `I17LastComplete` delegates directly to `i17Native.LastComplete()`. It
   exposes the detached native snapshot and presence bit even after retirement
   or close. It stores no second inventory cache and performs no refresh.
3. `I17Close` serializes with lifecycle admission, sets the permanent closed
   flag and calls native `Close()` before releasing that mutex. Repeated close
   succeeds without new work. It must be callable while the reader is pending.
4. `I17Retire` serializes with lifecycle admission. For an open adapter it calls
   native `Retire(i17Successor)` under that short mutex. Invalid or non-newer
   context returns the native error without changing adapter state. A successful
   call sets the permanent retired flag before releasing the mutex. This adapter
   accepts no successor refresh; a successor requires its own newly constructed
   adapter. Closed or already retired adapters refuse retirement.

Native `Retire` installs a successor context inside its owner. That existing
component behavior is distinct from this wrapper's terminal retirement policy.
Delegating it preserves native active-attempt fencing and historical
`Current=false`; the wrapper must not expose the resulting internal successor
as a mutable port context. Close after retirement may still close that owner.

Never hold the lifecycle mutex during `Cycle` or caller code. Close or retirement
that wins before native `Begin` causes refusal; if `Begin` already won, the
native publication fence decides the immutable terminal outcome. Busy ownership
lasts until the synchronous call returns, even if its attempt becomes terminal
earlier. No goroutine, poller, scheduler, transport, device access, active
acquisition, registration or background cleanup is introduced.

## Bounded inputs and error semantics

| Input | Bound and owner |
| --- | --- |
| `SmartloggerInventoryContext` | All eight fields below are fixed at creation and native-validated; no wildcard, reconnect inference or relabeling. Retirement's candidate is validated by the native owner and requires a strictly newer generation. |
| `SmartloggerOfflineInventoryLimits` | Positive finite `MaxPages`, `MaxObjects`, `MaxBytes`; reject zero, negative, overflowing or above-native bounds at creation. No unlimited defaults or later mutation. Use the merged cycle's limit validation semantics, including count-object accounting, without widening the parser's independent ceilings. |
| `i17Reader` | Nonnil synchronous callback, at most once per accepted cycle and zero calls on refusal. Consumes supplied records only, bounds materialization before allocating/copying, cooperates with the plan deadline and performs zero network/device work. No retry or fallback. |
| `i17Clock` | Fixed function; nil uses native default, injected function is monotonic and nonblocking, including calls under the native publication lock. |
| `i17Context` | Nonnil caller context; pre-cancelled work is refused. Its earlier deadline narrows the supplied absolute deadline. It cannot mutate the fixed inventory context. |
| `i17Deadline` | Finite absolute deadline strictly after begin and no later than fifteen seconds after begin, shortened by an earlier caller deadline. Never extend it; equality at publication is expired. |
| Returned native input | Counter-before, finite pages and counter-after remain the original native input; objects include the count object and bytes include two framing bytes per object as counted by the cycle. The native parser still enforces coherent counters, self evidence, continuation, ordering, counts and child limits. |

The native contract's simultaneous ceilings are fifteen seconds, 248 pages,
248 objects, 65536 response bytes and 247 children. Caller limits can narrow
work; satisfying their arithmetic cannot override native parser rejection. The
cycle's object-limit validation includes a count-object allowance in its source
expression; do not turn it into permission to exceed the native inventory
contract. Final constructor validation must agree with the consumed cycle API
and native accounting at implementation review. There is no separate invented
child-limit field in `SmartloggerOfflineInventoryLimits`.

Preserve the native refusal/accepted-attempt distinction: input, busy or terminal
refusal returns a zero result and error, not an invented failed observation.
Reader error, error plus data, incomplete input or exceeded bounds publishes no
inventory; the cycle uses an empty-input commit to terminate failure and retain
history. Preserve a reader's error unchanged and require it to be safe to retain.
Native validation failures have coarse errors; do not invent response details.

After reader return, explicit `context.Canceled` uses native `Cancel`; other
context errors use the cycle's failure path. A prior close/retirement terminal
result stays immutable even when an accompanying error reflects a later reader
or context error. Consumers inspect both outcome and error. The callback has no
context argument and cannot be forcibly interrupted: cancellation is observed
after it returns. Close/retirement can fence publication while it is pending,
but neither proves callback preemption. Do not claim stronger cancellation or
bounded execution for an arbitrary blocking function.

## Synthetic transition and identity acceptance

These are manual acceptance examples with independent expected values, not
executed adapter tests. All example names use i17 prefixes. Use a fake reader,
a controlled monotonic clock and native-valid synthetic records from the native
contract; use opaque local labels and relative elapsed durations only. Each
accepted refresh invokes underlying `Cycle`; each view invokes `LastComplete`.
Every row preserves denied admission, `NO_GO` and zero network/device work.

| Synthetic sequence | Required result and retained view |
| --- | --- |
| i17Empty, then i17Success at elapsed zero | Before success presence is false, inventory Unknown. One coherent fake-reader bracket yields `complete`; detached i17S retains its original plan, native inventory and markers. `DefaultDenied()` remains true. |
| i17Success, then i17Incomplete | Incomplete continuation or counter mismatch yields `failed` and an error; retain all of i17S, with no partial children and no renewed observation marker. |
| i17Success, then i17ReaderError | Error alone and error with otherwise valid data both retain i17S; original reader error survives and the accepted attempt fails unless already terminal. |
| i17Success, then i17Cancelled | Reader cancels caller before returning valid input: `cancelled` with context error; i17S remains unchanged. Pre-cancelled caller instead has zero reader calls and no accepted result. |
| i17Success, then i17Expired | Caller deadline exceeded during callback: no replacement; native failure path or already terminal outcome, not a promised `cancelled` label. Deadline equality cannot publish. |
| i17Pending, then i17Concurrent | Second refresh refuses busy with zero additional reader calls. No queue or second cycle; original slot remains owned until return. |
| i17Success, then i17CloseDuringPending | Close fences pending publication; late return has `closed` if close won before commit. i17S is historical with `Current=false`; later refresh refuses and repeated close is harmless. A commit that won first remains historical `complete`. |
| i17Success, then i17RetireDuringPending | Valid newer successor retires the native attempt; late return has `retired` if retirement won. i17S keeps old context and `Current=false`; this adapter permanently refuses refresh. A new adapter starts without transferred history. |
| i17Success, then i17InvalidRetirement | Invalid or equal/older generation returns error; no retirement flag, no context replacement and no loss of i17S. Open adapter may still refresh. |
| i17Success, then i17MutateView | Mutate returned native bytes, objects and child slices after return; a second view still equals original i17S. Separately mutate fake-reader buffers after completion: same expectation. |
| i17InvalidCreation or i17InvalidDeadline | Bad identity/limits/reader refuses creation; bad per-call deadline refuses before callback. No snapshot is fabricated and no work occurs. |

Vary every `SmartloggerInventoryContext` field independently, keeping all others
unchanged. For native-invalid variants assert constructor rejection; for valid
alternative labels construct a separate adapter and assert exact frozen plan
identity plus unchanged i17S after failures. The mutation column identifies
reasoned production defects these future tests must catch; no mutants were
executed for this documentation slice.

| Field | Independent synthetic variant and expected check | Production mutation to catch |
| --- | --- | --- |
| `OwnerToken` | i17OwnerA → i17OwnerB: separate port plans retain their own opaque owner; empty rejected. | Drop or overwrite owner token on construction/delegation. |
| `ConnectionGeneration` | Positive i17GenerationA → strictly greater i17GenerationB; zero rejected, equal/older retirement rejected. | Drop generation validation/fence or permit non-newer retirement. |
| `RoutingContext` | i17RouteA → i17RouteB: exact opaque label in plan; empty rejected. | Normalize or substitute routing context. |
| `UnitID` | Native logical unit zero → a nonzero synthetic value: construction rejected. | Remove the native unit-zero validation. |
| `ParentProfile` | i17ProfileA → i17ProfileB: exact label preserved, no admission inferred; empty rejected. | Replace parent profile with a default or omit its fence. |
| `SourceRevision` | i17SourceA → i17SourceB: exact source preserved; empty rejected. | Relabel source revision or omit equality. |
| `SelfModel` | Native-valid SmartLogger family predicate → invalid synthetic family: reject; mismatched supplied self entry fails without replacing i17S. | Remove family validation or parsed-self equality. |
| `Firmware` | Each native exact tuple separately, then invalid synthetic tuple: exact preservation or rejection; mismatched supplied self tuple retains i17S. | Add ordered firmware fallback or omit exact equality. |

Also vary native `AttemptToken` and `Deadline` independently in component-level
acceptance: a foreign attempt token and a changed or expired deadline cannot
publish. These are plan fields, not extra inventory-context fields. The public
port never accepts a caller-authored completion plan. Such component mutation
tests belong to the native owner, not a new parser or cycle in this wrapper.

## Retention, projection loss and remaining composition

Only the merged commit owner stores the last complete inventory. Failed,
incomplete or cancelled refreshes retain its entire original evidence, not
partial replacement children. Age advances from original `ObservedAt`; errors
never restamp history. Preserve plan/context, counter/page evidence, native
bytes, children, completion markers and `Current` through the detached view.
`Current` means matching open local owner context only, not freshness,
qualification or connected identity. Without a prior snapshot, presence remains
false and inventory remains Unknown, rather than zero or successful empty data.
Unrelated last-known-good observations remain intact.

The port adds no failed-response store, durable persistence or cross-adapter
history migration. Coarse native errors lose acquisition-stage detail; absence
does not explain why no complete inventory exists. A later semantic projection
must explicitly name any omitted native evidence and must preserve
unknown/zero/false/stale distinctions. No projection is defined here.

This independently mergeable contract addresses
[docs issue #227](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/227),
advances [registry issue #206](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/206)
and supplies a partial slice for
[registry issue #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201).
Neither parent closes; there is no special companion merge hold. Ordinary review
and applicable gates remain. No unmerged code link is current evidence.

Common production Provider composition, gateway integration, connected
qualification and physical acceptance remain separate. Existing eBUS MCP
compatibility, GraphQL parity, deterministic envelopes and G5 D1-D5/O8 are
unchanged. eeBUS output remains in `helianthus-eebusreg`. This page introduces no
authorization gate, namespace or stable API claim.
