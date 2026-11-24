# Growatt Protocol II Read-Only Candidate V1

## Scope

This profile defines a caller-selected native Growatt Modbus RTU Protocol II
v1.24 TL3-X capability for MAX, MID, and MAC families using holding and input
ranges 0 through 249. It is a native Growatt map, not SunSpec. Automatic
cross-family detection is not part of this contract; a caller supplies the
exact family and version selection.

## Transport and addressing

The candidate uses Modbus RTU with addressed units 1 through 254. Unit 0 is
broadcast and is forbidden for read operations. Each register is one 16-bit
word. Requests use FC03 for holding registers and FC04 for input registers.
FC06 and FC16 are outside this read-only profile.

Register addresses are zero-based PDU offsets. Register and multi-register
numeric values are big-endian. ASCII fields preserve exact register extent and
remove only terminal NUL or space padding.

## Identity tuple

An offline candidate fixture must contain one coherent FC03 snapshot with:

- offsets 9 through 14, six words, for primary and control firmware text;
- offsets 23 through 27, five words, for native serial text;
- offset 43, one word, for the device type code;
- offsets 82 and 83, two words, for the model-letter build tuple; and
- offset 88, one word, for the Modbus protocol version.

Manufacturer text, unit readability, one firmware field, or register range
alone is insufficient.

The FC03 observation is raw native candidate evidence. It accepts only a
fixture declared as Protocol II v1.24 TL3-X MAX/MID/MAC whose FC03 fields agree
with the caller-selected identity profile. It does not itself admit typed FC04
telemetry. Unknown device type, malformed ASCII, a protocol value outside the
selected schema, or disagreement among identity fields remains
`insufficient_evidence` for typed monitoring.

The bounded result of automatic matching is `NO_ADMISSIBLE_PROFILE`: there is no exact tuple and no typed field while the edition publishes no numeric device-type and version map. There is no current publicly admitted typed FC04 profile. The exported opaque
applicability value has no public successful constructor; its zero value and all
externally constructible forms fail closed. Only an unexported synthetic
in-package fixture helper may exercise the source-backed FC04 schema and
mechanics. That helper cannot establish real-build qualification. The inspected
manual identifies the TL3-X MAX/MID/MAC family and register range, but does not
publish a device-type, model-build, and protocol-value mapping. It therefore
provides no built-in allowlist here, and its revision `1.24` is not treated as a
device-reported protocol-register value. Before enabling public typed admission,
an owning source must establish one exact device-type, model-build, and
protocol-value tuple tied to the FC04 schema.

## Native identity capability

A qualified runtime identity contains the selected family, unicast unit,
normalized firmware text, native serial text, device type code, the two-word
model-build pair, Modbus protocol version, and the five exact FC03 identity
slices in their declared order. Each field comes from the exact identity tuple
above; it is not inferred from a related Growatt family.

The runtime API may carry its configured endpoint and transport context with
this native observation. Public documentation and fixtures use synthetic
identity values and do not publish installation-specific identifiers, captures,
or endpoint coordinates. A failed tuple gate produces no partial identity
projection.

## Native identity projection

A qualified identity result returns the selected family, unicast
unit, normalized firmware text, native serial text, device type code,
model-build pair, protocol version, and the five exact FC03 identity slices as
`native_identity` without a redaction marker or a substitute digest. Each field
retains its native tuple position and is not inferred from a related Growatt
family, unit, or firmware selection.

An incomplete, conflicting, or unsupported identity tuple produces no partial
identity projection. The identity projection does not authorize an FC06, FC16,
or other write.

The currently enumerated operation is FC03 identity acquisition. This contract
does not define an FC06 or FC16 control operation, so no control command is
constructed from it. A later exact operation contract may add command
construction and fake execution without making a real-device write automatic.

## FC04 monitoring foundation

