# S-Dongle provider-port composition contract

This application architecture contract is released under AGPL-3.0-only and
complements the CC0 native protocol contract. Nothing is stable before
Helianthus 1.0. The I21 port below is proposed acceptance behavior; this page
adds no executable implementation or claim that its new API is already merged.

## Authority and evidence status

Protocol facts come first from the public
[native gateway contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md).
The [qualification disposition](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/sdongle-qualification-disposition-v1.md)
retains its insufficient-evidence hard stop. This page publishes family-level
composition rules, no new model support, protocol mapping or live-read recipe.
Exact native model and firmware discriminators remain in native records.

| Evidence status | Basis and limit |
| --- | --- |
| Proven | The supplied merged [offline cycle source](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/sdongle_offline_provider.go) exposes `RunSDongleOfflineProvider`, the native request/result/record/bounds and lookup types, one cooperative lookup, cancellation fences, exact returned-plan key association and detached retained evidence. The [component boundary](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/sdongle-route-decision-implementation.md) documents documentary decisions and unconditional denial. |
| Hypothesis | The I21 interface, concrete adapter, bounded owner and retirement transitions below are requirements for future implementation and review. |
| Unknown | Common production Provider composition, gateway registry integration, runtime freshness, actual child capability and physical behavior. |

Qualification, freshness, admission and evidence status are independent axes.
The existing [cycle contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/sdongle-offline-provider-cycle.md)
contains broader proposed acceptance rules; its sequencing prose is not proof
that every proposed bound exists in the native implementation. The
[routing proposal](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/sdongle-provider-routing.md)
supplies native retention and dependency invalidation context.

## Proposed typed port and concrete adapter

The following Go declaration sketch defines this independent contract's API.
All new declarations, methods, fields, helpers and eventual tests use `I21` or
`i21`; names of consumed native APIs are unchanged. Reconcile final spelling
with I21 at code merge. These declarations belong together in the future local
port implementation file, with no import of an I sibling implementation.

```go
type I21SDongleProvider interface {
    I21Refresh(context.Context, time.Time) (I21SDongleView, error)
    I21View() I21SDongleView
    I21Retire() I21SDongleView
}

type I21SDongleConfig struct {
    I21Key         SDongleRouteKey
    I21Bounds      SDongleOfflineBounds
    I21MaxRefreshes uint16
    I21Previous    *SDongleOfflineRecord
}

type I21SDongleView struct {
    I21Key         SDongleRouteKey
    I21Retired     bool
    I21Busy        bool
    I21Attempts    uint16
    I21HasLatest   bool
    I21Latest      SDongleOfflineResult
    I21Failure     I21SDongleFailure
    I21Retained    *SDongleOfflineRecord
}

type I21SDongleFailure string
func (I21SDongleView) I21DefaultDenied() bool // always true

type I21SDongleOfflineProvider struct { /* private i21 state */ }
func I21NewSDongleProvider(I21SDongleConfig, SDongleOfflineLookup) (*I21SDongleOfflineProvider, error)
```

`I21SDongleOfflineProvider` concretely implements `I21SDongleProvider` by
calling `RunSDongleOfflineProvider`; it owns one frozen key, one callback and
one fixed bound configuration. It is a family-local port for future production
composition, not the absent common production `Provider` interface or M02
gateway registry. No socket, device, active acquisition, background scheduler,
registration or native qualification is provided. The owner never calls the
route component separately, looks up a child separately, scans a store for
another family, or infers parent provenance or a decision from a model match.

## Creation and every bounded input

Creation validates and detaches configuration without lookup or evaluation.
A nil callback, incomplete key, invalid limits or malformed previous record
returns an error and no usable owner. It does not manufacture a ready result.
Caller-provided data must remain coherent while being copied; returned views
and subsequent caller mutation cannot change frozen owner state.

