# SunSpec Read-Only Core V1 Model Families

## Scope

This guide explains the model families already covered by the executable
`sunspec.models@7abdf898-v1` catalog. It covers 28 distinct standard model
identifiers and 29 exact decoder tuples. It is a reading aid for the V1 core,
not a product compatibility list or an extension of the decoder catalog.

The core contract remains the authority for chain framing, exact lengths, value
sentinels, scale factors, and rejection rules. This page groups those existing
models by the kind of information they describe.

## Decoder Catalog Boundary

Every decoder selection uses model identifier, declared data-register length,
and the executable schema revision together. Model 1 length 66 is current and
length 65 is a compatibility tuple. The length-65 form is the current Common
layout without its final pad word; it is not a separate product family.

The `SunS` signature precedes Common Model 1, which occurs first and exactly
once. Each later block retains its observed order and occurrence. Unknown model
identifiers or lengths remain opaque blocks. A known identifier with a different
length is not decoded best-effort.

## Inverter Families

Models 101, 102, and 103 use integer values with declared scale factors. They
represent single-phase, split-phase, and three-phase inverter layouts,
respectively. The scale factor is part of the same model contract as the raw
measurement; a missing or unavailable factor does not create a substitute
number.

Models 111, 112, and 113 use IEEE FLOAT values. They represent single-phase,
split-phase, and three-phase inverter layouts, respectively. Integer-plus-scale
factor and FLOAT are separate wire encodings. They can describe comparable
measurements only after field-by-field decoding establishes matching quantity,
unit, phase, availability, and value.

## Inverter Extensions

Model 120 describes nameplate ratings. Model 121 describes basic settings, and
Model 122 describes extended measurements and status. Model 123 describes
immediate controls, Model 124 describes basic storage controls, and Model 160
adds repeated multiple-MPPT information.

These extensions are optional additions to a chain. Their absence is not an
error, and a malformed extension does not justify decoding a different length.
Models 123 and 124 are the SemReg setters documented on the controls page, and models 120 through 124 follow the writable-point rule. The setters and the hand calls are on the [controls page](controls-v1.md).

## Meter Families

Models 201, 202, 203, and 204 use integer values with declared scale factors.
They represent, in order, single-phase, split-phase, three-phase wye, and
three-phase delta meter layouts. Models 211, 212, 213, and 214 represent the
same topology sequence with IEEE FLOAT values.

The topology label belongs to the wire model. A meter tuple is not selected by
manufacturer name, product label, registration order, or a partial set of
measurements.

## Environmental Families

Model 302 describes irradiance, Model 303 back-of-module temperature, and Model
304 inclinometer data. Model 305 describes location, Model 306 a reference
point, Model 307 base meteorological data, and Model 308 a compact
meteorological data set.

These models remain optional standard blocks. Their appearance does not identify
a device, infer an installation, or create an environmental profile outside the
exact decoder tuple.

## Monitoring capabilities

Each fact's presence and whether it is required are declared from the public SunSpec model definitions.
An absent or unimplemented point is omitted and never reported as zero.
A scale factor that is unimplemented makes its value absent.
Monitoring facts use registry-native identifiers.
Each monitoring capability is read-only and adds no request beyond the chain read that already exists.

A scale-factor point, a header, and a pad are not monitoring facts. Integer models name the scale factor of each value. IEEE FLOAT models have no scale factor, so the scale is none. Total current is required on models 101, 102, 103, 111, 112, and 113.
Single-phase models 101 and 111 carry no phase B or phase C facts, and split-phase models 102 and 112 carry no phase C facts.
Split-phase models carry phase A and phase B facts. A register that is present only because the block length is fixed is not emitted for a phase the model does not define.
Environmental models 302 through 308 stay outside these monitoring capabilities.

### Inverter monitoring

