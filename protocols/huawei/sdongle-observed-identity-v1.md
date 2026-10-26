# Huawei S-Dongle Observed Single-Inverter Identity V1

## Scope and evidence basis

This page records what two bounded, read-only observations of one
operator-owned S-Dongle fronting one SUN2000-family inverter established about
the gateway unit, the child inverter unit, the neighbouring units, and the
overlap with the other Huawei classes. Both were taken with the operator's
approval at action time, after the persistent non-response recorded in the
[S-Dongle qualification disposition](../../architecture/sdongle-qualification-disposition-v1.md).
It is the observation record behind the S-Dongle entry of the
[gateway contract](gateway-readonly-v1.md) and behind the supersession rule of
the [qualification readiness contract](qualification-readiness-v1.md). It
defines no monitoring register, decoder, acquisition schedule, or registry
behavior, and it creates no admission. The registry companion is
helianthus-modbusreg issue 351 and its pull request 352. The historical V1 name
implies no stability before Helianthus 1.0.

Both runs issued only FC03 holding-register reads and FC2B / MEI 0x0e
device-identification reads, on one connection each. Every request was already
defined by the public gateway contract, the SmartLogger observation, the SUN2000
identity contract, or the Modbus application protocol. None writes, configures,
or controls, no private function code was sent, and extended inventory was never
addressed to the gateway unit. An attempt had a deadline of five seconds, and a
request was tried at most four times. The first run read the gateway unit and
probed units 0 through 3 and the overlap offsets, and the second run read the
child unit. This page names families and does not publish model tokens. Serial
numbers, ESNs, the residue after the model text, firmware and version-style
texts, binary values of unidentified meaning, the third word of the search
sequence, the capacity value, endpoints, addresses, times, and captures are not
published either.

| Grade | Meaning on this page |
| --- | --- |
| Proven | The sanitized observation record shows exactly this for the observed installation. It is not a statement about other installations, firmware, or models. |
| Hypothesis | The structure was observed but not correlated by a second independent reading, or the statement is an inference from observed structure. |
| Unknown | No evidence. |

The grades match those of the [SmartLogger observation](smartlogger-observed-inventory-v1.md)
and are separate from parser acceptance, identity matching, admission,
qualification, and support. Nothing here changes `catalog_registered=false`,
`automatic_runtime_admission=false`, `live_qualified=false`,
`support_claim=false`, or `write_authority=false`. The registry companion
re-creates the Proven rows as synthetic fixtures; no capture is published.

## Gateway unit 100

| ID | Statement | Grade |
| --- | --- | --- |
| SD-01 | Four holding-register reads at unit 100 were answered with data on the first attempt, each within tens of milliseconds: search status (FC03 offset 37411, quantity 1), protocol words (offset 30068, quantity 2), search sequence (offset 37410, quantity 3, read twice), and capacity (offset 37429, quantity 1). | Proven |
| SD-02 | Basic device identification (FC2B / MEI 0x0e, read code 1) at unit 100 is refused with exception 1 (illegal function). No vendor, product, model, or firmware object was returned. | Proven |
| SD-03 | The search status read returned one word, 0. | Proven |
| SD-04 | The value 0 means that the device search is complete. The gateway contract's candidate requires a completed search, and this observation shows the value but does not read its coding independently. | Hypothesis |
| SD-05 | The protocol words at unit 100 read 50 then 0. The same read at unit 1 gives 5 then 0 (SD-16), so one register answers differently by unit. | Proven |
| SD-06 | What the protocol words encode, including whether they form one 32-bit value and how they relate to the protocol baseline that the gateway contract's candidate names. | Unknown |
| SD-07 | The search sequence read type word 4, state word 0, and a non-zero third word, and all three words were equal in a read before and a read after the probes of units 0 through 3. Equality is a guard, not proof that nothing changed in between. | Proven |
| SD-08 | The sequence stays equal across the child's basic and extended identification reads. No read at unit 100 brackets them, because they were taken in the second run. | Unknown |
| SD-09 | The capacity read returned one word of at least 1. | Proven |
| SD-10 | No read at unit 100 returned a vendor, product, model, or firmware string, so the tuple on this page has no gateway model variant. | Proven |
| SD-11 | The gateway's product, model, and firmware. | Unknown |
| SD-12 | The outcome of an extended inventory read at unit 100. It was never sent, because the gateway contract does not permit it. | Unknown |

