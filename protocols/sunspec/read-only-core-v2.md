# SunSpec DER Read-Only Contract V2

## Scope

This page defines a bounded, offline-only SunSpec DER decoding contract. It is
not a device support claim, permission to acquire from a live endpoint, vendor
flavor, runtime catalog registration, or control interface. Existing SunSpec
V1 behavior remains unchanged.

The contract covers the `SunS` signature, Common Model 1, Models 701, 702, 703,
707, 708, 709, 713, 714, 715, 802, 803, 804, 805, 806, 807, 808, and 809, and the terminal block. It does not make a proprietary
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

The bounded V2 scope contains Common Model 1 and Models 701, 702, 703, 707, 708, 709, 713, 714, 715, 802, 803, 804, 805, 806, 807, 808, and 809.

| Model | V2 data-register length | Read-only role |
| --- | --- | --- |
| 1 | 66 | Common device information |
| 701 | 153 | DER AC measurement |
| 702 | 50 | DER capacity |
| 703 | 17 | DER enter-service observed state |
| 707 | `7 + NCrvSet*(4 + 9*NPt)` | DER Trip LV nested geometry |
| 708 | `7 + NCrvSet*(4 + 9*NPt)` | DER Trip HV nested geometry |
| 709 | `7 + NCrvSet*(4 + 12*NPt)` | DER Trip LF nested geometry |
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
| 809 | 1 | Flow battery stack structural observed state |

A V2 offline decoder selects only by model identifier, exact declared length,
and `sunspec.models@90b4a331-v2`. A known identifier with another length
remains opaque. No fixed ordering is inferred among Models 701, 702, 703, 707,
708, 709, 713, 714, 715, 802, 803, 804, 805, 806, 807, 808, and 809.

## Control-observability boundary

Model 715 is control-observability only. A decoder may retain its observed
words and derived state, including points that upstream describes as
read/write, but it does not infer current control authority or a permitted
operation from those words.

No point in Model 715 creates a write method, send authority, operation admission,
dispatch, retry, runtime activation, vendor activation, or catalog activation.

Model 703 enter-service settings are registers in the modbusreg namespace, with no SemReg element, and are decoded and callable by hand through MCP and GraphQL.
A decoder may retain Model 703 observed words and derived state, including
points that upstream describes as read/write.

Models 704 through 706 and 710 through 712 remain outside this V2 wave and remain opaque.

## DER Trip nested geometry

Models 707, 708, and 709 each have two header words followed by seven top-level
data words: `Ena`, `AdptCrvReq`, `AdptCrvRslt`, `NPt`, `NCrvSet`, a
model-specific scale factor, and `Tms_SF`. `NPt` is at payload-register offset
3 and absolute model word 5. `NCrvSet` is at payload-register offset 4 and
absolute model word 6.

Let `P` equal `NPt` and `C` equal `NCrvSet`. Their formal non-sentinel domains
are each 0 through 65534; zero is valid. Every `Crv[i]` contains `ReadOnly`,
then `MustTrip`, `MayTrip`, and `MomCess`. Each of those nested curves contains
`ActPt`, followed by `Pt[1..P]`. The exact point spans and declared
data-register-length formula are model-specific below.

`Crv[i].MustTrip.Pt[j]`, `Crv[i].MayTrip.Pt[j]`, and
`Crv[i].MomCess.Pt[j]` are distinct nested paths. An implementation must retain
their exact occurrence-relative offsets; it must not infer `P` or `C` from
`L`, `ActPt`, or trailing words. A missing or unavailable count, arithmetic
overflow, a length that does not fit `uint16`, a length that exceeds the current
isolated offline extent boundary, a declared-length mismatch, or a partial
nested group is raw-only opaque with zero decoded facts.

For a model-specific point span `S`, the zero-based payload offset of
`Crv[i]` is `7 + (i-1)*(4 + 3*S*P)`. `ReadOnly` is at that offset;
`MustTrip.ActPt`, `MayTrip.ActPt`, and `MomCess.ActPt` are respectively at
offsets `+1`, `+2 + S*P`, and `+3 + 2*S*P`. Within each nested curve,
`Pt[j]` begins one data register after `ActPt` plus `(j-1)*S`.