Because no automatic FC04 profile is admitted, the public FC04 decoder and observer
fail closed and create no typed telemetry or observer. The live FC04 record uses offset 0 and width_words=250 for words 0 through 249, acquired through FC04 0/125 and 125/125 in address order. An explicit endpoint and family selection of a documented TL3-X MAX, MID, or MAC family activates that configured profile, and the same evidence without a selection gives no automatic match. Word 113 keeps the MAX real power percent and the Storage Power daily AC-charge energy low word, and the raw observation is retained when the device qualifier is absent, inapplicable, or matches more than one interpretation. Word 125 keeps the PID and MAX HV Flyspan alternatives, and the raw observation is retained when the device qualifier is absent, inapplicable, or matches more than one interpretation. Word 939 is a source-table fact only and the live FC04 record is exactly two blocks. For n = 1 through 8 only, PV input n uses unsigned word 3 + 4(n-1) for voltage, unsigned word 4 + 4(n-1) for current, and the unsigned high/low pair starting at 5 + 4(n-1) for power. Holding register 43 is the device-type field and holding register 88 is the reported protocol-version field. The manufacturer uses 207 as an example of reported V2.07. Edition v1.24 is the document revision. The identified edition gives no numeric device-type and version map to that family schema, and that gap stays named. Words 35 through 38 keep their native AC and grid meanings and never serve as PV9. Temperature word 93 is the inverter temperature at 0.1 degrees Celsius. PV9 words 875 through 878 are source-only outside the 250-word live record. The unexported synthetic
fixture exercises exactly one input-register slice: zero-based offsets 0 through 58 inclusive (59 words). It is an all-or-nothing fixture decode: wrong function,
offset, word count, table/provenance, timeout, Modbus exception, missing
admission, identity/applicability mismatch, malformed response, or an unlisted
inverter-state value yields no typed record. The frozen 0 through 58 fixture remains historical evidence and supplies no current admissible record width. Its retained words stay
native raw evidence where the owning runtime contract permits retention; no
unlisted word is typed by this document.

Multiword values below are unsigned 32-bit integers, high word first. The
manual does not state a sentinel for these rows, so this contract invents none.

| Offset(s) | Native fact | Width and scale | Typed result |
| --- | --- | --- | --- |
| 0 | inverter run state | one unsigned word; only 0, 1, 3 | waiting, normal, fault |
| 1-2 | aggregate PV input power | unsigned 32-bit, high word first, 0.1 W | watts |
| 35-36 | aggregate output power | unsigned 32-bit, high word first, 0.1 W | watts |
| 37 | grid frequency | one unsigned word, 0.01 Hz | hertz |
| 38, 39 | phase 1 grid voltage and output current | one unsigned word each, 0.1 V and 0.1 A | volts and amperes |
| 42, 43 | phase 2 grid voltage and output current | one unsigned word each, 0.1 V and 0.1 A | volts and amperes |
| 46, 47 | phase 3 grid voltage and output current | one unsigned word each, 0.1 V and 0.1 A | volts and amperes |
| 53-54 | generated energy today | unsigned 32-bit, high word first, 0.1 kWh | kWh |
| 55-56 | generated energy total | unsigned 32-bit, high word first, 0.1 kWh | kWh |
| 57-58 | total work time | unsigned 32-bit, high word first, 0.5 s | seconds |

### Monitoring feature inventory

The exhaustive source and requested-field disposition is in the
[Growatt Protocol II source and profile evidence matrix](protocol-ii-source-profile-matrix-v1.md).
Its bounded result is `NO_ADMISSIBLE_PROFILE`: there is no exact tuple and no
typed field. This foundation retains only the source-backed schema and
synthetic fixture mechanics. It does not currently admit a typed profile or
close the broader `NATIVE-07-GROWATT-II` monitoring feature.

## Input register source table

