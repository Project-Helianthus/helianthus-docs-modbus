# Tesla Wall Connector Gen3 HSC RTU contract

## Scope and separation

This contract defines the Wall Connector Gen3 Home Site Controller profile carried in Modbus-shaped RTU frames. It is distinct from the Tesla legacy Wall Connector RS-485 contract. It must not use the legacy SLIP framing, checksum, command vocabulary, or qualification predicate.

This page defines the transport and version boundary. Named TEDAPI operation records and their request and response shapes are defined by the Tesla TEDAPI operation catalog.

## Serial and activation

The Gen3 HSC serial format is 115200 baud, eight data bits, no parity, and one stop bit. Before an exchange, the endpoint must complete the device-originated activation sequence: `TESLA` followed by NUL and then `PASS` followed by NUL. An activation failure, timeout, reset, unexpected frame, or loss of the selected profile disables the HSC exchange state.

## RTU framing

An RTU frame is:

```text
node | function | payload | crc-low | crc-high
```

The CRC is CRC16-Modbus with low byte first. A payload contains zero through 252 bytes and a complete frame contains four through 256 bytes. The usual configured HSC node is `0x10`; it is not a detector, broadcast address, or universal identity.

## Function boundary

FC100, FC101, and FC102 are private function-code values selected only by this Gen3 profile. FC100 uses `length:u8 | message[length]`. FC101 and FC102 requests use `length:u8 | request[length]`; their normal responses remain bounded native payloads until an operation-specific contract assigns a response structure.

These values are not globally reserved and do not select a Tesla codec outside a configured Gen3 profile.

## Exact version profiles

`wc3_24_28_3` and `wc3_24_44_3` are known HSC observations, not a version whitelist. An unenumerated version is recorded as `compatible_candidate` when its separately supplied HSC activation, private-function, and operation capabilities are compatible; otherwise it is `unknown`. `compatible_candidate` retains an unenumerated Gen3 version with its native payloads.

No numeric minimum version is asserted by this contract. The version label alone does not grant a HSC operation or live exchange. Compatibility evaluates version evidence independently from HSC activation, private-function path, and operation-schema capabilities. A legacy Wall Connector identity never qualifies this profile.

## Qualification

Qualification requires an explicit endpoint, configured node, exact version profile, compatible activation state, bounded single-flight correlation, and an operation contract. A frame that parses successfully is not itself a capability, admission, or completion claim.

## Native retention

Native runtime records retain bounded payloads, including unknown fields, exactly. Named operation records preserve their compatibility version, function, direction, transaction state, and native request or response bytes. Unknown data remains native rather than being discarded or projected into a semantic model.

## Native operation records

The FC100 operation catalog defines version-scoped native operation records. A
record retains its selected Gen3 profile, operation version, private function
code, request and response direction, normal or exception outcome, and the
complete bounded native payload for each retained request or response. The FC100 catalog applies only to the Gen3 profile; it does not select or reinterpret a legacy Wall Connector frame.

The Gen3 native operation catalog is defined in the TEDAPI protocol contract.
Known operation names describe the applicable request and terminal container,
but unknown fields and values remain part of the native payload. FC101 and FC102 retain the same native record context, while their normal payloads remain opaque unless a separate version-scoped operation contract assigns a named structure.

## EVSE current-limit records

Only the `wc3_24_44_3` operation version qualifies this contract. Persistent current configuration is FC100 family `6`, request tag `7`, terminal tag `8`. Its `settings.maxOutputCurrentAmps` value is an integer number of amperes.

Temporary provisional current configuration is family `6`, request tag `25`, terminal tag `26`. Its native request fields are `limitCurrentMaxAmps` in amperes, `limitTimeoutS`, and `inhibitCharging`. The terminal is an acknowledgement only; correlated family-`6` tag-`27` to tag-`28` readback is required to confirm a retained provisional value.

Persistent and provisional limits remain distinct. For interoperable EVSE requests, the final-pilot current floor is 6 A and the timeout is finite from 1 through 86399 seconds. Zero timeout remains unresolved and is not an interoperable request value. Native records retain the bounded request, terminal, and readback context without inferring a watt limit or a result for another version.

## MCP read-only current-limit projection

The no-argument `modbus.v1.tesla.gen3.evse.current_limit.get` tool projects only already-injected records for `wc3_24_44_3`. The projection is `READ_ONLY`: it always reports `outbound_allowed` as `false`, constructs no request, performs no acquisition, and never sends a frame.

Its optional persistent object retains the integer-A `max_output_current_amps` fact with the bounded family-6 t7 request and t8 terminal payloads. Its optional provisional object retains `limit_current_max_amps`, `limit_timeout_s`, and `inhibit_charging` with all four bounded payloads: t25 request, t26 acknowledgement, t27 readback request, and t28 readback terminal. A provisional object is available only when that complete correlated sequence is retained.

Each object is validated independently. An invalid object is not projected, but a complete qualified sibling remains available even when the provider reports an error. If neither object qualifies, the tool returns no projected data with a structured error.

The projection does not define a setter, must not infer a watt limit, and does not make zero timeout interoperable. It does not expose a result for another operation version or assign semantics to FC101 or FC102.

## Safety boundary

Offline codecs, request construction, and fake or replay dispatch may represent documented read and mutation operations. This contract does not authorize a live transmission, hardware action, deployment, or credential use. A live state-changing command requires action-time operator confirmation.

## Compatibility

The Gen3 HSC profile is independent from the legacy Wall Connector RS-485 profile. It does not provide a fallback to legacy SLIP, and the legacy profile does not provide a fallback to FC100, FC101, or FC102.
