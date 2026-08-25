# SunSpec DER Read-Only Candidate V2

## Scope

This page records a bounded candidate wave for future offline SunSpec DER
decoding. It is a protocol contract, not an executable decoder revision, a
device support claim, or permission to acquire from a live endpoint. Existing
SunSpec V1 behavior remains unchanged.

The candidate covers the `SunS` signature, Common Model 1, Models 701, 702,
713, and 714, and the terminal block. It does not extend a manufacturer flavor
and does not make a proprietary Huawei or Growatt register map SunSpec.

## Candidate catalog revision

The public logical identifier is `sunspec.models.candidate.v2`. Its model
shapes are pinned to the public Apache-2.0 SunSpec model catalogue at commit
`90b4a331dcca1d6eac69c1bead952fddcc5852e0`.

The candidate identifier is not an executable decoder key. In particular, it
must not be substituted for `sunspec.models@7abdf898-v1`, registered in a
runtime catalog, or used to claim support. A future executable revision needs
an independent contract decision and its own exact decoder keys.

## Chain boundary

A candidate chain begins with the `SunS` signature and Common Model 1. Common
must occur first and exactly once. The candidate wave uses the current
66-data-register Common block. The 65-data-register compatibility tuple remains
part of V1 only; this page does not declare the two Common lengths equivalent
for a future V2 decoder.

After Common, supported and unsupported blocks remain in observed order.
Repeated identifiers remain distinct occurrences. A structurally valid block
without an exact candidate decoder remains opaque with its raw words, declared
length, ordinal, and acquisition provenance. The terminal block is model
`0xffff` with length zero.

## Candidate model boundary

The bounded wave adds Models 701, 702, 713, and 714 to Common Model 1.

| Model | Candidate data-register length | Candidate role |
| --- | --- | --- |
| 1 | 66 | Common device information |
| 701 | 153 | DER AC measurement |
| 702 | 50 | DER capacity |
| 713 | 7 | DER storage capacity |
| 714 | `18 + 25*NPrt` | DER DC measurement with repeated ports |

A future decoder must select only by model identifier, exact declared length,
and executable schema revision. A known identifier with another length remains
opaque. No fixed ordering is invented among Models 701, 702, 713, and 714.

## Model 714 geometry

Model 714 has data-register length `18 + 25*NPrt`. The fixed extent is 18 data
registers and each repeated port consumes exactly 25 data registers. `NPrt` is
bounded from 0 through 2620 so the computed length remains representable by the
16-bit model-length field.

The declared count and length must agree exactly. Overflow, a partial repeated
group, an extent overrun, or a mismatch between `NPrt` and the available words
invalidates the candidate decode. A repeated port keeps its own index and raw
source span. Port type, numeric identifier, identifier text, DC measurements,
energy values, temperature, status, and alarm fields are not merged between
ports or between repeated Model 714 occurrences.

## Value interpretation boundary

Register words and multi-register values are big-endian. A SunSpec `uint64`
uses four words; zero is a valid value and all one-bits means not implemented.
This is distinct from `acc64`, for which zero means not accumulated.

A `sunssf` value is valid only from -10 through 10. The value `0x8000` means not
implemented. A missing, unavailable, or invalid referenced scale factor cannot
produce a scaled value.

Strings have a fixed word extent and contain UTF-8 text. The first NUL
terminates text, and every following byte in the extent must be NUL. Trailing
spaces before the terminator are data and are not trimmed. Invalid UTF-8 or a
non-NUL byte after termination is invalid encoding.

Unknown enum values and unknown bit masks retain their numeric raw provenance.
An unknown mandatory value cannot qualify a candidate model. Fields described
as read/write by SunSpec are observed state only in this candidate and create
no write method, authorization, retry, or control operation.

## Candidate fixture boundary

Future offline conformance may use independently generated, sanitized fixtures
for these two shapes:

- Common, 701, 702, and terminal; and
- Common, 701, 702, 713, 714 with two distinct ports, and terminal.

Negative fixtures must cover Model 714 count and length mismatch, repeated 714
occurrences, zero and all-one `uint64` values, invalid or missing scale factors,
invalid UTF-8, non-NUL data after termination, preserved trailing spaces,
unknown enums and bit masks, and an unsupported model length retained as
opaque. Fixtures contain no vendor identity, endpoint, serial number, live
capture, or support claim.

## Registry and runtime gate

V2 registry and runtime admission remains pending independent contract validation.
Until that decision exists, the candidate is default denied: no executable
decoder revision, catalog registration, automatic acquisition, telemetry
publication, capability admission, manufacturer flavor activation, or consumer
exposure may be derived from this page.

No Modbus transport change is implied. No control-capable point authorizes a
Modbus write. No gateway, deployment, or live-device operation is part of this
candidate contract.
