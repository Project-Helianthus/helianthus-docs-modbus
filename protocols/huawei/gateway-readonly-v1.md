# Huawei Gateway Read-Only Candidates V1

## Scope

SmartLogger, S-Dongle, and EMMA are three independent Huawei native Modbus
families. They are not SunSpec profiles and do not fall back to one another.
This contract defines offline, read-only candidate decoding and fail-closed
admission. All three candidates are disabled for automatic runtime admission.

## Shared encoding

Documented register addresses are zero-based PDU offsets. Numeric register
values are big-endian and most-significant word first. Strings occupy exactly
`quantity * 2` bytes; retain the raw extent, require ASCII, and strip only
terminal NUL or space padding.

Serial numbers, ESNs, registration keys, writable aliases, credentials, and
write-only search controls are not qualification predicates. That admission
rule does not redact an implemented native read observation: a codec preserves
the native value, identifier, configuration, payload, provenance, and version
context that it supports. A consumer may make a separate semantic projection.

The public-artifact boundary is separate from the runtime boundary. This
repository never publishes an operator's real capture, identifier, credential,
endpoint, or laboratory data; examples and fixtures are synthetic. It does not
turn native runtime observations into digests, masks, or withheld fields merely
because they are sensitive or mutating.

## SmartLogger candidate

The candidate targets unit 0 and requires all of:

- FC03 offset 65521, quantity 1, a stable U16 device-list change counter;
- FC2B, MEI 0x0e, ReadDevId 0x03, object 0x87 inventory;
- a self entry whose model identifies SmartLogger; and
- a self-entry firmware of the V300 line at or above `V300R001C00`, the
  minimum that both consulted SmartLogger editions state for that line.

