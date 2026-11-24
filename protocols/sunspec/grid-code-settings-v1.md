# SunSpec grid-code settings

These settings have no SemReg element; they are documented registers decoded and callable by hand through MCP and GraphQL in the modbusreg namespace, as an advanced facility.

Models 703 and 707, 708, and 709 are documented, readable, and decoded and callable by hand through MCP and GraphQL in the modbusreg namespace. A point in the tables is callable by hand only when its access is RW.

The point tables cite the public SunSpec model catalog by model id. A point that omits access uses the catalog schema default R. An id from 125 through 145 with no catalog model is named and this page adds no points for it.

## Model 125

Model 125, Pricing, declared length 8.

Source model id 125 (`pricing`) in the public SunSpec model catalog.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 125 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ModEna | 2 | 1 | bitfield16 | none | none | RW | ENABLE=0 | Mode-enable bits. | yes |
| SigType | 3 | 1 | enum16 | none | none | RW | UNKNOWN=0, ABSOLUTE=1, RELATIVE=2, MULTIPLIER=3, LEVEL=4 | Kind of pricing signal. | yes |
| Sig | 4 | 1 | int16 | Sig_SF | none | RW | none | Pricing-signal magnitude. | yes |
| WinTms | 5 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvtTms | 6 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 7 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| Sig_SF | 8 | 1 | sunssf | none | none | R | none | Scale factor Sig_SF. | no |
| Pad | 9 | 1 | pad | none | none | R | none | Unused padding word. | no |

## Model 126

Model 126, Static Volt-VAR, declared length 10 + NCrv * 54.

