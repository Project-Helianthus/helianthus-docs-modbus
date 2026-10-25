# Huawei Read-Only Monitoring Contract V1

## Scope and evidence basis

This page is the monitoring contract for the three Huawei gateway paths that
have an observed identity: the SmartLogger path, the EMMA path, and the
S-Dongle path. For each path it names the register groups that Helianthus reads
for monitoring, the facts each group yields, and the value form of every word
that Helianthus consumes: type, word order, gain, unit, and sign. Each read is
an FC03 holding-register read of one group, given as its offset and quantity.
Words in a group that Helianthus does not consume are retained as native
evidence and are not facts. The read pacing, the acquisition cycle, and the
production-site rules are on the companion
[read pacing and acquisition contract](read-pacing-v1.md). The historical V1
name implies no stability before Helianthus 1.0.

This page creates no admission and changes no disposition. Profile selection
for the SUN2000 and LUNA2000 classes stays `NO_ADMISSIBLE_PROFILE` under the
[inverter and battery disposition](inverter-battery-readonly-v1.md), the
S-Dongle outcome stays `PRE_LIVE_INSUFFICIENT_EVIDENCE` with its recorded stop
in force, and `catalog_registered=false`, `automatic_runtime_admission=false`,
`live_qualified=false`, `support_claim=false`, and `write_authority=false` are
unchanged. The registry companions are helianthus-modbusreg issue 348 for the
monitoring profiles and issue 349 for the read-only providers.

The page rests on two kinds of source. The vendor interface definitions listed
in the Documents consulted section state the offsets, types, gains, units, and
signs. Bounded read-only observations of three operator-owned installations
grade them. Each path had one run that read the monitoring groups at its
inverters, in daylight, at one operating point, with one connection, one
request in flight, and no write. The identity runs behind each path are
recorded on the [SmartLogger observation](smartlogger-observed-inventory-v1.md),
the [EMMA observation](emma-observed-identity-v1.md), and the
[S-Dongle observation](sdongle-observed-identity-v1.md). No value read from an
installation is published here: counters, powers, voltages, times, and
identifiers stay in the private record, and a check is described by what it
compared, never by the numbers.

| Grade | Meaning on this page |
| --- | --- |
| Proven | A live reading was decoded with the stated value form and agreed with an independent check: a physical anchor such as the grid frequency band or the rated power, or a second register of the same read. It holds for the observed units only. |
| Hypothesis | A document states the fact and no live reading has checked it, or a reading was decoded and is plausible but no independent check was possible, or the statement is an inference. |
| Unknown | Neither the consulted documents nor the observations settle it. |

A fact that only a document states is documentary and is never graded Proven.
Grades are separate from admission, qualification, and support.

Inverter families are named by product series. The model token of the
SmartLogger children is published on the
[SUN2000 identity contract](sun2000-observed-identity-v1.md); the exact model
tokens of the EMMA and S-Dongle children stay withheld, as on their observation
pages.

| Path | Inverter family | Inverter units read | Monitoring run |
| --- | --- | --- | --- |
| SmartLogger | SUN2000 M3 series, commercial three-phase | 1 and 2 of the eight listed | 76 requests, 59 answered with data, 17 exceptions, no timeout |
| EMMA | SUN2000 MAP0 series, residential three-phase hybrid | 3 and 4, both listed | 46 requests, 37 answered with data, 9 exceptions, no timeout |
| S-Dongle | SUN2000 M1 series, residential three-phase hybrid | 1, the one child | 31 requests, 25 answered with data, 2 exceptions, 4 timeouts at unit 0 |

## Shared decoding rules

1. **Addressing.** Offsets are zero-based PDU offsets of holding registers, read
   with FC03. Every consulted edition states its addresses this way, and the
   observed identity reads at those offsets answered as the identity pages
   record.
2. **Word order.** Values are big-endian, and a value of two or four registers
   carries its most significant word first. The consulted editions state
   big-endian transport. Two-register counters and powers decoded this way
   passed the checks below at all three inverter families (Proven).
