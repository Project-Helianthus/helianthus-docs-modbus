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
- one of the exact firmware tuples `V300R024C10SPC191` or
  `V300R024C10SPC210`.

SPC210 and SPC191 are parallel branches. They are not ordered by document
number and this revision does not apply an `or later` comparison to either.
Unknown V/R/C/SPC combinations remain insufficient.
Writable device name 65524, ESN 40713, basic MEI alone, and optional offering
strings are not detectors.

The change counter must be equal before and after child enumeration.

## S-Dongle candidate

The candidate targets logical unit 100 and requires all of:

- basic MEI product identity for an admitted S-Dongle model;
- FC03 offset 30068, quantity 2, U32 protocol version;
- FC03 offsets 37410 through 37412 for type, completed search state, and stable
  change sequence; and
- FC03 offset 37429, quantity 1, for capacity reconciliation.

The executable offline candidate in this revision is limited to
V200R025C00SPC120 with model A-05, B-03, or B-06. The distinct
S-DongleA-05 / V200R022C10SPC312 tuple remains documentary and default denied;
it must not be collapsed into the V200R025C00SPC120 gate. Protocol baseline D5.0
is an independent decoded gate.

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
wildcard, first-match rule, or implicit alias.

The structured software version must be exactly one of these branch forms:

- `SmartHEMS V100R024C00SPCnnn`, where decimal `nnn` is at least 100; or
- `SmartHEMS V100R025C00SPCnnn`, where decimal `nnn` is at least 102.

The numeric comparison is only within the exact R/C branch. R024 and R025 are
not ordered against one another, and an unrecognized branch or suffix is
insufficient evidence.

`EMMA-A01` and `EMMA-A02` are distinct capability variants. EMMA-A01 never inherits an EMMA-A02-only capability. The base read-only profile projects no
optional smart-load, charger, or control capability from either model token;
each such capability requires its own documented, model-specific gate.

Basic and extended MEI are optional enrichment, never initial EMMA identification. An optional-MEI failure does not negate an already validated
FC03 identity tuple, and optional-MEI success alone is insufficient to identify
the gateway. Serial register 30015, a model-register read without the complete
tuple, or a SmartHEMS prefix without an admitted model are insufficient.

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
Limit exhaustion is insufficient evidence, never partial success.

## Observed exact tuples

The entries below are exact values, observed or defined for the gateway
families. Every entry is compared field by field, byte for byte, and
case-sensitively, after only terminal NUL or space padding is stripped. There is
no wildcard, prefix, range, ordering, alias, case folding, whitespace
normalization, or inheritance between entries, and matching one entry never
implies another. A firmware identity is compared only as a complete string; its
V, R, C, and SPC fields are not parsed into numbers for comparison in this
section. The EMMA branch-floor rule above is an existing candidate rule that
this section does not extend. The Proven, Hypothesis, and Unknown grades are
defined in the [SmartLogger observation](smartlogger-observed-inventory-v1.md)
and are separate from admission and qualification.

| Family | Exact tuple | Basis | Status |
| --- | --- | --- | --- |
| SmartLogger, documentary branch | self-entry model `SmartLogger`, firmware `V300R024C10SPC191` | vendor-document inspection only; no observation | defined by the candidate above; unobserved (Unknown) |
| SmartLogger, documentary branch | self-entry model `SmartLogger`, firmware `V300R024C10SPC210` | vendor-document inspection only; no observation | defined by the candidate above; unobserved (Unknown) |
| SmartLogger, observed branch | gateway unit 0, self-entry model `Smart Logger`, firmware `V300R023C10SPC620`, self-entry unit `0` | sanitized read-only observation | exact entry; Proven for the observed installation |
| EMMA | none | no connected observation | Unknown placeholder |
| S-Dongle, observed single-inverter branch | gateway unit 100 and child unit 1, the tuple of the S-Dongle subsection below, with no gateway model variant | sanitized read-only observation | exact entry; Proven for the observed installation; the gateway's model variant is Unknown |

