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
request in flight, and no write. A second run per path read the meter groups,
under the same discipline (see the meter paths below). The identity runs behind
each path are recorded on the
[SmartLogger observation](smartlogger-observed-inventory-v1.md), the
[EMMA observation](emma-observed-identity-v1.md), and the
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
A row marked Proven (answered) grades only that a group returned data, or an
exception, at a unit; the grade of its value form is stated beside it. Grades
are separate from admission, qualification, and support.

Inverter families are named by product series. The model token of the
SmartLogger children is published on the
[SUN2000 identity contract](sun2000-observed-identity-v1.md); the exact model
tokens of the EMMA and S-Dongle children stay withheld, as on their observation
pages.

| Path | Inverter family | Inverter units read | Monitoring run | Meter run |
| --- | --- | --- | --- | --- |
| SmartLogger | SUN2000 M3 series, commercial three-phase | 1 and 2 of the eight listed | 76 requests, 59 answered with data, 17 exceptions, no timeout | 8 meter-group reads at units 11 and 19: 4 answered with data, 4 exceptions, no timeout |
| EMMA | SUN2000 MAP0 series, residential three-phase hybrid | 3 and 4, both listed | 46 requests, 37 answered with data, 9 exceptions, no timeout | 7 reads at unit 0: 7 answered with data, no exception, no timeout |
| S-Dongle | SUN2000 M1 series, residential three-phase hybrid | 1, the one child | 31 requests, 25 answered with data, 2 exceptions, 4 timeouts at unit 0 | 4 meter-group reads at unit 1: 4 answered with data, no exception; the first request of the connection went unanswered once and its repeat answered |

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
   retained. Exception 3 to a group that another family answers, or that an
   edition of the same family defines, is a refused group, not an absent device:
   the unit stays identified, and the group is not sent again until a revision
   of this page (see the version gates below).
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
contract, so no monitoring read is sent to units 9, 11, or 19. The one meter
run read units 11 and 19 under the operator's approval as an observation, not as
production (see the meter paths below).

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
| MS-06 | The inverter-exposed meter group (offset 37100, quantity 38) was refused with exception 3 at both units. The site's meters are listed by the logger as its own children and are not attached to an inverter, which is consistent with the refusal. The same offsets answered as four smaller reads at the M1 series child behind the S-Dongle (MM-16); the families, the software, and the extents differ, so the pair does not settle the cause. | Proven (refusal); cause Hypothesis |
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
| Grid or meter power and energy | AC and energy groups at meter units 11 and 19, answered once (MM-01) | Hypothesis for the value form, withheld while no meter class contract exists; the sign is Unknown (meter paths below) |
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

### EMMA unit 0 site groups

The EMMA's own site values are the documented source of the site PV, grid, and
battery facts on this path. Two reads of the meter run touched these groups: the
site power group was read as listed, and a part of the site energy group was read
as a shorter group of its own (MM-09). The groups below are named from the two
consulted SmartHEMS editions, which agree on every consumed field. A group not
yet read is a planned read, and it is not sent until an operator-approved
observation records its answer.