3. **Value.** A signed type is two's complement. The physical value is the raw
   integer divided by the gain, in the stated unit.
4. **Extent.** A group is read exactly as listed, with a quantity of at most 125.
   An observed group never spans an offset the observation did not cover. A
   planned group never spans an offset that its consulted editions leave
   undefined, and it ends on a value boundary.
5. **Refusal.** An exception reply to a group is recorded with its code and
   retained. Exception 3 to a group that another family answers is a refused
   group, not an absent device: the unit stays identified, and the group is not
   sent again until a revision of this page (see the version gate below).
6. **Timeout.** A timeout is a failed attempt and never evidence of absence.
7. **Zero.** A zero word is a value only where this page defines the word for the
   family. Elsewhere it is no evidence of a value or of its absence (see the
   battery rule below).
8. **Energy.** Energy counters are published as read. Helianthus derives no
   energy from power or from other counters. Rollover and reset behavior is
   Unknown, because none was observed.

## SmartLogger path

### Units

The logger answers at unit 0. Its listing names eight inverters at units 1
through 8, a PLC at unit 9, and two meters at units 11 and 19. Child reads go only
to listed units in the operator allowlist, under the routing rules of the
[gateway contract](gateway-readonly-v1.md). The PLC and the meters have no class
contract, so no monitoring read is sent to units 9, 11, or 19.

### Inverter groups (M3 series)

The consulted SUN2000MC edition names the observed model token in its
supported-model table, so it is the edition that binds the inverter groups on
this path.

| ID | Statement | Grade |
| --- | --- | --- |
| MS-01 | At units 1 and 2 the ratings group (FC03 offset 30070, quantity 13) carries a model-identifier word equal to the identifier that the edition's supported-model table assigns to the observed model token, and a rated-power pair that, at the edition's gain, equals the rating that the model token names. The edition therefore applies to these units. | Proven |
| MS-02 | The status group (offset 32000, quantity 16) answered with 16 words at both units. Its words are state and alarm bit fields whose bit meanings the edition refers to sheets outside it. They are retained as native evidence, and no state is published from them. One word of the group is derived from the serial number and is never published. | Proven (answered); meanings Unknown |
| MS-03 | The string group (offset 32016, quantity 24) answered at both units, and its last eight words, beyond the eight strings that the edition defines at offsets 32016 through 32031, were zero at both units. | Proven |
| MS-04 | The power group (offset 32064, quantity 32) was refused with exception 3 at both units. | Proven |
| MS-05 | The energy group (offset 32106, quantity 10) answered at both units. | Proven |
| MS-06 | The inverter-exposed meter group (offset 37100, quantity 38) was refused with exception 3 at both units. The site's meters are listed by the logger as its own children and are not attached to an inverter, which is consistent with the refusal. | Proven (refusal); cause Hypothesis |
| MS-07 | A single read at offset 37000 and a single read at offset 47000 each answered one zero word at both units. The operator describes no battery at the site. | Proven |

The edition defines offset 37000 as a battery state word and leaves offset 47000
undefined, so the answer at 47000 in MS-07 is a read of an offset that the
edition does not define.

Consumed fields of the M3 series groups:

| Fact | Read | Value form in the edition | Live check at units 1 and 2 | Grade |
| --- | --- | --- | --- | --- |
| String voltage, string n for n from 1 to 8 | offset 32016 + 2(n − 1), one word, from the string group | I16, V, gain 10 | Values fall inside the inverter's input range. Strings that share a tracker read equal voltages, in the pairing that the string and tracker counts of the ratings group imply. | Proven |
| String current, string n | offset 32017 + 2(n − 1), one word | I16, A, gain 100 | Strings that share a tracker read equal currents, and each current lies inside the inverter's input range. The power group is refused here, so string power has no same-read cross-check; no time-normalized energy comparison was made. | Hypothesis |
| Accumulated energy | offset 32106, two words | U32, kWh, gain 100 | It is lower than the DC-input energy counter (offset 32108, same form) by a ratio inside the conversion-efficiency band. At this gain its value is a lifetime yield that the rated power can deliver, and a gain ten times smaller would exceed that. | Proven |
| Current-hour energy | offset 32112, two words | U32, kWh, gain 100 | It does not exceed the current-day counter. That ordering does not establish the gain, and no energy change was compared with power over a measured interval. | Hypothesis |
| Current-day energy | offset 32114, two words | U32, kWh, gain 100 | It does not exceed the accumulated counter and is not below the hour counter. That ordering does not establish the gain, and no energy change was compared with power over a measured interval. | Hypothesis |
| Input power and active power | offsets 32064 and 32080, two words each, in the refused power group | I32, kW, gain 1000 | not read: the group is refused (MS-04) | Unknown on this path |
| Device status code | offset 32089, one word, in the refused power group | U16 code | not read | Unknown on this path |

The edition states no sign for the inverter's input or active power. The
statistics-time pair in the energy group (offset 32110) is retained and not
consumed. Its decoded value lay within seconds of the read moment in local time
rather than in UTC, at all three paths (Hypothesis; one reading per unit).

### Logger plant groups (planned)

No logger plant register was read in any run. The two groups below are planned
reads, named from the two consulted SmartLogger editions, which agree on them.
They are not sent until an operator-approved observation records their answer
and this page is revised.

| Group | Read | Consumed fields in both editions | Grade |
| --- | --- | --- | --- |
| Plant power | FC03 offset 40521, quantity 6, at unit 0 | plant DC input power at offset 40521 (U32, kW, gain 1000) and plant AC power at offset 40525 (I32, kW, gain 1000); the pair at offset 40523 is not consumed | Hypothesis for the value form; whether the observed logger answers is Unknown |
| Plant energy | FC03 offset 40560, quantity 4, at unit 0 | plant energy in total at offset 40560 (U32, kWh, gain 10) and for the current day at offset 40562 (U32, kWh, gain 10) | Hypothesis for the value form; whether the observed logger answers is Unknown |

The plant energy values carry a gain of 10, while the inverter counters of the
SUN2000MC edition carry a gain of 100 (DN-04). The editions state no sign for
the plant AC power.

### Facts on the SmartLogger path

| Fact | Source | Grade |
| --- | --- | --- |
| PV energy per inverter (accumulated, current-day, current-hour) | energy group at each inverter unit | Accumulated: Proven at units 1 and 2; current-day and current-hour: Hypothesis; all Hypothesis at units 3 through 8, which answered identity reads but were not read for monitoring |
| String voltage and current per inverter | string group | Voltage Proven and current Hypothesis at units 1 and 2; Hypothesis at units 3 through 8 |
| PV power per inverter | power group, refused | Unknown |
| Plant PV power and energy | plant groups, planned | Hypothesis (documentary) |
| Grid or meter power and energy | meter units 11 and 19, never read | Unknown (meter paths below) |
| Battery state of charge and power | no battery is described; zero words only (MS-07) | Unknown; the zero words are not published as a battery value |

## EMMA path

### Units

The EMMA answers at unit 0. Its listing names a backup box at unit 2 and two
inverters at units 3 and 4. The consulted SmartHEMS editions fix the EMMA's own
unit at 0 and address each other device at its RS-485 address, which the
listing gives as key 5. They define the inverter registers by reference to a
SUN2000 interface definition that is not among the consulted documents. The
backup box has no class contract, so no read is sent to unit 2.

### Inverter groups (MAP0 series)

No consulted document covers this family: the model-identifier word that the
ratings group carries at units 3 and 4 is not in the SUN2000MC edition's
supported-model table (Proven). The groups below were read at the offsets used
on the other two paths, and their words were decoded with the layout of the
SUN2000MC edition as a cross-family hypothesis.

