# Growatt diagnostic commit check implementation

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page describes the offline diagnostic candidate check for the Growatt
`1xSxxP ESS` RS-485 battery family and the exact revision tuple accepted by
the existing decoders. Nothing is stable before Helianthus 1.0.

| Evidence status | Basis and limit |
| --- | --- |
| Proven | The reviewed component checks exact provenance against a frozen successful base before diagnostic decoding; reported offline synthetic tests cover same-context success, provenance fences, complete-bundle rejection, fixed positions, native zeros and detached evidence. This establishes software behavior only. |
| Hypothesis | A later composition owner can use the checker within a serialized atomic commit and retention lifecycle. |
| Unknown | Hardware identity continuity, acquisition simultaneity, freshness budgets, restart persistence and consumer integration are not established. |

Qualification and runtime admission are separate axes that this component does
not change; evidence status establishes neither.

## Native authority

The [battery group retention contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/growatt-battery-group-retention.md)
is the lifecycle authority complemented by this implementation boundary.
The [CC0 native contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/growatt/bms-rs485-1xsxxp-v202.md)
owns register meanings, fixed extents and revision applicability; its native
boundary precedes this application check.

## Reviewed API and implementation boundary

After decoding a complete base with `DecodeGrowattBMSTypedReadOnlyStatus`,
the caller passes it and a `GrowattDiagnosticCommitContext` to
`NewGrowattDiagnosticCommitBase`. The constructor redecodes copied native
slices and freezes them; mutable exported typed fields do not establish success.
Empty tokens, zero epoch or cycle, and a zero base are invalid.

The context contains the successful base-record token, source-instance token,
owner epoch, cycle, selected unit, function, all four revision components and
the raw native continuity tuple: MCU version, BMS company/generation word,
pack company/generation word, full topology word and cell-series count.
Native continuity words must match the decoded base evidence.

`CheckGrowattDiagnosticCommit` takes the frozen `GrowattDiagnosticCommitBase`,
completion context, explicit `expectedReportedGroup` raw word and
`GrowattBMSMultiGroupDiagnosticInput`; it returns a
`GrowattDiagnosticCommitCandidate` and `GrowattDiagnosticCommitRejection`.
It matches the frozen context before running the existing diagnostic decoder.
The expected group word may be zero and is neither a selector nor inferred
pack identity.

An empty rejection string denotes success. The caller must commit the whole
candidate or nothing. `Context()` and `Identity()` preserve the successful base
reference, cycle, epoch, battery ID and reported-group word; `Diagnostic()`
returns a detached typed view and copied raw records.

The caller supplies the provenance and expected group, owns truthful same-cycle
association, and must serialize completion handling and recheck the active
epoch, cycle and base reference before atomic commit. It also owns duplicate
and conflicting results, continuity and cycle closure; success reserves no
cycle and is not valid after its context closes. Inputs must not be mutated
concurrently with the call. Numerical completion deadlines and retry budgets
are Unknown here.

## Retained state and loss states

The checker implements no aggregate store or retained-state lifecycle and
remembers no previous diagnostic identity. The owner must resolve changed
lineage before checking a complete candidate for a new lineage; simply using
the received group word as its expectation establishes no continuity.

| Result | Evidence and fence boundary |
| --- | --- |
| Success | One detached five-record bundle; raw order, source-slice offsets, selected unit, revision, function and words remain intact. Both cell blocks keep all fixed positions; zero cells, group word and native balance remain present values. Blocks are neither summed into aggregate telemetry nor renumbered. |
| `invalid_base` | Missing/zero reference or undecodable base evidence; no candidate. |
| `invalid_context` | Constructor provenance is empty, zero or disagrees with native unit, function or revision; no reference. |
| `context_mismatch` | Different base-record token, source, epoch, cycle, unit, function, revision or other native continuity word; no candidate for this base context. |
| `topology_changed` | Full topology differs, fencing the whole context; this takes precedence over other context differences. |
| `invalid_diagnostic` | Absent, malformed, reordered or otherwise decoder-rejected diagnostic input; no partial bundle. |
| `diagnostic_lineage_changed` | Complete decoded reported-group word differs from the expectation, fencing diagnostic lineage; an otherwise coherent base is not invalidated by this alone. |

Every rejection returns the zero candidate, leaving no sibling, balance or
identity available to commit. If a complete base succeeds but a diagnostic
cell slice is incomplete, its good sibling cannot refresh independently.
An owner with earlier applicable diagnostics must retain the entire earlier
bundle under its original context; this component supplies no such storage.
The retained/current/invalidated lifecycle remains the owner's responsibility,
rather than an output state machine implemented by this checker.

## Synthetic verification

The implementation report states that synthetic tests cover each provenance
axis, complete-bundle rejection, native zeros, fixed positions and detached raw
evidence. It reports initial RED and deliberate failing mutation commands,
followed by a passing final focused suite. These are reported synthetic proof
of software behavior, not device qualification or hardware acceptance.

## Boundaries and remaining acceptance

This component adds no transport, polling, storage, reads, registration,
profile admission, principal/credential/permission check, outbound authority
or consumer-binding behavior. Existing trust and admission checks remain with
their owners. MCP and GraphQL schemas are unchanged; later bindings must
preserve equivalent presence, provenance and rejection meaning. eBUS MCP
compatibility and the driver-owned eeBUS output binding remain unchanged.

This is a partial slice for modbusreg issue #305 and Project #2; parent
acceptance stays open. Downstream composition, atomic storage, independent
review, committed-head gates and hardware acceptance remain outside this
implementation. No hardware acceptance is claimed; documentation review is
neither hardware nor passive-capture evidence.