Source model id 126 (`volt_var`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*54. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 126 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| V_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| DeptRef_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor DeptRef_SF. | no |
| RmpIncDec_SF | 11 | 1 | sunssf | none | none | R | none | Scale factor RmpIncDec_SF. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*54 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| DeptRef | 13+(i-1)*54 | 1 | enum16 | none | none | RW | WMax=1, VArMax=2, VArAval=3 | Reference selected for the dependent axis. | yes |
| V1 | 14+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 1 of this curve. | yes |
| VAr1 | 15+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 1 of this curve. | yes |
| V2 | 16+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 2 of this curve. | yes |
| VAr2 | 17+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 2 of this curve. | yes |
| V3 | 18+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 3 of this curve. | yes |
| VAr3 | 19+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 3 of this curve. | yes |
| V4 | 20+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 4 of this curve. | yes |
| VAr4 | 21+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 4 of this curve. | yes |
| V5 | 22+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 5 of this curve. | yes |
| VAr5 | 23+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 5 of this curve. | yes |
| V6 | 24+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 6 of this curve. | yes |
| VAr6 | 25+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 6 of this curve. | yes |
| V7 | 26+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 7 of this curve. | yes |
| VAr7 | 27+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 7 of this curve. | yes |
| V8 | 28+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 8 of this curve. | yes |
| VAr8 | 29+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 8 of this curve. | yes |
| V9 | 30+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 9 of this curve. | yes |
| VAr9 | 31+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 9 of this curve. | yes |
| V10 | 32+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 10 of this curve. | yes |
| VAr10 | 33+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 10 of this curve. | yes |
| V11 | 34+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 11 of this curve. | yes |
| VAr11 | 35+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 11 of this curve. | yes |
| V12 | 36+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 12 of this curve. | yes |
| VAr12 | 37+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 12 of this curve. | yes |
| V13 | 38+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 13 of this curve. | yes |
| VAr13 | 39+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 13 of this curve. | yes |
| V14 | 40+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 14 of this curve. | yes |
| VAr14 | 41+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 14 of this curve. | yes |
| V15 | 42+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 15 of this curve. | yes |
| VAr15 | 43+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 15 of this curve. | yes |
| V16 | 44+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 16 of this curve. | yes |
| VAr16 | 45+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 16 of this curve. | yes |
| V17 | 46+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 17 of this curve. | yes |
| VAr17 | 47+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 17 of this curve. | yes |
| V18 | 48+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 18 of this curve. | yes |
| VAr18 | 49+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 18 of this curve. | yes |
| V19 | 50+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 19 of this curve. | yes |
| VAr19 | 51+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 19 of this curve. | yes |
| V20 | 52+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 20 of this curve. | yes |
| VAr20 | 53+(i-1)*54 | 1 | int16 | DeptRef_SF | none | RW | none | Reactive-power coordinate 20 of this curve. | yes |
| CrvNam | 54+(i-1)*54 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| RmpTms | 62+(i-1)*54 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| RmpDecTmm | 63+(i-1)*54 | 1 | uint16 | RmpIncDec_SF | % ref_value/min | RW | none | Ramp-down rate of this curve. | yes |
| RmpIncTmm | 64+(i-1)*54 | 1 | uint16 | RmpIncDec_SF | % ref_value/min | RW | none | Ramp-up rate of this curve. | yes |
| ReadOnly | 65+(i-1)*54 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 127

Model 127, Freq-Watt Param, declared length 10.

Source model id 127 (`freq_watt_param`) in the public SunSpec model catalog.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 127 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| WGra | 2 | 1 | uint16 | WGra_SF | % PM/Hz | RW | none | Active-power gradient. | yes |
| HzStr | 3 | 1 | int16 | HzStrStop_SF | Hz | RW | none | Start frequency. | yes |
| HzStop | 4 | 1 | int16 | HzStrStop_SF | Hz | RW | none | Stop frequency. | yes |
| HysEna | 5 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Hysteresis enable. | yes |
| ModEna | 6 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| HzStopWGra | 7 | 1 | uint16 | RmpIncDec_SF | % WMax/min | RW | none | Power gradient at the stop frequency. | yes |
| WGra_SF | 8 | 1 | sunssf | none | none | R | none | Scale factor WGra_SF. | no |
| HzStrStop_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor HzStrStop_SF. | no |
| RmpIncDec_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor RmpIncDec_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

## Model 128

Model 128, Dynamic Reactive Current, declared length 14.

Source model id 128 (`reactive_current`) in the public SunSpec model catalog.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 128 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ArGraMod | 2 | 1 | enum16 | none | none | RW | EDGE=0, CENTER=1 | Mode of the reactive-current gradient. | yes |
| ArGraSag | 3 | 1 | uint16 | ArGra_SF | %ARtg/%dV | RW | none | Reactive-current gradient used during a voltage sag. | yes |
| ArGraSwell | 4 | 1 | uint16 | ArGra_SF | %ARtg/%dV | RW | none | Reactive-current gradient used during a voltage swell. | yes |
| ModEna | 5 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| FilTms | 6 | 1 | uint16 | none | Secs | RW | none | Filter time. | yes |
| DbVMin | 7 | 1 | uint16 | VRefPct_SF | % VRef | RW | none | Lower voltage of the deadband. | yes |
| DbVMax | 8 | 1 | uint16 | VRefPct_SF | % VRef | RW | none | Upper voltage of the deadband. | yes |
| BlkZnV | 9 | 1 | uint16 | VRefPct_SF | % VRef | RW | none | Blocking-zone voltage. | yes |
| HysBlkZnV | 10 | 1 | uint16 | VRefPct_SF | % VRef | RW | none | Hysteresis of the blocking-zone voltage. | yes |
| BlkZnTmms | 11 | 1 | uint16 | none | mSecs | RW | none | Blocking-zone time. | yes |
| HoldTmms | 12 | 1 | uint16 | none | mSecs | RW | none | Hold time. | yes |
| ArGra_SF | 13 | 1 | sunssf | none | none | R | none | Scale factor ArGra_SF. | no |
| VRefPct_SF | 14 | 1 | sunssf | none | none | R | none | Scale factor VRefPct_SF. | no |
| Pad | 15 | 1 | pad | none | none | R | none | Unused padding word. | no |

## Model 129

Model 129, LVRTD, declared length 10 + NCrv * 50.

Source model id 129 (`lvrt`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 129 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| V_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| V1 | 14+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| V2 | 16+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| V3 | 18+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| V4 | 20+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| V5 | 22+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| V6 | 24+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| V7 | 26+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| V8 | 28+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| V9 | 30+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| V10 | 32+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| V11 | 34+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| V12 | 36+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| V13 | 38+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| V14 | 40+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| V15 | 42+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| V16 | 44+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| V17 | 46+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| V18 | 48+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| V19 | 50+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| V20 | 52+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 130

Model 130, HVRTD, declared length 10 + NCrv * 50.

Source model id 130 (`hvrt`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 130 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| V_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| V1 | 14+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| V2 | 16+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| V3 | 18+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| V4 | 20+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| V5 | 22+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| V6 | 24+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| V7 | 26+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| V8 | 28+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| V9 | 30+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| V10 | 32+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| V11 | 34+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| V12 | 36+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| V13 | 38+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| V14 | 40+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| V15 | 42+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| V16 | 44+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| V17 | 46+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| V18 | 48+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| V19 | 50+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| V20 | 52+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 131

Model 131, Watt-PF, declared length 10 + NCrv * 54.

Source model id 131 (`watt_pf`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*54. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 131 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| W_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor W_SF. | no |
| PF_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor PF_SF. | no |
| RmpIncDec_SF | 11 | 1 | sunssf | none | none | R | none | Scale factor RmpIncDec_SF. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*54 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| W1 | 13+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 1 of this curve. | yes |
| PF1 | 14+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 1 of this curve. | yes |
| W2 | 15+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 2 of this curve. | yes |
| PF2 | 16+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 2 of this curve. | yes |
| W3 | 17+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 3 of this curve. | yes |
| PF3 | 18+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 3 of this curve. | yes |
| W4 | 19+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 4 of this curve. | yes |
| PF4 | 20+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 4 of this curve. | yes |
| W5 | 21+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 5 of this curve. | yes |
| PF5 | 22+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 5 of this curve. | yes |
| W6 | 23+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 6 of this curve. | yes |
| PF6 | 24+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 6 of this curve. | yes |
| W7 | 25+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 7 of this curve. | yes |
| PF7 | 26+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 7 of this curve. | yes |
| W8 | 27+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 8 of this curve. | yes |
| PF8 | 28+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 8 of this curve. | yes |
| W9 | 29+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 9 of this curve. | yes |
| PF9 | 30+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 9 of this curve. | yes |
| W10 | 31+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 10 of this curve. | yes |
| PF10 | 32+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 10 of this curve. | yes |
| W11 | 33+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 11 of this curve. | yes |
| PF11 | 34+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 11 of this curve. | yes |
| W12 | 35+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 12 of this curve. | yes |
| PF12 | 36+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 12 of this curve. | yes |
| W13 | 37+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 13 of this curve. | yes |
| PF13 | 38+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 13 of this curve. | yes |
| W14 | 39+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 14 of this curve. | yes |
| PF14 | 40+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 14 of this curve. | yes |
| W15 | 41+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 15 of this curve. | yes |
| PF15 | 42+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 15 of this curve. | yes |
| W16 | 43+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 16 of this curve. | yes |
| PF16 | 44+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 16 of this curve. | yes |
| W17 | 45+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 17 of this curve. | yes |
| PF17 | 46+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 17 of this curve. | yes |
| W18 | 47+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 18 of this curve. | yes |
| PF18 | 48+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 18 of this curve. | yes |
| W19 | 49+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 19 of this curve. | yes |
| PF19 | 50+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 19 of this curve. | yes |
| W20 | 51+(i-1)*54 | 1 | int16 | W_SF | % WMax | RW | none | Active-power coordinate 20 of this curve. | yes |
| PF20 | 52+(i-1)*54 | 1 | int16 | PF_SF | cos() | RW | none | Power-factor coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*54 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| RmpPT1Tms | 61+(i-1)*54 | 1 | uint16 | none | Secs | RW | none | Ramp time of the first point. | yes |
| RmpDecTmm | 62+(i-1)*54 | 1 | uint16 | RmpIncDec_SF | % PF/min | RW | none | Ramp-down rate of this curve. | yes |
| RmpIncTmm | 63+(i-1)*54 | 1 | uint16 | RmpIncDec_SF | % PF/min | RW | none | Ramp-up rate of this curve. | yes |
| ReadOnly | 64+(i-1)*54 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |
| Pad | 65+(i-1)*54 | 1 | pad | none | none | R | none | Unused padding word. | no |

## Model 132

Model 132, Volt-Watt, declared length 10 + NCrv * 54.

Source model id 132 (`volt_watt`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*54. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 132 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| V_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| DeptRef_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor DeptRef_SF. | no |
| RmpIncDec_SF | 11 | 1 | sunssf | none | none | R | none | Scale factor RmpIncDec_SF. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*54 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| DeptRef | 13+(i-1)*54 | 1 | enum16 | none | none | RW | %WMax=1, %WAval=2 | Reference selected for the dependent axis. | yes |
| V1 | 14+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 1 of this curve. | yes |
| W1 | 15+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 1 of this curve. | yes |
| V2 | 16+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 2 of this curve. | yes |
| W2 | 17+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 2 of this curve. | yes |
| V3 | 18+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 3 of this curve. | yes |
| W3 | 19+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 3 of this curve. | yes |
| V4 | 20+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 4 of this curve. | yes |
| W4 | 21+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 4 of this curve. | yes |
| V5 | 22+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 5 of this curve. | yes |
| W5 | 23+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 5 of this curve. | yes |
| V6 | 24+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 6 of this curve. | yes |
| W6 | 25+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 6 of this curve. | yes |
| V7 | 26+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 7 of this curve. | yes |
| W7 | 27+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 7 of this curve. | yes |
| V8 | 28+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 8 of this curve. | yes |
| W8 | 29+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 8 of this curve. | yes |
| V9 | 30+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 9 of this curve. | yes |
| W9 | 31+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 9 of this curve. | yes |
| V10 | 32+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 10 of this curve. | yes |
| W10 | 33+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 10 of this curve. | yes |
| V11 | 34+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 11 of this curve. | yes |
| W11 | 35+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 11 of this curve. | yes |
| V12 | 36+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 12 of this curve. | yes |
| W12 | 37+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 12 of this curve. | yes |
| V13 | 38+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 13 of this curve. | yes |
| W13 | 39+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 13 of this curve. | yes |
| V14 | 40+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 14 of this curve. | yes |
| W14 | 41+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 14 of this curve. | yes |
| V15 | 42+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 15 of this curve. | yes |
| W15 | 43+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 15 of this curve. | yes |
| V16 | 44+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 16 of this curve. | yes |
| W16 | 45+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 16 of this curve. | yes |
| V17 | 46+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 17 of this curve. | yes |
| W17 | 47+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 17 of this curve. | yes |
| V18 | 48+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 18 of this curve. | yes |
| W18 | 49+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 18 of this curve. | yes |
| V19 | 50+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 19 of this curve. | yes |
| W19 | 51+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 19 of this curve. | yes |
| V20 | 52+(i-1)*54 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 20 of this curve. | yes |
| W20 | 53+(i-1)*54 | 1 | int16 | DeptRef_SF | % VRef | RW | none | Active-power coordinate 20 of this curve. | yes |
| CrvNam | 54+(i-1)*54 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| RmpPt1Tms | 62+(i-1)*54 | 1 | uint16 | none | Secs | RW | none | Ramp time of the first point. | yes |
| RmpDecTmm | 63+(i-1)*54 | 1 | uint16 | RmpIncDec_SF | % WMax/min | RW | none | Ramp-down rate of this curve. | yes |
| RmpIncTmm | 64+(i-1)*54 | 1 | uint16 | RmpIncDec_SF | % WMax/min | RW | none | Ramp-up rate of this curve. | yes |
| ReadOnly | 65+(i-1)*54 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 133

Model 133, Basic Scheduling, declared length 6 + NSchd * 60.

Source model id 133 (`schedule`) in the public SunSpec model catalog. The repeating block is `repeating`, one instance per `NSchd`. Instance i, counting from 1, starts at model word 8 + (i-1)*60. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 133 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActSchd | 2 | 2 | bitfield32 | none | none | RW | SCHED1=0, SCHED2=1, SCHED3=2, SCHED4=3, SCHED5=4, SCHED6=5, SCHED7=6, SCHED8=7, SCHED9=8, SCHED10=9, SCHED12=10, SCHED13=11, SCHED14=12, SCHED15=13, SCHED16=14, SCHED17=15, SCHED18=16, SCHED19=17, SCHED20=18, SCHED21=19, SCHED22=21, SCHED23=22, SCHED24=23, SCHED25=24, SCHED26=25, SCHED27=26, SCHED28=27, SCHED29=28, SCHED30=29, SCHED31=30, SCHED32=31 | Index of the active schedule. | yes |
| ModEna | 4 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| NSchd | 5 | 1 | uint16 | none | none | R | none | Number of stored schedules. | no |
| NPts | 6 | 1 | uint16 | none | none | R | none | Number of schedule points. | no |
| Pad | 7 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPts | 8+(i-1)*60 | 1 | uint16 | none | none | RW | none | Observed count of active schedule points. | yes |
| StrTms | 9+(i-1)*60 | 2 | uint32 | none | Secs | RW | none | Start time of this schedule. | yes |
| RepPer | 11+(i-1)*60 | 1 | uint16 | none | none | RW | none | Repeat period of this schedule. | yes |
| IntvTyp | 12+(i-1)*60 | 1 | enum16 | none | none | RW | ONETIME=0, DAILY=1, WEEKLY=2, MONTHLY=3, WEEKDAY=4, HOLIDAY=5, WEEKEND=6, YEARLY=7 | Schedule interval kind. | yes |
| XTyp | 13+(i-1)*60 | 1 | enum16 | none | none | RW | UNSET=0, TIME=1, TEMP=2, PRICE=3, OTHER=99 | Kind of independent-axis value. | yes |
| X_SF | 14+(i-1)*60 | 1 | sunssf | none | none | RW | none | Scale factor X_SF. | yes |
| YTyp | 15+(i-1)*60 | 1 | enum16 | none | none | RW | UNSET=0, WMax=1, RSRVD2=2, PF=3, RSRVD4=4, WATT_PRICE=5, VAR_PRICE=6, RSRVD7=7, VOLT_VAR_ARRAY=8, WChaGra=9, WDisChaGra=10, VArAval=11, Schedule=12, OTHER=99 | Kind of dependent-axis value. | yes |
| Y_SF | 16+(i-1)*60 | 1 | sunssf | none | none | RW | none | Scale factor Y_SF. | yes |
| X1 | 17+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 1 of this curve. | yes |
| Y1 | 19+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 1 of this curve. | yes |
| X2 | 21+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 2 of this curve. | yes |
| Y2 | 23+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 2 of this curve. | yes |
| X3 | 25+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 3 of this curve. | yes |
| Y3 | 27+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 3 of this curve. | yes |
| X4 | 29+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 4 of this curve. | yes |
| Y4 | 31+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 4 of this curve. | yes |
| X5 | 33+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 5 of this curve. | yes |
| Y5 | 35+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 5 of this curve. | yes |
| X6 | 37+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 6 of this curve. | yes |
| Y6 | 39+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 6 of this curve. | yes |
| X7 | 41+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 7 of this curve. | yes |
| Y7 | 43+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 7 of this curve. | yes |
| X8 | 45+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 8 of this curve. | yes |
| Y8 | 47+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 8 of this curve. | yes |
| X9 | 49+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 9 of this curve. | yes |
| Y9 | 51+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 9 of this curve. | yes |
| X10 | 53+(i-1)*60 | 2 | int32 | X_SF | none | RW | none | Independent-axis coordinate 10 of this curve. | yes |
| Y10 | 55+(i-1)*60 | 2 | int32 | Y_SF | none | RW | none | Dependent-axis coordinate 10 of this curve. | yes |
| Nam | 57+(i-1)*60 | 8 | string | none | none | RW | none | Name stored with this schedule. | yes |
| WinTms | 65+(i-1)*60 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RmpTms | 66+(i-1)*60 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| ActIndx | 67+(i-1)*60 | 1 | uint16 | none | none | R | none | Index of the active schedule entry. | no |

## Model 134

Model 134, Freq-Watt Crv, declared length 10 + NCrv * 58.

Source model id 134 (`freq_watt`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*58. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 134 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Hz_SF | 9 | 1 | sunssf | none | SF | R | none | Scale factor Hz_SF. | no |
| W_SF | 10 | 1 | sunssf | none | SF | R | none | Scale factor W_SF. | no |
| RmpIncDec_SF | 11 | 1 | sunssf | none | SF | R | none | Scale factor RmpIncDec_SF. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*58 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Hz1 | 13+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 1 of this curve. | yes |
| W1 | 14+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 1 of this curve. | yes |
| Hz2 | 15+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 2 of this curve. | yes |
| W2 | 16+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 2 of this curve. | yes |
| Hz3 | 17+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 3 of this curve. | yes |
| W3 | 18+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 3 of this curve. | yes |
| Hz4 | 19+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 4 of this curve. | yes |
| W4 | 20+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 4 of this curve. | yes |
| Hz5 | 21+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 5 of this curve. | yes |
| W5 | 22+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 5 of this curve. | yes |
| Hz6 | 23+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 6 of this curve. | yes |
| W6 | 24+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 6 of this curve. | yes |
| Hz7 | 25+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 7 of this curve. | yes |
| W7 | 26+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 7 of this curve. | yes |
| Hz8 | 27+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 8 of this curve. | yes |
| W8 | 28+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 8 of this curve. | yes |
| Hz9 | 29+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 9 of this curve. | yes |
| W9 | 30+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 9 of this curve. | yes |
| Hz10 | 31+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 10 of this curve. | yes |
| W10 | 32+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 10 of this curve. | yes |
| Hz11 | 33+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 11 of this curve. | yes |
| W11 | 34+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 11 of this curve. | yes |
| Hz12 | 35+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 12 of this curve. | yes |
| W12 | 36+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 12 of this curve. | yes |
| Hz13 | 37+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 13 of this curve. | yes |
| W13 | 38+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 13 of this curve. | yes |
| Hz14 | 39+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 14 of this curve. | yes |
| W14 | 40+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 14 of this curve. | yes |
| Hz15 | 41+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 15 of this curve. | yes |
| W15 | 42+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 15 of this curve. | yes |
| Hz16 | 43+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 16 of this curve. | yes |
| W16 | 44+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 16 of this curve. | yes |
| Hz17 | 45+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 17 of this curve. | yes |
| W17 | 46+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 17 of this curve. | yes |
| Hz18 | 47+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 18 of this curve. | yes |
| W18 | 48+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 18 of this curve. | yes |
| Hz19 | 49+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 19 of this curve. | yes |
| W19 | 50+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 19 of this curve. | yes |
| Hz20 | 51+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 20 of this curve. | yes |
| W20 | 52+(i-1)*58 | 1 | int16 | W_SF | % WRef | RW | none | Active-power coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*58 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| RmpPT1Tms | 61+(i-1)*58 | 1 | uint16 | none | Secs | RW | none | Ramp time of the first point. | yes |
| RmpDecTmm | 62+(i-1)*58 | 1 | uint16 | RmpIncDec_SF | % WMax/min | RW | none | Ramp-down rate of this curve. | yes |
| RmpIncTmm | 63+(i-1)*58 | 1 | uint16 | RmpIncDec_SF | % WMax/min | RW | none | Ramp-up rate of this curve. | yes |
| RmpRsUp | 64+(i-1)*58 | 1 | uint16 | RmpIncDec_SF | % WMax/min | RW | none | Ramp-up setting of this curve. | yes |
| SnptW | 65+(i-1)*58 | 1 | bitfield16 | none | none | RW | none | Stored active-power snapshot of this curve. | yes |
| WRef | 66+(i-1)*58 | 1 | uint16 | W_SF | W | RW | none | Active-power reference. | yes |
| WRefStrHz | 67+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Active-power reference at the start frequency. | yes |
| WRefStopHz | 68+(i-1)*58 | 1 | uint16 | Hz_SF | Hz | RW | none | Active-power reference at the stop frequency. | yes |
| ReadOnly | 69+(i-1)*58 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 135

Model 135, LFRT, declared length 10 + NCrv * 50.

Source model id 135 (`lfrt`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 135 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| Hz_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor Hz_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| Hz1 | 14+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| Hz2 | 16+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| Hz3 | 18+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| Hz4 | 20+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| Hz5 | 22+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| Hz6 | 24+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| Hz7 | 26+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| Hz8 | 28+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| Hz9 | 30+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| Hz10 | 32+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| Hz11 | 34+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| Hz12 | 36+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| Hz13 | 38+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| Hz14 | 40+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| Hz15 | 42+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| Hz16 | 44+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| Hz17 | 46+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| Hz18 | 48+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| Hz19 | 50+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| Hz20 | 52+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 136

Model 136, HFRT, declared length 10 + NCrv * 50.

Source model id 136 (`hfrt`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 136 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| Hz_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor Hz_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| Hz1 | 14+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| Hz2 | 16+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| Hz3 | 18+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| Hz4 | 20+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| Hz5 | 22+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| Hz6 | 24+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| Hz7 | 26+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| Hz8 | 28+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| Hz9 | 30+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| Hz10 | 32+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| Hz11 | 34+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| Hz12 | 36+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| Hz13 | 38+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| Hz14 | 40+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| Hz15 | 42+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| Hz16 | 44+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| Hz17 | 46+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| Hz18 | 48+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| Hz19 | 50+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| Hz20 | 52+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 137

Model 137, LVRTC, declared length 10 + NCrv * 50.

Source model id 137 (`lvrtc`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 137 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| V_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| V1 | 14+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| V2 | 16+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| V3 | 18+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| V4 | 20+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| V5 | 22+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| V6 | 24+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| V7 | 26+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| V8 | 28+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| V9 | 30+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| V10 | 32+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| V11 | 34+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| V12 | 36+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| V13 | 38+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| V14 | 40+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| V15 | 42+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| V16 | 44+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| V17 | 46+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| V18 | 48+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| V19 | 50+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| V20 | 52+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 138

Model 138, HVRTC, declared length 10 + NCrv * 50.

Source model id 138 (`hvrtc`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 138 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| V_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| V1 | 14+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| V2 | 16+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| V3 | 18+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| V4 | 20+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| V5 | 22+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| V6 | 24+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| V7 | 26+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| V8 | 28+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| V9 | 30+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| V10 | 32+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| V11 | 34+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| V12 | 36+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| V13 | 38+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| V14 | 40+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| V15 | 42+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| V16 | 44+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| V17 | 46+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| V18 | 48+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| V19 | 50+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| V20 | 52+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 139

Model 139, LVRTX, declared length 10 + NCrv * 50.

Source model id 139 (`lvrtx`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 139 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| V_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| CrvType | 11 | 1 | enum16 | none | none | R | CEASE_TO_ENERGIZE=1 | Kind of curve stored in this block. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| V1 | 14+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| V2 | 16+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| V3 | 18+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| V4 | 20+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| V5 | 22+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| V6 | 24+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| V7 | 26+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| V8 | 28+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| V9 | 30+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| V10 | 32+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| V11 | 34+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| V12 | 36+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| V13 | 38+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| V14 | 40+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| V15 | 42+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| V16 | 44+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| V17 | 46+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| V18 | 48+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| V19 | 50+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| V20 | 52+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 140

Model 140, HVRTX, declared length 10 + NCrv * 50.

Source model id 140 (`hvrtx`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 140 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| V_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| CrvType | 11 | 1 | enum16 | none | none | R | CEASE_TO_ENERGIZE=1 | Kind of curve stored in this block. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| V1 | 14+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| V2 | 16+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| V3 | 18+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| V4 | 20+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| V5 | 22+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| V6 | 24+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| V7 | 26+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| V8 | 28+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| V9 | 30+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| V10 | 32+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| V11 | 34+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| V12 | 36+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| V13 | 38+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| V14 | 40+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| V15 | 42+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| V16 | 44+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| V17 | 46+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| V18 | 48+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| V19 | 50+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| V20 | 52+(i-1)*50 | 1 | uint16 | V_SF | % VRef | RW | none | Voltage coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 141

Model 141, LFRTC, declared length 10 + NCrv * 50.

Source model id 141 (`lfrtc`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 141 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| Hz_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor Hz_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| Hz1 | 14+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| Hz2 | 16+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| Hz3 | 18+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| Hz4 | 20+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| Hz5 | 22+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| Hz6 | 24+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| Hz7 | 26+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| Hz8 | 28+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| Hz9 | 30+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| Hz10 | 32+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| Hz11 | 34+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| Hz12 | 36+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| Hz13 | 38+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| Hz14 | 40+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| Hz15 | 42+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| Hz16 | 44+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| Hz17 | 46+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| Hz18 | 48+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| Hz19 | 50+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| Hz20 | 52+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 142

Model 142, HFRTC, declared length 10 + NCrv * 50.

Source model id 142 (`hfrtc`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 142 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| Hz_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor Hz_SF. | no |
| Pad | 11 | 1 | pad | none | none | R | none | Unused padding word. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| Hz1 | 14+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| Hz2 | 16+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| Hz3 | 18+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| Hz4 | 20+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| Hz5 | 22+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| Hz6 | 24+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| Hz7 | 26+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| Hz8 | 28+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| Hz9 | 30+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| Hz10 | 32+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| Hz11 | 34+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| Hz12 | 36+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| Hz13 | 38+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| Hz14 | 40+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| Hz15 | 42+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| Hz16 | 44+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| Hz17 | 46+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| Hz18 | 48+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| Hz19 | 50+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| Hz20 | 52+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 143

Model 143, LFRTX, declared length 10 + NCrv * 50.

Source model id 143 (`lfrtx`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 143 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| Hz_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor Hz_SF. | no |
| CrvType | 11 | 1 | enum16 | none | none | R | CEASE_TO_ENERGIZE=1 | Kind of curve stored in this block. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| Hz1 | 14+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| Hz2 | 16+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| Hz3 | 18+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| Hz4 | 20+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| Hz5 | 22+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| Hz6 | 24+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| Hz7 | 26+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| Hz8 | 28+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| Hz9 | 30+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| Hz10 | 32+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| Hz11 | 34+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| Hz12 | 36+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| Hz13 | 38+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| Hz14 | 40+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| Hz15 | 42+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| Hz16 | 44+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| Hz17 | 46+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| Hz18 | 48+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| Hz19 | 50+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| Hz20 | 52+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 144

Model 144, HFRTX, declared length 10 + NCrv * 50.

Source model id 144 (`hfrtx`) in the public SunSpec model catalog. The repeating block is `curve`, one instance per `NCrv`. Instance i, counting from 1, starts at model word 12 + (i-1)*50. The offset column is that model word.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 144 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ActCrv | 2 | 1 | uint16 | none | none | RW | none | Index of the active curve. | yes |
| ModEna | 3 | 1 | bitfield16 | none | none | RW | ENABLED=0 | Mode-enable bits. | yes |
| WinTms | 4 | 1 | uint16 | none | Secs | RW | none | Time window. | yes |
| RvrtTms | 5 | 1 | uint16 | none | Secs | RW | none | Revert time. | yes |
| RmpTms | 6 | 1 | uint16 | none | Secs | RW | none | Ramp time. | yes |
| NCrv | 7 | 1 | uint16 | none | none | R | none | Number of stored curves. | no |
| NPt | 8 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| Tms_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |
| Hz_SF | 10 | 1 | sunssf | none | none | R | none | Scale factor Hz_SF. | no |
| CrvType | 11 | 1 | enum16 | none | none | R | CEASE_TO_ENERGIZE=1 | Kind of curve stored in this block. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ActPt | 12+(i-1)*50 | 1 | uint16 | none | none | RW | none | Observed count of active points. It does not select the layout. | yes |
| Tms1 | 13+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 1 of this curve. | yes |
| Hz1 | 14+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 1 of this curve. | yes |
| Tms2 | 15+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 2 of this curve. | yes |
| Hz2 | 16+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 2 of this curve. | yes |
| Tms3 | 17+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 3 of this curve. | yes |
| Hz3 | 18+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 3 of this curve. | yes |
| Tms4 | 19+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 4 of this curve. | yes |
| Hz4 | 20+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 4 of this curve. | yes |
| Tms5 | 21+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 5 of this curve. | yes |
| Hz5 | 22+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 5 of this curve. | yes |
| Tms6 | 23+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 6 of this curve. | yes |
| Hz6 | 24+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 6 of this curve. | yes |
| Tms7 | 25+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 7 of this curve. | yes |
| Hz7 | 26+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 7 of this curve. | yes |
| Tms8 | 27+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 8 of this curve. | yes |
| Hz8 | 28+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 8 of this curve. | yes |
| Tms9 | 29+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 9 of this curve. | yes |
| Hz9 | 30+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 9 of this curve. | yes |
| Tms10 | 31+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 10 of this curve. | yes |
| Hz10 | 32+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 10 of this curve. | yes |
| Tms11 | 33+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 11 of this curve. | yes |
| Hz11 | 34+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 11 of this curve. | yes |
| Tms12 | 35+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 12 of this curve. | yes |
| Hz12 | 36+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 12 of this curve. | yes |
| Tms13 | 37+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 13 of this curve. | yes |
| Hz13 | 38+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 13 of this curve. | yes |
| Tms14 | 39+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 14 of this curve. | yes |
| Hz14 | 40+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 14 of this curve. | yes |
| Tms15 | 41+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 15 of this curve. | yes |
| Hz15 | 42+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 15 of this curve. | yes |
| Tms16 | 43+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 16 of this curve. | yes |
| Hz16 | 44+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 16 of this curve. | yes |
| Tms17 | 45+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 17 of this curve. | yes |
| Hz17 | 46+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 17 of this curve. | yes |
| Tms18 | 47+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 18 of this curve. | yes |
| Hz18 | 48+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 18 of this curve. | yes |
| Tms19 | 49+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 19 of this curve. | yes |
| Hz19 | 50+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 19 of this curve. | yes |
| Tms20 | 51+(i-1)*50 | 1 | uint16 | Tms_SF | Secs | RW | none | Time coordinate 20 of this curve. | yes |
| Hz20 | 52+(i-1)*50 | 1 | uint16 | Hz_SF | Hz | RW | none | Frequency coordinate 20 of this curve. | yes |
| CrvNam | 53+(i-1)*50 | 8 | string | none | none | RW | none | Name stored with this curve. | yes |
| ReadOnly | 61+(i-1)*50 | 1 | enum16 | none | none | R | READWRITE=0, READONLY=1 | Stored access mark of this curve. | no |

## Model 145

Model 145, Extended Settings, declared length 8.

Source model id 145 (`ext_settings`) in the public SunSpec model catalog.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 145 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| NomRmpUpRte | 2 | 1 | uint16 | Rmp_SF | Pct | RW | none | Nominal ramp-up rate. | yes |
| NomRmpDnRte | 3 | 1 | uint16 | Rmp_SF | Pct | RW | none | Nominal ramp-down rate. | yes |
| EmgRmpUpRte | 4 | 1 | uint16 | Rmp_SF | Pct | RW | none | Emergency ramp-up rate. | yes |
| EmgRmpDnRte | 5 | 1 | uint16 | Rmp_SF | Pct | RW | none | Emergency ramp-down rate. | yes |
| ConnRmpUpRte | 6 | 1 | uint16 | Rmp_SF | Pct | RW | none | Ramp-up rate used when connecting. | yes |
| ConnRmpDnRte | 7 | 1 | uint16 | Rmp_SF | Pct | RW | none | Ramp-down rate used when connecting. | yes |
| AGra | 8 | 1 | uint16 | Rmp_SF | Pct | RW | none | Default ramp rate. | yes |
| Rmp_SF | 9 | 1 | sunssf | none | none | R | none | Scale factor Rmp_SF. | no |

## Model 703

Model 703, Enter Service, declared length 17.

Source model id 703 (`DEREnterService`) in the public SunSpec model catalog.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 703 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| ES | 2 | 1 | enum16 | none | none | RW | DISABLED=0, ENABLED=1 | Enter-service permission. | yes |
| ESVHi | 3 | 1 | uint16 | V_SF | Pct | RW | none | Enter-service voltage high threshold. | yes |
| ESVLo | 4 | 1 | uint16 | V_SF | Pct | RW | none | Enter-service voltage low threshold. | yes |
| ESHzHi | 5 | 2 | uint32 | Hz_SF | Hz | RW | none | Enter-service frequency high threshold. | yes |
| ESHzLo | 7 | 2 | uint32 | Hz_SF | Hz | RW | none | Enter-service frequency low threshold. | yes |
| ESDlyTms | 9 | 2 | uint32 | none | Secs | RW | none | Enter-service delay. | yes |
| ESRndTms | 11 | 2 | uint32 | none | Secs | RW | none | Enter-service random delay. | yes |
| ESRmpTms | 13 | 2 | uint32 | none | Secs | RW | none | Enter-service ramp time. | yes |
| ESDlyRemTms | 15 | 2 | uint32 | none | Secs | R | none | Enter-service delay still remaining. | no |
| V_SF | 17 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| Hz_SF | 18 | 1 | sunssf | none | none | R | none | Scale factor Hz_SF. | no |

## Model 707

Model 707, DER Trip LV (`DERTripLV`). Declared length is L = 7 + C*(4 + 9*P), where C is `NCrvSet` and P is `NPt`. The repeating block uses the low-voltage trip template geometry: each nested point is V as one uint16 then Tms as one uint32. Access, units, and symbols in the tables are this model's own catalog rows.

Source model id 707 in the public SunSpec model catalog. Curve i, counting from 1, starts at model word 9+(i-1)*(4+9*P). Point j inside a nested curve counts from 1. Offsets below are model words.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 707 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| Ena | 2 | 1 | enum16 | none | none | RW | DISABLED=0, ENABLED=1 | Enable word of this occurrence. | yes |
| AdptCrvReq | 3 | 1 | uint16 | none | none | RW | none | Request to adopt a stored curve. | yes |
| AdptCrvRslt | 4 | 1 | enum16 | none | none | R | IN_PROGRESS=0, COMPLETED=1, FAILED=2 | Result of the adopt-curve request. | no |
| NPt | 5 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| NCrvSet | 6 | 1 | uint16 | none | none | R | none | Number of stored curve sets. | no |
| V_SF | 7 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| Tms_SF | 8 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ReadOnly | 9+(i-1)*(4+9*P) | 1 | enum16 | none | none | R | RW=0, R=1 | Stored access mark of this curve. | no |
| MustTrip.ActPt | 9+(i-1)*(4+9*P)+1 | 1 | uint16 | none | none | RW | none | Observed active-point count on the must-trip curve. It does not select the layout. | yes |
| MustTrip.V | 9+(i-1)*(4+9*P)+2+(j-1)*3 | 1 | uint16 | V_SF | VNomPct | RW | none | Voltage sample on the must-trip curve. | yes |
| MustTrip.Tms | 9+(i-1)*(4+9*P)+3+(j-1)*3 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the must-trip curve. | yes |
| MayTrip.ActPt | 9+(i-1)*(4+9*P)+2+3*P | 1 | uint16 | none | none | RW | none | Observed active-point count on the may-trip curve. It does not select the layout. | yes |
| MayTrip.V | 9+(i-1)*(4+9*P)+3+3*P+(j-1)*3 | 1 | uint16 | V_SF | VNomPct | RW | none | Voltage sample on the may-trip curve. | yes |
| MayTrip.Tms | 9+(i-1)*(4+9*P)+4+3*P+(j-1)*3 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the may-trip curve. | yes |
| MomCess.ActPt | 9+(i-1)*(4+9*P)+3+6*P | 1 | uint16 | none | none | RW | none | Observed active-point count on the momentary-cessation curve. It does not select the layout. | yes |
| MomCess.V | 9+(i-1)*(4+9*P)+4+6*P+(j-1)*3 | 1 | uint16 | V_SF | VNomPct | RW | none | Voltage sample on the momentary-cessation curve. | yes |
| MomCess.Tms | 9+(i-1)*(4+9*P)+5+6*P+(j-1)*3 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the momentary-cessation curve. | yes |

## Model 708

Model 708, DER Trip HV (`DERTripHV`). Declared length is L = 7 + C*(4 + 9*P), where C is `NCrvSet` and P is `NPt`. Each nested point is this model's own span, V as one uint16 and Tms as one uint32, three registers. This section does not take field identifiers, units, enumerations, access, or sentinels from model 707. Multi-register word order is not stated by these point rows, so it stays unknown.

Source model id 708 in the public SunSpec model catalog. Curve i, counting from 1, starts at model word 9+(i-1)*(4+9*P). Point j inside a nested curve counts from 1. Offsets below are model words.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 708 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| Ena | 2 | 1 | enum16 | none | none | RW | DISABLED=0, ENABLED=1 | Enable word of this occurrence. | yes |
| AdptCrvReq | 3 | 1 | uint16 | none | none | RW | none | Request to adopt a stored curve. | yes |
| AdptCrvRslt | 4 | 1 | enum16 | none | none | R | IN_PROGRESS=0, COMPLETED=1, FAILED=2 | Result of the adopt-curve request. | no |
| NPt | 5 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| NCrvSet | 6 | 1 | uint16 | none | none | R | none | Number of stored curve sets. | no |
| V_SF | 7 | 1 | sunssf | none | none | R | none | Scale factor V_SF. | no |
| Tms_SF | 8 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ReadOnly | 9+(i-1)*(4+9*P) | 1 | enum16 | none | none | R | RW=0, R=1 | Stored access mark of this curve. | no |
| MustTrip.ActPt | 9+(i-1)*(4+9*P)+1 | 1 | uint16 | none | none | RW | none | Observed active-point count on the must-trip curve. It does not select the layout. | yes |
| MustTrip.V | 9+(i-1)*(4+9*P)+2+(j-1)*3 | 1 | uint16 | V_SF | VNomPct | RW | none | Voltage sample on the must-trip curve. | yes |
| MustTrip.Tms | 9+(i-1)*(4+9*P)+3+(j-1)*3 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the must-trip curve. | yes |
| MayTrip.ActPt | 9+(i-1)*(4+9*P)+2+3*P | 1 | uint16 | none | none | RW | none | Observed active-point count on the may-trip curve. It does not select the layout. | yes |
| MayTrip.V | 9+(i-1)*(4+9*P)+3+3*P+(j-1)*3 | 1 | uint16 | V_SF | VNomPct | RW | none | Voltage sample on the may-trip curve. | yes |
| MayTrip.Tms | 9+(i-1)*(4+9*P)+4+3*P+(j-1)*3 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the may-trip curve. | yes |
| MomCess.ActPt | 9+(i-1)*(4+9*P)+3+6*P | 1 | uint16 | none | none | RW | none | Observed active-point count on the momentary-cessation curve. It does not select the layout. | yes |
| MomCess.V | 9+(i-1)*(4+9*P)+4+6*P+(j-1)*3 | 1 | uint16 | V_SF | VNomPct | RW | none | Voltage sample on the momentary-cessation curve. | yes |
| MomCess.Tms | 9+(i-1)*(4+9*P)+5+6*P+(j-1)*3 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the momentary-cessation curve. | yes |

## Model 709

Model 709, DER Trip LF (`DERTripLF`). Declared length is L = 7 + C*(4 + 12*P), where C is `NCrvSet` and P is `NPt`. Each nested point is this model's own span, Hz as one uint32 and Tms as one uint32, four registers. This section does not take field identifiers, units, enumerations, access, or sentinels from model 707. Multi-register word order is not stated by these point rows, so it stays unknown.

Source model id 709 in the public SunSpec model catalog. Curve i, counting from 1, starts at model word 9+(i-1)*(4+12*P). Point j inside a nested curve counts from 1. Offsets below are model words.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | R | 709 | Model identifier. | no |
| L | 1 | 1 | uint16 | none | none | R | none | Declared length in registers after this word. | no |
| Ena | 2 | 1 | enum16 | none | none | RW | DISABLED=0, ENABLED=1 | Enable word of this occurrence. | yes |
| AdptCrvReq | 3 | 1 | uint16 | none | none | RW | none | Request to adopt a stored curve. | yes |
| AdptCrvRslt | 4 | 1 | enum16 | none | none | R | IN_PROGRESS=0, COMPLETED=1, FAILED=2 | Result of the adopt-curve request. | no |
| NPt | 5 | 1 | uint16 | none | none | R | none | Number of curve points. | no |
| NCrvSet | 6 | 1 | uint16 | none | none | R | none | Number of stored curve sets. | no |
| Hz_SF | 7 | 1 | sunssf | none | none | R | none | Scale factor Hz_SF. | no |
| Tms_SF | 8 | 1 | sunssf | none | none | R | none | Scale factor Tms_SF. | no |

### Repeating block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ReadOnly | 9+(i-1)*(4+12*P) | 1 | enum16 | none | none | R | RW=0, R=1 | Stored access mark of this curve. | no |
| MustTrip.ActPt | 9+(i-1)*(4+12*P)+1 | 1 | uint16 | none | none | RW | none | Observed active-point count on the must-trip curve. It does not select the layout. | yes |
| MustTrip.Hz | 9+(i-1)*(4+12*P)+2+(j-1)*4 | 2 | uint32 | Hz_SF | Hz | RW | none | Frequency sample on the must-trip curve. | yes |
| MustTrip.Tms | 9+(i-1)*(4+12*P)+4+(j-1)*4 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the must-trip curve. | yes |
| MayTrip.ActPt | 9+(i-1)*(4+12*P)+2+4*P | 1 | uint16 | none | none | RW | none | Observed active-point count on the may-trip curve. It does not select the layout. | yes |
| MayTrip.Hz | 9+(i-1)*(4+12*P)+3+4*P+(j-1)*4 | 2 | uint32 | Hz_SF | Hz | RW | none | Frequency sample on the may-trip curve. | yes |
| MayTrip.Tms | 9+(i-1)*(4+12*P)+5+4*P+(j-1)*4 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the may-trip curve. | yes |
| MomCess.ActPt | 9+(i-1)*(4+12*P)+3+8*P | 1 | uint16 | none | none | RW | none | Observed active-point count on the momentary-cessation curve. It does not select the layout. | yes |
| MomCess.Hz | 9+(i-1)*(4+12*P)+4+8*P+(j-1)*4 | 2 | uint32 | Hz_SF | Hz | RW | none | Frequency sample on the momentary-cessation curve. | yes |
| MomCess.Tms | 9+(i-1)*(4+12*P)+6+8*P+(j-1)*4 | 2 | uint32 | Tms_SF | Secs | RW | none | Time sample on the momentary-cessation curve. | yes |
