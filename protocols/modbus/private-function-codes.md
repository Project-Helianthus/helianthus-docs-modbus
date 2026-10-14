# Private Function Code Transport

## Scope and non-goals

This contract defines the vendor-neutral transport boundary for private Modbus
function codes. It applies to RTU frames and to Modbus TCP-shaped transports
where a private function code is carried in a PDU.

It does not define a vendor, a register map, request fields, response fields,
units, operation names, or a global function-code-to-codec mapping.

## Selection and ownership

The registry selects exactly one qualified vendor operation by the tuple:

```text
(endpoint, unit-id, vendor-profile, operation)
```

The selected vendor codec owns request construction, normal-response decoding,
unknown-field retention, and operation-specific response policy. The transport
does not select a vendor profile from a function code.

## Transport exchange

After registry selection, transport accepts only:

```text
(endpoint, unit-id, function-code, raw-request-payload, response-policy)
```

`function-code` is one byte. `raw-request-payload` is bounded by the transport
PDU limit. `response-policy` specifies only generic timing, retry, response
count, and replay constraints. It contains no vendor semantic decoder.

Transport returns either a bounded raw normal response with the requested
function code or a bounded raw exception response with `function-code | 0x80`.
The selected vendor codec validates and decodes a normal payload only after the
transport has correlated it to the in-flight request.

## Function-code isolation

Private function-code values are not globally owned. Different qualified vendor
profiles may use the same byte value with incompatible payload formats. A
transport implementation must not keep a global map from function code to
vendor handler, parser, or operation name.

The registry and endpoint identity select the codec before a frame is sent or a
normal response is decoded. Replayed frames are decoded only by the codec
selected for their own retained operation identity.

## Standard and private function boundary

A function-code byte never identifies a vendor, vendor profile, or operation.
This contract applies only after an operation has been independently classified
as vendor-defined or private and the exact endpoint, unit identifier, profile,
and operation selection has succeeded.

FC100, FC101, and FC102 may be reused by different qualified vendor profiles.
Their payload format and result interpretation remain selected-codec concerns;
the byte values have no global ownership in this contract.

FC0x41 is profile-qualified and is not globally reserved by this contract.

FC23 is a standard Modbus function code, not a private-function operation. It
is not covered by the raw private-function request contract.

A vendor-specific allocation interpretation for FC23 requires a separately admitted standard-function operation and a typed standard-function codec.

This contract makes no claim about the meaning, sendability, or allocation workflow of such an operation.

## Ambiguity and no-send

If the registry has zero or more than one qualified profile for an endpoint and
unit identifier, it must deny operation admission. The transport must receive
no request in that case. A readable frame, matching function code, or matching
unit identifier does not resolve profile ambiguity.

## Response correlation and exceptions

An exception frame is associated only with the matching in-flight request. Its
function byte is `function-code | 0x80`; its exception payload is exactly one
status byte before the transport integrity trailer. The transport retains the
numeric status without assigning vendor meaning.

An unrelated, malformed, late, or over-bound response enters quarantine and
must not satisfy a subsequent request. Normal response payloads remain raw
until the selected codec accepts them.

## RTU serialization

RTU allows one in-flight exchange per endpoint. The endpoint owns frame
separation, deadline handling, response correlation, quarantine, and recovery.
It makes no multi-initiator arbitration guarantee.

## Configured serial boundary

An RTU implementation may use a configured, bidirectional serial byte stream.
The stream is responsible only for opening the explicitly named local endpoint,
applying its explicit serial format, reporting the monotonic receipt offset of
each byte, writing complete framed byte sequences, and closing its own local
resource. It must not discover endpoints, select a vendor profile, infer a
codec from a function code, or admit an operation.

Opening a serial stream makes transport available; it does not make any vendor
operation eligible to be sent. Profile selection and operation admission remain
preconditions at the registry boundary. A serial stream must not be exposed as
a raw external-operation bypass.

Opening or configuration failure, cancellation, short write, read failure, and
unexpected endpoint loss are transport failures. They must preserve the
in-flight exchange boundary: after an uncertain transmission, the endpoint
must quarantine and recover before it accepts a successor request. A normal
lifecycle close ends the local stream without creating a successor request or
classifying itself as a failed exchange.

