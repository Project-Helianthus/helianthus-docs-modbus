# Growatt aggregate cycle retention implementation

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page describes the reviewed offline aggregate/base retention component for the Growatt battery family in modbusreg PR #313.

| Evidence status | Basis and boundary |
| --- | --- |
| Proven | Source inspection and synthetic tests establish aggregate atomicity, identity/context fencing, explicit deadlines, replacement revisions, detached evidence, bounded storage and failure retention within this component. |
| Hypothesis | A future composition owner can supply coherent cycle context and drive the API at bounded deadlines; integration is not implemented here. |
| Unknown | Hardware cross-cycle continuity, measurement simultaneity, freshness budgets, runtime behavior, persistence and consumer serialization are not established. |

Qualification and admission are separate axes that this component does not change. Nothing is stable before Helianthus 1.0.

## Native authority

The canonical [Growatt battery group retention contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/growatt-battery-group-retention.md) supplies the native/lifecycle authority for this aggregate slice. Its linked CC0 native family contract remains the protocol authority; this component adds no protocol fact, read extent, qualification result or admission rule.

## Reviewed API and implementation boundary

`NewGrowattAggregateRetention(maxCycleTicks)` creates the offline owner with a positive finite maximum completion span. Tick arguments are caller-supplied monotonic logical counters in one consistent unit, with no default freshness policy.

| Operation | Input and output boundary |
| --- | --- |
| `Begin(context, cycle, now, deadline)` | Requires a nonempty opaque source token, positive epoch and cycle, `deadline > now`, and `deadline - now <= maxCycleTicks`. Cycles increase within an epoch; epochs cannot decrease, and a higher epoch permits resetting the cycle counter. A pending predecessor becomes incomplete and is discarded from the latest-attempt slot. |
| `Complete(context, cycle, now, input)` | Requires the exact active context and cycle and complete input for `DecodeGrowattBMSTypedReadOnlyStatus`. Success atomically replaces the typed aggregate and four native slices; decoded native identity must equal the declared cycle identity. |
| `Fail(context, cycle, now)` | Records explicit acquisition failure without replacement content; known coherent continuity permits retention. Repeating the same failed outcome is idempotent. |
| `Advance(now)` | Closes a pending attempt as incomplete when `now >= deadline`; completion or failure at the deadline is too late. |
| `Snapshot()` | Returns detached values and native slices, the latest attempt, applicability state and original last-success metadata; reading does not advance time. |

The caller explicitly drives time and closure; there is no timer, scheduler, transport or polling loop. Without a caller operation, a pending snapshot stays pending. Time cannot move backwards, even across epoch changes on the same instance; a rejected callback for another context or cycle cannot advance the active clock.

`GrowattAggregateContext` carries `SourceInstance`, `OwnerEpoch`, `UnitID`, `Function`, the entire `Revision`, `IdentityKnown` and `Identity`. Revision includes family, file revision, header version and cumulative revision and must match the existing decoder contract. Native identity compares MCU software version, BMS company and generation, pack company and generation, topology and cell-series count field by field. The source token is internal correlation; callers start a newer epoch on owner restart or source replacement.

`IdentityKnown` asserts coherent evidence for every required identity field, including valid zeros; equal telemetry or a readable unit cannot establish it. Failed or partial acquisition cannot establish new continuity. Source tokens are bounded to 128 bytes, MCU version strings to 32 bytes and each revision component to 64 bytes; other context members are fixed-size. Public operations are serialized by an internal mutex; callers must not concurrently mutate input slices while passing them in.

## Retained state and loss states

`GrowattAggregateHistoryLimit` is one last-success record, alongside one latest attempt. A new complete success discards the previous success and increments the replacement revision even for equal values and raw words; a validated zero replaces nonzero. Typed aggregate and all four ordered native slices commit together, preserving opaque words, exact offsets, selected unit and exact revision. Failure cannot update a field, native slice, success tick or success revision; partial words never become replacement data.

| State | Applicable value |
| --- | --- |
| `absent` | No successful value has ever been accepted; no default-filled aggregate. |
| `current` | Complete success in the latest cycle; cycle membership does not establish freshness. |
| `retained` | Applicable earlier success during a pending, failed or incomplete later cycle. |
| `invalidated` | Prior evidence cannot apply; `Value` is nil. |

Changed continuity, unknown identity or contradictory complete native evidence invalidates applicability. A failure or return to an earlier key cannot resurrect invalidated values; only a new complete coherent success restores applicability. Invalidated raw/typed content stays internal until replacement. `SuccessRevision`, `SuccessCycle`, `SuccessTick` and `SuccessContext` retain the original accepted-success meaning, including while invalidated; attempt context, cycle, deadline and `pending`, `success`, `failed` or `incomplete` outcome remain separate.

Identical successful completions for the latest cycle are idempotent without refreshing the success tick. Different headers, offsets, lengths or words conflict and cannot overwrite success; failure after success also conflicts. Failed or incomplete cycles cannot later accept success, and superseded-cycle or old-epoch callbacks are rejected even when values match. Replacement-revision exhaustion fails closed without wrapping. There is no historical query or persistence API; freshness without a separate consumer policy is Unknown.

## Synthetic verification

The PR body reports synthetic tests covering every continuity axis, valid zeros, late/conflicting callbacks and concurrent snapshots. These are synthetic proof within the offline component, not qualification or hardware acceptance. The PR body states no mutation-control result; mutation-control evidence is Unknown.

## Boundaries and remaining acceptance

The component adds no acquisition or consumer binding, registers nothing, opens no transport, schedules no reads, retains no diagnostics and changes no existing decoder. Native status remains observation-only with `OutboundAllowed() == false`; no credential or permission check is added.

MCP and GraphQL bindings are not supplied or changed. Later composition must preserve equivalent presence, record revisions, attempt outcomes and native evidence availability, with explicit projection loss; retained data from a failed attempt must not populate an ordinary native-success response. Existing eBUS MCP compatibility is unchanged, and eeBUS output binding remains driver-owned.

This is a partial implementation toward Project #2: modbusreg issue #304 remains open. Composition and hardware continuity remain unestablished, and no hardware acceptance is claimed. Independent review and full committed-head gates remain separate acceptance steps; offline tests establish no transport, passive-capture, runtime or hardware acceptance.
