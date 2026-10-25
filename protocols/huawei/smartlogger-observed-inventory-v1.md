# Huawei SmartLogger Observed Identity and Inventory V1

## Scope and evidence basis

This page records what bounded, read-only observation of one operator-owned
installation of the SmartLogger family established about gateway identity, the
extended device inventory, and child addressing. It is the observation record
behind the exact entry and the child-routing rules in the
[gateway contract](gateway-readonly-v1.md). It defines no monitoring register,
decoder, acquisition schedule, or registry behavior, and it creates no
admission. The historical V1 name implies no stability before Helianthus 1.0.

Three passes issued only FC03 holding-register reads and FC2B / MEI 0x0e device
identification reads, with one request in flight and a fixed gap of 750 ms
between requests. Every request was already defined by the public gateway
contract, the public SunSpec contract, or the Modbus application protocol. None
was taken from vendor-authored material, and none writes, configures, or
controls. Serial numbers, ESNs, sensitive attribute values, codes of
unidentified meaning, endpoints, addresses, times, and captures are not
published. The strings below are product identity, not installation identity.

| Grade | Meaning on this page |
| --- | --- |
| Proven | The sanitized observation record shows exactly this for the observed installation. It is not a statement about other installations, firmware, or models. |
| Hypothesis | The structure was observed but not correlated by a second independent reading, or the statement is an inference from observed structure. |
| Unknown | No evidence. |

Grades are separate from parser acceptance, identity matching, admission,
qualification, and support. Nothing here changes `catalog_registered=false`,
`automatic_runtime_admission=false`, `live_qualified=false`,
`support_claim=false`, or `write_authority=false`. The registry companion
re-creates the Proven rows as synthetic fixtures; no capture is published.

## Gateway identity at unit 0

| ID | Statement | Grade |
| --- | --- | --- |
| SL-01 | Register reads at the gateway unit 0 are answered, each within 15 to 45 ms. | Proven |
| SL-02 | The change-counter read (FC03 offset 65521, quantity 1) returned the same single U16 value on all six reads: before and after the inventory in each of the three passes. | Proven |
| SL-03 | The counter value changes when the listing changes. | Unknown |
| SL-04 | A basic device-identification read (read code 1) at unit 0 returned vendor object `HUAWEI`, product object `Smart Logger` (one space between the words), and a 17-character version object `V300R023C10SPC620`. | Proven |
| SL-05 | The basic reply carried twelve objects (identifiers 0x00 to 0x03, 0x10 to 0x15, 0x17, and 0x19) instead of the three basic objects, with conformity 0x01 and no continuation. | Proven |
| SL-06 | The extended self entry (the first entry object) carries model attribute `Smart Logger`, firmware attribute `V300R023C10SPC620`, and unit attribute `0`. Its model and firmware equal the basic reply's product and version objects. | Proven |
| SL-07 | A basic read answers with the gateway's own identity when the request names unit 0, 1, or 100, so the unit identifier of an MEI request selects no device. Other unit identifiers were not tried. | Proven |
| SL-08 | The observed model value differs by one space from the documentary self-entry model `SmartLogger`, and the observed firmware is outside the two documentary firmware values. | Proven |
| SL-09 | Other firmware of the family reports its model with or without the space. | Unknown |

The counter stayed constant but never moved, so SL-03 stays Unknown: equality
before and after a read is a guard, not proof that no change occurred in
between, and a U16 counter can wrap.

## Extended inventory paging

The extended read starts at object 0x87 and follows the continuation fields.
The observed trace, in sizes only:

| Request cursor | More | Next object | PDU bytes | Objects present | Content |
| --- | --- | --- | --- | --- | --- |
| 0x87 | 0xff | 0x88 | 10 | 1 | count object, value 12 |
| 0x88 through 0x92 (11 requests) | 0xff | cursor plus 1 | 263 | 1 | one 254-byte entry object |
| 0x93 | 0x00 | 0x00 | 263 | 1 | the last entry object |