`SmartLogger` and `Smart Logger` are different strings, and neither is an alias
of the other. The three SmartLogger entries are independent branches with no
order between them. The observed branch is a defined exact entry; whether and
when a registry admits it is the registry's decision, and the entry carries no
qualification, support claim, or write authority. The observed branch is read
through the extended inventory self entry. The basic identification reply
(vendor `HUAWEI`, product, and version) is optional corroboration only. The
S-Dongle entry follows the same rules. It is separate from the documentary
S-Dongle tuple and from the offline candidate, it is read at two units of one
endpoint and not through a listing, and it names no gateway model. These
sections promise no stability before Helianthus 1.0.

### SmartLogger

| Field | Contract |
| --- | --- |
| Required tuple, observed branch | Gateway unit 0. The counter (FC03 offset 65521, quantity 1) is equal before and after one complete extended inventory (FC2B / MEI 0x0e / ReadDevId 0x03, start object 0x87). The first entry, the self entry, has attribute 1 exactly `Smart Logger`, attribute 2 exactly `V300R023C10SPC620`, and attribute 5 exactly `0`. The inventory is valid under the child-inventory rules above and the tolerance requirements of the observation. |
| Required tuple, documentary branches | As the candidate section above: the model and one of the two firmware values in the table. |
| Optional corroboration | A decodable basic read shows vendor `HUAWEI`, product `Smart Logger`, and the same firmware. A disagreement with the self entry is a conflicting detector and produces `insufficient_evidence`. Absence or a decode failure of the basic read changes nothing. |
| Forbidden identity | Serial number or ESN (attribute 4 and the serial-like basic object), the writable device name, readability of any register, a child listing, a basic reply alone, the product string without the firmware string, a prefix, wildcard, case-folded, or whitespace-normalized match, and the unit identifier of an MEI request. The gateway answers a basic read with its own identity for every unit identifier tried. |
| Multiple-positive outcome | No selection. Two matching Huawei candidates, or a Huawei candidate that collides with SunSpec/Fronius or Growatt, is `AMBIGUOUS` in the qualification card and `insufficient_evidence` in the collision rule below. Both select nothing and send nothing, and no order or priority applies. |
| Negative-overlap obligations | Executable fixtures against EMMA, S-Dongle, SunSpec/Fronius, and Growatt. Evidence so far: EMMA probes at the SmartLogger endpoint are exceptions (Proven); S-Dongle probes at logical unit 100 are exceptions and the basic reply is the gateway's own (Proven); no SunSpec marker (Proven); Growatt not probed (Unknown); every reverse direction Unknown. |

### EMMA

| Field | Contract |
| --- | --- |
| Required tuple | Unknown. No exact EMMA tuple has been observed, so no observed EMMA entry exists. The candidate above stays documentary and unobserved. An observed EMMA tuple would be a separate exact entry; the candidate's within-branch floors are a numeric comparison that this section's exact-value semantics do not use. |
| Forbidden identity | Serial number or ESN, the serial register, a model-register read without the complete tuple, a `SmartHEMS` prefix without an admitted model, optional MEI alone, child listing, writable alias, readability, and a prefix or wildcard match. |
| Multiple-positive outcome | No selection; `AMBIGUOUS` in the qualification card and `insufficient_evidence` in the collision rule, with no order or priority. |
| Negative-overlap obligations | Against SmartLogger: EMMA probes at the SmartLogger endpoint are rejected (Proven); SmartLogger probes at an EMMA endpoint are Unknown. Against S-Dongle: EMMA probes at the S-Dongle path do not return an EMMA tuple, because the offering and software offsets answer the child's own identity texts, the model offset answers non-text data, and unit 0 is silent (Proven); S-Dongle probes at an EMMA endpoint are Unknown. |
| Evidence state | Two bounded read-only attempts received no Modbus response of any kind: connections were accepted and then closed by the peer on the first request. The cause is Unknown; Modbus TCP disabled on the device, a client allowlist, and a session held by another client are candidates that were not tested. Identity, children, and capability are Unknown. |

### S-Dongle