The editions are cited by their cover labels, `V300R024C10SPC191` (Issue 52)
and `V300R024C10SPC210` (Issue 49), which identify them and are not floors; each
also states minima for the other SmartLogger lines. Every V300 build at or above
the minimum inherits the candidate's documented facts, graded Hypothesis until
observed, under the
[software applicability rule](monitoring-readonly-v1.md#software-applicability).
The sources are listed in the Documents consulted section at the end of this
page.
Writable device name 65524, ESN 40713, basic MEI alone, and optional offering
strings are not detectors.

The self-entry model value `SmartLogger` is the family name that the editions'
applicability sections give. They give it without a model list and print no
self-entry model text, so its exact comparison is admission policy of this
contract, under which model values stay exact, and not a documented fact. The
observed logger reports `Smart Logger` and has its own entry below.

The change counter must be equal before and after child enumeration. The
editions list the counter in their public-register table without stating the
unit it is read at. This contract reads it at unit 0 on the strength of
observation: it answered at unit 0 and was refused at a routed child behind the
logger (the [SmartLogger observation](smartlogger-observed-inventory-v1.md),
SL-02 and its overlap table). Its documentary route stays unspecified and
quarantined (RC-01 below).

## S-Dongle candidate

The candidate targets logical unit 100 and requires all of:

- basic MEI product identity for an admitted S-Dongle model;
- FC03 offset 30068, quantity 2, U32 protocol version;
- FC03 offsets 37410 through 37412 for type, completed search state, and stable
  change sequence; and
- FC03 offset 37429, quantity 1, for capacity reconciliation.

The executable offline candidate in this revision covers model SDongleA-05,
SDongleB-03, or SDongleB-06 from the floor `V200R022C10`, the minimum that the
consulted editions state for those models, and the builds that follow it, under
the software applicability rule. The V200R025C00SPC120 edition (Issue 01)
states that minimum for all three models, and the V200R022CC10 edition
(Issue 02) states it for SDongleA-05 and SDongleB-06. Their cover labels
identify the editions and are not floors; the second spells its branch with a
doubled C on its cover while its requirement names V200R022C10. The
S-DongleA-05 / V200R022C10SPC312 tuple, which the
[S-Dongle qualification disposition](../../architecture/sdongle-qualification-disposition-v1.md)
names as its qualification target, is a build of the V200R022C10 branch at or
above that floor. It falls under this one candidate and inherits the
candidate's documented facts with grade Hypothesis; it is not a separate entry.

The protocol version is decoded as the editions' note states: the high byte is
the incompatible main revision and the low byte the compatible release
revision, and D5.0 is main revision 5 with release revision 0. The candidate
requires main revision 5 with a release revision from 0 onward. The type word
at offset 37410 is the network connection type that the editions list, a
configuration value: the candidate records it and does not compare it.

Readability of unit 100, search status alone, or a serial number is
insufficient. Extended child inventory remains offline-only until the exact TCP
unit target is qualified.

At logical unit 100, the documented candidate probes are basic MEI and the
listed read-only FC03 gateway registers. Extended MEI inventory is not a
gateway-unit probe: it applies only to a separately qualified child unit in the
range 1 through 247. A gateway-unit timeout never authorizes a child-unit scan
or an extended-MEI fallback.

The candidate's own tuple has not been observed. A separate observed
single-inverter tuple is defined in the S-Dongle subsection below and recorded on
the [S-Dongle observation](sdongle-observed-identity-v1.md). It neither admits
nor changes the candidate.

## EMMA candidate

The canonical family class is `EMMA`. The candidate targets unit 0 and begins
with this FC03 identity tuple:

- FC03 offset 30000, quantity 15, offering name;
- FC03 offset 30222, quantity 20, EMMA-family model;
- FC03 offset 30035, quantity 15, structured software version.

The offering is a bounded, validated contextual field; it is not a family
discriminator. After terminal NUL and space padding are removed, `EMMA-A01` and
`EMMA-A02` are the only admitted exact model values. These comparisons are
case-sensitive; there is no prefix match,
wildcard, first-match rule, or implicit alias. The two values are the admission
list of this contract, not a documented model list: the consulted editions name
the family `EMMA` in their applicability sections without listing models, so
the family is wider than the list. A model value of the family outside the list
produces insufficient evidence because the list does not hold it, not because
the editions exclude it, and adding it is a registry change backed by its own
observation.

The structured software version is `SmartHEMS`, one space, and a V, R, C, and
SPC version text. The candidate's software floors are the minima that the two
consulted editions state:

- `SmartHEMS V100R024C00SPCnnn`, where decimal `nnn` is at least 100, the
  minimum of the V100R024C00 edition; and
- `SmartHEMS V100R025C00SPCnnn`, where decimal `nnn` is at least 102, the
  minimum of the V100R025C00SPC102 edition.

A build at or above a floor within its branch, and every build that follows it,
inherits the candidate's facts with grade Hypothesis until observed, under the
software applicability rule. The editions document no order between the R024C00
and R025C00 branches, so a build of either branch is compared with the floor of
its own branch by its SPC number. A build of a branch that has neither a
documented floor nor a documented relation to one inherits with grade
Hypothesis as well. A build below the floor of its own branch, or a text without
the structured form, is insufficient evidence.

`EMMA-A01` and `EMMA-A02` are distinct capability variants. EMMA-A01 never inherits an EMMA-A02-only capability. The base read-only profile projects no
optional smart-load, charger, or control capability from either model token;
each such capability requires its own documented, model-specific gate.

Basic and extended MEI are optional enrichment, never initial EMMA identification. An optional-MEI failure does not negate an already validated
FC03 identity tuple, and optional-MEI success alone is insufficient to identify
the gateway. Serial register 30015, a model-register read without the complete
tuple, or a SmartHEMS prefix without an admitted model are insufficient.

The candidate's FC03 identity tuple has been observed on one installation. The
observed entry is in the EMMA subsection below, and the record, with its grades,
is the [EMMA observation](emma-observed-identity-v1.md). The observation neither
admits nor changes the candidate.

## Child inventory

SmartLogger and EMMA use:

```text
FC2B / MEI 0x0e / ReadDevId 0x03 / ObjectID 0x87
```

Object 0x87 is the declared U8 device count. Objects 0x88 through 0xff describe
children 1 through 120; continuation may wrap once from 0xff to 0x00. `More`,
`Next object ID`, and response object count drive pagination. Reject cursor
loops, duplicate objects, duplicate child addresses, count mismatch, malformed
attributes, a second wrap, or a changing inventory guard.

A child record may contain model, software version, interface protocol,
device/address, feature version, product type, parent relation, and ESN. ESN is
not by itself a stable child identity: stable identity uses the parent profile,
routing address, model/product type, and source revision. When an implemented
codec reads an ESN, it remains a native observation; public fixtures and prose
use synthetic values instead of an operator's actual identifier.

Total enumeration is bounded to 15 seconds. SmartLogger and EMMA permit at most
248 pages, 248 objects, and 65536 response bytes. A separately qualified
S-Dongle child unit permits at most 121 pages, 121 objects, and 32768 response
bytes. These S-Dongle bounds never authorize extended MEI at logical unit 100.
Limit exhaustion is insufficient evidence, never partial success. These bounds
are resource policy of this contract. A page count, an entry length, a key set,
or a response size seen in an observation is a lower bound that a reader
accepts, never a cap, and the observation pages state each as such.

## Observed and documentary entries

The entries below record exactly what was observed or defined for the gateway
families. Model and label values are compared field by field, byte for byte, and
case-sensitively, after only terminal NUL or space padding is stripped, with no
wildcard, prefix, alias, case folding, or whitespace normalization, and a match
of one entry's model never implies another's. A firmware value in an entry is
the observed build or the documented minimum, and it is the floor of that entry
under the software applicability rule: a build that follows it, within its
branch or along a documented order of branches, or a build of a branch with no
documented relation to it, inherits the entry with grade Hypothesis until
observed, and a build below it does not. The Proven, Hypothesis, and Unknown
grades are defined in the [SmartLogger
observation](smartlogger-observed-inventory-v1.md) and are separate from
admission and qualification.

| Family | Tuple | Basis | Status |
| --- | --- | --- | --- |
| SmartLogger, documentary entry | self-entry model `SmartLogger`, firmware of the V300 line from the minimum `V300R001C00` that both consulted editions state, the editions with cover labels `V300R024C10SPC191` and `V300R024C10SPC210` | vendor-document inspection only; no observation | defined by the candidate above; unobserved (Unknown) |
| SmartLogger, observed entry | gateway unit 0, self-entry model `Smart Logger`, firmware `V300R023C10SPC620`, the floor of the observed facts, in the V300R023C10 branch, which precedes V300R024C10 along the documented upgrade path and is above the documented minimum, self-entry unit `0` | sanitized read-only observation | entry with an exact model and a software floor; Proven for the observed build at the observed installation, and Hypothesis for an inherited build |
| EMMA, observed gateway entry | gateway unit 0, the candidate's three FC03 reads (offering `SmartHEMS`, a model that is one of the two admitted values, a software text at or above the floor of its own branch), with the model value, software branch, and suffix withheld on the published pages | sanitized read-only observation | entry with an exact model and a software floor; Proven for the observed installation, and Hypothesis for an inherited build; the model variant, branch, and suffix are carried by the registry fixture and are otherwise Unknown |
| S-Dongle, observed single-inverter entry | gateway unit 100 and child unit 1, the tuple of the S-Dongle subsection below, with no gateway model variant | sanitized read-only observation | exact entry; Proven for the observed installation; the gateway's model variant is Unknown |

`SmartLogger` and `Smart Logger` are different strings, and neither is an alias
of the other. The documentary entry rests on the V300R001C00 minimum that both
editions state; their cover labels identify the editions and order nothing.
The observed entry's V300R023C10 branch precedes V300R024C10 within the V300
line, as the upgrade path from V300R023C10SPC551 to V300R024C10SPC275 in the
SmartLogger V300R024C10SPC275 Upgrade Guide documents, and it is above the
documented minimum, so the documented facts apply to it with grade Hypothesis,
and its own observed facts apply from its observed build onward. The observed
entry is a defined entry; whether and when a registry admits it is the
registry's decision, and the entry carries no qualification, support claim, or
write authority. The observed entry is read through the extended inventory self
entry. The basic identification reply (vendor `HUAWEI`, product, and version) is
optional corroboration only. The S-Dongle entry follows the same rules. It is
separate from the offline candidate: it names no gateway model and no gateway
software, so no floor relates the two, and it is read at two units of one
endpoint and not through a listing. The EMMA entry follows the same rules too.
It is the candidate's own tuple observed on one installation, read at unit 0
only, and the published pages name neither its model value nor its software
text; the model comparison is exact against the registry fixture, its software
is the floor of the entry, and the entry creates no capability. These sections
promise no stability before Helianthus 1.0.

### SmartLogger

| Field | Contract |
| --- | --- |
| Required tuple, observed entry | Gateway unit 0. The counter (FC03 offset 65521, quantity 1) is equal before and after one complete extended inventory (FC2B / MEI 0x0e / ReadDevId 0x03, start object 0x87). The first entry, the self entry, has attribute 1 exactly `Smart Logger`, attribute 2 a firmware text of the V300 line at or above the observed build `V300R023C10SPC620`, counting the branches that follow V300R023C10 within the V300 line, or of a branch with no documented relation to it, under the software applicability rule (Proven for the observed build, Hypothesis for an inherited one), and attribute 5 exactly `0`. The inventory is valid under the child-inventory rules above and the tolerance requirements of the observation. |
| Required tuple, documentary entry | As the candidate section above: the model, compared exactly as admission policy, and a firmware of the V300 line at or above the documented minimum `V300R001C00`. |
| Optional corroboration | A decodable basic read shows vendor `HUAWEI`, product `Smart Logger`, and the same firmware. A disagreement with the self entry is a conflicting detector and produces `insufficient_evidence`. Absence or a decode failure of the basic read changes nothing. |
| Forbidden identity | Serial number or ESN (attribute 4 and the serial-like basic object), the writable device name, readability of any register, a child listing, a basic reply alone, the product string without the firmware string, a prefix, wildcard, case-folded, or whitespace-normalized match, and the unit identifier of an MEI request. The gateway answers a basic read with its own identity for every unit identifier tried. |
| Multiple-positive outcome | No selection. Two matching Huawei candidates, or a Huawei candidate that collides with SunSpec/Fronius or Growatt, is `AMBIGUOUS` in the qualification card and `insufficient_evidence` in the collision rule below. Both select nothing and send nothing, and no order or priority applies. |
| Negative-overlap obligations | Executable fixtures against EMMA, S-Dongle, SunSpec/Fronius, and Growatt. Evidence so far: EMMA probes at the SmartLogger endpoint are exceptions (Proven); S-Dongle probes at logical unit 100 are exceptions and the basic reply is the gateway's own (Proven); no SunSpec marker (Proven); Growatt not probed (Unknown). The reverse direction at an EMMA is observed: the SmartLogger counter read is exception 3 at the EMMA unit and at one of its inverters (Proven), and an EMMA self entry is a SmartLogger negative control (Proven). The reverse direction at the S-Dongle gateway unit 100 is Unknown. |

### EMMA

| Field | Contract |
| --- | --- |
| Required tuple, observed gateway entry | All of the following at gateway unit 0 on one connection generation. FC03 offset 30000, quantity 15: the text `SmartHEMS`, a NUL, and NUL padding over the full 30 bytes. FC03 offset 30222, quantity 20: a text that equals, after terminal NUL padding is stripped, one of the two admitted model values, with NUL padding over the full 40 bytes. FC03 offset 30035, quantity 15: `SmartHEMS`, one space, and a version-style text that the candidate's software rule admits (at or above the floor of its own branch, a build that follows it, or a build of a branch with neither a documented floor nor a documented relation), followed by a NUL and NUL padding over the full 30 bytes. The observed build is Proven, and every other build that this rule admits is Hypothesis. The published pages name no model value and no version text, so the observed entry's model is compared exactly against the registry fixture, with no prefix, wildcard, or range linking two model values. Basic identification and the self entry of the extended inventory are optional corroboration only: a decodable disagreement with the FC03 tuple is a conflicting detector and produces `insufficient_evidence`, and absence or a decode failure changes nothing. The full contract and the tolerances are on the [EMMA observation](emma-observed-identity-v1.md). |
| Other model value and other branches | The other admitted model value is unobserved, and an observation of it would be its own entry, because model values are exact. A build of the other documented branch at or above its floor, or of a branch with neither a documented floor nor a documented relation, inherits the observed entry with grade Hypothesis under the software applicability rule, and an observation of it records only what differs. The admitted values are the admission list of the candidate section above, within a family that the editions name more widely. |
| Child inverters | A SUN2000-family inverter at a routed unit is identified by its own routed read under the EMMA observation: the unit is key 5 of exactly one inventory entry whose device type is `SUN2000`, it is in the operator allowlist, and its model block text equals key 1 of that entry. Two inverters were observed at units 3 and 4, and the child routing rules below apply to them. A backup-box entry is listed at unit 2, has no class contract, and is withheld. No battery unit is listed, and battery addressing is Unknown. |
| Forbidden identity | Serial number or ESN, the serial register, a model-register read without the complete tuple, a `SmartHEMS` prefix without an admitted model, optional MEI alone, child listing, writable alias, readability (including the EMMA offsets answered at an inverter, the SunSpec offset, and the basic reply that every unit identifier returns), and a prefix or wildcard match. |
| Multiple-positive outcome | No selection; `AMBIGUOUS` in the qualification card and `insufficient_evidence` in the collision rule, with no order or priority. |
| Negative-overlap obligations | Against SmartLogger: EMMA probes at the SmartLogger endpoint are rejected, and the SmartLogger counter read is exception 3 at the EMMA unit and at one inverter (all Proven); an EMMA self entry is a SmartLogger negative control (Proven). Against S-Dongle: EMMA probes at the S-Dongle path do not return an EMMA tuple, because the offering and software offsets answer the child's own identity texts, the model offset answers non-text data, and unit 0 is silent (Proven); the S-Dongle status reads are exception 4 at EMMA unit 100 and exception 3 at an inverter, and the basic reply at unit 100 names the product `HEMS` where the S-Dongle gateway gives exception 1 (all Proven); S-Dongle status reads at EMMA unit 0 are Unknown. Against SunSpec: no marker at unit 0 or at an inverter (Proven). Growatt is Unknown. |
| Evidence state | Four bounded read-only runs from two capture hosts received no Modbus response of any kind: every connection was accepted and then reset or closed by the peer a median of about 60 ms after the request was written. A fifth run, taken after the operator allowed the first capture host on the gateway, was answered on every request, each on its first attempt, on one connection. That a gateway resets the requests of a client it does not allow is a Hypothesis (one before and after pair); the allow mechanism, the reset of the second host, and whether anything else changed are Unknown. The earlier non-response is superseded for the identity of the observed gateway entry only, under the same-class rule of the [readiness contract](qualification-readiness-v1.md), and the record stays on file. Children are two inverters at units 3 and 4 plus a listed backup-box entry. The batteries are not listed and not found, so battery addressing and the EMMA's capability blocks are Unknown. The grades are on the [EMMA observation](emma-observed-identity-v1.md). |

### S-Dongle

| Field | Contract |
| --- | --- |
| Required tuple, observed single-inverter entry | All of the following at the stated units on one connection generation. Gateway unit 100: basic identification (FC2B / MEI 0x0e, read code 1) is answered with exception 1; FC03 offset 37411, quantity 1, reads 0; FC03 offset 30068, quantity 2, reads 50 then 0, compared as words and never decoded, because their encoding is Unknown (once an observation establishes it, the comparison takes the floor form of the protocol note above: main revision equal, release revision from the observed one onward); FC03 offset 37410, quantity 3, has state word 0 (the equality of the sequence across the child identification reads was not observed, SD-08, and is not part of the tuple), and its type word, observed as 4, is recorded and not compared, because it is the network connection type, a configuration value; FC03 offset 37429, quantity 1, reads at least 1. Child unit 1: the model block (FC03 offset 30000, quantity 15) is a printable non-empty model text of the SUN2000 family, a NUL, optional printable residue, and NUL padding over the full 30 bytes; basic identification (read code 1) carries vendor exactly `Huawei`, product exactly `SUN2000`, and a present version object, each object once; the extended inventory from object 0x87 (read code 3) is one page with conformity 0x03, no continuation, count object value 1, and one entry object 0x88 that carries keys 1 through 6, each once, whose key 1 equals the model text, and whose key 5 is exactly `1`; a further key is retained as opaque native evidence and does not reject the entry, and a repeated key does. No specific child model token is a discriminator of the tuple. The gateway names no product, so there is no gateway model variant. The full contract and the tolerances are on the [S-Dongle observation](sdongle-observed-identity-v1.md). |
| Required tuple, candidate | Unknown. The executable candidate above stays unobserved, and it stays distinct from the observed entry, which names no gateway model or software. The A-05 qualification target of the S-Dongle disposition falls under the candidate. |
| Forbidden identity | Serial number or ESN, a writable alias, readability of any register (including the S-Dongle's own search and capacity registers answered at the child, the EMMA offsets, and the SunSpec offset), readability of logical unit 100 or search status alone, basic identification alone, a child listing, the unit identifier of a request, and a prefix, wildcard, case-folded, or whitespace-normalized match. |
| Multiple-positive outcome | No selection; `AMBIGUOUS` in the qualification card and `insufficient_evidence` in the collision rule, with no order or priority. |
| Negative-overlap obligations | Against SmartLogger: the counter read at the child is an exception and unit 0 is silent, the basic reply at the child is its own SUN2000 identity, and S-Dongle probes at the SmartLogger endpoint are exceptions with the gateway's own basic reply (all Proven); the counter read at unit 100 is Unknown. Against EMMA: EMMA probes at the S-Dongle path do not return an EMMA tuple (Proven); S-Dongle probes at an EMMA endpoint are refused at unit 100 (exception 4) and at an inverter (exception 3), and the EMMA answers basic identification at unit 100 with its own reply where the S-Dongle gateway gives exception 1 (all Proven); S-Dongle status reads at EMMA unit 0 are Unknown. Against SunSpec: no marker at the child (Proven). Growatt is Unknown. |
| Evidence state | Two bounded read-only runs on one S-Dongle fronting one inverter, taken with the operator's approval at action time, observed the entry above (Proven for the observed installation). The recorded persistent non-response did not reproduce at unit 100, and it is superseded for the identity of the observed entry only by a run of the same class that matches the whole exact tuple on one connection generation, as the [readiness contract](qualification-readiness-v1.md) states; the two observation runs used separate connections and did not. Any further request needs action-time operator approval with confirmed connection context. The gateway's product, the encoding of the protocol words, the child unit without a scan, and every unit other than 0, 1, 2, 3, and 100 are Unknown. |

## Evidence gaps after observation

The gap names are those of the registry dispositions and the qualification
cards. Closing a gap here means the evidence exists and is described; the
registry fixture and the reconciliation of its disposition remain the registry
companion's work, and no gap closure is a qualification or support claim.

| Gap | Family | State | Grade |
| --- | --- | --- | --- |
| `sanitized_extended_mei_self_entry_fixture` | SmartLogger | Closed by observation for the observed entry | Proven |
| `exact_child_attribute_encoding_fixture`, structure | SmartLogger | Closed for the observed key set | Proven |
| `exact_child_attribute_encoding_fixture`, meaning of keys 3, 6, 9, and 10 | SmartLogger | Open; the editions give key 6 more than one meaning, which stays quarantined (RC-02) | Unknown |
| `pairwise_negative_overlap_with_emma_fixture` | SmartLogger | Closed by observation for the probes issued: EMMA probes at the SmartLogger endpoint are rejected, and the SmartLogger counter read is refused at the EMMA unit and at one inverter; the counter read at the S-Dongle gateway unit 100 is open | Proven and Unknown |
| Connected identity for the documentary entry (model `SmartLogger`) | SmartLogger | Open; never observed | Unknown |
| Connected FC03 identity tuple | EMMA | Closed by observation for the observed installation: the candidate's three reads answered at unit 0; the model value, software branch, and suffix are withheld, and the other model value and branch are open | Proven and Unknown |
| `sanitized_readonly_capability_fixture` | EMMA | Open; no capability, monitoring, or battery block was read | Unknown |
| `negative_overlap_with_smartlogger` | EMMA | Closed by observation in both directions for the probes issued: the EMMA reads are rejected at the SmartLogger endpoint, and the counter read is refused at the EMMA unit and at one inverter | Proven |
| `model_specific_capability_fixture` | EMMA | Open; the model variant is withheld on the published pages and no capability block was read | Unknown |
| Child inverters behind the EMMA | EMMA | Closed for the observed installation: units 3 and 4, listed and identified at their own units | Proven |
| Battery addressing | EMMA | Open; no battery is listed or found, and no battery read was issued | Unknown |
| Guard of an EMMA listing | EMMA | Open; the SmartLogger counter is refused at the EMMA | Unknown |
| `gateway_unit_100_topology` | S-Dongle | Closed by observation for the observed tuple: unit 100 is the gateway and unit 1 is the child | Proven |
| `sanitized_basic_mei_product_model_fixture` | S-Dongle | Partly closed: the gateway refuses basic identification and the child returns vendor and family; the gateway's product string was not obtained | Proven and Unknown |
| `exact_protocol_version_encoding_fixture` | S-Dongle | Partly closed: the protocol words are recorded as read at the gateway and the child; their encoding is open | Proven and Unknown |
| `completed_search_stable_sequence_capacity_fixture` | S-Dongle | Closed for the observed tuple by one before and after pair; the coding of the state value and the bracket around the child inventory are open | Proven, Hypothesis, and Unknown |
| `separately_qualified_child_unit_inventory_fixture` | S-Dongle | Closed for the observed tuple: child unit 1, one page, one entry | Proven |
| `pairwise_negative_overlap_with_emma_fixture` | S-Dongle | Closed by observation for the probes issued: EMMA probes at the S-Dongle path do not return an EMMA tuple, and the S-Dongle status reads are refused at EMMA unit 100 and at an inverter; the status reads at EMMA unit 0 are open | Proven and Unknown |
| Connected identity at the candidate's tuple | S-Dongle | Open; the observed gateway named no product or firmware, and the A-05 qualification target falls under the candidate | Unknown |

## Child routing

This section defines how a child listed in a SmartLogger inventory maps to a
routed unit, and what happens when the listing and an operator allowlist
disagree. The same rules are the contract for an EMMA inventory, and one EMMA
inventory has now been observed (EM-16 to EM-32 on the
[EMMA observation](emma-observed-identity-v1.md)). It fits them, with one
exception: the guard-counter re-read rule below is written for the SmartLogger
counter, which the EMMA refuses with exception 3, so an EMMA listing has no
guard, and its guard is Unknown. This section creates no EMMA admission. The
observation behind each rule is in the
[SmartLogger observation](smartlogger-observed-inventory-v1.md).

The S-Dongle path does not use these rules as written. The gateway unit's
listing is never read, because extended inventory is not addressed to the
gateway unit, and the one inventory read at the child lists only that child (SD-23
to SD-25 on the [S-Dongle observation](sdongle-observed-identity-v1.md)). How a
provider learns the child unit without a scan is Unknown. A scan and an inferred
address are never permitted.

### Routing rules

1. **Address.** A child entry names exactly one candidate routed unit: the
   decimal value of its attribute 5. The value must be an unsigned decimal
   integer from 1 through 247, distinct from every other entry and from the
   gateway unit. A malformed, zero, out-of-range, or repeated value rejects the
   whole inventory. The self entry's attribute 5 must equal the gateway unit the
   inventory was read on.
2. **Position is not routing.** Object position, listing order, the count, the
   model string, the product type, and the sensitive identity attribute never
   map an entry to a unit. The observed listing order is not unit order.
3. **A listing is never identity.** The model, firmware, product type, and unit
   in an entry are native listing evidence. They are retained, and they never
   select a class or profile, admit a child, or supply an element of a tuple.
   Identity is read at the routed unit under the class contract, and all
   identity reads of one tuple are taken at the same routed unit on one
   connection generation. A provider may use the listing to limit which
   read-only identity requests it sends to a listed and allowed unit, never to
   supply the answer.
4. **Effective set.** The operator allowlist is an explicit per-endpoint set of
   routed units, owned by configuration and not by this contract. Routed reads
   go only to units in the intersection of the validated listing and the
   allowlist. The listing never adds a unit to the allowlist, and the allowlist
   never causes a read to an unlisted unit. A provider never scans, infers an
   address, or probes a unit outside the intersection.
5. **Agreement check.** Where a class contract compares a listing value with a
   routed read, it uses exact equality, and a mismatch withholds the child and
   retains both readings. The listing's firmware text is not compared with a
   routed firmware text unless a class contract defines an exact comparison.
6. **Failure isolation.** A failure of one child never rejects the listing, fails
   a sibling, or authorizes a scan, a retry storm, or a fallback. A failure of
   the gateway-unit reads (counter or inventory) affects the whole endpoint.
7. **Retention.** A withheld child emits no native facts for the cycle. Native
   listing evidence, failure evidence, and any earlier valid last-known-good
   observation of that child are retained with their original age. A rejected
   inventory never yields a partial child list.

### Decision table

Reason labels are descriptive, not a public interface. The last column grades
the evidence that the case occurs and behaves as stated; the outcomes
themselves are contract.

| Case | Condition | Outcome | Effect on siblings and gateway | Evidence for the premise |
| --- | --- | --- | --- | --- |
| Listed and allowed, routed identity exact | the unit is in the listing and the allowlist, and the class contract's routed identity request is exact | identity is established by the routed read under the class contract, with the listing as corroboration only; the observed SUN2000 tuple still leaves profile selection at `NO_ADMISSIBLE_PROFILE` | none | Proven (eight units behind a SmartLogger, two behind an EMMA) |
| Listed and allowed, routed identity not exact | the routed read is an exception, not exact, not ASCII, or unpadded | `INSUFFICIENT_EVIDENCE`; the child is withheld as `identity_insufficient`; the failed read is retained | none | Proven for exceptions at two units; other causes Unknown |
| Listed but not allowed | the unit is in the listing and not in the allowlist | withheld as `not_allowlisted`; no routed read; the entry stays as listing evidence; the allowlist is not extended | none | Unknown (no allowlist was in force) |
| Allowed but not listed | the unit is in the allowlist and not in the listing | withheld as `not_listed`; no read and no probe, even if the unit would answer | none | Unknown |
| Listing changed during enumeration | the counter differs before and after, or a page is malformed, repeated, miscounted, or loops | the whole enumeration is rejected as `listing_unstable`; no partial list; every child of the endpoint is withheld; a committed listing from an earlier enumeration is stale history only | all children of this gateway; other endpoints unaffected | Unknown (the counter never changed) |
| One child times out while siblings answer | a routed read for one unit times out | that child is withheld for the cycle as `child_timeout`, with its last-known-good observation and age retained; no re-enumeration, scan, or sibling retry; repeated timeouts back off that child only | siblings and the gateway unaffected | Unknown (no child read timed out) |
| Gateway-unit read fails | the counter or inventory read at the gateway unit times out, is an exception, or is malformed | the endpoint is `INSUFFICIENT_EVIDENCE`; no child read; no child-unit scan and no extended-MEI fallback | all children of this endpoint | Unknown |
| Listing and routed model disagree | the listing's model differs from the model read at the routed unit | withheld as `identity_mismatch`; both readings are retained; the unit is not reassigned | none | Unknown (all eight agreed, and the two EMMA inverters agreed) |
| Listed class has no class contract | a listed and allowed unit labeled PLC, PowerMeter, or BackupBox | withheld as `no_class_contract`; no routed read | none | Proven (the entries exist, the backup-box entry of an EMMA among them) |
| Allowlist empty | no unit is allowed | every child is withheld as `not_allowlisted`; the enumeration itself may still run | the whole endpoint | Unknown |

### Guard-counter re-read rule

1. A committed listing is bound to the counter value read after its
   enumeration, which equals the value read before it.
2. Each routed read cycle starts with a counter re-read at the gateway unit. If
   it equals the bound value, the cycle may read the intersection of the
   listing and the allowlist. If it differs, no routed read is sent in that
   cycle, a fresh enumeration under the full counter bracket is required, and
   every child must be identified again at its routed unit before it counts as
   identified. Observations that came from the stale listing remain
   last-known-good history with their original age.
3. A counter re-read that fails (exception, timeout, or malformed reply) leaves
   the listing unconfirmed: no routed read in that cycle, no fallback, no scan.
4. Equality is a guard, not proof that nothing changed between two reads, and a
   16-bit counter can wrap.
5. How often the counter is re-read, and any cap on re-enumeration, belong to
   the pacing contract. This rule fixes only the order: counter first, then
   routed reads.

The counter read answered within tens of milliseconds and returned one value on
six reads (Proven). That the counter moves when the listing changes is Unknown,
so the rule fails closed on any difference or any failed re-read.

The rule is written for the SmartLogger counter and is not extended to an EMMA.
The counter read is refused at the EMMA unit with exception 3 (Proven, EM-31),
so the EMMA listing observed was read once and was bracketed by no guard. Which
register, if any, guards an EMMA listing is Unknown (EM-32), and this section
defines none. A listing that cannot be bracketed stays unconfirmed, and no
section of this page turns it into an admission.

## Private function codes

Huawei-defined FC0x41 and the Huawei-specific use of FC0x17 are profile-scoped
operations. Their payloads may be validated and retained only by an already
selected Huawei candidate codec. They do not identify a Huawei family and do
not reserve either function code globally.

Both functions are default-denied and no-send in this read-only profile.
Offline fixtures may prove bounds, exception handling, and unknown payload
retention, but must not execute file transfer, configuration, search, control,
or other state-changing sub-functions.

## Collision and failure rules

If any two Huawei candidates match one endpoint/unit observation, the result is
`insufficient_evidence`. A Huawei candidate colliding with SunSpec/Fronius or
Growatt is also insufficient. Timeout, disconnect, unstable inventory, a
software build below the floor of its branch, malformed strings, or a
non-optional Modbus exception produces no send and no partial profile. A build
that no observation has seen is not an unknown version: it inherits under the
software applicability rule.

Executable inventory parsing, candidate decoding, and pairwise overlap proof
belong to the consuming profile registry. This page creates no admission by
itself.

The per-class qualification cards, missing-evidence outcomes, and shared
no-fallback result are defined in
[`qualification-readiness-v1.md`](qualification-readiness-v1.md).

## Reference conflicts and quarantined facts

The Huawei gateway Modbus reference quarantines conflicts between editions, and
some of its readings differ from this contract. Where they touch a page of this
repository, both texts are carried here with their grades, under the
quarantine rule of the [applicability and licensing
page](../applicability-and-licensing.md). No edition, issue number, or date
selects a winner, a quarantined fact is neither read nor decoded, and the
contract changes only where a row says so.

| ID | Topic | This repository | The editions and the reference | Grade and handling |
| --- | --- | --- | --- | --- |
| RC-01 | Route of the inventory change counter (offset 65521) | The SmartLogger candidate and the guard-counter rule read the counter at gateway unit 0. It answered there on six reads. It was refused with exception 3 at routed unit 1 behind the logger, at the EMMA, and at one of the EMMA's inverters, and with exception 2 at the S-Dongle child ([SmartLogger observation](smartlogger-observed-inventory-v1.md)). | Issues 52 and 49 list the counter in their public-register table without stating the unit it is read at, and the reference classifies its documentary route as unspecified, apart from the per-child alias registers. The SmartHEMS editions do not define it. | The unit 0 reading is Proven for the observed installation, and the documentary route is Unknown and quarantined. The contract keeps unit 0 on the strength of the observation, and a read of the counter at a routed unit is a negative-overlap probe only. |
| RC-02 | Meaning of descriptor key 6 | The observation pages record key 6 as a short version-like text on every entry of all three paths, retained as opaque native evidence, with its meaning Unknown. | Key 6 depends on the edition: a parallel-network integer in Issue 49 and in the S-Dongle editions, a feature-version integer in Issue 52, and a feature-version string in the SmartHEMS editions. No single decoder applies. | Each edition's reading is documentary, Hypothesis for that edition, and the observed meaning is Unknown. Key 6 is never decoded and is retained as opaque native evidence. |
| RC-03 | Width of the plant energy counters at offsets 40446, 40450, 40454, and 40458 | No page reads these offsets. The planned logger plant groups of the [monitoring contract](monitoring-readonly-v1.md) start at offsets 40521 and 40560 and do not overlap them. | Issue 01 of the V300R024C10 interface definitions, dated 2026-10-15, prints each as a 64-bit signed value of two registers in one of its tables, while Issue 02 of the V300R025C10 and of the V300R026C10 interface definitions print each as four registers. The four-register rows do not repair the two-register rows. | Conflict, quarantined for the two-register rows. No page reads or decodes them. |
| RC-04 | Remapped child values | No page reads a remapped child value; child values are read at the routed unit. | Issues 53 and 49 print a 25-register child block next to offsets 38000 through 38105 with 32-bit cells of one register, which defines no coherent mapping, and no formula of another edition is borrowed to repair it. | Conflict, quarantined. No remapped address is computed or read. |
| RC-05 | The count object 0x87 | The child-inventory section reads object 0x87 as a U8 device count with objects 0x88 through 0xff describing children 1 through 120, and the SmartLogger card reads the count as the child count. The observations show a one-byte count that includes the gateway's own entry (SL-13 and EM-20). | Issues 52 and 49 describe object 0x87 as an integer count of devices, call object 0x88 the first device description, and label object 0xff device 120. The reference finds no byte width or encoding of the count established across editions, and it reads the label of object 0xff as no maximum-count or pagination rule. | The observed count is Proven for the observed installations, and the documentary width is Unknown. Both texts are carried: the observed entries count the self entry, as their tolerance requirements state, and the card's reading stays until a revision of the child-inventory rules settles it. |
| RC-06 | Extended inventory at the S-Dongle gateway unit | Extended inventory is not a gateway-unit probe at logical unit 100. It applies only to a separately qualified child unit, and it was never sent at unit 100 (SD-12 on the [S-Dongle observation](sdongle-observed-identity-v1.md)). | The S-Dongle editions define the private device list with the gateway's own unit 100 as their only endpoint. | Documentary, Hypothesis; the outcome at unit 100 is Unknown. The contract keeps its rule, and no request is added without an operator-approved observation. |
| RC-07 | Basic identification in the S-Dongle candidate | The candidate requires basic identification of an admitted model at unit 100. The observed gateway refuses it with exception 1 (SD-02), and the observed entry requires that refusal. | The reference reads basic identification as added evidence where a gateway supports it, not as a mandatory discriminator. | The refusal is Proven for the observed installation. Both texts are carried: the candidate's requirement stays, and the observed gateway cannot meet it. |
| RC-08 | Huawei-defined FC0x41 and the Huawei-specific use of FC0x17 | The private function codes section scopes both to an already selected Huawei candidate and keeps them default denied and no-send. | The reference finds that the gateway editions publish no FC0x41 subservice protocol and establish no raw FC0x17 service. | Both texts deny sending, so no request changes, and a gateway profile has no documented payload of either function to retain. |

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| SmartLogger V300R024C10SPC191 ModBus Interface Definitions | Issue 52 | 2025-06-06 | the minimum software of the V300 line (p. 15) and the family name in the applicability section (pp. 15–16), for the SmartLogger candidate and the documentary entry; the counter in the public-register table, RC-01 (p. 58); the count object, RC-05 (pp. 81–83); the descriptor keys and key 6, RC-02 (pp. 83–85) |
| SmartLogger V300R024C10SPC210 ModBus Interface Definitions | Issue 49 | 2025-03-19 | the minimum software of the V300 line (p. 13) and the family name in the applicability section (pp. 13–14), for the SmartLogger candidate and the documentary entry; the counter in the public-register table, RC-01 (p. 69); the remapped child block, RC-04 (pp. 70–71); the count object, RC-05 (pp. 96–97); the descriptor keys and key 6, RC-02 (pp. 97–99) |
| SmartLogger V300R024C10 ModBus Interface Definitions | Issue 53 | 2025-10-29 | the remapped child block, RC-04 (pp. 67–68) |
| SmartLogger V300R024C10 ModBus Interface Definitions | Issue 01 | 2026-10-15 | the two-register rows of the plant energy counters, RC-03 (pp. 28–29) |
| SmartLogger V300R025C10 ModBus Interface Definitions | Issue 02 | 2026-10-09 | the four-register rows of the plant energy counters, RC-03 (p. 20) |
| SmartLogger V300R026C10 ModBus Interface Definitions | Issue 02 | 2026-10-09 | the four-register rows of the plant energy counters, RC-03 (p. 20) |
| SmartLogger V300R024C10SPC275 Upgrade Guide | Issue 01 | 2026-10-16 | the upgrade path that places the V300R023C10 branch before V300R024C10 within the V300 line (pp. 7–8) |
| SmartHEMS V100R024C00 MODBUS Interface Definitions | Issue 01 | 2024-07-15 | the EMMA floor in the R024C00 branch and the family name `EMMA` in the applicability section (pp. 7–8); key 6 as a feature-version string, RC-02 (pp. 40–42) |
| SmartHEMS V100R025C00SPC102 MODBUS Interface Definitions | Issue V100R025C00SPC102 | 2025-08-14 | the EMMA floor in the R025C00 branch and the family name `EMMA` in the applicability section (pp. 7–8); key 6 as a feature-version string, RC-02 (p. 43) |
| SDongle V200R025C00SPC120 MODBUS Interface Definitions | Issue 01 | 2025-12-23 | the three models and the V200R022C10 minimum of the S-Dongle candidate (pp. 8–9); the protocol-version note and the listed network types of the type word (p. 9); the private device list at unit 100, RC-06 (pp. 30–31); key 6 as a parallel-network integer, RC-02 (pp. 31–32) |
| SDongle V200R022CC10 MODBUS Interface Definitions | Issue 02 | 2023-04-20 | the models SDongleA-05 and SDongleB-06 and the V200R022C10 minimum (pp. 8–9); the protocol-version note and the listed network types of the type word (p. 9); the private device list at unit 100, RC-06 (pp. 30–32); key 6 as a parallel-network integer, RC-02 (pp. 32–33) |
| Huawei gateway Modbus reference | reference baseline 2026-10-26.1 | 2026-10-26 | locating the statements in the documents above; its readings that the counter's documentary route is unspecified (RC-01), that the count object has no established width (RC-05), that basic identification is not a mandatory discriminator (RC-07), and that the gateway editions publish no FC0x41 or raw FC0x17 service (RC-08) |

The other rules of this page predate the page conventions of the
[applicability and licensing page](../applicability-and-licensing.md) and keep
their existing basis. No table, label, or text of the documents is reproduced
here.

**Copyright note.** The information on this page that is derived from the
SmartLogger documents listed above is attributed to Huawei Technologies Co.,
Ltd., which retains the copyright in those documents. This page states that
information in its own words and does not reproduce the documents. The CC0-1.0
dedication of this page covers its own expression only and does not relicense
those documents.

**Copyright note.** The information on this page that is derived from the
SmartHEMS and SDongle documents listed above is attributed to Huawei Digital
Power Technologies Co., Ltd., which retains the copyright in those documents.
This page states that information in its own words and does not reproduce the
documents. The CC0-1.0 dedication of this page covers its own expression only
and does not relicense those documents.

**Reference note.** The facts that the Documents consulted section attributes
to the Huawei gateway Modbus reference were taken through that independent
documentary work, whose contributors dedicate its original writing under
CC0-1.0. The vendor documents it cites keep their rights, as the copyright note
states. This page restates those facts in its own words and carries over none
of the reference's engineer-review or operational-authorization clauses.