| Group | Read at unit 0 | Consumed fields in both editions | Grade |
| --- | --- | --- | --- |
| Site energy | FC03 offset 30306, quantity 46 | battery charge energy for the current day (offset 30306, U32) and in total (offset 30308, U64); battery discharge energy for the current day (offset 30312, U32) and in total (offset 30314, U64); grid export energy for the current day (offset 30330, U32) and in total (offset 30332, U64); grid import energy for the current day (offset 30336, U32) and in total (offset 30338, U64); PV energy for the current day (offset 30346, U32) and in total (offset 30348, U64); all in kWh, gain 100 | Hypothesis for the value form; whether the EMMA answers the group as listed is Unknown; its consumption and grid part, read at offset 30324 with quantity 18, answered (MM-09) |
| Site power | FC03 offset 30354, quantity 12 | site PV power (offset 30354, U32), site consumption power (offset 30356, U32), grid exchange power (offset 30358, I32), battery power (offset 30360, I32), and the inverters' AC power (offset 30364, I32); all in kW, gain 1000 | Hypothesis for the value form; signs Unknown; answered with data at unit 0 (MM-09) |
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
| Site PV power and PV energy | site power group, answered once (MM-09); site energy group, planned | Hypothesis (documentary) |
| Grid exchange power, and grid export and import energy | site power group and the consumption and grid energy part of the site energy group, answered once (MM-09); sign of the power Unknown | Hypothesis (documentary) |
| Battery state of charge, power, and charged and discharged energy | battery power in the site power group, answered once; the other fields in planned groups; sign of the power Unknown | Hypothesis (documentary) |
| PV energy and string values per inverter | inverter groups, answered; not consumed as facts (ME-02, ME-04) | Hypothesis (no consulted edition for the family) |
| PV power per inverter | power group, refused | Unknown |
| Built-in sensor values, which the operator attributes to the backup box's meter | built-in sensor groups at unit 0, answered once (MM-09) | Hypothesis for the value form, withheld while no meter class contract exists; the meter identity is Hypothesis (MM-12), the sign Unknown (meter paths below) |

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
| Grid meter power and energy | inverter-side meter groups at unit 1, answered once (MM-16) | Hypothesis for the value form, a cross-family layout, withheld while no meter class contract exists; the status and type words Unknown (meter paths below) |
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

## Version gate: the SmartLogger meter groups

| ID | Statement | Grade |
| --- | --- | --- |
| MG-04 | At the two meter units behind the SmartLogger, the AC group (FC03 offset 32260, quantity 33) and the energy group (offset 32335, quantity 30) answered with data, and the meter-number group (offset 32293, quantity 6) and the configuration group (offset 33000, quantity 7) were refused with exception 3. The logger reports the software recorded in SL-04. | Proven |
| MG-05 | The consulted issues 32, 36, 37, 49, 53, and 54 define the answered groups. Only issues 49, 53, and 54, all issued for the V300R024C10 line, define the refused groups (DN-08). The observed pattern fits a gate on the logger's software, in which the meter-number and configuration groups belong to the V300R024C10 line. | Hypothesis |
| MG-06 | The logger answers two groups that issues 52 and 01 do not define. An edition's silence on a group therefore does not predict a refusal. | Proven (answered) |
| MG-07 | What causes the refusal of the meter-number and configuration groups: the logger's software, the meter model or its configuration, or the meter link. No consulted issue is issued for the logger's software, and one run at one logger cannot separate the candidates. | Unknown |

A derived note from the eight consulted SmartLogger issues (DN-08): the meter
section of issues 32, 36, and 37 has no meter-number group and no configuration
group, issues 49, 53, and 54 add both and a sign rule for the meter's power, and
issues 52 and 01 carry no meter section. The
system-requirements lists of issues 32, 36, 37, 49, 53, and 54 name a minimum
software for the logger family and state nothing for any group, so they do not
settle whether the observed logger serves a group.

Until an operator-approved observation reads the meter-number and configuration
groups at this logger's software with a different result, they are not sent to a
meter unit on this logger, and the transformer ratio and the meter number stay
Unknown. A logger at a different software branch is a different exact tuple, and
this gate is no claim about it.

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

One further run per path read the meter groups: at the two meter units behind the
SmartLogger, at the EMMA's own unit, and at the S-Dongle's child. Each run issued
FC03 reads only, on one connection with one request in flight and no write, in
daylight at one operating point, as the monitoring runs did. Each group is named
by purpose from the consulted editions and given as the offset and quantity that
Helianthus reads. The words inside a group are tabulated only where Helianthus
consumes them.

Proven (answered) in this section grades one fact: the group returned data, or an
exception, at that unit in the run. The value form of every word, which is its
meaning, type, gain, unit, and sign per the editions, is Hypothesis. No word of
a meter group was decoded against an independent check: the private record holds
word counts only, and no reference reading of any meter, such as its display or a
second meter, was taken. The operator's description of a meter is configuration
under the [power-meter contract](gateway-power-meter-v1.md). It identifies no
meter, and every meter stays `INSUFFICIENT_EVIDENCE` until an identity read under
a meter class contract exists. The meter-unit and sensor groups below are not
named in the cycle order of the [pacing contract](read-pacing-v1.md), and a meter
unit is sent no production read while it has no class contract. Adding one of
them to a production cycle is a revision of both pages.