| ID | Statement | Grade |
| --- | --- | --- |
| ME-01 | The status group (offset 32000, quantity 16) answered at units 3 and 4. It is retained, and no state is published from it. | Proven (answered); meanings Unknown |
| ME-02 | The string group (offset 32016, quantity 24) answered at both units. Decoded with the SUN2000MC layout, the strings that the ratings group counts read plausible voltages and currents, and the other words were zero. | Proven (answered); value form Hypothesis |
| ME-03 | The power group (offset 32064, quantity 32) was refused with exception 3 at both units, as at the SmartLogger path. | Proven |
| ME-04 | The energy group (offset 32106, quantity 10) answered at both units. Decoded with the SUN2000MC layout, the accumulated counter is lower than the DC-input counter, and the hour, day, and accumulated counters are ordered as expected. The hybrid inverter's battery flows prevent a power cross-check. | Proven (answered); value form Hypothesis |
| ME-05 | A battery group answered at both inverter units with data: a 30-word read at offset 37000 with 10 non-zero words, a 4-word read at offset 37066 with all words non-zero, and a single read at offset 47000 with the same non-zero word at both units. The batteries are therefore visible as registers of the inverter units, not as units of their own and not as listing entries. | Proven |
| ME-06 | What the battery group's words mean, their gains and signs, and how many packs each inverter carries. No consulted document defines these offsets for this family. The operator describes two LUNA2000 packs per inverter, each with one BMS and three modules. That description is configuration, not evidence. | Unknown |

Helianthus consumes no word of the MAP0 series groups as a fact until a
consulted edition covers the family or an independent check grades the layout.
The groups stay native evidence.

### EMMA unit 0 site groups (planned)

The EMMA's own site values are the documented source of the site PV, grid, and
battery facts on this path. None of them was read in any run. The groups below
are planned reads, named from the two consulted SmartHEMS editions, which agree
on every consumed field, and they are not sent until an operator-approved
observation records their answer.

| Group | Read at unit 0 | Consumed fields in both editions | Grade |
| --- | --- | --- | --- |
| Site energy | FC03 offset 30306, quantity 46 | battery charge energy for the current day (offset 30306, U32) and in total (offset 30308, U64); battery discharge energy for the current day (offset 30312, U32) and in total (offset 30314, U64); grid export energy for the current day (offset 30330, U32) and in total (offset 30332, U64); grid import energy for the current day (offset 30336, U32) and in total (offset 30338, U64); PV energy for the current day (offset 30346, U32) and in total (offset 30348, U64); all in kWh, gain 100 | Hypothesis for the value form; whether the EMMA answers is Unknown |
| Site power | FC03 offset 30354, quantity 12 | site PV power (offset 30354, U32), site consumption power (offset 30356, U32), grid exchange power (offset 30358, I32), battery power (offset 30360, I32), and the inverters' AC power (offset 30364, I32); all in kW, gain 1000 | Hypothesis for the value form; signs Unknown |
| State of charge | FC03 offset 30368, quantity 1 | battery state of charge, U16, %, gain 100 | Hypothesis; whether the EMMA answers is Unknown |

The site power group stops before offsets 30366 and 30367, which the editions
leave undefined, so the state of charge is a separate read. The editions state
no sign for the grid exchange power or for the battery power, so both signs
are Unknown. No value is published with an assumed sign. A rated storage capacity
pair at offset 30322 (U32, kWh, gain 1000) is a candidate presence word for the
battery group (Hypothesis); it is not part of the planned reads.

### Facts on the EMMA path

| Fact | Source | Grade |
| --- | --- | --- |
| Site PV power and PV energy | site power and site energy groups, planned | Hypothesis (documentary) |
| Grid exchange power, and grid export and import energy | site groups, planned; sign of the power Unknown | Hypothesis (documentary) |
| Battery state of charge, power, and charged and discharged energy | site groups, planned; sign of the power Unknown | Hypothesis (documentary) |
| PV energy and string values per inverter | inverter groups, answered; not consumed as facts (ME-02, ME-04) | Hypothesis (no consulted edition for the family) |
| PV power per inverter | power group, refused | Unknown |
| Meter values of the backup box's meter | never read | Unknown (meter paths below) |