This is the v1.24 input-register source table for words 0 through 249 and for the later PV and string group the same section places at words 875 through 999. Each register is one 16-bit word. A row is unsigned unless the table states a signed range or a signed 32-bit pair. A bit or code the document leaves undefined stays opaque and named. Live DD06 telemetry decodes a documented row only when every word of that row is inside the actual 0 through 249 record, and it uses the native type and scale in that row. BB03 string reading uses the same native scales: string voltage is an unsigned word at 0.1 V and string current is a signed word at 0.1 A. PV inputs 1 through 8 are unsigned. Temperature word 93 is the inverter temperature at 0.1 degrees Celsius, and its signedness is not stated. Words 35 through 38 keep their AC and grid meanings and never serve as PV9. PV9 words 875 through 878 and word 939 are source-only and supply neither a live field nor another request. Where a word has more than one device qualifier, or the qualifier is absent or inapplicable, the raw word is kept and neither meaning is selected. Groups after word 999, including the storage group that starts at word 1000, are further source groups and are not rows of the live record.

| Word | Native fact | Type and scale | Qualifier | Record |
| --- | --- | --- | --- | --- |
| 0 | inverter run state | one unsigned word | 0 waiting; 1 normal; 3 fault; other codes stay raw | live |
| 1-2 | aggregate PV input power | unsigned 32-bit, high word first, 0.1 W | reading | live |
| 3 | PV input 1 voltage | one unsigned word, 0.1 V | PV input 1 through 8 only | live |
| 4 | PV input 1 current | one unsigned word, 0.1 A | PV input 1 through 8 only | live |
| 5-6 | PV input 1 power | unsigned 32-bit, high word first, 0.1 W | PV input 1 through 8 only | live |
| 7 | PV input 2 voltage | one unsigned word, 0.1 V | PV input 1 through 8 only | live |
| 8 | PV input 2 current | one unsigned word, 0.1 A | PV input 1 through 8 only | live |
| 9-10 | PV input 2 power | unsigned 32-bit, high word first, 0.1 W | PV input 1 through 8 only | live |
| 11 | PV input 3 voltage | one unsigned word, 0.1 V | PV input 1 through 8 only | live |
| 12 | PV input 3 current | one unsigned word, 0.1 A | PV input 1 through 8 only | live |
| 13-14 | PV input 3 power | unsigned 32-bit, high word first, 0.1 W | PV input 1 through 8 only | live |
| 15 | PV input 4 voltage | one unsigned word, 0.1 V | PV input 1 through 8 only | live |
| 16 | PV input 4 current | one unsigned word, 0.1 A | PV input 1 through 8 only | live |
| 17-18 | PV input 4 power | unsigned 32-bit, high word first, 0.1 W | PV input 1 through 8 only | live |
| 19 | PV input 5 voltage | one unsigned word, 0.1 V | PV input 1 through 8 only | live |
| 20 | PV input 5 current | one unsigned word, 0.1 A | PV input 1 through 8 only | live |
| 21-22 | PV input 5 power | unsigned 32-bit, high word first, 0.1 W | PV input 1 through 8 only | live |
| 23 | PV input 6 voltage | one unsigned word, 0.1 V | PV input 1 through 8 only | live |
| 24 | PV input 6 current | one unsigned word, 0.1 A | PV input 1 through 8 only | live |
| 25-26 | PV input 6 power | unsigned 32-bit, high word first, 0.1 W | PV input 1 through 8 only | live |
| 27 | PV input 7 voltage | one unsigned word, 0.1 V | PV input 1 through 8 only | live |
| 28 | PV input 7 current | one unsigned word, 0.1 A | PV input 1 through 8 only | live |
| 29-30 | PV input 7 power | unsigned 32-bit, high word first, 0.1 W | PV input 1 through 8 only | live |
| 31 | PV input 8 voltage | one unsigned word, 0.1 V | PV input 1 through 8 only | live |
| 32 | PV input 8 current | one unsigned word, 0.1 A | PV input 1 through 8 only | live |
| 33-34 | PV input 8 power | unsigned 32-bit, high word first, 0.1 W | PV input 1 through 8 only | live |
| 35-36 | aggregate AC output power | unsigned 32-bit, high word first, 0.1 W | AC and grid; never a PV9 word | live |
| 37 | grid frequency | one unsigned word, 0.01 Hz | AC and grid; never a PV9 word | live |
| 38 | phase 1 grid voltage | one unsigned word, 0.1 V | AC and grid; never a PV9 word | live |
| 39 | phase 1 output current | one unsigned word, 0.1 A | AC and grid; never a PV9 word | live |
| 40-41 | phase 1 apparent power | unsigned 32-bit, high word first, 0.1 VA | reading | live |
| 42 | phase 2 grid voltage | one unsigned word, 0.1 V | three-phase | live |
| 43 | phase 2 output current | one unsigned word, 0.1 A | three-phase | live |
| 44-45 | phase 2 apparent power | unsigned 32-bit, high word first, 0.1 VA | three-phase | live |
| 46 | phase 3 grid voltage | one unsigned word, 0.1 V | three-phase | live |
| 47 | phase 3 output current | one unsigned word, 0.1 A | three-phase | live |
| 48-49 | phase 3 apparent power | unsigned 32-bit, high word first, 0.1 VA | three-phase | live |
| 50 | line voltage RS | one unsigned word, 0.1 V | line voltage | live |
| 51 | line voltage ST | one unsigned word, 0.1 V | line voltage | live |
| 52 | line voltage TR | one unsigned word, 0.1 V | line voltage | live |
| 53-54 | generated energy today | unsigned 32-bit, high word first, 0.1 kWh | reading | live |
| 55-56 | generated energy total | unsigned 32-bit, high word first, 0.1 kWh | reading | live |
| 57-58 | total work time | unsigned 32-bit, high word first, 0.5 s | reading | live |
| 59-60 | PV input 1 energy today | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 61-62 | PV input 1 energy total | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 63-64 | PV input 2 energy today | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 65-66 | PV input 2 energy total | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 67-68 | PV input 3 energy today | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 69-70 | PV input 3 energy total | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 71-72 | PV input 4 energy today | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 73-74 | PV input 4 energy total | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 75-76 | PV input 5 energy today | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 77-78 | PV input 5 energy total | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 79-80 | PV input 6 energy today | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 81-82 | PV input 6 energy total | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 83-84 | PV input 7 energy today | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 85-86 | PV input 7 energy total | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 87-88 | PV input 8 energy today | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 89-90 | PV input 8 energy total | unsigned 32-bit, high word first, 0.1 kWh | PV input 1 through 8 | live |
| 91-92 | PV energy total | unsigned 32-bit, high word first, 0.1 kWh | reading | live |
| 93 | inverter temperature | one word, 0.1 degrees Celsius; signedness not stated | reading | live |
| 94 | inverter IPM temperature | one word, 0.1 degrees Celsius; signedness not stated | reading | live |
| 95 | boost temperature | one word, 0.1 degrees Celsius; signedness not stated | reading | live |
| 96 | undefined temperature word | opaque and named | the source marks it reserved | live |
| 97 | battery voltage reported by the DSP | one unsigned word, 0.1 V | battery voltage | live |
| 98 | positive bus voltage | one unsigned word, 0.1 V | internal | live |
| 99 | negative bus voltage | one unsigned word, 0.1 V | internal | live |
| 100 | present output power factor | one unsigned word, range 0 through 20000 | unit not stated | live |
| 101 | real output power percent | one unsigned word, 1 percent | reading | live |
| 102-103 | output power limit | unsigned 32-bit, high word first, 0.1 W | power limit as a reading | live |
| 104 | derating code | one unsigned word | 0 none; 1 PV; 2 unmarked; 3 grid voltage; 4 grid frequency; 5 boost temperature; 6 inverter temperature; 7 control; 8 unmarked; 9 over-backup by time | live |
| 105 | inverter fault main code | one unsigned word | code; no symbol list in this row | live |
| 106 | undefined fault word | opaque and named | the source gives this word no definition | live |
| 107 | inverter fault subcode | one unsigned word | code; no symbol list in this row | live |
| 108 | storage remote-control enable | one unsigned word; unit not stated | storage, SPA; priority symbols are printed beside 108 and 109 and are not selected unless that qualifier applies | live |
| 109 | storage remote-control power | one unsigned word; unit not stated | storage, SPA; raw unless that qualifier applies | live |
| 110 | warning bits, high word | one unsigned word | warning reading | live |
| 111 | warning subcode | one unsigned word | warning reading | live |
| 112 | warning main code, or daily AC-charge energy high word | one unsigned word; the energy pair is 0.1 kWh with word 113 | MAX warning, or storage daily AC-charge energy; raw when the qualifier is absent, inapplicable, or matches both | live |
| 113 | real output power percent, or daily AC-charge energy low word | percent 0 through 100 for MAX; 0.1 kWh low word paired with word 112 for storage | MAX or storage; raw when the qualifier is absent, inapplicable, or matches both | live |
| 114 | inverter start delay, or AC-charge energy total high word | delay unit not stated; energy high word 0.1 kWh with word 115 | MAX or storage; raw when the qualifier is absent, inapplicable, or matches both | live |
| 115 | combined fault code, or AC-charge energy total low word | fault unit not stated; energy low word 0.1 kWh | MAX or storage; raw when the qualifier is absent, inapplicable, or matches both | live |
| 116 | grid-to-local-load energy, high word | high word of an unsigned pair, 0.1 kWh | storage; raw unless that qualifier applies | live |
| 117 | grid-to-local-load energy, low word | low word of the pair at 116, 0.1 kWh | storage; raw unless that qualifier applies | live |
| 118 | storage priority | one unsigned word | 0 load first; 1 battery first; 2 grid first; storage qualifier | live |
| 119 | battery type | one unsigned word | 0 lead-acid; 1 lithium; storage qualifier | live |
| 120 | storage auto-calibration command | one unsigned word | storage qualifier; this read profile does not send it | live |
| 121-124 | reserved words | opaque and named | the source marks them reserved | live |
| 125 | PV1 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; raw when the qualifier is absent, inapplicable, or matches both | live |
| 126 | PV1 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID | live |
| 127 | PV2 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; raw when the qualifier is absent, inapplicable, or matches both | live |
| 128 | PV2 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID | live |
| 129 | PV3 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; raw when the qualifier is absent, inapplicable, or matches both | live |
| 130 | PV3 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID | live |
| 131 | PV4 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; raw when the qualifier is absent, inapplicable, or matches both | live |
| 132 | PV4 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID | live |
| 133 | PV5 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; raw when the qualifier is absent, inapplicable, or matches both | live |
| 134 | PV5 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID | live |
| 135 | PV6 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; raw when the qualifier is absent, inapplicable, or matches both | live |
| 136 | PV6 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID | live |
| 137 | PV7 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; raw when the qualifier is absent, inapplicable, or matches both | live |
| 138 | PV7 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID | live |
| 139 | PV8 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; raw when the qualifier is absent, inapplicable, or matches both | live |
| 140 | PV8 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID | live |
| 141 | PID working status | one unsigned word | bits 0 through 7: 1 waiting, 2 normal, 3 fault; bits 8 through 15 undefined and opaque | live |
| 142 | string 1 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 143 | string 1 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 144 | string 2 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 145 | string 2 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 146 | string 3 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 147 | string 3 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 148 | string 4 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 149 | string 4 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 150 | string 5 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 151 | string 5 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 152 | string 6 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 153 | string 6 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 154 | string 7 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 155 | string 7 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 156 | string 8 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 157 | string 8 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 158 | string 9 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 159 | string 9 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 160 | string 10 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 161 | string 10 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 162 | string 11 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 163 | string 11 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 164 | string 12 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 165 | string 12 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 166 | string 13 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 167 | string 13 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 168 | string 14 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 169 | string 14 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 170 | string 15 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 171 | string 15 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 172 | string 16 voltage | one unsigned word, 0.1 V | string group starting at word 142 | live |
| 173 | string 16 current | one signed word, 0.1 A, range -15 through 15 A | string group starting at word 142 | live |
| 174 | string unmatch bits | one unsigned word | bits 0 through 15 are strings 1 through 16; suggestive | live |
| 175 | string current-unbalance bits | one unsigned word | bits 0 through 15 are strings 1 through 16; suggestive | live |
| 176 | string disconnect bits | one unsigned word | bits 0 through 15 are strings 1 through 16; suggestive | live |
| 177 | PID fault code | one unsigned word | bit 0 output overvoltage; bit 1 isolation; bit 2 bus voltage; bits 3 through 15 undefined and opaque | live |
| 178 | string prompt | one unsigned word | bit 0 unmatch; bit 1 disconnect; bit 2 current unbalance; bits 3 through 15 undefined and opaque | live |
| 179 | PV warning value | one unsigned word | unit not stated | live |
| 180 | warning value | one unsigned word | unit not stated; opaque named value | live |
| 181 | fault value | one unsigned word | unit not stated; opaque named value | live |
| 182-197 | debug data words | opaque and named | no scale is stated | live |
| 198 | aging-test flag | one unsigned word, 0 or 1 | flag | live |
| 199 | flash-erase aging flag | one unsigned word, 0 or 1 | flag | live |
| 200 | PV isolation | one unsigned word, kilohm | reading | live |
| 201 | phase R DC current | one word, 0.1 mA; signedness not stated | reading | live |
| 202 | phase S DC current | one word, 0.1 mA; signedness not stated | reading | live |
| 203 | phase T DC current | one word, 0.1 mA; signedness not stated | reading | live |
| 204 | PID bus voltage | one unsigned word, 0.1 V | reading | live |
| 205 | ground-fault current | one word, mA; signedness not stated | reading | live |
| 206 | compensation status and ratio | one unsigned word | low 8 bits: 0 none, 1 first mode, 2 second mode, 3 both; high 8 bits ratio with no stated scale | live |
| 207 | phase R load current | one unsigned word, 0.1 A | compensation reading | live |
| 208 | phase S load current | one unsigned word, 0.1 A | compensation reading | live |
| 209 | phase T load current | one unsigned word, 0.1 A | compensation reading | live |
| 210-211 | phase R load reactive power | unsigned 32-bit, high word first, 0.1 var | compensation reading | live |
| 212-213 | phase S load reactive power | unsigned 32-bit, high word first, 0.1 var | compensation reading | live |
| 214-215 | phase T load reactive power | unsigned 32-bit, high word first, 0.1 var | compensation reading | live |
| 216 | phase R load harmonic current | one unsigned word, 0.1 A | compensation reading | live |
| 217 | phase S load harmonic current | one unsigned word, 0.1 A | compensation reading | live |
| 218 | phase T load harmonic current | one unsigned word, 0.1 A | compensation reading | live |
| 219-220 | phase R compensated reactive power | unsigned 32-bit, high word first, 0.1 var | compensation reading | live |
| 221-222 | phase S compensated reactive power | unsigned 32-bit, high word first, 0.1 var | compensation reading | live |
| 223-224 | phase T compensated reactive power | unsigned 32-bit, high word first, 0.1 var | compensation reading | live |
| 225 | phase R compensated harmonic current | one unsigned word, 0.1 A | compensation reading | live |
| 226 | phase S compensated harmonic current | one unsigned word, 0.1 A | compensation reading | live |
| 227 | phase T compensated harmonic current | one unsigned word, 0.1 A | compensation reading | live |
| 228 | serial-port aging flag | one unsigned word, 0 or 1 | flag | live |
| 229 | fan fault bits | one unsigned word | bits 0 through 3 are fans 1 through 4; bits 4 through 7 undefined and opaque | live |
| 230-231 | output apparent power | unsigned 32-bit, high word first, 0.1 W | reading | live |
| 232-233 | output reactive power | signed 32-bit, high word first, 0.1 W | reading | live |
| 234-235 | nominal output reactive power | unsigned 32-bit, high word first, 0.1 var | power limit as a reading | live |
| 236-237 | reactive energy | unsigned 32-bit, high word first, 0.1 kWh | reading | live |
| 238 | arc-fault status | one unsigned word | 0 waiting; 1 self-check; 2 arc detection; 3 fault; 4 update | live |
| 239 | present transform value, first channel | one unsigned word | unit not stated | live |
| 240 | present transform value, second channel | one unsigned word | unit not stated | live |
| 241-248 | further debug data words | opaque and named | no scale is stated | live |
| 249 | reserved word | opaque and named | the source marks it reserved | live |
| 875 | PV9 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 876 | PV9 current | one unsigned word, 0.1 A | source group outside the live record | source-only |
| 877-878 | PV9 power | unsigned 32-bit, high word first, 0.1 W | source group outside the live record | source-only |
| 879 | PV10 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 880 | PV10 current | one unsigned word, 0.1 A | source group outside the live record | source-only |
| 881-882 | PV10 power | unsigned 32-bit, high word first, 0.1 W | source group outside the live record | source-only |
| 883 | PV11 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 884 | PV11 current | one unsigned word, 0.1 A | source group outside the live record | source-only |
| 885-886 | PV11 power | unsigned 32-bit, high word first, 0.1 W | source group outside the live record | source-only |
| 887 | PV12 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 888 | PV12 current | one unsigned word, 0.1 A | source group outside the live record | source-only |
| 889-890 | PV12 power | unsigned 32-bit, high word first, 0.1 W | source group outside the live record | source-only |
| 891 | PV13 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 892 | PV13 current | one unsigned word, 0.1 A | source group outside the live record | source-only |
| 893-894 | PV13 power | unsigned 32-bit, high word first, 0.1 W | source group outside the live record | source-only |
| 895 | PV14 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 896 | PV14 current | one unsigned word, 0.1 A | source group outside the live record | source-only |
| 897-898 | PV14 power | unsigned 32-bit, high word first, 0.1 W | source group outside the live record | source-only |
| 899 | PV15 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 900 | PV15 current | one unsigned word, 0.1 A | source group outside the live record | source-only |
| 901-902 | PV15 power | unsigned 32-bit, high word first, 0.1 W | source group outside the live record | source-only |
| 903 | PV16 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 904 | PV16 current | one unsigned word, 0.1 A | source group outside the live record | source-only |
| 905-906 | PV16 power | unsigned 32-bit, high word first, 0.1 W | source group outside the live record | source-only |
| 907-908 | PV9 energy today | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 909-910 | PV9 energy total | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 911-912 | PV10 energy today | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 913-914 | PV10 energy total | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 915-916 | PV11 energy today | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 917-918 | PV11 energy total | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 919-920 | PV12 energy today | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 921-922 | PV12 energy total | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 923-924 | PV13 energy today | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 925-926 | PV13 energy total | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 927-928 | PV14 energy today | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 929-930 | PV14 energy total | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 931-932 | PV15 energy today | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 933-934 | PV15 energy total | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 935-936 | PV16 energy today | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 937-938 | PV16 energy total | unsigned 32-bit, high word first, 0.1 kWh | source group outside the live record | source-only |
| 939 | PV9 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; source-only; raw when the qualifier is absent, inapplicable, or matches both | source-only |
| 940 | PV9 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID; source-only | source-only |
| 941 | PV10 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; source-only; raw when the qualifier is absent, inapplicable, or matches both | source-only |
| 942 | PV10 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID; source-only | source-only |
| 943 | PV11 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; source-only; raw when the qualifier is absent, inapplicable, or matches both | source-only |
| 944 | PV11 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID; source-only | source-only |
| 945 | PV12 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; source-only; raw when the qualifier is absent, inapplicable, or matches both | source-only |
| 946 | PV12 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID; source-only | source-only |
| 947 | PV13 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; source-only; raw when the qualifier is absent, inapplicable, or matches both | source-only |
| 948 | PV13 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID; source-only | source-only |
| 949 | PV14 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; source-only; raw when the qualifier is absent, inapplicable, or matches both | source-only |
| 950 | PV14 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID; source-only | source-only |
| 951 | PV15 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; source-only; raw when the qualifier is absent, inapplicable, or matches both | source-only |
| 952 | PV15 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID; source-only | source-only |
| 953 | PV16 positive-to-earth or MAX HV flyspan voltage | one unsigned word, 0.1 V, range 0 through 1000 V | PID or MAX HV flyspan; source-only; raw when the qualifier is absent, inapplicable, or matches both | source-only |
| 954 | PV16 positive-to-earth current | one signed word, 0.1 mA, range -10 through 10 mA | PID; source-only | source-only |
| 955 | string 17 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 956 | string 17 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 957 | string 18 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 958 | string 18 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 959 | string 19 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 960 | string 19 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 961 | string 20 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 962 | string 20 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 963 | string 21 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 964 | string 21 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 965 | string 22 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 966 | string 22 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 967 | string 23 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 968 | string 23 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 969 | string 24 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 970 | string 24 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 971 | string 25 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 972 | string 25 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 973 | string 26 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 974 | string 26 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 975 | string 27 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 976 | string 27 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 977 | string 28 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 978 | string 28 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 979 | string 29 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 980 | string 29 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 981 | string 30 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 982 | string 30 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 983 | string 31 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 984 | string 31 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 985 | string 32 voltage | one unsigned word, 0.1 V | source group outside the live record | source-only |
| 986 | string 32 current | one signed word, 0.1 A, range -15 through 15 A | source group outside the live record | source-only |
| 987 | string unmatch bits, strings 17 through 32 | one unsigned word | source-only | source-only |
| 988 | string current-unbalance bits, strings 17 through 32 | one unsigned word | source-only | source-only |
| 989 | string disconnect bits, strings 17 through 32 | one unsigned word | source-only | source-only |
| 990 | PV9 through PV16 warning | one unsigned word | abnormal input and boost-drive abnormal; source-only | source-only |
| 991 | string 1 through 16 abnormal | one unsigned word | source-only | source-only |
| 992 | string 17 through 32 abnormal | one unsigned word | source-only | source-only |
| 993-998 | words not individually defined | opaque and named | the source does not name each word | source-only |
| 999 | system command | one unsigned word | source-only; this read profile does not send it | source-only |

## Offline telemetry candidate

After the identity tuple passes, a fixture may decode bounded FC04 telemetry
from the 0 through 249 input range using an exact family schema. Fields not
present in that schema remain opaque words. Sentinels, scale, signedness, word
width, and units belong to the exact field definition and are never inferred
from a similar Growatt family.

The downstream POC must prove deterministic fixture decoding. This
specification does not register an automatic detector or claim support for
TL-X, TL-XH, TL-XH US, MAX 1500V, MAX-X LV, MOD TL3-XH, MIX, SPA, or SPH
ranges.

## Failure and overlap

A Growatt fixture that also satisfies a SunSpec signature or any Huawei family
tuple is ambiguous and produces no profile match. Registration order, vendor
name, unit number, or score must not pick a winner.

Malformed extents, inconsistent identity reads, unknown schema revision,
unsupported register range, timeout, or exception produces no send and no
partial publication. This version enumerates no control operation.

Executable fixture decoding and negative-overlap proof belong to the consuming
profile registry. This page creates no admission by itself.