Models 707, 708, and 709 are registers in the modbusreg namespace, with no SemReg element, and are decoded and callable by hand through MCP and GraphQL. They do not infer relationships to one another or to Models 710 through 712. Nothing is sent unless the operation is called.

## DER Trip model-specific observed fields

Model 707 has `V_SF` and `Tms_SF`. Every nested `Pt[j]` is `V:uint16` scaled by
`V_SF` followed by `Tms:uint32` scaled by `Tms_SF`, consuming three data
registers. Its exact declared data-register length is
`L = 7 + C*(4 + 9*P)`.

Model 708 has the same source-derived point spans as Model 707:
`V:uint16` scaled by `V_SF` followed by `Tms:uint32` scaled by `Tms_SF`,
consuming three data registers per `Pt[j]`. Its exact declared data-register
length is `L = 7 + C*(4 + 9*P)`.

Model 709 has `Hz_SF` and `Tms_SF`. Every nested `Pt[j]` is `Hz:uint32` scaled
by `Hz_SF` followed by `Tms:uint32` scaled by `Tms_SF`, consuming four data
registers. Its exact declared data-register length is
`L = 7 + C*(4 + 12*P)`.

For Models 707 and 708, `S` is 3; for Model 709, `S` is 4. These type, span,
scale-factor, and offset differences are the declared geometry of each model.

## BESS base observed-state boundary

Model 802 is a fixed-geometry battery base block with declared length 62.
It occupies 64 total words including its header and has no repeated group.
Every Model 802 field is observed state only and is `NO_SEND`.

No Model 802 field creates a write method, operation dispatch, control behavior,
runtime activation, vendor activation, catalog activation, transport behavior,
gateway behavior, or live I/O. Model 801 remains excluded as deprecated.
Models 806 through 809 remain separately bounded flow battery structural leaves.

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

## Flow battery stack boundary

Model 809 has fixed data-register length 1 and no effective repeated group.
`StackTBD` remains uninterpreted structural observed state. The declared cell group has count zero and is not materialized. Model 809 does not infer a relationship to Models 803 through 808. Every Model 809 field, including the zero-count `CellTBD` group name, is observed state only and is `NO_SEND`.

No Model 809 field creates a write method, send authority, operation admission,
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

## Monitoring capabilities

This section names read-only monitoring facts for the decoded V2 measurement models. It does not admit a profile, a runtime catalog, or a new read.
Each fact's presence and whether it is required are declared from the public SunSpec model definitions.
An absent or unimplemented point is omitted and never reported as zero.
A scale factor that is unimplemented makes its value absent.
Monitoring facts use registry-native identifiers.
Each monitoring capability is read-only and adds no request beyond the chain read that already exists.
A V2 point reuses a V1 fact identifier only when the quantity and the sign are the same.
A meter fact identifier is not reused for Model 701 power, current, or energy, because the meter sign is the opposite of DER injection.
The V2 monitoring models are Model 701 length 153, Model 713 length 7, Model 714 length 18 plus 25 times NPrt, Model 802 length 62, Model 803 length 26 plus 32 times NStr, Model 804 length 46 plus 16 times NMod, and Model 805 length 42.
Those are the catalog lengths, including 18 plus 25 times NPrt, 26 plus 32 times NStr, and 46 plus 16 times NMod.
Models 702, 703, 707, 708, 709, 715, 806, 807, 808, and 809 stay outside this monitoring section.
Heartbeat, alarm reset, warranty, and request points of these models stay observed words in the model boundary and are not monitoring facts. Enable and connect points that are listed are observed enums.

### AC measurement

