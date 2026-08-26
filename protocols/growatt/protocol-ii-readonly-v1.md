# Growatt Protocol II Read-Only Candidate V1

## Scope

This profile defines a caller-selected native Growatt Modbus RTU Protocol II
v1.24 TL3-X capability for MAX, MID, and MAC families using holding and input
ranges 0 through 249. It is a native Growatt map, not SunSpec. Automatic
cross-family detection is not part of this contract; a caller supplies the
exact family and version selection.

## Transport and addressing

The candidate uses Modbus RTU with addressed units 1 through 254. Unit 0 is
broadcast and is forbidden for read operations. Each register is one 16-bit
word. Requests use FC03 for holding registers and FC04 for input registers.
FC06 and FC16 are outside this read-only profile.

Register addresses are zero-based PDU offsets. Register and multi-register
numeric values are big-endian. ASCII fields preserve exact register extent and
remove only terminal NUL or space padding.

## Identity tuple

An offline candidate fixture must contain one coherent FC03 snapshot with:

- offsets 9 through 14, six words, for primary and control firmware text;
- offsets 23 through 27, five words, for native serial text;
- offset 43, one word, for the device type code;
- offsets 82 and 83, two words, for the model-letter build tuple; and
- offset 88, one word, for the Modbus protocol version.

Manufacturer text, unit readability, one firmware field, or register range
alone is insufficient.

The initial exact family gate accepts only a fixture declared as Protocol II
v1.24 TL3-X MAX/MID/MAC with a device type and model tuple explicitly mapped by
that fixture. Unknown device type, malformed ASCII, a protocol value outside
the selected schema, or disagreement among identity fields remains
`insufficient_evidence`.

## Native identity capability

A qualified runtime identity contains the selected family, unicast unit,
normalized firmware text, native serial text, device type code, the two-word
model-build pair, Modbus protocol version, and the five exact FC03 identity
slices in their declared order. Each field comes from the exact identity tuple
above; it is not inferred from a related Growatt family.

The runtime API may carry its configured endpoint and transport context with
this native observation. Public documentation and fixtures use synthetic
identity values and do not publish installation-specific identifiers, captures,
or endpoint coordinates. A failed tuple gate produces no partial identity
projection.

The currently enumerated operation is FC03 identity acquisition. This contract
does not define an FC06 or FC16 control operation, so no control command is
constructed from it. A later exact operation contract may add command
construction and fake execution without making a real-device write automatic.

## Offline telemetry candidate

After the identity tuple passes, a fixture may decode bounded FC04 telemetry
from the 0 through 249 input range using an exact family schema. Fields not
present in that schema remain opaque words. Sentinels, scale, signedness, word
width, and units belong to the exact field definition and are never inferred
from a similar Growatt family.

The downstream POC must prove deterministic fixture decoding. This
specification does not register an automatic detector or claim support for
TL-X, TL-XH, TL-XH US, MAX 1500V, MAX-X LV, MOD TL3-XH, MIX, SPA, or SPH
ranges.

## Failure and overlap

A Growatt fixture that also satisfies a SunSpec signature or any Huawei family
tuple is ambiguous and produces no profile match. Registration order, vendor
name, unit number, or score must not pick a winner.

Malformed extents, inconsistent identity reads, unknown schema revision,
unsupported register range, timeout, or exception produces no send and no
partial publication. All live operations remain denied in this version.

Executable fixture decoding and negative-overlap proof belong to the consuming
profile registry. This page creates no admission by itself.