| Path | Meter, per the operator | Exposure observed | Answered with data | Refused | Grade |
| --- | --- | --- | --- | --- | --- |
| SmartLogger | two CHINT DTSU666-family meters, current-transformer wired | the meters' own routed units 11 and 19 | the AC group and the energy group | the meter-number group and the configuration group | Proven (answered); value form Hypothesis; sign Unknown |
| EMMA | the backup box's own built-in meter; no CHINT meter at this site | the EMMA's own unit 0, the gateway level; the listing names no meter | the built-in sensor groups, the site power group, and the grid and consumption energy group | none | Proven (answered); meter identity Hypothesis; value form Hypothesis; sign Unknown |
| S-Dongle | a CHINT DTSU666-family meter on the inverter's RS-485 bus | the child inverter's unit 1; the child's listing names only itself | the meter status word, the AC group, the meter type word, and the lines group | none | Proven (answered); value form Hypothesis; status and type words Unknown |

### SmartLogger meter units

The reads went to units 11 and 19, the routed units that key 5 gives for the two
`PowerMeter` entries of the listing (PM-01). The run read the listing again
first and found the same inverters, PLC, and meters, and its change-counter
reads before and after the meter reads returned the value of the earlier passes
(SL-02).

| Group | Read at each meter unit | What the consulted editions define there |
| --- | --- | --- |
| AC | FC03 offset 32260, quantity 33 | the meter's phase and line voltages, phase currents, active, reactive, and apparent power, power factor, and reserved energy words; the group ends where the meter-number group begins |
| Meter number | FC03 offset 32293, quantity 6 | the meter's number, which is serial-bearing and never published |
| Energy | FC03 offset 32335, quantity 30 | the three phase active powers, then the total, negative, and positive active energy counters and the matching reactive counters |
| Configuration | FC03 offset 33000, quantity 7 | the meter link settings, the voltage and current transformer ratios, and the meter usage setting; the editions define these as read-write, and Helianthus only reads |

| ID | Statement | Grade |
| --- | --- | --- |
| MM-01 | The AC group and the energy group answered with data at both meter units on the first attempt. Non-zero words: 18 of 33 at each unit in the AC group, and 17 and 16 of 30 in the energy group. | Proven (answered); value form Hypothesis |
| MM-02 | The meter-number group and the configuration group were refused with exception 3 at both units on the first attempt. The units stay listed and answering, so the refusal is not an absent device (rule 5), and the two groups are not sent again at this logger's software until a revision of this page (MG-04). | Proven |
| MM-03 | The two units answer different words in both answered groups, so neither unit is an alias of the other. | Proven |
| MM-04 | The meters answer at their own routed units, as the listing gives them. Whether the logger also serves them at its unit 0 was not read. | Proven (routed units); unit 0 Unknown |
| MM-05 | The type, gain, unit, and sign of the answered words, as the consumed-fields table below gives them from the editions that define them. | Hypothesis |
| MM-06 | The sign of the meter's power words. Issues 49, 53, and 54 state that a positive value is power fed to the grid and a negative value is power supplied from it, and issues 32, 36, and 37 state no sign. No reading was correlated with a direction of flow, and no consulted issue is issued for the observed logger's software (MG-07). | Hypothesis where an issue states it; Unknown for the observed logger |
| MM-07 | Which of the three active energy counters is import and which is export. The editions name them total, negative, and positive and state no direction. | Unknown |
| MM-08 | The meters' make, model, and firmware, the current-transformer ratio, and the meter number. The operator declares the family and the wiring. The ratio and the number sit in the two refused groups, and no word of an answered group identifies a make or a model. | Unknown; the declaration is configuration |

### EMMA unit 0 groups

