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

## Shared resolution and negative overlap

Each class result is evaluated independently. Zero positive results produce
`INSUFFICIENT_EVIDENCE`. More than one positive result produces `AMBIGUOUS`,
retains the candidate class names, and selects no class. A failed SmartLogger
inventory does not cause an EMMA or S-Dongle attempt. An EMMA identity does not
cause a SmartLogger inventory request. S-Dongle non-response does not cause a
child scan.

A mixed resolution set containing one positive class and any failed class stays
`INSUFFICIENT_EVIDENCE` with no selected class. A retained S-Dongle persistent
non-response keeps `QUALIFICATION_EVIDENCE_BLOCKED`; shared resolution cannot
downgrade that hard stop or select another class around it.

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
