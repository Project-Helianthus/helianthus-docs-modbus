# Huawei grid-code settings

These settings have no SemReg element; they are documented registers decoded and callable by hand through MCP and GraphQL in the modbusreg namespace, as an advanced facility.

Each card below is one catalog file. A missing dictionary, curve layout, unnamed point, merged enumeration, or name and unit disagreement stays named and is not filled in.

A writable row is unsupported unless that card names its source edition and a verified
device-model and firmware-floor applicability. A catalog file name does not establish
the edition, the device models, or the firmware floor. Where device-model applicability
is unverified or unknown, or the card defines no grid-code row, writable support is
unsupported.

## L-LEGACY

Catalog file `registers-l-legacy.json`.

Source edition: SUN2000L V100R001 MODBUS Interface Definitions, Issue 05, 2018-04-03.
Family: SUN2000L. Firmware floor: V100R001C00. The edition lists its device models on
pages 7 and 8. Other editions of this title are outside this card. This card defines no
grid-code row.
Writable support: unsupported.

This card defines no grid-code row.

### Open points

- `l-legacy.control.dispatch.40122` is named and not filled.
- `l-legacy.control.dispatch.40123` is named and not filled.
- `l-legacy.control.dispatch.40125` is named and not filled.
- `l-legacy.control.dispatch.40126` is named and not filled.
- `l-legacy.control.dispatch.40200` is named and not filled.
- `l-legacy.control.dispatch.40201` is named and not filled.

## L-V200

Catalog file `registers-l-v200.json`.

Source edition: SUN2000L V200R001C00 Modbus Interface Definitions, Issue 11, 2026-06-27.
Family: SUN2000L. Firmware floor: SUN2000L V200R001C00. The edition lists its device
models on page 6. Other editions of this title are outside this card. The access column
is the access the edition records and is not qualified writable support.
Writable support: verified only for device models of the SUN2000L family at that firmware floor.

### Grid-protection block

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| l-v200.control.grid_protection.42000 | 42000 | 1 | U16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| l-v200.control.grid_protection.42015 | 42015 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| l-v200.control.grid_protection.42017 | 42017 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| l-v200.control.grid_protection.42019 | 42019 | 2 | U32 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| l-v200.control.grid_protection.42405 | 42405 | 2 | I32 | gain 1000 | kW | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |

### Open points

- Unnamed address-only grid-protection points stay unnamed.
- The 21-register curve inner layout is missing.
- The grid-code dictionary for this card is missing.
- `l-v200.control.dispatch.40037` is named and not filled.
- `l-v200.control.dispatch.40038` is named and not filled.
- `l-v200.control.dispatch.40120` is named and not filled.
- `l-v200.control.dispatch.40122` is named and not filled.
- `l-v200.control.dispatch.40123` is named and not filled.
- `l-v200.control.dispatch.40125` is named and not filled.
- `l-v200.control.dispatch.40126` is named and not filled.
- `l-v200.control.dispatch.40129` is named and not filled.
- `l-v200.control.dispatch.40133` is named and not filled.
- `l-v200.control.dispatch.40154` is named and not filled.
- `l-v200.control.dispatch.40175` is named and not filled.
- `l-v200.control.dispatch.40196` is named and not filled.
- `l-v200.control.dispatch.40198` is named and not filled.
- `l-v200.control.dispatch.40200` is named and not filled.
- `l-v200.control.dispatch.40201` is named and not filled.
- `l-v200.control.plant_control.47605` is named and not filled.
- `l-v200.control.plant_control.47677` is named and not filled.

## LB-C00

Catalog file `registers-lb-c00.json`.

Source edition: SUN2000LB V300R024C00 Modbus Interface Definitions, Issue 06,
2026-06-27. Families: SUN2000LB and SUN5000. Firmware floor: V300R024C00. The edition
lists its device models on page 6. The access column is the access the edition records
and is not qualified writable support.
Writable support: verified only for device models of the SUN2000LB and SUN5000 families at that firmware floor.

### Grid-protection block

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lb-c00.control.grid_protection.42000 | 42000 | 1 | U16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lb-c00.control.grid_protection.42015 | 42015 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lb-c00.control.grid_protection.42017 | 42017 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lb-c00.control.grid_protection.42019 | 42019 | 2 | U32 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lb-c00.control.grid_protection.42405 | 42405 | 2 | I32 | gain 1000 | kW | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |

### Open points

- Unnamed address-only grid-protection points stay unnamed.
- The grid-code dictionary for this card is missing.
- `lb-c00.control.dispatch.40037` is named and not filled.
- `lb-c00.control.dispatch.40038` is named and not filled.
- `lb-c00.control.dispatch.40120` is named and not filled.
- `lb-c00.control.dispatch.40122` is named and not filled.
- `lb-c00.control.dispatch.40123` is named and not filled.
- `lb-c00.control.dispatch.40125` is named and not filled.
- `lb-c00.control.dispatch.40126` is named and not filled.
- `lb-c00.control.dispatch.40129` is named and not filled.
- `lb-c00.control.dispatch.40133` is named and not filled.
- `lb-c00.control.dispatch.40154` is named and not filled.
- `lb-c00.control.dispatch.40175` is named and not filled.
- `lb-c00.control.dispatch.40196` is named and not filled.
- `lb-c00.control.dispatch.40198` is named and not filled.
- `lb-c00.control.dispatch.40200` is named and not filled.
- `lb-c00.control.dispatch.40201` is named and not filled.
- `lb-c00.control.plant_control.47605` is named and not filled.
- `lb-c00.control.plant_control.47677` is named and not filled.

## LB-C10

Catalog file `registers-lb-c10.json`.

Source edition: SUN2000LB V300R024C10 Modbus Interface Definitions, Issue 08,
2026-06-23. Families: SUN2000LB and SUN5000. Firmware floor: V300R024C10SPC100. The
edition lists its device models on page 7. Other editions of this title are outside this
card. The access column is the access the edition records and is not qualified writable
support.
Writable support: verified only for device models of the SUN2000LB and SUN5000 families at that firmware floor.

### Grid-protection block

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lb-c10.control.grid_protection.42000 | 42000 | 1 | U16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lb-c10.control.grid_protection.42015 | 42015 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lb-c10.control.grid_protection.42017 | 42017 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lb-c10.control.grid_protection.42019 | 42019 | 2 | U32 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lb-c10.control.grid_protection.42405 | 42405 | 2 | I32 | gain 1000 | kW | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |

### Open points

- Unnamed address-only grid-protection points stay unnamed.
- The grid-code dictionary for this card is missing.
- `lb-c10.control.dispatch.40037` is named and not filled.
- `lb-c10.control.dispatch.40038` is named and not filled.
- `lb-c10.control.dispatch.40120` is named and not filled.
- `lb-c10.control.dispatch.40122` is named and not filled.
- `lb-c10.control.dispatch.40123` is named and not filled.
- `lb-c10.control.dispatch.40125` is named and not filled.
- `lb-c10.control.dispatch.40126` is named and not filled.
- `lb-c10.control.dispatch.40129` is named and not filled.
- `lb-c10.control.dispatch.40133` is named and not filled.
- `lb-c10.control.dispatch.40154` is named and not filled.
- `lb-c10.control.dispatch.40175` is named and not filled.
- `lb-c10.control.dispatch.40196` is named and not filled.
- `lb-c10.control.dispatch.40198` is named and not filled.
- `lb-c10.control.dispatch.40200` is named and not filled.
- `lb-c10.control.dispatch.40201` is named and not filled.
- `lb-c10.control.plant_control.47605` is named and not filled.
- `lb-c10.control.plant_control.47677` is named and not filled.

## LC

Catalog file `registers-lc.json`.

Source edition: SUN2000LC V100R023C10 Modbus Interface Definitions, Issue 12,
2026-06-29. Family: SUN2000LC. Firmware floor: V100R023C10. The edition lists its device
models on page 6. Other editions of this title are outside this card. The access column
is the access the edition records and is not qualified writable support.
Writable support: verified only for device models of the SUN2000LC family at that firmware floor.

### Grid-protection block

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lc.control.grid_protection.42000 | 42000 | 1 | U16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lc.control.grid_protection.42015 | 42015 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lc.control.grid_protection.42017 | 42017 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lc.control.grid_protection.42019 | 42019 | 2 | U32 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| lc.control.grid_protection.42405 | 42405 | 2 | I32 | gain 1000 | kW | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |

### Open points

- Unnamed address-only grid-protection points stay unnamed.
- The grid-code dictionary for this card is missing.
- `lc.control.dispatch.40037` is named and not filled.
- `lc.control.dispatch.40038` is named and not filled.
- `lc.control.dispatch.40120` is named and not filled.
- `lc.control.dispatch.40122` is named and not filled.
- `lc.control.dispatch.40123` is named and not filled.
- `lc.control.dispatch.40125` is named and not filled.
- `lc.control.dispatch.40126` is named and not filled.
- `lc.control.dispatch.40129` is named and not filled.
- `lc.control.dispatch.40133` is named and not filled.
- `lc.control.dispatch.40154` is named and not filled.
- `lc.control.dispatch.40175` is named and not filled.
- `lc.control.dispatch.40196` is named and not filled.
- `lc.control.dispatch.40198` is named and not filled.
- `lc.control.dispatch.40200` is named and not filled.
- `lc.control.dispatch.40201` is named and not filled.
- `lc.control.plant_control.47605` is named and not filled.
- `lc.control.plant_control.47677` is named and not filled.

## MA-C00

Catalog file `registers-ma-c00.json`.

Source edition: SUN2000MA V100R001C00SPC178 Modbus Interface Definitions, Issue 10,
2026-09-09. Families: SUN2000, SUN2000HA, SUN2000L, SUN2000MA, and SUN8000. Firmware
floors: SUN2000 V100R001; SUN2000 V200R001C02; SUN2000 V200R001C90; SUN2000 V200R002C00;
SUN2000 V200R002C20; SUN2000 V300R001C00; SUN2000 V500R001C00; SUN2000HA V100R001;
SUN2000HA V200R001C00; SUN2000HA V300R001C00; SUN2000L V100R001C00; SUN2000L
V100R001C10; SUN2000L V100R001C12; SUN2000L V100R001C20; SUN2000L V200R001C00; SUN2000MA
V100R001C00; SUN2000MA V100R001C10; SUN2000MA V100R001C20; SUN8000 V100R001. The edition
lists its device models on pages 6, 7, 8, 9, 10, 11, and 12. Recorded floor strings
SUN2000L V200R001C0 and SUN2000MA V100R001C10SUN2000MA are not usable labels and do not
establish writable support. The access column is the access the edition records and is
not qualified writable support.
Writable support: verified only for device models of the SUN2000, SUN2000HA, SUN2000L, SUN2000MA, and SUN8000 families at one of those firmware floors.

### Grid-protection block

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-c00.control.grid_protection.42000 | 42000 | 1 | U16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c00.control.grid_protection.42015 | 42015 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c00.control.grid_protection.42017 | 42017 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c00.control.grid_protection.42019 | 42019 | 2 | U32 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c00.control.grid_protection.42405 | 42405 | 2 | I32 | gain 1000 | kW | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |

### Open points

- Unnamed address-only grid-protection points stay unnamed.
- The grid-code dictionary for this card is missing.
- `ma-c00.control.dispatch.40037` is named and not filled.
- `ma-c00.control.dispatch.40038` is named and not filled.
- `ma-c00.control.dispatch.40120` is named and not filled.
- `ma-c00.control.dispatch.40122` is named and not filled.
- `ma-c00.control.dispatch.40123` is named and not filled.
- `ma-c00.control.dispatch.40125` is named and not filled.
- `ma-c00.control.dispatch.40126` is named and not filled.
- `ma-c00.control.dispatch.40129` is named and not filled.
- `ma-c00.control.dispatch.40133` is named and not filled.
- `ma-c00.control.dispatch.40154` is named and not filled.
- `ma-c00.control.dispatch.40175` is named and not filled.
- `ma-c00.control.dispatch.40196` is named and not filled.
- `ma-c00.control.dispatch.40198` is named and not filled.
- `ma-c00.control.dispatch.40200` is named and not filled.
- `ma-c00.control.dispatch.40201` is named and not filled.
- `ma-c00.control.plant_control.47605` is named and not filled.
- `ma-c00.control.plant_control.47677` is named and not filled.

## MA-C20

Catalog file `registers-ma-c20.json`.

Source edition: SUN2000MA V100R001C20 Modbus Interface Definitions, Issue 01,
2026-07-03. Family: SUN2000MA. Firmware floor: SUN2000MA V100R001C20. The edition lists
its device models on pages 6 and 7. Other editions of this title are outside this card.
The access column is the access the edition records and is not qualified writable
support.
Writable support: verified only for device models of the SUN2000MA family at that firmware floor.

### Grid-code identity

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| identity.version_component.powergridstandardcodeprotocolversion | 30109 | 1 | U16 | not stated | not stated | RO | unknown | grid-code-identity | Protocol version of the power-grid standard code. Read only. |