## S-Dongle path

### Units

The S-Dongle answers its own registers at unit 100, and its one child answers at
unit 1. The consulted S-Dongle editions state unit 100 for the dongle and units
1 through 247 for the devices behind it. The recorded stop of the
[S-Dongle observation](sdongle-observed-identity-v1.md) stays in force, so no
production read is sent until a same-class run matches the whole tuple on one
connection generation.

### Inverter groups (M1 series)

No consulted document covers this family either: its model-identifier word is
not in the SUN2000MC edition's supported-model table (Proven). Here the power
group answered, and it gave independent anchors, so the SUN2000MC layout could
be checked against the reading.

| ID | Statement | Grade |
| --- | --- | --- |
| MD-01 | The status group (offset 32000, quantity 16), the string group (offset 32016, quantity 24), the power group (offset 32064, quantity 32), and the energy group (offset 32106, quantity 10) all answered at unit 1. | Proven |
| MD-02 | Decoded with the SUN2000MC layout, the power group agrees with itself: the grid frequency lies in the nominal band; the line voltages are the phase voltages times the square root of three; the phase currents, the voltages, and the active and reactive powers agree with the power factor word; and the input power times the efficiency word equals the active power. | Proven (one reading) |
| MD-03 | The input power of the power group agrees with the string voltage times current of the string group, and the hour and day counters are ordered as expected. A single reading holds no time interval, so it does not check any energy counter against power. | Proven (power and strings, one reading); energy Hypothesis |
| MD-04 | The device status word read the code that the SUN2000MC edition assigns to grid-connected operation, and the active power was positive while producing. No other state code was observed. | Proven (observed code); its meaning for this family Hypothesis |
| MD-05 | A single read at offset 37000 and a single read at offset 47000 each answered one zero word. The operator describes no battery at the site. | Proven |
| MD-06 | The power group's last word (offset 32095) was zero. In the SUN2000MC edition that offset starts a two-register value. | Proven |

Consumed fields of the M1 series groups at unit 1:

| Fact | Read | Value form (SUN2000MC layout) | Grade |
| --- | --- | --- | --- |
| Input power | offset 32064, two words, from the power group | I32, kW, gain 1000 | Proven at the observed child (MD-02, MD-03); family-wide Hypothesis |
| Active power | offset 32080, two words | I32, kW, gain 1000; positive while producing | Proven at the observed child; the negative range Unknown |
| Device status code | offset 32089, one word | U16 code; only the observed code is published, as grid-connected operation | Hypothesis for its meaning; every other code Unknown and withheld |
| String voltage and current, string n | as on the SmartLogger path | I16, V, gain 10, and I16, A, gain 100 | Proven at the observed child (MD-03) |
| Accumulated, current-hour, and current-day energy | offsets 32106, 32112, and 32114, two words each | U32, kWh, gain 100 | Hypothesis: the counters are ordered as expected (MD-03), but no energy change was compared with power over a measured interval |

The reactive power, the grid voltages, currents, and frequency, and the
efficiency and temperature words of the power group are not consumed. They are
the anchors of the check above and are retained.

### S-Dongle unit 100 plant groups (planned)

The consulted S-Dongle editions give the dongle plant-level values, and they
agree on every consumed field. None was read in any run, and they are not sent
until an operator-approved observation records their answer.

| Group | Read at unit 100 | Consumed fields in both editions | Grade |
| --- | --- | --- | --- |
| Plant power | FC03 offset 37498, quantity 8 | plant DC input power (offset 37498, U32), plant consumption power (offset 37500, U32), grid exchange power (offset 37502, I32, positive when power is imported from the grid and negative when exported to it), and battery power (offset 37504, I32, positive when charging and negative when discharging); all in kW, gain 1000 | Hypothesis for the value form and signs; whether the dongle answers is Unknown |
| Plant AC power | FC03 offset 37516, quantity 2 | plant AC power, I32, kW, gain 1000 | Hypothesis; whether the dongle answers is Unknown |

