# Tesla Gen3 HSC EVSE over Modbus RTU

## Scope and non-goals

This profile is limited to EVSE interoperability for energy management. It retains serial identity, model, firmware version, charging state, current capability, electrical observations, faults/interlocks, and capability/version provenance. It also defines only explicitly qualified EVSE enable, disable, and charging-current-limit controls. Non-EVSE operations are out of scope.

## Terminology

Native data is the complete bounded payload with profile and transaction context. An EVSE limit is a charging-current limit.

## Endpoint roles

The initiator owns serialization, deadlines, correlation, and native retention. Offline replay does not open a serial endpoint.

## Serial settings

Gen3 HSC uses 115200 baud, eight data bits, no parity, and one stop bit.

## Frame structure

`node | function | payload | CRC16-Modbus`; FC100 through FC102 are selected only by this Gen3 profile.

## Byte order and CRC

CRC16-Modbus is low byte first.

## Frame and payload limits

A frame is 4 through 256 bytes and a payload is 0 through 252 bytes.

## Node addressing and configuration

Node `0x10` is common but configured explicitly.

## Function 100

An FC100 PDU is `length:u8 | message[length]`, with exact length equality.

### FC100 EVSE operation registry

| Operation | EVSE use | request | terminal |
|---|---|---|---|
| GetVitals | charging state and aggregate electrical observations | exact empty | bounded native terminal |
| GetLifetimeStats | energy observations | exact empty | bounded native terminal |
| GetLoadSharingNetworkState | current capability and limits | exact empty | bounded native terminal |
| GetSystemInfo | serial/model/firmware identity, capability and version provenance | exact empty | bounded native terminal |

Terminals retain their complete bounded native body and unknown fields. Per-phase values remain native when present.

EVSE charging-current limit control, enable, and disable require an independently qualified request shape, unit and range where applicable, acknowledgement, and post-command confirmation. This version has no qualified Gen3 control setter.

## Functions 101 and 102

FC101 and FC102 use bounded native payloads but have no EVSE operation mapping in this version.

## Exception responses

An exception has `function | 0x80` and exactly one status byte.

## Timing, deadlines, and frame separation

Frame separation is 3.5 character times; timeout and partial frames are quarantined.

## Concurrency and arbitration

One locally serialized initiator is required.

## Request and response state machine

`idle -> validated -> waiting -> terminal | exception | deadline -> idle`.

## Fail-closed validation rules

Require endpoint/node, profile/version, bounds, correlation, and an EVSE operation contract. Unknown data grants no control.

## Unknown payload and field retention

Retain bounded native payloads exactly with function, direction, profile, version, and outcome.

## Runtime provenance

Records retain complete native EVSE payload with version, function, direction, and outcome.

## Security, privacy, and redaction

Runtime native EVSE data is retained; public examples use synthetic values.

## Capability and version gates

Version alone does not admit an operation.

## Conformance vectors and sanitized examples

`10 64 00 5a c5` is a valid empty FC100 envelope.

## Interoperability levels

Framing; native EVSE observation; qualified EVSE state/measurement; future qualified current-limit control.

## Compatibility and versioning

This Gen3 profile is separate from legacy Wall Connector RS-485.
