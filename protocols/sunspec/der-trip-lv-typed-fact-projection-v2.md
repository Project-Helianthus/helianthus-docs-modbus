# SunSpec V2 Model 707 Typed-Fact Projection Contract

## Scope and non-emission

This page defines the stable typed-fact names, value rules, and public offline
projection API that a separately reviewed implementation may use for exactly
Model 707 under `sunspec.models@90b4a331-v2`. It does not change the current raw-only behavior, select a model, or authorize a profile.

Every observation in this contract is `NO_SEND`, including fields whose wire
access permits modification. This contract creates no operation, write method,
device support claim, acquisition behavior, or live-system behavior.

## Public offline projection API

`ProjectSunSpecStructuralFacts(snapshot SunSpecChainSnapshot)` accepts exactly one immutable
`SunSpecChainSnapshot` and returns zero or more immutable `SunSpecStructuralProjection` records.
It is a separately invoked, offline projection query; it neither extends nor
changes `DecodeOccurrence` or `DecodeChain`.

Each record provides `WireKey()`, `SchemaRevision()`, `Ordinal()`, `RawWords()`,
`SourceSpans()`, and `Facts()`. Getter results are detached copies. It has no `DecoderKey()`, admission, qualification, topology, or
`SunSpecDecodedChain` identity. A projection is therefore neither a decoder selection nor a profile, capability, or product result.

Only a complete V2 Model 707 `structural_candidate` may produce a projection.
The candidate remains a post-payload classifier: it does not itself admit a
decoder or emit a fact. Candidate absence or malformed structural geometry produces no projection and zero facts.
The projection query does not modify an occurrence, chain snapshot, or qualification-observation JSON.

It must not accept or derive a projection from `SunSpecDecodedChain` or
`SunSpecQualificationObservation`. It must not recompute structural state from a wire key, words, spans, or
declared length; it uses only the retained private candidate sidecar.

Repeated Model 707 occurrences produce independent projections. V1, Model 708, and Model 709 produce no projection.
The projection query does not change acquisition, queueing, retry, deadline, limit, or terminal behavior.

## Stable identity and nested paths

A FieldID names a field template and never embeds an occurrence, curve, or
point index. The corresponding hierarchical path carries the exact indexes.
The following FieldIDs and paths are canonical:

- `sunspec.der.v2.707.ID` maps to `ID`.
- `sunspec.der.v2.707.L` maps to `L`.
- `sunspec.der.v2.707.Ena` maps to `Ena`.
- `sunspec.der.v2.707.AdptCrvReq` maps to `AdptCrvReq`.
- `sunspec.der.v2.707.AdptCrvRslt` maps to `AdptCrvRslt`.
- `sunspec.der.v2.707.NPt` maps to `NPt`.
- `sunspec.der.v2.707.NCrvSet` maps to `NCrvSet`.
- `sunspec.der.v2.707.V_SF` maps to `V_SF`.
- `sunspec.der.v2.707.Tms_SF` maps to `Tms_SF`.
- `sunspec.der.v2.707.Crv.ReadOnly` maps to `Crv[i].ReadOnly`.
- `sunspec.der.v2.707.Crv.MustTrip.ActPt` maps to
  `Crv[i].MustTrip.ActPt`; `sunspec.der.v2.707.Crv.MayTrip.ActPt` maps to
  `Crv[i].MayTrip.ActPt`; and `sunspec.der.v2.707.Crv.MomCess.ActPt` maps to
  `Crv[i].MomCess.ActPt`.
- `sunspec.der.v2.707.Crv.MustTrip.Pt.V` and
  `sunspec.der.v2.707.Crv.MustTrip.Pt.Tms` map to
  `Crv[i].MustTrip.Pt[j].V` and `Crv[i].MustTrip.Pt[j].Tms`.
- `sunspec.der.v2.707.Crv.MayTrip.Pt.V` and
  `sunspec.der.v2.707.Crv.MayTrip.Pt.Tms` map to
  `Crv[i].MayTrip.Pt[j].V` and `Crv[i].MayTrip.Pt[j].Tms`.
- `sunspec.der.v2.707.Crv.MomCess.Pt.V` and
  `sunspec.der.v2.707.Crv.MomCess.Pt.Tms` map to
  `Crv[i].MomCess.Pt[j].V` and `Crv[i].MomCess.Pt[j].Tms`.

Every fact retains its occurrence-relative source range and the exact ordered,
possibly fragmented raw source spans for that range.

## Requiredness and observation state

`ID`, `L`, `NPt`, and `NCrvSet` are structural requirements: the identifier,
declared length, available counts, and exact geometry must validate before any
typed fact exists. They are not a profile qualification signal.

For a valid occurrence, every listed template field is an observed fact with
`Required=false`. A non-structural unavailable or invalid value remains a raw
fact with its observation state; it is not replaced with a default and does not
establish capability or operation authority.

`NPt` and `NCrvSet` accept zero and reject `0xffff` as unavailable. A count
sentinel, count/length mismatch, arithmetic overflow, partial group, or source
span overrun makes the entire occurrence raw-only with zero typed facts.

## Types, units, and symbols

`ID`, `L`, `AdptCrvReq`, `NPt`, `NCrvSet`, every `ActPt`, and every nested `V`
are `uint16`. Each nested `Tms` is a big-endian `uint32`. A nested `V` has unit
`VNomPct`; a nested `Tms` has unit `Secs`.

`Ena`, `AdptCrvRslt`, and `Crv[i].ReadOnly` are `enum16`. Known symbols are
`Ena`: `0=DISABLED`, `1=ENABLED`; `AdptCrvRslt`: `0=IN_PROGRESS`,
`1=COMPLETED`, `2=FAILED`; and `ReadOnly`: `0=RW`, `1=R`. An otherwise valid
enum number remains its numeric observation with no substituted symbol.

For unsigned scalar types, an all-ones wire value is not implemented. It does
not become a signed value, a zero, or a default. `V_SF` and `Tms_SF` are
`sunssf` observations. A missing scale binding, unavailable scale, or invalid
scale leaves the dependent raw fact intact but produces no scaled value.

## Geometry, provenance, and isolation

The structural template contract remains authoritative for the exact Model 707
length, count offsets, nested point widths, checked bounds, and source-span
validation. No count is inferred from length, an activation point, or trailing
words. Malformed geometry produces zero typed facts and preserves the complete
raw occurrence and its source spans.

This contract is isolated to Model 707 and does not define any other model. It
preserves V1 behavior and does not change any runtime, transport, vendor,
gateway, or live-I/O boundary.