The grid exchange sign of the dongle is the reverse of the meter sign on the EMMA
and on the inverter-exposed meter group (DN-05). The two are never mixed.

### Facts on the S-Dongle path

| Fact | Source | Grade |
| --- | --- | --- |
| PV input power, active power, strings, and PV energy | inverter groups at unit 1 (energy Hypothesis) | Proven at the observed child; family-wide Hypothesis |
| Plant DC input, consumption, grid exchange, and battery power | plant groups at unit 100, planned | Hypothesis (documentary) |
| Grid meter power and energy | never read | Unknown (meter paths below) |
| Battery state of charge and power | no battery is described; zero words only (MD-05) | Unknown; the zero words are not published as a battery value |

## Version gate: the power group

| ID | Statement | Grade |
| --- | --- | --- |
| MG-01 | The power group (FC03 offset 32064, quantity 32) was refused with exception 3 at the two M3 series units behind the SmartLogger and at the two MAP0 series units behind the EMMA, and was answered at the M1 series child behind the S-Dongle. The firmware texts of the three families differ. | Proven |
| MG-02 | The string group, which also reaches past the edition's defined offsets, answered with zero words there (MS-03), and a single read at an undefined offset answered a zero word (MS-07). So an undefined offset inside an extent does not by itself cause a refusal on the M3 series. | Proven |
| MG-03 | What causes the refusal: the extent ending inside a value, the block length, the model, or the firmware. No consulted document settles it, and no consulted document covers the MAP0 or M1 series. | Unknown |

A derived note from the SUN2000MC edition, which lists only M3 series models:
the extent from offset 32064 for 32 registers ends at offset 32095, the first
register of a two-register value. The edition states no rule for a read that
ends inside a value, and it defines exception 3 only in general terms, as a
malformed remainder of a request. That reading points at the extent and does
not settle the cause (MG-03).

Until an operator-approved observation reads a value-aligned extent, the power
group is not read on the M3 and MAP0 series, and per-inverter power on those
paths stays Unknown. The candidate extents are offset 32064 with quantity 31,
which stops before the two-register value, and offset 32064 with quantity 33,
which includes it. Both are Unknown. The M1 series child is read with the
observed extent.

## Battery rule

| ID | Statement | Grade |
| --- | --- | --- |
| MB-01 | Inverters at which the operator describes no battery answered a single read at offset 37000 and at offset 47000 with a zero word and no exception: two M3 series units and the M1 series child. Inverters with batteries described by the operator answered the same offsets, and a longer battery group, with data (ME-05). | Proven |
| MB-02 | Battery registers answer zero, not an exception, at an inverter without a battery. | Hypothesis |
| MB-03 | Which word, if any, states battery presence for the MAP0 or M1 series. No consulted document defines one for these families; on the EMMA path the rated storage capacity at unit 0 is the candidate. | Unknown |

The rule that follows is contract, not evidence. An absent battery group is
Unknown, never zero. A zero word at a battery offset is never published as a
state of charge, power, or energy of zero, and presence is never decided from
the absence of an exception. An exception on a battery read does not negate the
identified parent inverter, and the last-known-good battery values are retained
with their original age, as the
[optional-group contract](luna2000-optional-group-v1.md) states.

## Meter paths

No meter register was read on any path. Each meter value is Unknown, and the
planned reads below are not sent until a meter class contract exists, the
operator approves the observation, and the observation records the answer.