Models 101, 102, 103, 111, 112, and 113 emit inverter monitoring facts. Optional facts beside the required current, voltage, active power, frequency, lifetime energy, cabinet temperature, operating state, and event words are power factor, apparent power, reactive power, DC current, DC voltage, DC power, heat-sink temperature, transformer temperature, other temperature, the vendor operating state, and the four vendor event words.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `inverter.ac.current.total` | 101, 102, 103, 111, 112, 113 | A | A | A_SF on 101, 102, and 103; none on 111, 112, and 113 | required | number |
| `inverter.ac.current.phase_a` | 101, 102, 103, 111, 112, 113 | AphA | A | A_SF on 101, 102, and 103; none on 111, 112, and 113 | required | number |
| `inverter.ac.current.phase_b` | 102, 103, 112, 113 | AphB | A | A_SF on 102 and 103; none on 112 and 113 | required | number |
| `inverter.ac.current.phase_c` | 103, 113 | AphC | A | A_SF on 103; none on 113 | required | number |
| `inverter.ac.voltage.line_ab` | 102, 103, 112, 113 | PPVphAB | V | V_SF on 102 and 103; none on 112 and 113 | optional | number |
| `inverter.ac.voltage.line_bc` | 103, 113 | PPVphBC | V | V_SF on 103; none on 113 | optional | number |
| `inverter.ac.voltage.line_ca` | 103, 113 | PPVphCA | V | V_SF on 103; none on 113 | optional | number |
| `inverter.ac.voltage.phase_a` | 101, 102, 103, 111, 112, 113 | PhVphA | V | V_SF on 101, 102, and 103; none on 111, 112, and 113 | required | number |
| `inverter.ac.voltage.phase_b` | 102, 103, 112, 113 | PhVphB | V | V_SF on 102 and 103; none on 112 and 113 | required | number |
| `inverter.ac.voltage.phase_c` | 103, 113 | PhVphC | V | V_SF on 103; none on 113 | required | number |
| `inverter.ac.power.active` | 101, 102, 103, 111, 112, 113 | W | W | W_SF on 101, 102, and 103; none on 111, 112, and 113 | required | number |
| `inverter.ac.frequency` | 101, 102, 103, 111, 112, 113 | Hz | Hz | Hz_SF on 101, 102, and 103; none on 111, 112, and 113 | required | number |
| `inverter.ac.power.apparent` | 101, 102, 103, 111, 112, 113 | VA | VA | VA_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.ac.power.reactive` | 101, 102, 103, 111, 112, 113 | VAr | var | VAr_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.ac.power_factor` | 101, 102, 103, 111, 112, 113 | PF | Pct | PF_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.ac.energy_lifetime` | 101, 102, 103, 111, 112, 113 | WH | Wh | WH_SF on 101, 102, and 103; none on 111, 112, and 113 | required | number |
| `inverter.dc.current` | 101, 102, 103, 111, 112, 113 | DCA | A | DCA_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.dc.voltage` | 101, 102, 103, 111, 112, 113 | DCV | V | DCV_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.dc.power` | 101, 102, 103, 111, 112, 113 | DCW | W | DCW_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.temperature.cabinet` | 101, 102, 103, 111, 112, 113 | TmpCab | C | Tmp_SF on 101, 102, and 103; none on 111, 112, and 113 | required | number |
| `inverter.temperature.heatsink` | 101, 102, 103, 111, 112, 113 | TmpSnk | C | Tmp_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.temperature.transformer` | 101, 102, 103, 111, 112, 113 | TmpTrns | C | Tmp_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.temperature.other` | 101, 102, 103, 111, 112, 113 | TmpOt | C | Tmp_SF on 101, 102, and 103; none on 111, 112, and 113 | optional | number |
| `inverter.operating_state` | 101, 102, 103, 111, 112, 113 | St | none | none | required | enum |
| `inverter.vendor_state` | 101, 102, 103, 111, 112, 113 | StVnd | none | none | optional | enum |
| `inverter.events.1` | 101, 102, 103, 111, 112, 113 | Evt1 | none | none | required | bitfield |
| `inverter.events.2` | 101, 102, 103, 111, 112, 113 | Evt2 | none | none | required | bitfield |
| `inverter.vendor_events.1` | 101, 102, 103, 111, 112, 113 | EvtVnd1 | none | none | optional | bitfield |
| `inverter.vendor_events.2` | 101, 102, 103, 111, 112, 113 | EvtVnd2 | none | none | optional | bitfield |
| `inverter.vendor_events.3` | 101, 102, 103, 111, 112, 113 | EvtVnd3 | none | none | optional | bitfield |
| `inverter.vendor_events.4` | 101, 102, 103, 111, 112, 113 | EvtVnd4 | none | none | optional | bitfield |

### DER observed state