Seven reads went to the EMMA's own unit 0. The backup-box entry at unit 2 was
never read, and the EMMA's listing names no meter (PM-10 of the power-meter
contract).

| Group | Read at unit 0 | What the consulted editions define there |
| --- | --- | --- |
| Built-in sensor, voltages, currents, and active power | FC03 offset 31639, quantity 20 | the built-in sensor's phase and line voltages, phase currents, and active power |
| Built-in sensor, power factor and phase powers | FC03 offset 31661, quantity 10 | its power factor, apparent power, and the three phase active powers |
| Built-in sensor, energy counters | FC03 offsets 31671, 31679, and 31687, quantity 4 each | its total, total negative, and total positive active energy counters, one read each because the editions leave four words undefined between them |
| Site power | FC03 offset 30354, quantity 12 | the site's PV, load, feed-in, and battery powers and the inverters' rated and active power |
| Grid and consumption energy | FC03 offset 30324, quantity 18 | the site's energy consumption, grid feed-in energy, and energy supplied from the grid, each for the current day and in total |

| ID | Statement | Grade |
| --- | --- | --- |
| MM-09 | All seven reads answered with data at unit 0 on the first attempt. Non-zero words: 10 of 20, 6 of 10, 4 of 4, 2 of 4, 1 of 4, 6 of 12, and 8 of 18, in the order of the table. | Proven (answered); value form Hypothesis |
| MM-10 | Both consulted SmartHEMS editions define all seven groups at these offsets with the same types and gains for every consumed field (DN-06), and no read was refused. No version gate was found on this path. | Proven (no refusal) |
| MM-11 | The EMMA serves these groups at its own unit 0, the gateway level. Its listing names no meter and the backup-box entry was never read, so no meter unit was addressed. | Proven (answered at unit 0) |
| MM-12 | The built-in sensor groups carry the meter in use at this site. The operator names the backup box's own built-in meter as the meter in use and describes no CHINT meter here, and the editions say that the EMMA's built-in registers serve a built-in meter (DN-11). No word identifies the meter or ties the sensor to the backup box. | Hypothesis for the meter identity; Proven (answered) for the groups |
| MM-13 | The external sensor group at unit 0 (from offset 31895) and the external-meter registers at a meter's own logical unit (from offset 30500) were not read, and the operator describes no external meter. | Unknown |
| MM-14 | The sign of the built-in sensor's power words and of the feed-in power in the site power group. The editions state a sign only in the note to their external-meter section (DN-11). | Unknown |
| MM-15 | Which of the three built-in energy counters is import and which is export. The editions name them total, negative, and positive and state no direction. The names of the feed-in and supply energies in the grid and consumption energy group state a direction. | Unknown for the built-in counters; Hypothesis (documentary) for the grid energies |

### S-Dongle child unit 1 groups

Four reads went to the child, unit 1, after the child's model read, which was the
first request of the connection.

| Group | Read at unit 1 | What the SUN2000MC edition defines there |
| --- | --- | --- |
| Meter status | FC03 offset 37100, quantity 1 | the meter status word, an enumeration |
| AC | FC03 offset 37101, quantity 24 | the meter's phase voltages, phase currents, active and reactive power, power factor, grid frequency, the energy fed to the grid and absorbed from it, and the accumulated reactive energy |
| Meter type | FC03 offset 37125, quantity 1 | the meter type word, an enumeration |
| Lines | FC03 offset 37126, quantity 13 | the line voltages, the three phase active powers, and the meter model check word |