## Configured production read and private-function endpoint

A production endpoint is opt-in. The standard read path admits only FC03 and FC04 requests
that have already passed the standard read-operation admission boundary. Its
configuration names exactly one local endpoint and one complete serial format:
baud rate, eight data bits, parity, and one or two stop bits. Empty endpoint
identity, incomplete format, unsupported format, broadcast unit identifier,
unbounded timeout, or an unqualified operation is `NO_SEND`. Configuration
does not discover an endpoint, select a unit, select a profile, or infer a
register map.

The same endpoint has a separate opt-in private-function path through
`RTUProductionConfig.PrivateFunction`: an upstream
`RTUPrivateFunctionAdmission` and `MaxResponses` from 1 through 8, both or
neither. The zero value (no admission and zero maximum responses) disables
private exchanges; a partial configuration or an out-of-range bound is
invalid. Endpoint construction still requires the standard read admission.
Private opt-in does not grant profile selection, operation qualification, or
read-only classification.

`ExchangePrivateFunction` sends nothing unless that path is enabled, upstream
admission approves the endpoint/generation/unit/function/payload candidate,
the policy allows exactly one attempt, the unit is not broadcast, and the
function code is in the user-defined ranges 65–72 or 100–110 (Modbus Application
Protocol Specification V1.1b3, section 5). Codes outside those ranges, including
standard read and write function codes, cannot use this path. Admission receives
a defensive payload copy and cannot change the request bytes to be sent.
Pre-send rejection is `NO_SEND`; it does not start or fence an exchange.
Unit identifiers above 247 are also rejected before transmission.

Accepted baud rates are 9600, 19200, 38400, 57600, 115200, and 230400; data bits are exactly eight; parity is none, even, or odd; and stop bits are one or two. The response timeout is greater than zero and no more than 30 seconds. Recovery has one bounded attempt and completes within the response timeout plus t3.5, with an absolute maximum of 60 seconds. An exchange has exactly one send attempt; no retry is admitted by this contract. FC03 and FC04 permit a zero-based offset from 0 through 65535 and a quantity from 1 through 125 registers. The normal response byte-count is exactly two times the requested quantity; its RTU ADU is exactly 5 + (2 × quantity) bytes and never exceeds 255 bytes. Any configuration, request, normal response, timeout, or recovery result outside these bounds is `NO_SEND` before transmission or a terminal transport fault after possible transmission.

Admission must calculate offset + quantity without 16-bit wrap and require it to be no greater than 65536; otherwise it is NO_SEND before transmission. Offset 65535 with quantity 1 and offset 65411 with quantity 125 are admitted exact-boundary requests; offset 65535 with quantity 2 is NO_SEND.

Each endpoint instance has a nonzero lifecycle generation, incremented before
a replacement or recovery successor admits a request. Close, endpoint loss,
cancellation after possible transmission, timeout after possible transmission,
short write, malformed length or CRC, and unexpected or late frame fence the
affected generation. A fenced or quarantined endpoint
admits no successor until its bounded recovery completes; a replacement starts
only in its successor generation. One endpoint has exactly one in-flight
exchange, shared by FC03/FC04 reads and private-function exchanges. Both paths
share lifecycle generation, request identifier allocation, and the same fence
and `Recover` boundary. There is no batching, scan, broadcast, or implicit
retry admission. The standard read path admits no standard write/control
function; whether an admitted private operation changes state remains the
owning registry's responsibility.

Each private response frame must complete within `ResponseTimeout`, including
first-byte receipt and the t3.5 frame end. RTU framing enforces t1.5 between
bytes and t3.5 frame separation; the frame decoder bounds frame size and checks
CRC before unit, function, and exception-shape correlation. A correlated
exception has the requested function OR 0x80 and exactly one status byte.
No normal payload format is inferred by transport.

An optional caller-supplied `RTUPrivateFunctionResponseClassifier` sees only
correlated normal frames, in arrival order, and marks each `Continue` or
`Terminal`. Without a classifier, the first good normal frame is terminal.
Reaching `MaxResponses` while still `Continue` is a `response_bound` failure;
a terminal frame at the bound is accepted. Each next frame gets a new response
timeout. Response collection allows at most `MaxResponses` frame timeouts plus
caller classification time; transport does not bound classifier
execution time. Request writing uses the caller context. The caller must supply
and enforce any whole-operation deadline, including callback bounds.
The request payload format, operation-specific frame count,
order, terminal rule, and read-only classification remain registry-owned.

