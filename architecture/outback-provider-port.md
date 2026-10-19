# OutBack family provider-port composition contract

This Helianthus application architecture proposal is released under
AGPL-3.0-only. Nothing here is stable before Helianthus 1.0.

## Native authority and evidence status

Protocol facts first follow the public native
[source/profile matrix](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/outback/axs-port-source-profile-matrix-v1.md)
and [read-only boundary](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/outback/axs-port-sunspec-readonly-v1.md).
This page adds no protocol mapping. Application retention follows the
[observation lifecycle](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/outback-observation-lifecycle.md),
[detached-record boundary](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/outback-detached-record-implementation.md)
and [offline cycle contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/outback-offline-provider-cycle.md).
The merged [offline holder source](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/outback_offline_provider.go)
is the implementation evidence for the existing API below. The cycle page
contains proposed requirements as well as component evidence; its proposals
must not be mistaken for behavior already enforced by the holder.

| Evidence status | Claim and limit |
| --- | --- |
| Proven from the supplied source | The existing holder accepts a cooperative diagnostic supplier, calls it synchronously once per cycle, fences superseded publication and retains one detached record plus latest status. These are source observations, not newly executed runtime tests. |
| Hypothesis / proposed contract | The I27 family port and configured adapter below restrict composition to that holder, bound overlapping callbacks and add a retained-generation presentation fence. This page specifies acceptance; it does not establish an implemented adapter. |
| Unknown | Unique public applicability, an admitted acquisition operation, common production Provider composition, gateway registration, runtime integration and physical acceptance. |

Evidence status, qualification, structural completeness, association, freshness
and admission remain independent. Every retained record evaluates `NO_GO`;
`TypedFacts()` and `Requests()` remain empty. Admission is explicitly denied
and every write/control path remains `NO_SEND`, even for structurally valid
input. All operations in this port perform zero network/device work.

## Existing API consumed by the proposed port

`NewOutBackOfflineProvider(source OutBackSourceAssociation, maxBytes uint64,
maxWork time.Duration, supplier OutBackDiagnosticSupplier)` returns
`(*OutBackOfflineProvider, error)`. The supplier signature is
`func(context.Context, OutBackOfflineAttempt) (OutBackDetachedRecordInput, error)`.
The native attempt contains `Generation`, `Number` and frozen `Source`.

| Existing method | Source-observed behavior |
| --- | --- |
| `Replace(source OutBackSourceAssociation) error` | Checks source accounting, advances generation even for equal metadata, cancels active work and sets status idle. Keeps record, receipt and actual attempt metadata. |
| `Retire()` | Permanently fences the holder, requests cancellation and sets retired status. Retained evidence remains accessible. |
| `Cycle(ctx context.Context, receivedAt time.Time) error` | Requires a non-nil context and nonzero receipt; calls the supplier once under a work deadline. Checks source equality, constructs a bounded detached record and fences final publication. |
| `Snapshot(current OutBackSourceAssociation) OutBackOfflineSnapshot` | Returns record, `RetainedAt`, `RetainedAttempt`, `LatestAttempt`, status and association. Checks current descriptor and native record association; it does not compare retained generation with current generation. |

The holder rejects zero byte bounds, nonpositive work duration and nil supplier.
Its errors include `ErrOutBackOfflineInput`, `ErrOutBackOfflineAssociation`,
`ErrOutBackOfflineSuperseded`, `ErrOutBackOfflineRetired` and constructor bound
errors. Cancellation/deadline errors produce canceled status; other callback,
association and constructor errors produce failed status. Invalid calls before
an attempt can leave latest status unchanged. Supplier errors are returned but
not stored as arbitrary error text. Retired in-flight completions return
superseded; a later fresh cycle on a retired holder returns retired.

The source can construct a candidate after replacement while a callback was
running; its final fence still prevents publication. It cannot forcibly stop
callback allocations or execution. Native `Cycle` alone also allows overlapping
calls, and native `Snapshot` alone can classify an old receipt as current after
equal-metadata replacement or a change away and back. The proposed adapter
must supply the additional restrictions below without claiming they already
exist in the cycle/component.

## Proposed typed interface and configured adapter

The following Go-shaped declaration specifies the local port. It consumes
already merged native types; it imports no sibling implementation. Every new
identifier, method, helper, fixture and test for this seam uses `I27` or `i27`.
Final API spelling must be reconciled with I27 at code merge.

```go
type I27OutBackProvider interface {
    I27Replace(I27Source OutBackSourceAssociation) error
    I27Refresh(I27Context context.Context, I27ReceivedAt time.Time) error
    I27Retire()
    I27Snapshot(I27Current OutBackSourceAssociation) (OutBackOfflineSnapshot, error)
}

type I27OutBackConfig struct {
    I27Source   OutBackSourceAssociation
    I27MaxBytes uint64
    I27MaxWork  time.Duration
    I27Supplier OutBackDiagnosticSupplier
}

type I27OutBackAdapter struct {
    i27Mu          sync.Mutex
    i27Holder      *OutBackOfflineProvider
    i27Generation  uint64
    i27Busy        bool
    i27LastReceipt time.Time
}

// Proposed constructor signature, not an implemented function body.
func I27NewOutBackAdapter(I27Config I27OutBackConfig) (*I27OutBackAdapter, error)
```

