# Huawei EMMA Observed Gateway Identity V1

## Scope and evidence basis

This page records what one bounded, read-only observation of one operator-owned
EMMA energy-management gateway established about the gateway unit, the
SUN2000-family inverters behind it, the neighbouring units, and the overlap
with the other Huawei classes. The run was taken after the operator allowed the
capture host on the gateway. Four runs from two capture hosts, taken before the
answered run, received no Modbus reply at all, and they are recorded here too.
It is the observation record behind the observed EMMA entry of the
[gateway contract](gateway-readonly-v1.md) and behind the EMMA observed-tuple
status of the [qualification readiness contract](qualification-readiness-v1.md).
It defines no monitoring register, capability map, decoder, acquisition
schedule, or registry behavior, and it creates no admission. The registry
companion is helianthus-modbusreg issue 353. The historical V1 name implies no
stability before Helianthus 1.0.

The answered run used one connection, one request in flight, a gap of 750 ms
between requests, a deadline of five seconds, and at most four attempts per
request. It issued 26 requests, 19 answered with data and 7 with an exception,
and every one was answered on its first attempt. The extended inventory read
counts as one request of five pages, so the run exchanged 30 responses in about
23 s. Only FC03 holding-register reads and FC2B / MEI 0x0e device-identification
reads (read codes 1 and 3) were issued. Every request was already defined by the
public gateway contract, the SmartLogger observation, the S-Dongle observation,
the SUN2000 identity contract, the public SunSpec contract, or the Modbus
application protocol. None writes, configures, or controls, no private function
code was sent, no register was taken from vendor-authored material, and no
capability, monitoring, or battery register was read. This page names families
and does not publish model tokens. Serial numbers, ESNs, the residue after the
inverter model text, firmware and version-style texts, binary values of
unidentified meaning, the text objects of unidentified meaning, the key 10
codes, endpoints, addresses, times, and captures are not published either.

| Grade | Meaning on this page |
| --- | --- |
| Proven | The sanitized observation record shows exactly this for the observed installation. It is not a statement about other installations, firmware, or models. |
| Hypothesis | The structure was observed but not correlated by a second independent reading, or the statement is an inference from observed structure, or it rests on a change that the record does not show. |
| Unknown | No evidence. |

The grades match those of the [SmartLogger observation](smartlogger-observed-inventory-v1.md)
and are separate from parser acceptance, identity matching, admission,
qualification, and support. Nothing here changes `catalog_registered=false`,
`automatic_runtime_admission=false`, `live_qualified=false`,
`support_claim=false`, or `write_authority=false`. The registry companion
re-creates the Proven rows as synthetic fixtures; no capture is published.

## Gateway unit 0: identity blocks

| ID | Statement | Grade |
| --- | --- | --- |
| EM-01 | Four holding-register reads at unit 0 were answered with data on the first attempt, each within 75 ms: the offering block (FC03 offset 30000, quantity 15: 30 bytes), the model block (offset 30222, quantity 20: 40 bytes), the software block (offset 30035, quantity 15: 30 bytes), and the serial-bearing block (offset 30015, quantity 10: 20 bytes). | Proven |
| EM-02 | The offering block holds the product-family label `SmartHEMS`, a NUL, and NUL padding to the end of the extent. | Proven |
| EM-03 | The model block holds a model token of the EMMA family, a NUL, and NUL padding to the end of the extent. After the terminal NUL padding is removed, the text equals one of the two exact values that the EMMA candidate of the gateway contract admits. Which one is withheld, as is every model token on this page. | Proven |
| EM-04 | The software block holds `SmartHEMS`, one space, a 17-character version-style text, a NUL, and NUL padding to the end of the extent. It carries no serial-class value. The version-style text has the structured form of one branch of the candidate's rule and meets that branch's numeric floor; its branch and suffix are withheld. | Proven |
| EM-05 | The version-style text of the software block equals key 2 of the EMMA's own inventory entry and the version object (0x02) of its basic reply. | Proven |
| EM-06 | The serial-bearing block holds a 12-character ASCII text followed by NUL padding. The same text is key 4 of the EMMA's own entry and object 0x10 of the basic reply, and object 0x1b carries it padded to 20 bytes. It is never published and never a predicate. | Proven |
| EM-07 | The three reads of the candidate (offering, model, software) were answered at unit 0 on one connection, each on its first attempt, and the candidate's rules hold on them. The candidate's FC03 identity tuple is therefore observed on this installation. | Proven (basis: EM-01 to EM-05) |
| EM-08 | Which of the two admitted model values this installation reports, its software branch and suffix, whether the other admitted model value or the other branch exists behind another installation, and which capability variant the model token names behind this one. | Unknown |

## Basic identification

