# Huawei Gateway Power Meter Contract V1

## Scope and evidence basis

This page covers power meters that a Huawei gateway lists as children: what the
observation shows, what identity a meter needs, how a meter is exposed, and why a
meter's electrical role is configuration. It defines no register, scale, unit,
decoder, or acquisition, and it creates no admission. The historical V1 name
implies no stability before Helianthus 1.0.

The evidence is the child listing of one SmartLogger-family gateway, described
in the [SmartLogger observation](smartlogger-observed-inventory-v1.md), which
also defines the Proven, Hypothesis, and Unknown grades used below, and, for
PM-08 only, the one inventory read on an S-Dongle path recorded on the
[S-Dongle observation](sdongle-observed-identity-v1.md), and, for PM-10 and
PM-11 only, the one inventory read on an EMMA path recorded on the
[EMMA observation](emma-observed-identity-v1.md). No register of any
meter unit was read for electrical values. The vendor interface
definition stays inspection-only and supplies nothing here. Grades are separate
from admission, qualification, and support, and `catalog_registered=false`,
`automatic_runtime_admission=false`, `live_qualified=false`,
`support_claim=false`, and `write_authority=false` are unchanged.

## Observed facts

| ID | Statement | Grade |
| --- | --- | --- |
| PM-01 | The listing carries two entries labeled `PowerMeter` (key 1), at routed units 11 and 19. | Proven |
| PM-02 | Neither meter entry has key 8. Key 6 has the same value on both meter entries and on the PLC entry, and a different value on the inverter entries. The firmware text (key 2) has 16 characters, not the 17 of the gateway, inverter, and PLC entries. | Proven |
| PM-03 | The label `PowerMeter` names a class, not a make or model, and no entry text names a manufacturer or a model. | Proven |
| PM-04 | The make, model, and firmware of either meter. | Unknown |
| PM-05 | Unit 11 answered the SUN2000 model read with exception 3, the answer that listed units give to an unserved read. Unit 19 was never read. | Proven |
| PM-06 | A meter unit serves an identity read or electrical values at its routed unit. | Unknown |
| PM-07 | Meter values are exposed at the gateway level, at unit 0, instead of or in addition to routed units. | Unknown |
| PM-08 | The one inventory read on an S-Dongle path lists a single inverter entry and no meter, and no meter unit was addressed there. | Proven |
| PM-09 | An S-Dongle fronts a power meter, or lists one at any unit. | Unknown |
| PM-10 | The one inventory read on an EMMA path lists the EMMA, a backup-box entry, and two inverter entries, and no meter, and no meter unit was addressed there. | Proven |
| PM-11 | An EMMA fronts a power meter that its listing omits. | Unknown |

Until the operator confirms the make and model, no meter identity exists.

## Family contract: power meter behind a Huawei gateway

| Field | Contract |
| --- | --- |
| Required tuple | Unknown. No meter make, model, or firmware is established. A meter tuple needs an exact model and firmware read at the meter's routed unit, or an exact gateway-level read if exposure is gateway-level, under a meter class contract that does not exist yet. Until one exists, every meter is `INSUFFICIENT_EVIDENCE`. |
| Forbidden identity | The listing label `PowerMeter`, any other listing content (model, firmware, unit), serial number or ESN, writable alias, readability of any register, an electrical value, a declared role, a SUN2000 or other class identity at the unit, and a prefix or wildcard match. |
| Multiple-positive outcome | `AMBIGUOUS`; no selection, order, or priority. |
| Negative-overlap obligations | Executable fixtures showing a meter unit fails the SUN2000 tuple (the model read at unit 11 is an exception, PM-05), and against SmartLogger, EMMA, S-Dongle, and SunSpec probes. Unit 19 has no evidence. |

## Exposure: routed or gateway-level

The listing shows meters as separate children with their own routed units. That
is the only observed exposure fact (PM-01). Whether a meter's values are served
at its routed unit with a gateway-normalized register set, or at the gateway
unit as gateway-level values, is Unknown (PM-06, PM-07). A provider must assume
neither.

Because no meter class contract exists, a meter that is listed and allowed is
withheld as having no class contract under the child-routing rules in the
[gateway contract](gateway-readonly-v1.md), and no read is sent to its unit.
When a meter class contract exists, it states the exposure path it observed and
its reads follow the same listing-intersect-allowlist rule. A gateway-level
exposure would need its own gateway contract, which does not exist.

## Role is configuration

1. The operator declares each meter's electrical role in configuration, for
   example a grid connection or a feeder or circuit measurement. The
   declaration is keyed to the endpoint and the routed unit, or to the
   gateway-level channel if exposure is gateway-level.
2. A role is never derived from registers. It is also never derived from the
   sign or magnitude of a power value, the label, the unit number, the listing
   order, the model, or the presence of another meter.
3. A meter without a declared role has role Unknown. This page defines no
   default role and no inferred role. A fact that depends on the role is not
   published without a declaration, and the semantic contract owns that
   consequence.
4. A declared role is configuration, not evidence. It does not identify the
   meter, supplies no discriminator, and changes no identity outcome.
5. Declaring a role writes nothing to the gateway or the meter.

## Open questions

1. The make, model, and firmware of both meters; the operator confirms them.
2. The exposure path: routed unit, gateway level, or both (PM-06, PM-07).
3. Whether unit 19 answers any read, since it lies outside the probed range.
4. Which identity read, if any, a meter unit serves, and its exact extents and
   padding.
5. Whether meters appear in an EMMA listing (PM-11), behind an S-Dongle (PM-09),
   or behind a hybrid system. The one EMMA listing observed held no meter
   (PM-10).
