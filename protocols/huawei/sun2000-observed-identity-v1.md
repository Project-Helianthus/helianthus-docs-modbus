# Huawei SUN2000 Observed Identity Applicability V1

## Scope and relation to the disposition

This page defines identity applicability for the SUN2000 inverter tuple observed
behind a SmartLogger-family gateway, with an exact model and a software floor,
and records the LUNA2000 optional group as an Unknown placeholder. It is an
identity contract only. It defines no monitoring register, scale, unit, decoder,
or acquisition. Profile admission still requires a pinned register map, so the
outcome of the [inverter and battery
disposition](inverter-battery-readonly-v1.md) for profile selection is
unchanged: `NO_ADMISSIBLE_PROFILE`. Where that page records identity as
unobserved, this page supersedes the status for identity only; every monitoring,
scale, unit, access-mode, and availability fact stays Unknown. The disposition
page publishes no register offset by design, so the offsets this identity
contract needs are published here.

Every statement of the tuple and of SU-01 to SU-16 rests on the sanitized
observation record described in the
[SmartLogger observation](smartlogger-observed-inventory-v1.md), which also
defines the Proven, Hypothesis, and Unknown grades used below. SU-10 to SU-12
rest on the [S-Dongle observation](sdongle-observed-identity-v1.md) instead, and
SU-13 to SU-16 rest on the [EMMA observation](emma-observed-identity-v1.md).
Each read of the tuple is one that the public
[gateway contract](gateway-readonly-v1.md) already defines for another Huawei
family; the observation shows what a routed SUN2000 unit returns at those
offsets, and no offset or string of the tuple is taken from a vendor interface
definition. The section on the [identity rows that the catalogue selection
reads](#identity-rows-that-the-catalogue-selection-reads) adds the offsets
30070 and 30050 and names the edition and the page that define each row; SU-17
to SU-25 rest on the bounded read-only runs behind the
[monitoring contract](monitoring-readonly-v1.md) and on the editions that the
Documents consulted section lists. Grades are separate from
admission, qualification, and support, and `catalog_registered=false`,
`automatic_runtime_admission=false`, `live_qualified=false`,
`support_claim=false`, and `write_authority=false` are unchanged. The
historical V1 name implies no stability before Helianthus 1.0.

## Family contract: SUN2000 behind a SmartLogger-family gateway

| Field | Contract |
| --- | --- |
| Family | SUN2000 three-phase inverter with the exact model token `SUN2000-50KTL-M3` only. Other model tokens of the same product line are outside this contract; no prefix, wildcard, or range links two tokens. |
| Required tuple | All of the following at one routed unit `u` on one connection generation. Model: FC03 offset 30000, quantity 15, text exactly `SUN2000-50KTL-M3` after terminal NUL padding is stripped. Firmware: FC03 offset 30035, quantity 15, a version-style text after terminal NUL padding is stripped, recorded exactly as read. The observed text `V200R023` is the floor of this tuple under the [software applicability rule](monitoring-readonly-v1.md#software-applicability): a text that follows it in its branch, or a text of a branch with no documented relation to it, inherits the identity facts of this page with grade Hypothesis until observed, and only a recorded observation narrows that. Unit: `u` is in 1 through 247, is attribute 5 of exactly one entry of a validated listing of the gateway, and is in the operator allowlist. |
| Recorded, not gating | The protocol words (FC03 offset 30068, quantity 2; observed 5 then 0, encoding Unknown), the listing's firmware text, and the listing's product type. They corroborate and are retained as native evidence; they select and reject nothing. The model identifier (offset 30070) and the software text (offset 30050) are no element of this tuple either: the catalogue selection reads them, as the section on the identity rows states, and the outcomes of this tuple do not depend on them. |
| Forbidden identity | Serial number, ESN (listing key 4 or the serial-bearing block), writable alias, readability of any register (including a successful read at the EMMA offering offset or the S-Dongle protocol offset), any child listing content (label, model, product type, firmware, unit), the gateway's own MEI reply addressed to the unit, and a prefix, wildcard, case-folded, or whitespace-normalized match. The routed firmware text and the listing firmware text are never compared as prefix and suffix. |
| Multiple-positive outcome | `AMBIGUOUS`: another Huawei class contract that is also positive at the same endpoint and unit produces no selection, and no order or priority breaks the tie. |
| Negative-overlap obligations | Executable fixtures against SmartLogger (the counter read at the unit is an exception and the MEI reply is the gateway's), EMMA (the model gate fails on non-text data), S-Dongle (search and capacity reads are exceptions; the protocol read answers and is no discriminator), SunSpec (no marker), and Growatt (Unknown: not probed). The evidence is in the observation page's overlap table. |
| Failure outcome | A missing, non-ASCII, unpadded, excepted, timed-out, or contradictory element produces `INSUFFICIENT_EVIDENCE`, no profile, and zero native monitoring facts. A firmware text that differs from the observed one is not a failure; it inherits as the required tuple states. |
| Outcome when every element matches | Identity applicability holds for this tuple: Proven for the observed firmware text, and Hypothesis for an inherited one. Profile selection stays `NO_ADMISSIBLE_PROFILE` and zero monitoring facts are emitted. |

A listing may limit which identity requests a provider sends to a listed,
allowed unit, but it never supplies the answer. The identity reads of one tuple
are all taken at the same routed unit.

### Decision outcomes

| Situation | Outcome |
| --- | --- |
| Model exact and firmware read at the routed unit, unit validated | identity applicability holds, graded as the outcome row above states; profile `NO_ADMISSIBLE_PROFILE` |
| Model without firmware, or firmware without model | `INSUFFICIENT_EVIDENCE` |
| Listing entry only, no routed read | `INSUFFICIENT_EVIDENCE` |
| Serial number or ESN only | `INSUFFICIENT_EVIDENCE` |
| Routed model differs from the listing's model | `INSUFFICIENT_EVIDENCE`; the child is withheld |
| Unit not in the listing, or not in the allowlist | no read is sent; the child is withheld |
| Another Huawei class also positive at the unit | `AMBIGUOUS` |

## Reads, extents, and padding

| Read | Extent | Observed value form | Grade |
| --- | --- | --- | --- |
| Model | FC03 offset 30000, quantity 15: 30 bytes | 16 ASCII characters then 14 NUL bytes, identical on units 1 through 8 | Proven |
| Firmware | FC03 offset 30035, quantity 15: 30 bytes | 8 ASCII characters then 22 NUL bytes, identical on units 1 through 8 | Proven |
| Protocol words | FC03 offset 30068, quantity 2: 4 bytes | two words, 5 then 0, identical on units 1 through 8 | Proven |
| Serial-bearing block | read on units 1 and 2: 20 bytes | ASCII with NUL padding; never published, never a predicate | Proven |
| Listing entry | one 254-byte object | text then NUL padding; the inverter entries carry 164 pad bytes | Proven |

The shared encoding applies: a string occupies exactly `quantity * 2` bytes,
the raw extent is retained, ASCII is required, and only terminal NUL or space
padding is stripped. A value that leaves no padding byte in its extent is not
matched, because it may be truncated. Observed values leave 14 and 22 padding
bytes, which is the basis for that rule (Hypothesis).

## Routed-unit observations

| ID | Statement | Grade |
| --- | --- | --- |
| SU-01 | Units 1 through 8 each answered the model read with `SUN2000-50KTL-M3`, the firmware read with `V200R023`, and the protocol read with 5 then 0; all eight agree. | Proven |
| SU-02 | For all eight units, the routed model string equals key 1 of the listing entry whose key 5 is that unit. | Proven |
| SU-03 | For all eight units, the routed firmware text is the leading eight characters of the listing's key 2 value `V200R023C00SPC128`. | Proven |
| SU-04 | At units 1 and 2 the firmware read (offset 30035) carries only the leading eight characters of the build, and the complete build is read at the same units from offset 30050 (SU-18, SU-19), so the remainder does not appear only in the listing. | Proven |
| SU-05 | Two builds that share the leading part differ in the software text of SU-18, which carries the SPC number, so they can be told apart at the routed unit. Only one build was seen in each family, so no such pair was observed. | Hypothesis |
| SU-06 | Reads to units 1 through 8 are served at the gateway's endpoint under their own unit identifiers. The physical path behind the gateway is not established. | Proven |
| SU-07 | The model read at the PLC unit (9) and at a meter unit (11) answered exception 3, so the SUN2000 tuple fails there. Unit 19 was not read. | Proven |
| SU-08 | A battery group is attached to any observed inverter. | Unknown |
| SU-09 | Other SUN2000 model tokens, other firmware text, or another gateway family report these forms, apart from the one S-Dongle child that SU-10 to SU-12 record and the two EMMA children that SU-13 to SU-16 record. | Unknown |
| SU-10 | A SUN2000-family child behind an S-Dongle (unit 1) answers the model read with a model token other than `SUN2000-50KTL-M3`, so the tuple of this page does not match it. Its own tuple is on the [S-Dongle observation](sdongle-observed-identity-v1.md). | Proven |
| SU-11 | That model block holds printable residue after the first NUL, whereas the model block of units 1 through 8 holds 14 NUL padding bytes after the text (read table above), so the form differs apart from the token. | Proven |
| SU-12 | The protocol words at that child read 5 then 0, as at units 1 through 8, so the protocol words separate neither the gateway family nor the model. | Proven |
| SU-13 | Two SUN2000-family children behind an EMMA (units 3 and 4) answer the model read with one model token, the same at both units and other than `SUN2000-50KTL-M3`, so the tuple of this page does not match them. Their own contract is on the [EMMA observation](emma-observed-identity-v1.md). | Proven |
| SU-14 | That model block holds NUL bytes and then printable residue that reaches the end of the extent with no trailing NUL padding, whereas the model block of units 1 through 8 holds 14 NUL padding bytes after the text (read table above), and the S-Dongle child's residue is followed by NUL padding (SU-11). | Proven |
| SU-15 | The protocol words at both EMMA children read 5 then 0, as at units 1 through 8 and at the S-Dongle child (SU-12). | Proven |
| SU-16 | The firmware text at the EMMA children is not the 8 characters read at units 1 through 8: it shares its leading part with key 2 of its listing entry and differs after that part, so it is not a prefix of key 2, which SU-03 found at units 1 through 8. The relation of SU-03 and SU-04 between the firmware text and the complete build is therefore a relation of the SmartLogger path only, and the software text of SU-18 is the complete build on all three paths. | Proven |

The firmware component of the tuple is the value read at the routed unit, not
the listing's longer value, and the listing value gates nothing. The complete
build needs no listing: it is read at the routed unit from offset 30050 (SU-17
to SU-19), where the firmware text of the SmartLogger path carries only its
leading eight characters. The tuple alone binds no register map. Which catalogue
row a unit matches is decided by the selection that the next section describes.

## Identity rows that the catalogue selection reads

When the registry's providers admit a child at a routed unit, they read three
identity rows there and give them, with the model text, to the catalogue
selection (helianthus-modbusreg issue 365). The selection follows the
[catalogue page](sun2000-inverter-catalogue-v1.md) (helianthus-modbusreg issue
362). The rows are identity only: they define no monitoring register, scale,
unit, or decoder. The tuple above, its outcomes, and the flags of the scope
section stay as stated, and a decision of the selection is not an outcome of the
tuple.

| Row | Read | Type | What the selection takes from it |
| --- | --- | --- | --- |
| Model identifier | FC03 offset 30070, quantity 1: 2 bytes | one unsigned 16-bit word | The key of the catalogue row, together with the model text. The word is compared whole with the identifier of each row whose token, or recorded wire alias, equals the model text, and it is never scaled or decoded. A token does not identify a model without it: the M3 series token is in three rows with more than one identifier, so without the word the decision is `AMBIGUOUS`, and the M1 series token selects no row. |
| Software text | FC03 offset 30050, quantity 15: 30 bytes | text | The complete software build. It is compared with the documented minimum, the floor, of each candidate row, within one branch and on the parts both carry, under the [software applicability rule](monitoring-readonly-v1.md#software-applicability). |
| Firmware text | FC03 offset 30035, quantity 15: 30 bytes | text | The firmware text, recorded exactly as read with the decision. It is the read of the firmware element of the tuple, and it takes no part in the comparison when a software text was read. |

The two texts follow the encoding rules above: exactly `quantity * 2` bytes,
ASCII, only terminal NUL or space padding stripped, and no match on a value that
leaves no padding byte. The three rows are read at the same routed unit as the
model text, one request each, and only at a unit that the listing names and the
allowlist admits. The listing never supplies an answer.

The editions that define the rows are below, with the physical page of each row
counted from the cover. The Documents consulted section gives their titles,
issues, and dates.

| Family | Model identifier, offset 30070 | Software text, offset 30050 | Firmware text, offset 30035 |
| --- | --- | --- | --- |
| M3 series | SUN2000MC edition, page 9 | SUN2000MC edition, page 8 | SUN2000MC edition, page 8 |
| MAP0 series | SUN2000MA V200R024C00SPC111 edition, page 10 | the same edition, page 9 | the same edition, page 9 |
| M1 series | SUN2000MA V100R001C00SPC178 edition, page 15 | Solar Inverter V3.0 document, page 14 | Solar Inverter V3.0 document, page 14 |

The identifier is compared with the model row of the same edition: page 5 of the
SUN2000MC edition, page 6 of the SUN2000MA V200R024C00SPC111 edition, and page 7
of both M1 sources. The monitoring contract's statements about which documents
cover the monitoring groups of the MAP0 and M1 series are unchanged: this page
consults these editions for the three identity rows only.

### Observations and document statements

| ID | Statement | Grade |
| --- | --- | --- |
| SU-17 | The software read (offset 30050, quantity 15) and the ratings read that starts at the identifier (offset 30070, quantity 13) answered with data, on the first attempt, at units 1 and 2 behind the SmartLogger, at units 3 and 4 behind the EMMA, and at unit 1 behind the S-Dongle. The firmware read answered at the same units (SU-01, EM-35, SD-15). All three owned families therefore answer the three identity rows at the routed child. | Proven |
| SU-18 | The software text at these units is ASCII: 17 characters that carry the V, R, and C parts and the SPC number, then 13 NUL bytes to the end of the 30-byte extent. The two units of a family that were read return the same text. | Proven |
| SU-19 | At each unit read, the software text equals key 2 of the listing entry whose key 5 is that unit (at the S-Dongle child, the child's own entry of SD-24). Behind the SmartLogger it is the value `V200R023C00SPC128` of SU-03, of which the firmware text is the leading eight characters. | Proven |
| SU-20 | At the S-Dongle child the firmware text is not a prefix of the software text, as SU-16 records for the EMMA children: the two share their leading eight characters and differ after them. | Proven |
| SU-21 | At each unit read, the identifier word equals the identifier that the model table of the family's edition assigns to the family's model token. Behind the EMMA the match goes through the wire alias that the catalogue records for the token, which stays a Hypothesis under the catalogue page. For the M3 series this is MS-01 of the [monitoring contract](monitoring-readonly-v1.md). | Proven (equality at the units read); Hypothesis (the word as the model identifier, outside the M3 series) |
| SU-22 | The editions define offset 30070 as a row of one unsigned 16-bit word, the model identifier, and offsets 30050 and 30035 as rows of 15 words of text, the software text and the firmware text, on the pages of the table above. They state no gain or unit for any of the three. | Hypothesis |
| SU-23 | The SUN2000MA V100R001C00SPC178 edition defines the identifier row for the M1 series and leaves out the two text rows that the Solar Inverter V3.0 document defines for it. The omission is no recorded change, because the silence of a following document records none, and the child answers both rows (SU-17). | Hypothesis |
| SU-24 | The one-word read of offset 30070 that the providers send has no observation of its own: the observed read has quantity 13 and begins at the identifier, and that the shorter read answers is an inference from it. | Hypothesis |
| SU-25 | Whether offsets 30050 and 30070 answer at a gateway unit, and with what. Neither was read at unit 0 or unit 100 of any gateway, so the two reads are no discriminator between a gateway and its children. | Unknown |

### Admission rule

A provider admits a routed child only when the catalogue selection over the
model text, the model identifier, the software text, and the firmware text read
at that unit decides `SELECTED` for a row of the path's family, graded
Hypothesis until an observation grades it; `NOT_SELECTED` and `AMBIGUOUS`
withhold the child with the decision and its reason recorded, and an identity
read that fails or has the wrong shape leaves the child without a decision, with
nothing guessed. The decision, its closed reasons, and the floor comparison are
those of the [catalogue page](sun2000-inverter-catalogue-v1.md) and
helianthus-modbusreg issue 362; the three reads at admission are those of
helianthus-modbusreg issue 365.

## Optional groups: hybrid SUN2000 and LUNA2000

No hybrid SUN2000 and no LUNA2000 battery was observed, so every statement about
them is Unknown. The form of the contract is fixed so that nothing is inferred
from the inverter-only tuple above.

| Field | Contract |
| --- | --- |
| Required tuple | Unknown. A hybrid SUN2000 needs its own tuple of the same form (exact model, firmware floor, routed unit). The LUNA2000 group needs a separate exact identity read; neither is defined by this revision. |
| Forbidden identity | The parent inverter's identity, a hybrid model token, any child listing content, serial number or ESN, a writable alias, register readability, and a prefix or wildcard match. A battery group is never inferred from an inverter model. |
| Multiple-positive outcome | `AMBIGUOUS`; no selection, order, or priority. |
| Negative-overlap obligations | Executable fixtures against the inverter-only tuple above, SmartLogger, EMMA, and S-Dongle. No evidence exists. |

The existing optional-group rules still apply. An absent group yields Unknown
values, never numeric zero. A read exception on the group does not negate an
identified inverter, and last-known-good values are retained where a profile
permits. An inverter identity does not prove battery presence, and a gateway
listing proves neither inverter nor battery identity.

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| Huawei PV inverter Modbus reference | reference baseline 2026-10-26.1 | 2026-10-26 | the identity rows section: the offset, quantity, and type of the three rows, the edition that defines each row for each family, and the physical pages (SU-22, SU-23); no other register, model, floor, or dictionary entry is restated |
| SUN2000MC V200R023C00 Modbus Interface Definitions | Issue 01 | 2023-03-17 | the M3 series rows: the model row on physical page 5, the firmware text and software text rows on page 8, and the model identifier row on page 9 |
| SUN2000MA V200R024C00SPC111 Modbus Interface Definitions | Issue 10 | 2026-09-09 | the MAP0 series rows: the model row on physical page 6, the firmware text and software text rows on page 9, and the model identifier row on page 10 |
| SUN2000MA V100R001C00SPC178 Modbus Interface Definitions | Issue 10 | 2026-09-09 | the M1 series rows: the model row on physical page 7 and the model identifier row on page 15, and the omission of the two text rows (SU-23) |
| Solar Inverter Modbus Interface Definitions (V3.0) | Issue 01 | 2023-01-17 | the M1 series rows: the model row on physical page 7, and the firmware text and software text rows on page 14 |

The tuple above and SU-01 to SU-16 rest on observations: the routed-unit reads
and the listing described in the
[SmartLogger observation](smartlogger-observed-inventory-v1.md), the S-Dongle
child recorded on the [S-Dongle observation](sdongle-observed-identity-v1.md),
and the EMMA children recorded on the
[EMMA observation](emma-observed-identity-v1.md). The section on the identity
rows rests on the editions above as well, which were taken through the Huawei PV
inverter Modbus reference; it states in its own words the offsets, quantities,
types, and pages of three rows and reproduces no table or text of them. The
monitoring contract lists the vendor interface definition it rests on in its own
Documents consulted section, with the title, version, and date of the document
and a copyright note in force, under the page conventions in the
[applicability and licensing page](../applicability-and-licensing.md).

**Copyright note.** The information on this page that is derived from the
documents listed above is attributed to Huawei Technologies Co., Ltd., which
retains the copyright in those documents. This page states that information in
its own words and does not reproduce the documents. The CC0-1.0 dedication of
this page covers its own expression only and does not relicense those documents.

**Reference note.** The facts that the Documents consulted section attributes
to the Huawei PV inverter Modbus reference were taken through that independent
documentary work, whose contributors dedicate its original writing under
CC0-1.0. The vendor documents it cites keep their rights, as the copyright note
states. This page restates those facts in its own words and carries over none
of the reference's engineer-review or operational-authorization clauses.

## Open questions

1. Does a software text of a release outside the observed ones carry more than
   the build, such as an offering name shown together with it, as a display note
   of the Solar Inverter V3.0 document describes for one release? Such a text is
   neither the V, R, and C form nor the accepted shortened form, so the
   selection takes it as a malformed element and selects nothing (software
   applicability rule, item 4). No observed text carries one.
2. Which other SUN2000 model tokens and firmware texts exist behind this and
   other gateway families? Each other model token needs its own tuple and
   observation. Another firmware text with this model token inherits this tuple
   under the software applicability rule until an observation records a change.
   One further child behind an S-Dongle has its own tuple (SU-10), and the two
   behind an EMMA have theirs (SU-13).
3. What does the protocol-word pair encode, and should it become a gate? Its
   encoding is Unknown.
4. Does a PLC or meter unit answer any SUN2000-shaped read other than an
   exception? Only the model read was issued there.
5. Which hybrid SUN2000 tuple and LUNA2000 group identity exist, and is the
   group read at the parent's routed unit or at a separate unit? No evidence
   exists.
