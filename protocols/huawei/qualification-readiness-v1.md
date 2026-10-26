# Huawei Qualification Readiness V1

## Scope and class outcomes

This contract prepares separate offline qualification cards for SmartLogger,
EMMA, and S-Dongle. The cards consume already-read synthetic evidence and never
open a connection, scan a unit range, create an automatic request, or fall back
between Huawei classes. Identity is not telemetry support.

| Class | Provider-local status | Residual evidence |
| --- | --- | --- |
| SmartLogger | `QUALIFICATION_TEST_READY` | one connected read-only SmartLogger identity and inventory capture |
| EMMA | `QUALIFICATION_EVIDENCE_BLOCKED` | sanitized read-only capability, SmartLogger negative-overlap, and model-specific capability fixtures |
| S-Dongle | `QUALIFICATION_EVIDENCE_BLOCKED` | confirmed connection context, gateway/child topology, exact identity and protocol encoding, stable search/capacity, and separately qualified child inventory |

No class is `HARDWARE_TEST_READY`. Every result remains default denied with
`catalog_registered=false`, `automatic_runtime_admission=false`,
`live_qualified=false`, `support_claim=false`, and `write_authority=false`.

## SmartLogger qualification card

The card identity is
`huawei.qualification.smartlogger.readonly@1.0.0`. It applies only to logical
unit 0 and uses this bounded caller-run sequence:

1. an FC03 read at PDU offset 65521, quantity 1, for the U16 inventory change
   counter;
2. an already-read extended MEI inventory using MEI 0x0e, ReadDevId 0x03, and
   start object 0x87; and
3. the same FC03 counter read after inventory.

