# SunSpec Additional Model Evidence V1

## Status

This packet is the FMV3-M7-01 evidence boundary for standard SunSpec model
expansion. It is not an implementation or support statement. The candidate
sets below remain manufacturer-neutral and do not alter the currently admitted
Fronius chain.

## Primary Source

The authoritative input is the Apache-2.0 `sunspec/models` repository.
Helianthus consumes only the model definitions from that catalogue. This page independently
summarizes model identity and admission constraints; it does not reproduce the
upstream JSON model files.

## Candidate Sets

| Candidate | Model IDs | Disposition | M7 boundary |
| --- | --- | --- | --- |
| Integer AC meter | `201`, `202`, `203`, `204` | `PROFILE_CANDIDATE` | Read-only decoding may be evaluated in M7-02. |
| Float AC meter | `211`, `212`, `213`, `214` | `PROFILE_CANDIDATE` | Must prove canonical equivalence with the integer family before promotion. |
| Environmental telemetry | `302` through `308` | `PROFILE_CANDIDATE` | Irradiance, module temperature, orientation, location, and meteorological facts need separate canonical capability review. |
| Grid and control models | `125` through `145` | `EVIDENCE_ONLY` | Read-only decoding may be researched, but no write, control, or activation authority exists. |

Models `125` through `145` include pricing, scheduling, grid-support curves,
ride-through settings, and extended settings. Their presence in the public
model catalog does not authorize Helianthus writes. FC05, FC06, FC0F, FC10,
FC16, FC17, or any vendor write operation remains forbidden.

## Detection And Chain Rules

The only fixed detector PDU is the existing SunSpec signature read: configured
unit, FC03, PDU offset `40000`, quantity `2`. After a valid signature and Common
Model, each candidate is discovered by the generic `(model_id, model_length)`
header walk. Dynamic block reads remain bounded by the model length and the
runtime maximum of 125 registers per PDU.

FC04 may be used only by a separately versioned profile whose authoritative
model contract assigns a candidate to input registers. This packet does not
change the currently deployed FC03-only Fronius acquisition profile.

Unknown standard model IDs remain structurally retained as opaque blocks with
provenance. Repeated IDs retain occurrence order. A malformed length, missing
terminator, unsupported schema revision, or ambiguous model definition fails
that candidate closed without invalidating other structurally valid blocks.

## Admission Requirements

M7-02 may admit only a bounded subset that proves:

- exact upstream commit and model-file identity;
- model ID, declared length, schema revision, field type, units, scale, sentinel,
  enum, bitfield, string, accumulator, and repeated-group behavior;
- integer/scale-factor and float equivalence where both families exist;
- no vendor names or firmware assumptions in the standard decoder;
- no canonical fact promotion before a versioned capability contract exists;
- no write path, even for standard fields marked writable upstream.

The candidate set is therefore evidence-qualified but not catalog-admitted.

## Grid-support hand-write surface

The sections above are the M7 admission boundary. This section records the
hand-write surface of the grid-support points. Each encoded point builds one
function 16 request for its own register span. The surface builds that request
and sends nothing until the operation is called. A value the point cannot
represent produces no request. A scaled point whose scale factor is not a
usable value is not offered. A repeating point of a curve is offered only when
that curve's `ReadOnly` word is the read-write value. Declared from the
specification. A hardware test is a later level.

The access source is named for each encoded point. A point left out because no
source establishes write access is named with that reason. A point the SunSpec
model definition marks read-write, and that this surface leaves out, is named
separately.

### Encoded from the published controls contract

The source is this repository's published controls contract
([`controls-v1.md`](../protocols/sunspec/controls-v1.md)). The hand-call table
there marks these points read-write:

- Model 123: `Conn_WinTms`, `Conn_RvrtTms`, `Conn`, `WMaxLimPct_WinTms`,
  `WMaxLimPct_RvrtTms`, `WMaxLimPct_RmpTms`, `OutPFSet_WinTms`,
  `OutPFSet_RvrtTms`, `OutPFSet_RmpTms`, `VArPct_WinTms`, `VArPct_RvrtTms`,
  `VArPct_RmpTms`, `VArPct_Mod`.
