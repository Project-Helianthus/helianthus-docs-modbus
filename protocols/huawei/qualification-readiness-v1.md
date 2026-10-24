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
`SmartLogger`. Its software version must be exactly
`V300R024C10SPC191` or `V300R024C10SPC210`; these are separate exact tuples,
not an ordered firmware ladder.

Child attributes use the existing bounded semicolon encoding: key 1 is model,
2 software version, 3 protocol version, 4 sensitive native identity input,
5 routing address, 6 feature version, and 8 product type. Key 4 is validated
but never copied into a public fixture. Unknown keys, repeated keys, missing
model, malformed ASCII, repeated child address, or wrong object order rejects
the whole inventory. A counter change, count mismatch, cursor loop, second wrap, or any exhausted limit rejects
the whole inventory. No partial child list survives a failure.

An EMMA self entry is a SmartLogger negative control and produces no SmartLogger
selection. A successful synthetic card proves only that the bounded qualification
procedure and retention logic are ready. The connected read-only identity and
inventory capture remains missing.

## SmartLogger observed-tuple status

The residual evidence listed for SmartLogger in the table above, one connected
read-only identity and inventory capture, is closed for one observed tuple and
stays open for the card's two documentary tuples, which were never observed.
The observed tuple is a separate exact entry in the
[gateway contract](gateway-readonly-v1.md); its evidence and grades are in the
[SmartLogger observation](smartlogger-observed-inventory-v1.md).

Applied to the observed gateway, the card above returns
`INSUFFICIENT_EVIDENCE`, because the gateway's self-entry model and firmware are
outside the card's two exact tuples. That is the card working as written, not a
failure of the gateway. The observed tuple needs its own card in the registry
companion, and this page defines no card identity for it. Such a card must
accommodate what the observation showed:

- responses of at least 263 bytes with one object each, and a declared-object
  field that differs from the objects present; the "count mismatch" rejection
  above compares the count object with the number of entries and does not
  refer to that field;
- a count object that includes the self entry;
- attribute keys 9 and 10 as known opaque keys, and attribute order that is
  not numeric; and
- a basic reply that carries more than the basic category, which is optional
  corroboration only.

A counter that stays equal across the bracket, a complete valid inventory, and
the exact self-entry values are the observed tuple's qualification inputs. None
of this changes the statuses in the table above, the rule that no class is
`HARDWARE_TEST_READY`, or any default-denied field.

## EMMA qualification card

The card identity is `huawei.qualification.emma.readonly@1.0.0`. It applies only
to logical unit 0 and consumes the exact FC03 identity tuple: offset 30000
quantity 15 for offering, offset 30222 quantity 20 for model, and offset 30035
quantity 15 for software version.

After terminal padding is removed, the model must be exactly `EMMA-A01` or
`EMMA-A02`. Firmware must remain in its own branch: R024C00 requires SPC100 or
greater within R024C00, and R025C00 requires SPC102 or greater within R025C00.
No comparison crosses branches. A SmartLogger model, near alias, unknown branch,
below-floor SPC, partial tuple, or wrong logical unit produces insufficient
evidence.

An exact EMMA identity returns `QUALIFICATION_EVIDENCE_BLOCKED` while retaining
zero native telemetry facts. Identity is reproducibly qualified, but the card
does not invent a capability acquisition map. Its missing evidence is named exactly:

- `sanitized_readonly_capability_fixture`;
- `negative_overlap_with_smartlogger`; and
- `model_specific_capability_fixture`.

EMMA-A01 and EMMA-A02 remain distinct capability variants. Neither identity
token creates a load, charger, control, or other telemetry capability.

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

This section describes the retained card as recorded. A subsequent observation
supersedes the stop for the identity of one observed tuple only, as the next
section and the shared-resolution rule state.

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

The residual evidence listed for S-Dongle in the table above stands as follows
for the observed tuple.

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
