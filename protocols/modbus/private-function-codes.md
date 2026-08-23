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

## Validation and compatibility

Before send, validate endpoint identity, unit identifier, exact profile
selection, operation admission, function-code bound, payload bound, retry
policy, and response policy. Any failed validation is no-send.

New vendor profiles may reuse existing private function-code values only when
their codec selection remains endpoint- and profile-scoped. A new vendor codec
must not change the behavior of a replay retained for another profile.