| ID | Statement | Grade |
| --- | --- | --- |
| MM-16 | All four reads answered with data at unit 1. Non-zero words: 1 of 1, 15 of 24, 1 of 1, and 8 of 13. The four groups tile offsets 37100 through 37138 with no gap and no overlap. | Proven (answered); value form Hypothesis |
| MM-17 | The child's model read, the first request of the connection, went unanswered once and its repeat was answered, as on the pacing contract's PD-01. The four meter reads each answered on the first attempt. | Proven |
| MM-18 | The meter status word and the meter type word are non-zero. The edition gives both as enumerations and lists no value for either (DN-10), so what the two words say is not decoded, and no word identifies a make or a model. | Unknown |
| MM-19 | The meter groups are served by the child inverter at unit 1, not as a listing entry: the child's listing names only itself (SD-23, SD-27). The dongle's plant grid power at unit 100 is a planned read and was not read, so whether it comes from the same meter is Unknown. | Proven (answered at unit 1); unit 100 Unknown |
| MM-20 | The meter on the inverter's RS-485 bus is a CHINT DTSU666-family meter, per the operator. The answers fit an attached meter, and no word establishes it. | Unknown; the declaration is configuration |
| MM-21 | The SUN2000MC edition lists only M3 series models (DN-01), so its meter groups apply to the M1 series child as a cross-family hypothesis. Whether the whole area answers as one read, such as the 38 words refused at the M3 series units (MS-06) or the 39 words to the check word, was not tried. | Hypothesis (layout); Unknown (single read) |
| MM-22 | The edition states that a positive active power word is power fed to the grid and a negative one is power obtained from it, and it describes the two energy counters as energy fed to the grid and energy absorbed from it. No reading was correlated with a flow. | Hypothesis (documentary, cross-family) |

### Consumed fields of the meter groups

Helianthus consumes the following words and retains every other word of a meter
group as native evidence. Each cell gives the offsets, the type, the unit, and the
gain that the consulted editions state.

| Fact | SmartLogger meter unit | EMMA unit 0, built-in sensor | S-Dongle child, unit 1 |
| --- | --- | --- | --- |
| Phase voltages | 32260, 32262, 32264: U32, V, gain 100 | 31639, 31641, 31643: U32, V, gain 100 | 37101, 37103, 37105: I32, V, gain 10 |
| Phase currents | 32272, 32274, 32276: I32, A, gain 10 | 31651, 31653, 31655: I32, A, gain 10 | 37107, 37109, 37111: I32, A, gain 100 |
| Active power | 32278: I32, kW, gain 1000 | 31657: I32, kW, gain 1000 | 37113: I32, W, gain 1 |
| Power factor | 32284: I16, gain 1000 | 31661: I32, gain 1000 | 37117: I16, gain 1000 |
| Phase active powers | 32335, 32337, 32339: I32, kW, gain 1000 | 31665, 31667, 31669: I32, kW, gain 1000 | 37132, 37134, 37136: I32, W, gain 1 |
| Active energy counters | 32341 total, 32349 negative, 32357 positive: I64, kWh, gain 100 | 31671 total, 31679 negative, 31687 positive: I64, kWh, gain 100 | 37119 fed to the grid, 37121 absorbed from the grid: I32, kWh, gain 100 |

Every cell is Hypothesis: it is a document's value form for a word that answered
(MM-05, MM-09, MM-16), with no reference reading. At the S-Dongle child the
layout is also a cross-family hypothesis (MM-21). The status word at offset 37100
and the type word at offset 37125 are retained and not consumed (MM-18).

On the EMMA path the site groups add these consumed fields, all Hypothesis for
the value form: the grid exchange power at offset 30358 (I32, kW, gain 1000, sign
Unknown), and, from the grid and consumption energy group, the consumption energy
for the current day (offset 30324, U32) and in total (offset 30326, U64), the grid
feed-in energy for the current day (offset 30330, U32) and in total (offset 30332,
U64), and the energy supplied from the grid for the current day (offset 30336,
U32) and in total (offset 30338, U64), all in kWh, gain 100.

Energy counters are published as read (rule 8). No meter power is published with
an assumed sign (MM-06, MM-14, MM-22), and the grid signs of different sources
are never mixed (DN-05).

## Derived notes

These notes are findings that no consulted document states in one place.