Models 120, 121, 122, and 123 are read-only observed state. The facts are the nameplate ratings, the settings, the connection and control status, the active-power limit percent and its enable, and the power-factor and reactive settings. Storage ratings of model 120 are in the storage table. No fact in this table adds a request.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `der.type` | 120 | DERTyp | none | none | required | enum |
| `der.rating.active_power` | 120 | WRtg | W | WRtg_SF | required | number |
| `der.rating.apparent_power` | 120 | VARtg | VA | VARtg_SF | required | number |
| `der.rating.reactive_power.q1` | 120 | VArRtgQ1 | var | VArRtg_SF | required | number |
| `der.rating.reactive_power.q2` | 120 | VArRtgQ2 | var | VArRtg_SF | required | number |
| `der.rating.reactive_power.q3` | 120 | VArRtgQ3 | var | VArRtg_SF | required | number |
| `der.rating.reactive_power.q4` | 120 | VArRtgQ4 | var | VArRtg_SF | required | number |
| `der.rating.current` | 120 | ARtg | A | ARtg_SF | required | number |
| `der.rating.power_factor.q1` | 120 | PFRtgQ1 | cos() | PFRtg_SF | required | number |
| `der.rating.power_factor.q2` | 120 | PFRtgQ2 | cos() | PFRtg_SF | required | number |
| `der.rating.power_factor.q3` | 120 | PFRtgQ3 | cos() | PFRtg_SF | required | number |
| `der.rating.power_factor.q4` | 120 | PFRtgQ4 | cos() | PFRtg_SF | required | number |
| `der.settings.max_active_power` | 121 | WMax | W | WMax_SF | required | number |
| `der.settings.reference_voltage` | 121 | VRef | V | VRef_SF | required | number |
| `der.settings.reference_voltage_offset` | 121 | VRefOfs | V | VRefOfs_SF | required | number |
| `der.settings.max_voltage` | 121 | VMax | V | VMinMax_SF | optional | number |
| `der.settings.min_voltage` | 121 | VMin | V | VMinMax_SF | optional | number |
| `der.settings.max_apparent_power` | 121 | VAMax | VA | VAMax_SF | optional | number |
| `der.settings.max_reactive_power.q1` | 121 | VArMaxQ1 | var | VArMax_SF | optional | number |
| `der.settings.max_reactive_power.q2` | 121 | VArMaxQ2 | var | VArMax_SF | optional | number |
| `der.settings.max_reactive_power.q3` | 121 | VArMaxQ3 | var | VArMax_SF | optional | number |
| `der.settings.max_reactive_power.q4` | 121 | VArMaxQ4 | var | VArMax_SF | optional | number |
| `der.settings.active_power_gradient` | 121 | WGra | % WMax/sec | WGra_SF | optional | number |
| `der.settings.min_power_factor.q1` | 121 | PFMinQ1 | cos() | PFMin_SF | optional | number |
| `der.settings.min_power_factor.q2` | 121 | PFMinQ2 | cos() | PFMin_SF | optional | number |
| `der.settings.min_power_factor.q3` | 121 | PFMinQ3 | cos() | PFMin_SF | optional | number |
| `der.settings.min_power_factor.q4` | 121 | PFMinQ4 | cos() | PFMin_SF | optional | number |
| `der.settings.reactive_power_action` | 121 | VArAct | none | none | optional | enum |
| `der.settings.apparent_power_calculation` | 121 | ClcTotVA | none | none | optional | enum |
| `der.settings.max_ramp_rate` | 121 | MaxRmpRte | % WGra | MaxRmpRte_SF | optional | number |
| `der.settings.nominal_frequency` | 121 | ECPNomHz | Hz | ECPNomHz_SF | optional | number |
| `der.settings.connected_phase` | 121 | ConnPh | none | none | optional | enum |
| `der.status.pv_connection` | 122 | PVConn | none | none | required | bitfield |
| `der.status.storage_connection` | 122 | StorConn | none | none | required | bitfield |
| `der.status.ecp_connection` | 122 | ECPConn | none | none | required | bitfield |
| `der.status.active_energy` | 122 | ActWh | Wh | none | optional | number |
| `der.status.apparent_energy` | 122 | ActVAh | VAh | none | optional | number |
| `der.status.reactive_energy.q1` | 122 | ActVArhQ1 | varh | none | optional | number |
| `der.status.reactive_energy.q2` | 122 | ActVArhQ2 | varh | none | optional | number |
| `der.status.reactive_energy.q3` | 122 | ActVArhQ3 | varh | none | optional | number |
| `der.status.reactive_energy.q4` | 122 | ActVArhQ4 | varh | none | optional | number |
| `der.status.available_reactive_power` | 122 | VArAval | var | VArAval_SF | optional | number |
| `der.status.available_active_power` | 122 | WAval | W | WAval_SF | optional | number |
| `der.status.limit_mask` | 122 | StSetLimMsk | none | none | optional | bitfield |
| `der.status.active_controls` | 122 | StActCtl | none | none | optional | bitfield |
| `der.status.time_source` | 122 | TmSrc | none | none | optional | string |
| `der.status.timestamp` | 122 | Tms | Secs | none | optional | number |
| `der.status.ride_through` | 122 | RtSt | none | none | optional | bitfield |
| `der.status.insulation_resistance` | 122 | Ris | ohms | Ris_SF | optional | number |
| `der.control.connection.window_seconds` | 123 | Conn_WinTms | Secs | none | optional | number |
| `der.control.connection.revert_seconds` | 123 | Conn_RvrtTms | Secs | none | optional | number |
| `der.control.connection.command` | 123 | Conn | none | none | required | enum |
| `der.control.active_power_limit.percent` | 123 | WMaxLimPct | % WMax | WMaxLimPct_SF | required | number |
| `der.control.active_power_limit.window_seconds` | 123 | WMaxLimPct_WinTms | Secs | none | optional | number |
| `der.control.active_power_limit.revert_seconds` | 123 | WMaxLimPct_RvrtTms | Secs | none | optional | number |
| `der.control.active_power_limit.ramp_seconds` | 123 | WMaxLimPct_RmpTms | Secs | none | optional | number |
| `der.control.active_power_limit.enabled` | 123 | WMaxLim_Ena | none | none | required | enum |
| `der.control.power_factor.setpoint` | 123 | OutPFSet | cos() | OutPFSet_SF | required | number |
| `der.control.power_factor.window_seconds` | 123 | OutPFSet_WinTms | Secs | none | optional | number |
| `der.control.power_factor.revert_seconds` | 123 | OutPFSet_RvrtTms | Secs | none | optional | number |
| `der.control.power_factor.ramp_seconds` | 123 | OutPFSet_RmpTms | Secs | none | optional | number |
| `der.control.power_factor.enabled` | 123 | OutPFSet_Ena | none | none | required | enum |
| `der.control.reactive_power.percent_wmax` | 123 | VArWMaxPct | % WMax | VArPct_SF | optional | number |
| `der.control.reactive_power.percent_var_max` | 123 | VArMaxPct | % VArMax | VArPct_SF | optional | number |
| `der.control.reactive_power.percent_var_available` | 123 | VArAvalPct | % VArAval | VArPct_SF | optional | number |
| `der.control.reactive_power.window_seconds` | 123 | VArPct_WinTms | Secs | none | optional | number |
| `der.control.reactive_power.revert_seconds` | 123 | VArPct_RvrtTms | Secs | none | optional | number |
| `der.control.reactive_power.ramp_seconds` | 123 | VArPct_RmpTms | Secs | none | optional | number |
| `der.control.reactive_power.mode` | 123 | VArPct_Mod | none | none | optional | enum |
| `der.control.reactive_power.enabled` | 123 | VArPct_Ena | none | none | required | enum |

