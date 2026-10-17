# Tesla activation observation hook V1

## Status and native sources

This proposed transport-to-registry contract defines bounded, passive,
pre-exchange byte observation for the Tesla Wall Connector Gen3 HSC family.
It specifies a seam, not an implemented production witness, a new activation
protocol, or permission to acquire from a device. The historical V1 name is a
contract identifier; nothing is stable before Helianthus 1.0.

Read the public native contracts first:

- [HSC transport and activation](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/tesla/gen3-hsc-rtu.md)
  owns family selection, serial configuration, native framing and qualification.
- [Private-function transport](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/modbus/private-function-codes.md)
  owns stream lifecycle, generation fencing, correlation and recovery.
- [Read-acquisition lifecycle](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/tesla/gen3-read-acquisition-v1.md)
  owns readiness, activation timeout, operation admission, epochs and retention.
- [Activation evidence worksheet](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/tesla/activation-evidence-worksheet.md)
  owns the independent evidence intake and negative controls (K33).

| Claim | Evidence grade | Separate disposition |
| --- | --- | --- |
| Existing pages specify native transport bounds and a lifecycle witness comparison | Proven as published contract requirements, not as device observations | No new implementation or qualification evidence here |
| Reported activation token exchange | Hypothesis about the physical exchange | The lifecycle comparison remains a prerequisite, not proof of activation |
| Token origin, relationship to RTU framing, and repetition after reset | Unknown; docs-modbus #158 remains unresolved | No invented direction, reset sequence or framing rule |
| Proposed hook below | Proposed interface requirements, not an observed fact | Acquisition/admission and live qualification remain independently gated |

The HSC wording describes device-originated tokens, while the lifecycle and
worksheet explicitly leave origin and timing open. This page preserves that
uncertainty. It does not resolve it by treating a receive-side byte match as
attribution. Matching bytes alone cannot establish live qualification.

## Ownership and current versus proposed behavior

The published read lifecycle currently obtains bytes from an injected witness
and documents the absence of production pre-exchange observation. This page
does not change that availability claim. The proposal is for transport to
observe and return native evidence; the registry interprets that evidence
against the selected public profile and the existing lifecycle rules.

Transport must not contain a Tesla token comparator, select a profile from
bytes, label a match as activation, construct a handshake, or admit an exchange.
The registry must not obtain an independent reader or raw serial handle.
Observation has no transmit, reset, flush, discovery, retry or fallback action.
No witness implementation, dependency pin or gateway composition is required
to review this contract. No new authorization gate is introduced.

## Input and detached result

Names below are logical fields, not a language API. All bounds are explicit
positive finite values checked before taking the stream. Missing/invalid
inputs fail before observation; a busy endpoint fails fast without queueing.

| Input | Requirement and lifetime |
| --- | --- |
| Endpoint label and endpoint instance | Explicit configured label plus opaque local instance identity; label equality cannot substitute for the owned instance. Never expose a local path or hardware identity. |
| Expected generation | Nonzero current unfenced transport generation of that instance, checked under endpoint synchronization before observation begins. Never infer it from bytes. |
| Observation identity | Transport-allocated local identity unique within the instance/generation; distinguishes attempts without inventing a wire transaction ID. |
| Caller context and absolute deadline | Cancellation plus a finite deadline, no later than the lifecycle activation deadline and any enclosing acquisition deadline. Deadline is sampled before observation; it never slides when bytes arrive. |
| Clock epoch | Identifies the monotonic clock domain for start, byte and return offsets; incomparable clocks cannot establish timeliness. |
| Requested byte count and segment cap | Explicit finite allocation/read bounds. Completion means exactly the requested byte count was captured; it does not mean an activation exchange was complete. Segment-cap exhaustion before that count is incomplete. |

Each result is detached: copy all bytes, segment metadata and diagnostics;
return no stream, buffer alias, mutable currentness flag or callable capability.
Later reads or mutations of a returned value cannot change retained evidence.