### Grid-protection block

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-c20.control.grid_protection.42000 | 42000 | 1 | U16 | gain 1 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42001 | 42001 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42002 | 42002 | 1 | U16 | gain 1 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42003 | 42003 | 1 | U16 | gain 1 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42012 | 42012 | 1 | U16 | gain 1 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42014 | 42014 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42015 | 42015 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42017 | 42017 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42019 | 42019 | 2 | U32 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42021 | 42021 | 2 | U32 | gain 1000 | kVA | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42023 | 42023 | 2 | U32 | gain 1000 | kW | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42025 | 42025 | 2 | U32 | gain 1000 | kVar | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42027 | 42027 | 2 | U32 | gain 1000 | kW | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42029 | 42029 | 1 | U16 | gain 1 | min/100% | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42030 | 42030 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42032 | 42032 | 1 | U16 | gain 10 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42033 | 42033 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42034 | 42034 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42040 | 42040 | 1 | U16 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42041 | 42041 | 1 | U16 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42042 | 42042 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42043 | 42043 | 1 | U16 | gain 1000 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42044 | 42044 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42045 | 42045 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42046 | 42046 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42047 | 42047 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42048 | 42048 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42049 | 42049 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42050 | 42050 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42051 | 42051 | 1 | U16 | gain 1 | %/min | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42052 | 42052 | 1 | U16 | gain 10 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42053 | 42053 | 1 | U16 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42054 | 42054 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42055 | 42055 | 1 | U16 | gain 1 | min | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42061 | 42061 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42062 | 42062 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42063 | 42063 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42064 | 42064 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42065 | 42065 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42066 | 42066 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42067 | 42067 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42068 | 42068 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42069 | 42069 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42070 | 42070 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42072 | 42072 | 1 | U16 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42073 | 42073 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42074 | 42074 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42075 | 42075 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42076 | 42076 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42077 | 42077 | 2 | U32 | gain 10 | kW | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42079 | 42079 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42080 | 42080 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42081 | 42081 | 1 | U16 | gain 10 | Hz/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42082 | 42082 | 1 | U16 | gain 10 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42083 | 42083 | 1 | I16 | gain 1000 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42084 | 42084 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42085 | 42085 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42086 | 42086 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42087 | 42087 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42088 | 42088 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42089 | 42089 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42090 | 42090 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42091 | 42091 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42092 | 42092 | 1 | U16 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42097 | 42097 | 1 | U16 | gain 1000 | MΩ | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42098 | 42098 | 1 | U16 | gain 10 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42099 | 42099 | 1 | U16 | gain 10 | ° | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42100 | 42100 | 1 | U16 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42101 | 42101 | 1 | U16 | gain 1 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42102 | 42102 | 1 | U16 | gain 1 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42103 | 42103 | 1 | U16 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42104 | 42104 | 1 | U16 | gain 1 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42105 | 42105 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42107 | 42107 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42109 | 42109 | 1 | U16 | gain 10 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42110 | 42110 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42111 | 42111 | 1 | U16 | gain 10 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42112 | 42112 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42113 | 42113 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42114 | 42114 | 1 | U16 | gain 10 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42115 | 42115 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42116 | 42116 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42118 | 42118 | 1 | U16 | gain 100 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42119 | 42119 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42120 | 42120 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42121 | 42121 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42122 | 42122 | 1 | U16 | gain 10 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42123 | 42123 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42124 | 42124 | 1 | U16 | gain 1 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42125 | 42125 | 1 | U16 | gain 1 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42126 | 42126 | 1 | U16 | gain 10 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42127 | 42127 | 1 | U16 | gain 10 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42128 | 42128 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42129 | 42129 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42130 | 42130 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42131 | 42131 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42132 | 42132 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42133 | 42133 | 1 | U16 | gain 1 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42134 | 42134 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42135 | 42135 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42136 | 42136 | 1 | U16 | gain 10 | mA | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42138 | 42138 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42139 | 42139 | 1 | U16 | gain 10 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42140 | 42140 | 1 | U16 | gain 10 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42141 | 42141 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42142 | 42142 | 1 | U16 | gain 1 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42143 | 42143 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42144 | 42144 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42145 | 42145 | 1 | U16 | gain 1 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42146 | 42146 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42147 | 42147 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42148 | 42148 | 1 | U16 | gain 1 | %/min | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42151 | 42151 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42152 | 42152 | 1 | U16 | gain 1 | %/min | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42155 | 42155 | 21 | MLD | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42176 | 42176 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42177 | 42177 | 1 | U16 | gain 1 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42178 | 42178 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42179 | 42179 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42180 | 42180 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42181 | 42181 | 1 | I16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42182 | 42182 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42183 | 42183 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42192 | 42192 | 2 | U32 | gain 1000 | %/s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42200 | 42200 | 21 | MLD | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42221 | 42221 | 21 | MLD | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42242 | 42242 | 1 | U16 | gain 100 | s | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42287 | 42287 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42288 | 42288 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42290 | 42290 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42291 | 42291 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42293 | 42293 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42294 | 42294 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42296 | 42296 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42297 | 42297 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42299 | 42299 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42302 | 42302 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42305 | 42305 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42306 | 42306 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42308 | 42308 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42309 | 42309 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42311 | 42311 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42312 | 42312 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42314 | 42314 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42315 | 42315 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42317 | 42317 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42318 | 42318 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42320 | 42320 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42321 | 42321 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42323 | 42323 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42324 | 42324 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42326 | 42326 | 1 | U16 | gain 10 | V | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42327 | 42327 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42329 | 42329 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42330 | 42330 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42332 | 42332 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42333 | 42333 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42335 | 42335 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42336 | 42336 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42338 | 42338 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42339 | 42339 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42341 | 42341 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42342 | 42342 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42344 | 42344 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42345 | 42345 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42347 | 42347 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42348 | 42348 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42350 | 42350 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42351 | 42351 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42353 | 42353 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42354 | 42354 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42356 | 42356 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42357 | 42357 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42359 | 42359 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42360 | 42360 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42362 | 42362 | 1 | U16 | gain 100 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42363 | 42363 | 2 | U32 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42400 | 42400 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42403 | 42403 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42404 | 42404 | 1 | U16 | gain 10 | Hz | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42407 | 42407 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42409 | 42409 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42429 | 42429 | 1 | U16 | gain 1 | ms | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42432 | 42432 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42590 | 42590 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42594 | 42594 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42595 | 42595 | 1 | U16 | gain 100 | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42596 | 42596 | 1 | U16 | gain 1 | % | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42597 | 42597 | 1 | I16 | gain 1 | min | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42598 | 42598 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42599 | 42599 | 1 | E16 | not stated | not stated | RW | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42730 | 42730 | 1 | E16 | not stated | not stated | WO | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |
| ma-c20.control.grid_protection.42779 | 42779 | 1 | E16 | not stated | not stated | WO | unknown | grid-protection-block | Grid-protection point. Name and role are not stated. |

### Open points

- Unnamed address-only grid-protection points stay unnamed.
- The 193-wide grid-protection class is not split.
- The grid-code dictionary for this card is missing.
- `ma-c20.control.dispatch.40037` is named and not filled.
- `ma-c20.control.dispatch.40038` is named and not filled.
- `ma-c20.control.dispatch.40120` is named and not filled.
- `ma-c20.control.dispatch.40122` is named and not filled.
- `ma-c20.control.dispatch.40123` is named and not filled.
- `ma-c20.control.dispatch.40124` is named and not filled.
- `ma-c20.control.dispatch.40125` is named and not filled.
- `ma-c20.control.dispatch.40126` is named and not filled.
- `ma-c20.control.dispatch.40128` is named and not filled.
- `ma-c20.control.dispatch.40129` is named and not filled.
- `ma-c20.control.dispatch.40133` is named and not filled.
- `ma-c20.control.dispatch.40154` is named and not filled.
- `ma-c20.control.dispatch.40175` is named and not filled.
- `ma-c20.control.dispatch.40196` is named and not filled.
- `ma-c20.control.dispatch.40198` is named and not filled.
- `ma-c20.control.dispatch.40199` is named and not filled.
- `ma-c20.control.dispatch.40200` is named and not filled.
- `ma-c20.control.dispatch.40201` is named and not filled.
- `ma-c20.control.dispatch.40202` is named and not filled.
- `ma-c20.control.dispatch.40205` is named and not filled.
- `ma-c20.control.dispatch.40206` is named and not filled.
- `ma-c20.control.dispatch.40300` is named and not filled.
- `ma-c20.control.dispatch.40354` is named and not filled.
- `ma-c20.control.dispatch.40375` is named and not filled.
- `ma-c20.control.dispatch.40376` is named and not filled.
- `ma-c20.control.plant_control.47426` is named and not filled.
- `ma-c20.control.plant_control.47438` is named and not filled.
- `ma-c20.control.plant_control.47677` is named and not filled.

## MA-V200

Catalog file `registers-ma-v200.json`.

Source edition: SUN2000MA V200R024C00SPC111 Modbus Interface Definitions, Issue 10,
2026-09-09. Families: SUN2000MA and SUN5000. Firmware floor: V200R024C00. The edition
lists its device models on page 6. The access column is the access the edition records
and is not qualified writable support.
Writable support: verified only for device models of the SUN2000MA and SUN5000 families at that firmware floor.

### Grid-code identity

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| metadata.grid_code_protocol_id.30109 | 30109 | 1 | U16 | not stated | not stated | RO | unknown | grid-code-identity | Grid-code protocol identifier. Read only. |

### Grid masks

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| capability.grid_mask_1.30219 | 30219 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 1. Bit meanings are not in this card. |
| capability.grid_mask_2.30220 | 30220 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 2. Bit meanings are not in this card. |
| capability.grid_mask_3.30221 | 30221 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 3. Bit meanings are not in this card. |
| capability.grid_mask_4.30222 | 30222 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 4. Bit meanings are not in this card. |
| capability.grid_mask_5.30223 | 30223 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 5. Bit meanings are not in this card. |
| capability.grid_mask_6.30224 | 30224 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 6. Bit meanings are not in this card. |
| capability.grid_mask_7.30225 | 30225 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 7. Bit meanings are not in this card. |
| capability.grid_mask_8.30226 | 30226 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 8. Bit meanings are not in this card. |
| capability.grid_mask_9.30227 | 30227 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 9. Bit meanings are not in this card. |
| capability.grid_mask_10.30228 | 30228 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 10. Bit meanings are not in this card. |
| capability.grid_mask_11.30229 | 30229 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 11. Bit meanings are not in this card. |
| capability.grid_mask_12.30230 | 30230 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 12. Bit meanings are not in this card. |
| capability.grid_mask_13.30231 | 30231 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 13. Bit meanings are not in this card. |
| capability.grid_mask_14.30232 | 30232 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 14. Bit meanings are not in this card. |
| capability.grid_mask_15.30233 | 30233 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 15. Bit meanings are not in this card. |
| capability.grid_mask_16.30234 | 30234 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 16. Bit meanings are not in this card. |
| capability.grid_mask_17.30235 | 30235 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 17. Bit meanings are not in this card. |
| capability.grid_mask_18.30236 | 30236 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 18. Bit meanings are not in this card. |
| capability.grid_mask_19.30237 | 30237 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 19. Bit meanings are not in this card. |
| capability.grid_mask_20.30238 | 30238 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 20. Bit meanings are not in this card. |
| capability.grid_mask_21.30239 | 30239 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 21. Bit meanings are not in this card. |
| capability.grid_mask_22.30240 | 30240 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 22. Bit meanings are not in this card. |
| capability.grid_mask_23.30241 | 30241 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 23. Bit meanings are not in this card. |
| capability.grid_mask_24.30242 | 30242 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 24. Bit meanings are not in this card. |
| capability.grid_mask_25.30243 | 30243 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 25. Bit meanings are not in this card. |
| capability.grid_mask_26.30244 | 30244 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 26. Bit meanings are not in this card. |
| capability.grid_mask_27.30245 | 30245 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 27. Bit meanings are not in this card. |
| capability.grid_mask_28.30246 | 30246 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 28. Bit meanings are not in this card. |
| capability.grid_mask_29.30247 | 30247 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 29. Bit meanings are not in this card. |
| capability.grid_mask_30.30248 | 30248 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 30. Bit meanings are not in this card. |
| capability.grid_mask_31.30249 | 30249 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 31. Bit meanings are not in this card. |
| capability.grid_mask_32.30250 | 30250 | 1 | E16 | not stated | not stated | RO | unknown | grid-masks | Grid-capability mask 32. Bit meanings are not in this card. |

### Grid profile

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.grid_code | 42000 | 1 | U16 | gain 1 | not stated | RW | unknown; edition catalogue is not in this file | grid-profile | Selects the grid code for this edition. |
| ma-v200.control.output_mode | 42001 | 1 | E16 | not stated | not stated | RW | unknown; only three-phase three-wire is described | grid-profile | Output mode. The card describes three-phase three-wire only. |
| ma-v200.control.nominal_voltage | 42002 | 1 | U16 | gain 1 | V | RW | unknown | grid-profile | Nominal voltage reference Vn. |
| ma-v200.control.nominal_frequency | 42003 | 1 | U16 | gain 1 | Hz | RW | unknown | grid-profile | Nominal frequency reference Fn. |
| ma-v200.control.isolation_mode | 42050 | 1 | E16 | not stated | not stated | RW | unknown | grid-profile | Isolation mode in the grid-profile block. |

### Reactive power and power factor

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.power_factor_target | 40122 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Target power factor. |
| ma-v200.control.reactive_ratio_target | 40123 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Reactive ratio, converted with Smax. |
| ma-v200.control.reactive_adjustment_time | 40124 | 1 | U16 | gain 1 | s | RW | unknown | reactive-power-and-power-factor | Adjustment time associated with a reactive curve. |
| ma-v200.control.night_reactive_ratio | 40128 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Night reactive ratio, converted with Smax. |
| ma-v200.control.night_reactive_power | 40129 | 2 | I32 | gain 1000 | kVar | RW | unknown | reactive-power-and-power-factor | Night reactive power. |
| ma-v200.control.curve_reactive_adjustment_time | 40196 | 1 | U16 | gain 1 | s | RW | unknown | reactive-power-and-power-factor | Adjustment time associated with a reactive curve. |

### Reactive and power-factor curve points

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.qu_mode | 40037 | 1 | E16 | not stated | not stated | RW | unknown | reactive-and-power-factor-curve-points | Q-U mode selection. Enumeration is not stated. |
| ma-v200.control.qu_trigger_power | 40038 | 1 | I16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Power level that triggers Q-U. |
| ma-v200.control.qu_exit_power | 40198 | 1 | I16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Power level that exits Q-U. |
| ma-v200.control.qu_minimum_power_factor | 40375 | 1 | U16 | gain 1000 | not stated | RW | 0..1 in an EN50549 context; zero is special; other bounds unknown | reactive-and-power-factor-curve-points | Lower power-factor bound on Q-U output. Depends on country code. |
| ma-v200.control.qu_activation_delay | 40376 | 1 | U16 | gain 1 | s | RW | unknown | reactive-and-power-factor-curve-points | Q-U activation delay. Depends on country code. |
| ma-v200.control.curve_aux_42032 | 42032 | 1 | U16 | gain 10 | s | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| ma-v200.control.curve_aux_42101 | 42101 | 1 | U16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| ma-v200.control.curve_aux_42102 | 42102 | 1 | U16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| ma-v200.control.pu_adjustment_time | 42242 | 1 | U16 | gain 100 | s | RW | unknown | reactive-and-power-factor-curve-points | P-U adjustment time. |

### Curve blocks

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.cosphi_pn_curve | 40133 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Cos-phi versus Pn curve block. Inner layout is not in this card. |
| ma-v200.control.qu_characteristic_curve | 40154 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Q-U characteristic curve block. Inner layout is not in this card. |
| ma-v200.control.pfu_characteristic_curve | 40175 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | PF-U characteristic curve block. Inner layout is not in this card. |
| ma-v200.control.qp_curve | 40354 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Q-P curve block. Inner layout is not in this card. |
| ma-v200.control.lvrt_curve | 42155 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | LVRT curve block. Inner point layout is not in this card. |
| ma-v200.control.pu_curve | 42221 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | P-U curve block. Inner layout is not in this card. |

### Frequency-power

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.distributed_active_percent | 40199 | 1 | I16 | gain 10 | % | RW | unknown | frequency-power | Active-power percent cap during an underfrequency increase. |
| ma-v200.control.frequency_power_42040 | 42040 | 1 | U16 | gain 1 | s | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| ma-v200.control.frequency_power_42041 | 42041 | 1 | U16 | gain 1 | ms | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| ma-v200.control.frequency_power_42042 | 42042 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| ma-v200.control.frequency_power_42043 | 42043 | 1 | U16 | gain 1000 | Hz | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| ma-v200.control.frequency_power_42051 | 42051 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| ma-v200.control.frequency_power_42052 | 42052 | 1 | U16 | gain 10 | % | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| ma-v200.control.frequency_power_42053 | 42053 | 1 | U16 | gain 1 | ms | RW | unknown | frequency-power | Frequency-response initial delay in a Polish profile. |
| ma-v200.control.frequency_power_42141 | 42141 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Frequency-power point described in a G99 context. |
| ma-v200.control.frequency_power_42142 | 42142 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Frequency-power point described in a G99 context. |
| ma-v200.control.frequency_power_42143 | 42143 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42144 | 42144 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42145 | 42145 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42146 | 42146 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42147 | 42147 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42148 | 42148 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42151 | 42151 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42152 | 42152 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42176 | 42176 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42177 | 42177 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42178 | 42178 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| ma-v200.control.frequency_power_42179 | 42179 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |

### Frequency slope

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.frequency_slope_42080 | 42080 | 1 | E16 | not stated | not stated | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |
| ma-v200.control.frequency_slope_42081 | 42081 | 1 | U16 | gain 10 | Hz/s | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |
| ma-v200.control.frequency_slope_42082 | 42082 | 1 | U16 | gain 10 | s | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |

### Voltage and frequency protection levels

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.ten_minute_overvoltage_threshold | 42290 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Ten-minute overvoltage threshold. |
| ma-v200.control.ten_minute_overvoltage_duration | 42291 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Ten-minute overvoltage duration. |
| ma-v200.control.overvoltage_level_1_threshold | 42293 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 overvoltage threshold. |
| ma-v200.control.overvoltage_level_1_duration | 42294 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 overvoltage duration. |
| ma-v200.control.overvoltage_level_2_threshold | 42296 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 overvoltage threshold. |
| ma-v200.control.overvoltage_level_2_duration | 42297 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 overvoltage duration. |
| ma-v200.control.overvoltage_level_3_threshold | 42299 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 overvoltage threshold. |
| ma-v200.control.overvoltage_level_3_duration | 42300 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 overvoltage duration. |
| ma-v200.control.overvoltage_level_4_threshold | 42302 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 overvoltage threshold. |
| ma-v200.control.overvoltage_level_4_duration | 42303 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 overvoltage duration. |
| ma-v200.control.overvoltage_level_5_threshold | 42305 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 overvoltage threshold. |
| ma-v200.control.overvoltage_level_5_duration | 42306 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 overvoltage duration. |
| ma-v200.control.overvoltage_level_6_threshold | 42308 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 overvoltage threshold. |
| ma-v200.control.overvoltage_level_6_duration | 42309 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 overvoltage duration. |
| ma-v200.control.undervoltage_level_1_threshold | 42311 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 undervoltage threshold. |
| ma-v200.control.undervoltage_level_1_duration | 42312 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 undervoltage duration. |
| ma-v200.control.undervoltage_level_2_threshold | 42314 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 undervoltage threshold. |
| ma-v200.control.undervoltage_level_2_duration | 42315 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 undervoltage duration. |
| ma-v200.control.undervoltage_level_3_threshold | 42317 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 undervoltage threshold. |
| ma-v200.control.undervoltage_level_3_duration | 42318 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 undervoltage duration. |
| ma-v200.control.undervoltage_level_4_threshold | 42320 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 undervoltage threshold. |
| ma-v200.control.undervoltage_level_4_duration | 42321 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 undervoltage duration. |
| ma-v200.control.undervoltage_level_5_threshold | 42323 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 undervoltage threshold. |
| ma-v200.control.undervoltage_level_5_duration | 42324 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 undervoltage duration. |
| ma-v200.control.undervoltage_level_6_threshold | 42326 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 undervoltage threshold. |
| ma-v200.control.undervoltage_level_6_duration | 42327 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 undervoltage duration. |
| ma-v200.control.overfrequency_level_1_threshold | 42329 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 overfrequency threshold. |
| ma-v200.control.overfrequency_level_1_duration | 42330 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 overfrequency duration. |
| ma-v200.control.overfrequency_level_2_threshold | 42332 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 overfrequency threshold. |
| ma-v200.control.overfrequency_level_2_duration | 42333 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 overfrequency duration. |
| ma-v200.control.overfrequency_level_3_threshold | 42335 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 overfrequency threshold. |
| ma-v200.control.overfrequency_level_3_duration | 42336 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 overfrequency duration. |
| ma-v200.control.overfrequency_level_4_threshold | 42338 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 overfrequency threshold. |
| ma-v200.control.overfrequency_level_4_duration | 42339 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 overfrequency duration. |
| ma-v200.control.overfrequency_level_5_threshold | 42341 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 overfrequency threshold. |
| ma-v200.control.overfrequency_level_5_duration | 42342 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 overfrequency duration. |
| ma-v200.control.overfrequency_level_6_threshold | 42344 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 overfrequency threshold. |
| ma-v200.control.overfrequency_level_6_duration | 42345 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 overfrequency duration. |
| ma-v200.control.underfrequency_level_1_threshold | 42347 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 underfrequency threshold. |
| ma-v200.control.underfrequency_level_1_duration | 42348 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 underfrequency duration. |
| ma-v200.control.underfrequency_level_2_threshold | 42350 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 underfrequency threshold. |
| ma-v200.control.underfrequency_level_2_duration | 42351 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 underfrequency duration. |
| ma-v200.control.underfrequency_level_3_threshold | 42353 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 underfrequency threshold. |
| ma-v200.control.underfrequency_level_3_duration | 42354 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 underfrequency duration. |
| ma-v200.control.underfrequency_level_4_threshold | 42356 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 underfrequency threshold. |
| ma-v200.control.underfrequency_level_4_duration | 42357 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 underfrequency duration. |
| ma-v200.control.underfrequency_level_5_threshold | 42359 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 underfrequency threshold. |
| ma-v200.control.underfrequency_level_5_duration | 42360 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 underfrequency duration. |
| ma-v200.control.underfrequency_level_6_threshold | 42362 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 underfrequency threshold. |
| ma-v200.control.underfrequency_level_6_duration | 42363 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 underfrequency duration. |

### Ride-through

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.ramps_42100 | 42100 | 1 | U16 | gain 1 | s | RW | unknown | ride-through | Active-power gradient while recovering after a grid fault. |
| ma-v200.control.ride_through_42110 | 42110 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.grid_jump_threshold | 42111 | 1 | U16 | gain 10 | % | RW | unknown | ride-through | Grid-jump threshold limited to a VDE4120 context. |
| ma-v200.control.ride_through_42112 | 42112 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.ride_through_42113 | 42113 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.ride_through_42114 | 42114 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.ride_through_42118 | 42118 | 1 | U16 | gain 100 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.ride_through_42119 | 42119 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through point. The documentary default differs by profile. |
| ma-v200.control.ride_through_42120 | 42120 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | LVRT entry threshold. A grid-profile predicate is required. |
| ma-v200.control.ride_through_42121 | 42121 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Masks voltage protection during LVRT or HVRT. |
| ma-v200.control.ride_through_42122 | 42122 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Sequence reactive current during LVRT. |
| ma-v200.control.vrt_exit_hysteresis | 42123 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | Ride-through exit hysteresis against the entry thresholds. |
| ma-v200.control.ride_through_42124 | 42124 | 1 | U16 | gain 1 | % | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.ride_through_42125 | 42125 | 1 | U16 | gain 1 | %/s | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.ride_through_42126 | 42126 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.ride_through_42127 | 42127 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Sequence reactive current during LVRT. |
| ma-v200.control.ride_through_42128 | 42128 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| ma-v200.control.ride_through_42133 | 42133 | 1 | U16 | gain 1 | % | RW | unknown | ride-through | LVRT reactive-current limit against rated current. |
| ma-v200.control.lvrt_zero_current_threshold_conflict | 42134 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | Below the LVRT zero-current threshold, zero current; otherwise the configured LVRT mode. |
| ma-v200.control.ride_through_42135 | 42135 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |

### Voltage rise

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.voltage_rise_42138 | 42138 | 1 | E16 | not stated | not stated | RW | unknown | voltage-rise | Voltage-rise setting. Specific role is not stated. |
| ma-v200.control.voltage_rise_reactive_point | 42139 | 1 | U16 | gain 10 | % | RW | unknown | voltage-rise | Voltage-rise reactive point. It must sit below the active point. |
| ma-v200.control.voltage_rise_active_point | 42140 | 1 | U16 | gain 10 | % | RW | unknown | voltage-rise | Voltage-rise active point. It must sit above the reactive point. |

### Islanding

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.islanding_42129 | 42129 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |
| ma-v200.control.islanding_42130 | 42130 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |
| ma-v200.control.islanding_42131 | 42131 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |

### Normal reconnection

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.normal_connection_42084 | 42084 | 1 | U16 | gain 10 | V | RW | unknown | normal-reconnection | Normal reconnection voltage. High versus low is not stated. |
| ma-v200.control.normal_connection_42085 | 42085 | 1 | U16 | gain 10 | V | RW | unknown | normal-reconnection | Normal reconnection voltage. High versus low is not stated. |
| ma-v200.control.normal_connection_42086 | 42086 | 1 | U16 | gain 100 | Hz | RW | unknown | normal-reconnection | Normal reconnection frequency. High versus low is not stated. |
| ma-v200.control.normal_connection_42087 | 42087 | 1 | U16 | gain 100 | Hz | RW | unknown | normal-reconnection | Normal reconnection frequency. High versus low is not stated. |

### Post-fault reconnection and rapid restart

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ma-v200.control.startup_recovery_42088 | 42088 | 1 | U16 | gain 10 | V | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection voltage. High versus low is not stated. |
| ma-v200.control.startup_recovery_42089 | 42089 | 1 | U16 | gain 10 | V | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection voltage. High versus low is not stated. |
| ma-v200.control.startup_recovery_42090 | 42090 | 1 | U16 | gain 100 | Hz | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection frequency. High versus low is not stated. |
| ma-v200.control.startup_recovery_42091 | 42091 | 1 | U16 | gain 100 | Hz | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection frequency. High versus low is not stated. |
| ma-v200.control.startup_recovery_42105 | 42105 | 2 | U32 | gain 1 | ms | RW | unknown | post-fault-reconnection-and-rapid-restart | Time used only while rapid restart after a grid fault is enabled. |
| ma-v200.control.rapid_restart_mode | 42116 | 1 | E16 | not stated | not stated | RW | 0 ordinary restart; 1 rapid restart | post-fault-reconnection-and-rapid-restart | Selects ordinary restart or rapid restart after a short grid break. |

### Open points

- Bit identities for grid_mask_1 through grid_mask_32 are missing.
- The inner layout of each 21-register curve block is missing.
- The grid-code dictionary for this card is missing.
- `ma-v200.control.fixed_active_limit_low_resolution` is named and not filled.
- `ma-v200.control.active_percent_limit` is named and not filled.
- `ma-v200.control.fixed_active_limit_watts` is named and not filled.
- `ma-v200.control.active_power.field_45235` is named and not filled.
- `ma-v200.control.active_power.field_45236` is named and not filled.
- `ma-v200.control.active_power.field_45237` is named and not filled.
- `ma-v200.control.active_power.field_45238` is named and not filled.
- `ma-v200.control.microgrid.field_42044` is named and not filled.
- `ma-v200.control.microgrid.field_42045` is named and not filled.
- `ma-v200.control.plant_dispatch.field_47604` is named and not filled.
- `ma-v200.control.plant_dispatch.field_47605` is named and not filled.
- `ma-v200.control.apparent_power_limit` is named and not filled.
- `ma-v200.control.active_power_limit` is named and not filled.
- `ma-v200.control.apparent_reference_disputed_unit` is named and not filled.
- `ma-v200.control.active_power_reference` is named and not filled.
- `ma-v200.control.quality_42065` is named and not filled.
- `ma-v200.control.reactive_ramp` is named and not filled.
- `ma-v200.control.active_ramp` is named and not filled.
- `ma-v200.control.ramps_42029` is named and not filled.
- `ma-v200.control.ramps_42030` is named and not filled.
- `ma-v200.control.ramps.field_42037` is named and not filled.
- `ma-v200.control.ramps_42103` is named and not filled.
- `ma-v200.control.ramps_42107` is named and not filled.
- `ma-v200.control.ramps_42109` is named and not filled.
- `ma-v200.control.remote_scheduling` is named and not filled.
- `ma-v200.control.instruction_lifetime` is named and not filled.
- `ma-v200.control.japan_broadcast_active_ramp` is named and not filled.
- `ma-v200.control.startup_recovery_42061` is named and not filled.
- `ma-v200.control.startup_recovery_42062` is named and not filled.
- `ma-v200.control.startup_recovery_42092` is named and not filled.
- `ma-v200.control.startup_recovery_42104` is named and not filled.

## MB02

Catalog file `registers-mb02.json`.

Source edition: SUN2000MB V200R023C10 Modbus Interface Definitions, Issue 02,
2024-02-01. Families: SUN2000MB and SUN600. Firmware floors: V200R022C10;
V200R023C10PSC110. The edition lists its device models on pages 6 and 7. The access
column is the access the edition records and is not qualified writable support.
Writable support: verified only for device models of the SUN2000MB and SUN600 families at one of those firmware floors.

### Grid-code identity

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.grid_code_protocol_id | 30109 | 1 | U16 | not stated | not stated | RO | unknown | grid-code-identity | Grid-code protocol identifier. Read only. |

### Grid profile

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.grid_code | 42000 | 1 | U16 | gain 1 | not stated | RW | unknown; CHINA_MV800 is not a full catalogue | grid-profile | Selects the grid code. One isolated code text is not the list. |
| mb02.control.output_mode | 42001 | 1 | E16 | not stated | not stated | RW | unknown; only three-phase three-wire is described | grid-profile | Output mode. The card describes three-phase three-wire only. |
| mb02.control.nominal_voltage | 42002 | 1 | U16 | gain 1 | V | RW | unknown | grid-profile | Nominal voltage reference Vn. |
| mb02.control.nominal_frequency | 42003 | 1 | U16 | gain 1 | Hz | RW | unknown | grid-profile | Nominal frequency reference Fn. |
| mb02.control.isolation_mode | 42050 | 1 | E16 | not stated | not stated | RW | unknown | grid-profile | Isolation arrangement. Customer view is described as display-only. |

### Reactive power and power factor

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.power_factor_target | 40122 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Target power factor. |
| mb02.control.reactive_ratio_target | 40123 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Reactive ratio, converted with Smax. |
| mb02.control.reactive_adjustment_time | 40124 | 1 | U16 | gain 1 | s | RW | unknown | reactive-power-and-power-factor | Curve adjustment time, also for Q-P and cos-phi/P. |
| mb02.control.night_reactive_ratio | 40128 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Night reactive ratio, converted with Smax. |
| mb02.control.night_reactive_power | 40129 | 2 | I32 | gain 1000 | kVar | RW | unknown | reactive-power-and-power-factor | Night reactive power. |
| mb02.control.curve_reactive_adjustment_time | 40196 | 1 | U16 | gain 1 | s | RW | unknown | reactive-power-and-power-factor | Curve adjustment time, also for Q-P and cos-phi/P. |

### Reactive and power-factor curve points

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.qu_mode | 40037 | 1 | E16 | not stated | not stated | RW | unknown | reactive-and-power-factor-curve-points | Q-U mode selection. Enumeration is not stated. |
| mb02.control.qu_trigger_power | 40038 | 1 | I16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Power level that triggers Q-U. |
| mb02.control.qu_exit_power | 40198 | 1 | I16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Power level that exits Q-U. |
| mb02.control.qu_minimum_power_factor | 40375 | 1 | U16 | gain 1000 | not stated | RW | unknown; an EN50549 range is mentioned and not recorded | reactive-and-power-factor-curve-points | Power-factor bound on Q-U reactive output. |
| mb02.control.qu_activation_delay | 40376 | 1 | U16 | gain 1 | s | RW | unknown | reactive-and-power-factor-curve-points | Q-U trigger delay. Depends on the grid profile. |
| mb02.control.curve_aux_42032 | 42032 | 1 | U16 | gain 10 | s | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| mb02.control.curve_aux_42101 | 42101 | 1 | U16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| mb02.control.curve_aux_42102 | 42102 | 1 | U16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| mb02.control.pu_adjustment_time | 42242 | 1 | U16 | gain 100 | s | RW | unknown | reactive-and-power-factor-curve-points | P-U adjustment time. |

