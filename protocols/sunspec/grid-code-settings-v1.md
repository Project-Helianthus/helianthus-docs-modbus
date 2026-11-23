# SunSpec grid-code settings

These settings have no SemReg element; they are documented registers decoded and callable by hand through MCP and GraphQL in the modbusreg namespace, as an advanced facility.

Models 703 and 707, 708, and 709 are documented, readable, and decoded and callable by hand through MCP and GraphQL in the modbusreg namespace.
The point tables cite the public SunSpec model catalog by model id. Where that catalog defines none, the section adds no points.

## Model 125

Model 125 is named here. The catalog defines none, and this section adds no points.

## Model 126

Model 126 is named here. The catalog defines none, and this section adds no points.

## Model 127

Model 127 is named here. The catalog defines none, and this section adds no points.

## Model 128

Model 128 is named here. The catalog defines none, and this section adds no points.

## Model 129

Model 129 is named here. The catalog defines none, and this section adds no points.

## Model 130

Model 130 is named here. The catalog defines none, and this section adds no points.

## Model 131

Model 131 is named here. The catalog defines none, and this section adds no points.

## Model 132

Model 132 is named here. The catalog defines none, and this section adds no points.

## Model 133

Model 133 is named here. The catalog defines none, and this section adds no points.

## Model 134

Model 134 is named here. The catalog defines none, and this section adds no points.

## Model 135

Model 135 is named here. The catalog defines none, and this section adds no points.

## Model 136

Model 136 is named here. The catalog defines none, and this section adds no points.

## Model 137

Model 137 is named here. The catalog defines none, and this section adds no points.

## Model 138

Model 138 is named here. The catalog defines none, and this section adds no points.

## Model 139

Model 139 is named here. The catalog defines none, and this section adds no points.

## Model 140

Model 140 is named here. The catalog defines none, and this section adds no points.

## Model 141

Model 141 is named here. The catalog defines none, and this section adds no points.

## Model 142

Model 142 is named here. The catalog defines none, and this section adds no points.

## Model 143

Model 143 is named here. The catalog defines none, and this section adds no points.

## Model 144

Model 144 is named here. The catalog defines none, and this section adds no points.

## Model 145

Model 145 is named here. The catalog defines none, and this section adds no points.

## Model 703

Model 703 is the enter-service model. The public contract records declared length 17. The reachable catalog defines no point rows for model 703, so each point stays unknown. The model is documented, readable, and decoded and callable by hand through MCP and GraphQL in the modbusreg namespace.

## Model 707

Model 707 uses the geometry of the low-voltage trip template. Declared length is L = 7 + C*(4 + 9*P). Access is not stated by that template, so the callable-by-hand cell stays unknown.

### Fixed block

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ID | 0 | 1 | uint16 | none | none | unknown | 707 | Header identifier of a valid occurrence. | unknown |
| L | 1 | 1 | uint16 | none | none | unknown | equals 7+C*(4+9*P) | Declared payload length. | unknown |
| Ena | 2 | 1 | enum16 | none | none | unknown | 0 disabled, 1 enabled | Enable word of this occurrence. | unknown |
| AdptCrvReq | 3 | 1 | uint16 | none | none | unknown | unknown | Curve request word. Meaning stays as the template leaves it. | unknown |
| AdptCrvRslt | 4 | 1 | enum16 | none | none | unknown | 0 in progress, 1 completed, 2 failed | Curve result word. | unknown |
| NPt | 5 | 1 | uint16 | none | none | unknown | 0 through 65534 | Point count P. | unknown |
| NCrvSet | 6 | 1 | uint16 | none | none | unknown | 0 through 65534 | Curve-set count C. | unknown |
| V_SF | 7 | 1 | sunssf | none | none | unknown | unknown | Scale for nested V. | unknown |
| Tms_SF | 8 | 1 | sunssf | none | none | unknown | unknown | Scale for nested Tms. | unknown |

### Repeating block

Offset of curve i, with i from 1, is 2 + 7 + (i-1)*(4+9*P) as a model word when payload 0 is model word 2. Each nested point is V as one uint16 then Tms as one uint32.

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Crv ReadOnly | payload B, model word B+2 | 1 | enum16 | none | none | unknown | 0 RW, 1 R | Stored access symbol of the curve. | unknown |
| MustTrip ActPt | payload B+1 | 1 | uint16 | none | none | unknown | unknown | Observed count. It does not select the layout. | unknown |
| MustTrip Pt V | one word after ActPt, step 3 | 1 | uint16 | V_SF | percent of nominal | unknown | unknown | Nested voltage sample. | unknown |
| MustTrip Pt Tms | the two words after V | 2 | uint32 | Tms_SF | seconds | unknown | big-endian on this model | Nested time sample. | unknown |
| MayTrip ActPt | payload B+2+3*P | 1 | uint16 | none | none | unknown | unknown | Observed count. It does not select the layout. | unknown |
| MayTrip Pt V | one word after its ActPt, step 3 | 1 | uint16 | V_SF | percent of nominal | unknown | unknown | Nested voltage sample. | unknown |
| MayTrip Pt Tms | the two words after that V | 2 | uint32 | Tms_SF | seconds | unknown | big-endian on this model | Nested time sample. | unknown |
| MomCess ActPt | payload B+3+6*P | 1 | uint16 | none | none | unknown | unknown | Observed count. It does not select the layout. | unknown |
| MomCess Pt V | one word after its ActPt, step 3 | 1 | uint16 | V_SF | percent of nominal | unknown | unknown | Nested voltage sample. | unknown |
| MomCess Pt Tms | the two words after that V | 2 | uint32 | Tms_SF | seconds | unknown | big-endian on this model | Nested time sample. | unknown |

## Model 708

Model 708 uses only its own point span: V as uint16 and Tms as uint32, three registers, and L = 7 + C*(4 + 9*P). It does not inherit model 707 field identifiers, units, byte order, enumerations, access, or sentinels. An unsupported fact is unknown or raw.

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V | point span, first register | 1 | uint16 | unknown | unknown | unknown | unknown | Voltage sample of this model. | unknown |
| Tms | the next two registers of the same point | 2 | uint32 | unknown | unknown | unknown | unknown | Time sample of this model. | unknown |

## Model 709

Model 709 uses only its own point span: Hz as uint32 and Tms as uint32, four registers, and L = 7 + C*(4 + 12*P). It does not inherit model 707 field identifiers, units, byte order, enumerations, access, or sentinels. An unsupported fact is unknown or raw.

| point | offset (model word) | size (registers) | type | scale factor point | unit | access (R, RW or W as the catalog states) | value range or enumeration symbols | meaning (own words) | callable by hand (yes for RW and W) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Hz | point span, first two registers | 2 | uint32 | unknown | unknown | unknown | unknown | Frequency sample of this model. | unknown |
| Tms | the next two registers of the same point | 2 | uint32 | unknown | unknown | unknown | unknown | Time sample of this model. | unknown |