## Child unit 1

| ID | Statement | Grade |
| --- | --- | --- |
| SD-13 | The model block (FC03 offset 30000, quantity 15: 30 bytes) holds a model token of the SUN2000 family, a NUL, printable ASCII residue, and then NUL padding to the end of the extent. | Proven |
| SD-14 | The units behind the SmartLogger hold only NUL padding after the model text (the model row of the read table in the [SUN2000 identity contract](sun2000-observed-identity-v1.md)), so the residue is a difference in form between the two paths. The residue content is withheld, is never a predicate, and is retained as native evidence at runtime. | Proven |
| SD-15 | The firmware block (offset 30035, quantity 15) holds text followed by NUL padding. Its text is withheld and is not a predicate. | Proven |
| SD-16 | The protocol words (offset 30068, quantity 2) read 5 then 0, equal to those of units 1 through 8 behind the SmartLogger (SU-01) and different from the gateway's (SD-05). | Proven |
| SD-17 | The serial-bearing block (offset 30015, quantity 10: 20 bytes) holds ASCII text followed by NUL padding. It is never published and never a predicate. | Proven |
| SD-18 | Basic identification (read code 1) returned conformity 0x01, no continuation, and six objects: 0x00 vendor `Huawei`, 0x01 product `SUN2000` (the family, without a model), 0x02 a version-style text that is present and withheld, and 0x03, 0x15, and 0x17 as two-byte binary values of unidentified meaning, which are withheld. | Proven |
| SD-19 | The vendor object differs in case from the SmartLogger's vendor object `HUAWEI` (SL-04). | Proven |
| SD-20 | The basic reply carries objects outside the basic category (0x03, 0x15, and 0x17), two of them (0x15 and 0x17) in the reserved range 0x07 to 0x7f, and no serial-like object. The SmartLogger's basic reply carried twelve objects (SL-05). | Proven |
| SD-21 | The extended inventory (read code 3, start object 0x87) completed in one page with conformity 0x03, more-follows 0x00, next-object field 0x87, a declared-object field of 2 that equals the two objects present, and a response of 87 bytes. | Proven |
| SD-22 | The next-object field is set while more-follows is 0x00, which the [tolerant decoding vocabulary](../modbus/tolerant-tcp-modes-v1.md) names `next_object_without_more_follows`. | Proven |
| SD-23 | The two objects are the count object 0x87 (length 1, value 1) and one entry object 0x88. | Proven |
| SD-24 | The entry is 75 bytes of `key=value` pairs separated by `;`, not NUL padded, with keys 1 through 6 in that order, and with no key 8, 9, or 10. | Proven |
| SD-25 | Key 5 of the entry is `1`, the unit that was read, and key 1 equals the model token of the model block (SD-13). | Proven |
| SD-26 | Keys 3 and 6 carry version-style texts that equal those on the inverter entries of the SmartLogger observation. Key 2 is firmware text and key 4 is ESN-class. All values are withheld and none is a predicate. | Proven |
| SD-27 | The one entry is the child's own entry, as the SmartLogger's self entry is the gateway's. | Hypothesis |
| SD-28 | Whether the S-Dongle lists its children at any unit, and how a provider learns the child unit without a scan. | Unknown |

## Neighbouring units and the silent unit

| ID | Statement | Grade |
| --- | --- | --- |
| SD-29 | Units 2 and 3 answered the model-block read with exception 4 (server device failure). | Proven |
| SD-30 | Unit 0 gave no response to any of the five requests addressed to it (the model-block read, the SmartLogger counter read, and the three EMMA reads), each tried four times at the five-second deadline. There was no exception and no data. | Proven |
| SD-31 | Only units 0, 1, 2, 3, and 100 were addressed. The probe of units 0 through 3 was the plan of the observation and is not a contract operation. | Proven |
| SD-32 | Whether any other unit answers, whether an inverter sits at another unit, whether the S-Dongle fronts more than one inverter, and what exception 4 at units 2 and 3 denotes. | Unknown |

## First request and the recorded stop

