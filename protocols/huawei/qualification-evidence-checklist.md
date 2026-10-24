# Huawei family evidence closure checklist

This checklist records remaining evidence; it creates no selector, decoder,
provider, qualification, or support claim. The native contracts come first:
[gateway candidates](gateway-readonly-v1.md),
[qualification cards](qualification-readiness-v1.md), and
[inverter/battery disposition](inverter-battery-readonly-v1.md). The observation
record and the contracts derived from it are the
[SmartLogger observation](smartlogger-observed-inventory-v1.md), the
[SUN2000 identity contract](sun2000-observed-identity-v1.md), and the
[power-meter contract](gateway-power-meter-v1.md).
This protocol evidence summary follows the [CC0 publication lane](../../LICENSE).
It does not copy or relicense registry implementation or vendor source material.

## Distinct evidence levels

Proven, Hypothesis, and Unknown describe evidence for an individual claim.
They are separate from parser acceptance, identity matching, profile admission,
and physical qualification. A synthetic test can prove an offline behavior;
it cannot prove that an installation has that identity or capability.

| Family | Published contract | Synthetic parser coverage | Admissible identity tuple | Native profile | Production acquisition |
| --- | --- | --- | --- | --- | --- |
| SmartLogger | Bounded gateway candidate and qualification card | Stable inventory and rejection cases; card is `QUALIFICATION_TEST_READY` | Defined by the gateway contract, including one exact observed tuple; connected evidence exists for that tuple only, and the two documentary tuples are unobserved | Registry disposition `NO_ADMISSIBLE_PROFILE`; unregistered, no decoder keys | Denied; no live qualification or support claim |
| EMMA | Independent FC03 identity and qualification card | Finite identity aliases, branch floors, inventory rejection cases | `OFFLINE_IDENTITY_ADMITTED` only; complete tuple required; no connected observation (no Modbus response) | Capability evidence blocked; unregistered, no telemetry decoder keys | Denied; identity matching supplies no native telemetry facts |
| S-Dongle | Separate gateway and child contracts | Exact candidate tuple evaluation only; positive synthetic input cannot replace stopped qualification | Documentary tuple and offline candidate remain distinct; actual identity insufficient; not attempted | `PRE_LIVE_INSUFFICIENT_EVIDENCE`; unregistered, no decoder keys | Denied; `LIVE_STOPPED_PERSISTENT_NON_RESPONSE`, further I/O hard stopped |
| SUN2000 | Fail-closed disposition only | Decision rows are documentary, not executable detection | One observed exact identity tuple in the identity contract; admissible pinned map absent | `NO_ADMISSIBLE_PROFILE`; no decoder | None admitted; no live qualification |
| LUNA2000 | Separate fail-closed battery disposition | Decision rows are documentary, not executable detection | Unknown; no observed tuple; battery identity cannot be inherited from parent or gateway | `NO_ADMISSIBLE_PROFILE`; no decoder | None admitted; no live qualification |
| Power meter | Class and listing facts only, with the role as configuration | Not applicable; no meter read was issued | Unknown; make, model, firmware, and exposure path are not established | No meter class contract; every meter is `INSUFFICIENT_EVIDENCE` | None admitted; no live qualification |

All rows retain default denial, no automatic runtime admission, no support
claim, and no write authority. No row is `HARDWARE_TEST_READY`.

Registry evidence locators in `helianthus-modbusreg` are
`profiles/vendor/huawei/smartlogger-disposition.json`,
`profiles/vendor/huawei/emma-disposition.json`, and
`profiles/vendor/huawei/sdongle-disposition.json`. Their assertions are in
`huawei_smartlogger_disposition_test.go`, `huawei_emma_test.go`, and
`huawei_sdongle_disposition_test.go`; bounded offline inventory coverage is in
`huawei_smartlogger_inventory_test.go` and `huawei_emma_inventory_test.go`,
with S-Dongle candidate evaluation in `huawei_sdongle_observation_test.go`.
These locators identify inspected evidence, not a test execution or a dependency
on a private artifact. SUN2000 and LUNA2000 Unknown rows come from their linked
native disposition contract.

## SmartLogger closure

- [x] `sanitized_extended_mei_self_entry_fixture`: the evidence is closed for
  the observed tuple (self entry read under an equal counter bracket). The
  registry fixture is the registry companion's work.
- [x] `exact_child_attribute_encoding_fixture`: closed for the observed key set.
  The meaning of keys 3, 6, 9, and 10 stays Unknown.
- [ ] `pairwise_negative_overlap_with_emma_fixture`: one direction is closed
  (EMMA probes at the SmartLogger endpoint are rejected). The reverse direction
  stays open until an EMMA answers.
