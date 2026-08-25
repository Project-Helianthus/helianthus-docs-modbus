# SunSpec V2 Model 707 Nested Template Contract

## Scope and isolation

This page defines the offline structural template for exactly Model 707 under
the V2 schema. It describes one bounded occurrence at a time and preserves
raw evidence when that occurrence is invalid. It makes no product claim and
does not create live acquisition or operational behavior.

## Template identity and top-level map

The template identity is exactly schema revision `sunspec.models@90b4a331-v2` and Model 707.
The two occurrence header words are `ID:uint16` at offset 0 and `L:uint16` at
offset 1. Payload offsets begin at occurrence-word offset 2:

| Payload offset | Occurrence-word offset | Field | Type and words |
| --- | --- | --- | --- |
| 0 | 2 | `Ena` | `enum16`, 1 |
| 1 | 3 | `AdptCrvReq` | `uint16`, 1 |
| 2 | 4 | `AdptCrvRslt` | `enum16`, 1 |
| 3 | 5 | `NPt` | `uint16`, 1 |
| 4 | 6 | `NCrvSet` | `uint16`, 1 |
| 5 | 7 | `V_SF` | `sunssf`, 1 |
| 6 | 8 | `Tms_SF` | `sunssf`, 1 |

`NPt` and `NCrvSet` are at occurrence-word offsets 5 and 6. Let `P` equal
`NPt` and `C` equal `NCrvSet`. `P` and `C` each accept 0 through 65534; `0xffff` is unavailable and zero is valid.

## Nested curve layout

The exact declared payload length is `L = 7 + C*(4 + 9*P)`. For `i` beginning
at 1, `Crv[i]` starts at payload offset `7 + (i-1)*(4 + 9*P)`. It contains:

1. `ReadOnly:enum16`, one word.
2. `MustTrip.ActPt:uint16`, then `P` `MustTrip.Pt[j]` groups.
3. `MayTrip.ActPt:uint16`, then `P` `MayTrip.Pt[j]` groups.
4. `MomCess.ActPt:uint16`, then `P` `MomCess.Pt[j]` groups.

Every nested `Pt[j]` has the same three-word layout. `V` is one `uint16` word scaled by `V_SF`; `Tms` is two big-endian `uint32` words scaled by `Tms_SF`.
`Crv[i].MustTrip.Pt[j].V` and `Crv[i].MustTrip.Pt[j].Tms` are separate paths.
The corresponding `MayTrip` and `MomCess` paths are also separate and retain
their own occurrence-relative ranges.

Within one `Crv[i]`, the three `ActPt` words are at relative offsets `+1`,
`+2 + 3*P`, and `+3 + 6*P`. The first point of each nested curve is one word
after its `ActPt`; subsequent points advance by three words. `ActPt` is
observed data and never selects or changes the layout.

## Per-occurrence validation and bounds

An occurrence is structurally valid only when its header has Model 707, its
declared length equals the formula above, both counts are available and in
range, and the exact raw spans cover every occurrence word without a partial
group. The current isolated offline boundary requires `L <= 65534`.
This leaves at most 65536 words including the two header words. Checked
arithmetic applies before calculating every product, extent, emitted entry, or
allocation. A separate chain boundary may be smaller and remains independently
enforced.

`P` and `C` are never inferred from `L`, an `ActPt` value, or trailing words.
An occurrence does not create a relationship to another occurrence or model.

## Failure boundary

Invalid geometry remains raw-only with zero typed facts and exact raw spans.
This includes a wrong identifier or length, unavailable count, count or extent
overflow, a length mismatch, a boundary excess, incomplete raw coverage, or a
partial group. No partial typed result is retained.

## Observed-state boundary

Every field is observed state only and is `NO_SEND`. In particular, `Ena`,
`AdptCrvReq`, `ReadOnly`, every `ActPt`, and every point remain observations
even where their wire access permits modification.