### Curve blocks

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.cosphi_pn_curve | 40133 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Cos-phi versus Pn curve block. Inner layout is not in this card. |
| mb02.control.qu_characteristic_curve | 40154 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Q-U characteristic curve block. Inner layout is not in this card. |
| mb02.control.pfu_characteristic_curve | 40175 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | PF-U characteristic curve block. Inner layout is not in this card. |
| mb02.control.qp_curve | 40354 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Q-P curve block. Inner layout is not in this card. |
| mb02.control.lvrt_curve | 42155 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | LVRT curve block. Inner point layout is not in this card. |
| mb02.control.qu_curve_alternate | 42200 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Alternate Q-U curve block. Inner layout is not in this card. |
| mb02.control.pu_curve | 42221 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | P-U curve block. Inner layout is not in this card. |

### Frequency-power

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.distributed_active_percent | 40199 | 1 | I16 | gain 10 | % | RW | unknown | frequency-power | Active-power percent cap during an underfrequency increase. |
| mb02.control.frequency_power_42040 | 42040 | 1 | U16 | gain 1 | s | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mb02.control.frequency_power_42041 | 42041 | 1 | U16 | gain 1 | ms | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mb02.control.frequency_power_42042 | 42042 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mb02.control.frequency_power_42043 | 42043 | 1 | U16 | gain 1000 | Hz | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mb02.control.frequency_power_42051 | 42051 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mb02.control.frequency_power_42052 | 42052 | 1 | U16 | gain 10 | % | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mb02.control.frequency_power_42053 | 42053 | 1 | U16 | gain 1 | ms | RW | unknown | frequency-power | Frequency-response initial delay in a Polish profile. |
| mb02.control.frequency_power_42141 | 42141 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Frequency-power point described in a G99 context. |
| mb02.control.frequency_power_42142 | 42142 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Droop for frequency-sensitive mode, in a G99 context. |
| mb02.control.frequency_power_42143 | 42143 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Overfrequency mode derates power past the trigger. Enable code unknown. |
| mb02.control.frequency_power_42144 | 42144 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Cutoff point for overfrequency. |
| mb02.control.frequency_power_42145 | 42145 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Cutoff power for overfrequency. |
| mb02.control.frequency_power_42146 | 42146 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Overfrequency trigger. It depends on the country or region profile. |
| mb02.control.frequency_power_42147 | 42147 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Exit point for overfrequency. |
| mb02.control.frequency_power_42148 | 42148 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | How fast power recovers after overfrequency derating. |
| mb02.control.frequency_power_42151 | 42151 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Underfrequency response below the trigger. Enable code unknown. |
| mb02.control.frequency_power_42152 | 42152 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | How fast power recovers after an underfrequency increase. |
| mb02.control.frequency_power_42176 | 42176 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Cutoff point for underfrequency. |
| mb02.control.frequency_power_42177 | 42177 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Cutoff power for underfrequency. |
| mb02.control.frequency_power_42178 | 42178 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Trigger point for underfrequency. |
| mb02.control.frequency_power_42179 | 42179 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Exit point for underfrequency. |

### Frequency slope

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.frequency_slope_42080 | 42080 | 1 | E16 | not stated | not stated | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |
| mb02.control.frequency_slope_42081 | 42081 | 1 | U16 | gain 10 | Hz/s | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |
| mb02.control.frequency_slope_42082 | 42082 | 1 | U16 | gain 10 | s | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |

### Voltage and frequency protection levels

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.ten_minute_undervoltage_threshold | 42287 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Ten-minute undervoltage threshold. |
| mb02.control.ten_minute_undervoltage_duration | 42288 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Ten-minute undervoltage duration. |
| mb02.control.ten_minute_overvoltage_threshold | 42290 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Ten-minute overvoltage threshold. |
| mb02.control.ten_minute_overvoltage_duration | 42291 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Ten-minute overvoltage duration. |
| mb02.control.overvoltage_level_1_threshold | 42293 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 overvoltage threshold. |
| mb02.control.overvoltage_level_1_duration | 42294 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 overvoltage duration. |
| mb02.control.overvoltage_level_2_threshold | 42296 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 overvoltage threshold. |
| mb02.control.overvoltage_level_2_duration | 42297 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 overvoltage duration. |
| mb02.control.overvoltage_level_3_threshold | 42299 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 overvoltage threshold. |
| mb02.control.overvoltage_level_3_duration | 42300 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 overvoltage duration. |
| mb02.control.overvoltage_level_4_threshold | 42302 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 overvoltage threshold. |
| mb02.control.overvoltage_level_4_duration | 42303 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 overvoltage duration. |
| mb02.control.overvoltage_level_5_threshold | 42305 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 overvoltage threshold. |
| mb02.control.overvoltage_level_5_duration | 42306 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 overvoltage duration. |
| mb02.control.overvoltage_level_6_threshold | 42308 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 overvoltage threshold. |
| mb02.control.overvoltage_level_6_duration | 42309 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 overvoltage duration. |
| mb02.control.undervoltage_level_1_threshold | 42311 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 undervoltage threshold. |
| mb02.control.undervoltage_level_1_duration | 42312 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 undervoltage duration. |
| mb02.control.undervoltage_level_2_threshold | 42314 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 undervoltage threshold. |
| mb02.control.undervoltage_level_2_duration | 42315 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 undervoltage duration. |
| mb02.control.undervoltage_level_3_threshold | 42317 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 undervoltage threshold. |
| mb02.control.undervoltage_level_3_duration | 42318 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 undervoltage duration. |
| mb02.control.undervoltage_level_4_threshold | 42320 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 undervoltage threshold. |
| mb02.control.undervoltage_level_4_duration | 42321 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 undervoltage duration. |
| mb02.control.undervoltage_level_5_threshold | 42323 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 undervoltage threshold. |
| mb02.control.undervoltage_level_5_duration | 42324 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 undervoltage duration. |
| mb02.control.undervoltage_level_6_threshold | 42326 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 undervoltage threshold. |
| mb02.control.undervoltage_level_6_duration | 42327 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 undervoltage duration. |
| mb02.control.overfrequency_level_1_threshold | 42329 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 overfrequency threshold. |
| mb02.control.overfrequency_level_1_duration | 42330 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 overfrequency duration. |
| mb02.control.overfrequency_level_2_threshold | 42332 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 overfrequency threshold. |
| mb02.control.overfrequency_level_2_duration | 42333 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 overfrequency duration. |
| mb02.control.overfrequency_level_3_threshold | 42335 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 overfrequency threshold. |
| mb02.control.overfrequency_level_3_duration | 42336 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 overfrequency duration. |
| mb02.control.overfrequency_level_4_threshold | 42338 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 overfrequency threshold. |
| mb02.control.overfrequency_level_4_duration | 42339 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 overfrequency duration. |
| mb02.control.overfrequency_level_5_threshold | 42341 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 overfrequency threshold. |
| mb02.control.overfrequency_level_5_duration | 42342 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 overfrequency duration. |
| mb02.control.overfrequency_level_6_threshold | 42344 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 overfrequency threshold. |
| mb02.control.overfrequency_level_6_duration | 42345 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 overfrequency duration. |
| mb02.control.underfrequency_level_1_threshold | 42347 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 underfrequency threshold. |
| mb02.control.underfrequency_level_1_duration | 42348 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 underfrequency duration. |
| mb02.control.underfrequency_level_2_threshold | 42350 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 underfrequency threshold. |
| mb02.control.underfrequency_level_2_duration | 42351 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 underfrequency duration. |
| mb02.control.underfrequency_level_3_threshold | 42353 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 underfrequency threshold. |
| mb02.control.underfrequency_level_3_duration | 42354 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 underfrequency duration. |
| mb02.control.underfrequency_level_4_threshold | 42356 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 underfrequency threshold. |
| mb02.control.underfrequency_level_4_duration | 42357 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 underfrequency duration. |
| mb02.control.underfrequency_level_5_threshold | 42359 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 underfrequency threshold. |
| mb02.control.underfrequency_level_5_duration | 42360 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 underfrequency duration. |
| mb02.control.underfrequency_level_6_threshold | 42362 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 underfrequency threshold. |
| mb02.control.underfrequency_level_6_duration | 42363 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 underfrequency duration. |

### Ride-through

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.ramps_42100 | 42100 | 1 | U16 | gain 1 | s | RW | unknown | ride-through | Power-rise timing or gradient after a grid fault. |
| mb02.control.ride_through_42110 | 42110 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.grid_jump_threshold | 42111 | 1 | U16 | gain 10 | % | RW | unknown | ride-through | Grid-jump threshold limited to a VDE4120 context. |
| mb02.control.ride_through_42112 | 42112 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.ride_through_42113 | 42113 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.ride_through_42114 | 42114 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.ride_through_42118 | 42118 | 1 | U16 | gain 100 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.ride_through_42119 | 42119 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through point. The documentary default differs by profile. |
| mb02.control.ride_through_42120 | 42120 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | LVRT trigger threshold, governed by the local grid standard. |
| mb02.control.ride_through_42121 | 42121 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Selects masking of voltage protection during ride-through. |
| mb02.control.ride_through_42122 | 42122 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Positive-sequence reactive compensation while LVRT is active. |
| mb02.control.vrt_exit_hysteresis | 42123 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | LVRT recovery adds hysteresis to the trigger. HVRT recovery subtracts it. |
| mb02.control.ride_through_42124 | 42124 | 1 | U16 | gain 1 | % | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.ride_through_42125 | 42125 | 1 | U16 | gain 1 | %/s | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.ride_through_42126 | 42126 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.ride_through_42127 | 42127 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Negative-sequence reactive compensation while LVRT is active. |
| mb02.control.ride_through_42128 | 42128 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mb02.control.ride_through_42133 | 42133 | 1 | U16 | gain 1 | % | RW | unknown | ride-through | Caps reactive current, as a percent, during LVRT. |
| mb02.control.lvrt_zero_current_threshold_conflict | 42134 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | Both branches name zero-current mode. The card calls that contradictory. |
| mb02.control.ride_through_42135 | 42135 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |

### Voltage rise

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.voltage_rise_42138 | 42138 | 1 | E16 | not stated | not stated | RW | unknown | voltage-rise | Voltage-rise setting. Specific role is not stated. |
| mb02.control.voltage_rise_reactive_point | 42139 | 1 | U16 | gain 10 | % | RW | unknown | voltage-rise | Voltage-rise reactive point. It must sit below the active point. |
| mb02.control.voltage_rise_active_point | 42140 | 1 | U16 | gain 10 | % | RW | unknown | voltage-rise | Voltage-rise active point. It must sit above the reactive point. |

### Islanding

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.islanding_42129 | 42129 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |
| mb02.control.islanding_42130 | 42130 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |
| mb02.control.islanding_42131 | 42131 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |

### Normal reconnection

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.normal_connection_42084 | 42084 | 1 | U16 | gain 10 | V | RW | unknown | normal-reconnection | Normal reconnection voltage. High versus low is not stated. |
| mb02.control.normal_connection_42085 | 42085 | 1 | U16 | gain 10 | V | RW | unknown | normal-reconnection | Normal reconnection voltage. High versus low is not stated. |
| mb02.control.normal_connection_42086 | 42086 | 1 | U16 | gain 100 | Hz | RW | unknown | normal-reconnection | Normal reconnection frequency. High versus low is not stated. |
| mb02.control.normal_connection_42087 | 42087 | 1 | U16 | gain 100 | Hz | RW | unknown | normal-reconnection | Normal reconnection frequency. High versus low is not stated. |

### Post-fault reconnection and rapid restart

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mb02.control.startup_recovery_42088 | 42088 | 1 | U16 | gain 10 | V | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection voltage. High versus low is not stated. |
| mb02.control.startup_recovery_42089 | 42089 | 1 | U16 | gain 10 | V | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection voltage. High versus low is not stated. |
| mb02.control.startup_recovery_42090 | 42090 | 1 | U16 | gain 100 | Hz | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection frequency. High versus low is not stated. |
| mb02.control.startup_recovery_42091 | 42091 | 1 | U16 | gain 100 | Hz | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection frequency. High versus low is not stated. |
| mb02.control.startup_recovery_42105 | 42105 | 2 | U32 | gain 1 | ms | RW | unknown | post-fault-reconnection-and-rapid-restart | Time used only while rapid restart after a grid fault is enabled. |
| mb02.control.rapid_restart_mode | 42116 | 1 | E16 | not stated | not stated | RW | 0 ordinary restart; 1 rapid restart | post-fault-reconnection-and-rapid-restart | Selects ordinary restart or rapid restart after a short grid break. |

### Open points

- The inner layout of each curve block cited from the key-information table is missing.
- Grid-mask rows are not copied from another card.
- `mb02.control.fixed_active_limit_low_resolution` is named and not filled.
- `mb02.control.active_percent_limit` is named and not filled.
- `mb02.control.fixed_active_limit_watts` is named and not filled.
- `mb02.control.apparent_power_limit` is named and not filled.
- `mb02.control.active_power_limit` is named and not filled.
- `mb02.control.apparent_reference_disputed_unit` is named and not filled.
- `mb02.control.active_power_reference` is named and not filled.
- `mb02.control.quality_42065` is named and not filled.
- `mb02.control.reactive_ramp` is named and not filled.
- `mb02.control.active_ramp` is named and not filled.
- `mb02.control.ramps_42029` is named and not filled.
- `mb02.control.ramps_42030` is named and not filled.
- `mb02.control.ramps_42103` is named and not filled.
- `mb02.control.ramps_42107` is named and not filled.
- `mb02.control.ramps_42109` is named and not filled.
- `mb02.control.remote_scheduling` is named and not filled.
- `mb02.control.instruction_lifetime` is named and not filled.
- `mb02.control.japan_broadcast_active_ramp` is named and not filled.
- `mb02.control.startup_recovery_42061` is named and not filled.
- `mb02.control.startup_recovery_42062` is named and not filled.
- `mb02.control.startup_recovery_42092` is named and not filled.
- `mb02.control.startup_recovery_42104` is named and not filled.

## MC

Catalog file `registers-mc.json`.

Source edition: SUN2000MC V200R023C00 Modbus Interface Definitions, Issue 01,
2023-03-17. Family: SUN2000MC. Firmware floor: SUN2000MC V200R023C00. The edition lists
its device models on page 5. The access column is the access the edition records and is
not qualified writable support.
Writable support: verified only for device models of the SUN2000MC family at that firmware floor.

### Grid-code identity

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| metadata.grid_code_protocol_id.30109 | 30109 | 1 | U16 | not stated | not stated | RO | unknown | grid-code-identity | Grid-code protocol identifier. Read only. |

### Grid profile

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.grid_code | 42000 | 1 | U16 | gain 1 | not stated | RW | unknown; edition catalogue is not in this file | grid-profile | Selects the grid code for this edition. |
| mc.control.output_mode | 42001 | 1 | E16 | not stated | not stated | RW | unknown; only three-phase three-wire is described | grid-profile | Output mode. The card describes three-phase three-wire only. |
| mc.control.nominal_voltage | 42002 | 1 | U16 | gain 1 | V | RW | unknown | grid-profile | Nominal voltage reference Vn. |
| mc.control.nominal_frequency | 42003 | 1 | U16 | gain 1 | Hz | RW | unknown | grid-profile | Nominal frequency reference Fn. |
| mc.control.isolation_mode | 42050 | 1 | E16 | not stated | not stated | RW | unknown | grid-profile | Isolation mode in the grid-profile block. |