| ID | Statement | Grade |
| --- | --- | --- |
| EM-09 | Basic device identification (FC2B / MEI 0x0e, read code 1) at unit 0 returned one page with conformity 0x01, more-follows 0x00, next-object field 0x00, 14 objects, a declared-object field of 14 that equals the objects present, and a PDU of 118 bytes. | Proven |
| EM-10 | The objects are 0x00 vendor `Huawei`, 0x01 product `HEMS` (the family label, without a model), 0x02 the version-style text of EM-05, 0x10 and 0x1b ESN-class texts, 0x18 an 8-character text of unidentified meaning, and 0x03, 0x11, 0x12, 0x13, 0x14, 0x15, 0x17, and 0x19 two-byte binary values of unidentified meaning. All but the vendor and product objects are withheld. | Proven |
| EM-11 | The reply carries eleven objects outside the basic category (0x03 and ten objects in the reserved range 0x07 to 0x7f: 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x17, 0x18, 0x19, and 0x1b). The SmartLogger's basic reply carried twelve objects (SL-05) and the S-Dongle child's six (SD-18). | Proven |
| EM-12 | The vendor object differs in case from the SmartLogger's vendor object `HUAWEI` (SL-04) and equals the S-Dongle child's `Huawei` (SD-18). | Proven |
| EM-13 | The PDU of the basic reply is byte-identical at unit 0, unit 100, and routed unit 3, each time the EMMA's own identity. The unit identifier of an MEI request selects no device, as at the SmartLogger (SL-07). Other unit identifiers were not tried. | Proven |
| EM-14 | Basic identification at unit 100 is answered, where the S-Dongle gateway refuses it with exception 1 (SD-02). The content of the product object tells the two paths apart, and never whether the request is answered. | Proven |
| EM-15 | Whether any basic or extended identification read reaches an inverter's own identity through the EMMA. At unit 3 the basic read returned the EMMA's reply, and the extended inventory was never addressed to a routed unit. | Unknown |

## Extended inventory at unit 0

The extended read starts at object 0x87 and follows the continuation fields. The
observed trace, in sizes only:

| Request cursor | More | Next object | PDU bytes | Objects present | Content |
| --- | --- | --- | --- | --- | --- |
| 0x87 | 0xff | 0x88 | 10 | 1 | count object, value 4 |
| 0x88 | 0xff | 0x89 | 88 | 1 | the EMMA's own entry |
| 0x89 | 0xff | 0x8a | 102 | 1 | one entry |
| 0x8a | 0xff | 0x8b | 111 | 1 | one entry |
| 0x8b | 0x00 | 0x00 | 111 | 1 | the last entry |

| ID | Statement | Grade |
| --- | --- | --- |
| EM-16 | One pass enumerated the whole inventory in five requests (cursors 0x87 through 0x8b), each answered on its first attempt with conformity 0x03, in about 3.1 s at the 750 ms gap. | Proven |
| EM-17 | Each response carries exactly one object, while its declared-object field reads 5 in every response. The field is therefore not a per-response count, and it equals the number of objects in the whole stream (the count object plus four entries). | Proven |
| EM-18 | The declared-object field is the stream total for a Huawei gateway that lists children. SL-12 and EM-17 are one reading each, on two classes. | Hypothesis |
| EM-19 | Next object is the requested cursor plus 1 on every response with more-follows 0xff, and the last response has more-follows 0x00 and next object 0x00. No response sets the next-object field next to more-follows 0x00, so `next_object_without_more_follows` (SD-22) does not occur here. | Proven |
| EM-20 | The count object has length 1 and value 4, equal to the number of entry objects (0x88 through 0x8b) including the EMMA's own entry. The child count is the count minus one, which is three. | Proven |
| EM-21 | Every PDU is at most 111 bytes, below the classic 253-byte limit. The first response is a count-only page, and on every response the declared-object field differs from the objects present (the wire shapes of `count_only_page` and `object_count_mismatch` in the [tolerant decoding vocabulary](../modbus/tolerant-tcp-modes-v1.md)). | Proven |
| EM-22 | Each entry is text of `key=value` pairs separated by `;`, 79 to 102 bytes, not NUL padded. The S-Dongle's entry is also unpadded (SD-24), whereas the SmartLogger's entries are 254-byte padded objects. | Proven |
| EM-23 | Entry 0x88 is the EMMA's own entry. Its key 5 is 0, the unit read; its key 1 equals the model block (EM-03); its key 2 equals the version-style text of the software block (EM-05); its key 4 equals the serial-bearing block (EM-06); and its key 8 equals the product object `HEMS`. | Proven |
| EM-24 | Keys 3 and 6 carry version-style texts on every entry, and key 9 reads 0 on every entry. On the two SUN2000 entries, keys 3 and 6 equal those of the SmartLogger's SUN2000 entries and of the S-Dongle child's entry. | Proven |
| EM-25 | Key 10, an 8-character code of unidentified meaning, is present on the two SUN2000 entries only and precedes key 9 there. It is withheld. The SmartLogger carried key 10 on its self entry only. | Proven |
| EM-26 | The meaning of keys 3, 6, 9, and 10. | Unknown |

### Entry encoding