| Result | Required native evidence and limit |
| --- | --- |
| Identity | Endpoint label, instance, generation and observation identity copied from the actual observation, never relabeled to a successor |
| Time | Clock epoch, observation start/end and return offsets; per-byte receipt offsets, or explicit Unknown resolution with segment bounds; no wall-clock capture time in public projections |
| Segments | Ordered exact bytes, receive direction, segment boundaries, offsets and completeness; fragmentation is not a wire-frame boundary. Sender attribution remains Unknown unless independently supported. |
| Termination | `captured`, `deadline`, `canceled`, `closed`, `generation_lost`, `read_error`, or `segment_bound`, with bounded cause and available partial evidence |
| Coverage | Requested and captured byte counts, segment count, timing resolution, known loss/truncation and any unavailable diagnostics; absent bytes stay absent |
| Framing/integrity | Only actually supported diagnostics, otherwise Unknown; activation bytes are not assumed RTU frames and no CRC is invented |

`captured` describes a complete requested byte window only. Reads request no
more than the remaining byte budget, so a large underlying read cannot silently
discard a suffix. An implementation unable to guarantee bounded lossless
capture must report incomplete coverage and withhold usable observation.
Reaching the segment cap with the requested count complete is allowed; needing
another segment is not. There is no token-search loop that discards leading,
trailing, unrelated or malformed bytes to manufacture a match. Unread bytes
outside the window are not evidence of absence; subsequent unexpected bytes
remain subject to the existing transport/lifecycle fault rules.

## Exclusive stream ownership and lifetime

Observation reserves the endpoint's same single-flight owner used by standard
reads, private exchanges and recovery. No second reader, exchange, observation
or recovery may consume the stream concurrently. Close and cancellation must
still interrupt a blocked read within the supplied deadline. A platform unable
to provide interruptible bounded reads cannot implement this seam by leaving a
background reader alive after return.

| State/event | Observation result and currentness | Admission consequence |
| --- | --- | --- |
| Idle, current instance/generation, valid bounds | Reserve one observation; begin a fresh window, excluding buffered evidence from previous observations/generations | No exchange while observing |
| Exact requested count before deadline | Return detached `captured` evidence and release reader ownership | Candidate evidence only; no transport readiness decision |
| Partial/empty bytes, read error or segment exhaustion | Return partial/empty evidence with cause; invalidate that observation | Readiness remains unavailable; no implicit retry |
| Cancellation or return at/after deadline, even with matching bytes | Invalidate observation and retain bytes as history; timer callback scheduling cannot extend the deadline | Reject readiness; no recovery after a spent acquisition budget |
| Close, endpoint loss/replacement, fencing or recovery begins | Invalidate active and previously returned observations for that instance/generation; interrupt active reader before any successor consumes bytes | No successor use of old evidence; closed remains terminal |
| Recovery succeeds or Restart replaces endpoint | Existing lifecycle obtains a successor generation/instance and requires fresh activation | Fresh observation required; never rebind history |
| Concurrent caller or invalid input | Refuse without consuming stream bytes | No send, no queued observation |

The start boundary must distinguish newly received bytes from stale buffered
bytes without silently flushing evidence. If provenance of queued bytes is
unknown, fail closed and retain that limitation. Observation failure does not
invent an exchange failure or a send; any required endpoint fencing/recovery
uses the existing transport boundary, not a new reset procedure.

A returned result cannot certify its own continuing validity. Before readiness
is committed, the registry must recheck the actual instance, generation,
observation identity, clock domain, deadline, cancellation and endpoint state
against the transport owner. That validation and the readiness commit must be
serialized with Close, fencing and recovery so they cannot be overtaken by a
late result. An adapter must document how it provides this atomic boundary;
a detached snapshot or an unlocked check followed by a commit is insufficient.
This requirement does not prescribe a witness implementation or change epoch
pinning: the existing lifecycle still pins generation at its first admitted
exchange and rejects old generations at dispatch.

