# Growatt 1xSxxP ESS BMS RS485 Read-Only Candidate V2.02

## Scope

This contract defines a default-denied, offline read-only candidate for the
Growatt 1xSxxP ESS battery protocol over Modbus RTU. It is a battery-to-inverter
interoperability protocol, not Growatt inverter Protocol II and not SunSpec.

This page permits a bounded offline decoder for an externally supplied,
revision-declared observation. A decoder may retain only fields with an exact,
versioned definition and must retain every other admitted word as opaque.

This page creates no catalog entry, executable detector, automatic runtime
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

The `1xSxxP` label describes this protocol topology.
It does not automatically apply the contract to any commercial battery,
inverter, logger, or later
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

Only the typed extension words listed below are decoded. Every other extension
word remains opaque until an exact, versioned field definition establishes its
distinct byte and word encoding. Reserved or unknown fields inside an admitted
slice stay opaque and retain their position.

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

## Typed read-only fields

The typed subset is limited to the fields listed below. It is decoded only
after the complete four-slice observation and exact revision tuple pass their
existing validation; no individual slice produces a partial typed result.

- `0x0001` and `0x0002` are version byte pairs: the high byte precedes the low
  byte for the MCU and gauge versions, respectively.
- `0x000D` and `0x000E` hold the BMS and battery-pack identity components.
  Company and generation occupy the low and high bytes, respectively, and are
  numeric protocol values rather than a global vendor detector.
- At `0x0013`, the high byte must be zero. Its low two bits are the observed
  operating state: soft-starting, standby, charging, or discharging. Any other
  state encoding rejects the typed result.
- SOC is the low byte at `0x0015` and must be in the inclusive range 0 through
  100. Its high byte must be zero. Voltage at `0x0016` is unsigned in 10 mV
  units. Current at `0x0017` is signed two's-complement and uses 10 mA units.
  Temperature at `0x0018` is signed degrees Celsius and must be between -127
  and 127.
- Remaining and full-charge capacity at `0x001A` and `0x001B` are unsigned in
  10 mAh units. Cycle count at `0x001E` is an unsigned 16-bit count.
- Only `0x0100`, `0x0101`, `0x0102`, `0x0104`, `0x0105`, and `0x0106` have typed
  extension meanings: charge time in seconds; current-cycle charge capacity in
  0.1 Ah; average cell voltage in mV; floating pack voltage in 0.1 V; and
  cumulative charge and discharge capacity in 0.1 Ah. `0x0103`, `0x0107`
  through `0x010B`, and both `0x010D` slice words remain opaque.

Warnings, errors, company-specific status interpretation, calibration, and
every control-adjacent value remain opaque. Decoding any field is observation
only and cannot authorize a request or control action.


## Writes and controls

FC10 Preset Multiple Registers, address allocation, handshake writes, force
charge, protection settings, calibration, BMS control, and every field marked
W or WR are unconditional `NO_SEND`. This remains true even if an offline
fixture contains a structurally valid request or a device would accept it.

Offset 0x010C and offsets 0x010F through 0x0161 are outside the admitted read
plan because they contain control or writable calibration authority. FC05,
FC06, FC0F, FC10, FC17, private functions, and broadcast are not fallback
operations.

## Decoder and runtime boundary

A bounded offline decoder is permitted only for an externally declared
revision tuple, one explicitly selected unicast unit, and the exact FC03 slices
listed above. It must retain raw words with barcode, serial, endpoint, and
installation identity absent. Every decoded field needs an exact versioned
byte-order, word-order, signedness, and scaling definition; otherwise it stays
opaque. Repeated-pack data requires an exact extent and explicit pack identity;
without those, no repeated fact is emitted.

No bounded decoder creates catalog registration, executable detection,
automatic runtime admission, telemetry publication, or a support claim. A
synthetic identity assembled from the document is not a substitute for a
separately qualified identity decision.

## Collision and failure behavior

An observation that also satisfies Growatt Protocol II, SunSpec/Fronius, or a
Huawei family is ambiguous and produces no match. Registration order, vendor
name, unit address, score, or first response never selects a winner.

Timeout, CRC failure, exception, malformed length, unsupported revision,
partial tuple, unknown company/generation, repeated-pack inconsistency, or
encoding uncertainty produces `insufficient_evidence`, no send, and no partial
publication.