Model 701, length 153, is DER AC measurement.
Model 701 positive active power and positive reactive power are injected by the DER.
Total active power, apparent power, reactive power, power factor, frequency, cabinet temperature, heat-sink temperature, transformer temperature, and other temperature reuse the inverter fact identifiers. Average line-to-line voltage and average line-to-neutral voltage reuse the meter voltage identifiers. Line and phase voltages reuse the inverter voltage identifiers. Signed current and per-phase power use DER fact identifiers because the inverter current is a magnitude and the meter power sign is opposite.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `der.ac.wiring_type` | 701 | ACType | none | none | required | enum |
| `der.ac.operating_state` | 701 | St | none | none | optional | enum |
| `der.ac.inverter_state` | 701 | InvSt | none | none | optional | enum |
| `der.ac.connection_state` | 701 | ConnSt | none | none | optional | enum |
| `der.ac.alarm` | 701 | Alrm | none | none | optional | bitfield |
| `der.ac.mode` | 701 | DERMode | none | none | optional | bitfield |
| `inverter.ac.power.active` | 701 | W | W | W_SF | optional | number |
| `inverter.ac.power.apparent` | 701 | VA | VA | VA_SF | optional | number |
| `inverter.ac.power.reactive` | 701 | Var | Var | Var_SF | optional | number |
| `inverter.ac.power_factor` | 701 | PF | Pct | PF_SF | optional | number |
| `der.ac.current` | 701 | A | A | A_SF | optional | number |
| `meter.ac.voltage.line_line.average` | 701 | LLV | V | V_SF | optional | number |
| `meter.ac.voltage.line_neutral.average` | 701 | LNV | V | V_SF | optional | number |
| `inverter.ac.frequency` | 701 | Hz | Hz | Hz_SF | optional | number |
| `der.ac.energy.injected` | 701 | TotWhInj | Wh | TotWh_SF | optional | number |
| `der.ac.energy.absorbed` | 701 | TotWhAbs | Wh | TotWh_SF | optional | number |
| `der.ac.energy.reactive_injected` | 701 | TotVarhInj | Varh | TotVarh_SF | optional | number |
| `der.ac.energy.reactive_absorbed` | 701 | TotVarhAbs | Varh | TotVarh_SF | optional | number |
| `der.ac.temperature.ambient` | 701 | TmpAmb | C | Tmp_SF | optional | number |
| `inverter.temperature.cabinet` | 701 | TmpCab | C | Tmp_SF | optional | number |
| `inverter.temperature.heatsink` | 701 | TmpSnk | C | Tmp_SF | optional | number |
| `inverter.temperature.transformer` | 701 | TmpTrns | C | Tmp_SF | optional | number |
| `der.ac.temperature.switchgear` | 701 | TmpSw | C | Tmp_SF | optional | number |
| `inverter.temperature.other` | 701 | TmpOt | C | Tmp_SF | optional | number |
| `der.ac.power.active.phase_a` | 701 | WL1 | W | W_SF | optional | number |
| `der.ac.power.apparent.phase_a` | 701 | VAL1 | VA | VA_SF | optional | number |
| `der.ac.power.reactive.phase_a` | 701 | VarL1 | Var | Var_SF | optional | number |
| `der.ac.power_factor.phase_a` | 701 | PFL1 | Pct | PF_SF | optional | number |
| `der.ac.current.phase_a` | 701 | AL1 | A | A_SF | optional | number |
| `inverter.ac.voltage.line_ab` | 701 | VL1L2 | V | V_SF | optional | number |
| `inverter.ac.voltage.phase_a` | 701 | VL1 | V | V_SF | optional | number |
| `der.ac.energy.injected.phase_a` | 701 | TotWhInjL1 | Wh | TotWh_SF | optional | number |
| `der.ac.energy.absorbed.phase_a` | 701 | TotWhAbsL1 | Wh | TotWh_SF | optional | number |
| `der.ac.energy.reactive_injected.phase_a` | 701 | TotVarhInjL1 | Varh | TotVarh_SF | optional | number |
| `der.ac.energy.reactive_absorbed.phase_a` | 701 | TotVarhAbsL1 | Varh | TotVarh_SF | optional | number |
| `der.ac.power.active.phase_b` | 701 | WL2 | W | W_SF | optional | number |
| `der.ac.power.apparent.phase_b` | 701 | VAL2 | VA | VA_SF | optional | number |
| `der.ac.power.reactive.phase_b` | 701 | VarL2 | Var | Var_SF | optional | number |
| `der.ac.power_factor.phase_b` | 701 | PFL2 | Pct | PF_SF | optional | number |
| `der.ac.current.phase_b` | 701 | AL2 | A | A_SF | optional | number |
| `inverter.ac.voltage.line_bc` | 701 | VL2L3 | V | V_SF | optional | number |
| `inverter.ac.voltage.phase_b` | 701 | VL2 | V | V_SF | optional | number |
| `der.ac.energy.injected.phase_b` | 701 | TotWhInjL2 | Wh | TotWh_SF | optional | number |
| `der.ac.energy.absorbed.phase_b` | 701 | TotWhAbsL2 | Wh | TotWh_SF | optional | number |
| `der.ac.energy.reactive_injected.phase_b` | 701 | TotVarhInjL2 | Varh | TotVarh_SF | optional | number |
| `der.ac.energy.reactive_absorbed.phase_b` | 701 | TotVarhAbsL2 | Varh | TotVarh_SF | optional | number |
| `der.ac.power.active.phase_c` | 701 | WL3 | W | W_SF | optional | number |
| `der.ac.power.apparent.phase_c` | 701 | VAL3 | VA | VA_SF | optional | number |
| `der.ac.power.reactive.phase_c` | 701 | VarL3 | Var | Var_SF | optional | number |
| `der.ac.power_factor.phase_c` | 701 | PFL3 | Pct | PF_SF | optional | number |
| `der.ac.current.phase_c` | 701 | AL3 | A | A_SF | optional | number |
| `inverter.ac.voltage.line_ca` | 701 | VL3L1 | V | V_SF | optional | number |
| `inverter.ac.voltage.phase_c` | 701 | VL3 | V | V_SF | optional | number |
| `der.ac.energy.injected.phase_c` | 701 | TotWhInjL3 | Wh | TotWh_SF | optional | number |
| `der.ac.energy.absorbed.phase_c` | 701 | TotWhAbsL3 | Wh | TotWh_SF | optional | number |
| `der.ac.energy.reactive_injected.phase_c` | 701 | TotVarhInjL3 | Varh | TotVarh_SF | optional | number |
| `der.ac.energy.reactive_absorbed.phase_c` | 701 | TotVarhAbsL3 | Varh | TotVarh_SF | optional | number |
| `der.ac.throttle.percent` | 701 | ThrotPct | Pct | none | optional | number |
| `der.ac.throttle.source` | 701 | ThrotSrc | none | none | optional | bitfield |
| `der.ac.alarm_info` | 701 | MnAlrmInfo | none | none | optional | string |