### MPPT inputs

Model 160 emits one entry for each repeated module. The entry index is the repeated-group index, not a separate wire point. The entry carries the module identifier, label, DC current, voltage, power, lifetime DC energy, temperature, operating state, and events.
An MPPT input is not assumed to be a string. String values come from string-level documentation. A Model 160 module role is unknown unless a public SunSpec model definition states the module label meaning.
A storage charge label or a storage discharge label would fill the role only when a public SunSpec model definition states that label meaning. The model 160 label has no such meaning, so every role below is unknown. An unavailable module count emits no module entry.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind | Role |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `mppt.module.index` | 160 | repeat index | none | none | required | number | unknown |
| `mppt.module.id` | 160 | ID | none | none | optional | number | unknown |
| `mppt.module.label` | 160 | IDStr | none | none | optional | string | unknown |
| `mppt.module.dc_current` | 160 | DCA | A | DCA_SF | optional | number | unknown |
| `mppt.module.dc_voltage` | 160 | DCV | V | DCV_SF | optional | number | unknown |
| `mppt.module.dc_power` | 160 | DCW | W | DCW_SF | optional | number | unknown |
| `mppt.module.dc_energy` | 160 | DCWH | Wh | DCWH_SF | optional | number | unknown |
| `mppt.module.temperature` | 160 | Tmp | C | none | optional | number | unknown |
| `mppt.module.operating_state` | 160 | DCSt | none | none | optional | enum | unknown |
| `mppt.module.events` | 160 | DCEvt | none | none | optional | bitfield | unknown |
| `mppt.events` | 160 | Evt | none | none | optional | bitfield | unknown |

