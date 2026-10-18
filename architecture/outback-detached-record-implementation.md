# OutBack detached record implementation boundary

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page describes the reviewed offline component in
[helianthus-modbusreg PR #312](https://github.com/Project-Helianthus/helianthus-modbusreg/pull/312)
for caller-supplied opaque OutBack AXS Port family observations.
Nothing is stable before Helianthus 1.0.

| Evidence status | Boundary |
| --- | --- |
| Proven | The reviewed component retains one bounded immutable diagnostic record with detached raw words, ordered occurrences, present/missing spans and original source metadata; evaluation remains `NO_GO` with zero typed facts and zero requests. This is component evidence, not device qualification. |
| Hypothesis | Later composition could use these records as diagnostic inputs for a retention lifecycle; this component does not establish that lifecycle. |
| Unknown | Unique public applicability evidence and a qualified read operation remain unestablished. |

Qualification and runtime admission are separate axes that this component does
not change; equal payloads, structural completeness and matching declared
geometry establish neither source qualification nor profile admission.

## Native authority

The [canonical observation lifecycle](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/outback-observation-lifecycle.md)
is the application contract and identifies the native authorities that take
precedence: the
[source/profile matrix](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/outback/axs-port-source-profile-matrix-v1.md)
and the
[native read-only boundary](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/outback/axs-port-sunspec-readonly-v1.md).
This implementation companion does not change those native contracts.

## Reviewed API and implementation boundary

`NewOutBackDetachedRecord(input, maxBytes)` takes an
`OutBackDetachedRecordInput` and a positive finite `uint64` byte bound for one
record, returning an `*OutBackDetachedRecord` and an error.
The input contains `Words`, `DeclaredWords`, `Present`, `Missing`,
`Occurrences` and `Source` supplied by the caller.
The whole input is checked before copying; zero or insufficient bounds return
`nil, ErrOutBackDetachedRecordBound`, with no partial receipt or replacement.

`AccountedBytes()` exposes deterministic evidence-byte accounting, including
nested words, spans, occurrences and source strings; it is neither exact Go heap
usage nor a durable serialization format.
Callers must choose a practical bound; accepting every representable bound under
available memory is not guaranteed.

`RawWords()`, `PresentSpans()`, `MissingSpans()` and `Occurrences()` return
copies of mutable buffers, including nested occurrence buffers;
`DeclaredWords()` and `SourceAssociation()` return values.
Occurrence `WireKey` retains the native identifier and declared payload length,
while `Ordinal` and slice order are preserved independently without renumbering.
Occurrence `Offset` is a logical payload offset within the record, not a
transport address; span coordinates are relative to the enclosing raw record or
occurrence payload.

`OutBackSourceAssociation` retains source key, revision, public locator, content
identity, declared layout, source-set revision, selector inputs and availability.
Its strings are opaque exact values supplied by the caller, without source
verification or admission.
`Association(current)` compares every association axis without rewriting the
original; it is a pure comparison, not concurrent publication fencing.

`Evaluate()` returns the existing inert OutBack flavor decision;
`TypedFacts()` and `Requests()` remain empty, including for nil and zero records.
Every evaluation is `NO_GO`, including complete candidate geometries
64110/282, 64110/420, 64111/23 and 64111/26; identifier 64111 remains opaque.
These are native block identifiers and lengths, not device model claims.

## Retained state and loss states

Raw words remain exactly the supplied sequence, with duplicates, ordered
occurrences and incomplete extents preserved without padding or deduplication.
`Complete()` describes structural coverage only: nonempty ordered contiguous
present coverage must match the supplied and declared extent, without missing
spans, and each occurrence must have matching payload extent and fit in the
record.
Gaps, overlaps, out-of-range extents and empty records remain incomplete;
malformed spans are retained diagnostically without triggering reads.
Completeness verifies neither wire provenance nor source contents, headers,
layout or applicability.

| State or loss boundary | Reviewed behavior |
| --- | --- |
| Absent / failed construction | Failed construction returns no record and touches no store or previous record, including any previously retained complete evidence. |
| Retained | Successful construction retains detached evidence with its original association; missing words are never allocated and unavailable string metadata remains empty rather than guessed. |
| Current association | All association fields match and both original and current descriptors are available; `current` still does not imply admission. |
| Historical association | Any independent association-field change, an unavailable source or a zero record yields `historical`, without relabelling the original evidence. Equal payloads with different descriptors remain distinct records. |
| Invalidated interpreted view | Transaction fencing, concurrent source-set replacement and publication invalidation are outside this component; no interpreted view is added. |
| Unknown | A retention policy, capacity eviction and durable persistence are not established by this component. |

## Synthetic verification

Test execution results and mutation-control outcomes are **Unknown** from the
PR body: it reports neither a test execution result nor a mutation-control result.
The reported record and evaluation behavior is a synthetic proof boundary,
not qualification, device support or hardware acceptance.
This page claims no newly executed component test or live smoke result.

## Boundaries and remaining acceptance

This slice adds no retention store, provider lifecycle, decoder, profile,
registry registration, scheduler, transport, admission, transaction fencing,
capacity eviction, durable persistence or consumer integration.
It introduces no authentication or authorization gate.
Existing eBUS MCP compatibility, GraphQL parity and driver-owned eeBUS binding
remain unchanged; no consumer integration or parity acceptance is claimed.

This is the documentation companion for modbusreg PR #312 and a partial slice of
[modbusreg issue #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201);
the parent issue remains open.
Provider lifecycle, concurrent source-set replacement and publication fencing,
retention policy, public qualification, transport conformance, runtime
integration, consumer validation and hardware acceptance remain outside this
slice.
No hardware acceptance is claimed.
