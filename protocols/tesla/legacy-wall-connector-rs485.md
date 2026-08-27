# Tesla legacy Wall Connector RS-485 contract

## Scope and identification

This contract defines the legacy Tesla Wall Connector RS-485 protocol family.
The legacy profile is a pre-Gen3 candidate and is not an assertion that every Wall Connector Gen2 implements this protocol. An implementation identifies this flavor explicitly; it does not infer it from a Tesla name, a serial setting, a frame prefix, or a Gen3 profile.

This is not a Modbus profile and is not a TEDAPI-over-Modbus profile.

## Serial and framing

The legacy serial format is 9600 baud, eight data bits, no parity, and one stop bit. It uses a two-wire half-duplex RS-485 bus.

An encoded frame is:

```text
C0 | escaped(message) | C0
```

The byte substitutions are exact:

```text
C0 -> DB DC
DB -> DB DD
```

Bytes outside a delimited frame are ignored. A decoder must bound a frame before allocating or retaining it and reject an unterminated or malformed escape sequence.

## Checksum

The final message byte is an eight-bit additive checksum:

```text
sum(message_without_checksum[1:]) & 0xff
```

It excludes the first command byte and the checksum byte itself. A receiver validates the checksum after unescaping and before interpreting a command family.

## Command-family boundary

The command families are `FB`, `FC`, and `FD`. The known link and heartbeat forms include `FCE1`, `FBE2`, `FDE2`, `FBE0`, and `FDE0`. Their fields remain native records unless a separately versioned operation contract assigns semantics.

A legacy command byte `FC` is not a Modbus function code. FC100, FC101, and FC102 are not part of this contract. A legacy decoder must not call a Gen3 HSC codec, a Modbus RTU parser, or a TEDAPI envelope parser.

## EVSE dynamic-current records

This candidate legacy-family contract retains the `FBE0` request and `FDE0`
state records for EVSE energy-management current allocation. It is not an
assertion that every Gen2 unit implements these records.

`FDE0` retains the reported state byte, the current allocation, and the actual
measured current as separate native values. The allocation is not the actual
current and neither value is a power setpoint.

The absolute offer states are `0x05` for pre-charge and `0x09` for charging.
Each carries a big-endian unsigned 16-bit current value in centiamperes. A
decoder preserves the state and raw bounded record; capability and device
limits are not inferred from the wire range alone.

`0x06` and `0x07` are relative changes of 2 A. They remain native-only and do
not form an absolute EVSE allocation. `0x08` remains unknown and unmapped.

## Qualification

This profile is selected only by explicit local configuration and a compatible legacy Wall Connector identity. It has two evidence tiers:

- `build_confirmed` records the exact known compatibility label `legacy_cc_4_5_10`.
- `family_compatible` records a locally declared legacy protocol family when its framing and command-family evidence matches, without claiming a firmware build or an exclusive hardware generation.

The family-compatible tier accepts a locally declared legacy protocol family without claiming a firmware build. A missing, contradictory, or unknown identity remains `unknown` and does not inherit a build-specific field interpretation.

## Native retention

Native runtime records retain bounded decoded frames and unknown command payloads exactly. Unknown fields, command variants, and values remain native data; they are not converted to a Gen3 TEDAPI field, a Modbus register, or a protocol-neutral fact.

## Safety boundary

Offline codecs, request construction, and fake or replay dispatch may represent documented command forms. This contract does not authorize a live transmission, hardware action, deployment, or credential use. A live state-changing command requires action-time operator confirmation.

## Compatibility

The legacy profile is independent from Gen3 HSC RTU. No common codec, profile, version predicate, operation identifier, or response rule is implied by both protocols.
