# Growatt aggregate offline provider-cycle contract

This Helianthus application architecture contract is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.
Nothing is stable before Helianthus 1.0.

## Authority, scope and evidence status

The [canonical native family contract](../protocols/growatt/bms-rs485-1xsxxp-v202.md)
is the protocol authority for the Growatt `1xSxxP ESS` battery family: exact
revision, complete base input, native identity, opaque words and denied outbound
authority. The [battery group retention contract](growatt-battery-group-retention.md)
defines the broader proposed lifecycle. The merged
[aggregate cycle retention component page](growatt-aggregate-cycle-retention-implementation.md)
(ZD) describes the existing aggregate-only component. These authorities are
distinct: this page adds application composition around that component, not
protocol facts or a rewrite of its group lifecycle.

| Evidence status | Basis and boundary |
| --- | --- |
| Proven by source inspection | The supplied `GrowattAggregateRetention` source provides `Begin`, `Complete`, `Fail`, `Advance` and detached `Snapshot`, with one last success and one latest attempt. The merged component page reports its synthetic component verification; that is not provider-cycle implementation evidence. |
| Hypothesis / proposed acceptance | A family-local offline seam can compose those operations around exactly one injected reader returning supplied native records, under the ordering and bounds below. All new composition behavior on this page is required acceptance, pending implementation evidence and review. |
| Unknown | The new exported signature, implemented callback/cancellation behavior, production integration, persistence, hardware continuity, wall-clock freshness budgets and consumer serialization. |

Evidence status does not establish qualification, freshness, support, promotion
or runtime admission. This contract can merge independently of A30; it consumes
no A30 output. A later code merge must agree with this behavior and reconcile
the reviewed signature. There is no claim that a new provider API exists today,
and no link to a proposed implementation as current evidence.

## Family-local boundary and existing types

The proposed seam accepts caller-supplied `GrowattAggregateContext`, cycle,
logical start/completion ticks and deadline, finite work/input bounds, and one
nonnil offline reader. The reader conceptually returns
`(GrowattBMSReadOnlyInput, error)`. This notation is a behavioral description,
not an approved Go signature. The caller must supply a cancellation signal and
make it observable before invocation and at completion.

The existing native input carries `UnitID`, `Function`, `Revision` and ordered
`Slices` with `Offset` and `Words`. Existing
`DecodeGrowattBMSTypedReadOnlyStatus` produces
`GrowattBMSTypedReadOnlyStatus`; its `NativeObservation()` preserves copied
native evidence. The existing result envelope is `GrowattAggregateSnapshot`,
including `GrowattAggregateAttempt`, applicability, success metadata and an
optional typed `Value`. The composition must reuse that retention owner and
envelope. An operation error is separate from the snapshot: retained content
does not turn an error into native success.

This is an offline provider seam over supplied native records. It opens no RTU
session, registers nothing, owns no acquisition, schedules no diagnostics and
performs no retry. It is not the future gateway Provider registry M02, a global
provider API or a transport adapter. It neither admits FC04 inverter data nor
extends FC03 input, diagnostic admission or outbound authority. There is no
automatic admission or new credential/authorization check.

## Continuity, clocks and finite bounds

The caller establishes the entire context before invocation. Equality means
field-by-field equality, not a telemetry comparison or a fingerprint inferred
by the seam.

| Required axis | Acceptance rule |
| --- | --- |
| `SourceInstance` | Nonempty opaque internal correlation token, at most 128 bytes; never a public installation identifier. A replacement source starts a newer epoch. |
| `OwnerEpoch` | Positive; never decreases. An owner restart starts a newer epoch. |
| `UnitID`, `Function` | Preserve the explicitly selected native unit and exact function. Only the canonical base contract can pass decoding; FC04 is not an alternative. |
| Every `GrowattBMSRevisionTuple` field | Compare `Family`, `FileRevision`, `HeaderVersion`, `CumulativeRevision` independently. Each is bounded to 64 bytes; bounded strings alone do not make a revision supported. |
| `IdentityKnown` | Explicit coherent evidence for every identity member, including valid zeros. False cannot be repaired by a readable unit, default values or partial input. |
| Every `GrowattAggregateIdentity` field | Compare `MCUSoftwareVersion` (at most 32 bytes), `BMSCompany`, `BMSGeneration`, `PackCompany`, `PackGeneration`, `Topology`, `CellSeriesCount` independently. Retain whole native topology evidence; do not infer another pack. |
| Cycle | Positive and strictly increasing within an epoch. A higher epoch permits resetting the cycle counter. Every completion carries the original exact context and cycle. |
| Logical clock and deadline | One monotonic tick domain, including across epochs on the same retention instance. Require `deadline > now` and `deadline - now <= maxCycleTicks`, with positive finite `maxCycleTicks`. Completion at the deadline is already late. |