| ID | Statement | Grade |
| --- | --- | --- |
| SD-33 | In each run the first request on the single connection was unanswered at its five-second deadline, and the repeat on the same connection was answered within tens of milliseconds: the basic identification at unit 100 (exception 1) in the first run, and the model-block read at unit 1 in the second. Every subsequent request to units 1, 2, 3, and 100 was answered on its first attempt. | Proven |
| SD-34 | The first request on a fresh connection may go unanswered once, and a repeat on the same connection is then answered. This is a lead from two observations with different first requests; its cause is not established. | Hypothesis |
| SD-35 | A reader that makes one attempt per request records those two first requests as non-response. | Proven |
| SD-36 | The persistent non-response recorded in the disposition did not reproduce: all six requests at unit 100 were answered, five with data and one with exception 1, and one of them only on its repeat. | Proven |
| SD-37 | Why the requests of the recorded stop went unanswered, and whether SD-34 explains it. | Unknown |

## Overlap with the other Huawei classes

Each row is a probe that another class defines, read on the S-Dongle path at the
stated place. The SmartLogger, SunSpec, and EMMA candidates read at unit 0 or at
a routed unit, and the gateway candidate reads at unit 100.

| Probe | Read at | Result | Grade |
| --- | --- | --- | --- |
| SmartLogger counter read (FC03 offset 65521, quantity 1) | child unit 1 | exception 2 | Proven |
| SmartLogger counter read | unit 0 | no response | Proven |
| SmartLogger counter read | gateway unit 100 | not probed | Unknown |
| EMMA offering read (offset 30000, quantity 15) | child unit 1 | the model block of SD-13, which is the child's own identity read, so the read is no discriminator | Proven |
| EMMA model read (offset 30222, quantity 20) | child unit 1 | 20 words that are not ASCII text, so the EMMA model gate fails | Proven |
| EMMA software read (offset 30035, quantity 15) | child unit 1 | the firmware block of SD-15, which is the child's own identity read | Proven |
| The three EMMA reads | unit 0 | no response | Proven |
| SunSpec signature read (offset 40000, quantity 2) | child unit 1 | two words that are not the SunSpec marker | Proven |
| S-Dongle search sequence read (offset 37410, quantity 3) | child unit 1 | data: type word 4 and state word 0 as at the gateway, and a third word of 0 where the gateway's is non-zero | Proven |
| S-Dongle capacity read (offset 37429, quantity 1) | child unit 1 | data, equal to the gateway's word | Proven |
| Basic identification | unit 100 and unit 1 | exception 1 at unit 100, and the SUN2000 identity of SD-18 at unit 1 | Proven |
| Growatt probes | any | not issued | Unknown |
| S-Dongle protocol-version, search, and capacity reads | EMMA path, unit 100 | exception 4 on all three ([EMMA observation](emma-observed-identity-v1.md)) | Proven |
| S-Dongle search and capacity reads | EMMA path, routed inverter unit 3 | exception 3 on both | Proven |
| S-Dongle basic identification | EMMA path, unit 100 | the EMMA's own identity with product `HEMS`, where the S-Dongle gateway gives exception 1 | Proven |
| S-Dongle status reads | EMMA path, unit 0 | not probed | Unknown |

| ID | Statement | Grade |
| --- | --- | --- |
| SD-38 | The S-Dongle's own search sequence and capacity registers answer at the child as well as at the gateway, whereas the same reads give exception 3 at a routed unit behind the SmartLogger. A read of them does not bind a match to unit 100 by itself. | Proven |
| SD-39 | The EMMA model offset and the SunSpec signature offset answer data at the child that identifies neither an EMMA nor a SunSpec device, and the EMMA offering and software offsets answer the child's own identity texts. | Proven |
| SD-40 | Readability alone is never identity: no read that merely answers selects a class, a model, or a unit. | Proven (basis: SD-38 and SD-39) |
| SD-41 | Basic identification separates the paths by the content of its objects and by unit, never by whether it answers: it is refused at the gateway unit, returns the SUN2000 identity at the child, and returns the logger's own identity at every unit identifier behind the SmartLogger (SL-07). | Proven |
| SD-42 | The protocol words and the version-style texts do not separate the S-Dongle child from the SUN2000 units behind the SmartLogger: both carry 5 then 0 (SD-16) and equal keys 3 and 6 (SD-26). | Proven |