| ID | Statement | Grade |
| --- | --- | --- |
| SL-10 | One pass enumerated the whole inventory in 13 requests (cursors 0x87 through 0x93), each answered on the first attempt. | Proven |
| SL-11 | Each response carries exactly one object, while its declared-object field reads 13 in every response. The field is therefore not a per-response count. | Proven |
| SL-12 | The declared-object field equals the number of objects in the whole stream (the count object plus twelve entries). | Hypothesis |
| SL-13 | The count object has length 1 and value 12, equal to the number of entry objects (0x88 through 0x93) including the self entry. | Proven |
| SL-14 | The twelve entry responses are 263-byte PDUs (MBAP length field 264) holding one 254-byte object each, 10 bytes above the classic 253-byte PDU limit. Twelve of the 13 responses are oversize. | Proven |
| SL-15 | A strict reader (classic frame limit, declared-object field compared with objects present, basic reply limited to the basic category) stopped the first pass at the basic reply and the first extended response, and the second pass at the first oversize response. It would reject every response of the third pass. | Proven |
| SL-16 | Next object is the requested cursor plus 1 on every response with More 0xff; the last response has More 0x00 and Next object 0x00. | Proven |
| SL-17 | The inventory plus its two counter reads (15 exchanges) completed in under 11 s at the 750 ms gap; each exchange itself took about 16 ms. | Proven |

### Tolerance requirements

These are observed requirements: a reader that cannot do each of them cannot
read this logger's inventory. They narrow the existing ceilings of 15 seconds,
248 pages, 248 objects, 65536 response bytes, and 247 children; they do not
remove them, and anything beyond a ceiling is still insufficient evidence.

1. **Frame length.** Accept FC2B / MEI 0x0e responses with a PDU of at least 263
   bytes (MBAP length field at least 264). The classic 253-byte PDU limit and
   the 254 stream limit are not applied to this function. Observation fixes only
   the lower bound; the finite upper cap is chosen and documented by the
   consuming registry and is otherwise Unknown. Basis: SL-14.
2. **Declared-object field.** Do not require it to equal the number of objects
   present. Completeness comes from the count object, `More`, `Next object ID`,
   and a final `More` of 0x00. Basis: SL-11.
3. **Entry length.** Accept one object of up to 254 bytes per response. Basis:
   SL-14.
4. **Basic reply.** Decode a basic reply with objects beyond the basic category
   as received and retain the extra objects as opaque native evidence. A basic
   reply that cannot be decoded neither negates nor supplies identity. Basis:
   SL-05.
5. **Count.** The count object counts entries including the self entry, so the
   child count is the count minus one. Basis: SL-13.
6. **Attribute keys.** Keys 9 and 10 are known opaque keys, and key order inside
   an entry is not numeric and is not validated. Other unknown keys and repeated
   keys still reject the inventory. Basis: the encoding table below.

## Entry encoding

Each entry object is text made of `key=value` pairs separated by `;`, followed
by NUL bytes up to the object length of 254. The observed padding is 164 to 187
bytes. A synthetic template with placeholders:

```text
1=<model>;2=<firmware>;3=<opaque>;4=<sensitive>;5=<unit>;8=<product type>;9=<opaque>
```

| Key | Observed content | Present on | Role in this contract | Grade |
| --- | --- | --- | --- | --- |
| 1 | model or family string | all twelve entries | native listing evidence; never identity | Proven |
| 2 | firmware string, 17 characters on the self entry, the inverters, and the PLC; 16 characters on the meters | all twelve entries | native listing evidence; never identity | Proven |
| 3 | short version-like text, constant within a class (the [qualification card](qualification-readiness-v1.md) calls it protocol version) | all twelve entries | opaque | Hypothesis |
| 4 | sensitive native identity input | all twelve entries | retained as native evidence at runtime, never published, never a predicate | Proven |
| 5 | unsigned decimal unit identifier | all twelve entries | the routing address | Proven |
| 6 | short version-like text, constant within a class (the card calls it feature version) | all twelve entries | opaque | Hypothesis |
| 8 | product type, observed only as `SUN2000` | the eight inverter entries only | listing label; never identity | Proven |
| 9 | small integer, value 0 on all twelve entries | all twelve entries | opaque | Unknown |
| 10 | short code of unidentified meaning, treated as sensitive | the self entry only | opaque; never published | Unknown |

The Grade of a key row grades its presence, content class, and role; Unknown
means the meaning of the value is not established. Key sets by entry class, in
the order observed: self entry `1;2;3;4;5;6;10;9`, inverter `1;2;3;4;5;6;8;9`,
PLC and meter `1;2;3;4;5;6;9`. Key 10 precedes key 9 on the self entry.

## Listing contents

This table is a synthetic re-creation of the sanitized routing table. The unit
column is attribute 5; the order column is the object order of the listing.