The counter values must be equal. Inventory is limited to 15 seconds, 248
pages, 248 objects, 65536 response bytes, and 247 children. Object 0x87 declares
the child count. The first record is the self entry and its model must be exactly
`SmartLogger`. That exactness is admission policy of this card: the consulted
editions name the SmartLogger family in their applicability sections without a
model list and print no self-entry model text, so the value is the family name
and not a documented exhaustive model. Its software version must be of the V300
line at or above `V300R001C00`, the minimum that both consulted editions state
for that line. Their cover labels, `V300R024C10SPC191` and `V300R024C10SPC210`,
identify the editions and are not floors. A build that no observation has seen
inherits with grade Hypothesis under the
[software applicability rule](monitoring-readonly-v1.md#software-applicability).

Child attributes use the bounded semicolon encoding of `key=value` pairs, with
the keys that each consulted edition defines. In both editions key 1 is the
model text, 2 the software text, 3 the interface-protocol version text, 4 the
sensitive native identity input, and 5 the routing address. Key 6 differs by
edition: Issue 52 defines it as a feature-version integer and Issue 49 as a
parallel-network integer, so the card decodes neither and retains key 6 as
opaque native evidence. Issue 52 also defines key 8, the product type; key 9,
parent-device information; and key 10, a registration-code text that is never a
command, and it marks key 7 not applicable. Issue 49 defines keys 1 through 6
only. Key 4 is validated but never copied into a public fixture. A key that
neither edition defines is retained as opaque native evidence and does not by
itself reject the inventory. Repeated keys, missing model, malformed ASCII,
repeated child address, or wrong object order rejects the whole inventory. A
counter change, count mismatch, cursor loop, second wrap, or any exhausted limit rejects
the whole inventory. No partial child list survives a failure.

An EMMA self entry is a SmartLogger negative control and produces no SmartLogger
selection. A successful synthetic card proves only that the bounded qualification
procedure and retention logic are ready. The connected read-only identity and
inventory capture remains missing.

## SmartLogger observed-tuple status

The residual evidence listed for SmartLogger in the table above, one connected
read-only identity and inventory capture, is closed for one observed tuple and
stays open for the card's documentary entry (model `SmartLogger`), which was
never observed.
The observed tuple is a separate entry, with its own floor, in the
[gateway contract](gateway-readonly-v1.md); its evidence and grades are in the
[SmartLogger observation](smartlogger-observed-inventory-v1.md).

Applied to the observed gateway, the card above returns `INSUFFICIENT_EVIDENCE`,
because the gateway's self-entry model `Smart Logger` is not the card's exact
model `SmartLogger`. Its firmware is of the V300R023C10 branch, which precedes
V300R024C10 along the documented upgrade path and is above the documented
minimum, so it meets the card's software rule and is not the reason. That is
the card working as written, not a failure of the gateway. The observed tuple needs its own card
in the registry companion, and this page defines no card identity for it. Such a
card must accommodate what the observation showed:

- responses of at least 263 bytes with one object each, and a declared-object
  field that differs from the objects present; the "count mismatch" rejection
  above compares the count object with the number of entries and does not
  refer to that field;
- a count object that includes the self entry;
- attribute keys 9 and 10, which Issue 52 defines, as known opaque keys, and
  attribute order that is not numeric; and
- a basic reply that carries more than the basic category, which is optional
  corroboration only.

A counter that stays equal across the bracket, a complete valid inventory, and
the self-entry values (the exact model and a firmware under the entry's floor)
are the observed tuple's qualification inputs. None of this changes the statuses
in the table above, the rule that no class is `HARDWARE_TEST_READY`, or any
default-denied field.

## EMMA qualification card

The card identity is `huawei.qualification.emma.readonly@1.0.0`. It applies only
to logical unit 0 and consumes the exact FC03 identity tuple: offset 30000
quantity 15 for offering, offset 30222 quantity 20 for model, and offset 30035
quantity 15 for software version.

After terminal padding is removed, the model must be exactly `EMMA-A01` or
`EMMA-A02`, the admission list of this card within the family `EMMA` that the
consulted editions name without a model list. Firmware meets the floor of its
branch: R024C00 requires SPC100 or
greater within R024C00, and R025C00 requires SPC102 or greater within R025C00.
These are the minima that the two editions state, and a build that follows a
floor inherits the card's identity facts with grade Hypothesis.
No comparison crosses branches. The editions document no order between the
R024C00 and R025C00 branches, so each build is compared with the floor of its
own branch, and a build of a branch with neither a documented floor nor a
documented relation inherits the card's identity facts with grade Hypothesis
under the software applicability rule. No build is refused for being unseen. A SmartLogger
model, near alias, SPC below the floor within R024C00 or R025C00, partial tuple,
or wrong logical unit produces insufficient evidence.

An exact EMMA identity returns `QUALIFICATION_EVIDENCE_BLOCKED` while retaining
zero native telemetry facts. Identity is reproducibly qualified, but the card
does not invent a capability acquisition map. Its missing evidence is named exactly:

- `sanitized_readonly_capability_fixture`;
- `negative_overlap_with_smartlogger`; and
- `model_specific_capability_fixture`.

EMMA-A01 and EMMA-A02 remain distinct capability variants. Neither identity
token creates a load, charger, control, or other telemetry capability.

## EMMA observed-tuple status

One bounded, read-only run, taken after the operator allowed the capture host on
the gateway, read one EMMA at unit 0 and two inverters behind it at units 3 and
4, on one connection. The evidence and its grades are in the
[EMMA observation](emma-observed-identity-v1.md), and the exact entry is in the
[gateway contract](gateway-readonly-v1.md).

Applied to the observed gateway, the EMMA card above returns
`QUALIFICATION_EVIDENCE_BLOCKED` with zero native telemetry facts: the offering,
model, and software reads answered at unit 0, the model is one of the two exact
values, and the software form meets the floor of its own branch (Proven for the
observed installation). The card keeps its identity and its missing-evidence
names, and the executable replay of the observed tuple is the registry
companion's work (helianthus-modbusreg issue 353). The model value, software
branch, and suffix are withheld on the published pages. An EMMA self entry is
now observed: the SmartLogger counter is refused at the EMMA, and the entry's
model is not a SmartLogger model, so it selects no SmartLogger (Proven). The
residual evidence listed for EMMA in the table at the top of this page stands as
follows for the observed installation.

| Residual evidence | State | Grade |
| --- | --- | --- |
| Connected FC03 identity tuple | closed for the observed installation; the other model value and the other branch are not observed | Proven and Unknown |
| `negative_overlap_with_smartlogger` | closed in both directions for the probes issued: the counter read is exception 3 at the EMMA unit and at one inverter, and the EMMA reads are rejected at the SmartLogger endpoint | Proven |
| `sanitized_readonly_capability_fixture` | open; no capability or monitoring block was read | Unknown |
| `model_specific_capability_fixture` | open; the capability of the observed model variant is not established | Unknown |
| Battery addressing | open; no battery is listed or found | Unknown |

The refused runs recorded before the answered run are superseded for the
identity of the observed tuple only, under the same-class rule of the shared
resolution section below: the answered run matched the whole gateway tuple at
unit 0 on one connection and addressed the same endpoint. The refused runs stay
on record, and their cause is a Hypothesis (a gateway that resets the requests
of a client it does not allow). None of this changes the statuses in the table
at the top of this page, the rule that no class is `HARDWARE_TEST_READY`, or any
default-denied field.

## S-Dongle evidence-blocked card

The card identity is
`huawei.qualification.sdongle.evidence-blocked@1.0.0`. Its retained outcome is
`LIVE_STOPPED_PERSISTENT_NON_RESPONSE` at logical unit 100. The prior bounded
basic MEI attempts and the authorized minimal FC03 status attempts all timed
out, and no later Modbus request was sent. A synthetic positive input to the
offline S-Dongle decoder cannot replace this evidence outcome.

Further I/O remains a hard stop. Resumption requires all of:

- confirmed gateway connection context containing endpoint, port, logical unit
  100, and whether the connection reaches a gateway or child;
- `gateway_unit_100_topology` that distinguishes gateway identity from child
  routing;
- `sanitized_basic_mei_product_model_fixture`;
- `exact_protocol_version_encoding_fixture`;
- `completed_search_stable_sequence_capacity_fixture`; and
- `separately_qualified_child_unit_inventory_fixture` for one exact child unit
  before any extended inventory.

The timeout does not prove device absence or incompatibility and never
authorizes a unit scan, child-address inference, extended-MEI fallback, private
function, or retry. A future run requires action-time operator approval.

This section describes the retained card as recorded. A same-class run that
matches the whole exact tuple of one observed path on one connection generation
supersedes the stop for that identity only, as the next section and the
shared-resolution rule state.

## S-Dongle observed-tuple status

Two bounded, read-only runs, taken with the operator's approval at action time,
read one S-Dongle at gateway unit 100 and child unit 1. The evidence and its
grades are in the [S-Dongle observation](sdongle-observed-identity-v1.md), and
the exact tuple is in the [gateway contract](gateway-readonly-v1.md).

Applied to the observed path, the evidence-blocked card above still returns
`QUALIFICATION_EVIDENCE_BLOCKED`: it keeps its identity, its retained outcome,
and its missing-evidence names, and it is the record of the stopped run. The
observed tuple needs its own card in the registry companion (helianthus-modbusreg
issue 351 and pull request 352), and this page defines no card identity for it.
Such a card must accommodate what the observation showed:

- the model block holds printable residue after its first NUL, a next object
  identifier set next to a zero continuation, a declared-object field that is
  not compared, a basic reply with objects beyond the basic category, and one
  inventory entry that is not NUL padded;
- basic identification at the gateway unit is a required exception 1 and not a
  failure, and extended inventory is addressed to the child unit only;
- the card consumes answered replies only, so an unanswered first attempt can
  neither be required nor forged; and
- the gateway names no product, so the selected class carries no model variant,
  and the child's model never becomes the gateway's.

The two observation runs read the gateway unit and the child unit on separate
connections, so neither matched the complete tuple on one connection generation
and neither alone supersedes the stop; a future approved run must match it
whole. The residual evidence listed for S-Dongle in the table above stands as
follows for the observed tuple.

| Residual evidence | State | Grade |
| --- | --- | --- |
| Gateway and child topology | closed for the observed tuple | Proven |
| Stable search and capacity | closed by one before and after pair; the state coding is not read independently | Proven and Hypothesis |
| Separately qualified child inventory | closed for the observed tuple | Proven |
| Exact identity | the child's family identity is observed; the gateway's product is not | Proven and Unknown |
| Protocol encoding | the words are recorded as read; their encoding is open | Proven and Unknown |
| Connection context | not recorded on this page; required again for every further run | Unknown |

The persistent non-response did not reproduce at unit 100 (Proven). Why the
recorded requests went unanswered is Unknown. None of this changes the statuses
in the table at the top of this page, the rule that no class is
`HARDWARE_TEST_READY`, or any default-denied field.

## Shared resolution and negative overlap

Each class result is evaluated independently. Zero positive results produce
`INSUFFICIENT_EVIDENCE`. More than one positive result produces `AMBIGUOUS`,
retains the candidate class names, and selects no class. A failed SmartLogger
inventory does not cause an EMMA or S-Dongle attempt. An EMMA identity does not
cause a SmartLogger inventory request. S-Dongle non-response does not cause a
child scan.

A mixed resolution set containing one positive class and any failed class stays
`INSUFFICIENT_EVIDENCE` with no selected class. A retained persistent
non-response record of a class keeps that class `QUALIFICATION_EVIDENCE_BLOCKED`
and its hard stop in force. The record is superseded only by an observation of
the same class: a result of that class that matched its exact tuple. No other
result can downgrade that hard stop or select another class around it. That
holds for a match of another class, however many classes match; for a failed,
partial, or absent result of the same class; and for the readability of any
register, which is never identity.

When a same-class match supersedes the record, shared resolution drops the
record from the set and resolves the class like any other result: alone it
selects the class, next to a positive result of another class the set is
`AMBIGUOUS`, and next to a failed class the set stays `INSUFFICIENT_EVIDENCE`.
The supersession is of the record's status for the identity that matched and of
nothing more. The record stays on record with its attempts, the profile outcome
is unchanged, monitoring is not admitted, the default-denied fields are
unchanged, and any further live request needs the operator's approval at action
time and a confirmed connection context. Supersession does not say that the
recorded requests should have been answered, and their cause is Unknown.

The rule compares classes and not installations. The sanitized record names no
installation, so whether a superseding match came from the installation that
recorded the stop is not stated by the record (Unknown).

Failed and ambiguous results have an empty selected class, zero native facts,
zero automatic requests, and `fallback_attempted=false`. Missing or unavailable
native values remain unknown; they are never emitted as numeric zero, an empty
telemetry record, or a support claim.

## Sanitized expected result

The shared expected result contains only the three card identities, their
provider-local statuses, the missing-evidence names above, and false or zero
safety fields. It contains no endpoint, port number, serial, ESN, account,
credential, private capture, or device fingerprint.

The common safety result is:

```json
{
  "default_denied": true,
  "catalog_registered": false,
  "automatic_runtime_admission": false,
  "support_claim": false,
  "write_authority": false
}
```

Each class row also has `hardware_test_ready=false`,
`live_qualified=false`, `automatic_request_count=0`, and
`native_fact_count=0`.

## Integration and hardware boundary

These cards close provider-local qualification preparation only. Actual gateway
acquisition, native diagnostics, semantic publication, public surfaces, and
end-to-end replay belong to later integration work. Physical qualification and
hardware acceptance remain separate and are not established by synthetic
fixtures or an offline identity match.

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| SmartLogger V300R024C10SPC191 ModBus Interface Definitions | Issue 52 | 2025-06-06 | the minimum software of the V300 line (p. 15) and the family name in the applicability section (pp. 15–16), on the SmartLogger card; the descriptor keys, key 6 as a feature-version integer, and keys 8 through 10 (pp. 83–85) |
| SmartLogger V300R024C10SPC210 ModBus Interface Definitions | Issue 49 | 2025-03-19 | the minimum software of the V300 line (p. 13) and the family name in the applicability section (pp. 13–14), on the SmartLogger card; the descriptor keys 1 through 6 and key 6 as a parallel-network integer (pp. 97–99) |
| SmartLogger V300R024C10SPC275 Upgrade Guide | Issue 01 | 2026-10-16 | the upgrade path that places the observed V300R023C10 branch before V300R024C10 within the V300 line (pp. 7–8) |
| SmartHEMS V100R024C00 MODBUS Interface Definitions | Issue 01 | 2024-07-15 | the R024C00 floor and the family name `EMMA` on the EMMA card (pp. 7–8) |
| SmartHEMS V100R025C00SPC102 MODBUS Interface Definitions | Issue V100R025C00SPC102 | 2025-08-14 | the R025C00 floor and the family name `EMMA` on the EMMA card (pp. 7–8) |
| Huawei gateway Modbus reference | reference baseline 2026-10-26.1 | 2026-10-26 | locating the minimum statements, the family names, the descriptor keys, and the upgrade path in the documents above |

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
SmartHEMS documents listed above is attributed to Huawei Digital Power
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
