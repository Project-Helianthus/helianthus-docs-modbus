# Tesla Gen3 read-path acquisition lifecycle contract V1

## Scope and evidence status

This contract governs driver acquisition on the Tesla Wall Connector Gen 3
Home Site Controller (HSC) profile over Modbus RTU. Endpoint ownership,
qualification, dispatch, budgets, freshness and retention are driver policy.
The [RS-485 site-controller protocol specification](rs485-site-controller-protocol.md#15-firmware-versions-and-applicability)
(§§1.5, 4.2) and the [TEDAPI message specification](tedapi-specification.md#13-certainty-and-applicability)
(§1.3) define firmware applicability by named version, not by a version floor.
FC100 support alone does not establish support for any particular TEDAPI tag.
The same capability checks apply to the floor build and to
every later build of that same Gen3 version line. This is an admission filter,
not protocol coverage.

The driver's version label has the form `wc3_` followed by three
underscore-separated integers. The first two select the read line `wc3_24_44`;
the third orders builds on that line. The read floor is `wc3_24_44_3`.
The independently qualified provisional current-limit mutation stays bound to
the exact operation version `wc3_24_44_3`. Neither a hardware test level nor
this version filter establishes live qualification. The legacy Wall Connector
RS-485 profile is separate, non-Modbus, and never a fallback.

## Operations in scope

The driver selects six read paths, each with an empty request body and the
family and terminal tag shown below. TEDAPI §§6.2.1, 6.4.1–6.4.2,
6.4.5–6.4.6 and 6.4.11 specify these FC100 paths for 26.34.0 and 26.42.0.
Applicability of those individual reads on `24.44.3` and later `wc3_24_44`
builds is not specified by those sections. Missing or unknown compatibility
is not admission.

| Operation | Family | Request tag → terminal tag |
|---|---|---|
| Common system information | 4 | 2 → 3 |
| WC vitals | 6 | 1 → 2 |
| WC lifetime statistics | 6 | 3 → 4 |
| WC system information | 6 | 9 → 10 |
| WC load-sharing state | 6 | 11 → 12 |
| Provisional readback | 6 | 27 → 28 |

A deployment configures an ordered, non-empty, duplicate-free subset of these
operations as its polling set. Where the configured build establishes t27/t28
compatibility, t27 can be selected alone or beside other supported reads.
The lifecycle admits family 6, tags 27 → 28, as a selectable observation and
as the on-demand read of the separately admitted native mutation even when tag 27 is absent from periodic Operations.
The existing explicit t27 window supplies freshness and retention to that
on-demand path without scheduling it. A missing or invalid window prevents
only the dependent mutation from sending; it does not stop other reads
with valid windows.

The only driver mutation is the provisional current-limit operation of the
[current-limit operation contract V1](gen3-current-limit-operation-v1.md).
It uses the same single-flight owner and current generation; that mutation is never retried.
The persistent settings write (6/7 → 6/8) is a distinct TEDAPI operation
(§§6.4.4, 7.8), not a driver setter or acquisition mapping. The configuration
read (6/5 → 6/6, §6.4.3) and all other wire-defined operations remain outside
this lifecycle: any unselected family/tag pair is `NO_SEND`.

## Lifecycle states and transitions

The lifecycle is in exactly one externally visible state: `stopped`,
`activating`, `ready`, `recovering`, `unavailable`, or `closed`.

| From | Trigger | To |
|---|---|---|
| `stopped` | Start | `activating` |
| `activating` | driver reports the confirmation after a host echo of the immediately preceding greeting, in time | `ready` |
| `activating` | configured readiness probe: silence for the whole activation timeout, then an acknowledged first configured read | `ready` |
| `activating` | activation failure, refusal, reset error, unexpected bytes, an echo that differs from its greeting, any other order, or an expired activation context | `unavailable` |
| `activating` | silence for the whole activation timeout without a configured readiness probe, or a readiness probe that is not acknowledged | `unavailable` |
| `ready` | Acquire or PollOnce ending `ack`, `rejected`, or `no_send` | `ready` |
| `ready` | transport timeout or other transport failure after possible transmission | `recovering` |
| `ready` | success receipt that the operation decoder rejects | `unavailable` (endpoint retired) |
| `recovering` | transport recovery succeeds | `ready` |
| `recovering` | recovery fails, or the acquisition budget is already spent | `unavailable` |
| `ready` or `recovering` | station reset or loss of routed mode invalidates readiness | `unavailable` |
| `unavailable` | Local Restart with retained readiness for an unchanged station epoch | `ready` |
| `unavailable` | Restart without current station readiness, including after station reset | `activating` |
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
increasing order. An epoch pins one generation of the current endpoint
instance at a time. The first admitted exchange of an epoch pins that
generation, and it must be strictly greater than the generation pinned by any
earlier epoch of the same endpoint instance. Recovery keeps that epoch and
does not repeat activation while the station epoch is unchanged.
It replaces a fenced generation with a successor generation in the same
epoch and endpoint instance. The successor must be strictly greater than the
fenced generation, which is no longer admitted. A record is current only
when its epoch, endpoint instance and generation are the live ones.

A station epoch is the station's continuous period of routed operation. A
local endpoint or transport change does not establish that the station has
restarted. A local Restart with retained readiness for an unchanged station
epoch opens a successor endpoint instance in the same lifecycle epoch, with
empty admission. It sends no echo and does not wait for a second exchange.
A station reset or loss of routed mode invalidates readiness and fences the
current generation before further dispatch. Prior activation and acquisition
records are historical. Without current
station readiness, Restart enters `activating`; a new readiness result opens
a new lifecycle epoch. An old generation never serves a new epoch.

## Admission rules

Admission is fail-closed and evaluated at dispatch, outside the transport
lock, for each exchange. A candidate is admitted only when all hold:

- The lifecycle is `ready`, station readiness is current, and the endpoint
  is not closed.
- The request is exactly the planned request payload for the selected
  operation: the planned exact FC100 payload for a selected read or the
  independently qualified provisional current-limit mutation, byte for byte.
  No caller-supplied bytes reach the endpoint.
- The candidate names the endpoint instance the lifecycle currently owns.
  A retired or replaced endpoint instance refuses every candidate.
- The candidate carries the configured endpoint label and the configured node
  and function FC100.
- The candidate carries the transport generation the current epoch pins for
  the current endpoint instance. For the first exchange of an epoch on that
  instance, the generation is newer than every earlier epoch of the same
  endpoint instance. After recovery replaces a fenced generation of that
  instance, the epoch pins the successor generation of that instance, and a
  candidate that still carries the replaced generation is refused. A local
  Restart under an unchanged station epoch can replace the instance in the
  same lifecycle epoch; a candidate naming the replaced instance is refused.

The standard register-read admission of the owned endpoint (FC03 and FC04)
admits nothing; this lifecycle never reads registers. The configuration itself
is refused as `NO_SEND` unless it names an explicit endpoint label and local
path, a qualified Gen3 profile, an identified build at or above the read floor
on the `wc3_24_44` line whose activation, private-function, and operation
capabilities are compatible, an activation driver, valid time bounds, an
attempt bound of 1 through 3, and a valid freshness and retention window for
every configured operation.
The read floor is the identified, capability-compatible label `wc3_24_44_3`
on the `wc3_24_44` line. A `compatible_candidate` is admitted for these reads
only when it is identified on that line at or above the floor and those
capabilities are compatible. An unidentified build, including an ambiguous
or missing version and a build that is not on the `wc3_24_44` line, is refused
with that reason and nothing is sent. A build on that line whose third integer
is below 3 is refused as below-floor and nothing is sent. A build whose
activation, private function, or operation schema is incompatible is refused
as capability-incompatible and nothing is sent. A version label alone grants
no operation. The mutation requires its own exact operation version and
qualification; read admission cannot authorize it.

The lifecycle owns one configured production endpoint, with 115200 baud,
eight data bits, no parity and one stop bit (RS-485 §2.1), an explicit endpoint
label, and a bounded response count. It gives the local path only to the
endpoint opener, not to the record. FC100 on 24.44.3 and 26.34.0 replies
asynchronously (RS-485 §§2.7, 5). The host must wait for the reply or timeout
before sending the next request. The specification gives no minimum or maximum
reply time; the budgets below are driver policy, not station timing.

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

Each transport exchange has exactly one send attempt. The provisional
current-limit mutation is never retried. An acquisition is bounded
by the following. Each value is configured explicitly, and a missing or
out-of-range value is `NO_SEND`. The numeric limits are configuration maxima
enforced by the implementation, not defaults and not minimums.

| Budget | Rule |
|---|---|
| Attempts | `MaxAttempts` is 1 through 3 exchanges per acquisition. |
| Acquisition deadline | One deadline covers all attempts and recovery of the acquisition. It is at least one response timeout and at most five minutes. |
| Response timeout | The response timeout is positive and at most thirty seconds. It applies per received response frame, not to the whole exchange: the transport restarts it for each frame. |
| Response count | An exchange accepts at most eight response frames. |
| Activation timeout | Each activation is bounded by a positive activation timeout of at most sixty seconds, within the acquisition deadline when it runs inside an acquisition. |
| Recovery | The transport's recovery call is bounded by one response timeout plus one inter-frame interval and also by the acquisition deadline. |

Because the response timeout restarts per frame, the response timeout and the
response-count ceiling do not bound an exchange as a whole. The overall bound of
an exchange, and of the acquisition that contains it, is the acquisition
deadline.

A retry happens only when all hold: the previous attempt ended `timeout` or
`indeterminate` after possible transmission, transport recovery succeeded
and pinned a successor generation in the same epoch, the activation is not
repeated, the retry carries that successor generation, attempts remain, and the
acquisition deadline has not expired. An exchange ending `ack`, `rejected`
(Modbus exception or TEDAPI application error), or `no_send` is terminal and
is not retried. That retry rule does not apply to the provisional
current-limit mutation. A wrong-tag, unrelated, or otherwise uncorrelated response is
not a terminal: it is a classifier fault that fences the transport generation
and follows the recovery path, so it can never satisfy this or a later request
and is never retried inside the same generation.

A later recovery does not repeat the activation. This recovery path requires
current station readiness. Recovery success returns to `ready` with the
successor generation pinned in the same epoch. A cancelled or expired acquisition does not start
recovery. It leaves the endpoint fenced and the lifecycle `unavailable`.
Restart has its own caller-supplied deadline. It may reuse readiness only in
an unchanged station epoch; otherwise it must obtain a new readiness result
within its activation timeout. Restart after a station reset never reuses the
previous activation report. This contract supplies no separate cleanup budget;
recovery must finish within the acquisition deadline. A separate cleanup
budget must be finite and published before an implementation relies on it.

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
- A record is current only while the lifecycle is `ready` and its epoch, its
  endpoint instance, and its generation are the live ones. A record from a
  fenced generation, another endpoint instance, a replaced endpoint instance,
  or a closed lifecycle remains historical evidence, may still be fresh by age,
  and is never current.
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
- Activation report of the epoch, when an activation opened it, as specified
  in the activation section.
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
never carry a value, even when response frames were received. The provisional
mutation uses the outcome classes of the
[current-limit operation contract V1](gen3-current-limit-operation-v1.md).
Frames received
alongside a non-`ack` state remain evidence only. A receipt retired by Close
is never promoted to `ack`, whatever its frames decode to. No evidence state
creates a support claim, a hardware claim, or control authority, and nothing is
invented or zero-filled for a missing value.

## Activation prerequisite and the current NO_SEND gate

The [RS-485 site-controller protocol specification](rs485-site-controller-protocol.md#3-start-up-exchange)
(§§3.2–3.6) defines the station exchange. On 24.44.3 and 26.34.0 the tokens are
plain bytes with no RTU address, function code or CRC. The peer echoes the
`TESLA` probe and its trailing NUL unchanged. On a match the station sends
`PASS` and NUL before entering routed mode. On failure it sends `FAIL` and
NUL, and probes again only if attempts remain. The peer waits for the complete
pass token before sending an addressed request. The required quiet time
after the token is not specified.

On 24.44.3 and 26.34.0, if no echo byte has arrived at the end of the probe,
the station waits at most a nominal 2 ms before evaluating the echo. This is
not a latest accepted arrival time. The latest accepted echo arrival, the interval between attempts and the time
from station start to the first probe are not specified. The station allows ten attempts
on 24.44.3, MID 25.2.2, 26.18.0 and 26.34.0; 24.28.3 has no attempt limit.
For 26.42.0, the start-up attempt count and echo evaluation timing are not
specified. On 24.44.3, a single exchange with unchanged conditions is
Provisional: an internal station restart request can start another exchange,
and its trigger is not specified. Whether the port answers addressed requests
after start-up without an echoed probe is not specified. The site-controller
watchdog is separate from activation and does not change the port mode on
24.44.3 or 26.34.0 (§3.5).

The lifecycle drives the exchange through an injected activation driver on
the endpoint it owns. The driver reports ordered events: the device greeting;
the host echo, which is the same bytes as the greeting just received; then
either the device confirmation or a refusal (with a new greeting only if
the station makes another attempt). Readiness requires a report that ends
with the confirmation after a host echo of the immediately preceding greeting. A confirmation with no host
echo, a refusal, a greeting without a confirmation, an echo that differs from
its greeting, any other bytes, or any other order never admits readiness. The
tokens are `TESLA`, `PASS` and `FAIL`, each followed by NUL, compared exactly.
The activation deadline is taken from the lifecycle clock before the driver is called. A driver report returned at or after that deadline is rejected regardless of whether the context timer has fired.
A report delivered after the activation deadline never establishes readiness, even when its bytes match.
Cancellation is re-checked inside the readiness commit, under the lifecycle
mutex that Close also takes, so a Close or cancellation cannot be overtaken by
a late report. A driver error, a timeout, a reset error, or an activation
context that is already cancelled or expired when the report arrives leaves
the lifecycle `unavailable`.

The lifecycle retains the report of the activation that opened the current
epoch: the events with their host-side monotonic offsets and, for each echo,
the host-side interval from receipt of the last greeting byte to the start of
the write, and the write duration.
These are host-side values, not wire timing.

An optional readiness probe is an explicitly configured use of the first
configured read operation. It applies only when the driver reports silence for
the whole activation timeout, meaning no event at all. On 26.34.0 and 26.42.0 a station can
answer addressed requests even when the peer did not receive the pass token
(RS-485 §3.3). The probe is a driver read, not a substitute for a station
activation. Only an acknowledgement current to the probe can open the
lifecycle epoch. Any other result leaves the lifecycle `unavailable`. The
probe is never used after any event was reported.
It is a transmission and it is off unless configured.

The only bytes the lifecycle causes to be transmitted are the planned read
requests, the one provisional current-limit mutation, and the host echo of a
greeting. The echo is sent only by a driver whose configuration selects the responder explicitly.
A local Restart under an unchanged station epoch sends no echo and does not
wait for a second exchange. A station reset invalidates that exception.
The driver never admits an exchange by itself; it only gates readiness.
A configuration without a driver is `NO_SEND`.

## What this contract does not claim

- The only mutation is the provisional current limit, and it is never retried.
  The provisional readback is a planned read of this lifecycle. Both follow the
  [current-limit operation contract V1](gen3-current-limit-operation-v1.md).
  The persistent settings write, enable, and disable stay outside.
- Driver admission does not establish firmware support, and read qualification
  grants no control authority.
- No new register, field, unit, scale, or range semantics. Terminal bodies stay
  native.
- No discovery, broadcast, profile fallback, or inferred default endpoint or
  node.
- No Gen2 or legacy Wall Connector coverage, and no dispatch by function-code
  byte alone.
- No promotion to a protocol-neutral model and no consumer binding.

## Compatibility and versioning

This is version 1 of the read-path acquisition contract. Later revisions may
only add: further observation operations, each with its own documented
family/tag pair and operation contract; additional evidence fields; or new
bounded diagnostics. A change that removes or reinterprets a state, a
transition, an admission rule, an evidence state, the budgets, or the
no-value rule for `timeout` and `indeterminate` requires a new contract
version. The operation numbers change only through a published revision.
The driver read build floor is `wc3_24_44_3` on the `wc3_24_44` line, subject
to per-build capability compatibility; it is not the firmware coverage of
FC100 or TEDAPI.

## Falsifiers

The contract is wrong, or an implementation does not conform, if any of these
is observed:

- A `timeout` or `indeterminate` record carries a value, or replaces the last
  acknowledged record.
- A receipt from a closed or retired endpoint, from a previous epoch, or from
  a fenced generation, is recorded as `ack` or counted as current.
- A response whose family or terminal tag does not match the selected
  operation, other than a TEDAPI application error, is accepted as a terminal,
  or is followed by a retry in the same transport generation.
- A request other than the planned exact payload, or for a retired endpoint
  instance or another generation, is admitted; or FC03 or FC04 is admitted.
- Read acquisition at an unidentified, below-floor, or capability-incompatible
  build constructs a request, or an operation outside the six selected read
  paths and the one provisional mutation is acquired.
- More than three attempts, an attempt after the acquisition deadline expired,
  a retry without recovery, a retry that repeats the activation, a retry
  admitted on a fenced generation, or a retry after an exception or
  application error.
- Recovery continues past the acquisition deadline with no separately
  documented cleanup budget.
- Readiness from a confirmation with no host echo, a refusal, a greeting without a confirmation, an echo that differs from its greeting, any other bytes, or any other order.
- A readiness probe used after any event was reported, or without explicit configuration.
- A record from another endpoint instance counted as current.
- A local Restart with unchanged station readiness waits for a second
  exchange or sends an echo; or a Restart uses a previous station activation
  after a reset or loss of routed mode.
- Readiness from a driver error, or from a report delivered after its context
  expired.
- Two lifecycle calls hold the in-flight slot, or a concurrent caller waits
  instead of failing fast.
- A mutation other than the one provisional current-limit request is
  constructed or sent, or that mutation is retried.