| Object | Label (key 1) | Unit | Product type (key 8) | Firmware (key 2) |
| --- | --- | --- | --- | --- |
| 0x88 | `Smart Logger` | 0 | none | `V300R023C10SPC620` |
| 0x89 | `SUN2000-50KTL-M3` | 2 | `SUN2000` | `V200R023C00SPC128` |
| 0x8a | `SUN2000-50KTL-M3` | 3 | `SUN2000` | `V200R023C00SPC128` |
| 0x8b | `SUN2000-50KTL-M3` | 4 | `SUN2000` | `V200R023C00SPC128` |
| 0x8c | `SUN2000-50KTL-M3` | 5 | `SUN2000` | `V200R023C00SPC128` |
| 0x8d | `SUN2000-50KTL-M3` | 6 | `SUN2000` | `V200R023C00SPC128` |
| 0x8e | `SUN2000-50KTL-M3` | 7 | `SUN2000` | `V200R023C00SPC128` |
| 0x8f | `SUN2000-50KTL-M3` | 8 | `SUN2000` | `V200R023C00SPC128` |
| 0x90 | `PLC` | 9 | none | present, 17 characters |
| 0x91 | `SUN2000-50KTL-M3` | 1 | `SUN2000` | `V200R023C00SPC128` |
| 0x92 | `PowerMeter` | 11 | none | present, 16 characters |
| 0x93 | `PowerMeter` | 19 | none | present, 16 characters |

All rows are Proven for the observed installation: one gateway, eight
inverters, one PLC, and two meter entries, twelve entries in all.

## Device-type vocabulary

| Observed label | Where | Entries | Units | Consequence in this contract | Grade |
| --- | --- | --- | --- | --- | --- |
| `Smart Logger` | key 1 of the self entry | 1 | 0 | the gateway's own entry; the observed tuple in the gateway contract | Proven |
| `SUN2000` | key 8 | 8 | 1 through 8 | a listing label; identity is read at the routed unit under the [SUN2000 contract](sun2000-observed-identity-v1.md) | Proven |
| `SUN2000-50KTL-M3` | key 1 of the inverter entries | 8 | 1 through 8 | listing model, compared by exact equality with the routed model read | Proven |
| `PLC` | key 1, no key 8 | 1 | 9 | no class contract exists; the unit is withheld | Proven |
| `PowerMeter` | key 1, no key 8 | 2 | 11 and 19 | a class label, not a model; see the [power-meter contract](gateway-power-meter-v1.md) | Proven |

Key 8 appears only on inverter entries, so its absence says nothing beyond key
1. What a PLC entry is, which other labels or key 8 values other device classes
use, and whether any other class appears in a listing are Unknown.

## Child addressing evidence

| ID | Statement | Grade |
| --- | --- | --- |
| CA-01 | Key 5 of the eight `SUN2000-50KTL-M3` entries is 1 through 8, and exactly units 1 through 8 answered the model read at the routed unit with that same string. | Proven |
| CA-02 | For units 1 and 2, the serial-bearing block read at the routed unit equals key 4 of the entry whose key 5 is that unit, and differs from key 4 of every other entry. The values are not published and are not an identity predicate; the correlation only shows that key 5 binds an entry to its unit. | Proven |
| CA-03 | For units 3 through 8, key 5 binds the entry to the unit beyond the shared model string. Identical model strings cannot rule out a permutation. | Hypothesis |
| CA-04 | Object order is not unit order: the entry for unit 1 (object 0x91) follows the entries for units 2 through 8 and the PLC entry. | Proven |
| CA-05 | Units are not contiguous: the listed units are 0 through 9, 11, and 19, and units 10 and 12 carry no entry. | Proven |
| CA-06 | Units 0, 1, 9, and 11 (all listed) answered an unserved read with exception 3; units 10, 12, and 100 (no entry) answered with exception 4. | Proven |
| CA-07 | The exception code distinguishes a listed unit from an unlisted unit. This contract does not use it for identity, admission, or discovery. | Hypothesis |
| CA-08 | Unit 19, listed and beyond the probed range of 1 through 12, answers reads. It was never read. | Unknown |
| CA-09 | No observed key identifies a parent; the parent of every entry is the gateway that lists it. | Hypothesis |

The observation also used a bounded probe of units 1 through 12 as a discovery
fallback while the inventory was not yet readable. That probe is not a
contract operation: the contract discovers children only from the validated
listing and never scans.

## Negative-overlap observations

Each row is a probe that another family's candidate defines, read at the
stated place. The EMMA and S-Dongle candidates apply at unit 0 and at logical
unit 100; the routed-unit rows show how a SUN2000 child answers those probes.