### Storage capacity

Model 713, length 7, is DER storage capacity. Watt-hour rating, state of charge, state of health, and charge state reuse the V1 storage fact identifiers.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `storage.rating.energy` | 713 | WHRtg | Wh | WH_SF | optional | number |
| `storage.status.available_energy` | 713 | WHAvail | Wh | WH_SF | optional | number |
| `storage.status.state_of_charge` | 713 | SoC | Pct | Pct_SF | optional | number |
| `storage.status.state_of_health` | 713 | SoH | Pct | Pct_SF | optional | number |
| `storage.status.charge_state` | 713 | Sta | none | none | optional | enum |

### DC ports

Model 714, length 18 plus 25 times NPrt, is DER DC measurement with repeated ports. Each emitted port has its port type. An unavailable port count emits no port entry.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `der.dc.alarm` | 714 | PrtAlrms | none | none | optional | bitfield |
| `der.dc.port.count` | 714 | NPrt | none | none | optional | number |
| `der.dc.current` | 714 | DCA | A | DCA_SF | optional | number |
| `der.dc.power` | 714 | DCW | W | DCW_SF | optional | number |
| `der.dc.energy.injected` | 714 | DCWhInj | Wh | DCWH_SF | optional | number |
| `der.dc.energy.absorbed` | 714 | DCWhAbs | Wh | DCWH_SF | optional | number |
| `der.dc.port.index` | 714 | repeat index | none | none | required | number |
| `der.dc.port.type` | 714 | PrtTyp | none | none | optional | enum |
| `der.dc.port.id` | 714 | ID | none | none | optional | number |
| `der.dc.port.label` | 714 | IDStr | none | none | optional | string |
| `der.dc.port.current` | 714 | DCA | A | DCA_SF | optional | number |
| `der.dc.port.voltage` | 714 | DCV | V | DCV_SF | optional | number |
| `der.dc.port.power` | 714 | DCW | W | DCW_SF | optional | number |
| `der.dc.port.energy.injected` | 714 | DCWhInj | Wh | DCWH_SF | optional | number |
| `der.dc.port.energy.absorbed` | 714 | DCWhAbs | Wh | DCWH_SF | optional | number |
| `der.dc.port.temperature` | 714 | Tmp | C | Tmp_SF | optional | number |
| `der.dc.port.state` | 714 | DCSta | none | none | optional | enum |
| `der.dc.port.alarm` | 714 | DCAlrm | none | none | optional | bitfield |

