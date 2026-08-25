# Tesla Energy Device API over Modbus RTU

## Scope and non-goals

This specification defines the Tesla Home Site Controller (HSC) read-only
interoperability profile carried in Modbus RTU-shaped frames. It defines frame
validation, opaque vendor function handling, qualification gates, and safe
runtime reporting.

It does not define configuration, firmware update, pairing, trust management,
contactor, inverter, battery, or other control operations. It does not define a
Tesla Modbus/TCP service, arbitrary TEDAPI operation admission, or field
semantics for FC101 or FC102.

## Terminology

An **initiator** sends a request. A **responder** returns a response. **HSC**
denotes the Tesla flavor addressed by this profile. **TEDAPI payload** denotes a
bounded opaque nanopb message. **Qualified** means admitted by explicit
configuration and applicable capability and version gates. **Opaque** means
bytes are retained without assigning fields, units, enums, or commands.

## Endpoint roles

The initiator owns local serialization, deadlines, retry policy, redaction, and
operation admission. The responder accepts a configured node and vendor
function. A capture or replay endpoint is receive-only or offline and must not
open a live serial endpoint or transmit frames.

## Serial settings

The HSC profile uses 115200 baud, eight data bits, no parity, and one stop bit.
A character is ten bit times. The configured receiver separation is 35 bit
times, equivalent to 3.5 character times at this format.

## Frame structure

Each RTU frame is:

```text
node | function | payload | crc-low | crc-high
```

`node` and `function` are one byte each. Payload contains zero through 252
bytes. The entire frame contains four through 256 bytes. No fragmentation,
transaction identifier, or additional outer length field is defined.

## Byte order and CRC

CRC is CRC16-Modbus with initial value `0xffff` and reflected polynomial
`0xa001`. It covers `node`, `function`, and every payload byte. CRC is appended
low byte first.

## Frame and payload limits

An implementation must reject a frame shorter than four bytes or longer than
256 bytes. It must reject a payload longer than 252 bytes. It must not truncate,
split, concatenate, or retry a rejected frame.

## Node addressing and configuration

The usual HSC node is `0x10`. This value is a configurable profile default, not
a universal detector. Enabling this flavor requires explicit local
configuration and applicable passive compatibility and version gates. A valid
frame, a matching node, or a readable response alone is insufficient to admit a
vendor request.

Tesla HSC codec selection is profile-scoped. The generic transport treats each
private function code as a byte value and does not select a Tesla codec from
that byte. A normal HSC payload is decoded only after the endpoint, node,
profile, and operation selected this profile.

## Function 100

An FC100 data PDU is `length:u8 | message[length]`. The data PDU contains one
through 252 bytes. `length` is zero through 251 and must equal the exact number
of following bytes. A PDU containing only `00` is syntactically valid and
contains an empty message; it does not admit an operation. No uint16 length is
transmitted in the RTU frame.

A missing prefix, an inexact prefix, or trailing bytes must be rejected and
must cause no send.

FC100 can produce an echoed request frame and a later result frame. The echo is
an intermediate response, not proof of operation success. Implementations
must classify intermediate and terminal frames inside one bounded single-flight
transaction and must quarantine late, unrelated, malformed, or timed-out
frames so they cannot satisfy a later request. A terminal response may arrive
without an echo.

FC100 is not a general TEDAPI admission mechanism. This profile admits no
outbound FC100 operation, including a request with a locally valid envelope. A
later compatible profile may admit one particular operation only with an
explicit non-mutating per-operation contract, version qualification, read-only
admission, and replay-safe declaration. The Tesla profile alone owns FC100
interpretation; it does not create a global function-code handler.

### Qualified WC vitals operation

This version defines a qualified operation: `tesla.hsc.fc100.wc_vitals.v1`.
It is a semantic read-only snapshot operation and is not a configuration,
control, or discovery operation. It is compatible only with the explicit
`tesla_hsc_modbus_v1` profile and the `wc3_24_44_3` operation version. Any
other operation version, missing capability, unqualified endpoint or node,
missing replay-safe declaration, or unknown response shape must cause no send.

The nested request message is exactly `32 02 0a 00`; therefore its FC100 PDU is
exactly `04 32 02 0a 00`. The outer message selects WC messages, the nested
message selects the empty vitals request, and no caller-supplied request fields
are permitted. This byte sequence is an operation descriptor, not an endpoint
probe or a transmission instruction.

An echoed PDU exactly equal to this request PDU is an FC100 intermediate. A
successful terminal PDU selects one bounded WC-message response tag `2`. The
tag-`2` body is a bounded opaque terminal body. This version defines no member,
field number, wire type, scalar, enum, repeated value, unit, scale, range, or
field-presence contract within that body. Its values, field names, units, identifiers, and raw bytes are not projected by this version; a decoder may retain only terminal-tag presence, terminal-body length, digest, and structural replay metadata. An omitted inner value must not be interpreted as a scalar
zero, an empty repeated value, or an empty nested member. A normal terminal PDU that does not match this success shape is not a vitals result and must fail closed as a redacted operation failure. The generic exception-response rules remain separate.

