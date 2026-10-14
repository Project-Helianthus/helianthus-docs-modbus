# Tesla Gen3 read-path acquisition lifecycle contract V1

## Scope and evidence status

This is the operation contract for the driver-owned read-path acquisition
lifecycle of the Tesla Wall Connector Gen3 Home Site Controller (HSC) profile
over Modbus RTU. It specifies endpoint ownership, activation gating, admission,
scheduling, retry and deadline budgets, recovery, freshness and retention, and
the evidence record for the five retained observation operations. It is the
public contract that an implementing registry must satisfy; it is not a
protocol observation and it adds no wire fact.

The wire format, activation sequence, qualification predicates, and operation
numbers are owned by the existing pages: the
[Gen3 HSC contract](gen3-hsc-rtu.md), the
[TEDAPI contract](tedapi.md#fc100-evse-operation-numbers), and the
[private-function transport contract](../modbus/private-function-codes.md#configured-production-read-and-private-function-endpoint).
The retry, outcome-class, and recovery rules reuse the read-side rules of the
[current-limit operation contract V1](gen3-current-limit-operation-v1.md).
The rules below are Helianthus lifecycle requirements, not additional
observations of firmware behavior.

The contract covers only the exact `wc3_24_44_3` operation version. It claims
no support, hardware qualification, or live qualification, and it grants no
control authority. The legacy Wall Connector RS-485 profile is a separate,
non-Modbus flow that this lifecycle never reaches and never falls back to; the
two profiles are never substituted for each other.

## Operations in scope

The lifecycle acquires exactly the five observation operations below. Each is
one FC100 family number with one request tag paired with one terminal tag, as
listed by the [TEDAPI operation numbers](tedapi.md#fc100-evse-operation-numbers).
Every request body is exact empty.

| Operation | Family | Request tag → terminal tag |
|---|---|---|
| Common system information | 4 | 2 → 3 |
| WC vitals | 6 | 1 → 2 |
| WC lifetime statistics | 6 | 3 → 4 |
| WC system information | 6 | 9 → 10 |
| WC load-sharing state | 6 | 11 → 12 |

A deployment configures an ordered, non-empty, duplicate-free subset of these
five operations as its polling set. Any other family/tag pair has no
acquisition mapping and is `NO_SEND`. In particular the current-limit pairs
(family 6, tags 7 → 8, 25 → 26, and 27 → 28) are not acquisition operations:
the persistent and provisional mutations and the provisional readback belong to
the [current-limit operation contract V1](gen3-current-limit-operation-v1.md),
and a lifecycle conforming to this page has no mutation path.

## Lifecycle states and transitions

The lifecycle is in exactly one externally visible state: `stopped`,
`activating`, `ready`, `recovering`, `unavailable`, or `closed`.

| From | Trigger | To |
|---|---|---|
| `stopped` | Start | `activating` |
| `activating` | activation witness reports the documented sequence in time | `ready` |
| `activating` | activation failure, timeout, reset error, unexpected bytes, or an expired activation context | `unavailable` |
| `ready` | Acquire or PollOnce ending `ack`, `rejected`, or `no_send` | `ready` |
| `ready` | transport timeout or other transport failure after possible transmission | `recovering` |
| `ready` | success receipt that the operation decoder rejects | `unavailable` (endpoint retired) |
| `recovering` | transport recovery succeeds | `activating` |
| `recovering` | recovery fails, or the acquisition budget is already spent | `unavailable` |
| `unavailable` | Restart | `activating` |
| any state | Close | `closed` |

Start is valid only from `stopped`; Restart is the way out of `unavailable`.
An open failure at Start or Restart leaves the lifecycle `unavailable`. A
success receipt that is not current for the owned endpoint epoch is
`indeterminate` evidence (see the evidence section) and does not by itself
change the state, because a closed or retired lifecycle is already outside
`ready`. `closed` is terminal: every later operational call (Start, Restart,
Acquire, PollOnce) returns a closed error, while a repeated Close returns
success and the lifecycle state and retained historical records stay readable.

Every successful activation opens a new lifecycle epoch, numbered in
increasing order. An epoch binds exactly one transport generation: the first
admitted exchange of an epoch pins the transport generation for that epoch,
and the pinned generation must be strictly greater than the generation pinned
by any earlier epoch of the same endpoint instance. Recovery therefore always
yields a successor epoch and generation, and a Restart opens a successor
endpoint instance whose admission starts empty; an old generation never serves a
new epoch.

## Admission rules

Admission is fail-closed and evaluated at dispatch, outside the transport
lock, for each exchange. A candidate is admitted only when all hold:

- The lifecycle is `ready` and not closed.
- The request is exactly the planned request payload for the selected
  operation: the planned exact FC100 payload for one of the five operations,
  byte for byte. No caller-supplied bytes reach the endpoint.
- The candidate names the endpoint instance the lifecycle currently owns.
  A retired or replaced endpoint instance refuses every candidate.
- The candidate carries the configured endpoint label and the configured node
  and function FC100.
- The candidate carries the transport generation pinned for the current epoch,
  or, for the first exchange of an epoch, a generation newer than every earlier
  epoch.

The standard register-read admission of the owned endpoint (FC03 and FC04)
admits nothing; this lifecycle never reads registers. The configuration itself
is refused as `NO_SEND` unless it names an explicit endpoint label and local
path, a qualified Gen3 profile, exactly the version `wc3_24_44_3`, an
activation witness, valid time bounds, an attempt bound of 1 through 3, and a
valid freshness and retention window for every configured operation. A Gen3
version label that is known, or a `compatible_candidate`, but is not
`wc3_24_44_3`, is refused: the operation contract is bound to that exact version
and a version label alone grants no operation.

The lifecycle owns one production endpoint at a time and builds its
configuration: 115200 baud, eight data bits, no parity, one stop bit, the
configured endpoint label, and a bounded response count per exchange. The local
path is given only to the endpoint opener and never appears in an evidence
record.

## Scheduling and single-flight

One lifecycle call owns the single in-flight slot. Start, Restart, Acquire, and
PollOnce each reserve the slot; a concurrent call fails fast with a busy error
and is not queued, so no request waits behind another. This is a local
serialization guarantee and does not exclude an external actor on the bus.

PollOnce acquires, in configured order and once each, every configured
operation whose retained last-known-good record is not both fresh and current,
and stops on a lifecycle error. A continuous poller repeats PollOnce on a
ticker-paced configured interval and performs at most one Restart of an
`unavailable` lifecycle per loop iteration. Buffered ticks do not guarantee a
full interval between two Restart attempts.

## Retry, deadline, and recovery budgets

Each transport exchange has exactly one send attempt. An acquisition is bounded
by the following. Each value is configured explicitly, and a missing or
out-of-range value is `NO_SEND`. The numeric limits are configuration maxima
enforced by the implementation, not defaults and not minimums.

| Budget | Rule |
|---|---|
| Attempts | `MaxAttempts` is 1 through 3 exchanges per acquisition. |
| Acquisition deadline | One deadline covers all attempts, recovery, and re-activation of the acquisition. It is at least one response timeout and at most five minutes. |
| Response timeout | The response timeout is positive and at most thirty seconds. It applies per received response frame, not to the whole exchange: the transport restarts it for each frame. |
| Response count | An exchange accepts at most eight response frames. |
| Activation timeout | Each activation is bounded by a positive activation timeout of at most sixty seconds, within the acquisition deadline when it runs inside an acquisition. |
| Recovery | The transport's recovery call is bounded by one response timeout plus one inter-frame interval and also by the acquisition deadline. |

Because the response timeout restarts per frame, the response timeout and the
response-count ceiling do not bound an exchange as a whole. The overall bound of
an exchange, and of the acquisition that contains it, is the acquisition
deadline.

A retry happens only when all hold: the previous attempt ended `timeout` or
`indeterminate` after possible transmission, transport recovery succeeded, a
fresh activation succeeded in a successor epoch, attempts remain, and the
acquisition deadline has not expired. An exchange ending `ack`, `rejected`
(Modbus exception or TEDAPI application error), or `no_send` is terminal and
is not retried. A wrong-tag, unrelated, or otherwise uncorrelated response is
not a terminal: it is a classifier fault that fences the transport generation
and follows the recovery path, so it can never satisfy this or a later request
and is never retried inside the same generation.

Recovery and re-activation run inside the acquisition deadline. This contract
defines no separate cleanup budget: a cancelled or expired acquisition does not
start recovery, leaves the endpoint fenced, and leaves the lifecycle
`unavailable`; Restart, with its own caller-supplied deadline and the activation
timeout, is the bounded way back. An implementation that adds a cleanup budget
must document it as a finite, separately published bound before relying on it.

A success receipt that the transport reports but the operation decoder rejects
is not retried. The endpoint is not fenced by the transport in that case, so
the lifecycle retires it, which makes the lifecycle `unavailable` until
Restart rather than reusing the same generation.

## Freshness and retention

Each configured operation has its own explicit window: a freshness duration
greater than zero, and a retention duration no shorter than freshness and at
most twenty-four hours. There is no default window and no value is inferred
from the operation.

- A failed attempt, whatever its evidence state, never replaces the last
  acknowledged record. The last acknowledged (last-known-good) record and the
  last attempt are retained separately.
- A last-known-good record is fresh while its age is non-negative and no longer
  than the freshness duration. It is discarded once its age exceeds the
  retention duration; the last attempt is discarded on the same rule.
- A record is current only while the lifecycle is `ready` and the record was
  acquired in the active epoch. A record from a recovered, restarted, or closed
  endpoint remains historical evidence, may still be fresh by age, and is never
  current.
- A consumer that needs live state uses only records that are acknowledged,
  fresh, and current. A historical record is evidence, not a reading of the
  present state.

## Evidence record

Every exchange outcome returns one immutable record with independent copies
of its byte fields. Lifecycle and pre-exchange refusals (an unsupported or
unconfigured operation, a busy, unavailable, or closed lifecycle) return an
error without a populated record.
A record carries:

- Native identity: configured endpoint label, node, operation, and its family
  and request/terminal tag pair.
- Profile and versions: profile name, profile version, operation version, the
  Gen3 version label, and its disposition.
- Source: the private-function exchange of the owned production endpoint.
- Correlation: lifecycle epoch, transport generation, transport request
  identifier, attempt number, and the attempt bound.
- Timestamps: the lifecycle clock observation time, the transport receipt wall
  time, and the monotonic send and receive offsets with their clock epoch.
- Frames: the exact request ADU and every received response ADU, with the
  transport outcome and integrity result.
- Cause text where applicable, the numeric Modbus exception status when one was
  received, and the numeric application status when a TEDAPI application error
  was decoded.
- The evidence state, from the table below.

| State | Meaning | Value-bearing |
|---|---|---|
| `ack` | A correlated terminal, current at the transport and for the owned endpoint epoch, accepted by the selected operation decoder. Carries the complete native terminal body. | yes |
| `rejected` | A correlated Modbus exception, or a TEDAPI application-error terminal. Numeric status is retained. | no |
| `timeout` | Exchange or acquisition deadline expiry after possible transmission. | no |
| `indeterminate` | Any other failure after possible transmission; a success receipt the decoder rejected; or a success receipt that is not current for the owned endpoint epoch, for example one that completed after Close or retirement. | no |
| `no_send` | Proven pre-send rejection. | no |

`timeout` and `indeterminate` are indeterminate evidence about the device: the
request may have been transmitted and its effect, for a read, is unknown. They
never carry a value, even when response frames were received. Frames received
alongside a non-`ack` state remain evidence only. A receipt retired by Close
is never promoted to `ack`, whatever its frames decode to. No evidence state
creates a support claim, a hardware claim, or control authority, and nothing is
invented or zero-filled for a missing value.

## Activation prerequisite and the current NO_SEND gate

An exchange is admitted only after the device-originated activation sequence of
the [Gen3 HSC contract](gen3-hsc-rtu.md#serial-and-activation) has been
observed: the bytes `TESLA` followed by NUL and then `PASS` followed by NUL. The
lifecycle obtains the observed bytes only from an injected activation witness
and compares them byte for byte with that sequence within the activation
timeout. A witness error, a timeout, a reset error, any other byte sequence, or
an activation context that is already cancelled or expired when the report
arrives leaves the lifecycle `unavailable`. The activation deadline is taken
from the lifecycle clock before the witness is called. A witness report
returned at or after that deadline is rejected regardless of whether the
context timer has fired. A report delivered after the
activation deadline never establishes readiness, even when its bytes match.
Cancellation is re-checked inside the readiness commit, under the lifecycle
mutex that Close also takes, so a Close or cancellation cannot be overtaken by
a late report.
Activation is required again after every recovery and every restart.

The witness never admits an exchange by itself; it only gates readiness.
A configuration without a witness is `NO_SEND`. At the cited revision the
production endpoint of the transport library exposes no pre-exchange raw bytes,
so no production witness exists and a lifecycle cannot be constructed for live
use. Two open items remove that gate and are tracked separately:

- helianthus-docs-modbus issue 158 asks for a publishable clarification of the
  activation exchange (which side originates each token, how the sequence is
  timed against RTU framing, and whether it repeats after a device reset). This
  page fixes none of those points.
- helianthus-modbus issue 38 tracks the transport witness hook that would let a
  production witness observe the activation bytes.

Until both are closed the activation stage is a documented gate, not a
qualified live step. This contract describes the byte comparison only.

## What this contract does not claim

- No mutation path. Current-limit set, readback, enable, and disable are outside
  this lifecycle; the current-limit operations belong to the
  [current-limit operation contract V1](gen3-current-limit-operation-v1.md)
  and are separate work.
- No support, hardware, or live-qualification claim. The implementation has no
  live device or real serial stream in its evidence; its tests run against a
  fake endpoint that mirrors this contract.
- No new register, field, unit, scale, or range semantics. Terminal bodies stay
  native.
- No discovery, broadcast, profile fallback, or inferred default endpoint or
  node.
- No Gen2 or legacy Wall Connector coverage, and no dispatch by function-code
  byte alone.
- No promotion to a protocol-neutral model and no consumer binding.
- No resolution of the activation exchange questions above.

## Compatibility and versioning

This is version 1 of the read-path acquisition contract. Later revisions may
only add: further observation operations, each with its own documented
family/tag pair and operation contract; additional evidence fields; or new
bounded diagnostics. A change that removes or reinterprets a state, a
transition, an admission rule, an evidence state, the budgets, or the
no-value rule for `timeout` and `indeterminate` requires a new contract
version. Binding to the operation version `wc3_24_44_3` changes only through a
published revision of the operation numbers.

## Falsifiers

The contract is wrong, or an implementation does not conform, if any of these
is observed:

- A `timeout` or `indeterminate` record carries a value, or replaces the last
  acknowledged record.
- A receipt from a closed or retired endpoint, or from a previous epoch, is
  recorded as `ack` or counted as current.
- A response whose family or terminal tag does not match the selected
  operation, other than a TEDAPI application error, is accepted as a terminal,
  or is followed by a retry in the same transport generation.
- A request other than the planned exact payload, or for a retired endpoint
  instance or another generation, is admitted; or FC03 or FC04 is admitted.
- A configuration bound to a Gen3 version other than `wc3_24_44_3` constructs,
  or an operation outside the five listed pairs is acquired.
- More than three attempts, an attempt after the acquisition deadline expired,
  a retry without recovery and a fresh activation, or a retry after an
  exception or application error.
- Recovery or re-activation continues past the acquisition deadline with no
  separately documented cleanup budget.
- Readiness is established without the exact activation sequence, after a
  witness error, or from a report delivered after its context expired.
- Two lifecycle calls hold the in-flight slot, or a concurrent caller waits
  instead of failing fast.
- Any mutation request is constructed or sent.

## Implementation evidence

The reference implementation is the `TeslaGen3ReadAcquisition` lifecycle in
helianthus-modbusreg, pull request 209 (issue 208, plan item M3), at revision
`51db865a` of its branch. That revision contains the five points this page
states explicitly: exact-tag correlation that fences on a wrong-tag response,
binding to the exact version `wc3_24_44_3`, no promotion of a retired receipt,
recovery inside the acquisition deadline, and no readiness from an expired
activation context. The
revision is a pre-merge citation; it is replaced by the merged revision when
the pull request merges. The implementation is evidence of one conforming
design, not an observation of device behavior.