| Path | Meter | Exposure | Planned reads | Grade |
| --- | --- | --- | --- | --- |
| SmartLogger | two meters, listed at units 11 and 19; the operator declares them CHINT DTSU666 family, current-transformer wired | the meters' own routed units, as listed | at each meter unit, FC03 offset 32260, quantity 25 (voltages, currents, active power at offset 32278 as I32, kW, gain 1000, and the power factor at offset 32284 as I16, gain 1000), and FC03 offset 32335, quantity 30 (phase active powers, and three active-energy totals at offsets 32341, 32349, and 32357, each I64, kWh, gain 100, whose directions Issue 37 does not state), named from Issue 37 of the logger document (DN-03) | Unknown; value form Hypothesis; sign Unknown |
| EMMA | the backup box's own meter, per the operator; the listing names no meter (EM-29) | Unknown: the editions offer an EMMA built-in sensor group and an external sensor group at unit 0, and an external meter at its own unit | at unit 0, the built-in sensor group from FC03 offset 31639, quantity 20 (active power at offset 31657, I32, kW, gain 1000), and its energy reads at offsets 31671, 31679, and 31687, quantity 4 each (I64, kWh, gain 100); the external sensor group from offset 31895, quantity 20, with energy reads at offsets 31927, 31935, and 31943, quantity 4 each | Unknown; which group carries the backup box's meter is Unknown |
| S-Dongle | a CHINT DTSU666-family meter (H variant) on the inverter's RS-485 bus, per the operator; the child's listing names only itself | Unknown: an inverter-exposed group at unit 1, or the dongle's plant grid power at unit 100 | at unit 1, the inverter-exposed meter group from FC03 offset 37100, quantity 39, which the SUN2000MC edition defines for its own models (active power at offset 37113, I32, W, gain 1, positive when feeding the grid; active energy exported and imported at offsets 37119 and 37121, I32, kWh, gain 100); at unit 100, the plant power group above | Unknown; value form Hypothesis, because the edition does not list the M1 series |

The meter's role is configuration under the
[power-meter contract](gateway-power-meter-v1.md). An operator declaration of
make or wiring is configuration too. It identifies no meter, and every meter
stays `INSUFFICIENT_EVIDENCE` until an identity read under a meter class contract
exists. The inverter-exposed group was refused on the M3 series behind the
SmartLogger, where no meter hangs on an inverter (MS-06), so its behavior at the
S-Dongle child is Unknown. The planned quantity of 39 differs from the refused
quantity of 38 and ends on the edition's last value of the group.

## Derived notes

These notes are findings that no consulted document states in one place.