Semantic read-only classification does not claim that the responder has no
ephemeral transport-side effects. It grants no configuration, control, pairing,
trust, firmware, or other persistent authority.

### Qualified Common system-information operation

This version defines a qualified Common system-information operation:
`tesla.hsc.fc100.common_system_info.v1`. It is a semantic read-only snapshot
operation and is not a configuration, control, or discovery operation. It is
compatible only with the explicit `tesla_hsc_modbus_v1` profile and the
`wc3_24_44_3` operation version. Any other operation version, missing
capability, unqualified endpoint or node, missing replay-safe declaration, or
unknown response shape must cause no send.

The nested request message is exactly `22 02 12 00`; therefore its FC100 PDU is
exactly `04 22 02 12 00`. The outer message selects Common messages, the nested
message selects the empty system-information request, and no caller-supplied
request fields are permitted. This byte sequence is an operation descriptor,
not an endpoint probe or a transmission instruction.

An echoed PDU exactly equal to this request PDU is an FC100 intermediate. A
successful terminal PDU selects one bounded Common-message response tag `3`.
The tag-`3` body is a bounded opaque terminal body. This version defines no
member, field number, wire type, scalar, enum, repeated value, unit, scale,
range, or field-presence contract within that body. Its values, field names,
units, identifiers, and raw bytes are not projected by this version; a decoder
may retain only terminal-tag presence, terminal-body length, digest, and
structural replay metadata. An omitted inner value must not be interpreted as a
scalar zero, an empty repeated value, or an empty nested member. A normal
terminal PDU that does not match this success shape is not a system-information
result and must fail closed as a redacted operation failure. A normal Common error body is a terminal application failure; the generic exception-response rules remain separate.

Semantic read-only classification does not claim that the responder has no
ephemeral transport-side effects. It grants no configuration, control, pairing,
trust, firmware, or other persistent authority.

### MCP qualified WC vitals replay

An MCP WC vitals replay view may be emitted only by an injected provider that
already selected `tesla.hsc.fc100.wc_vitals.v1`, `tesla_hsc_modbus_v1`, and
`wc3_24_44_3`. It exposes only the operation and version qualification, replay
kind, snapshot length, and snapshot digest. Its `outbound_allowed` value is
always `false`. An unavailable or invalid provider result produces no data.
The view never creates a request, opens a serial endpoint, invokes a generic
transport exchange, or falls back to FC101 or FC102. It exposes no raw bytes,
snapshot values, field names, identifiers, control meaning, or runtime
activation state.

### Read-only replay metadata

An offline FC100 decoder may retain the nested-message length, the numeric
first protobuf key field number, its numeric wire type, and a deterministic
digest of the nested message. The field number is 1 through 536870911 and the
wire type is 0 through 5. Raw nested bytes, protobuf field names, values,
operation identity, capability, and send authority are not projected.
Invalid, truncated, overflowed, or out-of-range keys are rejected.

A complete offline wire summary may retain the total FC100 envelope length,
nested-message length, deterministic digest, entry count, and an ordered list
of at most 64 entries. Each entry contains only its numeric field number and
numeric wire type. Values are consumed only to validate wire boundaries and
are never retained or projected. Wire types 3 and 4 are valid only as paired
group boundaries with the same field number. A malformed, truncated,
oversized, unpaired, or over-count summary is rejected.

## Functions 101 and 102

An FC101 or FC102 request PDU is `length:u8 | request[length]`. The request
PDU contains one through 252 bytes. `length` is zero through 251 and must equal
the exact number of following bytes. A PDU containing only `00` is
syntactically valid and contains an empty request. This request syntax does not
admit transmission or assign read-only semantics.

An FC101 or FC102 normal response is zero through 252 opaque bytes. This
version defines no response length-prefix or field contract for either
function. A normal response is one terminal response or an exception; FC100
echo and result handling does not apply. Implementations may frame, classify,
retain, and replay response bytes offline, but must not infer field names,
enums, units, control meaning, or operation admission from them.

Live outbound FC101 and FC102 are denied in the initial profile, including MCP
operations, even when their request syntax is locally valid. Future typed
support requires a compatible specification version, qualified capability,
explicit admission policy, and conformance vectors. Their byte values remain
Tesla profile details and do not reserve those values for another vendor profile
at a different endpoint.

## Exception responses

An exception response has `function | 0x80` and exactly one status byte before
the CRC. An unknown function can return status `1`. FC101 or FC102 codec failure
can return status `4`. Other status values remain opaque numeric values unless a
later version defines them.

## Timing, deadlines, and frame separation

Frame separation is 3.5 character times. The initiator applies a bounded
request deadline and a bounded post-timeout quarantine. Partial frames and
trailing bytes are not carried into a subsequent transaction. An implementation
must preserve an explicit timeout result rather than guessing a response.