- [x] Publishable evidence from a bounded read-only qualification for the full
  unit identity, exact firmware, self entry, and inventory guarded by equal
  before and after counters, with native child attributes and pagination
  anomalies preserved under the existing bounds, exists for the observed tuple.
- [ ] The same evidence for the card's two documentary tuples, which were never
  observed.
- [ ] Reconcile that evidence into the registry disposition before claiming an
  admissible native profile; then establish production acquisition separately.

`QUALIFICATION_TEST_READY` describes offline procedure preparation only. It
does not supersede the registry's missing evidence or mean provider-ready.

## EMMA closure

Observation status: two bounded read-only attempts received no Modbus response,
so none of the items below is closed. The cause is Unknown.

- [ ] Retain the complete FC03 offering/model/software tuple and its exact
  model-specific and within-branch firmware rules. Optional MEI enrichment is
  neither initial identity nor a reason to discard a valid FC03 tuple.
- [ ] Close `sanitized_readonly_capability_fixture`,
  `negative_overlap_with_smartlogger`, and `model_specific_capability_fixture`.
  Keep capability variants separate; an identity token establishes no optional
  load, charger, control, or telemetry capability.
- [ ] Establish an admissible native capability/acquisition map, revise the
  blocked disposition, and qualify production reads independently of the
  existing offline identity match.

## S-Dongle closure

Observation status: not attempted, so none of the items below is closed.

- [ ] Preserve the persistent non-response hard stop. Any future run needs new
  action-time operator approval and confirmed gateway/child connection context;
  this checklist authorizes no request or retry.
- [ ] Close `sanitized_basic_mei_product_model_fixture`,
  `exact_protocol_version_encoding_fixture`, and
  `separately_qualified_child_unit_inventory_fixture`.
- [ ] Also satisfy the qualification card's `gateway_unit_100_topology` and
  `completed_search_stable_sequence_capacity_fixture` requirements. Keep the
  documentary default-denied firmware tuple distinct from the offline candidate
  and its independent protocol baseline.
- [ ] Qualify one exact child routing context before extended inventory. A
  gateway timeout permits no child scan, inferred address, or extended-MEI
  fallback. Reconcile the disposition before native-profile admission and
  separately establish production acquisition.

Non-response proves neither absence nor incompatibility. Private functions
remain no-send under the native contract; the
[sanitized disposition](../../architecture/sdongle-qualification-disposition-v1.md)
provides application admission guidance under its separate AGPL license.

## SUN2000 and LUNA2000 closure, independently per family

- [ ] Pin the vendor document name and version and establish publishable facts
  before revising the native contract. The current source is inspection-only;
  its existence grants no redistribution or relicensing permission.
- [x] SUN2000 identity evidence: one observed exact tuple exists. The sanitized
  fixture is the registry companion's work.
- [ ] SUN2000 monitoring fixtures, LUNA2000 identity and monitoring fixtures,
  and executable negative overlap against SmartLogger, EMMA, and S-Dongle. A
  companion page alone closes none of these requirements.
- [x] An exact identity applicability contract for the observed SUN2000 tuple,
  covering model, firmware, and unit identity, exists in the identity contract.
- [ ] An admissible pinned register map for SUN2000, and the equivalent exact
  applicability contract for LUNA2000, before selection, decoding, or
  production acquisition.

All missing registers remain explicitly unspecified: monitoring, scale, unit,
access mode, and availability markers are Unknown, and so is battery identity.
No model family or firmware range is supported. An inverter identity does not
prove battery presence; a gateway child listing proves neither inverter nor
battery identity or capability. Optional absent groups remain unknown, never numeric zero;
optional-group exceptions retain last-known-good values where a future profile
permits, without invalidating an already identified unit.

## Power meter closure

- [x] The rule that a meter's electrical role is configuration and is never
  derived from registers is stated in the power-meter contract.
- [ ] The make, model, and firmware of each meter; the operator confirms them.
- [ ] The exposure path: routed unit, gateway level, or both.
- [ ] A meter class contract with an exact identity read. Until then every meter
  is withheld as having no class contract.

## Evidence retention and closure boundary

Preserve native observations and their identity, provenance, and version context;
document any application projection loss separately. Public examples must be
synthetic and self-contained, without private identifiers or captures. An invalid
inventory yields no partial admission or partial child list; that rule does not
authorize erasing unrelated valid last-known-good observations.

Unknown versions, missing discriminators, collisions, unstable inventory, and
exhausted bounds remain fail-closed under the linked contracts. Evidence never
transfers between gateway, inverter, and battery families. Closing any checklist
item does not itself register a profile or establish live qualification,
production acquisition, hardware acceptance, or parent-issue completion.