### Storage

Model 124 charge and discharge limits are the SemReg setters on the [controls page](controls-v1.md), together with the optional storage ratings of model 120.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `storage.rating.energy` | 120 | WHRtg | Wh | WHRtg_SF | optional | number |
| `storage.rating.charge` | 120 | AhrRtg | AH | AhrRtg_SF | optional | number |
| `storage.rating.max_charge_power` | 120 | MaxChaRte | W | MaxChaRte_SF | optional | number |
| `storage.rating.max_discharge_power` | 120 | MaxDisChaRte | W | MaxDisChaRte_SF | optional | number |
| `storage.control.max_charge_power` | 124 | WChaMax | W | WChaMax_SF | required | number |
| `storage.control.charge_gradient` | 124 | WChaGra | % WChaMax/sec | WChaDisChaGra_SF | required | number |
| `storage.control.discharge_gradient` | 124 | WDisChaGra | % WChaMax/sec | WChaDisChaGra_SF | required | number |
| `storage.control.mode` | 124 | StorCtl_Mod | none | none | required | bitfield |
| `storage.control.max_charge_apparent_power` | 124 | VAChaMax | VA | VAChaMax_SF | optional | number |
| `storage.control.minimum_reserve` | 124 | MinRsvPct | % WChaMax | MinRsvPct_SF | optional | number |
| `storage.status.state_of_charge` | 124 | ChaState | % AhrRtg | ChaState_SF | optional | number |
| `storage.status.available_charge` | 124 | StorAval | AH | StorAval_SF | optional | number |
| `storage.status.internal_battery_voltage` | 124 | InBatV | V | InBatV_SF | optional | number |
| `storage.status.charge_state` | 124 | ChaSt | none | none | optional | enum |
| `storage.control.discharge_rate` | 124 | OutWRte | % WDisChaMax | InOutWRte_SF | optional | number |
| `storage.control.charge_rate` | 124 | InWRte | % WChaMax | InOutWRte_SF | optional | number |
| `storage.control.rate_window` | 124 | InOutWRte_WinTms | Secs | none | optional | number |
| `storage.control.rate_revert` | 124 | InOutWRte_RvrtTms | Secs | none | optional | number |
| `storage.control.rate_ramp` | 124 | InOutWRte_RmpTms | Secs | none | optional | number |
| `storage.control.charge_source` | 124 | ChaGriSet | none | none | optional | enum |

### Meters

Models 201, 202, 203, 204, 211, 212, 213, and 214 emit every current, phase-to-neutral voltage, line-to-line voltage, frequency, active power, apparent power, reactive power, power factor, active energy counter, apparent energy counter, reactive energy counter, and event word defined by the model. Totals and per-phase points are both listed. A point the model marks mandatory is required. Every other listed point is optional.

Integer model 201 names the line voltages PPVphAB, PPVphBC, and PPVphCA. Integer models 202, 203, and 204 name them PhVphAB, PhVphBC, and PhVphCA. Float models 211, 212, 213, and 214 name them PPVphAB, PPVphBC, and PPVphCA. The fact identifier is the same. Integer reactive phase points use a capital Ph in the phase suffix. Float reactive phase points use ph. Integer power factor uses unit Pct. Float power factor uses unit PF.

