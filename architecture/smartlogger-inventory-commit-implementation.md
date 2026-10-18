# SmartLogger inventory commit implementation

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page describes the reviewed supplied-page ownership slice in helianthus-modbusreg PR #307 for the Huawei SmartLogger provider family.

| Evidence status | Claim and limit |
| --- | --- |
| Proven | The reviewed component provides an explicitly invoked offline transaction owner with one active attempt, exact commit fences and detached last-complete access; the reported synthetic verification covers these mechanics. |
| Hypothesis | Later composition can supply a coherent bracket with independently established transport generation and acquisition provenance; this remains design intent. |
| Unknown | Connected identity, live qualification, production acquisition, transport isolation and end-to-end consumer replay are not established. |

Proven, Hypothesis and Unknown are evidence labels, separate from qualification and admission, which this component does not change. Successful mechanics and parsed inventory remain default denied. Nothing is stable before Helianthus 1.0.

## Native authority

The [SmartLogger provider transaction lifecycle native contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/smartlogger-provider-lifecycle-v1.md) and its linked public native sources remain authoritative for encoding, exact self firmware tuples, counter bracketing and parser ceilings. This application page describes the reviewed implementation boundary without widening those protocol facts.

## Reviewed API and implementation boundary

`NewSmartloggerInventoryCommitOwner(context, clock)` creates an explicitly invoked offline, in-memory owner. Construction validates nonempty opaque owner, routing, parent-profile and source context, a nonzero connection generation, logical unit zero, the exact SmartLogger family and a native exact firmware tuple. These caller-supplied values correlate evidence and do not independently prove a connected parent. A nil clock uses `time.Now`; an injected clock must be monotonic and nonblocking and is called under the publication lock. Owners and attempt handles must not be copied; the zero owner refuses attempts.

| API or evidence surface | Reviewed boundary |
| --- | --- |
| `Begin(deadline)` | Freezes context, a unique owner-local attempt token and an absolute caller-supplied deadline strictly after the begin observation and no later than fifteen seconds after it. A second begin returns `ErrSmartloggerInventoryBusy` without replacement or queuing. |
| `SmartloggerInventoryAttempt.Plan()` | Returns a value copy of the frozen plan. |
| `SmartloggerInventoryAttempt.Commit(plan, input)` | Accepts already-collected counter-before, pages and counter-after as `HuaweiSmartLoggerOfflineInventoryInput` for that exact plan. The caller must begin before collection and must not mutate the input during commit. Acquisition timing and transport provenance cannot be attested by this component. |
| Commit identity and fences | Compares owner token, attempt token, connection generation, routing context, logical unit, parent profile, source revision, self family, firmware and deadline. An altered completion fails the attempt. |
| Native validation and publication | Reuses `ParseHuaweiSmartLoggerOfflineInventory` with its native limits and rejection rules and independently validates the self entry's exact family and firmware against the frozen identity. The deadline is rechecked after validation and detachment; reaching it fails. Only then can the complete snapshot replace history atomically. |
| `SmartloggerInventoryResult` | Returns the original plan, terminal outcome and completion marker by value. Each accepted attempt has one immutable terminal result: `complete`, `failed`, `cancelled`, `closed` or `retired`. |
| `LastComplete()` | Returns detached inventory, native counter/page evidence, the frozen plan, original begin observation and successful completion marker. Native bytes, object slices and child slices have no mutable aliases to stored state. |

`Cancel`, `Close`, `Retire` and commit share the publication mutex. `Cancel` fixes a cancelled outcome and releases that attempt's slot; `Close` retires the active attempt and permanently closes the owner. `Retire(newContext)` requires a valid, strictly greater connection generation and retires the active attempt before installing the successor context. A late callback returns its original terminal result and cannot release a successor's slot. Cancellation, closure or retirement after a successful commit does not rewrite that historical success.

## Retained state and loss states

Failure retains the entire previous inventory snapshot and its original observation and completion markers. Age is measured from `ObservedAt`, never from the latest unsuccessful attempt. Counter changes, malformed late pages, invalid self identity and exhaustion cannot publish partial children or renew age. Failure is deliberately coarse: this slice provides no acquisition-stage or failed-response diagnostic store.

| State or loss of authority | Meaning and limit |
| --- | --- |
| Current | `Current` means only that retained context still matches the open owner; it is not connected identity proof. |
| Retained history after generation retirement | The old snapshot remains historical with `Current=false`; only a new complete bracket can replace it. New-generation history alone is not current identity proof. |
| Terminal attempt | Its immutable result remains correlated to its original plan; later callbacks cannot rewrite it or release a successor's slot. |
| Absent inventory | Further absent-state semantics are Unknown in the reviewed API prose. |

Native evidence remains part of the detached snapshot. Runtime retention of potentially sensitive native attributes is separate from public redaction and redistribution.

## Synthetic verification

The PR reports nine focused tests with 22 named subtests covering independent identity axes, late validation, terminal immutability and publication ordering. It reports that fifteen disposable production mutants were caught by assertion failures and that the initial RED compilation failure preceded implementation. These are reported synthetic proof of the reviewed mechanics, not qualification or hardware acceptance.

## Boundaries and remaining acceptance

This component adds no acquisition or production-admission integration, catalog registration, profile admission, child capability promotion, scheduler, transport retry or gateway integration. It introduces no authentication or authorization gate. Existing trust and admission checks, eBUS MCP compatibility, GraphQL parity, G5 D1-D5/O8 and driver ownership of the eeBUS output binding remain unchanged.

This is a partial implementation slice for registry issue #298, with related issues #206 and #201; the parent issues stay open. Qualification, production acquisition and hardware acceptance remain separate, and no hardware acceptance is claimed. Connected identity, transport isolation and end-to-end consumer replay remain Unknown.