| Key | Observed content | Present on | Role in this contract | Grade |
| --- | --- | --- | --- | --- |
| 1 | model or family string | all four entries | native listing evidence; never identity | Proven |
| 2 | version-style text | all four entries | native listing evidence; never identity | Proven |
| 3 | version-style text | all four entries | opaque | Proven |
| 4 | sensitive native identity input | all four entries | retained as native evidence at runtime, never published, never a predicate | Proven |
| 5 | unsigned decimal unit identifier | all four entries | the routing address | Proven |
| 6 | version-style text | all four entries | opaque | Proven |
| 8 | device-type word: `HEMS`, `BackupBox`, or `SUN2000` | all four entries | listing label; never identity | Proven |
| 9 | small integer, value 0 | all four entries | opaque | Unknown |
| 10 | 8-character code, treated as sensitive | the two SUN2000 entries only | opaque; never published | Unknown |

The Grade of a key row grades its presence, content class, and role; Unknown
means the meaning of the value is not established. Key sets by entry class, in
the order observed: the EMMA's own entry and the backup-box entry
`1;2;3;4;5;6;8;9`, and the inverter entries `1;2;3;4;5;6;8;10;9`. Key 10
precedes key 9 where it is present.

### Listing contents

This table is a synthetic re-creation of the sanitized routing table. The unit
column is attribute 5; the order column is the object order of the listing.

| Object | Device type (key 8) | Unit | Model (key 1) |
| --- | --- | --- | --- |
| 0x88 | `HEMS` | 0 | the EMMA's model token, withheld |
| 0x89 | `BackupBox` | 2 | a backup-box model token, withheld |
| 0x8a | `SUN2000` | 3 | a token of the SUN2000 family, withheld |
| 0x8b | `SUN2000` | 4 | the same token as object 0x8a, withheld |

All rows are Proven for the observed installation: one gateway, one backup-box
entry, and two inverters, four entries in all.

| ID | Statement | Grade |
| --- | --- | --- |
| EM-27 | The listing has four entries, and its object order is unit order (0, 2, 3, 4). That is one reading. Object order never maps an entry to a unit (routing rule 2 of the gateway contract), and the SmartLogger listing's order was not unit order (CA-04). | Proven |
| EM-28 | Units are not contiguous: unit 1 carries no entry. | Proven |
| EM-29 | No entry is a battery and no entry is a power meter, and the text LUNA2000 occurs in no response of the run. | Proven |
| EM-30 | The listing carries a backup-box entry (device type `BackupBox`, unit 2). No Huawei class contract on these pages covers a backup box, so the entry is native listing evidence and the unit is withheld as having no class contract. | Proven |
| EM-31 | The SmartLogger counter read (FC03 offset 65521, quantity 1) is refused at the EMMA with exception 3, and the inventory was read once, with no register read before or after it. This observation brackets the listing with no guard. | Proven |
| EM-32 | Whether any register guards an EMMA listing, and whether the listing changes while it is read or between reads. | Unknown |

## Units addressed and child routing

| Unit | Listing entry | Reads sent | Outcome classes |
| --- | --- | --- | --- |
| 0 | the EMMA (object 0x88) | the four identity blocks, basic identification, the extended inventory, the SmartLogger counter, the SunSpec signature | data on seven reads; exception 3 on the counter |
| 100 | none | basic identification, and the S-Dongle protocol-version, search sequence, and capacity reads | the EMMA's basic reply; exception 4 on the three FC03 reads |
| 3 | inverter (object 0x8a) | the four identity blocks, the SmartLogger counter, the EMMA model read, the S-Dongle search sequence and capacity reads, the SunSpec signature, basic identification | data on seven reads; exception 3 on the counter, the search sequence, and the capacity |
| 4 | inverter (object 0x8b) | the four identity blocks | data on four reads |
| 2 | backup box (object 0x89) | none | none |
| 1, 5 to 8, and every other unit | none | none | none |