| Input | Required bound or validation |
| --- | --- |
| `I21Key` | Complete native key: nonempty family, model, firmware, role, request, scope and revision; every scalar field, including protocol, unit and child context, frozen by exact value. Structural completeness is not qualification. |
| `I21Bounds.LookupTimeout` | Positive and at most 15 seconds; effective cycle deadline is the earlier of this duration and the refresh context deadline. No per-step reset. |
| `I21Bounds.MaxInputBytes` | Positive and at most 1048576 bytes. Native aggregate string-byte accounting covers selected/evidence keys, observation strings, outcome/reasons, four reference revision/reference pairs and additional reference strings. This is not a total Go heap or raw-wire bound. |
| `I21Bounds.MaxReferences` | Positive and at most 256 additional references. Counts and byte limits both apply; fixed reference fields are also byte-accounted. |
| `I21MaxRefreshes` | Positive `uint16`, at most 65535 accepted attempts for the owner's lifetime. Never wraps or resets; exhausted owners refuse further refreshes without lookup. |
| `I21Previous` | Optional single planned native record with nonzero `EvaluatedAt`, fitting the same native byte/reference accounting. May retain a different original key as history; never relabel or treat it as this owner's current decision. No history list or input log. |
| Refresh context and time | Nonnil context and nonzero caller-supplied attempt time. No generated clock, capture time, freshness renewal or evidence-age inference. |
| Callback/store | Exactly one cooperative offline callback on a valid active refresh; caller must pre-bound supplied store size/search/copy work. Native result checks occur after callback return and cannot constrain an arbitrary callback's allocations or force it to terminate. No retry or orphan goroutine. |
| Plan documentary bounds | Preserve `SDongleRouteBounds`: positive deadline at most 15 seconds, explicit `RetryBounded`, finite `MaxRetries` (zero allowed), positive pages, objects and bytes; child maxima remain 121 pages, 121 objects and 32768 bytes. These grant no callback retry authority. |

Only one refresh can be in flight. A second caller receives an I21 busy refusal
without waiting, queuing, spending an attempt or calling lookup. State locking
must not span the callback: retirement and view remain available during a
cooperative call. Accepted attempts consume the finite budget even when the
cycle subsequently fails or is cancelled. Invalid context/time, busy, exhausted
and retired refusals do not consume it. No automatic recreation resets a budget.

## Refresh, errors and retirement

An accepted refresh supplies the frozen key/bounds, caller attempt time and a
detached copy of the single retained record to `RunSDongleOfflineProvider`.
The native cycle validates input before checking cancellation. It checks context
before lookup, after lookup (before accepting either error or plan), and after
decision evaluation. It returns blocked plus an error for invalid input, lookup
failure, oversized results or requested/returned plan-key mismatch. The component
owns evidence-key equality, qualification assertions and documentary precedence;
the wrapper must not claim that every such failure occurs before evaluation.

On completion, publish a detached latest attempt only if the owner has not
retired and cancellation/deadline has not become observable before publication.
If cancellation is observed only by this final wrapper fence, publish a blocked
latest attempt with no decision, retain the prior history unchanged and return
the context error. Serialize the final fence and publication with retirement. A late result must
not overwrite latest or retained state after retirement. Retirement is
idempotent and terminal, cancels the internal active context, fences future
calls immediately, and returns a detached retired view without waiting for an
uncooperative callback. It cannot forcibly interrupt that callback. An in-flight
refresh returns an I21 retirement error when it eventually returns; it cannot
publish its apparent success. If retirement and completion race, the serialized
order decides: a result published first remains historical in the retired view.

`I21Failure` uses a finite I21-prefixed classification vocabulary for none,
invalid input, busy, exhausted, retired, cancelled, deadline, lookup, bounds and
association. These are wrapper diagnostics, not invented native evaluator
reasons. Preserve native returned errors for the invoking caller; do not retain
unbounded arbitrary error strings or error objects in owner state. Concurrent
refusals leave the stored latest attempt unchanged. Native errors that share
`ErrSDongleOfflineInput` may remain in a combined invalid-input/bounds class;
no unsupported precision is inferred. Documentary blocked/denied with no error
retains its native decision, outcome, reason and evaluator reason unchanged.