### Battery base

Model 802, length 62, is the battery base. Amp-hour rating, watt-hour rating, maximum charge power, maximum discharge power, state of charge, state of health, and charge state reuse the V1 storage fact identifiers. The amp-hour unit token of this model is Ah.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `storage.rating.charge` | 802 | AHRtg | Ah | AHRtg_SF | optional | number |
| `storage.rating.energy` | 802 | WHRtg | Wh | WHRtg_SF | optional | number |
| `storage.rating.max_charge_power` | 802 | WChaRteMax | W | WChaDisChaMax_SF | optional | number |
| `storage.rating.max_discharge_power` | 802 | WDisChaRteMax | W | WChaDisChaMax_SF | optional | number |
| `battery.base.discharge_rate` | 802 | DisChaRte | %WHRtg | DisChaRte_SF | optional | number |
| `battery.base.state_of_charge.max` | 802 | SoCMax | %WHRtg | SoC_SF | optional | number |
| `battery.base.state_of_charge.min` | 802 | SoCMin | %WHRtg | SoC_SF | optional | number |
| `battery.base.state_of_charge.reserve_max` | 802 | SocRsvMax | %WHRtg | SoC_SF | optional | number |
| `battery.base.state_of_charge.reserve_min` | 802 | SoCRsvMin | %WHRtg | SoC_SF | optional | number |
| `storage.status.state_of_charge` | 802 | SoC | %WHRtg | SoC_SF | optional | number |
| `battery.base.depth_of_discharge` | 802 | DoD | % | DoD_SF | optional | number |
| `storage.status.state_of_health` | 802 | SoH | % | SoH_SF | optional | number |
| `battery.base.cycle_count` | 802 | NCyc | none | none | optional | number |
| `storage.status.charge_state` | 802 | ChaSt | none | none | optional | enum |
| `battery.base.type` | 802 | Typ | none | none | optional | enum |
| `battery.base.state` | 802 | State | none | none | optional | enum |
| `battery.base.vendor_state` | 802 | StateVnd | none | none | optional | enum |
| `battery.base.events.1` | 802 | Evt1 | none | none | optional | bitfield |
| `battery.base.events.2` | 802 | Evt2 | none | none | optional | bitfield |
| `battery.base.vendor_events.1` | 802 | EvtVnd1 | none | none | optional | bitfield |
| `battery.base.vendor_events.2` | 802 | EvtVnd2 | none | none | optional | bitfield |
| `battery.base.voltage` | 802 | V | V | V_SF | optional | number |
| `battery.base.voltage.max` | 802 | VMax | V | V_SF | optional | number |
| `battery.base.voltage.min` | 802 | VMin | V | V_SF | optional | number |
| `battery.base.cell_voltage.max` | 802 | CellVMax | V | CellV_SF | optional | number |
| `battery.base.cell_voltage.max_string` | 802 | CellVMaxStr | none | none | optional | number |
| `battery.base.cell_voltage.max_module` | 802 | CellVMaxMod | none | none | optional | number |
| `battery.base.cell_voltage.min` | 802 | CellVMin | V | CellV_SF | optional | number |
| `battery.base.cell_voltage.min_string` | 802 | CellVMinStr | none | none | optional | number |
| `battery.base.cell_voltage.min_module` | 802 | CellVMinMod | none | none | optional | number |
| `battery.base.cell_voltage.average` | 802 | CellVAvg | V | CellV_SF | optional | number |
| `battery.base.current` | 802 | A | A | A_SF | optional | number |
| `battery.base.current.charge_max` | 802 | AChaMax | A | AMax_SF | optional | number |
| `battery.base.current.discharge_max` | 802 | ADisChaMax | A | AMax_SF | optional | number |
| `battery.base.power` | 802 | W | W | W_SF | optional | number |