- Model 124: `WChaGra`, `WDisChaGra`, `InOutWRte_WinTms`, `InOutWRte_RvrtTms`,
  `InOutWRte_RmpTms`, `ChaGriSet`.

The same contract names these setter points, and the SunSpec model definition
marks them read-write. The surface encodes them as well:

- Model 123: `WMaxLimPct`, `WMaxLim_Ena`.
- Model 124: `StorCtl_Mod`, `OutWRte`, `InWRte`.

### Encoded from the SunSpec model definition

The source is the SunSpec model definition. This repository's published
grid-code contract
([`grid-code-settings-v1.md`](../protocols/sunspec/grid-code-settings-v1.md))
records that access. The surface encodes each point that record marks
read-write. Models 125 through 145, 703, 707, 708, and 709 have no SemReg
element in that contract.

Fixed points:

- Model 125: `ModEna`, `SigType`, `Sig`, `WinTms`, `RvtTms`, `RmpTms`.
- Model 126: `ActCrv`, `ModEna`, `WinTms`, `RvrtTms`, `RmpTms`.
- Model 127: `WGra`, `HzStr`, `HzStop`, `HysEna`, `ModEna`, `HzStopWGra`.
- Model 128: `ArGraMod`, `ArGraSag`, `ArGraSwell`, `ModEna`, `FilTms`,
  `DbVMin`, `DbVMax`, `BlkZnV`, `HysBlkZnV`, `BlkZnTmms`, `HoldTmms`.
- Model 129 and model 130: `ActCrv`, `ModEna`, `WinTms`, `RvrtTms`, `RmpTms`.
- Model 131 and model 132: `ActCrv`, `ModEna`, `WinTms`, `RvrtTms`, `RmpTms`.
- Model 133: `ActSchd`, `ModEna`.
- Models 134 through 144: `ActCrv`, `ModEna`, `WinTms`, `RvrtTms`, `RmpTms`.
- Model 145: `NomRmpUpRte`, `NomRmpDnRte`, `EmgRmpUpRte`, `EmgRmpDnRte`,
  `ConnRmpUpRte`, `ConnRmpDnRte`, `AGra`.
- Model 703: `ES`, `ESVHi`, `ESVLo`, `ESHzHi`, `ESHzLo`, `ESDlyTms`,
  `ESRndTms`, `ESRmpTms`.
- Models 707, 708, and 709: `Ena`, `AdptCrvReq`.

Repeating points:

- Model 126: `ActPt`, `DeptRef`, `V1` through `V20`, `VAr1` through `VAr20`,
  `CrvNam`, `RmpTms`, `RmpDecTmm`, `RmpIncTmm`.
- Model 129 and model 130: `ActPt`, `Tms1` through `Tms20`, `V1` through
  `V20`, `CrvNam`.
- Model 131: `ActPt`, `W1` through `W20`, `PF1` through `PF20`, `CrvNam`,
  `RmpPT1Tms`, `RmpDecTmm`, `RmpIncTmm`.
- Model 132: `ActPt`, `DeptRef`, `V1` through `V20`, `W1` through `W20`,
  `CrvNam`, `RmpPt1Tms`, `RmpDecTmm`, `RmpIncTmm`.
- Model 133: `ActPts`, `StrTms`, `RepPer`, `IntvTyp`, `XTyp`, `X_SF`, `YTyp`,
  `Y_SF`, `Nam`, `WinTms`, `RmpTms`, `X1` through `X10`, `Y1` through `Y10`.
- Model 134: `ActPt`, `Hz1` through `Hz20`, `W1` through `W20`, `CrvNam`,
  `RmpPT1Tms`, `RmpDecTmm`, `RmpIncTmm`, `RmpRsUp`, `SnptW`, `WRef`,
  `WRefStrHz`, `WRefStopHz`.
