# Huawei Gateway Power Meter Contract V1

## Scope and evidence basis

This page covers power meters that a Huawei gateway lists as children, and the
meter paths observed behind three gateways: what the observations show, what
identity a meter needs, how a meter is exposed, and why a meter's electrical
role is configuration. It defines no register, scale, unit, decoder, or
acquisition, and it creates no admission. The groups that were read, their value
form, and the reads themselves are on the
[monitoring contract](monitoring-readonly-v1.md). The historical V1 name implies
no stability before Helianthus 1.0.

The evidence is the child listing of one SmartLogger-family gateway, described
in the [SmartLogger observation](smartlogger-observed-inventory-v1.md), which
also defines the Proven, Hypothesis, and Unknown grades used below, and, for
PM-08 only, the one inventory read on an S-Dongle path recorded on the
[S-Dongle observation](sdongle-observed-identity-v1.md), and, for PM-10 only, the
one inventory read on an EMMA path recorded on the
[EMMA observation](emma-observed-identity-v1.md). A further bounded read-only run
per path, described on the monitoring contract, read the meter groups at the
SmartLogger's two meter units, at the EMMA's own unit, and at the S-Dongle's
child. The vendor interface definitions listed in the Documents consulted section
name those groups. They are a source for what to read and never an identity.
Proven (answered) on this page grades that a group returned data, or an
exception, at a unit, and the value form of every word stays Hypothesis because
no reference reading of any meter was taken. Grades are separate from admission,
qualification, and support, and `catalog_registered=false`,
`automatic_runtime_admission=false`, `live_qualified=false`,
`support_claim=false`, and `write_authority=false` are unchanged.

## Observed facts

| ID | Statement | Grade |
| --- | --- | --- |
| PM-01 | The listing carries two entries labeled `PowerMeter` (key 1), at routed units 11 and 19. | Proven |
| PM-02 | Neither meter entry has key 8. Key 6 has the same value on both meter entries and on the PLC entry, and a different value on the inverter entries. The firmware text (key 2) has 16 characters, not the 17 of the gateway, inverter, and PLC entries. | Proven |
| PM-03 | The label `PowerMeter` names a class, not a make or model, and no entry text names a manufacturer or a model. | Proven |
| PM-04 | The make, model, and firmware of either meter, and of the meter at the S-Dongle site. The operator declares the CHINT DTSU666 family at the SmartLogger and S-Dongle sites, current-transformer wired at the SmartLogger site. The declaration is configuration and identifies no meter. | Unknown |
| PM-05 | Unit 11 answered the SUN2000 model read with exception 3, the answer that listed units give to an unserved read. Unit 19 was not sent that read. | Proven |
| PM-06 | Both meter units serve electrical-value groups at their own routed units: the AC group and the energy group answered with data at units 11 and 19 (MM-01 of the monitoring contract). | Proven (answered); value form Hypothesis |
| PM-07 | The meter values of the SmartLogger path are also served at the gateway level, at unit 0. | Unknown |
| PM-08 | The one inventory read on an S-Dongle path lists a single inverter entry and no meter, and no meter unit was addressed there. | Proven |
| PM-09 | An S-Dongle lists a power meter at any unit. | Unknown |
| PM-10 | The one inventory read on an EMMA path lists the EMMA, a backup-box entry, and two inverter entries, and no meter, and no meter unit was addressed there. | Proven |
| PM-11 | The EMMA serves meter groups, the built-in sensor groups, at its own unit 0, although its listing names no meter and its backup-box entry was never read (MM-09, MM-11). The operator names the backup box's own built-in meter as the meter in use there and describes no CHINT meter at that site. | Proven (answered); the meter behind the groups Hypothesis |
| PM-12 | The meter-number group and the configuration group were refused with exception 3 at both meter units (MG-04), and the refusals carry forward to the builds that follow the observed one as Hypothesis. The meter number and the transformer ratios, which those groups hold, are Unknown. | Proven (refusal); content Unknown |
| PM-13 | The inverter child behind an S-Dongle serves the inverter-side meter groups with data, while its listing names only itself (MM-16, MM-19). | Proven (answered); value form Hypothesis |
| PM-14 | The meter status word and the meter type word at the S-Dongle child are non-zero. Their meaning is not decoded, and no word at any path identifies a meter make or model (MM-18, MM-08). | Unknown |

The operator's declaration of a meter's family is configuration, not evidence.
Until a read under a meter class contract establishes the make, model, and
firmware, no meter identity exists.

## Family contract: power meter behind a Huawei gateway

| Field | Contract |
| --- | --- |
| Required tuple | Unknown. No meter make, model, or firmware is established. A meter tuple needs an exact model and firmware read at the meter's routed unit, or an exact gateway-level read if exposure is gateway-level, under a meter class contract that does not exist yet. Until one exists, every meter is `INSUFFICIENT_EVIDENCE`. |
| Forbidden identity | The listing label `PowerMeter`, any other listing content (model, firmware, unit), serial number or ESN, the content of the meter-number group, writable alias, readability of any register, an electrical value, a meter status or type word, a transformer ratio, a declared role, a declared make or family, a SUN2000 or other class identity at the unit, and a prefix or wildcard match. |
| Multiple-positive outcome | `AMBIGUOUS`; no selection, order, or priority. |
| Negative-overlap obligations | Executable fixtures showing a meter unit fails the SUN2000 tuple (the model read at unit 11 is an exception, PM-05), and against SmartLogger, EMMA, S-Dongle, and SunSpec probes. Unit 19 was not sent the SUN2000 model read, so it has no evidence for that fixture. |