## Concurrency and arbitration

This profile assumes one locally serialized initiator. It makes no
multi-initiator arbitration, collision detection, carrier-sense, or
listen-before-talk guarantee. An implementation must not use concurrent sends,
probe by broadcast, or infer safe multi-initiator operation.

## Request and response state machine

```text
idle -> locally_validated -> sent -> waiting
waiting -> intermediate -> waiting
waiting -> terminal -> idle
waiting -> deadline -> quarantine -> idle
locally_validated -> denied -> idle
```

Only an admitted, locally valid request can reach `sent`. A malformed or
unrelated response reaches `quarantine`, never `terminal`.

The `intermediate` transition applies only to FC100. FC101 and FC102 transition
directly from `waiting` to a terminal response, exception, or deadline.

## Fail-closed validation rules

Before sending, validate configuration, node, function, payload bound, request
length prefix, capability, version, read-only admission, and replay policy. Any
failed validation produces no send. FC101 and FC102 produce no send in this
version even when their request PDU is locally valid. Vendor PDUs have zero
retries by default. A retry is permitted only for an admitted replay-safe
request and is bounded by an explicit policy.

## Unknown payload and field retention

Opaque payloads and unknown fields are retained as bounded byte sequences with
their frame metadata and direction. FC101 and FC102 normal responses retain
their raw bytes without length-prefix decoding. Retained bytes are not converted
to a value, enum, unit, capability, or command. Retention must preserve enough
framing information for deterministic offline replay while enforcing size limits
and redaction rules.

## Runtime provenance

Runtime records include contract version, flavor, configured node, function,
direction, frame length, CRC result, transaction state, capability disposition,
timing outcome, and a redacted payload digest. Records must distinguish locally
validated, sent, intermediate, terminal, timeout, exception, and quarantined
outcomes. Records contain no raw sensitive payload by default.

### MCP FC100 summary projection

An MCP FC100 summary view may be emitted only from an injected, locally
validated wire summary. It exposes only the qualification (`framing_only` or
`qualified_read_only`), total envelope length, nested-message length, entry
count, ordered numeric field-number and wire-type entries, and payload digest.
Its `outbound_allowed` value is always `false`. A missing or invalid provider
summary produces an unavailable result with no summary data. The view never
exposes raw bytes, values, field names, operation identity, capability, request
construction, or control meaning.

## Security, privacy, and redaction

The initial profile is read-only and disabled by default. Raw payload bytes,
serial numbers, device identifiers, account material, and private coordinates
must not be published through logs, MCP, fixtures, or diagnostics. Public MCP
results expose length, digest, function, timing, and redacted categorical
metadata only. Offline fixtures use sanitized values.

## Capability and version gates

Framing support is not a capability claim. Detection performs no vendor
transmission. A flavor is usable only when explicit configuration, passive
compatibility evidence, capability profile, and version compatibility all pass.
Unknown versions and missing capability information remain framing-only and
deny outbound operations.

## Conformance vectors and sanitized examples

The following vectors validate frame construction, envelope syntax where
defined, and CRC byte order only:

```text
FC100 empty message: 10 64 00 5a c5
FC100 one-byte message: 10 64 01 00 44 ab
FC101 empty request: 10 65 00 5b 55
FC102 empty request: 10 66 00 5b a5
FC100 exception status 1: 10 e4 01 fa c5
FC101 exception status 4: 10 e5 04 3b 56
FC102 exception status 4: 10 e6 04 3b a6
FC100 qualified terminal with synthetic opaque body: 10 64 06 32 04 12 02 08 01 31 81
FC100 qualified Common system-information request: 10 64 04 22 02 12 00 54 3d
FC100 qualified Common terminal with synthetic opaque body: 10 64 06 22 04 1a 02 08 01 31 71

FC100 missing prefix: 10 64 0d 9b
FC100 trailing byte: 10 64 00 00 45 3b
FC100 inexact prefix: 10 64 02 00 44 5b
```

The first four vectors are normal request or FC100 data syntax only and do not
admit a live request. The final three vectors have valid CRC bytes but must be
rejected by FC100 envelope validation. There is no FC101 or FC102 normal
response vector in this version.

## Interoperability levels

1. **Framing only:** validate bounded RTU frames and preserve opaque bytes.
2. **FC100 envelope:** validate FC100 length prefix and response phases.
3. **Qualified read-only TEDAPI operations:** transmit only explicitly
   allowlisted, version-compatible, replay-safe operations.
4. **FC101/FC102 opaque:** validate request envelopes, retain raw normal
   response bytes, and perform no live transmission or typed interpretation.
5. **Future typed FC101/FC102:** requires a later compatible contract and
   explicit qualification.

## Compatibility and versioning

This profile is versioned as a compatibility contract. A newer implementation
must preserve the fail-closed behavior of this version for unknown fields,
unknown status values, unsupported functions, and unqualified capabilities.
Typed interpretations or new outbound operations require a new compatible
contract version and corresponding conformance coverage.