| ID | Statement | Grade |
| --- | --- | --- |
| EM-33 | Only units 0, 3, 4, and 100 were addressed, with the reads in the table. The plan's bounded probe of units 1 through 8, a discovery fallback, was not issued, because the listing named the inverter units. | Proven |
| EM-34 | The inverter units were taken from key 5 of the two entries with device type `SUN2000`, and both answered the identity reads at exactly those units. No scan found them. | Proven |
| EM-35 | Units 3 and 4 each answered the model block (FC03 offset 30000, quantity 15), the firmware block (offset 30035, quantity 15), the protocol words (offset 30068, quantity 2), and the serial-bearing block (offset 30015, quantity 10) with data on the first attempt, each within 60 ms. | Proven |
| EM-36 | At each of the two units the model block holds the same model token of the SUN2000 family, NUL bytes, and then printable ASCII residue of a part-number class that reaches the end of the 30-byte extent, with no trailing NUL padding. The residue is withheld, is never a predicate, and is retained as native evidence at runtime. | Proven |
| EM-37 | That form differs from the model block of the units behind the SmartLogger, which holds only NUL padding after the text (the read table of the [SUN2000 identity contract](sun2000-observed-identity-v1.md)), and from the S-Dongle child's, where the residue is followed by NUL padding (SD-13). | Proven |
| EM-38 | At each unit the model text before the first NUL equals key 1 of the entry whose key 5 is that unit. | Proven |
| EM-39 | At each unit the serial-bearing block equals key 4 of the entry whose key 5 is that unit and differs from key 4 of every other entry, and the two units' blocks differ from each other. The values are not published and are not an identity predicate; the correlation shows that key 5 binds an entry to its unit, with a swap of the two inverters excluded. | Proven |
| EM-40 | The protocol words read 5 then 0 at both units, equal to those of units 1 through 8 behind the SmartLogger (SU-01) and of the S-Dongle child (SD-16). | Proven |
| EM-41 | The firmware block at each unit holds a version-style text followed by NUL padding, the same text at both units. It shares its leading part with key 2 of the entry and differs from that value after the leading part, so it is not a prefix of key 2, which SU-03 found behind the SmartLogger. It is withheld and is not a predicate. | Proven |
| EM-42 | At units 3 and 4 the EMMA's own offsets return the inverter's identity texts or non-text data and never the EMMA's identity (overlap table), so each inverter is read at its own unit and not through unit 0. | Proven |
| EM-43 | No key identifies a parent, and the parent of every entry is the gateway that lists it. | Hypothesis |
| EM-44 | The negative-overlap results at unit 4 (the probes ran at unit 3 only), any read at unit 2, whether any unit other than 0, 3, 4, and 100 answers a read, and whether an inverter sits at an unlisted unit. | Unknown |

## Unit 100 and the neighbouring units

| ID | Statement | Grade |
| --- | --- | --- |
| EM-45 | At unit 100, which has no listing entry, the S-Dongle protocol-version, search sequence, and capacity reads (FC03 offsets 30068, 37410, and 37429) each answered exception 4 (server device failure) on the first attempt, within 13 to 39 ms. | Proven |
| EM-46 | At routed unit 3 the search sequence and capacity reads answered exception 3 on both, and the SmartLogger counter read answered exception 3 at units 0 and 3. | Proven |
| EM-47 | Exception 3 marks an unserved register on a listed unit and exception 4 an unlisted unit, as behind the SmartLogger (CA-06, CA-07). The contract does not use the code for identity, admission, or discovery. | Hypothesis |
| EM-48 | What unit 100 is on an EMMA (an alias of the gateway, a neighbour, or an unserved address), and what exception 4 denotes there. It answers basic identification with the gateway's reply and refuses the three FC03 reads. | Unknown |

## Overlap with the other Huawei classes

Each row is a probe that another class defines, read on the EMMA path at the
stated place, or an EMMA probe read on another path. The EMMA candidate reads at
unit 0, the SmartLogger candidate reads at unit 0, and the S-Dongle candidate
reads at unit 100. A `not probed` cell is an Unknown cell.

| Probe | Read at | Result | Grade |
| --- | --- | --- | --- |
| SmartLogger counter read (FC03 offset 65521, quantity 1) | EMMA unit 0 | exception 3 | Proven |
| SmartLogger counter read | routed inverter unit 3 | exception 3 | Proven |
| SmartLogger counter read | unit 100, unit 4, and unit 2 | not probed | Unknown |
| EMMA offering read (offset 30000, quantity 15) | routed inverter unit 3 | the inverter's model block of EM-36, which is the child's own identity read, so the read is no discriminator | Proven |
| EMMA model read (offset 30222, quantity 20) | routed inverter unit 3 | 20 words that are not ASCII text, so the EMMA model gate fails | Proven |
| EMMA software read (offset 30035, quantity 15) | routed inverter unit 3 | the firmware block of EM-41, which is the child's own identity read, so the read is no discriminator | Proven |
| The three EMMA reads | unit 100 | not probed | Unknown |
| The three EMMA reads | SmartLogger endpoint, unit 0 | exception 3 on all three ([SmartLogger observation](smartlogger-observed-inventory-v1.md)) | Proven |
| The three EMMA reads | S-Dongle path, unit 0 and child unit 1 | no response at unit 0; the child's own identity texts and non-text data at unit 1 ([S-Dongle observation](sdongle-observed-identity-v1.md)) | Proven |
| S-Dongle basic identification | unit 100 | the EMMA's own reply with product `HEMS`, where the S-Dongle gateway gives exception 1 | Proven |
| S-Dongle protocol-version, search sequence, and capacity reads | unit 100 | exception 4 on all three | Proven |
| S-Dongle search sequence and capacity reads | routed inverter unit 3 | exception 3 on both | Proven |
| S-Dongle protocol-version read | routed inverter unit 3 | two words, 5 then 0, the child's own words, so the read alone is no discriminator | Proven |
| S-Dongle status reads | EMMA unit 0 | not probed | Unknown |
| SunSpec signature read (offset 40000, quantity 2) | EMMA unit 0 and routed inverter unit 3 | two words that are not the SunSpec marker at each | Proven |
| Basic identification | unit 0, unit 100, and unit 3 | the same EMMA reply at all three (EM-13) | Proven |
| SUN2000 identity-contract reads (offsets 30000 and 30035) | EMMA unit 0 | the EMMA's own label and software texts, so the SUN2000 tuple fails | Proven |
| SUN2000 identity-contract reads | routed inverter units 3 and 4 | a different model token and a different firmware text, so the SUN2000 tuple of that contract fails | Proven |
| Growatt probes | any | not issued | Unknown |