| Synthetic transition | Lookup count | Stored view after transition |
| --- | --- | --- |
| `i21Create` valid owner | 0 | No latest attempt; optional detached history only; denied admission. |
| `i21Ready` accepted planned cycle | 1 | Latest `ready` with native `planned`; retained replaced by that complete record; `DefaultDenied()` remains true. |
| `i21Denied` next cycle returns `no-send` | 1 | Latest `denied`, original reasons retained; earlier planned history survives; never display retained readiness as latest status. |
| `i21Withheld` coherent lookup but incomplete/stale/conflicting evidence | 1 | Latest `blocked` with `withheld` decision; retain earlier good history under its original key. |
| `i21LookupError` callback returns error and usable-looking plan | 1 | Latest blocked/error classification; discard candidate plan; retain history. |
| `i21Mismatch` returned plan key differs | 1 | Latest blocked/association error without decision; no fallback. |
| `i21CancelledBefore` valid accepted refresh already cancelled | 0 | Consumes one attempt; latest blocked/cancelled, no new decision or retention. |
| `i21CancelledAfter` cancellation during callback or before publication | 1 | Latest blocked/cancelled or deadline; do not publish apparent readiness; history unchanged. |
| `i21Busy` overlapping refresh | 0 additional | Refusal; existing latest/history unchanged; active refresh still owns its attempt. |
| `i21Exhausted` budget spent | 0 | Refusal; preserve latest including denied/blocked status; no budget wrap. |
| `i21RetireIdle` or repeated retirement | 0 | Retired view; latest and history remain detached documentary records, unusable for future refresh. |
| `i21RetireActive` while lookup is running | At most the existing 1 | Immediate retired view; eventual completion is fenced and cannot replace latest/history. |
| `i21RefreshRetired` or invalid caller input | 0 | Error/refusal without a new decision, lookup or retention mutation. |

All rows have zero network/device work. Planned/documentary ready remains
DefaultDenied. Preserve the qualification disposition's denied/`NO_GO` meaning
separately: `NO_GO` is not a new native cycle constant and ready cannot clear
that disposition or restart its stopped run.

## Exact identity and independent synthetic variants

Use a complete conditional synthetic `i21GatewayA` or `i21ChildA`, not a real
model or claim that a qualified child exists. For each row vary only the named
field in returned `Plan.Key` against frozen `I21Key`; repeat independently for
`Evidence.Key`. Expected results are plan association error before evaluation
or component withholding for evidence mismatch, respectively. No lookup for a
second route follows. These are manual acceptance cases, not executed tests.

| Independently varied field | Association defect the eventual variant must catch |
| --- | --- |
| `Family` | Family match omitted or cross-family fallback permitted. |
| `Model` | Native discriminator dropped or replaced by routing family. |
| `Firmware` | Exact firmware equality replaced by prefix/range acceptance. |
| `ProtocolMajor` | Major baseline ignored. |
| `ProtocolMinor` | Minor baseline inferred from major or firmware. |
| `Role` | Child/gateway role inferred from model or unit. |
| `Unit` | Unit ignored or inferred from another route. |
| `Request` | Request class omitted from association. |
| `Scope` | Scope widened or ignored. |
| `Revision` | Revision omitted or old evidence relabelled. |
| `Child.Parent.Family`, `Child.Parent.Model`, `Child.Parent.Firmware` | Three separate variants catch omission of each parent identity field. |
| `Child.Parent.ProtocolMajor`, `Child.Parent.ProtocolMinor` | Two separate variants catch omission of either parent baseline field. |
| `Child.Parent.Role`, `Child.Parent.Unit`, `Child.Parent.Request` | Three separate variants catch substitution of parent role, unit or request. |
| `Child.Parent.Scope`, `Child.Parent.Revision` | Two separate variants catch parent scope or revision association loss. |
| `Child.EvidenceRevision` | Child evidence revision inferred from unchanged parent/model. |
| `Child.Qualification` | Child qualification inherited from gateway readability or parent qualification. |
| `Child.GuardBefore`, `Child.GuardAfter` | Two separate variants catch omission of either inventory guard. |