- Model 135 and model 136: `ActPt`, `Tms1` through `Tms20`, `Hz1` through
  `Hz20`, `CrvNam`.
- Models 137, 138, 139, and 140: `ActPt`, `Tms1` through `Tms20`, `V1`
  through `V20`, `CrvNam`.
- Models 141, 142, 143, and 144: `ActPt`, `Tms1` through `Tms20`, `Hz1`
  through `Hz20`, `CrvNam`.
- Model 707, on the structural path of `MustTrip`, `MayTrip`, and `MomCess`:
  `ActPt`, `V`, `Tms`.
- Model 708: `MustTrip.ActPt`, `MustTrip.V`, `MustTrip.Tms`,
  `MayTrip.ActPt`, `MayTrip.V`, `MayTrip.Tms`, `MomCess.ActPt`, `MomCess.V`,
  `MomCess.Tms`.
- Model 709: `MustTrip.ActPt`, `MustTrip.Hz`, `MustTrip.Tms`,
  `MayTrip.ActPt`, `MayTrip.Hz`, `MayTrip.Tms`, `MomCess.ActPt`, `MomCess.Hz`,
  `MomCess.Tms`.

The 32-bit points in that model 708 and model 709 list, `Tms` on model 708
and `Hz` and `Tms` on model 709, use the multi-register data-encoding rule in
the [model-chain contract](protocol-routing-vendor-sunspec-model-chain-v1.md).

### Left out because no source establishes write access

The SunSpec model schema default is read when a point omits `access`. The
published contract marks the same points read-only, or does not mark them
writable. The surface leaves them out for that reason.

- Model 120, every point: `ID`, `L`, `DERTyp`, `WRtg`, `WRtg_SF`, `VARtg`,
  `VARtg_SF`, `VArRtgQ1`, `VArRtgQ2`, `VArRtgQ3`, `VArRtgQ4`, `VArRtg_SF`,
  `ARtg`, `ARtg_SF`, `PFRtgQ1`, `PFRtgQ2`, `PFRtgQ3`, `PFRtgQ4`, `PFRtg_SF`,
  `WHRtg`, `WHRtg_SF`, `AhrRtg`, `AhrRtg_SF`, `MaxChaRte`, `MaxChaRte_SF`,
  `MaxDisChaRte`, `MaxDisChaRte_SF`, `Pad`.
- Model 121: `ID`, `L`, `WMax_SF`, `VRef_SF`, `VRefOfs_SF`, `VMinMax_SF`,
  `VAMax_SF`, `VArMax_SF`, `WGra_SF`, `PFMin_SF`, `MaxRmpRte_SF`,
  `ECPNomHz_SF`.
- Model 122, every point: `ID`, `L`, `PVConn`, `StorConn`, `ECPConn`,
  `ActWh`, `ActVAh`, `ActVArhQ1`, `ActVArhQ2`, `ActVArhQ3`, `ActVArhQ4`,
  `VArAval`, `VArAval_SF`, `WAval`, `WAval_SF`, `StSetLimMsk`, `StActCtl`,
  `TmSrc`, `Tms`, `RtSt`, `Ris`, `Ris_SF`. The published controls contract
  states that model 122 measurements and status points are read-only.
- Model 123: `ID`, `L`, `WMaxLimPct_SF`, `OutPFSet_SF`, `VArPct_SF`.
- Model 124: `ID`, `L`, `ChaState`, `StorAval`, `InBatV`, `ChaSt`,
  `WChaMax_SF`, `WChaDisChaGra_SF`, `VAChaMax_SF`, `MinRsvPct_SF`,
  `ChaState_SF`, `StorAval_SF`, `InBatV_SF`, `InOutWRte_SF`.
- Model 125: `ID`, `L`, `Sig_SF`, `Pad`.
- Model 126: `ID`, `L`, `NCrv`, `NPt`, `V_SF`, `DeptRef_SF`, `RmpIncDec_SF`,
  `ReadOnly`.