| ID | Statement | Grade |
| --- | --- | --- |
| EM-49 | Readability alone is never identity: the EMMA's offsets answer at an inverter with the inverter's own texts or with non-text data, the SunSpec offset answers data at the EMMA and at the inverter without the marker, and basic identification answers at every unit identifier tried with the EMMA's own identity. No read that merely answers selects a class, a model, or a unit. | Proven (basis: the overlap table and EM-13) |
| EM-50 | Basic identification separates the EMMA from the S-Dongle gateway by the product object `HEMS`, and from the SmartLogger by the product object and the vendor case, and never by whether it answers (SD-41, SL-07). The vendor case alone does not separate the EMMA from the S-Dongle child, which also reports `Huawei`. | Proven |
| EM-51 | The protocol words and keys 3 and 6 of the SUN2000 entries do not separate the EMMA's inverters from the SUN2000 units behind the SmartLogger or from the S-Dongle child: all carry 5 then 0 (EM-40) and equal keys 3 and 6 (EM-24). The model block form (EM-37) and the firmware text (EM-41) differ. | Proven |
| EM-52 | An EMMA self entry is a SmartLogger negative control: the counter is refused at the EMMA, the entry's model is not a SmartLogger model, and its device type is `HEMS`. | Proven |

## Refused runs and the non-allowed-client signature

| ID | Statement | Grade |
| --- | --- | --- |
| EM-53 | Four runs, two from each of two capture hosts, each issued 20 requests of the clean-room kind (the EMMA identity reads, basic and extended identification, the overlap probes at units 0 and 100, and a bounded probe of units 1 through 8) before the answered run. None received a Modbus reply: 80 requests and 320 attempts, every connection accepted at the TCP level. | Proven |
| EM-54 | Of the 320 attempts, 311 ended with the peer resetting the connection (259) or closing it (52), a median of about 60 ms after the request was written (90th percentile about 0.2 s, longest about 3.5 s). The other nine attempts timed out at five seconds. Every request kind and every unit addressed ended this way. | Proven |
| EM-55 | The first capture host, which was reset on every request in two runs, had every request answered in the answered run, against the same endpoint. The record carries the same endpoint reference in all five runs; it is not published. | Proven |
| EM-56 | A client that the gateway does not allow is accepted at the TCP level and then reset or closed a few tens of milliseconds after its request, whatever the request kind and unit (the signature of EM-53 and EM-54), and allowing the client ends that behavior. The basis is one before and after pair on one host, with the change between the two reported by the operator and not shown by the record. | Hypothesis |
| EM-57 | The second capture host was reset in both of its runs with the same signature. Whether it was allowed, and why it was reset, is not shown by the record. | Unknown |
| EM-58 | The gateway's allow mechanism and its scope (per address, per port, per protocol), whether anything other than the allowing changed between the refused runs and the answered run (for example Modbus TCP enablement or a session held by another client), and whether every non-allowed client sees this signature. | Unknown |
| EM-59 | In the answered run the first request on the fresh connection was answered on its first attempt, after 72 ms. The first-request non-response of the S-Dongle (SD-33, SD-34) did not occur at the EMMA. | Proven |

A reader that sees a connection reset or closed by the peer after a written
request records a failed attempt with its elapsed time, retains it as native
evidence, and applies its bounded attempt count. It never infers absence,
incompatibility, or a cause from it, never scans units, and never falls back to
another class. The signature on every request is retained as a pattern. It
produces `INSUFFICIENT_EVIDENCE`, and never a class.

## Battery addressing and capability

| ID | Statement | Grade |
| --- | --- | --- |
| EM-60 | The operator describes the installation as having two LUNA2000 batteries. No read of this observation confirms or contradicts the description. | Unknown |
| EM-61 | Whether the batteries appear as registers of the inverters at units 3 and 4, as registers of the EMMA, or at their own units. No battery group read was issued, because it is not defined by a public contract, and no battery unit read was issued, because the listing named no battery unit. | Unknown |
| EM-62 | The EMMA's own capability, monitoring, and load or charger blocks. None was read, so the capability of the observed model variant is Unknown. | Unknown |

## Family contract: EMMA observed gateway tuple

