# SunSpec Read-Only Core V1

## Scope

This profile defines deterministic read-only decoding for a bounded SunSpec
model chain. The profile is vendor-neutral. A manufacturer flavor may constrain
applicability but must not redefine standard model fields.

## Chain structure

A chain begins with the `SunS` signature and Common Model 1. Each model block
starts with a 16-bit model identifier and a 16-bit model length. The length is
the number of 16-bit data registers after the header. The terminal block is
model `0xffff` with length zero.

The decoder retains block order, occurrence index, start address, declared
length, exact raw words, schema revision, and acquisition provenance. Repeated
model identifiers remain separate occurrences. A structurally valid unknown
model remains an opaque block and does not invalidate the chain.

## Initial model catalog

The V1 read-only catalog contains:

- Common Model 1;
- integer plus scale-factor inverter Models 101, 102, and 103;
- float inverter Models 111, 112, and 113;
- nameplate Model 120;
- basic settings Model 121;
- extended measurements and status Model 122;
- immediate controls Model 123 as read-only state;
- basic storage controls Model 124 as read-only state;
- multiple-MPPT Model 160;
- meter Models 201 through 204 and 211 through 214; and
- environmental Models 302 through 308.

Implementations must select a decoder by model identifier, exact model length,
and schema revision. A known identifier with an unknown length is opaque, not a
best-effort decode.

## Value rules

Register words are big-endian. Multi-register integer and float values use the
word order declared by the selected schema. Strings retain their exact word
extent and remove only terminal NUL or space padding. Enum, bitfield,
accumulator, signed and unsigned integer, float, and string fields retain their
wire type.

Scale-factor sentinels, integer not-implemented sentinels, IEEE NaN, infinity,
and unsupported enum values produce unavailable or unknown facts. They are not
converted into zero. Scale factors are applied only to their declared fields.

## Encoding equivalence

Common Model 1 plus Model 103 and Common Model 1 plus Model 113 can represent
the same three-phase inverter measurements through different wire encodings.
Equivalence is established field by field only when quantity, unit, phase,
availability, and value agree after each model's declared decoding rules. A
matching model identifier or a partially decoded block is not equivalence.

Optional Models 120, 121, 122, 123, 124, and 160 add their own standard fields.
Missing optional models remain absent. A malformed optional block invalidates
that block and any chain extent that can no longer be established safely.

## Safety and disposition

This contract admits only bounded reads and offline fixture replay. Fields
defined by control models are decoded as observed state and never create write
authority. Unknown versions, length mismatches, extent overruns, missing Common
Model 1, a missing terminal block, or ambiguous chain base produce no profile
match.
