# Growatt Protocol II Read-Only Candidate V1

## Scope

This profile defines an offline candidate for the Growatt Modbus RTU Protocol
II v1.24 TL3-X class: MAX, MID, and MAC families using holding and input ranges
0 through 249. It is a native Growatt map, not SunSpec. It is disabled for
automatic detection and live acquisition.

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
- offset 43, one word, for the device type code;
- offsets 82 and 83, two words, for the model-letter build tuple; and
- offset 88, one word, for the Modbus protocol version.

Serial-number offsets 23 through 27 are sensitive and are not read or used as
identity. Manufacturer text, unit readability, one firmware field, or register
range alone is insufficient.

The initial exact family gate accepts only a fixture declared as Protocol II
v1.24 TL3-X MAX/MID/MAC with a device type and model tuple explicitly mapped by
that fixture. Unknown device type, malformed ASCII, a protocol value outside
the selected schema, or disagreement among identity fields remains
`insufficient_evidence`.

## Public identity projection

A qualified identity projection may contain only the selected family, the
normalized firmware text, the device type code, the two-word model-build pair,
and the Modbus protocol version. Each projected value comes from the exact
identity tuple above; it is not inferred from a related Growatt family.

Serial-number words, unit identifiers, raw slices, endpoints, and transport
details are excluded from this projection. This projection does not add
automatic detection, telemetry, endpoint acquisition, control, or a device
support claim. A failed tuple gate produces no partial identity projection.

## Offline telemetry candidate

After the identity tuple passes, a fixture may decode bounded FC04 telemetry
from the 0 through 249 input range using an exact family schema. Fields not
present in that schema remain opaque words. Sentinels, scale, signedness, word
width, and units belong to the exact field definition and are never inferred
from a similar Growatt family.

The downstream POC must prove deterministic fixture decoding. This
specification does not register an automatic detector, enable an endpoint, or
claim support for TL-X, TL-XH, TL-XH US, MAX 1500V, MAX-X LV, MOD TL3-XH, MIX,
SPA, or SPH ranges.

## Failure and overlap

A Growatt fixture that also satisfies a SunSpec signature or any Huawei family
tuple is ambiguous and produces no profile match. Registration order, vendor
name, unit number, or score must not pick a winner.

Malformed extents, inconsistent identity reads, unknown schema revision,
unsupported register range, timeout, or exception produces no send and no
partial publication. All live operations remain denied in this version.

Executable fixture decoding and negative-overlap proof belong to the consuming
profile registry. This page creates no admission by itself.
