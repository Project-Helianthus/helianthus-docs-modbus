# SunSpec DER Read-Only Contract V2

## Scope

This page defines a bounded, offline-only SunSpec DER decoding contract. It is
not a device support claim, permission to acquire from a live endpoint, vendor
flavor, runtime catalog registration, or control interface. Existing SunSpec
V1 behavior remains unchanged.

The contract covers the `SunS` signature, Common Model 1, Models 701, 702, 713,
and 714, and the terminal block. It does not make a proprietary Huawei or
Growatt register map SunSpec.

## Schema revision

The executable offline schema key is `sunspec.models@90b4a331-v2`. Its
publication and licensing boundary is recorded in the protocol applicability
and licensing specification.

This key is separate from `sunspec.models@7abdf898-v1`. V1 and V2 decoder
definitions and caches are revision-isolated. V1 outputs remain unchanged.
The V2 key selects offline decoder definitions only; it does not register a
runtime catalog or claim support.

## Chain boundary

A V2 chain begins with the `SunS` signature and Common Model 1. Common must
occur first and exactly once. Common Model 1 with declared length 66 is the
only V2 Common tuple. Common Model 1 length 65 is a V1 compatibility tuple and
remains opaque under V2.

After Common, supported and unsupported blocks retain observed order. Repeated
identifiers remain distinct occurrences. A structurally valid block without an
exact V2 decoder remains opaque with its raw words, declared length, ordinal,
and acquisition provenance. The terminal block is model `0xffff` with length
zero.

## Model scope

The bounded V2 scope contains Common Model 1 and Models 701, 702, 713, and 714.

| Model | V2 data-register length | Read-only role |
| --- | --- | --- |
| 1 | 66 | Common device information |
| 701 | 153 | DER AC measurement |
| 702 | 50 | DER capacity |
| 713 | 7 | DER storage capacity |
| 714 | `18 + 25*NPrt` | DER DC measurement with repeated ports |

A V2 offline decoder selects only by model identifier, exact declared length,
and `sunspec.models@90b4a331-v2`. A known identifier with another length
remains opaque. No fixed ordering is inferred among Models 701, 702, 713, and
714.

## Model 714 geometry

Model 714 has data-register length `18 + 25*NPrt`. The fixed extent is 18 data
registers and each repeated port consumes exactly 25 data registers. `NPrt` is
bounded from 0 through 2620 so the computed length remains representable by the
16-bit model-length field.

If `NPrt` is unavailable, an unavailable sentinel, overflows, or does not match
the declared length, Model 714 is a raw-only opaque block. No count is inferred
from remaining words. A partial repeated group or extent overrun has the same
result. A repeated port retains its own index and raw source span; no port is
merged with another port or with another Model 714 occurrence.

## Value interpretation boundary

Register words and multi-register values are big-endian. A SunSpec `uint64`
uses four big-endian words; zero is a valid value and all one-bits means not
implemented. Exact unsigned scaling must not pass through an `int64` or
floating-point representation, truncate, or round.

A `sunssf` value is valid only from -10 through 10. The value `0x8000` means
not implemented. An absent, unavailable, or invalid referenced scale factor
cannot produce a scaled fact.

Strings have a fixed word extent and contain UTF-8 text. A string beginning
with word `0x0080` followed only by zero padding is a valid empty string. An
all-zero string extent is unavailable. Otherwise, the first NUL requires a
zero-only tail. Spaces before the terminator are data and are not trimmed.
Invalid UTF-8 or a non-NUL byte after termination is invalid encoding.

Unknown enum values and unknown bit masks retain numeric raw provenance. An
unknown mandatory value cannot qualify a decoded model. Fields described as
read/write are observed state only and create no write method, authorization,
retry, or control operation.

## Fixture boundary

Offline conformance uses synthetic, non-vendor fixtures. Fixtures retain chain
order, repeated occurrences, raw spans, and opaque blocks without vendor
identity, endpoint, serial number, live capture, or support claim.

The fixture set must cover Common with 701 and 702; Common with 701, 702, 713,
and a repeated-port 714; 714 count and length mismatch; zero and all-one
`uint64`; invalid or missing scale factors; invalid string encoding; preserved
spaces; unknown enum and bit-mask values; repeated occurrences; and an
unsupported model length retained as opaque.

## Offline implementation boundary

This contract permits a separate offline registry implementation to use the V2
schema key and synthetic fixtures. No standard profile admission, runtime
catalog registration, vendor admission, automatic acquisition, telemetry
publication, capability admission, or consumer exposure may be derived from
this contract.

No Modbus transport change is implied. No control-capable point authorizes a
Modbus write. No gateway, deployment, or live-device operation is part of this
contract.