`I27OutBackAdapter` is the proposed concrete implementation of
`I27OutBackProvider`. It privately owns exactly one `OutBackOfflineProvider`,
constructed with the configured source, bounds and supplier. The raw holder is
never exposed or shared; the adapter is pointer-owned and is not copied after
use. Creation imports no record and invokes no supplier. A zero/nil adapter
fails closed: error-returning methods refuse with `I27ErrOutBackInput`, while
`I27Retire` is a no-op. No successful zero-value construction is implied.

`I27Replace` delegates accepted replacements to `Replace`; `I27Refresh` delegates
one accepted invocation to `Cycle`; `I27Retire` delegates to `Retire`;
`I27Snapshot` delegates to `Snapshot` and may only downgrade its association to
`OutBackAssociationHistorical`. It never upgrades a native historical result.
An absent record remains nil/historical, with no invented native unassociated
constant. Existing native APIs are consumed, not renamed or reimplemented.

The adapter maintains a bounded local generation mirror, a single refresh
occupancy flag and last accepted caller receipt. Mirror updates and native
Replace/Retire/Snapshot calls are serialized at the adapter boundary. Refresh
reserves occupancy under that synchronization, then releases it before calling
`Cycle`. No adapter lock spans caller work. Replacement and retirement remain
callable from inside the supplier. Occupancy is released only when that actual
callback/cycle returns, including after retirement or replacement. A concurrent
or reentrant refresh returns `I27ErrOutBackBusy` immediately; it never queues,
spawns work or retries. Replacement does not free callback capacity.

The mirror starts at the native constructor's generation and advances only
when native `Replace` succeeds, including equal-metadata replacement. Refuse
exhaustion before wraparound. On snapshot, require
`RetainedAttempt.Generation` to equal that mirror as well as native current
association. Retirement forces historical presentation. Therefore replacing
with identical metadata, or changing away and back, cannot renew old evidence.
Only a new fenced import can establish a current receipt. Native attempts
remain unchanged; the adapter introduces no synthetic native source identity.

## Bounded inputs, cancellation and refusals

| Input or resource | Required bound and refusal |
| --- | --- |
| Configured source and supplier | Source is an exact opaque `OutBackSourceAssociation`; non-nil supplier is mandatory. Validate source-only input using `NewOutBackDetachedRecord` with the same byte bound before retaining configuration. No default source or fallback descriptor. |
| Record bytes | `I27MaxBytes` is positive, practical and finite. Native accounting includes words, present/missing spans, ordered occurrences, nested words/spans and all source strings before detachment. Accounted bytes are not a heap quota. No allocations for missing extents. |
| Work | `I27MaxWork` is a positive practical finite duration; effective deadline is the earlier of caller cancellation/deadline and native work timeout. The supplier must bound its own work, allocations and result sizes before returning. A timeout cannot preempt non-cooperative Go code. |
| Refresh context and receipt | Reject nil/already-canceled contexts and zero receipts before callback. `I27ReceivedAt` is caller receipt metadata only, never capture time or freshness. The adapter rejects a regressing receipt against the last accepted refresh, including failed attempts; comparisons use one caller-consistent time basis. Snapshot does not compute a freshness age. |
| Replace and snapshot descriptors | Bound all strings via source-only native accounting before comparison or retention. Snapshot bound failure returns an empty snapshot and error, not a guessed current view; it does not erase retained state. Missing/unavailable current evidence is historical; callers must represent conflict as unavailable, never choose one matching descriptor from a conflict. |
| Concurrency and retained state | One live callback at most, one detached record, one native latest-status envelope and constant-sized adapter metadata. No queue, retry, closure history, raw failed-input log or error-string persistence. Old record and temporary constructor candidate can coexist within the configured practical work/memory budget. |
| Counters and lifecycle | Native attempt/generation exhaustion and adapter mirror exhaustion refuse before reuse. Retirement is permanent and idempotent; accepted replacement cannot revive it. |

`I27ErrOutBackInput` and `I27ErrOutBackBusy` are proposed wrapper refusals;
the wrapper otherwise preserves native errors and context cancellation.
Refusal before delegation leaves native latest status and retained state
unchanged. Method return error and latest native status are separate signals.
Invalid source replacement likewise preserves the prior configuration.
Arbitrary supplier error text must not enter a public status projection.

The configured supplier returns only supplied opaque diagnostic input. It must
leave returned buffers untouched until refresh returns. On error, its returned
input is ignored. On success, all source axes must equal the frozen attempt;
no relabeling or replacement-source stamping is permitted. Native construction
detaches mutable buffers; snapshot readers use native copying accessors.
Cancellation observed before final publication wins over success or supplier
error. Replacement/retirement fence late success and late failure alike; a late
callback cannot overwrite a newer status. Cancellation after publication does
not undo the published record. There is no separate cancel API: callers cancel
their refresh context, or replace/retire the holder.

## Synthetic lifecycle and loss table