No result is usable twice for separate activation attempts. The registry binds
the observation identity to its current activation attempt. An invalidated
observation cannot regain validity if a label is reused or bytes later match.
After readiness, existing dispatch admission continues to enforce the owned
endpoint and generation; the observation grants no bypass or lasting send right.

## Synthetic examples and independent expected outcomes

These are constructed offline examples, not captures or firmware evidence.
All offsets are relative synthetic milliseconds in clock domain C. Baseline:
label E, instance I, generation 7, observation A, deadline 50, requested count
11 and segment cap 8. The byte comparator below is only the existing lifecycle
comparator: `TESLA` + NUL + `PASS` + NUL. No example instructs transmission.

| Case; minimal evidence | Expected transport result | Registry/lifecycle expectation |
| --- | --- | --- |
| Fragmented: `TE` at 1, `SLA\0` at 2, `PA` at 3, `SS\0` at 4; return 5, no invalidation | `captured`, four segments, 11 bytes, original offsets retained | Exact ordered comparison may satisfy the offline comparator if all independent prerequisites hold; physical activation/qualification remains Unknown |
| Late: same bytes at 1 through 4, return exactly 50 | Historical bytes; deadline invalidation regardless of timer delivery | No readiness, even though bytes match |
| Wrong generation: result is generation 7; owner has advanced to 8 before commit | Detached result keeps generation 7 | Reject; no relabeling or successor admission |
| Canceled: complete bytes at 4; cancellation before readiness commit | Retain bytes; observation invalidated even if capture had returned | No readiness; matching data cannot overtake cancellation |
| Partial: only `TESLA\0` before deadline | `deadline`, six bytes; no fabricated suffix | No readiness; keep partial evidence |
| Leading unrelated byte: requested window starts `X` followed by first ten comparator bytes | `captured` window with unexpected bytes, not a token search | Exact comparison fails; do not trim or extend window to find a match |
| Close/recovery race: complete result returns at 5; Close or recovery wins before commit | Original result remains detached historical evidence | No readiness; a fresh successor observation is required if lifecycle permits restart |
| Segment exhaustion: eight one-byte segments, still short of 11 | `segment_bound`, eight exact bytes | No readiness; no automatic retry |

The following are reasoned falsifiers for future implementation review, not
executed mutation tests. Each changes one field of the otherwise unchanged
fragmented baseline: changing endpoint label, instance, generation or observation
identity alone must fail binding; changing clock epoch alone must fail time
comparison; moving return to the deadline must fail timeliness; canceling the
context alone must fail readiness. Removing each corresponding check would
incorrectly accept that case. Reordering a segment or changing one native byte
must fail exact comparison; dropping byte-copy isolation would let later buffer
reuse change evidence. Releasing stream ownership while a reader survives
would allow competing consumption and violates the ownership contract.

## Retention, compatibility and remaining acceptance

Preserve native segments, partial evidence, Unknown diagnostics and provenance
independently of interpretation. A public projection that omits native bytes
or timing must state that loss and cannot prove exact byte agreement or timely
arrival. Failed observation never replaces a qualified sibling or partial
last-known-good read state with invented values. Historical read records keep
their original provenance/freshness; they are not made current by token matches.

This seam changes no existing profile qualification, trust/admission predicate,
read-only MCP envelope, eBUS MCP compatibility, GraphQL parity or semantic
projection. It defines no receipt system, idempotency ledger, principal boundary,
or recovery redesign. Gateway composition remains outside this contract.

This is a partial contract slice for docs-modbus #174, modbus #38, modbusreg
#200 and docs-modbus #158. Remaining acceptance includes transport implementation
and race/boundary proof, a conforming registry adapter, independent publishable
activation clarification and qualification evidence. K33 worksheet completion,
existing read-lifecycle acceptance and parent closure are separate. No open
implementation PR, predecessor or witness implementation is a prerequisite for
this proposed page. No runtime, hardware, live-smoke or release success follows.