## Exposure: routed, gateway-level, or inverter-side

The observations show three different exposure paths, one per gateway family:

| Path | Where the meter groups answered | Listed as a child | Grade |
| --- | --- | --- | --- |
| SmartLogger | at the meters' own routed units 11 and 19 (PM-06) | yes, two `PowerMeter` entries (PM-01) | Proven (answered) |
| EMMA | at the gateway's own unit 0, the built-in sensor groups (PM-11) | no (PM-10) | Proven (answered); the meter behind them Hypothesis |
| S-Dongle | at the inverter child's unit 1, the inverter-side groups (PM-13) | no; the child lists only itself (PM-08) | Proven (answered) |

An exposure observed on one path is no claim about another path. Within a path,
an exposure or a refusal observed at a build carries forward to the builds that
follow it, graded Hypothesis, until an observation records a different answer;
it is never read as limited to the observed build. Whether the SmartLogger path
also serves meter values at its unit 0 is Unknown (PM-07), as is whether the
S-Dongle's plant grid power at unit 100 comes from the same meter.

Because no meter class contract exists, a meter that is listed and allowed is
withheld as having no class contract under the child-routing rules in the
[gateway contract](gateway-readonly-v1.md), and no production read is sent to its
unit. The reads of the meter run were observations under the operator's
approval. When a meter class contract exists, it states the exposure path it
observed and its reads follow the same listing-intersect-allowlist rule. A
gateway-level exposure would need its own gateway contract, and an inverter-side
exposure belongs to the inverter's contract, which does not cover meter words
(profile selection stays `NO_ADMISSIBLE_PROFILE`). Neither exists.

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

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| SmartLogger ModBus Interface Definitions | Issue 32 | 2018-11-15 | the names of the AC and energy groups at the SmartLogger meter units (PM-06) |
| SmartLogger ModBus Interface Definitions | Issue 36 | 2020-04-13 | the names of the AC and energy groups at the SmartLogger meter units (PM-06) |
| SmartLogger ModBus Interface Definitions | Issue 37 | 2020-06-24 | the names of the AC and energy groups at the SmartLogger meter units (PM-06) |
| SmartLogger V300R024C10SPC210 ModBus Interface Definitions | Issue 49 | 2025-03-19 | the names of the AC, energy, meter-number, and configuration groups (PM-06, PM-12) |
| SmartLogger V300R024C10 ModBus Interface Definitions | Issue 53 | 2025-10-29 | the names of the AC, energy, meter-number, and configuration groups (PM-06, PM-12) |
| SmartLogger V300R024C10 ModBus Interface Definitions | Issue 54 | 2026-02-06 | the names of the AC, energy, meter-number, and configuration groups (PM-06, PM-12) |
| SmartLogger V300R025C10 ModBus Interface Definitions | Issue 02 | 2026-10-09 | the names of the AC, energy, and configuration groups (PM-06, PM-12) |
| SmartLogger V300R026C10 ModBus Interface Definitions | Issue 02 | 2026-10-09 | the names of the AC, energy, and configuration groups (PM-06, PM-12) |
| SmartHEMS V100R024C00 MODBUS Interface Definitions | Issue 01 | 2024-07-15 | the built-in sensor groups at the EMMA's unit 0 and the note on built-in meters (PM-11) |
| SmartHEMS V100R025C00SPC102 MODBUS Interface Definitions | Issue V100R025C00SPC102 | 2025-08-14 | the built-in sensor groups at the EMMA's unit 0 and the note on built-in meters (PM-11) |
| SUN2000MC V200R023C00 Modbus Interface Definitions | Issue 01 | 2023-03-17 | the inverter-side meter groups at the S-Dongle child and the absence of a value list for the status and type words (PM-13, PM-14) |

The observations that grade these facts are the runs described in the scope
section. No value, table, label, or text of the documents is reproduced here.

**Copyright note.** The information on this page that is derived from the
SmartLogger and SUN2000MC documents listed above is attributed to Huawei
Technologies Co., Ltd., which retains the copyright in those documents. This
page states that information in its own words and does not reproduce the
documents. The CC0-1.0 dedication of this page covers its own expression only
and does not relicense those documents.

**Copyright note.** The information on this page that is derived from the
SmartHEMS documents listed above is attributed to Huawei Digital Power
Technologies Co., Ltd., which retains the copyright in those documents. This
page states that information in its own words and does not reproduce the
documents. The CC0-1.0 dedication of this page covers its own expression only
and does not relicense those documents.

## Open questions

1. The make, model, and firmware of each meter. The operator's declaration of the
   family is configuration (PM-04), and the meter-number group that might hold a
   number was refused (PM-12).
2. The exposure beyond what was read: whether the SmartLogger path also serves
   meter values at its unit 0 (PM-07), whether the S-Dongle's plant grid power at
   unit 100 comes from the same meter, whether the EMMA's built-in sensor groups
   carry the backup box's own meter (PM-11), and whether an observation at
   another build answers differently.
3. Which identity read, if any, a meter unit serves, and its exact extents and
   padding. The meter-number group is serial-bearing and would be no identity
   predicate in any case.
4. Whether meters appear in an EMMA listing (PM-10), behind an S-Dongle (PM-09),
   or behind a hybrid system. The one EMMA listing observed held no meter.
5. The sign of each meter's power words, the direction of its energy counters,
   and the meaning of the S-Dongle child's meter status and type words
   (PM-14). These need a reference reading and are open on the monitoring
   contract.
6. The transformer ratios of the SmartLogger's meters, which sit in a refused
   group (PM-12).