| ID | Note | Basis |
| --- | --- | --- |
| DN-01 | The SUN2000MC edition binds only the M3 series on this page. The MAP0 and M1 series carry model-identifier words that its supported-model table does not list, and none of the consulted gateway editions defines inverter registers itself: each refers to a separate SUN2000 interface definition. | MS-01, the model-identifier words of the EMMA and S-Dongle children, and the gateway editions' inverter sections |
| DN-02 | The two SmartLogger editions agree on every planned plant field. The V300R025C10 edition adds a minimum interval between query commands, which the V300R024C10SPC191 edition does not state (see the pacing contract). | both SmartLogger editions |
| DN-03 | Neither of the two SmartLogger editions above carries a power-meter register table, although their change history records the addition of power-meter registers. Issue 37 of the logger document carries such a table at the meter's own unit, and the meter reads are named from it and from the other issues that define the same groups (DN-08). The observed logger serves the AC and energy groups and refuses the other two (MG-04). | the change history of the two editions, and Issue 37 |
| DN-04 | Energy gains differ by source: gain 100 for the inverter counters of the SUN2000MC edition and for the EMMA site energy, and gain 10 for the logger's plant energy. The meter energy counters carry gain 100 in all three sources. A consumer never applies one source's gain to another source's words. | the three documents |
| DN-05 | Grid signs differ by source: the S-Dongle plant grid exchange power is positive when power is imported from the grid, while the EMMA's external-meter note, the meter note of SmartLogger issues 49, 53, and 54, and the SUN2000MC inverter-exposed meter group use positive for power exported to the grid. The EMMA site grid exchange and battery powers, the EMMA built-in sensor powers, the logger plant AC power, and the inverter active power carry no stated sign. | the S-Dongle, SmartHEMS, SmartLogger, and SUN2000MC documents |
| DN-06 | The EMMA unit 0 groups, their types, units, and gains, are the same in the two SmartHEMS editions, including the built-in sensor groups, the site power group, and the grid and consumption energy group that the meter run read, and the S-Dongle plant group is the same in the two S-Dongle editions. A read on either path is therefore not tied to one of the two editions. | the paired editions |
| DN-07 | The two LUNA2000 port definitions cover commercial and utility-scale storage systems in their model tables, not the residential packs that the operator describes behind the EMMA. No battery field on this page rests on them. | both LUNA2000 documents |
| DN-08 | The meter section differs across the eight consulted SmartLogger issues. Issues 32, 36, and 37 define the meter's voltage, current, power, and energy fields, with no meter-number group and no configuration group. Issues 49, 53, and 54 define the same fields and add both groups and a sign rule for the meter's power. Issues 52 and 01 carry no meter section. The system-requirements lists name a minimum software for the logger family and nothing per group. | the eight SmartLogger issues |
| DN-09 | Every meter group read in the meter run starts at an offset that its defining editions define, ends on a value boundary, and spans no offset they leave undefined, so shared rule 4 holds for it. The SmartLogger AC group ends with the last two-word value before offset 32293, and its energy group ends on the last reactive energy counter. The two EMMA built-in sensor reads before the energy counters leave out the two undefined words after the active power, and the three energy counters are three reads because four undefined words lie between each pair. The four S-Dongle groups tile offsets 37100 through 37138. | the SmartLogger, SmartHEMS, and SUN2000MC documents |
| DN-10 | The SUN2000MC edition gives the meter status word, the meter type word, and the meter model check word as 16-bit enumerations and lists no value for any of them at its rows. A non-zero answer therefore carries no documented meaning. The edition also defines read-write meter model, address, and name settings, which were not read. | the SUN2000MC document |
| DN-11 | Both SmartHEMS editions say, in the note to their external-meter section, that the EMMA's built-in registers are used when a built-in meter is used, and they state the sign rule (positive when power is fed to the grid) only in that note. They state no sign for the built-in sensor groups. | both SmartHEMS documents |

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| SUN2000MC V200R023C00 Modbus Interface Definitions | Issue 01 | 2023-03-17 | the M3 series inverter groups and consumed fields, the derived note on the power-group extent, MG-02, the inverter-exposed meter groups at the S-Dongle child and their consumed fields, the battery word at offset 37000, and DN-01, DN-04, DN-05, DN-09, and DN-10 |
| SmartLogger V300R024C10SPC191 ModBus Interface Definitions | Issue 52 | 2025-06-06 | the logger plant groups, the logger's own unit, MG-06, and DN-02 to DN-04 and DN-08 |
| SmartLogger V300R025C10 ModBus Interface Definitions | Issue 01 | 2025-12-22 | the logger plant groups, the logger's own unit, MG-06, and DN-02, DN-03, and DN-08 |
| SmartLogger ModBus Interface Definitions | Issue 37 | 2020-06-24 | the meter groups at the SmartLogger meter units and their consumed fields, MG-05, and DN-03, DN-08, and DN-09 |
| SmartLogger ModBus Interface Definitions | Issue 32 | 2018-11-15 | the meter groups at the SmartLogger meter units, MG-05, and DN-08 |
| SmartLogger ModBus Interface Definitions | Issue 36 | 2020-04-13 | the meter groups at the SmartLogger meter units, MG-05, and DN-08 |
| SmartLogger V300R024C10SPC210 ModBus Interface Definitions | Issue 49 | 2025-03-19 | the meter-number and configuration groups, the meter sign note, MG-05, and DN-05, DN-08, and DN-09 |
| SmartLogger V300R024C10 ModBus Interface Definitions | Issue 53 | 2025-10-29 | the meter-number and configuration groups, the meter sign note, MG-05, and DN-05, DN-08, and DN-09 |
| SmartLogger V300R024C10 ModBus Interface Definitions | Issue 54 | 2026-02-06 | the meter-number and configuration groups, the meter sign note, MG-05, and DN-05, DN-08, and DN-09 |
| SmartHEMS V100R024C00 MODBUS Interface Definitions | Issue 01 | 2024-07-15 | the EMMA unit 0 site groups, the sensor groups, the built-in sensor groups and the grid groups of the meter run, the EMMA addressing, and DN-01, DN-04 to DN-06, DN-09, and DN-11 |
| SmartHEMS V100R025C00SPC102 MODBUS Interface Definitions | Issue V100R025C00SPC102 | 2025-08-14 | the EMMA unit 0 site groups, the sensor groups, the built-in sensor groups and the grid groups of the meter run, the external-meter sign note, the EMMA addressing, and DN-01, DN-04 to DN-06, DN-09, and DN-11 |
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
3. Do the planned logger and S-Dongle plant groups, and the EMMA site energy
   group as listed and its state of charge, answer on the observed gateways, and
   do their values agree with the inverter groups?