| Field | Contract |
| --- | --- |
| Family | An EMMA energy-management gateway at unit 0. The capability variant is the one that the model token names, and no capability is created by the identity. The inverters behind it have their own contract below, and a child's model never becomes the gateway's. |
| Required tuple | All of the following at gateway unit 0 on one connection generation. FC03 offset 30000, quantity 15: the text `SmartHEMS`, a NUL, and NUL padding over the full 30 bytes. FC03 offset 30222, quantity 20: a text that equals, after terminal NUL padding is stripped, one of the two exact model values that the EMMA candidate of the gateway contract admits, with NUL padding over the full 40 bytes. FC03 offset 30035, quantity 15: `SmartHEMS`, one space, and a version-style text that the candidate's software rule admits: at or above the floor of its own branch, a build that follows it, or a build of a branch with neither a documented floor nor a documented relation, the inherited builds with grade Hypothesis under the [software applicability rule](monitoring-readonly-v1.md#software-applicability); the text is followed by a NUL and NUL padding over the full 30 bytes. The observed build is Proven, and every other build that this rule admits is Hypothesis. The page publishes no model token and no version text, so the exact model comparison is made against the registry fixture, and no prefix, wildcard, or range links two tokens. |
| Optional corroboration | A decodable basic read at unit 0 shows vendor `Huawei`, product `HEMS`, and the version-style text of the software block. The extended inventory from object 0x87 has its first entry (object 0x88) as the self entry, with key 5 exactly `0`, key 1 equal to the model block, key 2 equal to the version-style text of the software block, and key 8 `HEMS`. A decodable corroboration that disagrees with the FC03 tuple is a conflicting detector and produces `INSUFFICIENT_EVIDENCE`. Absence or a decode failure of either read changes nothing, as the gateway contract states for optional MEI. |
| Recorded, not gating | The objects of the basic reply beyond the vendor, product, and version objects, the declared-object field, the next-object field, entry keys 3, 4, 6, 9, and 10, entry padding and key order, the serial-bearing block, and any timing. They are retained as native evidence and select and reject nothing. |
| Forbidden identity | Serial number or ESN (the serial-bearing block, entry key 4, and basic objects 0x10 and 0x1b), a writable alias, readability of any register (including the EMMA offsets answered at an inverter, the SunSpec offset, and the basic reply that every unit identifier returns), a model-register read without the complete tuple, a `SmartHEMS` prefix without an admitted model, basic identification alone, a child listing, the unit identifier of a request, and a prefix, wildcard, case-folded, or whitespace-normalized match. |
| Multiple-positive outcome | `AMBIGUOUS`: another Huawei class contract that is also positive at the same endpoint produces no selection, and no order or priority breaks the tie. The collision rule of the gateway contract gives `insufficient_evidence`. |
| Negative-overlap obligations | Executable fixtures against SmartLogger (the counter read is exception 3 at unit 0 and at an inverter, and the EMMA self entry is a SmartLogger negative control), S-Dongle (the status reads are exception 4 at unit 100 and exception 3 at an inverter, and the basic reply names the product `HEMS`), SunSpec (no marker at unit 0 or at an inverter), and the SUN2000 identity contract (the inverter's model token and firmware text differ from its tuple). Growatt probes are Unknown. The evidence is in the overlap table above. |
| Failure outcome | A missing element; a block that is not ASCII or not NUL padded; an exception on any of the three reads; a request unanswered after its bounded attempts, including a connection reset or closed by the peer after the request was written; a model outside the two admitted values; a software text without the structured form, or below the candidate's floor within its own branch; an offering other than `SmartHEMS`; or a conflicting corroboration produces `INSUFFICIENT_EVIDENCE`, no selected class, and zero native monitoring facts. |
| Outcome when every element is exact | Identity applicability holds for this tuple. The selected class is EMMA with the capability variant that the model token names, the qualification card stays `QUALIFICATION_EVIDENCE_BLOCKED` for its capability evidence, the profile stays default denied, and zero monitoring facts are emitted. In the observation every element matched on one connection, which carried all 26 requests. |

## Family contract: SUN2000-family inverter behind an EMMA

| Field | Contract |
| --- | --- |
| Family | A SUN2000-family inverter at a routed unit behind an EMMA whose gateway tuple above holds. The page publishes no model token, so no specific token is a discriminator and a particular child model stays Unknown here; the registry fixture carries it and the comparison is exact. A battery group is never inferred from an inverter or from the gateway. |
| Required tuple | All of the following at one routed unit `u` on one connection generation. The unit `u` is in 1 through 247, is key 5 of exactly one entry of a validated listing read at unit 0 whose key 8 is `SUN2000`, and is in the operator allowlist. The model block (FC03 offset 30000, quantity 15) holds a printable non-empty model text of the SUN2000 family, a NUL, and then only NUL bytes and printable ASCII to the end of the 30-byte extent, and the text equals key 1 of that entry exactly. |
| Recorded, not gating | The firmware block and the protocol words (5 then 0, encoding Unknown), the residue after the model text, the serial-bearing block, and entry keys 2, 3, 4, 6, and 10. They are retained as native evidence and select and reject nothing. |
| Forbidden identity | Serial number or ESN (entry key 4 and the serial-bearing block), a writable alias, readability of any register (including the EMMA offsets, the S-Dongle protocol-version offset, and the SunSpec offset), any child listing content (label, model, device type, firmware, unit), the gateway's own basic reply addressed to the unit, and a prefix, wildcard, case-folded, or whitespace-normalized match. |
| Multiple-positive outcome | `AMBIGUOUS`: another Huawei class contract that is also positive at the same endpoint and unit produces no selection, and no order or priority breaks the tie. |
| Negative-overlap obligations | Executable fixtures against SmartLogger (the counter read is exception 3), S-Dongle (the search sequence and capacity reads are exception 3, and the protocol read answers and is no discriminator), EMMA (the model gate fails on non-text data), SunSpec (no marker), and the SUN2000 observed tuple of the [SUN2000 identity contract](sun2000-observed-identity-v1.md) (a different model token and firmware text). Growatt is Unknown. The probes ran at unit 3 only, so unit 4 is Unknown (EM-44). |
| Failure outcome | A missing, non-ASCII, excepted, unanswered, or contradictory element, or a model text that differs from key 1 of the entry, produces `INSUFFICIENT_EVIDENCE`, no profile, and zero native monitoring facts. The child is withheld as `identity_insufficient` or `identity_mismatch`, and no sibling and not the gateway is affected. |
| Outcome when every element is exact | Identity applicability holds for the inverter. Profile selection stays `NO_ADMISSIBLE_PROFILE` and zero monitoring facts are emitted. Units 3 and 4 both matched in the observation. |

A provider reads unit 0 for the gateway tuple and reads a child only at a unit
that is in the validated listing and in the operator allowlist (routing rules 1
to 4 of the gateway contract). It never scans, never infers a child address, and
never reads the backup-box unit, which has no class contract. The reads at
unit 100, the overlap reads at unit 3, and the reads at unit 4 beyond the
identity blocks were the plan of the observation, and a provider does not send
them. The gateway contract's guard-counter re-read rule is written for the
SmartLogger counter, which is refused at the EMMA (EM-31). This page defines no
EMMA guard (EM-32). A listing that cannot be bracketed stays unconfirmed and
admits nothing by itself.

### Decision outcomes

| Situation | Outcome |
| --- | --- |
| Every element of the gateway tuple exact | identity applicability holds; the card stays `QUALIFICATION_EVIDENCE_BLOCKED` |
| An exception, a missing reply, or a connection reset or closed after the write on any of the three reads | `INSUFFICIENT_EVIDENCE` |
| Model outside the two admitted values, a SmartLogger-shaped model, or an offering other than `SmartHEMS` | `INSUFFICIENT_EVIDENCE` |
| Software text without the structured form, or below the floor within its own branch | `INSUFFICIENT_EVIDENCE` |
| Software build that follows the floor of its branch and was never observed, or of a branch with neither a documented floor nor a documented relation | identity applicability holds with grade Hypothesis; the card stays `QUALIFICATION_EVIDENCE_BLOCKED` |
| Self entry or basic reply decodable and in disagreement with the FC03 tuple | `INSUFFICIENT_EVIDENCE` |
| Serial number or ESN only, basic identification only, or readability only | `INSUFFICIENT_EVIDENCE` |
| Another Huawei class also positive at the endpoint | `AMBIGUOUS` |
| Child unit listed with device type `SUN2000`, allowed, and its model text equal to key 1 | identity applicability holds for the child; profile `NO_ADMISSIBLE_PROFILE` |
| Child read an exception, not exact, or not equal to key 1 | the child is withheld; siblings and the gateway are unaffected |
| Listed unit with device type `BackupBox` | withheld as `no_class_contract`; no read |
| Allowed unit that is not listed | withheld as `not_listed`; no read and no probe |

## Tolerance requirements

These are observed requirements: a reader that cannot do each of them cannot
read this tuple. Each is a lower bound and none is a cap. They add to the
tolerance requirements of the SmartLogger observation and remove none of them.

1. **Identity blocks.** The text ends at the first NUL, and for the EMMA's own
   three blocks every byte after it is NUL padding to the end of the extent. A
   block with no NUL inside the extent may be truncated and is not matched.
   Basis: EM-02 to EM-04.
2. **Inverter model block.** The text ends at the first NUL. Every byte after
   it must be NUL or printable ASCII, and the residue may reach the end of the
   extent with no trailing padding. It is retained as native evidence and never
   compared or published. Basis: EM-36 and EM-37.
3. **Basic reply.** Decode a reply with eleven objects beyond the basic category
   as received, and retain the extra objects, the ESN-class texts among them, as
   opaque native evidence. The declared-object field equals the objects present
   here and is still never compared. Basis: EM-09 to EM-11.
4. **Declared-object field of the inventory.** Retain it and never compare it;
   completeness comes from the count object, more-follows, and the entries.
   Basis: EM-17 and EM-21.
5. **Entries.** Accept entries that are not NUL padded, of the observed 79 to
   102 bytes; those lengths are lower bounds and not caps. Key order is not
   validated. Keys 9 and 10 are known opaque keys on any entry class, and key 10
   is on the inverter entries here. A key outside the observed set is retained
   as opaque native evidence and does not reject the inventory; repeated keys
   still reject it. Basis: EM-22, EM-24, and EM-25.
6. **Count object.** It counts the entries including the self entry, so the
   child count is the count minus one. Basis: EM-20.
7. **Frame length.** The longest PDU was 118 bytes, within the classic 253-byte
   limit. That length is a lower bound and not a cap: a reader of this tuple
   works within the resource bounds of the gateway contract and does not refuse
   a longer response, such as an oversize page of the kind the SmartLogger
   observation records, for its length alone. Basis: EM-09 and EM-21.
8. **Counter.** The refusal of the SmartLogger counter (exception 3) is no
   failure of the tuple, which does not read it, and the counter is no guard for
   an EMMA listing. Basis: EM-31.
9. **Transport.** A connection reset or closed by the peer after a written
   request is a failed attempt, retained with its elapsed time, and never
   evidence of absence. Basis: EM-53 to EM-56.

Timing is not a requirement. Answers came within tens of milliseconds, one
exception reply took about 0.7 s, and the five inventory pages took about 3.1 s
at the 750 ms gap. They are recorded and never required, and no predicate of
the tuple depends on an elapsed time or an attempt count. How many attempts a
future approved run uses is set by that approval and is bounded.

## Status of the refused runs

The gateway contract and the other observation pages recorded that bounded
attempts at the EMMA received no Modbus reply, and the record now holds four
such runs (EM-53, EM-54). The rule of the
[qualification readiness contract](qualification-readiness-v1.md) is that a
recorded persistent non-response is superseded only by an observation of the
same class, that is, a result of that class that matched its exact tuple. The
answered run matched every element of the gateway tuple above at unit 0 on one
connection, and it addressed the same endpoint as the refused runs (EM-55). It
therefore supersedes the non-response for the identity of this tuple only.

Nothing else is superseded. The refused runs stay on record with their
attempts, the qualification card stays `QUALIFICATION_EVIDENCE_BLOCKED` for its
capability evidence, the profile outcome and the default-denied fields are
unchanged, monitoring is not admitted, and any further live request needs the
operator's approval at action time and a confirmed connection context.
Supersession does not say that the refused requests should have been answered,
and their cause is the Hypothesis EM-56. A result of another class, a failed or
absent EMMA result, and the readability of any register supersede nothing.

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| none | none | none | none |

This page rests on observations only: every graded row comes from the sanitized
observation record, and no vendor document was consulted to write it. The
candidate's admitted model values and software floors, which the family
contract refers to, are carried by the [gateway contract](gateway-readonly-v1.md)
together with the documents they rest on, and are not derived here.

**Copyright note.** Not applicable. No information on this page is derived from
a vendor document.

## Open questions

1. Which of the two admitted model values and which software branch the
   installation reports is withheld here (EM-08). Does the other model value
   exist behind another installation, and what capability variant does each name?
2. Where are the batteries addressed (EM-60, EM-61)? Their registers may sit at
   the inverter units, at the EMMA, or at their own units. No battery group read
   is a public contract, and none was issued.
3. What are the EMMA's own capability, monitoring, and load or charger blocks
   (EM-62)? They are needed before any model-specific capability fixture.
4. What guards an EMMA listing, and does the listing change while it is read
   (EM-31, EM-32)? The SmartLogger counter is refused, so the guard-counter
   re-read rule has no counter on this path.
5. What is the backup-box entry at unit 2, and does it answer any read (EM-30,
   EM-44)? No class contract covers it, and it was never read.
6. Do other units answer, can an inverter sit at an unlisted unit, and does
   unit 4 give the same overlap results as unit 3 (EM-44)? Units 1 and 5 to 8
   were not addressed, because the listing filled the inverter set.
7. What does unit 100 denote on an EMMA, and what does exception 4 mean there
   (EM-48)? Is the exception code a reliable listed or unlisted marker (EM-47)?
8. Does any identification read reach an inverter's own identity through the
   EMMA (EM-15)? The extended inventory was never addressed to a routed unit.
9. What do keys 3, 6, 9, and 10, the protocol words, and the unidentified
   objects of the basic reply encode (EM-26)? Is the declared-object field the
   stream total on every class that lists children (EM-18)?
10. What is the gateway's allow mechanism and its scope, did anything besides
    the allowing change between the refused and the answered runs, and why was
    the second capture host reset (EM-56 to EM-58)?
11. Does a power meter appear behind an EMMA? None was listed (EM-29, and PM-10
    of the [power-meter contract](gateway-power-meter-v1.md)). SmartLogger counter
    reads at unit 100, S-Dongle status reads at unit 0, and Growatt probes have
    no evidence.