### Battery bank

Model 803, length 26 plus 32 times NStr, is the battery bank with repeated strings. String current, state of charge, and state of health in the repeated group use the battery string fact identifiers.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `battery.bank.string_count` | 803 | NStr | none | none | optional | number |
| `battery.bank.connected_strings` | 803 | NStrCon | none | none | optional | number |
| `battery.bank.module_temperature.max` | 803 | ModTmpMax | C | ModTmp_SF | optional | number |
| `battery.bank.module_temperature.max_string` | 803 | ModTmpMaxStr | none | none | optional | number |
| `battery.bank.module_temperature.max_module` | 803 | ModTmpMaxMod | none | none | optional | number |
| `battery.bank.module_temperature.min` | 803 | ModTmpMin | C | ModTmp_SF | optional | number |
| `battery.bank.module_temperature.min_string` | 803 | ModTmpMinStr | none | none | optional | number |
| `battery.bank.module_temperature.min_module` | 803 | ModTmpMinMod | none | none | optional | number |
| `battery.bank.module_temperature.average` | 803 | ModTmpAvg | C | ModTmp_SF | optional | number |
| `battery.bank.string_voltage.max` | 803 | StrVMax | V | V_SF | optional | number |
| `battery.bank.string_voltage.max_string` | 803 | StrVMaxStr | none | none | optional | number |
| `battery.bank.string_voltage.min` | 803 | StrVMin | V | V_SF | optional | number |
| `battery.bank.string_voltage.min_string` | 803 | StrVMinStr | none | none | optional | number |
| `battery.bank.string_voltage.average` | 803 | StrVAvg | V | V_SF | optional | number |
| `battery.bank.string_current.max` | 803 | StrAMax | A | A_SF | optional | number |
| `battery.bank.string_current.max_string` | 803 | StrAMaxStr | none | none | optional | number |
| `battery.bank.string_current.min` | 803 | StrAMin | A | A_SF | optional | number |
| `battery.bank.string_current.min_string` | 803 | StrAMinStr | none | none | optional | number |
| `battery.bank.string_current.average` | 803 | StrAAvg | A | A_SF | optional | number |
| `battery.bank.balancing_cells` | 803 | NCellBal | none | none | optional | number |
| `battery.string.index` | 803 | repeat index | none | none | required | number |
| `battery.string.module_count` | 803 | StrNMod | none | none | optional | number |
| `battery.string.state` | 803 | StrSt | none | none | optional | bitfield |
| `battery.string.connection_failure` | 803 | StrConFail | none | none | optional | enum |
| `battery.string.state_of_charge` | 803 | StrSoC | % | SoC_SF | optional | number |
| `battery.string.state_of_health` | 803 | StrSoH | % | SoH_SF | optional | number |
| `battery.string.current` | 803 | StrA | A | A_SF | optional | number |
| `battery.string.cell_voltage.max` | 803 | StrCellVMax | V | CellV_SF | optional | number |
| `battery.string.cell_voltage.max_module` | 803 | StrCellVMaxMod | none | none | optional | number |
| `battery.string.cell_voltage.min` | 803 | StrCellVMin | V | CellV_SF | optional | number |
| `battery.string.cell_voltage.min_module` | 803 | StrCellVMinMod | none | none | optional | number |
| `battery.string.cell_voltage.average` | 803 | StrCellVAvg | V | CellV_SF | optional | number |
| `battery.string.module_temperature.max` | 803 | StrModTmpMax | C | ModTmp_SF | optional | number |
| `battery.string.module_temperature.max_module` | 803 | StrModTmpMaxMod | none | none | optional | number |
| `battery.string.module_temperature.min` | 803 | StrModTmpMin | C | ModTmp_SF | optional | number |
| `battery.string.module_temperature.min_module` | 803 | StrModTmpMinMod | none | none | optional | number |
| `battery.string.module_temperature.average` | 803 | StrModTmpAvg | C | ModTmp_SF | optional | number |
| `battery.string.disconnect_reason` | 803 | StrDisRsn | none | none | optional | enum |
| `battery.string.connection_state` | 803 | StrConSt | none | none | optional | bitfield |
| `battery.string.events.1` | 803 | StrEvt1 | none | none | optional | bitfield |
| `battery.string.events.2` | 803 | StrEvt2 | none | none | optional | bitfield |
| `battery.string.vendor_events.1` | 803 | StrEvtVnd1 | none | none | optional | bitfield |
| `battery.string.vendor_events.2` | 803 | StrEvtVnd2 | none | none | optional | bitfield |
| `battery.string.enable_state` | 803 | StrSetEna | none | none | optional | enum |
| `battery.string.connect_state` | 803 | StrSetCon | none | none | optional | enum |

