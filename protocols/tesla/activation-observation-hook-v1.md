# Tesla activation observation hook V1

## Scope

This transport-to-registry contract defines an optional, receive-only
byte window for the Wall Connector Gen 3 HSC family. V1 identifies the
interface; it does not assert production availability.
The interface is not stable before Helianthus 1.0.

The [RS-485 site-controller protocol specification](rs485-site-controller-protocol.md#3-start-up-exchange)
defines the port's start-up conditions, tokens, transitions and firmware
applicability. The station sends a probe, the peer echoes it, and the station
sends a pass or fail token as specified for that firmware. On 24.44.3 and
26.34.0, start-up tokens are separate from addressed RTU traffic. This
separation is not specified for other builds.

The hook neither sends the echo nor runs the state machine. A receive window
may contain all, part or none of a token. Neither matching bytes (including a
pass token) nor silence establish the port's state or driver readiness. The
hook's deadline, byte count and segment cap do not define any protocol timing
or attempt limit.

Related interfaces:

- [HSC transport and activation](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/tesla/gen3-hsc-rtu.md)
  describes driver support and its separate admission checks.
- [Private-function transport](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/modbus/private-function-codes.md)
  owns stream lifecycle, generation fencing, correlation and recovery.
- [Read-acquisition lifecycle](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/tesla/gen3-read-acquisition-v1.md)
  owns driver readiness, activation timeout, operation admission, epochs and retention.
- [Activation evidence worksheet](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/tesla/activation-evidence-worksheet.md)
  is a compatibility landing for the start-up rules, not a prerequisite.

## Ownership

The read-acquisition lifecycle assigns any active start-up exchange on its
endpoint to the activation driver. The hook returns native diagnostics; it
is not the activation driver and is not called to obtain a readiness result.
An absent, failed or successful diagnostic window does not alter the driver's
readiness or admission rules.

The hook must not compare bytes against Tesla tokens, select a profile from
bytes, label a match as activation, or construct or admit an exchange. It has
no transmit path, echo responder, reset, flush, discovery, retry or fallback.
The registry must not obtain an independent reader or raw serial handle.

## Input and detached result

Names below are logical fields, not a language API. All bounds are explicit
positive finite values checked before taking the stream. Missing/invalid
inputs fail before observation; a busy endpoint fails fast without queueing.

| Input | Requirement and lifetime |
| --- | --- |
| Endpoint label and endpoint instance | Explicit configured label plus opaque local instance identity; label equality cannot substitute for the owned instance. Never expose a local path or hardware identity. |
| Expected generation | Nonzero current unfenced transport generation of that instance, checked under endpoint synchronization before observation begins. Never infer it from bytes. |
| Observation identity | Transport-allocated local identity unique within the instance/generation; distinguishes attempts without inventing a wire transaction ID. |
| Caller context and absolute deadline | Cancellation plus a finite deadline, no later than any applicable lifecycle activation or enclosing acquisition deadline. Deadline is sampled before observation; it never slides when bytes arrive. |
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
| Framing/integrity | Only actually supported diagnostics, otherwise Unknown; the hook does not interpret start-up tokens as RTU frames or invent a CRC |

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

| State/event | Observation result and currentness |
| --- | --- |
| Idle, current instance/generation, valid bounds | Reserve one observation; begin a fresh window, excluding buffered evidence from previous observations/generations |
| Exact requested count before deadline | Return detached `captured` evidence and release reader ownership |
| Partial/empty bytes, read error or segment exhaustion | Return partial/empty evidence with cause; invalidate that observation; no implicit retry |
| Cancellation or return at/after deadline, even with matching bytes | Invalidate observation and retain bytes as history; timer callback scheduling cannot extend the deadline |
| Close, endpoint loss/replacement, fencing or recovery begins | Invalidate active and previously returned observations for that instance/generation; interrupt active reader before any successor consumes bytes; closed remains terminal |
| Recovery succeeds or Restart replaces endpoint | Associate new windows only with the live instance and generation; never rebind history to a successor |
| Concurrent caller or invalid input | Refuse without consuming stream bytes; no queued observation |

The start boundary must distinguish newly received bytes from stale buffered
bytes without silently flushing evidence. If the origin of queued bytes is
unknown, withhold a current observation and retain that limitation.
Observation failure does not count as exchange failure or initiate recovery.
Any independently required fencing or recovery belongs to the transport.
Replacing a host endpoint or transport generation does not determine whether
the station has restarted its start-up state machine.

A detached result cannot certify its own continuing validity. Before the
registry associates a result with a current diagnostic request, it must recheck
the endpoint label and instance, generation, observation identity, clock epoch,
deadline, cancellation and endpoint state against the transport owner. That
check and association must be serialized with Close, fencing and recovery. A
late or invalidated result may be retained as history but cannot regain
currentness. An observation belongs only to its original request, even when a
label is reused or later bytes match. These checks govern the diagnostic result,
not activation or exchange admission.

## Synthetic examples and independent expected outcomes

All offsets are relative synthetic milliseconds in clock domain C. Baseline:
label E, instance I, generation 7, observation A, deadline 50, requested count
6 and segment cap 8. These offsets are not an echo window or a retry count.
The hook records received bytes only; the examples do not require a sender.

| Case; minimal evidence | Expected transport result | Diagnostic use |
| --- | --- | --- |
| Fragmented greeting: `TE` at 1, `SLA\0` at 2; return 3, no invalidation | `captured`, two segments, 6 bytes, original offsets retained | A complete diagnostic window, not a confirmation or readiness result |
| Late: same bytes at 1 through 2, return exactly 50 | Historical bytes; deadline invalidation regardless of timer delivery | No current observation, even though the bytes match |
| Wrong generation: result is generation 7; owner has advanced to 8 before association | Detached result keeps generation 7 | Reject current association; no relabeling to the successor |
| Canceled: complete greeting bytes at 2; cancellation before association | Retain bytes; observation invalidated even if capture had returned | No current observation; matching bytes cannot overtake cancellation |
| Partial: only `TES` before deadline | `deadline`, three bytes; no fabricated suffix | Incomplete; keep partial evidence |
| Leading unrelated byte: requested window starts `X` followed by the first five greeting bytes | `captured` window with unexpected bytes, not a token search | Keep all six bytes; do not trim or extend the window |
| Close/recovery race: complete result returns at 3; Close or recovery wins before association | Original result remains detached historical evidence | No current observation; history is not rebound |
| Segment exhaustion: cap 4, four one-byte segments, still short of 6 | `segment_bound`, four exact bytes | Incomplete; no automatic retry |

Starting from the fragmented example, change one result field at a time and
leave the owning request unchanged: label E to F, instance I to J, generation
7 to 8, or observation identity A to B. Each mismatch prevents current
association. Changing clock epoch C to D alone prevents time comparison.
Returning at the deadline or canceling the context invalidates the result.
Reordering segments or changing a byte does not preserve the native record.
Reusing the transport buffer must not change a detached result, and releasing
ownership must not leave a reader that can consume later bytes.

## Retention and compatibility

Preserve native segments, partial evidence and Unknown diagnostics separately
from interpretation. A public projection that omits native bytes or timing
must state that loss and cannot establish byte agreement or timely arrival.
Failed observation never replaces a qualified sibling or partial
last-known-good read state with invented values. Historical read records keep
their original identity and freshness; a token match does not make them current.

A transport implementation must provide bounded, interruptible reads, and its
registry adapter must enforce the ownership and lifetime rules before using the
result as current diagnostics. Neither implementation nor diagnostic output is
a prerequisite for start-up or read-lifecycle readiness. The hook changes no
profile qualification, trust or admission checks, read-only consumer envelope,
consumer compatibility, parity or semantic projection. It grants no operation
or action-time authorization.
