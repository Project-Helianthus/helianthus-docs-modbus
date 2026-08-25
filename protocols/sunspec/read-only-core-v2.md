# SunSpec DER Read-Only Contract V2

## Scope

This page defines a bounded, offline-only SunSpec DER decoding contract. It is
not a device support claim, permission to acquire from a live endpoint, vendor
flavor, runtime catalog registration, or control interface. Existing SunSpec
V1 behavior remains unchanged.

The contract covers the `SunS` signature, Common Model 1, Models 701, 702, 703,
713, 714, 715, 802, 803, 804, 805, 806, and 807, and the terminal block. It does not make a proprietary
Huawei or Growatt register map SunSpec.

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

The bounded V2 scope contains Common Model 1 and Models 701, 702, 703, 713, 714,
715, 802, 803, 804, 805, 806, 807, and 808.

| Model | V2 data-register length | Read-only role |
| --- | --- | --- |
| 1 | 66 | Common device information |
| 701 | 153 | DER AC measurement |
| 702 | 50 | DER capacity |
| 703 | 17 | DER enter-service observed state |
| 713 | 7 | DER storage capacity |
| 714 | `18 + 25*NPrt` | DER DC measurement with repeated ports |
| 715 | 7 | DER controller observed state |
| 802 | 62 | BESS base observed state |
| 803 | `26 + 32*NStr` | BESS bank observed state with repeated strings |
| 804 | `46 + 16*NMod` | BESS string observed state with repeated modules |
| 805 | 42 | BESS module observed state |
| 806 | 1 | Flow battery structural observed state |
| 807 | 34 | Flow battery string observed state |
| 808 | 1 | Flow battery module structural observed state |

A V2 offline decoder selects only by model identifier, exact declared length,
and `sunspec.models@90b4a331-v2`. A known identifier with another length
remains opaque. No fixed ordering is inferred among Models 701, 702, 703, 713,
714, 715, 802, 803, 804, 805, 806, 807, and 808.

## Control-observability boundary

Models 703 and 715 are control-observability only. A decoder may retain their
observed words and derived state, including points that upstream describes as
read/write, but it does not infer current control authority or a permitted
operation from those words.

No point in either model creates a write method, send authority, operation admission,
dispatch, retry, runtime activation, vendor activation, or catalog activation.
Models 704 through 712 remain outside this V2 wave and remain opaque.

## BESS base observed-state boundary

Model 802 is a fixed-geometry battery base block with declared length 62.
It occupies 64 total words including its header and has no repeated group.
Every Model 802 field is observed state only and is `NO_SEND`.

No Model 802 field creates a write method, operation dispatch, control behavior,
runtime activation, vendor activation, catalog activation, transport behavior,
gateway behavior, or live I/O. Model 801 remains excluded as deprecated.
Model 809 remains excluded pending a separate family and substructure decision.

## BESS bank and string geometry

Model 803 has data-register length `26 + 32*NStr`. `NStr` is at payload-register
offset 0. It is bounded from 0 through 2047 so the computed length remains
representable by the 16-bit model-length field. Each repeated string consumes
exactly 32 data registers.

Model 804 has data-register length `46 + 16*NMod`. `NMod` is at payload-register
offset 1. It is bounded from 0 through 4093 so the computed length remains
representable by the 16-bit model-length field. Each repeated module consumes
exactly 16 data registers.

At NMod=4093, Model 804 has declared data-register length 65534 and occupies 65536 words including header.
The maximum is valid only for an isolated synthetic offline occurrence.
It must not be used as a terminal-qualified live chain or acquisition map.
Maximum provenance retains fragmented bounded source spans whose cumulative extent is exactly 65536 words.

For either model, an unavailable sentinel, missing count, overflow, declared
length mismatch, partial repeated group, or source-span extent overrun makes the
block raw-only opaque with zero decoded facts. No count is inferred from trailing
words. A repeated group retains a model-local stable index and its exact raw
source span; repeated Model 803 and Model 804 occurrences remain distinct.

Model 803 does not infer Model 804 child occurrences from ordering, `Idx`,
`NStr`, or any other field. Model 804 does not infer a Model 803 parent from
ordering, `Idx`, `NMod`, or any other field. Every field in both models,
including `SetEna`, `SetCon`, and any upstream read/write field, is observed
state only and is `NO_SEND`.

No Model 803 or Model 804 field creates a write method, send authority,
operation admission, dispatch, retry, control behavior, runtime activation,
vendor activation, catalog activation, transport behavior, gateway behavior, or
live I/O.

## BESS module boundary

Model 805 has fixed data-register length 42 and has no repeated group. `StrIdx` and `ModIdx` are observed fields only.
Neither establishes any inferred relationship to Model 803 or Model 804.
Every Model 805 field is observed state only and is `NO_SEND`.

No Model 805 field creates a write method, send authority, operation admission,
dispatch, retry, control behavior, runtime activation, vendor activation,
catalog activation, transport behavior, gateway behavior, or live I/O.

## Flow battery structural boundary

Model 806 has fixed data-register length 1 and no effective repeated group.
`BatTBD` remains uninterpreted structural observed state. Model 806 does not infer a relationship to Models 803, 804, 805, or 807 through 809. Every Model 806 field is observed state only and is `NO_SEND`.

No Model 806 field creates a write method, send authority, operation admission,
dispatch, retry, control behavior, runtime activation, vendor activation,
catalog activation, transport behavior, gateway behavior, or live I/O.

## Flow battery string boundary

Model 807 has fixed data-register length 34 and no effective repeated group.
`Idx` and `NMod` remain observed structural fields only. Model 807 does not infer a relationship to Models 806, 808, or 809. Every Model 807 field, including control-adjacent zero-count group names, is observed state only and is `NO_SEND`.

No Model 807 field creates a write method, send authority, operation admission,
dispatch, retry, control behavior, runtime activation, vendor activation,
catalog activation, transport behavior, gateway behavior, or live I/O.

## Flow battery module boundary

Model 808 has fixed data-register length 1 and no effective repeated group.
`ModuleTBD` remains uninterpreted structural observed state. The declared stack group has count zero and is not materialized. Model 808 does not infer a relationship to Models 803 through 807 or 809. Every Model 808 field, including the zero-count `StackTBD` group name, is observed state only and is `NO_SEND`.

No Model 808 field creates a write method, send authority, operation admission,
dispatch, retry, control behavior, runtime activation, vendor activation,
catalog activation, transport behavior, gateway behavior, or live I/O.

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

The fixture set must cover Common with 701 and 702; Common with fixed 703 and
715 observed-state blocks; Common with fixed 802 observed-state words; Common
with 701, 702, 713, and a repeated-port 714; 714 count and length mismatch;
Common with Model 803 strings, Common with Model 804 modules, and Common with
fixed Model 805 observed-state words; Common with fixed Model 806 structural
observed-state words; Common with fixed Model 807 observed-state words; zero and nonzero count geometry; count
and length mismatch; zero and all-one `uint64`;
invalid or missing scale factors; invalid string
encoding; preserved spaces; unknown enum and bit-mask values; repeated
occurrences; and an unsupported model length retained as opaque.

## Offline implementation boundary

This contract permits a separate offline registry implementation to use the V2
schema key and synthetic fixtures. No standard profile admission, runtime
catalog registration, vendor admission, automatic acquisition, telemetry
publication, capability admission, or consumer exposure may be derived from
this contract.

No Modbus transport change is implied. No control-capable point authorizes a
Modbus write. No gateway, deployment, or live-device operation is part of this
contract.