| Field | Contract |
| --- | --- |
| Required tuple, observed single-inverter branch | All of the following at the stated units on one connection generation. Gateway unit 100: basic identification (FC2B / MEI 0x0e, read code 1) is answered with exception 1; FC03 offset 37411, quantity 1, reads 0; FC03 offset 30068, quantity 2, reads 50 then 0, compared as words and never decoded; FC03 offset 37410, quantity 3, has type word 4 and state word 0 (the equality of the sequence across the child identification reads was not observed, SD-08, and is not part of the tuple); FC03 offset 37429, quantity 1, reads at least 1. Child unit 1: the model block (FC03 offset 30000, quantity 15) is a printable non-empty model text of the SUN2000 family, a NUL, optional printable residue, and NUL padding over the full 30 bytes; basic identification (read code 1) carries vendor exactly `Huawei`, product exactly `SUN2000`, and a present version object, each object once; the extended inventory from object 0x87 (read code 3) is one page with conformity 0x03, no continuation, count object value 1, and one entry object 0x88 whose keys are exactly 1 through 6, each once, whose key 1 equals the model text, and whose key 5 is exactly `1`. No specific child model token is a discriminator of the tuple. The gateway names no product, so there is no gateway model variant. The full contract and the tolerances are on the [S-Dongle observation](sdongle-observed-identity-v1.md). |
| Required tuple, other branches | Unknown. The executable candidate above and the separate documentary tuple both stay unobserved, and they stay distinct from each other and from the observed branch. |
| Forbidden identity | Serial number or ESN, a writable alias, readability of any register (including the S-Dongle's own search and capacity registers answered at the child, the EMMA offsets, and the SunSpec offset), readability of logical unit 100 or search status alone, basic identification alone, a child listing, the unit identifier of a request, and a prefix, wildcard, case-folded, or whitespace-normalized match. |
| Multiple-positive outcome | No selection; `AMBIGUOUS` in the qualification card and `insufficient_evidence` in the collision rule, with no order or priority. |
| Negative-overlap obligations | Against SmartLogger: the counter read at the child is an exception and unit 0 is silent, the basic reply at the child is its own SUN2000 identity, and S-Dongle probes at the SmartLogger endpoint are exceptions with the gateway's own basic reply (all Proven); the counter read at unit 100 is Unknown. Against EMMA: EMMA probes at the S-Dongle path do not return an EMMA tuple (Proven); S-Dongle probes at an EMMA endpoint are Unknown. Against SunSpec: no marker at the child (Proven). Growatt is Unknown. |
| Evidence state | Two bounded read-only runs on one S-Dongle fronting one inverter, taken with the operator's approval at action time, observed the branch above (Proven for the observed installation). The recorded persistent non-response did not reproduce at unit 100, and it is superseded for the identity of the observed branch only, by a result of the same class, as the [readiness contract](qualification-readiness-v1.md) states. Any further request needs action-time operator approval with confirmed connection context. The gateway's product, the encoding of the protocol words, the child unit without a scan, and every unit other than 0, 1, 2, 3, and 100 are Unknown. |

## Evidence gaps after observation

The gap names are those of the registry dispositions and the qualification
cards. Closing a gap here means the evidence exists and is described; the
registry fixture and the reconciliation of its disposition remain the registry
companion's work, and no gap closure is a qualification or support claim.

| Gap | Family | State | Grade |
| --- | --- | --- | --- |
| `sanitized_extended_mei_self_entry_fixture` | SmartLogger | Closed by observation for the observed branch | Proven |
| `exact_child_attribute_encoding_fixture`, structure | SmartLogger | Closed for the observed key set | Proven |
| `exact_child_attribute_encoding_fixture`, meaning of keys 3, 6, 9, and 10 | SmartLogger | Open | Unknown |
| `pairwise_negative_overlap_with_emma_fixture` | SmartLogger | Partly closed: EMMA probes at the SmartLogger endpoint are rejected; the reverse direction is open | Proven and Unknown |
| Connected identity at the two documentary firmware values | SmartLogger | Open; never observed | Unknown |
| Connected FC03 identity tuple | EMMA | Open; no Modbus response | Unknown |
| `sanitized_readonly_capability_fixture` | EMMA | Open | Unknown |
| `negative_overlap_with_smartlogger` | EMMA | Partly closed: one direction only | Proven and Unknown |
| `model_specific_capability_fixture` | EMMA | Open | Unknown |
| `gateway_unit_100_topology` | S-Dongle | Closed by observation for the observed tuple: unit 100 is the gateway and unit 1 is the child | Proven |
| `sanitized_basic_mei_product_model_fixture` | S-Dongle | Partly closed: the gateway refuses basic identification and the child returns vendor and family; the gateway's product string was not obtained | Proven and Unknown |
| `exact_protocol_version_encoding_fixture` | S-Dongle | Partly closed: the protocol words are recorded as read at the gateway and the child; their encoding is open | Proven and Unknown |
| `completed_search_stable_sequence_capacity_fixture` | S-Dongle | Closed for the observed tuple by one before and after pair; the coding of the state value and the bracket around the child inventory are open | Proven, Hypothesis, and Unknown |
| `separately_qualified_child_unit_inventory_fixture` | S-Dongle | Closed for the observed tuple: child unit 1, one page, one entry | Proven |
| `pairwise_negative_overlap_with_emma_fixture` | S-Dongle | Partly closed: EMMA probes at the S-Dongle path do not return an EMMA tuple; S-Dongle probes at an EMMA endpoint are open | Proven and Unknown |
| Connected identity at the candidate's tuple and the documentary tuple | S-Dongle | Open; the observed gateway named no product or firmware | Unknown |

## Child routing

This section defines how a child listed in a SmartLogger inventory maps to a
routed unit, and what happens when the listing and an operator allowlist
disagree. The same rules are the contract for an EMMA inventory, but no EMMA
inventory has been observed and this section creates no EMMA admission. The
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
| Listed and allowed, routed identity exact | the unit is in the listing and the allowlist, and the class contract's routed identity request is exact | identity is established by the routed read under the class contract, with the listing as corroboration only; the observed SUN2000 tuple still leaves profile selection at `NO_ADMISSIBLE_PROFILE` | none | Proven (eight units) |
| Listed and allowed, routed identity not exact | the routed read is an exception, not exact, not ASCII, or unpadded | `INSUFFICIENT_EVIDENCE`; the child is withheld as `identity_insufficient`; the failed read is retained | none | Proven for exceptions at two units; other causes Unknown |
| Listed but not allowed | the unit is in the listing and not in the allowlist | withheld as `not_allowlisted`; no routed read; the entry stays as listing evidence; the allowlist is not extended | none | Unknown (no allowlist was in force) |
| Allowed but not listed | the unit is in the allowlist and not in the listing | withheld as `not_listed`; no read and no probe, even if the unit would answer | none | Unknown |
| Listing changed during enumeration | the counter differs before and after, or a page is malformed, repeated, miscounted, or loops | the whole enumeration is rejected as `listing_unstable`; no partial list; every child of the endpoint is withheld; a committed listing from an earlier enumeration is stale history only | all children of this gateway; other endpoints unaffected | Unknown (the counter never changed) |
| One child times out while siblings answer | a routed read for one unit times out | that child is withheld for the cycle as `child_timeout`, with its last-known-good observation and age retained; no re-enumeration, scan, or sibling retry; repeated timeouts back off that child only | siblings and the gateway unaffected | Unknown (no child read timed out) |
| Gateway-unit read fails | the counter or inventory read at the gateway unit times out, is an exception, or is malformed | the endpoint is `INSUFFICIENT_EVIDENCE`; no child read; no child-unit scan and no extended-MEI fallback | all children of this endpoint | Unknown |
| Listing and routed model disagree | the listing's model differs from the model read at the routed unit | withheld as `identity_mismatch`; both readings are retained; the unit is not reassigned | none | Unknown (all eight agreed) |
| Listed class has no class contract | a listed and allowed unit labeled PLC or PowerMeter | withheld as `no_class_contract`; no routed read | none | Proven (the entries exist) |
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
Growatt is also insufficient. Timeout, disconnect, unstable inventory, unknown
version, malformed strings, or a non-optional Modbus exception produces no
send and no partial profile.

Executable inventory parsing, candidate decoding, and pairwise overlap proof
belong to the consuming profile registry. This page creates no admission by
itself.

The per-class qualification cards, missing-evidence outcomes, and shared
no-fallback result are defined in
[`qualification-readiness-v1.md`](qualification-readiness-v1.md).