### Battery string

Model 804, length 46 plus 16 times NMod, is the battery string. Its string index, current, state of charge, and state of health use the same fact identifiers as the repeated string of model 803.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `battery.string.index` | 804 | Idx | none | none | optional | number |
| `battery.string.module_count` | 804 | NMod | none | none | optional | number |
| `battery.string.state` | 804 | St | none | none | optional | bitfield |
| `battery.string.connection_failure` | 804 | ConFail | none | none | optional | enum |
| `battery.string.balancing_cells` | 804 | NCellBal | none | none | optional | number |
| `battery.string.state_of_charge` | 804 | SoC | % | SoC_SF | optional | number |
| `battery.string.depth_of_discharge` | 804 | DoD | % | DoD_SF | optional | number |
| `battery.string.cycle_count` | 804 | NCyc | none | none | optional | number |
| `battery.string.state_of_health` | 804 | SoH | % | SoH_SF | optional | number |
| `battery.string.current` | 804 | A | A | A_SF | optional | number |
| `battery.string.voltage` | 804 | V | V | V_SF | optional | number |
| `battery.string.cell_voltage.max` | 804 | CellVMax | V | CellV_SF | optional | number |
| `battery.string.cell_voltage.max_module` | 804 | CellVMaxMod | none | none | optional | number |
| `battery.string.cell_voltage.min` | 804 | CellVMin | V | CellV_SF | optional | number |
| `battery.string.cell_voltage.min_module` | 804 | CellVMinMod | none | none | optional | number |
| `battery.string.cell_voltage.average` | 804 | CellVAvg | V | CellV_SF | optional | number |
| `battery.string.module_temperature.max` | 804 | ModTmpMax | C | ModTmp_SF | optional | number |
| `battery.string.module_temperature.max_module` | 804 | ModTmpMaxMod | none | none | optional | number |
| `battery.string.module_temperature.min` | 804 | ModTmpMin | C | ModTmp_SF | optional | number |
| `battery.string.module_temperature.min_module` | 804 | ModTmpMinMod | none | none | optional | number |
| `battery.string.module_temperature.average` | 804 | ModTmpAvg | C | ModTmp_SF | optional | number |
| `battery.string.connection_state` | 804 | ConSt | none | none | optional | bitfield |
| `battery.string.events.1` | 804 | Evt1 | none | none | optional | bitfield |
| `battery.string.events.2` | 804 | Evt2 | none | none | optional | bitfield |
| `battery.string.vendor_events.1` | 804 | EvtVnd1 | none | none | optional | bitfield |
| `battery.string.vendor_events.2` | 804 | EvtVnd2 | none | none | optional | bitfield |
| `battery.string.enable_state` | 804 | SetEna | none | none | optional | enum |
| `battery.string.connect_state` | 804 | SetCon | none | none | optional | enum |