Before invoking the reader, reject a nil callback, invalid work/input limits,
invalid logical bounds and structurally invalid context. Validate the declared
unit, function and revision against the existing native contract before the
callback; do not use the callback for discovery. Unknown identity remains an
explicit lifecycle condition: `Begin` may invalidate prior applicability, but
the seam must not invoke a reader to establish missing continuity or complete
that cycle as successful. Close that attempt through `Fail` while timely, or
expiry when already late. These are proposed composition checks beyond simply
calling the component constructor.

Finite bounds must cover reader work as well as returned storage. The caller
declares a positive finite work budget and input capacity before invocation;
the callback must honor that budget, deadline and cancellation. No unbounded
queue, wait, retry loop or detached background callback is allowed. The existing
base contract requires four ordered slices totaling 50 words, with its exact
per-slice lengths and offsets. Reject capacity below that complete base before
invoking the reader; a larger budget cannot authorize extra slices or words. Reject over-bound
results before decoding/copying them into retained storage. Do not truncate
them to manufacture a valid base. A bounded error classification must not copy
arbitrary callback messages or payloads into public results.

The logical deadline is not a mechanism for forcibly stopping arbitrary code.
A noncooperative callback cannot be made bounded by this component. Production
acceptance must demonstrate cooperative bounded return; the caller must also
drive `Advance` at closure even when no completion arrives. Reading a snapshot
does not advance logical time or expire an attempt.

## Required callback, error and cancellation order

The following is proposed acceptance for the new seam; it adds no second
retention algorithm.

1. Validate all preconditions that can be checked without calling the reader.
   Preflight rejection invokes it zero times and leaves retention unchanged.
   Cancellation already observed before `Begin` likewise invokes it zero times
   and returns cancellation without creating an attempt.
2. Call `Begin(context, cycle, now, deadline)` on the supplied retention owner.
   A rejected begin invokes the reader zero times. A successful begin replaces
   the latest attempt and fences any pending predecessor; that predecessor
   cannot later commit. There is no historical attempt ledger.
3. After a successful begin, recheck cancellation and coherent known identity.
   If either disallows invocation, close through `Fail` for that exact context
   and cycle (or observe expiry), return the relevant error and a detached
   snapshot. Otherwise invoke the reader exactly once, outside retention's
   internal critical section, without concurrent mutation of supplied slices.
4. On return, first fence the original context/cycle against the active
   attempt. Superseded or old-epoch results are rejected, even if identical to
   current values. They cannot advance the active clock or close its attempt.
   The component's `Complete`/`Fail` fence remains authoritative; a preliminary
   caller check alone is insufficient under replacement.
5. For the still-active attempt, process the supplied completion tick in the
   same monotonic domain. Backward time is an error with no replacement.
   At or after the deadline, closure is `incomplete` through the component's
   time advancement, never success. Cancellation or reader error remains an
   operation error; expiry determines the attempt outcome when both apply.
6. Before a timely commit, check cancellation again. Cancellation wins over a
   simultaneous reader success: discard returned input, call `Fail`, and
   return cancellation. Otherwise a reader error wins over any accompanying
   input: discard that input, call `Fail`, return the reader failure. Neither
   path calls `Complete` or refreshes success metadata. Cancellation observed
   after an accepted commit cannot retroactively undo it; the commit check is
   the required cancellation decision point.
7. For timely, uncancelled, error-free return, enforce input bounds and call
   `Complete` with the original context/cycle and entire native input. A
   pre-decoder bound rejection closes through `Fail`; native validation errors
   from `Complete` follow its failed/invalidation behavior. Never call `Fail`
   after successful `Complete`. Return the operation outcome and detached
   `Snapshot`, preserving any earlier applicable success separately.

`Complete` and `Fail` already validate their callback fence before advancing
time. Do not call unconditional `Advance` with a stale callback's tick first.
The active owner separately drives `Advance` for deadline closure. Duplicate
successful component completions are idempotent only for identical native
input and cannot renew `SuccessTick`; conflicting duplicates reject. A seam
call with an already-used cycle is not permission to invoke the reader again.
Failed, incomplete or superseded cycles cannot later accept success. If a
closure operation itself rejects, expose that failure rather than claiming a
failed or cancelled attempt was recorded. The caller still owes active-cycle
closure; cancellation does not authorize clock fabrication.

## Ownership, replacement and loss

Reuse `GrowattAggregateHistoryLimit == 1`: one aggregate last success and one
latest attempt. Do not add a second last-good cache, ledger or diagnostic bank.
The existing component serializes its operations; composition must preserve
that protection when callbacks overlap or a source is replaced.

A complete coherent success atomically replaces the typed aggregate and all
four native slices, including opaque words, offsets, selected unit and exact
revision. It increments `SuccessRevision` even when all values are equal, and
sets `SuccessCycle`, `SuccessTick` and `SuccessContext` to that accepted success.
A present validated zero replaces nonzero. A partial/default-filled input,
missing slice or typed-decoder error cannot merge any field into old evidence.
Revision exhaustion fails closed rather than wrapping.