- Model 127: `ID`, `L`, `WGra_SF`, `HzStrStop_SF`, `RmpIncDec_SF`, `Pad`.
- Model 128: `ID`, `L`, `ArGra_SF`, `VRefPct_SF`, `Pad`.
- Model 129 and model 130: `ID`, `L`, `NCrv`, `NPt`, `Tms_SF`, `V_SF`, `Pad`,
  `ReadOnly`.
- Model 131: `ID`, `L`, `NCrv`, `NPt`, `W_SF`, `PF_SF`, `RmpIncDec_SF`,
  `ReadOnly`, `Pad`.
- Model 132: `ID`, `L`, `NCrv`, `NPt`, `V_SF`, `DeptRef_SF`, `RmpIncDec_SF`,
  `ReadOnly`.
- Model 133: `ID`, `L`, `NSchd`, `NPts`, `Pad`, `ActIndx`.
- Model 134: `ID`, `L`, `NCrv`, `NPt`, `Hz_SF`, `W_SF`, `RmpIncDec_SF`,
  `ReadOnly`.
- Model 135 and model 136: `ID`, `L`, `NCrv`, `NPt`, `Tms_SF`, `Hz_SF`,
  `Pad`, `ReadOnly`.
- Model 137 and model 138: `ID`, `L`, `NCrv`, `NPt`, `Tms_SF`, `V_SF`, `Pad`,
  `ReadOnly`.
- Model 139 and model 140: `ID`, `L`, `NCrv`, `NPt`, `Tms_SF`, `V_SF`,
  `CrvType`, `ReadOnly`.
- Model 141 and model 142: `ID`, `L`, `NCrv`, `NPt`, `Tms_SF`, `Hz_SF`,
  `Pad`, `ReadOnly`.
- Model 143 and model 144: `ID`, `L`, `NCrv`, `NPt`, `Tms_SF`, `Hz_SF`,
  `CrvType`, `ReadOnly`.
- Model 145: `ID`, `L`, `Rmp_SF`.
- Model 703: `ID`, `L`, `ESDlyRemTms`, `V_SF`, `Hz_SF`.
- Model 707: `ID`, `L`, `AdptCrvRslt`, `NPt`, `NCrvSet`, `V_SF`, `Tms_SF`,
  `ReadOnly`.
- Model 708: `ID`, `L`, `AdptCrvRslt`, `NPt`, `NCrvSet`, `V_SF`, `Tms_SF`,
  `ReadOnly`.
- Model 709: `ID`, `L`, `AdptCrvRslt`, `NPt`, `NCrvSet`, `Hz_SF`, `Tms_SF`,
  `ReadOnly`.

### SunSpec read-write points this surface leaves out

The SunSpec model definition marks the points below read-write. The published
controls hand-call table does not name them, and the surface does not encode
them.

- Model 121: `WMax`, `VRef`, `VRefOfs`, `VMax`, `VMin`, `VAMax`, `VArMaxQ1`,
  `VArMaxQ2`, `VArMaxQ3`, `VArMaxQ4`, `WGra`, `PFMinQ1`, `PFMinQ2`,
  `PFMinQ3`, `PFMinQ4`, `VArAct`, `ClcTotVA`, `MaxRmpRte`, `ECPNomHz`,
  `ConnPh`. Model 121 scale factors and `ID` and `L` omit `access` and are
  named in the section above.
- Model 123: `OutPFSet`, `OutPFSet_Ena`, `VArWMaxPct`, `VArMaxPct`,
  `VArAvalPct`, `VArPct_Ena`.
- Model 124: `WChaMax`, `VAChaMax`, `MinRsvPct`.

## Model 703 enter-service voltage thresholds

`ESVHi` and `ESVLo` are percent of normal voltage. The decoder reports the
unit `Pct` for both, and the published grid-code contract records the same
unit. Declared from the specification. A hardware test is a later level.