### Reactive power and power factor

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.power_factor_target | 40122 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Target power factor. |
| mc.control.reactive_ratio_target | 40123 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Reactive ratio, converted with Smax. |
| mc.control.reactive_adjustment_time | 40124 | 1 | U16 | gain 1 | s | RW | unknown | reactive-power-and-power-factor | Adjustment time associated with a reactive curve. |
| mc.control.night_reactive_ratio | 40128 | 1 | I16 | gain 1000 | not stated | RW | unknown | reactive-power-and-power-factor | Night reactive ratio, converted with Smax. |
| mc.control.night_reactive_power | 40129 | 2 | I32 | gain 1000 | kVar | RW | unknown | reactive-power-and-power-factor | Night reactive power. |
| mc.control.curve_reactive_adjustment_time | 40196 | 1 | U16 | gain 1 | s | RW | unknown | reactive-power-and-power-factor | Adjustment time associated with a reactive curve. |

### Reactive and power-factor curve points

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.qu_mode | 40037 | 1 | E16 | not stated | not stated | RW | unknown | reactive-and-power-factor-curve-points | Q-U mode selection. Enumeration is not stated. |
| mc.control.qu_trigger_power | 40038 | 1 | I16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Power level that triggers Q-U. |
| mc.control.qu_exit_power | 40198 | 1 | I16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Power level that exits Q-U. |
| mc.control.qu_minimum_power_factor | 40375 | 1 | U16 | gain 1000 | not stated | RW | 0..1 in an EN50549 context; zero is special; other bounds unknown | reactive-and-power-factor-curve-points | Lower power-factor bound on Q-U output. Depends on country code. |
| mc.control.qu_activation_delay | 40376 | 1 | U16 | gain 1 | s | RW | unknown | reactive-and-power-factor-curve-points | Q-U activation delay. Depends on country code. |
| mc.control.curve_aux_42032 | 42032 | 1 | U16 | gain 10 | s | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| mc.control.curve_aux_42101 | 42101 | 1 | U16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| mc.control.curve_aux_42102 | 42102 | 1 | U16 | gain 1 | % | RW | unknown | reactive-and-power-factor-curve-points | Curve-auxiliary setting. Specific role is not stated. |
| mc.control.pu_adjustment_time | 42242 | 1 | U16 | gain 100 | s | RW | unknown | reactive-and-power-factor-curve-points | P-U adjustment time. |

### Curve blocks

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.cosphi_pn_curve | 40133 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Cos-phi versus Pn curve block. Inner layout is not in this card. |
| mc.control.qu_characteristic_curve | 40154 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Q-U characteristic curve block. Inner layout is not in this card. |
| mc.control.pfu_characteristic_curve | 40175 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | PF-U characteristic curve block. Inner layout is not in this card. |
| mc.control.qp_curve | 40354 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Q-P curve block. Inner layout is not in this card. |
| mc.control.lvrt_curve | 42155 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | LVRT curve block. Inner point layout is not in this card. |
| mc.control.qu_curve_alternate | 42200 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | Alternate Q-U curve block. Inner layout is not in this card. |
| mc.control.pu_curve | 42221 | 21 | MLD | not stated | not stated | RW | unknown | curve-blocks | P-U curve block. Inner layout is not in this card. |

### Frequency-power

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.distributed_active_percent | 40199 | 1 | I16 | gain 10 | % | RW | unknown | frequency-power | Active-power percent cap during an underfrequency increase. |
| mc.control.frequency_power_42040 | 42040 | 1 | U16 | gain 1 | s | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mc.control.frequency_power_42041 | 42041 | 1 | U16 | gain 1 | ms | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mc.control.frequency_power_42042 | 42042 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mc.control.frequency_power_42043 | 42043 | 1 | U16 | gain 1000 | Hz | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mc.control.frequency_power_42051 | 42051 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mc.control.frequency_power_42052 | 42052 | 1 | U16 | gain 10 | % | RW | unknown | frequency-power | Frequency-power setting. Specific role is not stated. |
| mc.control.frequency_power_42053 | 42053 | 1 | U16 | gain 1 | ms | RW | unknown | frequency-power | Frequency-response initial delay in a Polish profile. |
| mc.control.frequency_power_42141 | 42141 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Frequency-power point described in a G99 context. |
| mc.control.frequency_power_42142 | 42142 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Frequency-power point described in a G99 context. |
| mc.control.frequency_power_42143 | 42143 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42144 | 42144 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42145 | 42145 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42146 | 42146 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42147 | 42147 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42148 | 42148 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | Overfrequency reduction quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42151 | 42151 | 1 | E16 | not stated | not stated | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42152 | 42152 | 1 | U16 | gain 1 | %/min | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42176 | 42176 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42177 | 42177 | 1 | U16 | gain 1 | % | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42178 | 42178 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power_42179 | 42179 | 1 | U16 | gain 100 | Hz | RW | unknown | frequency-power | Underfrequency increase quantity. Entry, stop, exit or recovery is unassigned. |
| mc.control.frequency_power.field_42429 | 42429 | 1 | U16 | gain 1 | ms | RW | unknown | frequency-power | Delay before an underfrequency power increase takes effect. |

### Frequency slope

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.frequency_slope_42080 | 42080 | 1 | E16 | not stated | not stated | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |
| mc.control.frequency_slope_42081 | 42081 | 1 | U16 | gain 10 | Hz/s | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |
| mc.control.frequency_slope_42082 | 42082 | 1 | U16 | gain 10 | s | RW | unknown | frequency-slope | Frequency-slope setting. Specific role is not stated. |

### Voltage and frequency protection levels

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.ten_minute_undervoltage_threshold | 42287 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Ten-minute undervoltage threshold. |
| mc.control.ten_minute_undervoltage_duration | 42288 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Ten-minute undervoltage duration. |
| mc.control.ten_minute_overvoltage_threshold | 42290 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Ten-minute overvoltage threshold. |
| mc.control.ten_minute_overvoltage_duration | 42291 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Ten-minute overvoltage duration. |
| mc.control.overvoltage_level_1_threshold | 42293 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 overvoltage threshold. |
| mc.control.overvoltage_level_1_duration | 42294 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 overvoltage duration. |
| mc.control.overvoltage_level_2_threshold | 42296 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 overvoltage threshold. |
| mc.control.overvoltage_level_2_duration | 42297 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 overvoltage duration. |
| mc.control.overvoltage_level_3_threshold | 42299 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 overvoltage threshold. |
| mc.control.overvoltage_level_3_duration | 42300 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 overvoltage duration. |
| mc.control.overvoltage_level_4_threshold | 42302 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 overvoltage threshold. |
| mc.control.overvoltage_level_4_duration | 42303 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 overvoltage duration. |
| mc.control.overvoltage_level_5_threshold | 42305 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 overvoltage threshold. |
| mc.control.overvoltage_level_5_duration | 42306 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 overvoltage duration. |
| mc.control.overvoltage_level_6_threshold | 42308 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 overvoltage threshold. |
| mc.control.overvoltage_level_6_duration | 42309 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 overvoltage duration. |
| mc.control.undervoltage_level_1_threshold | 42311 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 undervoltage threshold. |
| mc.control.undervoltage_level_1_duration | 42312 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 undervoltage duration. |
| mc.control.undervoltage_level_2_threshold | 42314 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 undervoltage threshold. |
| mc.control.undervoltage_level_2_duration | 42315 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 undervoltage duration. |
| mc.control.undervoltage_level_3_threshold | 42317 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 undervoltage threshold. |
| mc.control.undervoltage_level_3_duration | 42318 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 undervoltage duration. |
| mc.control.undervoltage_level_4_threshold | 42320 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 undervoltage threshold. |
| mc.control.undervoltage_level_4_duration | 42321 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 undervoltage duration. |
| mc.control.undervoltage_level_5_threshold | 42323 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 undervoltage threshold. |
| mc.control.undervoltage_level_5_duration | 42324 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 undervoltage duration. |
| mc.control.undervoltage_level_6_threshold | 42326 | 1 | U16 | gain 10 | V | RW | tied to Vn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 undervoltage threshold. |
| mc.control.undervoltage_level_6_duration | 42327 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 undervoltage duration. |
| mc.control.overfrequency_level_1_threshold | 42329 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 overfrequency threshold. |
| mc.control.overfrequency_level_1_duration | 42330 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 overfrequency duration. |
| mc.control.overfrequency_level_2_threshold | 42332 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 overfrequency threshold. |
| mc.control.overfrequency_level_2_duration | 42333 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 overfrequency duration. |
| mc.control.overfrequency_level_3_threshold | 42335 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 overfrequency threshold. |
| mc.control.overfrequency_level_3_duration | 42336 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 overfrequency duration. |
| mc.control.overfrequency_level_4_threshold | 42338 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 overfrequency threshold. |
| mc.control.overfrequency_level_4_duration | 42339 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 overfrequency duration. |
| mc.control.overfrequency_level_5_threshold | 42341 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 overfrequency threshold. |
| mc.control.overfrequency_level_5_duration | 42342 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 overfrequency duration. |
| mc.control.overfrequency_level_6_threshold | 42344 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 overfrequency threshold. |
| mc.control.overfrequency_level_6_duration | 42345 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 overfrequency duration. |
| mc.control.underfrequency_level_1_threshold | 42347 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 1 underfrequency threshold. |
| mc.control.underfrequency_level_1_duration | 42348 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 1 underfrequency duration. |
| mc.control.underfrequency_level_2_threshold | 42350 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 2 underfrequency threshold. |
| mc.control.underfrequency_level_2_duration | 42351 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 2 underfrequency duration. |
| mc.control.underfrequency_level_3_threshold | 42353 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 3 underfrequency threshold. |
| mc.control.underfrequency_level_3_duration | 42354 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 3 underfrequency duration. |
| mc.control.underfrequency_level_4_threshold | 42356 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 4 underfrequency threshold. |
| mc.control.underfrequency_level_4_duration | 42357 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 4 underfrequency duration. |
| mc.control.underfrequency_level_5_threshold | 42359 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 5 underfrequency threshold. |
| mc.control.underfrequency_level_5_duration | 42360 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 5 underfrequency duration. |
| mc.control.underfrequency_level_6_threshold | 42362 | 1 | U16 | gain 100 | Hz | RW | tied to Fn and the grid code; numeric bounds unknown | voltage-and-frequency-protection-levels | Level 6 underfrequency threshold. |
| mc.control.underfrequency_level_6_duration | 42363 | 2 | U32 | gain 1 | ms | RW | unknown | voltage-and-frequency-protection-levels | Level 6 underfrequency duration. |

### Ride-through

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.ramps_42100 | 42100 | 1 | U16 | gain 1 | s | RW | unknown | ride-through | Active-power gradient while recovering after a grid fault. |
| mc.control.ride_through_42110 | 42110 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.grid_jump_threshold | 42111 | 1 | U16 | gain 10 | % | RW | unknown | ride-through | Grid-jump threshold limited to a VDE4120 context. |
| mc.control.ride_through_42112 | 42112 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.ride_through_42113 | 42113 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.ride_through_42114 | 42114 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.ride_through_42118 | 42118 | 1 | U16 | gain 100 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.ride_through_42119 | 42119 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through point. The documentary default differs by profile. |
| mc.control.ride_through_42120 | 42120 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | LVRT entry threshold. A grid-profile predicate is required. |
| mc.control.ride_through_42121 | 42121 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Masks voltage protection during LVRT or HVRT. |
| mc.control.ride_through_42122 | 42122 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Sequence reactive current during LVRT. |
| mc.control.vrt_exit_hysteresis | 42123 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | Ride-through exit hysteresis against the entry thresholds. |
| mc.control.ride_through_42124 | 42124 | 1 | U16 | gain 1 | % | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.ride_through_42125 | 42125 | 1 | U16 | gain 1 | %/s | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.ride_through_42126 | 42126 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.ride_through_42127 | 42127 | 1 | U16 | gain 10 | not stated | RW | unknown | ride-through | Sequence reactive current during LVRT. |
| mc.control.ride_through_42128 | 42128 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |
| mc.control.ride_through_42133 | 42133 | 1 | U16 | gain 1 | % | RW | unknown | ride-through | LVRT reactive-current limit against rated current. |
| mc.control.lvrt_zero_current_threshold_conflict | 42134 | 1 | U16 | gain 10 | V | RW | unknown | ride-through | LVRT zero-current wording stays with this edition. |
| mc.control.ride_through_42135 | 42135 | 1 | E16 | not stated | not stated | RW | unknown | ride-through | Ride-through setting. Specific role is not stated. |

### Voltage rise

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.voltage_rise_42138 | 42138 | 1 | E16 | not stated | not stated | RW | unknown | voltage-rise | Voltage-rise setting. Specific role is not stated. |
| mc.control.voltage_rise_reactive_point | 42139 | 1 | U16 | gain 10 | % | RW | unknown | voltage-rise | Voltage-rise reactive point. It must sit below the active point. |
| mc.control.voltage_rise_active_point | 42140 | 1 | U16 | gain 10 | % | RW | unknown | voltage-rise | Voltage-rise active point. It must sit above the reactive point. |

### Islanding

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.islanding_42129 | 42129 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |
| mc.control.islanding_42130 | 42130 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |
| mc.control.islanding_42131 | 42131 | 1 | E16 | not stated | not stated | RW | unknown | islanding | Islanding setting. Specific role is not stated. |

### Normal reconnection

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.normal_connection_42084 | 42084 | 1 | U16 | gain 10 | V | RW | unknown | normal-reconnection | Normal reconnection voltage. High versus low is not stated. |
| mc.control.normal_connection_42085 | 42085 | 1 | U16 | gain 10 | V | RW | unknown | normal-reconnection | Normal reconnection voltage. High versus low is not stated. |
| mc.control.normal_connection_42086 | 42086 | 1 | U16 | gain 100 | Hz | RW | unknown | normal-reconnection | Normal reconnection frequency. High versus low is not stated. |
| mc.control.normal_connection_42087 | 42087 | 1 | U16 | gain 100 | Hz | RW | unknown | normal-reconnection | Normal reconnection frequency. High versus low is not stated. |

### Post-fault reconnection and rapid restart

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mc.control.startup_recovery_42088 | 42088 | 1 | U16 | gain 10 | V | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection voltage. High versus low is not stated. |
| mc.control.startup_recovery_42089 | 42089 | 1 | U16 | gain 10 | V | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection voltage. High versus low is not stated. |
| mc.control.startup_recovery_42090 | 42090 | 1 | U16 | gain 100 | Hz | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection frequency. High versus low is not stated. |
| mc.control.startup_recovery_42091 | 42091 | 1 | U16 | gain 100 | Hz | RW | unknown | post-fault-reconnection-and-rapid-restart | Post-fault reconnection frequency. High versus low is not stated. |
| mc.control.startup_recovery_42105 | 42105 | 2 | U32 | gain 1 | ms | RW | unknown | post-fault-reconnection-and-rapid-restart | Time used only while rapid restart after a grid fault is enabled. |
| mc.control.rapid_restart_mode | 42116 | 1 | E16 | not stated | not stated | RW | 0 ordinary restart; 1 rapid restart | post-fault-reconnection-and-rapid-restart | Selects ordinary restart or rapid restart after a short grid break. |

### Open points