A correlated private-function exception ends the exchange with an error
without fencing. Every other failure of a started private exchange fences the
generation until `Recover` succeeds: write fault or short write, timeout,
cancellation, read fault, malformed/CRC-failed/unit- or function-mismatched
frame, classifier error or panic, invalid disposition, or response-bound
exhaustion. Returned normal responses exist only on success; on an exception
or failure they are nil and received frames remain available as evidence.
Cancellation observed after a frame is classified `Terminal` still fences the endpoint and returns no responses.

The correlation identity binds endpoint generation, request identifier, unit
identifier, FC03 or FC04 function, request offset, quantity, and the exact
request ADU. A response satisfies a read only when it arrives in the same
unfenced generation and has the matching unit, function, valid RTU integrity,
and response shape. A Modbus exception is terminal evidence for that request;
it is never successful data. A structurally valid, correlated Modbus exception is terminal evidence for its request but does not fence the endpoint generation or require recovery. A malformed, CRC-failed, late, unrelated, or prior-generation exception is a transport fault and enters quarantine. Late, duplicate, unrelated, malformed, CRC-failed, or prior-generation frames enter quarantine and never satisfy a later request.

Every terminal exchange retains immutable request and response ADU bytes,
integrity result, endpoint generation, correlation identifier, unit identifier,
function, monotonic send and receipt bounds, retry disposition, and terminal
outcome. Failed exchanges retain their available request and transport evidence
without inventing response bytes. Endpoint identity in public evidence is a
stable configured endpoint label, never a local serial path. Evidence from a
closed, replaced, fenced, or quarantined generation is historical only and
cannot authorize, correlate, or be rebound to a successor request. Current
read evidence exists only for a successful, integrity-valid response in the
endpoint's current unfenced generation.

Private exchanges retain a separate immutable-by-value
`RTUPrivateFunctionEvidence` receipt, not an FC03/FC04 read receipt. It contains
the exact request ADU and all received response frames in arrival order,
including a failing final frame or partial bytes; no response bytes means no
invented response frame. It also retains endpoint, generation, request ID,
unit/function, monotonic send/receipt offsets, integrity result, terminal
outcome, currentness, receipt wall time, and clock epoch. Input/output byte
slices are defensively copied. Integrity is not operation success: valid
earlier frames remain evidence even if a subsequent timeout or classifier
failure ends the exchange. The receipt returned by `ExchangePrivateFunction`
keeps its receipt-time `Current`, true only for success in the then-current
unfenced, unclosed generation. `LastPrivateFunctionEvidence` returns a copied
historical receipt, separately from `LastEvidence` for reads, but derives
`Current` from the live lifecycle: stored `Current` AND matching endpoint
generation AND not closed AND not fenced. It reports `Current=false` once its generation is fenced, recovered, or closed.
Success at receipt time is recorded by `TerminalOutcome=success`, not by `Current`.
Neither receipt can be rebound to a successor exchange.

The [operation-specific current-limit contract](../tesla/gen3-current-limit-operation-v1.md#registry-owned-request-and-response-framing)
describes a separately scoped consumer. Operation contracts supply additional
requirements, not transport authority or live write qualification.

This contract is offline-validated production-path documentation, not a device
compatibility, physical qualification, support, deployment, or live-I/O claim.
The transport owns endpoint lifecycle, raw evidence, framing, and correlation.
The registry still owns profile qualification and read/private-operation admission;
vendor codecs own decoding; semantic projection, gateway composition, and
persistence policy remain outside this contract.

## Validation and compatibility

Before send, validate endpoint identity, unit identifier, exact profile
selection, operation admission, function-code bound, payload bound, retry
policy, and response policy. Any failed validation is no-send.

New vendor profiles may reuse existing private function-code values only when
their codec selection remains endpoint- and profile-scoped. A new vendor codec
must not change the behavior of a replay retained for another profile.