There are 24 independent scalar variants at each key location, not one variant
changing a parent object wholesale. Also vary `Current`, `Conflict`, observation
identity/baseline, reference revisions and child route-reference distinction
independently against the component contract. A matching model does not supply
parent provenance, child route evidence or qualification. Changing a route key
requires another explicitly created owner; retire the old owner to fence its
in-flight work. No automatic child owner creation or parent lookup is allowed.

## Retained view, partial loss and consumer boundary

The owner stores at most one latest result and one last-known-good native record;
`I21Latest.Retained` and `I21Retained` describe the same historical record but
must be independently detached wherever mutable references escape. All copies,
including `Evidence.References`, are detached across input, internal state and
every view. No accumulating attempt log, per-child map or persistent store is
introduced. Caller archives of older detached views are outside this owner's
bounded memory and must have their own limits.

A later failure replaces the latest attempt, never clears or upgrades history.
`EvaluatedAt` is original local attempt context, not native capture time or
freshness. An old `Current` assertion survives as historical evidence; neither
its presence nor a new view asserts current validity. Retain partial last-known-good
native evidence with original identity, provenance, reasons, guards, revisions
and validity. This wrapper cannot invent missing fragments or merge incomplete
records into a complete planned record. A parent/guard change invalidates
dependent child readiness even when the model is unchanged; independently valid
siblings survive only where independence is demonstrated outside this owner.

A consumer projection must disclose omitted native fields, missing evidence,
stale/unknown status and lost associations while preserving native records
separately. No absent/unknown field becomes numeric zero or false. Equivalent
future consumers must preserve eBUS MCP compatibility and GraphQL parity for
native evidence, reasons, status and loss; this page implements no binding.
eeBUS output remains owned by helianthus-eebusreg. G5 D1-D5/O8 are unchanged.

## Production acquisition boundary

Production acquisition over a supplied read-only session follows the native
[read pacing and production acquisition contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/read-pacing-v1.md)
and reads only the groups of the native
[monitoring contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/monitoring-readonly-v1.md). Both are
authoritative, and this section adds no protocol fact, read recipe, or wire
operation. The mapping onto this port is proposed acceptance (Hypothesis) for
the companion provider of
[modbusreg issue #349](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/349);
admission stays denied.

- **Recorded stop.** No production refresh runs until a same-class run matches
  the whole S-Dongle tuple on one connection generation.
- **Cycle ordering.** One production refresh runs one native cycle: the
  search-sequence guard at the gateway unit, which is also the first request of
  each connection generation and may take one extra attempt, the gateway's
  plant groups once the native contract lists them as observed, then the four
  groups of the child unit.
- **Child isolation.** A failed child read withholds the child for that refresh
  only. A changed or failed guard sends no child read and identifies the child
  again in the next refresh.
- **Retention and loss.** Each group keeps its last complete reading with its
  original age. Planned groups, unconsumed words, battery zero words, and every
  meter value are named losses and are never projected as zero, empty, or
  false.

## Acceptance and companion disposition

Manual source/API, transition, independent identity, loss, example and public-link
review is documentation evidence only. No wrapper tests, mutation kills, runtime
integration, native qualification, transport, smoke or physical PASS is asserted.
Implementation acceptance must verify detachment, single-call counts, finite
budgets, cancellation/retirement races and each independent identity variant.

This partial contract references
[docs-modbus issue #229](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/229)
and advances [modbusreg issue #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201);
it closes neither parent nor the common Provider/gateway composition work.
It consumes merged native anchors only, has no dependency on I21 code or an
unmerged companion, and can merge first with no special merge hold. Ordinary
review and applicable committed checks remain separate acceptance. No new
authorization gate or stable namespace is introduced; any new roadmap work
belongs to 0.11 and later.