With coherent unchanged caller continuity, failure or incompleteness preserves
the earlier aggregate and native evidence as `retained`; with no success the
view remains `absent`, never fabricated zero. Changed context, unknown identity
or contradictory complete native identity makes prior content inapplicable.
An `invalidated` snapshot exposes no `Value`, while original success metadata
keeps its original meaning. Returning to an old key or recording failure cannot
resurrect it; only a new complete coherent success restores applicability.
Partial/error input cannot establish new continuity. Nonempty native headers
contradicting the declared context are not merely a telemetry failure; preserve
the component's fail-closed invalidation.

Snapshots detach typed and raw storage. The callback/caller must not mutate
input during handoff; no mutable reader buffer may escape as retained evidence.
Failure, cancellation, lateness, snapshot reads and identical retransmission
cannot renew last-success time or revision. Age is measured from the original
`SuccessTick` in the caller's logical domain. `current` means latest-cycle
membership, not freshness; freshness remains Unknown without separate policy.

## Synthetic transition examples

These are invented family-level logical ticks and cycles, not captures or
qualification fixtures. A complete input below always means the entire native
base contract, coherent declared revision/identity and all four slices. Each
row starts from the explicitly stated prior state; no partial payload is a
successful fixture. Outbound authority stays denied in every row.

| Case | Prior state and operation | Required view and age |
| --- | --- | --- |
| Success | No earlier success; cycle 1 begins at tick 10, deadline 20; complete reader input returns at 12 | `current`, success revision 1, cycle 1, tick 12. Native `OutboundAllowed() == false`; no runtime admission. |
| Reader failure | Prior success at tick 12; cycle 2 begins at 21, deadline 30; reader returns input plus error at 24 | Ignore supplied input; `failed`, `retained`, same success revision/cycle/tick. Logical age 12 at tick 24, admission still denied. |
| Partial base | Same prior success; timely reader returns only part of the base with no reader error | `Complete` rejects; no partial replacement or success tick renewal. Retained value is available only under coherent unchanged continuity, not as a successful native response. |
| Valid zero replacement | Same prior success; cycle 2 complete coherent input at tick 24 contains validated zero current | Atomic replacement, revision 2, cycle 2, tick 24; zero remains present with its native evidence. It grants no qualification or admission. |
| Cancellation | Same prior success; cycle 2 begins at 21; cancellation is observed after reader return at 24, before commit | Discard returned success; `Fail` leaves prior success at tick 12, age 12, `retained`, denied admission. Cancellation before begin would create no cycle. |
| Expiry / late completion | Same prior success; cycle 2 deadline 30; owner advances to 30; input returns at 31 | `incomplete`, prior success tick 12, age 19 at 31. Late completion cannot restore success; admission denied. |
| Supersession | Same prior success; cycle 3 supersedes pending cycle 2; cycle 2 returns with a later tick | Reject cycle 2 without advancing cycle 3's clock or outcome. Retained age still derives from tick 12; no admission change. |
| Source replacement | Same prior success; newer epoch with a different synthetic source token begins; reader fails or is cancelled | Prior content is `invalidated`, no applicable `Value`; success metadata still names tick 12. Same numerical telemetry or return to the old key cannot revive it. New complete coherent success is required; even then admission stays denied. |
| Identity unavailable / contradiction | Same prior success; next context has `IdentityKnown == false`, or complete native evidence contradicts any declared identity field | Unknown continuity invokes no reader; contradictory complete input cannot commit. Prior value is inapplicable, with its original success metadata, never relabelled fresh or admitted. |

## Consumer boundary and remaining production work

Retained evidence from failure or cancellation must not fill an ordinary native
success response. Future deterministic envelopes must preserve equivalent MCP
and GraphQL presence, attempt outcomes, success revisions/cycles/ticks,
applicability and native evidence availability. Document every projection loss;
do not silently flatten retained data into fresh telemetry. This page supplies
neither binding nor schema, changes no eBUS MCP compatibility and leaves eeBUS
output driver-owned. Gateway G5 D1–D5/O8 obligations remain unchanged.

This is a partial contract for issue #218 toward Project #2, Connect all drivers
and native acquisition into the gateway composition; it does not close that
parent. Remaining production work includes review of the exact API, code
agreement with this contract, bounded/cancellation behavior and concurrency
tests across every listed identity axis, detached ownership and deterministic
envelope/parity evidence. Future M02 registration, concrete persistence,
transport ownership and live qualification are outside this slice.

Manual source, claim, transition, loss, example and offline link review can
accept the documentation boundary. Full committed-head gates and independent
review remain required. No runtime, transport, passive-capture, physical or
hardware acceptance follows from this offline contract.