| Probe | Read at | Result | Grade |
| --- | --- | --- | --- |
| EMMA offering, model, and software reads | gateway unit 0 | exception 3 on all three | Proven |
| EMMA offering read | routed units 1 through 8 | answers the SUN2000 model string, so the offering read is not a discriminator | Proven |
| EMMA software read | routed units 1 through 8 | answers a short text that is not the structured EMMA form | Proven |
| EMMA model read | routed unit 1 | 20 words that are not ASCII text, so the EMMA model gate fails | Proven |
| S-Dongle basic identification | logical unit 100 | the gateway's own identity, not an S-Dongle model | Proven |
| S-Dongle protocol-version read | logical unit 100 | exception 4 | Proven |
| S-Dongle search and capacity reads | logical unit 100 | exception 4 on both | Proven |
| S-Dongle protocol-version read | routed units 1 through 8 | two words, 5 then 0, identical on all eight, so the read alone is not a discriminator | Proven |
| S-Dongle search and capacity reads | routed unit 1 | exception 3 on both | Proven |
| SmartLogger counter read | routed unit 1 | exception 3 | Proven |
| SunSpec signature read | gateway unit 0 and routed unit 1 | two words that are not the SunSpec marker at unit 0, two zero words at unit 1 | Proven |
| Growatt probes | any | not issued | Unknown |
| SmartLogger probes at an EMMA endpoint | EMMA endpoint | no Modbus response in two bounded attempts; connections were accepted and then closed by the peer on the first request | Unknown |
| SmartLogger counter read | S-Dongle path, child unit 1 | exception 2 | Proven |
| SmartLogger counter read | S-Dongle path, unit 0 | no response on four attempts | Proven |
| SmartLogger counter read | S-Dongle path, gateway unit 100 | not probed | Unknown |
| EMMA offering, model, and software reads | S-Dongle path, child unit 1 | the offering and software reads answer the child's own identity texts, and the model read answers 20 words that are not ASCII text | Proven |
| EMMA offering, model, and software reads | S-Dongle path, unit 0 | no response on all three | Proven |
| S-Dongle probes at an EMMA endpoint | EMMA endpoint | the EMMA endpoint returned no Modbus response to the reads it was sent | Unknown |

The negative overlap with EMMA and S-Dongle is shown at the SmartLogger
endpoint. The rows that read at an S-Dongle path come from a separate
observation of one S-Dongle, recorded on the
[S-Dongle observation](sdongle-observed-identity-v1.md); their grades apply to
that installation. They show the SmartLogger and EMMA probes in the reverse
direction at that path's child unit and at unit 0, and not at its gateway unit
100. For EMMA the reverse direction at an EMMA endpoint stays Unknown, and the
Growatt probes were not issued. Those stay open obligations.

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| none | none | none | none |

This page rests on observations only: every graded row comes from the sanitized
observation record, and no vendor document was consulted to write it. The
documentary values that SL-08 and open question 1 compare the observation with
are carried by the [gateway contract](gateway-readonly-v1.md), not derived here.
A page that rests on a vendor document, such as a monitoring page, lists the
document in its own Documents consulted section, with the title, version, and
date of the document and a copyright note in force, under the page conventions
in the [applicability and licensing page](../applicability-and-licensing.md).

**Copyright note.** Not applicable. No information on this page is derived from
a vendor document.

## Open questions

1. Which model string a logger at either documentary firmware value reports is
   Unknown, because neither was observed. SL-08 shows that the observed
   logger's model differs from the documented model by one space.
2. The meaning of keys 3, 6, 9, and 10, and whether the counter moves when the
   listing changes (SL-03), are Unknown. A listing change was never observed.
3. The finite frame cap above 263 bytes is Unknown (tolerance requirement 1).
4. At the 750 ms gap a full enumeration used 15 exchanges in under 11 s, so the
   15-second ceiling would bound a listing to roughly sixteen entries
   (Hypothesis). A larger installation needs a different gap or ceiling, which
   belongs to the pacing contract.
5. Whether unit 19 and the other meter and PLC units answer any read is
   Unknown (CA-08), as is the behavior of a timing-out child: no child read
   timed out.
6. Whether units outside the probed set exist without a listing entry is
   Unknown; the contract never probes them.
7. EMMA listings and tuples, and negative overlap with an EMMA endpoint in the
   reverse direction, have no evidence. The EMMA endpoint did not answer. The
   S-Dongle path was observed separately (see the
   [S-Dongle observation](sdongle-observed-identity-v1.md)), and its listing, if
   any, was never read. The causes of the EMMA non-response are Unknown;
   candidates not tested are Modbus TCP disabled on the device, a client
   allowlist, and a session held by another client.
