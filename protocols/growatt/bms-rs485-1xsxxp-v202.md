# Growatt 1xSxxP ESS BMS RS485 Read-Only Candidate V2.02

## Scope

This contract defines a default-denied, offline read-only candidate for the
Growatt 1xSxxP ESS battery protocol over Modbus RTU. It is a battery-to-inverter
interoperability protocol, not Growatt inverter Protocol II and not SunSpec.

This page creates no decoder, catalog entry, automatic detector, runtime
acquisition, telemetry publication, or support claim.

## Exact applicability and revision

Applicability requires one exact, externally declared revision tuple:

- protocol family label `1xSxxP ESS`;
- file revision family `Rev2.01`;
- document header version `V2.0`; and
- cumulative change record through revision `2.02`.

These values are one combined applicability key. They are not interchangeable
version aliases and do not establish an ordering against another Growatt
protocol. No wire register in the admitted read set proves this document
revision.

The `1xSxxP` label describes this protocol topology. It does not automatically
apply the contract to any commercial battery, inverter, logger, or later
product merely because that product is branded Growatt, uses RS485, or exposes
FC03.

## Transport and addressing

The transport is Modbus RTU with a default line configuration of 9600 baud,
eight data bits, no parity, and one stop bit. Frames use the standard Modbus
CRC16 wire order. A 200 millisecond response interval is the documented
protocol expectation; an implementation still requires an explicit bounded
operation deadline and must not retry by widening the request.

Only unit addresses 1 through 247 are response-bearing candidates.
Unit 0 is broadcast and is always `NO_SEND`.
A unit is selected explicitly; there is no
unit scan, first-response selection, address fallback, or inferred default.
One request is in flight on one RTU session at a time.

## FC03 read-only boundary

All documented addresses are zero-based PDU offsets. The only admitted
function is FC03 Read Holding Registers. An offline fixture may contain these
bounded slices:

- offset 0x0001, quantity 7, for bounded firmware and gauge-version context;
- offset 0x000D, quantity 29, for company/generation, capability, status,
  telemetry, warning, topology, and cell-series context;
- offset 0x0100, quantity 12, for the read-only prefix of the 2.02 extension;
  and
- offset 0x010D, quantity 2, for the final read-only extension values before
  the writable calibration range.

The two extension slices remain opaque words until an exact clean-room fixture
proves their distinct byte and word encoding. Reserved or unknown fields inside
an admitted slice stay opaque and retain their position.

Offsets 0x0009 through 0x000C contain barcode material and are not read,
retained, or used for identity. A larger coalesced read that includes those
offsets is outside this contract.

## Offline identity tuple

The minimum offline tuple combines all of:

- MCU software version at offset 0x0001;
- BMS company and generation at offset 0x000D;
- battery-pack company and generation at offset 0x000E;
- bounded box or battery topology evidence at offset 0x001F; and
- cell-series count at offset 0x0029.

Company codes, generation values, software version, a readable unit, or one
telemetry value alone are insufficient. The company fields are scoped to this
protocol and are not a global Growatt vendor detector. Barcode, serial number,
unit address, and writable configuration are forbidden identity inputs.

Because the protocol revision is not wire-identifiable, a fixture must declare
the exact revision tuple independently and prove that its decoded identity
fields are coherent with that declaration.

## Pack topology and repeated data

The protocol can describe more than one pack or box by repeated register
regions and pack identifiers. The initial candidate does not infer a second
pack layout from the first one. Every repeated region requires an exact extent,
an explicit pack identity, duplicate detection, and a fixture proving the
mapping.

Missing, duplicate, changing, or contradictory pack identity is
`insufficient_evidence`. Disappearance does not cause a remaining pack to be
renumbered or to inherit the missing pack's values.

## Values and unknown retention

Each ordinary Modbus register is one 16-bit word. Signedness, scaling, bitfield
meaning, byte order across a field, and multi-register word order come only
from an exact field definition for this revision. They are never copied from
Growatt Protocol II, another BMS protocol, or a nearby address.

Malformed extents, impossible counts, invalid enum or bitfield values, unknown
scales, and unsupported extension fields are retained as bounded opaque words
or reject the candidate. They never become guessed telemetry.

## Writes and controls

FC10 Preset Multiple Registers, address allocation, handshake writes, force
charge, protection settings, calibration, BMS control, and every field marked
W or WR are unconditional `NO_SEND`. This remains true even if an offline
fixture contains a structurally valid request or a device would accept it.

Offset 0x010C and offsets 0x010F through 0x0161 are outside the admitted read
plan because they contain control or writable calibration authority. FC05,
FC06, FC0F, FC10, FC17, private functions, and broadcast are not fallback
operations.

## Fixture and admission gate

Registry implementation is `NO_GO` until an exact, permitted, sanitized
clean-room fixture provides:

- the complete revision tuple and a CC0-compatible fixture license;
- one admitted unicast unit and exact FC03 request slices;
- raw words with barcode, serial, endpoint, and installation identity absent;
- declared byte and word order for every decoded field;
- coherent company, generation, firmware, topology, and cell-series facts;
- repeated-pack geometry or an explicit single-pack bound; and
- negative-overlap records against Growatt Protocol II, SunSpec/Fronius, and
  native Huawei profiles.

Without that fixture, catalog registration, executable detection, automatic
runtime admission, telemetry publication, and a support claim remain disabled.
A synthetic identity assembled from the document is not a substitute.

## Collision and failure behavior

An observation that also satisfies Growatt Protocol II, SunSpec/Fronius, or a
Huawei family is ambiguous and produces no match. Registration order, vendor
name, unit address, score, or first response never selects a winner.

Timeout, CRC failure, exception, malformed length, unsupported revision,
partial tuple, unknown company/generation, repeated-pack inconsistency, or
encoding uncertainty produces `insufficient_evidence`, no send, and no partial
publication.
