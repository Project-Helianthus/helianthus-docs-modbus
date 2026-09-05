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

### Exact 24.44.3 body and evidence contract

This table qualifies body decoding only for `wc3_24_44_3`. It records newly
authored field metadata from the exact signed 24.44.3 artifact; it does not
reproduce a source schema, implementation, capture, or sender recipe.

Artifact SHA-256: `a7c9104450879a8f0943f83dda76c865c2bb5de1cfca3d6afc1a328ea1633806`.
Descriptor-tree SHA-256: `41863115905a67530956526df456439e72fdafc4a81afdf6129521aa94da4b67`.
Complete descriptor-row SHA-256: `79f28d7d613b6bd83dfbe0682d045cf2da95a03109d7dfc95fe03e06393a419f`.

Wire type 0 is a varint and wire type 2 is a nested length-delimited message.
t7/t8 use singular field 1 (wire type 2) containing settings field 1 (wire type 0, signed int32 amperes).
t25/t28 use singular field 1 (wire type 2) containing provisional fields 1 and 2 (wire type 0, uint32) and field 3 (wire type 0, bool).
t28 additionally carries distinct singular field 2 (wire type 0, uint32) for configured current.
t26 and t27 have empty bodies.

| Body | Exact 24.44.3 interpretation |
| --- | --- |
| t7 ConfigureSettings request | The nested settings current is the requested persistent integer-ampere value. Other settings members remain raw native evidence. |
| t8 ConfigureSettings terminal | t8 is getter-populated returned persistent settings state, not an acknowledgement. Its nested current is a returned persistent integer-ampere value. |
| t25 SetProvisional request | The nested values are requested provisional current in integer amperes, timeout in seconds, and inhibit-charging boolean. |
| t26 terminal | t26 is an acknowledgement only and cannot confirm an applied provisional value. |
| t27 request | Empty readback request. |
| t28 terminal | The nested values are returned provisional current, timeout, and inhibit state. Its distinct outer field 2 is returned configured current in integer amperes. |

The exact descriptor records are bounded static evidence. Addresses are main
image virtual addresses; offsets are in the signed container.

| Descriptor | VA / offset | SHA-256 |
| --- | --- | --- |
| t7 request | `0x1f107a90` / `0x107bac` | `27e8ac77bd8f14aa9400567d273d29618a56832f0241dec2285a145d19d097da` |
| shared settings | `0x1f108754` / `0x108870` | `b80f647be57fa7c44c38878895d1f5527c778e34ec0df74503a0684878c54b88` |
| t8 response | `0x1f107abc` / `0x107bd8` | `2a5fc2d9d93deea774467c7cdd900274a95f1bba1ca5d1b71323e402052133b4` |
| t25 request | `0x1f10810c` / `0x108228` | `4fff4964cdf246200ccd9d477b2350b505d211bffc66686d827140a41dca11b8` |
| shared provisional values | `0x1f108710` / `0x10882c` | `f20e2a1b3076fe646e0590c4f789e4e15f086c8895b39384b50643a90d385d9c` |
| t26 empty response | `0x1f108130` / `0x10824c` | `259b801526162e10c9a25b1d9ad910a708496802150207c4ce26aa0c24137942` |
| t27 empty request | `0x1f107d88` / `0x107ea4` | `5ed96649b6e57e5dca5ff8609aad42cb9f96fabace3531a1c41fb3ef1af050e7` |
| t28 response | `0x1f107db4` / `0x107ed0` | `d8a01e37163023537bce557f6144b457d97780a16b1cb567392c04cb72ac65f8` |

The handler/readback evidence keeps persistent, provisional, configured, and
effective/pilot current distinct. No t7--t28 body is an effective/pilot-current
fact.

| Evidence role | VA / offset | SHA-256 |
| --- | --- | --- |
| WC family-6 handler | `0x1f037d9c` / `0x37eb8` | `dbc8f5730047a6d3078275408b8608bef7250c570814cb92d4f04b711c637923` |
| t8 settings-state builder | `0x1f037c14` / `0x37d30` | `a818d9e08fbd11f438fad710afd189d06adce12f2f5496851578cf19e0aeb614` |
| t25 three-value enqueue | `0x1f03d510` / `0x3d62c` | `b0e30bc93c3af943ea572b4320c0355a570ebd4f5aeed0790b196c6b81c9eb59` |
| selector-20 snapshot update | `0x1f03ccd0` / `0x3cdec` | `212af65c444a0a3ccba72fc69334c9ec09648839fa6130dab97678734bcfe394` |
| t28 four-word readback copy | `0x1f03cf6c` / `0x3d088` | `3bd43ed16ffe6f06eab4e08ab9f23c33397989ca523c4b98d928a246cd5ad48a` |

A t28 body has no nonce, timestamp, or generation counter. It cannot establish
that no intervening actor changed provisional state. An offline decoder must
retain t25 requested values and t28 returned values independently and report a
match or mismatch without claiming causal confirmation.

Unknown members remain retained as raw evidence; malformed encodings and duplicate documented singular members are rejected by Helianthus decoder policy.
An omitted scalar is retained as absent at wire and zero at the firmware default;
it is not assigned an `unlimited`, disabled, or expiry meaning. Zero current and zero timeout remain unknown.

No sender, dispatcher, transport activation, operation authorization, or live-device claim follows from this decoder contract.

## MCP read-only current-limit projection

The no-argument `modbus.v1.tesla.gen3.evse.current_limit.get` tool projects only already-injected records for `wc3_24_44_3`. The projection is `READ_ONLY`: it always reports `outbound_allowed` as `false`, constructs no request, performs no acquisition, and never sends a frame.

Its optional persistent object retains the integer-A `max_output_current_amps` fact with the bounded family-6 t7 request and t8 terminal payloads. Its optional provisional object retains `limit_current_max_amps`, `limit_timeout_s`, and `inhibit_charging` with all four bounded payloads: t25 request, t26 acknowledgement, t27 readback request, and t28 readback terminal. A provisional object is available only when that complete correlated sequence is retained.

Each object is validated independently. An invalid object is not projected, but a complete qualified sibling remains available even when the provider reports an error. If neither object qualifies, the tool returns no projected data with a structured error.

The projection does not define a setter, must not infer a watt limit, and does not make zero timeout interoperable. It does not expose a result for another operation version or assign semantics to FC101 or FC102.

## Safety boundary

Offline codecs, request construction, and fake or replay dispatch may represent documented read and mutation operations. This contract does not authorize a live transmission, hardware action, deployment, or credential use. A live state-changing command requires action-time operator confirmation.

## Compatibility

The Gen3 HSC profile is independent from the legacy Wall Connector RS-485 profile. It does not provide a fallback to legacy SLIP, and the legacy profile does not provide a fallback to FC100, FC101, or FC102.