A multi-device chain is segmented at each Common model, and each segment is one device with its own identity. A chain whose segments cannot be attributed keeps a named reason. A device's identity anchor is its native position in the chain, so identities stay the same start after start. Positive meter current and positive meter active power are toward the load, and negative values are toward the grid.
Negative meter current and negative meter active power are toward the grid. Positive reactive power is inductive, with current lagging voltage. Negative reactive power is capacitive, with current leading voltage.
The power-factor sign follows reactive power: positive is lagging and negative is leading.
Active energy, apparent energy, and reactive energy are separate counters, and a counter is not a signed instantaneous value.
The reactive counters are the imported quadrant 1, imported quadrant 2, exported quadrant 3, and exported quadrant 4 named by the model. The same sign convention applies to each phase point. Frequency has no import or export sign. A valid counter whose value is zero stays zero. An unimplemented counter is omitted.

| Fact | Model | Point | Unit | Scale factor | Admission | Value kind |
| --- | --- | --- | --- | --- | --- | --- |
| `meter.ac.current.total` | 201, 202, 203, 204, 211, 212, 213, 214 | A | A | A_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | required | number |
| `meter.ac.current.phase_a` | 201, 203, 204, 211, 212, 213, 214 | AphA | A | A_SF on 201, 203, and 204; none on 211, 212, 213, and 214 | required | number |
| `meter.ac.current.phase_a` | 202 | AphA | A | A_SF | optional | number |
| `meter.ac.current.phase_b` | 202, 203, 204, 212, 213, 214 | AphB | A | A_SF on 202, 203, and 204; none on 212, 213, and 214 | required | number |
| `meter.ac.current.phase_b` | 201, 211 | AphB | A | A_SF on 201; none on 211 | optional | number |
| `meter.ac.current.phase_c` | 202, 203, 204, 213, 214 | AphC | A | A_SF on 202, 203, and 204; none on 213 and 214 | required | number |
| `meter.ac.current.phase_c` | 201, 211, 212 | AphC | A | A_SF on 201; none on 211 and 212 | optional | number |
| `meter.ac.voltage.line_neutral.average` | 202, 203, 212, 213 | PhV | V | V_SF on 202 and 203; none on 212 and 213 | required | number |
| `meter.ac.voltage.line_neutral.average` | 201, 204, 211, 214 | PhV | V | V_SF on 201 and 204; none on 211 and 214 | optional | number |
| `meter.ac.voltage.line_neutral.phase_a` | 202, 203, 212, 213 | PhVphA | V | V_SF on 202 and 203; none on 212 and 213 | required | number |
| `meter.ac.voltage.line_neutral.phase_a` | 201, 204, 211, 214 | PhVphA | V | V_SF on 201 and 204; none on 211 and 214 | optional | number |
| `meter.ac.voltage.line_neutral.phase_b` | 202, 203, 212, 213 | PhVphB | V | V_SF on 202 and 203; none on 212 and 213 | required | number |
| `meter.ac.voltage.line_neutral.phase_b` | 201, 204, 211, 214 | PhVphB | V | V_SF on 201 and 204; none on 211 and 214 | optional | number |
| `meter.ac.voltage.line_neutral.phase_c` | 203, 213 | PhVphC | V | V_SF on 203; none on 213 | required | number |
| `meter.ac.voltage.line_neutral.phase_c` | 201, 202, 204, 211, 212, 214 | PhVphC | V | V_SF on 201, 202, and 204; none on 211, 212, and 214 | optional | number |
| `meter.ac.voltage.line_line.average` | 202, 203, 204, 212, 213, 214 | PPV | V | V_SF on 202, 203, and 204; none on 212, 213, and 214 | required | number |
| `meter.ac.voltage.line_line.average` | 201, 211 | PPV | V | V_SF on 201; none on 211 | optional | number |
| `meter.ac.voltage.line_line.ab` | 212, 213, 214 | PPVphAB | V | none | required | number |
| `meter.ac.voltage.line_line.ab` | 201, 211 | PPVphAB | V | V_SF on 201; none on 211 | optional | number |
| `meter.ac.voltage.line_line.ab` | 202, 203, 204 | PhVphAB | V | V_SF | required | number |
| `meter.ac.voltage.line_line.bc` | 213, 214 | PPVphBC | V | none | required | number |
| `meter.ac.voltage.line_line.bc` | 201, 211, 212 | PPVphBC | V | V_SF on 201; none on 211 and 212 | optional | number |
| `meter.ac.voltage.line_line.bc` | 203, 204 | PhVphBC | V | V_SF | required | number |
| `meter.ac.voltage.line_line.bc` | 202 | PhVphBC | V | V_SF | optional | number |
| `meter.ac.voltage.line_line.ca` | 213, 214 | PPVphCA | V | none | required | number |
| `meter.ac.voltage.line_line.ca` | 201, 211, 212 | PPVphCA | V | V_SF on 201; none on 211 and 212 | optional | number |
| `meter.ac.voltage.line_line.ca` | 203, 204 | PhVphCA | V | V_SF | required | number |
| `meter.ac.voltage.line_line.ca` | 202 | PhVphCA | V | V_SF | optional | number |
| `meter.ac.frequency` | 201, 202, 203, 204, 211, 212, 213, 214 | Hz | Hz | Hz_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | required | number |
| `meter.ac.power.active.total` | 201, 202, 203, 204, 211, 212, 213, 214 | W | W | W_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | required | number |
| `meter.ac.power.active.phase_a` | 201, 202, 203, 204, 211, 212, 213, 214 | WphA | W | W_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.active.phase_b` | 201, 202, 203, 204, 211, 212, 213, 214 | WphB | W | W_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.active.phase_c` | 201, 202, 203, 204, 211, 212, 213, 214 | WphC | W | W_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.apparent.total` | 201, 202, 203, 204, 211, 212, 213, 214 | VA | VA | VA_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.apparent.phase_a` | 201, 202, 203, 204, 211, 212, 213, 214 | VAphA | VA | VA_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.apparent.phase_b` | 201, 202, 203, 204, 211, 212, 213, 214 | VAphB | VA | VA_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.apparent.phase_c` | 201, 202, 203, 204, 211, 212, 213, 214 | VAphC | VA | VA_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.reactive.total` | 201, 202, 203, 204, 211, 212, 213, 214 | VAR | var | VAR_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.reactive.phase_a` | 201, 202, 203, 204, 211, 212, 213, 214 | VARphA | var | VAR_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.reactive.phase_b` | 201, 202, 203, 204, 211, 212, 213, 214 | VARphB | var | VAR_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power.reactive.phase_c` | 201, 202, 203, 204, 211, 212, 213, 214 | VARphC | var | VAR_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.ac.power_factor.total` | 201, 202, 203, 204 | PF | Pct | PF_SF | optional | number |
| `meter.ac.power_factor.total` | 211, 212, 213, 214 | PF | PF | none | optional | number |
| `meter.ac.power_factor.phase_a` | 201, 202, 203, 204 | PFphA | Pct | PF_SF | optional | number |
| `meter.ac.power_factor.phase_a` | 211, 212, 213, 214 | PFphA | PF | none | optional | number |
| `meter.ac.power_factor.phase_b` | 201, 202, 203, 204 | PFphB | Pct | PF_SF | optional | number |
| `meter.ac.power_factor.phase_b` | 211, 212, 213, 214 | PFphB | PF | none | optional | number |
| `meter.ac.power_factor.phase_c` | 201, 202, 203, 204 | PFphC | Pct | PF_SF | optional | number |
| `meter.ac.power_factor.phase_c` | 211, 212, 213, 214 | PFphC | PF | none | optional | number |
| `meter.energy.export.total` | 201, 202, 203, 204, 211, 212, 213, 214 | TotWhExp | Wh | TotWh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | required | number |
| `meter.energy.export.phase_a` | 201, 202, 203, 204, 211, 212, 213, 214 | TotWhExpPhA | Wh | TotWh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.export.phase_b` | 201, 202, 203, 204, 211, 212, 213, 214 | TotWhExpPhB | Wh | TotWh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.export.phase_c` | 201, 202, 203, 204, 211, 212, 213, 214 | TotWhExpPhC | Wh | TotWh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.import.total` | 201, 202, 203, 204, 211, 212, 213, 214 | TotWhImp | Wh | TotWh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | required | number |
| `meter.energy.import.phase_a` | 201, 202, 203, 204, 211, 212, 213, 214 | TotWhImpPhA | Wh | TotWh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.import.phase_b` | 201, 202, 203, 204, 211, 212, 213, 214 | TotWhImpPhB | Wh | TotWh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.import.phase_c` | 201, 202, 203, 204, 211, 212, 213, 214 | TotWhImpPhC | Wh | TotWh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.apparent_export.total` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVAhExp | VAh | TotVAh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.apparent_export.phase_a` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVAhExpPhA | VAh | TotVAh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.apparent_export.phase_b` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVAhExpPhB | VAh | TotVAh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.apparent_export.phase_c` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVAhExpPhC | VAh | TotVAh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.apparent_import.total` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVAhImp | VAh | TotVAh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.apparent_import.phase_a` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVAhImpPhA | VAh | TotVAh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.apparent_import.phase_b` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVAhImpPhB | VAh | TotVAh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.apparent_import.phase_c` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVAhImpPhC | VAh | TotVAh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.reactive_import.q1.total` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVArhImpQ1 | varh | TotVArh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.reactive_import.q2.total` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVArhImpQ2 | varh | TotVArh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.reactive_export.q3.total` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVArhExpQ3 | varh | TotVArh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.reactive_export.q4.total` | 201, 202, 203, 204, 211, 212, 213, 214 | TotVArhExpQ4 | varh | TotVArh_SF on 201, 202, 203, and 204; none on 211, 212, 213, and 214 | optional | number |
| `meter.energy.reactive_import.q1.phase_a` | 201, 202, 203, 204 | TotVArhImpQ1PhA | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_import.q1.phase_a` | 211, 212, 213, 214 | TotVArhImpQ1phA | varh | none | optional | number |
| `meter.energy.reactive_import.q1.phase_b` | 201, 202, 203, 204 | TotVArhImpQ1PhB | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_import.q1.phase_b` | 211, 212, 213, 214 | TotVArhImpQ1phB | varh | none | optional | number |
| `meter.energy.reactive_import.q1.phase_c` | 201, 202, 203, 204 | TotVArhImpQ1PhC | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_import.q1.phase_c` | 211, 212, 213, 214 | TotVArhImpQ1phC | varh | none | optional | number |
| `meter.energy.reactive_import.q2.phase_a` | 201, 202, 203, 204 | TotVArhImpQ2PhA | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_import.q2.phase_a` | 211, 212, 213, 214 | TotVArhImpQ2phA | varh | none | optional | number |
| `meter.energy.reactive_import.q2.phase_b` | 201, 202, 203, 204 | TotVArhImpQ2PhB | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_import.q2.phase_b` | 211, 212, 213, 214 | TotVArhImpQ2phB | varh | none | optional | number |
| `meter.energy.reactive_import.q2.phase_c` | 201, 202, 203, 204 | TotVArhImpQ2PhC | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_import.q2.phase_c` | 211, 212, 213, 214 | TotVArhImpQ2phC | varh | none | optional | number |
| `meter.energy.reactive_export.q3.phase_a` | 201, 202, 203, 204 | TotVArhExpQ3PhA | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_export.q3.phase_a` | 211, 212, 213, 214 | TotVArhExpQ3phA | varh | none | optional | number |
| `meter.energy.reactive_export.q3.phase_b` | 201, 202, 203, 204 | TotVArhExpQ3PhB | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_export.q3.phase_b` | 211, 212, 213, 214 | TotVArhExpQ3phB | varh | none | optional | number |
| `meter.energy.reactive_export.q3.phase_c` | 201, 202, 203, 204 | TotVArhExpQ3PhC | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_export.q3.phase_c` | 211, 212, 213, 214 | TotVArhExpQ3phC | varh | none | optional | number |
| `meter.energy.reactive_export.q4.phase_a` | 201, 202, 203, 204 | TotVArhExpQ4PhA | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_export.q4.phase_a` | 211, 212, 213, 214 | TotVArhExpQ4phA | varh | none | optional | number |
| `meter.energy.reactive_export.q4.phase_b` | 201, 202, 203, 204 | TotVArhExpQ4PhB | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_export.q4.phase_b` | 211, 212, 213, 214 | TotVArhExpQ4phB | varh | none | optional | number |
| `meter.energy.reactive_export.q4.phase_c` | 201, 202, 203, 204 | TotVArhExpQ4PhC | varh | TotVArh_SF | optional | number |
| `meter.energy.reactive_export.q4.phase_c` | 211, 212, 213, 214 | TotVArhExpQ4phC | varh | none | optional | number |
| `meter.events` | 201, 202, 203, 204, 211, 212, 213, 214 | Evt | none | none | required | bitfield |
## Safety and Non-Claims

Documented support is declared from the public standard, and a hardware test is a recorded level. A point the model documents as writable gets an operation on the controls page or by hand in the modbusreg namespace.