- The inner layout of each 21-register curve block is missing.
- The grid-code dictionary for this card is missing.
- `mc.control.fixed_active_limit_low_resolution` is named and not filled.
- `mc.control.active_percent_limit` is named and not filled.
- `mc.control.fixed_active_limit_watts` is named and not filled.
- `mc.control.microgrid.field_42044` is named and not filled.
- `mc.control.microgrid.field_42045` is named and not filled.
- `mc.control.microgrid.field_42407` is named and not filled.
- `mc.control.microgrid.field_42409` is named and not filled.
- `mc.control.plant_dispatch.field_47426` is named and not filled.
- `mc.control.plant_dispatch.field_47674` is named and not filled.
- `mc.control.plant_dispatch.field_47675` is named and not filled.
- `mc.control.plant_dispatch.field_47677` is named and not filled.
- `mc.control.apparent_power_limit` is named and not filled.
- `mc.control.active_power_limit` is named and not filled.
- `mc.control.apparent_reference_disputed_unit` is named and not filled.
- `mc.control.active_power_reference` is named and not filled.
- `mc.control.protection.field_42068` is named and not filled.
- `mc.control.protection.field_42115` is named and not filled.
- `mc.control.quality_42065` is named and not filled.
- `mc.control.reactive_ramp` is named and not filled.
- `mc.control.active_ramp` is named and not filled.
- `mc.control.ramps_42029` is named and not filled.
- `mc.control.ramps_42030` is named and not filled.
- `mc.control.ramps_42103` is named and not filled.
- `mc.control.ramps_42107` is named and not filled.
- `mc.control.ramps_42109` is named and not filled.
- `mc.control.ramps.field_42403` is named and not filled.
- `mc.control.ramps.field_42404` is named and not filled.
- `mc.control.remote_scheduling` is named and not filled.
- `mc.control.instruction_lifetime` is named and not filled.
- `mc.control.japan_broadcast_active_ramp` is named and not filled.
- `mc.control.startup_recovery_42061` is named and not filled.
- `mc.control.startup_recovery_42062` is named and not filled.
- `mc.control.startup_recovery_42092` is named and not filled.
- `mc.control.startup_recovery_42104` is named and not filled.

## COMMERCIAL

Catalog file `registers-commercial.json`.

Source edition: SUN2000 Commercial Inverter MODBUS Interface Definitions, Issue 01,
2017-12-26. The edition records no device-model rows. The firmware floor is unknown.
Device-model applicability is unknown. The access column is the access the edition
records and is not qualified writable support.
Writable support: unsupported.

### Dispatch settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| commercial.control.dispatch.40120 | 40120 | 1 | U16 | 10 | kW | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| commercial.control.dispatch.40122 | 40122 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| commercial.control.dispatch.40123 | 40123 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| commercial.control.dispatch.40125 | 40125 | 1 | U16 | 10 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| commercial.control.dispatch.40200 | 40200 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. Quarantine Q03. |
| commercial.control.dispatch.40201 | 40201 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. Quarantine Q03. |

### Grid-protection settings

No row in this block.

### Dispatch snapshots

No row in this block.

### Ride-through records

No row in this block.

### Open points

- Unnamed inverter dispatch rows stay unnamed.
- Commercial points 40200 and 40201 stay an open point.

## HA

Catalog file `registers-ha.json`.

Source edition: Solar Inverter Modbus Interface Definitions (V3.0), Issue 08,
2026-06-01. Family: SUN2000HA. Firmware floor: SUN2000HA V500R026C10. The edition lists
its device models on page 6. Other editions of this title are outside this card. The
access column is the access the edition records and is not qualified writable support.
Writable support: verified only for device models of the SUN2000HA family at that firmware floor.

### Dispatch settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ha.control.dispatch.40037 | 40037 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40038 | 40038 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40120 | 40120 | 1 | U16 | 10 | kW | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40122 | 40122 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40123 | 40123 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40124 | 40124 | 1 | U16 | 10 | s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40125 | 40125 | 1 | U16 | 10 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40129 | 40129 | 2 | I32 | 1000 | kVar | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40133 | 40133 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| ha.control.dispatch.40154 | 40154 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| ha.control.dispatch.40175 | 40175 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| ha.control.dispatch.40196 | 40196 | 1 | U16 | 1 | s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40198 | 40198 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| ha.control.dispatch.40200 | 40200 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| ha.control.dispatch.40201 | 40201 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| ha.control.dispatch.40205 | 40205 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |

### Grid-protection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ha.control.grid_protection.42000 | 42000 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| ha.control.grid_protection.42015 | 42015 | 2 | U32 | 1000 | %/s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| ha.control.grid_protection.42017 | 42017 | 2 | U32 | 1000 | %/s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| ha.control.grid_protection.42019 | 42019 | 2 | U32 | 1 | s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| ha.control.grid_protection.42067 | 42067 | 1 | ENUM16 | unknown | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |

### Dispatch snapshots

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| dispatch.snapshot.adjustmentmode | 35300 | 1 | U16 | 1 | - | RO | unknown | dispatch-snapshots | Dispatch adjustment-mode readback. Quarantine D01. |
| dispatch.snapshot.adjustmentmode | 35304 | 1 | U16 | 1 | - | RO | unknown | dispatch-snapshots | Dispatch adjustment-mode readback. Quarantine D01. |
| dispatch.snapshot.adjustmentvalue | 35305 | 2 | U32 | 1 | - | RO | unknown | dispatch-snapshots | Dispatch adjustment-value readback. |
| dispatch.snapshot.adjustmentcommand | 35307 | 1 | U16 | 1 | - | RO | unknown | dispatch-snapshots | Dispatch adjustment-command readback. Quarantine D01. |

### Ride-through records

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| time.event_or_collection.timeofthelasthighvoltsride_throughs | 35318 | 2 | U32 | 1 | - | RO | unknown | ride-through-records | Timestamp of the last high-voltage ride-through. |
| time.event_or_collection.timeofthelastlowvoltsride_throughs | 35320 | 2 | U32 | 1 | - | RO | unknown | ride-through-records | Timestamp of the last low-voltage ride-through. |
| inverter.measurement.cumulativenumberofhighvoltsride_throughs | 35322 | 2 | U32 | 1 | - | RO | unknown | ride-through-records | Count of high-voltage ride-through events. |
| inverter.measurement.cumulativenumberoflowvoltsride_throughs | 35324 | 2 | U32 | 1 | - | RO | unknown | ride-through-records | Count of low-voltage ride-through events. |
| time.event_or_collection.exittimeofthelasthighvoltsride_throughs | 35493 | 2 | U32 | 1 | - | RO | unknown | ride-through-records | Timestamp when the last ride-through ended. |
| time.event_or_collection.exittimeofthelastlowvoltsride_throughs | 35495 | 2 | U32 | 1 | - | RO | unknown | ride-through-records | Timestamp when the last ride-through ended. |

### Open points

- Unnamed inverter dispatch rows stay unnamed.
- The inner layout of each quantity-21 curve block is missing.
- Quarantine D01 merged enumerations stay unsplit.

## HB

Catalog file `registers-hb.json`.

Source edition: SUN2000HB V100R023C00 Inverter Modbus Interface Definitions, Issue 01,
2024-07-18. Family: SUN2000HB. Firmware floor: SUN2000HB V100R023C00. The edition lists
its device models on page 6. The access column is the access the edition records and is
not qualified writable support.
Writable support: verified only for device models of the SUN2000HB family at that firmware floor.

### Dispatch settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hb.control.dispatch.40037 | 40037 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hb.control.dispatch.40038 | 40038 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hb.control.dispatch.40039 | 40039 | 1 | I16 | 100 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hb.control.dispatch.40040 | 40040 | 1 | I16 | 100 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hb.control.dispatch.40043 | 40043 | 2 | I32 | 1000 | kW | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hb.control.dispatch.40122 | 40122 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hb.control.dispatch.40129 | 40129 | 1 | I32 | 1000 | kVar | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| hb.control.dispatch.40133 | 40133 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| hb.control.dispatch.40154 | 40154 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| hb.control.dispatch.40175 | 40175 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| hb.control.dispatch.40196 | 40196 | 1 | U16 | 1 | s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hb.control.dispatch.40198 | 40198 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hb.control.dispatch.40200 | 40200 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| hb.control.dispatch.40201 | 40201 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| hb.control.dispatch.40354 | 40354 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |

### Grid-protection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hb.control.grid_protection.42000 | 42000 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hb.control.grid_protection.42015 | 42015 | 2 | U32 | 1000 | %/s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hb.control.grid_protection.42017 | 42017 | 2 | U32 | 1000 | %/s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hb.control.grid_protection.42019 | 42019 | 2 | U32 | 1 | s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |

### Dispatch snapshots

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| dispatch.snapshot.regulationmode | 35300 | 1 | U16 | 1 | - | RO | unknown | dispatch-snapshots | Dispatch regulation-mode readback. Quarantine D01. |
| dispatch.snapshot.adjustmentvalue | 35301 | 2 | U32 | * | - | RO | unknown | dispatch-snapshots | Dispatch adjustment-value readback. |
| dispatch.snapshot.adjustmentinstruction | 35303 | 1 | U16 | 1 | - | RO | 40039=activepct_0_01; 40043=activefixedvalue; unlisted: raw (hb.value-enum.35303) | dispatch-snapshots | Dispatch adjustment-instruction readback. |
| dispatch.snapshot.regulationmode | 35304 | 1 | U16 | 1 | - | RO | 0=power_factor; 1=absolute_value; 2=reactive_apparent_ratio; 3=q_u_curve; 4=cosphi_active_power_ratio_curve; 5=pf_u_curve; 6=q_p_curve; unlisted: raw (hb.value-enum.35304) | dispatch-snapshots | Dispatch regulation-mode readback. Class conflict. |
| dispatch.snapshot.adjustmentvalue | 35305 | 2 | U32 | * | - | RO | unknown | dispatch-snapshots | Dispatch adjustment-value readback. Class conflict. |
| dispatch.snapshot.adjustmentinstruction | 35307 | 1 | U16 | 1 | - | RO | 40122=power_factor; 40040=reactive_apparent_ratio_adjustment; 40129=fixed_night_reactive_power_kvar; unlisted: raw (hb.value-enum.35307) | dispatch-snapshots | Dispatch adjustment-instruction readback. Class conflict. |

### Ride-through records

No row in this block.

### Open points

- Unnamed inverter dispatch rows stay unnamed.
- The inner layout of each quantity-21 curve block is missing.
- Quarantine D01 merged enumerations stay unsplit.

## HD

Catalog file `registers-hd.json`.

Source edition: SUN2000HD V100R026C00 Modbus Interface Definitions, Issue 01,
2026-03-30. Family: SUN2000HD. Firmware floor: SUN2000HD V100R026C00. The edition lists
its device models on page 6. The access column is the access the edition records and is
not qualified writable support.
Writable support: verified only for device models of the SUN2000HD family at that firmware floor.

### Dispatch settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hd.control.dispatch.40037 | 40037 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40038 | 40038 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40120 | 40120 | 1 | U16 | 10 | kW | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40122 | 40122 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40123 | 40123 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40124 | 40124 | 1 | U16 | 10 | s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40125 | 40125 | 1 | U16 | 10 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40129 | 40129 | 2 | I32 | 1000 | kVar | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40133 | 40133 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| hd.control.dispatch.40154 | 40154 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| hd.control.dispatch.40175 | 40175 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| hd.control.dispatch.40196 | 40196 | 1 | U16 | 1 | s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40198 | 40198 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| hd.control.dispatch.40200 | 40200 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| hd.control.dispatch.40201 | 40201 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |

### Grid-protection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hd.control.grid_protection.42000 | 42000 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42014 | 42014 | 1 | ENUM16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42015 | 42015 | 2 | U32 | 1000 | %/s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42017 | 42017 | 2 | U32 | 1000 | %/s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42019 | 42019 | 2 | U32 | 1 | s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42067 | 42067 | 1 | ENUM16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42589 | 42589 | 1 | ENUM16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42606 | 42606 | 1 | ENUM16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42607 | 42607 | 1 | ENUM16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42608 | 42608 | 1 | ENUM16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| hd.control.grid_protection.42609 | 42609 | 1 | U16 | 1 | min | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |

### Dispatch snapshots

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| dispatch.snapshot.adjustmentmode | 35300 | 4 | U16 | 1 | - | RO | unknown | dispatch-snapshots | Dispatch adjustment-mode readback. Quantity is 4 for type U16. |
| dispatch.snapshot.adjustmentmode | 35304 | 4 | U16 | 1 | - | RO | unknown | dispatch-snapshots | Dispatch adjustment-mode readback. Quarantine D01. Quantity is 4 for type U16. |

### Ride-through records

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| grid.ride_through_count.lvrttimes | 35483 | 2 | U32 | 1 | - | RO | unknown | ride-through-records | Count of low-voltage ride-through events. |
| grid.ride_through_count.hvrttimes | 35485 | 2 | U32 | 1 | - | RO | unknown | ride-through-records | Count of high-voltage ride-through events. |

### Open points

- Unnamed inverter dispatch rows stay unnamed.
- The inner layout of each quantity-21 curve block is missing.
- The HD snapshot width at the adjustment-mode rows stays unresolved.
- Quarantine D01 merged enumerations stay unsplit.

## SUN-C81

Catalog file `registers-sun-c81.json`.

Source edition: SUN2000 V100R001C81 Solar Inverter Modbus Interface Definitions, Issue
01, 2025-03-27. Families: SUN2000 and SUN2000HA. Firmware floors: SUN2000 V100R001C81;
SUN2000 V200R001C02; SUN2000 V200R001C90; SUN2000 V200R002C00; SUN2000 V200R002C20;
SUN2000HA V100R001C00. The edition lists its device models on pages 6, 7, and 8. The
access column is the access the edition records and is not qualified writable support.
Writable support: verified only for device models of the SUN2000 and SUN2000HA families at one of those firmware floors.

### Dispatch settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sun-c81.control.dispatch.40117 (, occurrence 1) | 40117 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40117 (, occurrence 2) | 40117 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40118 (, occurrence 1) | 40118 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40118 (, occurrence 2) | 40118 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40119 (, occurrence 1) | 40119 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40119 (, occurrence 2) | 40119 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40120 (, occurrence 1) | 40120 | 1 | U16 | 10 | kW | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40120 (, occurrence 2) | 40120 | 1 | U16 | 10 | kW | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40121 (, occurrence 1) | 40121 | 1 | U16 | 10 | %/s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40121 (, occurrence 2) | 40121 | 1 | U16 | 10 | %/s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40122 (, occurrence 1) | 40122 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40122 (, occurrence 2) | 40122 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40123 (, occurrence 1) | 40123 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40123 (, occurrence 2) | 40123 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40124 (, occurrence 1) | 40124 | 1 | U16 | 1 | s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40124 (, occurrence 2) | 40124 | 1 | U16 | 1 | s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40125 (, occurrence 1) | 40125 | 1 | U16 | 10 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40125 (, occurrence 2) | 40125 | 1 | U16 | 10 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40133 | 40133 | 21 | BYTES | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40154 | 40154 | 21 | BYTES | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40198 | 40198 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-c81.control.dispatch.40200 | 40200 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40201 | 40201 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40232 (, occurrence 1) | 40232 | 1 | U16 | 10 | % | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40232 (, occurrence 2) | 40232 | 1 | U16 | 10 | % | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40234 (, occurrence 1) | 40234 | 1 | U16 | 1 | % | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40234 (, occurrence 2) | 40234 | 1 | U16 | 1 | % | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40235 (, occurrence 1) | 40235 | 1 | U16 | 10 | kW | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40235 (, occurrence 2) | 40235 | 1 | U16 | 10 | kW | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40236 (, occurrence 1) | 40236 | 1 | I16 | 1000 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40236 (, occurrence 2) | 40236 | 1 | I16 | 1000 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40237 (, occurrence 1) | 40237 | 1 | I16 | 1000 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-c81.control.dispatch.40237 (, occurrence 2) | 40237 | 1 | I16 | 1000 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |

### Grid-protection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sun-c81.control.grid_protection.42045 | 42045 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42047 | 42047 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42049 | 42049 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42051 | 42051 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42053 | 42053 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42055 | 42055 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42057 | 42057 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42059 | 42059 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42061 | 42061 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42063 | 42063 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42064 | 42064 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42065 | 42065 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42066 | 42066 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42067 | 42067 | 1 | U16 | 100 | Hz | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42068 | 42068 | 1 | U16 | 100 | Hz | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42069 | 42069 | 1 | U16 | 100 | Hz | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42070 | 42070 | 1 | U16 | 100 | Hz | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42071 | 42071 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42072 | 42072 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42074 | 42074 | 1 | U16 | 1000 | MΩ | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42075 | 42075 | 1 | U16 | 10 | % | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42083 | 42083 | 1 | U16 | 1 | s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42084 | 42084 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42085 | 42085 | 1 | U16 | 1 | s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42086 | 42086 | 1 | U16 | 1 | s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42087 | 42087 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42089 | 42089 | 1 | U16 | 10 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42090 | 42090 | 1 | U16 | 1 | % | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42091 | 42091 | 1 | U16 | 1 | % | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42092 | 42092 | 1 | U16 | 100 | Hz | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42093 | 42093 | 1 | U16 | 100 | Hz | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42094 | 42094 | 1 | U16 | 1 | %/min | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42095 | 42095 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42096 | 42096 | 1 | U16 | 1 | % | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42097 | 42097 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42101 | 42101 | 1 | U16 | 1 | min | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42125 | 42125 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42151 | 42151 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42152 | 42152 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42154 | 42154 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42155 | 42155 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42157 | 42157 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42158 | 42158 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42160 | 42160 | 1 | U16 | 10 | V | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42161 | 42161 | 2 | U32 | 1 | ms | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42174 | 42174 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42320 | 42320 | 1 | U16 | 1 | % | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42321 | 42321 | 1 | I16 | 1000 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42333 | 42333 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-c81.control.grid_protection.42731 | 42731 | 1 | U16 | 1 | unknown | WO | unknown | grid-protection-settings | Grid-protection setting. Name unknown. write-only command class. |

### Dispatch snapshots

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| dispatch.snapshot.adjustmentmode | 32402 | 1 | U16 | 1 | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-mode readback. Quarantine D01. |
| dispatch.snapshot.adjustmentvalue | 32403 | 2 | U32 | * | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-value readback. |
| dispatch.snapshot.adjustmentcommand | 32405 | 1 | U16 | 1 | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-command readback. Quarantine D01. |
| dispatch.snapshot.adjustmentmode | 32406 | 1 | U16 | 1 | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-mode readback. Quarantine D01. |
| dispatch.snapshot.adjustmentvalue | 32407 | 2 | U32 | * | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-value readback. |
| dispatch.snapshot.adjustmentcommand | 32409 | 1 | U16 | 1 | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-command readback. Quarantine D01. |

### Ride-through records

No row in this block.

### Open points

- Unnamed inverter dispatch rows stay unnamed.

## SUN-V300

Catalog file `registers-sun-v300.json`.

Source edition: SUN2000 V300R001C00 Solar Inverter Modbus Interface Definitions, Issue
01, 2025-01-09. Family: SUN2000. Firmware floor: SUN2000 V300R001C00. The edition lists
its device models on page 5. The access column is the access the edition records and is
not qualified writable support.
Writable support: verified only for device models of the SUN2000 family at that firmware floor.

### Dispatch settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sun-v300.control.dispatch.40037 | 40037 | 1 | U16 | 1 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40038 | 40038 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40120 | 40120 | 1 | U16 | 10 | kW | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40122 | 40122 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40123 | 40123 | 1 | I16 | 1000 | unknown | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40125 | 40125 | 1 | U16 | 10 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40129 | 40129 | 2 | I32 | 1000 | kVar | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40133 | 40133 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| sun-v300.control.dispatch.40154 | 40154 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| sun-v300.control.dispatch.40175 | 40175 | 21 | MLD | 1 | unknown | RW | unknown | dispatch-settings | Dispatch block of 21 registers. Interior unknown. |
| sun-v300.control.dispatch.40196 | 40196 | 1 | U16 | 1 | s | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40198 | 40198 | 1 | U16 | 1 | % | RW | unknown | dispatch-settings | Dispatch setting. Name unknown. |
| sun-v300.control.dispatch.40200 | 40200 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |
| sun-v300.control.dispatch.40201 | 40201 | 1 | U16 | 1 | unknown | WO | unknown | dispatch-settings | Dispatch setting. Name unknown. write-only command class. |

### Grid-protection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sun-v300.control.grid_protection.42000 | 42000 | 1 | U16 | 1 | unknown | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-v300.control.grid_protection.42015 | 42015 | 2 | U32 | 1000 | %/s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-v300.control.grid_protection.42017 | 42017 | 2 | U32 | 1000 | %/s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |
| sun-v300.control.grid_protection.42019 | 42019 | 2 | U32 | 1 | s | RW | unknown | grid-protection-settings | Grid-protection setting. Name unknown. |

### Dispatch snapshots

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| dispatch.snapshot.adjustmentmode | 35300 | 1 | U16 | 1 | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-mode readback. Class conflict. Quarantine D01. |
| dispatch.snapshot.adjustmentvalue | 35302 | 2 | U32 | * | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-value readback. Class conflict. |
| dispatch.snapshot.adjustmentcommand | 35303 | 1 | U16 | 1 | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-command readback. Class conflict. Quarantine D01. |
| dispatch.snapshot.adjustmentmode | 35304 | 1 | U16 | 1 | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-mode readback. Class conflict. Quarantine D01. |
| dispatch.snapshot.adjustmentvalue | 35305 | 2 | U32 | * | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-value readback. Class conflict. |
| dispatch.snapshot.adjustmentcommand | 35307 | 1 | U16 | 1 | N/A | RO | unknown | dispatch-snapshots | Dispatch adjustment-command readback. Class conflict. Quarantine D01. |

### Ride-through records

No row in this block.

### Open points

- Unnamed inverter dispatch rows stay unnamed.
- The inner layout of each quantity-21 curve block is missing.

## emma-v100r024c00-01-2024-07-15

Catalog file `registers-emma-v100r024c00-01-2024-07-15.json`.

Source edition: EMMA V100R024C00, Issue 01, 2024-07-15. Family: EMMA. Firmware floor:
SmartHEMS V100R024C00SPC100, inclusive. The edition records this floor on page 7. The
edition does not confirm exact device models. Device-model applicability is unverified.
The access column is the access the edition records and is not qualified writable
support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40100 | 40100 | 1 | ENUM16 | N/A | N/A | RW | 0=no limit; 5=zero-power grid connection; 6=feed-in limit in kW; 7=feed-in limit in percent | plant-dispatch-and-grid-connection-settings | Grid-connection power limit mode. |

### Open points

- Unnamed numeric intervals stay unnamed.

## emma-v100r025c00spc102-2025-08-14

Catalog file `registers-emma-v100r025c00spc102-2025-08-14.json`.

Source edition: EMMA V100R025C00SPC102, issue not stated, 2025-08-14. Family: EMMA.
Firmware floor: SmartHEMS V100R025C00SPC102, inclusive. The edition records this floor
on page 7. The edition does not confirm exact device models. Device-model applicability
is unverified. The access column is the access the edition records and is not qualified
writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40100 | 40100 | 1 | ENUM16 | N/A | N/A | RW | 0=no limit; 5=zero-power grid connection; 6=feed-in limit in kW; 7=feed-in limit in percent | plant-dispatch-and-grid-connection-settings | Grid-connection power limit mode. |

### Open points

- Unnamed numeric intervals stay unnamed.

## s-dongle-v100r001c00-05-2022-07-06

Catalog file `registers-s-dongle-v100r001c00-05-2022-07-06.json`.

Source edition: S-Dongle V100R001C00, Issue 05, 2022-07-06. Family: S-Dongle. Firmware
floor: V100R001C00SPC100. The component of that floor is not stated. The edition records
this floor on page 8. The edition's device-model list is exhaustive for the S-Dongle
family. This card defines no grid-code row.
Writable support: unsupported.

This card defines no grid-code row.

This card defines no grid-code row.

### Open points

- Signed grid power on this dongle edition stays a reading, not a setting.

## s-dongle-v200r022cc10-02-2023-04-20

Catalog file `registers-s-dongle-v200r022cc10-02-2023-04-20.json`.

Source edition: S-Dongle V200R022CC10, Issue 02, 2023-04-20. Family: S-Dongle. Firmware
floor: V200R022C10. The component of that floor is not stated. The edition records this
floor on page 8. The edition's device-model list is exhaustive for the S-Dongle family.
This card defines no grid-code row.
Writable support: unsupported.

This card defines no grid-code row.

This card defines no grid-code row.

### Open points

- Signed grid power on this dongle edition stays a reading, not a setting.

## s-dongle-v200r025c00-01-2025-04-27

Catalog file `registers-s-dongle-v200r025c00-01-2025-04-27.json`.

Source edition: S-Dongle V200R025C00, Issue 01, 2025-04-27. Family: S-Dongle. Firmware
floor: V200R022C10. The component of that floor is not stated. The edition records this
floor on page 8. The edition's device-model list is exhaustive for the S-Dongle family.
This card defines no grid-code row.
Writable support: unsupported.

This card defines no grid-code row.

This card defines no grid-code row.

### Open points

- Signed grid power on this dongle edition stays a reading, not a setting.

## s-dongle-v200r025c00spc120-01-2025-12-23

Catalog file `registers-s-dongle-v200r025c00spc120-01-2025-12-23.json`.

Source edition: S-Dongle V200R025C00SPC120, Issue 01, 2025-12-23. Family: S-Dongle.
Firmware floor: V200R022C10. The component of that floor is not stated. The edition
records this floor on page 8. The edition's device-model list is exhaustive for the
S-Dongle family. This card defines no grid-code row.
Writable support: unsupported.

This card defines no grid-code row.

This card defines no grid-code row.

### Open points

- Signed grid power on this dongle edition stays a reading, not a setting.

## smartlogger-32-2018-11-15

Catalog file `registers-smartlogger-32-2018-11-15.json`.

Source edition: SmartLogger, Issue 32, 2018-11-15. Family: SmartLogger. Firmware floors,
each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00; SmartLogger V200R001C00.
The edition records these floors on page 10. The edition does not confirm exact device
models. Device-model applicability is unverified. The access column is the access the
edition records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=reduction disabled; 1=remote dry-contact control; 3=percentage limit; 4=remote communications dispatch; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-32-2018-11-15.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | U32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=output disabled; 1=remote dry-contact control; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=closed-loop power factor; 10=distributed closed-loop power factor; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-32-2018-11-15.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive power; unlisted: raw (smartlogger-32-2018-11-15.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch divisor 1000. Fixed-reactive branch divisor 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40420 | 40420 | 2 | U32 | 10 | kW | RW | Out-of-range values are discarded. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Out-of-range values are discarded. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | U16 | 10 | % | RW | 0–100% | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-36-2020-04-13

Catalog file `registers-smartlogger-36-2020-04-13.json`.

Source edition: SmartLogger, Issue 36, 2020-04-13. Family: SmartLogger. Firmware floors,
each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00; SmartLogger V100R002C00;
SmartLogger V200R001C00; SmartLogger V300R001C00. The edition records these floors on
page 10. The edition does not confirm exact device models. Device-model applicability is
unverified. The access column is the access the edition records and is not qualified
writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI dispatch; 3=fixed-percentage limit in open loop; 4=remote dispatch; 6=export limit in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-36-2020-04-13.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | U32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI dispatch; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-36-2020-04-13.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive power; unlisted: raw (smartlogger-36-2020-04-13.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch divisor 1000. Fixed-reactive branch divisor 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40420 | 40420 | 2 | U32 | 10 | kW | RW | Out-of-range values are discarded. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Out-of-range values are discarded. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | U16 | 10 | % | RW | 0–100% | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-37-2020-06-24

Catalog file `registers-smartlogger-37-2020-06-24.json`.

Source edition: SmartLogger, Issue 37, 2020-06-24. Family: SmartLogger. Firmware floors,
each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00; SmartLogger V100R002C00;
SmartLogger V200R001C00; SmartLogger V300R001C00. The edition records these floors on
page 11. The edition does not confirm exact device models. Device-model applicability is
unverified. The access column is the access the edition records and is not qualified
writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI dispatch; 3=fixed-percentage limit in open loop; 4=remote dispatch; 6=export limit in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-37-2020-06-24.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | U32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI dispatch; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-37-2020-06-24.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive power; unlisted: raw (smartlogger-37-2020-06-24.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch divisor 1000. Fixed-reactive branch divisor 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40420 | 40420 | 2 | U32 | 10 | kW | RW | Out-of-range values are discarded. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Out-of-range values are discarded. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | U16 | 10 | % | RW | 0–100% | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-v300r024c10-01-2026-10-15

Catalog file `registers-smartlogger-v300r024c10-01-2026-10-15.json`.

Source edition: SmartLogger V300R024C10, Issue 01, 2026-10-15. Family: SmartLogger.
Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00;
SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00. The edition
records these floors on page 15. The edition does not confirm exact device models.
Device-model applicability is unverified. The access column is the access the edition
records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI-port dispatch; 3=percentage limit in open loop; 4=remote communications dispatch; 6=power-limited grid connection in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10-01-2026-10-15.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI-port dispatch; 2=absolute reactive-power target; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 12=PF-U curve; 14=Q-P curve; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10-01-2026-10-15.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r024c10-01-2026-10-15.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Fixed reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | PCS rated active power, both signs. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 1) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 2) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | Minus through plus PCS rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Lower end is minus PCS rated active power. Upper end is inverter-plus-PCS rated active power. Outside values are discarded. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus combined rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | I16 | 10 | % | RW | −100% to 100%. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Span runs from a negative PCS active-power rating up to the inverter-and-PCS active-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Span is negative through positive, bounded by the inverter-and-PCS apparent-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.44165 | 44165 | 1 | U16 | N/A | N/A | RW | 0=no output; 1=DI dispatch; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 8=reserved; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 11=reserved. 65533 and 65534 are unassigned in this cell | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-v300r024c10-53-2025-10-29

Catalog file `registers-smartlogger-v300r024c10-53-2025-10-29.json`.

Source edition: SmartLogger V300R024C10, Issue 53, 2025-10-29. Family: SmartLogger.
Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00;
SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00. The edition
records these floors on page 15. The edition does not confirm exact device models.
Device-model applicability is unverified. The access column is the access the edition
records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI-port dispatch; 3=percentage limit in open loop; 4=remote communications dispatch; 6=power-limited grid connection in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10-53-2025-10-29.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI-port dispatch; 2=absolute reactive-power target; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 12=PF-U curve; 14=Q-P curve; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10-53-2025-10-29.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r024c10-53-2025-10-29.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Fixed reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | PCS rated active power, both signs. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 1) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 2) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | Minus through plus PCS rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Lower end is minus PCS rated active power. Upper end is inverter-plus-PCS rated active power. Outside values are discarded. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus combined rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | I16 | 10 | % | RW | −100% to 100%. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Span runs from a negative PCS active-power rating up to the inverter-and-PCS active-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Span is negative through positive, bounded by the inverter-and-PCS apparent-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-v300r024c10-54-2026-02-06