## Family contract: S-Dongle observed single-inverter tuple

| Field | Contract |
| --- | --- |
| Family | An S-Dongle gateway fronting one SUN2000-family inverter. The gateway names no product, so the tuple has no gateway model variant (SD-10), and the child's model never becomes the gateway's. |
| Required tuple | All of the following at the stated units on one connection generation. Gateway unit 100: basic identification (FC2B / MEI 0x0e, read code 1) is answered with exception 1; FC03 offset 37411, quantity 1, reads 0; FC03 offset 30068, quantity 2, reads 50 then 0, compared as words and never decoded, because their encoding is Unknown (SD-06), and once an observation establishes it the comparison takes the floor form of the consulted editions' note, the same main revision with a release revision from the observed one onward; FC03 offset 37410, quantity 3, has state word 0 (the equality of the sequence across the child identification reads was not observed, SD-08, and is not part of the tuple); FC03 offset 37429, quantity 1, reads at least 1. Child unit 1: the model block (FC03 offset 30000, quantity 15) is a printable non-empty model text of the SUN2000 family, a NUL, optional printable residue, and NUL padding over the full 30 bytes; basic identification (read code 1) carries vendor exactly `Huawei`, product exactly `SUN2000`, and a present version object, each object once; the extended inventory from object 0x87 (read code 3) is one page with conformity 0x03 and no continuation, whose count object equals the number of entry objects that follow it from 0x88 (the entry count is the value of the count object, and the observed count of 1, one entry, is a lower bound and not a cap, SD-23), in which every entry carries at least the observed keys 1 through 6, each once, and names a distinct unit in key 5, exactly one entry names the unit `1`, and that entry's key 1 equals the model text; a key beyond the observed set is unknown to this page and is never grounds for refusal, and on the child's entry it is retained as opaque native evidence and reported; a further entry is native listing evidence and is never read; and a repeated key rejects the entry. The page publishes no model token, so no specific token is a discriminator of the tuple and a particular child model stays Unknown; no prefix, wildcard, or range links two tokens. |
| Recorded, not gating | The type word of the search-sequence read at unit 100 (observed as 4; the consulted editions name that word the network connection type, a configuration value, and list values that do not include 4), the child's firmware text and protocol words, entry keys 2, 3, 4, and 6, any key beyond them, the version object of the basic reply, objects beyond the basic category, the capacity value beyond the lower bound above, the residue after the model text, the declared-object field, the next-object field, entry padding, entry key order, and any timing. They corroborate and are retained as native evidence; they select and reject nothing. |
| Forbidden identity | Serial number, ESN (entry key 4 and the serial-bearing block), writable alias, readability of any register (including the S-Dongle's own registers answered at the child, the EMMA offsets, and the SunSpec offset), readability of unit 100 or search status alone, basic identification alone, a child listing, the unit identifier of a request, and a prefix, wildcard, case-folded, or whitespace-normalized match. |
| Multiple-positive outcome | `AMBIGUOUS`: another Huawei class contract that is also positive at the same endpoint produces no selection, and no order or priority breaks the tie. The collision rule of the gateway contract gives `insufficient_evidence`. |
| Negative-overlap obligations | Executable fixtures against SmartLogger (the counter read at the child is an exception and at unit 0 is silent; the basic reply at the child is its own SUN2000 identity), EMMA (the model gate fails on non-text data and unit 0 is silent), SunSpec (no marker), and the SUN2000 identity contract (a different model-block form). Growatt probes are Unknown, and S-Dongle probes at an EMMA endpoint are refused at unit 100 and at an inverter (Proven), with the status reads at the EMMA's unit 0 Unknown. The evidence is in the overlap table above. |
| Failure outcome | A missing element, an exception other than the required refusal at the gateway unit, a request unanswered after its bounded attempts, or a contradictory element produces `INSUFFICIENT_EVIDENCE`, no selected class, and zero native monitoring facts. |
| Outcome when every element is exact | Identity applicability holds for this tuple. The selected class is S-Dongle with no model variant, the child's entry, and any further entry, is native listing evidence and no child list is retained, the profile outcome stays `PRE_LIVE_INSUFFICIENT_EVIDENCE`, and zero monitoring facts are emitted. Applied to a run, every element must match on one connection generation. The two observation runs used separate connections, one for the gateway unit and one for the child unit, so the complete tuple was not matched on a single connection generation by them; a future approved run must match it whole. The recorded persistent non-response is superseded for this identity only by a run in which this whole tuple matched on one connection generation, as the [qualification readiness contract](qualification-readiness-v1.md) states; neither the gateway-unit result alone nor the child result alone supersedes it. |

A provider addresses only unit 100 and unit 1 for this tuple. It never reads
unit 0, units 2 and 3, or any other unit, never scans, and never infers a child
address; the probes of SD-29 to SD-31 were the plan of the observation. The
extended inventory is addressed to the child only, never to the gateway unit.

### Decision outcomes

| Situation | Outcome |
| --- | --- |
| Every element of the required tuple exact | identity applicability holds; the disposition outcome stays `PRE_LIVE_INSUFFICIENT_EVIDENCE` |
| Basic identification at unit 100 answers with a reply instead of exception 1 | `INSUFFICIENT_EVIDENCE` |
| Gateway reads exact and no child identity, or a child model text that is not printable, not of the SUN2000 family, or not equal to entry key 1 | `INSUFFICIENT_EVIDENCE` |
| Child inventory missing, logger-shaped, with a count object that differs from the entry objects present, with entries that share a unit or none that names the unit read, or with an entry that lacks any of keys 1 through 6 or repeats a key | `INSUFFICIENT_EVIDENCE` |
| Further entries that each carry keys 1 through 6 at distinct units, or a key beyond 1 through 6 on an entry | no change to the outcome; neither is grounds for refusal, a further entry is never read, and a key beyond 1 through 6 on the child's entry is retained as opaque native evidence and reported |
| Entry key 5 differs from the unit read, or entry key 1 differs from the model block | `INSUFFICIENT_EVIDENCE` |
| Serial number or ESN only, or readability only | `INSUFFICIENT_EVIDENCE` |
| Another Huawei class also positive at the endpoint | `AMBIGUOUS` |

## Tolerance requirements

These are observed requirements: a reader that cannot do each of them cannot
read this tuple. Each is a lower bound and none is a cap. They add to the
tolerance requirements of the SmartLogger observation and remove none of them.

1. **Model block.** The text ends at the first NUL. Every byte after it must be
   printable ASCII followed only by NUL padding, and the residue is retained as
   native evidence and never compared or published. A block with no NUL inside
   the extent may be truncated and is not matched. Basis: SD-13 and SD-14.
2. **Next-object field.** Accept a set next-object field next to more-follows
   0x00 as the anomaly `next_object_without_more_follows`; retain it and never
   compare it. Basis: SD-21 and SD-22.
3. **Declared-object field.** Retain it and never compare it; completeness comes
   from the count object, more-follows, and the entry. Basis: SD-21 and SL-11.
4. **Basic reply.** Decode a reply with objects beyond the basic category as
   received and retain the extra objects as opaque native evidence. Basis: SD-20
   and the fourth tolerance requirement of the SmartLogger observation.
5. **Entries and count.** Accept an entry that is not NUL padded and is shorter
   than the 254-byte entries of the SmartLogger observation (75 bytes here);
   padding is accepted and not required. Key order is not validated. The entry
   count is the value of the count object, and the observed count of 1 is a
   lower bound and not a cap: a reader of this tuple accepts more entries within
   the resource bounds of the [gateway contract](gateway-readonly-v1.md) and
   reads none of them. The observed keys 1 through 6 are a lower bound too: a
   key beyond them is never grounds for refusal, and on the child's entry it is
   retained as opaque native evidence and reported, whereas repeated keys still
   reject the inventory. The gateway catalogue (helianthus-modbusreg issues 361 and 366)
   records the descriptor attributes that each edition defines, and key 6 is
   never decoded (RC-02 of the gateway contract). Basis: SD-23 and SD-24.
6. **Frame length.** The longest response was 87 bytes, within the classic
   253-byte limit. That length is a lower bound and not a cap: a reader of this
   tuple works within the resource bounds of the gateway contract and does not
   refuse a longer response, such as an oversize page of the kind the
   SmartLogger observation records, for its length alone. Basis: SD-21.

Timing is not a requirement. The first-request behavior of SD-33 and SD-34 is
recorded and never required, and no predicate of the tuple depends on an
elapsed time or an attempt count. How many attempts a future approved run uses
is set by that approval and is bounded.

## Hard-stop status

The recorded stop was a persistent non-response at unit 100. SD-36 shows that
requests of the kinds that expired were answered at unit 100 in this
observation, so the non-response did not reproduce. The two observation runs
used separate connections, one for the gateway unit and one for the child unit,
and so did not match the complete tuple on one connection generation. They
therefore leave the stop in force: a consumer clears it for the identity of this
tuple only when a future approved run matches every element of the required
tuple on one connection generation. The gateway-unit result alone, however
exact, is a result of the same class that did not match the complete tuple, and
supersedes nothing. The sequence bracket around the child identification reads
(SD-08) is not part of the tuple and stays Unknown. The
[qualification readiness contract](qualification-readiness-v1.md) states the
rule: a recorded persistent non-response is superseded only by an observation of
the same class that matched its exact tuple. Once such a run exists, the record
stays on record, the profile outcome and the default-denied fields are
unchanged, monitoring is not admitted, and any further live request needs the
operator's approval at action time and a confirmed connection context.

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| SDongle V200R025C00SPC120 MODBUS Interface Definitions | Issue 01 | 2025-12-23 | the network connection type that the type word carries and its listed values, and the main and release revisions of the protocol-version note, both in the family contract (p. 9) |
| SDongle V200R022CC10 MODBUS Interface Definitions | Issue 02 | 2023-04-20 | the network connection type that the type word carries and its listed values, and the main and release revisions of the protocol-version note, both in the family contract (p. 9) |
| Huawei gateway Modbus reference | reference baseline 2026-10-26.1 | 2026-10-26 | locating the type word and the protocol-version note in the two documents above |

Every graded row of this page comes from the two sanitized runs, and no row is
graded from a document. The documents above give the family contract two notes
only: why the type word is recorded and not compared, and the form that the
protocol-word comparison takes once the encoding is known. No table, label, or
text of the documents is reproduced here.

**Copyright note.** The information on this page that is derived from the
SDongle documents listed above is attributed to Huawei Digital Power
Technologies Co., Ltd., which retains the copyright in those documents. This
page states that information in its own words and does not reproduce the
documents. The CC0-1.0 dedication of this page covers its own expression only
and does not relicense those documents.

**Reference note.** The facts that the Documents consulted section attributes
to the Huawei gateway Modbus reference were taken through that independent
documentary work, whose contributors dedicate its original writing under
CC0-1.0. The vendor documents it cites keep their rights, as the copyright note
states. This page restates those facts in its own words and carries over none
of the reference's engineer-review or operational-authorization clauses.

## Open questions

1. What is the gateway's product, model, and firmware (SD-11)? Until a read
   names it, the tuple has no model variant and the product-string gap stays
   open.
2. What do the protocol words encode (SD-06), and does the search state value 0
   mean a completed search (SD-04)?
3. Does the search sequence stay equal across the child's extended inventory
   read (SD-08)? That bracket was not observed.
4. Which unit names the child without a scan, and does the S-Dongle list its
   children at any unit (SD-28)? Extended inventory at unit 100 is not
   permitted, and its outcome is Unknown (SD-12).
5. Do other units answer, can an S-Dongle front more than one inverter, and what
   does exception 4 denote (SD-32)? Only units 0, 1, 2, 3, and 100 were
   addressed.
6. Is the first-request behavior a property of a fresh connection (SD-34), and
   did it cause the recorded stop (SD-37)? Two observations with different first
   requests are a lead only.
7. Is a battery group attached to the child, and which model tokens and firmware
   texts of the SUN2000 family exist behind an S-Dongle? No group read was
   issued and one child was observed, so both are Unknown.
8. S-Dongle status reads at the EMMA's unit 0, SmartLogger counter reads at
   unit 100, and Growatt probes have no evidence. The EMMA path is recorded on
   the [EMMA observation](emma-observed-identity-v1.md), which also records the
   S-Dongle probes refused there at unit 100 and at an inverter.
9. Does a power meter appear behind an S-Dongle? None was observed (PM-08 of the
   [power-meter contract](gateway-power-meter-v1.md)).