| ID | Note | Basis |
| --- | --- | --- |
| DN-01 | The SUN2000MC edition binds only the M3 series on this page. The MAP0 and M1 series carry model-identifier words that its supported-model table does not list, and none of the consulted gateway editions defines inverter registers itself: each refers to a separate SUN2000 interface definition. | MS-01, the model-identifier words of the EMMA and S-Dongle children, and the gateway editions' inverter sections |
| DN-02 | The two SmartLogger editions agree on every planned plant field. The V300R025C10 edition adds a minimum interval between query commands, which the V300R024C10SPC191 edition does not state (see the pacing contract). | both SmartLogger editions |
| DN-03 | Neither of the two SmartLogger editions above carries a power-meter register table, although their change history records the addition of power-meter registers. Issue 37 of the logger document carries such a table at the meter's own unit, so the planned meter reads are named from it. Whether the observed logger serves them is Unknown. | the change history of the two editions, and Issue 37 |
| DN-04 | Energy gains differ by source: gain 100 for the inverter counters of the SUN2000MC edition and for the EMMA site energy, and gain 10 for the logger's plant energy. A consumer never applies one source's gain to another source's words. | the three documents |
| DN-05 | Grid signs differ by source: the S-Dongle plant grid exchange power is positive when power is imported from the grid, while the EMMA's external-meter note and the SUN2000MC inverter-exposed meter group use positive for power exported to the grid. The EMMA site grid exchange and battery powers, the logger plant AC power, and the inverter active power carry no stated sign. | the S-Dongle, SmartHEMS, and SUN2000MC documents |
| DN-06 | The EMMA unit 0 groups, their types, units, and gains, are the same in the two SmartHEMS editions, and the S-Dongle plant group is the same in the two S-Dongle editions. A planned read on either path is therefore not tied to one of the two editions. | the paired editions |
| DN-07 | The two LUNA2000 port definitions cover commercial and utility-scale storage systems in their model tables, not the residential packs that the operator describes behind the EMMA. No battery field on this page rests on them. | both LUNA2000 documents |

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| SUN2000MC V200R023C00 Modbus Interface Definitions | Issue 01 | 2023-03-17 | the M3 series inverter groups and consumed fields, the derived note on the power-group extent, MG-02, the inverter-exposed meter group, the battery word at offset 37000, and DN-01, DN-04, and DN-05 |
| SmartLogger V300R024C10SPC191 ModBus Interface Definitions | Issue 52 | 2025-06-06 | the logger plant groups, the logger's own unit, and DN-02 to DN-04 |
| SmartLogger V300R025C10 ModBus Interface Definitions | Issue 01 | 2025-12-22 | the logger plant groups, the logger's own unit, and DN-02 and DN-03 |
| SmartLogger ModBus Interface Definitions | Issue 37 | 2020-06-24 | the planned meter reads at the SmartLogger meter units, and DN-03 |
| SmartHEMS V100R024C00 MODBUS Interface Definitions | Issue 01 | 2024-07-15 | the EMMA unit 0 site groups, the sensor groups, the EMMA addressing, and DN-01, DN-04 to DN-06 |
| SmartHEMS V100R025C00SPC102 MODBUS Interface Definitions | Issue V100R025C00SPC102 | 2025-08-14 | the EMMA unit 0 site groups, the sensor groups, the external-meter sign note, the EMMA addressing, and DN-01, DN-04 to DN-06 |
| SDongle V200R025C00SPC120 MODBUS Interface Definitions | Issue 01 | 2025-12-23 | the S-Dongle plant groups and their signs, the dongle addressing, and DN-05 and DN-06 |
| SDongle V200R022CC10 MODBUS Interface Definitions | Issue 02 | 2023-04-20 | the S-Dongle plant groups and their signs, and DN-06 |
| LUNA2000B V200R024C00SPC410 Modbus Port Definitions | Issue 01 | 2026-01-24 | DN-07 only |
| LUNA2000C ESS Modbus Port Definitions | Issue 01 | 2023-06-13 | DN-07 only |

The observations that grade these facts are the runs described in the scope
section. No value, table, label, or text of the documents is reproduced here.

**Copyright note.** The information on this page that is derived from the
SUN2000MC, SmartLogger, and LUNA2000 documents listed above is attributed to
Huawei Technologies Co., Ltd., which retains the copyright in those documents.
This page states that information in its own words and does not reproduce the
documents. The CC0-1.0 dedication of this page covers its own expression only
and does not relicense those documents.

**Copyright note.** The information on this page that is derived from the
SmartHEMS and SDongle documents listed above is attributed to Huawei Digital
Power Technologies Co., Ltd., which retains the copyright in those documents.
This page states that information in its own words and does not reproduce the
documents. The CC0-1.0 dedication of this page covers its own expression only
and does not relicense those documents.

## Open questions

1. What causes the refusal of the power group on the M3 and MAP0 series (MG-03),
   and does a value-aligned extent answer there?
2. Which document covers the MAP0 and M1 series inverter groups and their
   battery group (DN-01, ME-06)? Until one is consulted, those layouts
   stay a cross-family hypothesis, even where a reading agreed with them.
3. Do the planned logger, EMMA, and S-Dongle plant groups answer on the observed
   gateways, and do their values agree with the inverter groups?
4. What do the EMMA site grid exchange and battery powers use as sign (DN-05)?
5. Which group carries the backup box's meter on the EMMA path, and does any
   meter unit answer a read at all?
6. How do the groups behave at a second operating point, in standby or at night?
   Every monitoring read was taken once, in daylight.
7. Do the energy counters roll over or reset, and when does the current-day
   counter restart?