Catalog file `registers-smartlogger-v300r024c10-54-2026-02-06.json`.

Source edition: SmartLogger V300R024C10, Issue 54, 2026-02-06. Family: SmartLogger.
Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00;
SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00. The edition
records these floors on page 15. The edition does not confirm exact device models.
Device-model applicability is unverified. The access column is the access the edition
records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI-port dispatch; 3=percentage limit in open loop; 4=remote communications dispatch; 6=power-limited grid connection in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10-54-2026-02-06.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI-port dispatch; 2=absolute reactive-power target; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 12=PF-U curve; 14=Q-P curve; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10-54-2026-02-06.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r024c10-54-2026-02-06.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Fixed reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | PCS rated active power, both signs. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 1) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 2) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | Minus through plus PCS rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Lower end is minus PCS rated active power. Upper end is inverter-plus-PCS rated active power. Outside values are discarded. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus combined rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | I16 | 10 | % | RW | −100% to 100%. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Span runs from a negative PCS active-power rating up to the inverter-and-PCS active-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Span is negative through positive, bounded by the inverter-and-PCS apparent-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-v300r024c10spc180-01-2025-06-23

Catalog file `registers-smartlogger-v300r024c10spc180-01-2025-06-23.json`.

Source edition: SmartLogger V300R024C10SPC180, Issue 01, 2025-06-23. Family:
SmartLogger. Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger
V100R001C00; SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00.
The edition records these floors on page 16. The edition does not confirm exact device
models. Device-model applicability is unverified. The access column is the access the
edition records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI-port dispatch; 3=percentage limit in open loop; 4=remote communications dispatch; 6=power-limited grid connection in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10spc180-01-2025-06-23.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI-port dispatch; 2=absolute reactive-power target; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 12=PF-U curve; 14=Q-P curve; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10spc180-01-2025-06-23.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r024c10spc180-01-2025-06-23.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Fixed reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | PCS rated active power, both signs. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 1) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 2) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | Minus through plus PCS rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Lower end is minus PCS rated active power. Upper end is inverter-plus-PCS rated active power. Outside values are discarded. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus combined rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | I16 | 10 | % | RW | −100% to 100%. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Span runs from a negative PCS active-power rating up to the inverter-and-PCS active-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Span is negative through positive, bounded by the inverter-and-PCS apparent-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-v300r024c10spc191-52-2025-06-06

Catalog file `registers-smartlogger-v300r024c10spc191-52-2025-06-06.json`.

Source edition: SmartLogger V300R024C10SPC191, Issue 52, 2025-06-06. Family:
SmartLogger. Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger
V100R001C00; SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00.
The edition records these floors on page 15. The edition does not confirm exact device
models. Device-model applicability is unverified. The access column is the access the
edition records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI-port dispatch; 3=percentage limit in open loop; 4=remote communications dispatch; 6=power-limited grid connection in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10spc191-52-2025-06-06.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI-port dispatch; 2=absolute reactive-power target; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 12=PF-U curve; 14=Q-P curve; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10spc191-52-2025-06-06.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r024c10spc191-52-2025-06-06.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Fixed reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | PCS rated active power, both signs. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 1) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 2) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | Minus through plus PCS rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Lower end is minus PCS rated active power. Upper end is inverter-plus-PCS rated active power. Outside values are discarded. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus combined rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | I16 | 10 | % | RW | −100% to 100%. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Span runs from a negative PCS active-power rating up to the inverter-and-PCS active-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Span is negative through positive, bounded by the inverter-and-PCS apparent-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-v300r024c10spc210-49-2025-03-19

Catalog file `registers-smartlogger-v300r024c10spc210-49-2025-03-19.json`.

Source edition: SmartLogger V300R024C10SPC210, Issue 49, 2025-03-19. Family:
SmartLogger. Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger
V100R001C00; SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00;
LUNA2000B V300R024C00. The edition records these floors on page 13. The edition does not
confirm exact device models. Device-model applicability is unverified. The access column
is the access the edition records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI-port dispatch; 3=percentage limit in open loop; 4=remote communications dispatch; 6=power-limited grid connection in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10spc210-49-2025-03-19.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI-port dispatch; 2=absolute reactive-power target; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 12=PF-U curve; 14=Q-P curve; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r024c10spc210-49-2025-03-19.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r024c10spc210-49-2025-03-19.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Fixed reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | PCS rated active power, both signs. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | Minus through plus PCS rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Lower end is minus PCS rated active power. Upper end is inverter-plus-PCS rated active power. Outside values are discarded. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus combined rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | I16 | 10 | % | RW | −100% to 100%. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Span runs from a negative PCS active-power rating up to the inverter-and-PCS active-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Span is negative through positive, bounded by the inverter-and-PCS apparent-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.41889 | 41889 | 1 | U16 | N/A | N/A | RW | 0=unrestricted; 1=DI dispatch; 3=fixed-percentage limit in open loop; 4=remote communications dispatch; 6=grid power limit in kW; 200=remote output control. 65533 and 65534 are unassigned in this cell | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.44165 | 44165 | 1 | U16 | 1 | N/A | RW | 0=no output; 1=DI dispatch; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-v300r025c10-01-2025-12-22

Catalog file `registers-smartlogger-v300r025c10-01-2025-12-22.json`.

Source edition: SmartLogger V300R025C10, Issue 01, 2025-12-22. Family: SmartLogger.
Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00;
SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00. The edition
records these floors on page 7. The edition does not confirm exact device models.
Device-model applicability is unverified. The access column is the access the edition
records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI-port dispatch; 3=percentage limit in open loop; 4=remote communications dispatch; 6=power-limited grid connection in kW; 200=remote output control; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r025c10-01-2025-12-22.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI-port dispatch; 2=absolute reactive-power target; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 12=PF-U curve; 14=Q-P curve; 65533=subordinate SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r025c10-01-2025-12-22.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r025c10-01-2025-12-22.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Fixed reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | PCS rated active power, both signs. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 1) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40384 (, occurrence 2) | 40384 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | Minus through plus PCS rated apparent power. Commands outside that span are not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Lower end is minus PCS rated active power. Upper end is inverter-plus-PCS rated active power. Outside values are discarded. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus combined rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | unknown | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40428 | 40428 | 1 | I16 | 10 | % | RW | −100% to 100%. A negative value imports when storage is installed. | plant-dispatch-and-grid-connection-settings | Percent setpoint for aggregate active output. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Span runs from a negative PCS active-power rating up to the inverter-and-PCS active-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Span is negative through positive, bounded by the inverter-and-PCS apparent-power rating. A command past either end is not run. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |

### Open points

- Unnamed numeric intervals stay unnamed.

## smartlogger-v300r025c10-02-2026-10-09

Catalog file `registers-smartlogger-v300r025c10-02-2026-10-09.json`.

Source edition: SmartLogger V300R025C10, Issue 02, 2026-10-09. Family: SmartLogger.
Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00;
SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00. The edition
records these floors on page 7. The edition does not confirm exact device models.
Device-model applicability is unverified. The access column is the access the edition
records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI dispatch; 2=reserved; 3=fixed-percentage limit in open loop; 4=remote communications dispatch; 5=reserved; 6=grid power limit in kW; 7=reserved; 200=remote output control; 65533=control from another SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r025c10-02-2026-10-09.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI dispatch; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 8=reserved; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 11=reserved; 65533=control from another SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r025c10-02-2026-10-09.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r025c10-02-2026-10-09.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Out-of-range action unknown. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | Minus through plus array PCS rated active power. Out-of-range action unknown. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 | 40384 | 2 | I32 | 10 | kVar | RW | Both printed ends are positive inverter rated apparent power. A negative lower end is absent. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit. Printed bound is unresolved. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | PCS rated apparent power is repeated twice. Sign, delimiter, and execution rule unknown. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit. Printed bound is unresolved. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Outside values are discarded. Printed lower end is positive PCS rated active power. Upper end is inverter-plus-PCS rated active power. No minus sign is printed on the lower end. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter-and-PCS rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | Inverter scope only. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | Inverter scope only. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Printed start is a positive PCS active-power rating. Printed end is an inverter-plus-PCS active-power rating. The start carries no minus sign. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Minus through plus inverter-and-PCS rated apparent power. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.44165 | 44165 | 1 | U16 | N/A | N/A | RW | 0=no output; 1=DI dispatch; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 8=reserved; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 11=reserved. 65533 and 65534 are unassigned in this cell | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |

### Open points

- Unnamed numeric intervals stay unnamed.
- `gateway-self.40486` has a name and unit disagreement and stays open.
- `gateway-self.40608` repeats code 3 and leaves code 1 unassigned.

## smartlogger-v300r026c10-02-2026-10-09

Catalog file `registers-smartlogger-v300r026c10-02-2026-10-09.json`.

Source edition: SmartLogger V300R026C10, Issue 02, 2026-10-09. Family: SmartLogger.
Firmware floors, each inclusive: SUN2000 V100R001C95; SmartLogger V100R001C00;
SmartLogger V100R002C00; SmartLogger V200R001C00; SmartLogger V300R001C00. The edition
records these floors on page 7. The edition does not confirm exact device models.
Device-model applicability is unverified. The access column is the access the edition
records and is not qualified writable support.
Writable support: unsupported.

### Plant dispatch and grid-connection settings

| point key | address | quantity | type | gain | unit | access (RO, RW or WO as the card gives) | range or dictionary | functional class | meaning (own words) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gateway-self.40737 | 40737 | 1 | U16 | 1 | N/A | RO | 0=unrestricted; 1=DI dispatch; 2=reserved; 3=fixed-percentage limit in open loop; 4=remote communications dispatch; 5=reserved; 6=grid power limit in kW; 7=reserved; 200=remote output control; 65533=control from another SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r026c10-02-2026-10-09.gateway-self.value-enum.40737) | plant-dispatch-and-grid-connection-settings | Active-power dispatch mode. |
| gateway-self.40738 | 40738 | 2 | I32 | 10 | kW | RO | unknown | plant-dispatch-and-grid-connection-settings | Readback of the active-power dispatch target. |
| gateway-self.40740 | 40740 | 1 | U16 | 1 | N/A | RO | 0=no output; 1=DI dispatch; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 8=reserved; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 11=reserved; 65533=control from another SmartLogger; 65534=no dispatch; unlisted: raw (smartlogger-v300r026c10-02-2026-10-09.gateway-self.value-enum.40740) | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |
| gateway-self.40741 | 40741 | 1 | U16 | 1 | N/A | RO | 0=power factor; 1=fixed reactive-power value; unlisted: raw (smartlogger-v300r026c10-02-2026-10-09.gateway-self.value-enum.40741) | plant-dispatch-and-grid-connection-settings | Selects power-factor or fixed reactive target. |
| gateway-self.40742 | 40742 | 2 | I32 | 10/1000 | kVar | RO | Power-factor branch gain 1000. Reactive-power branch gain 10. | plant-dispatch-and-grid-connection-settings | Reactive dispatch target. Gain follows the selected mode. |
| gateway-self.40378 | 40378 | 2 | U32 | 10 | kW | RW | 0 through array inverter rated active power, inclusive. Out-of-range action unknown. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40381 | 40381 | 2 | I32 | 10 | kW | RW | Minus through plus array PCS rated active power. Out-of-range action unknown. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40384 | 40384 | 2 | I32 | 10 | kVar | RW | Both printed ends are positive inverter rated apparent power. A negative lower end is absent. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit. Printed bound is unresolved. |
| gateway-self.40386 | 40386 | 2 | I32 | 10 | kVar | RW | PCS rated apparent power is repeated twice. Sign, delimiter, and execution rule unknown. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit. Printed bound is unresolved. |
| gateway-self.40420 | 40420 | 2 | I32 | 10 | kW | RW | Outside values are discarded. Printed lower end is positive PCS rated active power. Upper end is inverter-plus-PCS rated active power. No minus sign is printed on the lower end. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40422 | 40422 | 2 | I32 | 10 | kVar | RW | Minus through plus inverter-and-PCS rated apparent power. Outside values are discarded. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40424 | 40424 | 2 | U32 | 10 | kW | RW | Inverter scope only. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate active-power target. |
| gateway-self.40426 | 40426 | 2 | I32 | 10 | kVar | RW | Inverter scope only. Numeric ends unknown. | plant-dispatch-and-grid-connection-settings | Writes the aggregate reactive-power target. |
| gateway-self.40429 | 40429 | 1 | I16 | 1000 | N/A | RW | (−1, −0.8] ∪ [0.8, 1]; −1 excluded | plant-dispatch-and-grid-connection-settings | Power-factor setpoint for aggregate reactive output. |
| gateway-self.40430 | 40430 | 2 | I32 | 1000 | kW | RW | Printed start is a positive PCS active-power rating. Printed end is an inverter-plus-PCS active-power rating. The start carries no minus sign. | plant-dispatch-and-grid-connection-settings | Active-power dispatch limit or setpoint. |
| gateway-self.40432 | 40432 | 2 | I32 | 1000 | kVar | RW | Minus through plus inverter-and-PCS rated apparent power. | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch limit or setpoint. |
| gateway-self.44165 | 44165 | 1 | U16 | N/A | N/A | RW | 0=no output; 1=DI dispatch; 2=fixed reactive power; 3=fixed power factor; 4=Q-U curve; 5=cos(Phi)-P/Pn curve; 6=Q-U hysteresis under CEI0-16; 7=remote communications dispatch; 8=reserved; 9=older closed-loop power-factor policy; 10=current closed-loop power-factor policy; 11=reserved. 65533 and 65534 are unassigned in this cell | plant-dispatch-and-grid-connection-settings | Reactive-power dispatch mode. |

### Open points

- Unnamed numeric intervals stay unnamed.
- `gateway-self.40486` has a name and unit disagreement and stays open.
- `gateway-self.40608` repeats code 3 and leaves code 1 unassigned.

## Documents consulted

The source edition, family, and firmware floor named on each card are the edition identity and the model-floor rows of the Huawei PV inverter Modbus reference and the Huawei gateway Modbus reference, reference baseline 2026-10-26.1. Each card names that edition by title, issue, and date. This page restates no vendor table and no device-model token.

**Copyright note.** The information on this page that is derived from the inverter and SmartLogger editions named above is attributed to Huawei Technologies Co., Ltd., which retains the copyright in those documents. This page states that information in its own words and does not reproduce the documents. The CC0-1.0 dedication of this page covers its own expression only and does not relicense those documents.

**Copyright note.** The information on this page that is derived from the EMMA and S-Dongle editions named above is attributed to Huawei Digital Power Technologies Co., Ltd., which retains the copyright in those documents. This page states that information in its own words and does not reproduce the documents. The CC0-1.0 dedication of this page covers its own expression only and does not relicense those documents.

**Reference note.** The edition identity, family, and firmware floor attributed to the Huawei PV inverter Modbus reference and the Huawei gateway Modbus reference were taken through those independent documentary works, whose contributors dedicate their original writing under CC0-1.0. The vendor documents they cite keep their rights, as the copyright notes state. This page restates those facts in its own words.