These are manual acceptance examples, not executed adapter tests or device
observations. `i27A` and `i27B` denote synthetic exact descriptors, and `i27g1`
and `i27g2` local generations. Receipt order is logical only. Every row retains
denied admission, `NO_GO`, empty typed facts/requests and `NO_SEND`.

| Event / sequence | Required view and deliberate loss |
| --- | --- |
| Create with bounded i27A and supplier | Idle, nil record, historical association; zero callbacks. Nil supplier, zero bounds or oversized source fail creation. |
| First complete i27A import in i27g1 | Imported status, original detached record and receipt. Current only if source available, native comparison current and retained generation matches. No qualification. |
| Empty slot receives bounded partial or malformed input | Incomplete status; retain exact supplied words, spans and ordered occurrences diagnostically. No padding, truncation, repair, deduplication or occurrence selection. |
| Complete i27A followed by same-source incomplete result | Earlier complete record and receipt remain; latest status incomplete, fragment discarded. A partial record can instead replace an earlier partial record. This preserves partial last-known-good state without claiming a typed view. |
| Same-source supplier returns input plus error | Discard returned input, retain record/receipt and current association where still eligible; latest failed. No automatic retry. |
| Supplier result exceeds byte bound | Constructor refuses, latest failed, prior record/receipt intact. Capacity check after return does not bound callback allocations. |
| Cancel context before refresh / during callback | Before refresh: no invocation, no native status change. During callback: cooperative cancellation; final canceled status if still current, old record retained. Late input never commits. |
| Supplier replaces i27A with i27B during callback | Successful replacement sets idle and i27g2, original i27A history becomes historical. Old callback returns superseded and cannot change status. A second refresh is busy until it returns. |
| Supplier retires during callback | Retired status, historical retained record, old completion superseded; subsequent refresh refused as retired. No deadlock and no revival. |
| Replace i27A with equal i27A, or i27A → i27B → i27A | Old record remains historical despite native metadata equality. Only a fresh accepted import in the final generation can become current. |
| Snapshot after failure, retirement or caller-view mutation | Original record/source/receipt remain detached. Snapshot reads do not renew receipt. No history list or durable storage is implied. |
| New complete replacement-source import | Replaces the one retained slot atomically with its own original source and receipt; prior record is evicted from the adapter. Previously returned detached views stay unchanged. |

## Synthetic identity table

Start with retained available `i27A` and an otherwise identical current
descriptor in the same generation. Change exactly one field per row while
keeping words and every other field equal. Repeat each mismatch as a supplier
return against frozen `i27A`: it must return native association error, retain
the old record and report failed. These are required future test vectors and
reasoned mutation mappings, not executed mutation kills.

| Independent axis | Synthetic variant | Required distinction / production mutation to catch |
| --- | --- | --- |
| `Key` | `i27keyA` → `i27keyB` | Historical; dropping key equality must fail this vector. |
| `Revision` | `i27revA` → `i27revB` | Historical; dropping revision equality must fail this vector. |
| `PublicLocator` | Public matrix link → public read-only-boundary link above | Historical despite same content declaration; dropping locator equality must fail this vector. |
| `ContentIdentity` | `i27contentA` → `i27contentB` | Historical despite equal locator; dropping content equality must fail this vector. Opaque labels are not verified digests. |
| `DeclaredLayout` | `i27layoutA` → `i27layoutB` | Historical; dropping layout equality must fail this vector. Never reinterpret retained words. |
| `SourceSetRevision` | `i27setA` → `i27setB` | Historical; dropping source-set equality must fail this vector. |
| `SelectorInputs` | `i27selectorA` → `i27selectorB` | Historical; dropping selector equality must fail this vector. |
| `Available` | Current true → false; separately original false with current true, then both false | Historical in each case; dropping declaration equality must fail the first two supplier-conflict vectors, while dropping either-side availability checks must fail the corresponding snapshot vector. Both false can match supplier declarations but never become current. |

Additionally, equal descriptors across generations must stay historical;
removing the adapter retained-generation check must fail that vector. Missing
and conflicting current evidence remain historical even if one candidate
matches. No word equality, completeness or field omission supplies source
identity. None of these comparisons verifies public source contents.

## Composition boundary and remaining acceptance

This local family port supplies no polling plan, hard-coded register span,
decoder, transport request, socket, device access, acquisition, background
scheduler, native qualification or registration. It is neither the common
production Provider interface nor the M02 gateway registry. No sibling code
or unmerged file is a prerequisite. No authentication or authorization gate
is introduced. G5 D1–D5/O8 remain unchanged; eBUS MCP
compatibility and GraphQL parity are preserved as constraints without claiming
integration tests. eeBUS output remains owned by helianthus-eebusreg.

This is the contract slice for
[docs-modbus issue #232](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/232)
and a partial contribution to
[modbusreg issue #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201);
the parent remains open. The companion can merge first and has no special
merge hold. Ordinary review and applicable gates still apply. Implementation
API reconciliation, independent identity/transition tests, committed-head CI,
common Provider and gateway composition, runtime integration, transport,
consumer parity and physical acceptance remain unestablished by this page.
