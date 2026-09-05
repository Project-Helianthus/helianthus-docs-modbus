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

### Bounded payload layout

The post-command payload retained by this contract includes the two-byte source
ID and two-byte destination ID. The heartbeat data after those IDs is seven
bytes in protocol 1 or nine bytes in protocol 2. Therefore a typed decoder
accepts only an eleven-byte or thirteen-byte post-command payload, after the
complete frame has passed delimiter, escape, size, and checksum validation.

For `FBE0`, bytes `0..1` are the source ID, bytes `2..3` are the destination
ID, byte `4` is the state, and bytes `5..6` are the big-endian unsigned
allocated current in centiamperes. The remaining heartbeat bytes, `7..10` in
the protocol-1 form or `7..12` in the protocol-2 form, remain opaque and are
retained in the complete native frame.

The offline typed decoder accepts a complete, checksum-validated `FDE0`
response only with the same eleven-byte or thirteen-byte post-command payload
lengths. It has the same source, destination, state, and allocated-current
positions; bytes `7..8` are the separate big-endian unsigned actual current in
centiamperes. The remaining bytes, `9..10` in the protocol-1 form or `9..12`
in the protocol-2 form, remain opaque. A shorter, longer, or
wrong-direction/command frame does not produce a typed record. The decoder
retains the complete bounded frame, including every accepted opaque byte,
without assigning it additional meaning.

### Evidence and confidence

The portable layout and its field roles are **community-observed/correlated**,
not an exact-build proof. At pinned revision
[`7fb019a`](https://github.com/dracoventions/TWCManager/blob/7fb019a6838c9d15ba3b27f27458fa76c5e482d2/TWCManager.py#L1690-L1706),
TWCManager constructs `FDE0` from command, two IDs, and seven or nine
heartbeat-data bytes. Its pinned `FBE0` and `FDE0` parsers separately capture
the two IDs before the heartbeat data at
[`FBE0`](https://github.com/dracoventions/TWCManager/blob/7fb019a6838c9d15ba3b27f27458fa76c5e482d2/TWCManager.py#L3207-L3213)
and
[`FDE0`](https://github.com/dracoventions/TWCManager/blob/7fb019a6838c9d15ba3b27f27458fa76c5e482d2/TWCManager.py#L3344-L3351).
At pinned revision
[`593b722`](https://github.com/craigpeacock/TWC/blob/593b722c117e310076572b4c5ff644c3f2e56865/TWC.c#L114-L157),
the `M_HEARTBEAT` and `S_HEARTBEAT` records identify the address, state,
allocated-current, actual-current, and remaining-byte roles used here.

These public community implementations support the bounded offline layout but
do not promote it to universal device support, an exact firmware/build claim,
or a live behavioral guarantee. The separate `build_confirmed` tier remains
the only exact-build evidence tier in this contract.

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

Typed dynamic-current construction requires the selected legacy profile,
request/response direction, complete encoded frame, and caller-supplied fields
to agree. Earlier callers that supplied unvalidated raw bytes or independent
state/current values must supply this bounded frame context before they can
obtain a typed native record.