4. What do the EMMA site grid exchange and battery powers use as sign (DN-05)?
5. Do the built-in sensor groups at the EMMA's unit 0 carry the backup box's own
   meter, as the operator states and the editions' note suggests (MM-12), and
   does the external sensor group answer at a site that has an external meter
   (MM-13)?
6. How do the groups, the meter groups among them, behave at a second operating
   point, in standby or at night? Every monitoring read was taken once, in
   daylight.
7. Do the energy counters roll over or reset, and when does the current-day
   counter restart?
8. What is the sign of the meter powers on each path, and which of the active
   energy counters is import and which is export (MM-06, MM-07, MM-14, MM-15,
   MM-22)? Both need a time-aligned reference reading of the meter.
9. Which word, if any, identifies the meter make or model on each path: the
   S-Dongle child's status and type words (MM-18), the meter model, address, and
   name settings that the SUN2000MC edition defines (DN-10), or a word at the
   SmartLogger or EMMA paths? Are the SmartLogger's two meters the same model
   (MM-08)?
10. What are the transformer ratios and the meter number of the SmartLogger's
    meters, which sit in the refused groups (MM-08), and does any other software
    branch or reader expose them?
11. What causes the SmartLogger's refusal of the meter-number and configuration
    groups (MG-07), and what does the observed logger's software define for
    meters beyond the two groups that answered?
12. Does the whole inverter-side meter area answer as one read at the S-Dongle
    child, and do the four smaller groups answer at the M3 series units
    (MM-21)?
13. Which reads are still missing: the EMMA's backup box at unit 2, the PLC at
    unit 9, the S-Dongle's plant grid power at unit 100, and the meter values at
    the SmartLogger's unit 0 (MM-04, MM-19)?