### Battery module

Model 805, length 42, is the battery module. Model 804 also repeats a module group. Module state of charge uses one fact identifier for both.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `battery.module.index` | 804 | repeat index | none | none | required | number |
| `battery.module.cell_count` | 804 | ModNCell | none | none | optional | number |
| `battery.module.state_of_charge` | 804 | ModSoC | % | SoC_SF | optional | number |
| `battery.module.state_of_health` | 804 | ModSoH | % | SoH_SF | optional | number |
| `battery.module.cell_voltage.max` | 804 | ModCellVMax | V | CellV_SF | optional | number |
| `battery.module.cell_voltage.max_cell` | 804 | ModCellVMaxCell | none | none | optional | number |
| `battery.module.cell_voltage.min` | 804 | ModCellVMin | V | CellV_SF | optional | number |
| `battery.module.cell_voltage.min_cell` | 804 | ModCellVMinCell | none | none | optional | number |
| `battery.module.cell_voltage.average` | 804 | ModCellVAvg | V | CellV_SF | optional | number |
| `battery.module.cell_temperature.max` | 804 | ModCellTmpMax | C | ModTmp_SF | optional | number |
| `battery.module.cell_temperature.max_cell` | 804 | ModCellTmpMaxCell | none | none | optional | number |
| `battery.module.cell_temperature.min` | 804 | ModCellTmpMin | C | ModTmp_SF | optional | number |
| `battery.module.cell_temperature.min_cell` | 804 | ModCellTmpMinCell | none | none | optional | number |
| `battery.module.cell_temperature.average` | 804 | ModCellTmpAvg | C | ModTmp_SF | optional | number |
| `battery.module.string_index` | 805 | StrIdx | none | none | optional | number |
| `battery.module.index` | 805 | ModIdx | none | none | optional | number |
| `battery.module.cell_count` | 805 | NCell | none | none | optional | number |
| `battery.module.state_of_charge` | 805 | SoC | % | SoC_SF | optional | number |
| `battery.module.depth_of_discharge` | 805 | DoD | % | DoD_SF | optional | number |
| `battery.module.state_of_health` | 805 | SoH | % | SoH_SF | optional | number |
| `battery.module.cycle_count` | 805 | NCyc | none | none | optional | number |
| `battery.module.voltage` | 805 | V | V | V_SF | optional | number |
| `battery.module.cell_voltage.max` | 805 | CellVMax | V | CellV_SF | optional | number |
| `battery.module.cell_voltage.max_cell` | 805 | CellVMaxCell | none | none | optional | number |
| `battery.module.cell_voltage.min` | 805 | CellVMin | V | CellV_SF | optional | number |
| `battery.module.cell_voltage.min_cell` | 805 | CellVMinCell | none | none | optional | number |
| `battery.module.cell_voltage.average` | 805 | CellVAvg | V | CellV_SF | optional | number |
| `battery.module.cell_temperature.max` | 805 | CellTmpMax | C | Tmp_SF | optional | number |
| `battery.module.cell_temperature.max_cell` | 805 | CellTmpMaxCell | none | none | optional | number |
| `battery.module.cell_temperature.min` | 805 | CellTmpMin | C | Tmp_SF | optional | number |
| `battery.module.cell_temperature.min_cell` | 805 | CellTmpMinCell | none | none | optional | number |
| `battery.module.cell_temperature.average` | 805 | CellTmpAvg | C | Tmp_SF | optional | number |
| `battery.module.balancing_cells` | 805 | NCellBal | none | none | optional | number |
| `battery.module.identity_string` | 805 | SN | none | none | optional | string |
