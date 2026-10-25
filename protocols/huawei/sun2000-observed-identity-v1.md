# Huawei SUN2000 Observed Identity Applicability V1

## Scope and relation to the disposition

This page defines exact identity applicability for the SUN2000 inverter tuple
observed behind a SmartLogger-family gateway, and records the LUNA2000 optional
group as an Unknown placeholder. It is an identity contract only. It defines no
monitoring register, scale, unit, decoder, or acquisition. Profile admission
still requires a pinned register map, so the outcome of the
[inverter and battery disposition](inverter-battery-readonly-v1.md) for profile
selection is unchanged: `NO_ADMISSIBLE_PROFILE`. Where that page records
identity as unobserved, this page supersedes the status for identity only;
every monitoring, scale, unit, access-mode, and availability fact stays
Unknown. The disposition page publishes no register offset by design, so the
offsets this identity contract needs are published here.

Every statement rests on the sanitized observation record described in the
[SmartLogger observation](smartlogger-observed-inventory-v1.md), which also
defines the Proven, Hypothesis, and Unknown grades used below. SU-10 to SU-12
rest on the [S-Dongle observation](sdongle-observed-identity-v1.md) instead, and
SU-13 to SU-16 rest on the [EMMA observation](emma-observed-identity-v1.md).
Each read used here is one that the public
[gateway contract](gateway-readonly-v1.md) already defines for another Huawei
family; the observation shows what a routed SUN2000 unit returns at those
offsets. No offset or string is taken from the vendor
interface definition: this page rests on observations only, as its Documents
consulted section records. Grades are separate from
admission, qualification, and support, and `catalog_registered=false`,
`automatic_runtime_admission=false`, `live_qualified=false`,
`support_claim=false`, and `write_authority=false` are unchanged. The
historical V1 name implies no stability before Helianthus 1.0.

## Family contract: SUN2000 behind a SmartLogger-family gateway

| Field | Contract |
| --- | --- |
| Family | SUN2000 three-phase inverter with the exact model token `SUN2000-50KTL-M3` only. Other model tokens of the same product line are outside this contract; no prefix, wildcard, or range links two tokens. |
| Required tuple | All of the following at one routed unit `u` on one connection generation. Model: FC03 offset 30000, quantity 15, text exactly `SUN2000-50KTL-M3` after terminal NUL padding is stripped. Firmware: FC03 offset 30035, quantity 15, text exactly `V200R023` after terminal NUL padding is stripped. Unit: `u` is in 1 through 247, is attribute 5 of exactly one entry of a validated listing of the gateway, and is in the operator allowlist. |
| Recorded, not gating | The protocol words (FC03 offset 30068, quantity 2; observed 5 then 0, encoding Unknown), the listing's firmware text, and the listing's product type. They corroborate and are retained as native evidence; they select and reject nothing. |
| Forbidden identity | Serial number, ESN (listing key 4 or the serial-bearing block), writable alias, readability of any register (including a successful read at the EMMA offering offset or the S-Dongle protocol offset), any child listing content (label, model, product type, firmware, unit), the gateway's own MEI reply addressed to the unit, and a prefix, wildcard, case-folded, or whitespace-normalized match. The routed firmware text and the listing firmware text are never compared as prefix and suffix. |
| Multiple-positive outcome | `AMBIGUOUS`: another Huawei class contract that is also positive at the same endpoint and unit produces no selection, and no order or priority breaks the tie. |
| Negative-overlap obligations | Executable fixtures against SmartLogger (the counter read at the unit is an exception and the MEI reply is the gateway's), EMMA (the model gate fails on non-text data), S-Dongle (search and capacity reads are exceptions; the protocol read answers and is no discriminator), SunSpec (no marker), and Growatt (Unknown: not probed). The evidence is in the observation page's overlap table. |
| Failure outcome | A missing, non-ASCII, unpadded, excepted, timed-out, or contradictory element produces `INSUFFICIENT_EVIDENCE`, no profile, and zero native monitoring facts. |
| Outcome when every element is exact | Identity applicability holds for this tuple. Profile selection stays `NO_ADMISSIBLE_PROFILE` and zero monitoring facts are emitted. |

A listing may limit which identity requests a provider sends to a listed,
allowed unit, but it never supplies the answer. The identity reads of one tuple
are all taken at the same routed unit.

### Decision outcomes

| Situation | Outcome |
| --- | --- |
| Model and firmware exact at the routed unit, unit validated | identity applicability holds; profile `NO_ADMISSIBLE_PROFILE` |
| Model without firmware, or firmware without model | `INSUFFICIENT_EVIDENCE` |
| Listing entry only, no routed read | `INSUFFICIENT_EVIDENCE` |
| Serial number or ESN only | `INSUFFICIENT_EVIDENCE` |
| Routed model differs from the listing's model | `INSUFFICIENT_EVIDENCE`; the child is withheld |
| Unit not in the listing, or not in the allowlist | no read is sent; the child is withheld |
| Another Huawei class also positive at the unit | `AMBIGUOUS` |

## Reads, extents, and padding

| Read | Extent | Observed value form | Grade |
| --- | --- | --- | --- |
| Model | FC03 offset 30000, quantity 15: 30 bytes | 16 ASCII characters then 14 NUL bytes, identical on units 1 through 8 | Proven |
| Firmware | FC03 offset 30035, quantity 15: 30 bytes | 8 ASCII characters then 22 NUL bytes, identical on units 1 through 8 | Proven |
| Protocol words | FC03 offset 30068, quantity 2: 4 bytes | two words, 5 then 0, identical on units 1 through 8 | Proven |
| Serial-bearing block | read on units 1 and 2: 20 bytes | ASCII with NUL padding; never published, never a predicate | Proven |
| Listing entry | one 254-byte object | text then NUL padding; the inverter entries carry 164 pad bytes | Proven |

The shared encoding applies: a string occupies exactly `quantity * 2` bytes,
the raw extent is retained, ASCII is required, and only terminal NUL or space
padding is stripped. A value that leaves no padding byte in its extent is not
matched, because it may be truncated. Observed values leave 14 and 22 padding
bytes, which is the basis for that rule (Hypothesis).

## Routed-unit observations

| ID | Statement | Grade |
| --- | --- | --- |
| SU-01 | Units 1 through 8 each answered the model read with `SUN2000-50KTL-M3`, the firmware read with `V200R023`, and the protocol read with 5 then 0; all eight agree. | Proven |
| SU-02 | For all eight units, the routed model string equals key 1 of the listing entry whose key 5 is that unit. | Proven |
| SU-03 | For all eight units, the routed firmware text is the leading eight characters of the listing's key 2 value `V200R023C00SPC128`. | Proven |
| SU-04 | The routed read carries only the leading part of the version, and the remainder appears only in the listing. | Hypothesis |
| SU-05 | Distinct builds that share the leading part can be told apart at the routed unit. | Unknown |
| SU-06 | Reads to units 1 through 8 are served at the gateway's endpoint under their own unit identifiers. The physical path behind the gateway is not established. | Proven |
| SU-07 | The model read at the PLC unit (9) and at a meter unit (11) answered exception 3, so the SUN2000 tuple fails there. Unit 19 was not read. | Proven |
| SU-08 | A battery group is attached to any observed inverter. | Unknown |
| SU-09 | Other SUN2000 model tokens, other firmware text, or another gateway family report these forms, apart from the one S-Dongle child that SU-10 to SU-12 record and the two EMMA children that SU-13 to SU-16 record. | Unknown |
| SU-10 | A SUN2000-family child behind an S-Dongle (unit 1) answers the model read with a model token other than `SUN2000-50KTL-M3`, so the tuple of this page does not match it. Its own tuple is on the [S-Dongle observation](sdongle-observed-identity-v1.md). | Proven |
| SU-11 | That model block holds printable residue after the first NUL, whereas the model block of units 1 through 8 holds 14 NUL padding bytes after the text (read table above), so the form differs apart from the token. | Proven |
| SU-12 | The protocol words at that child read 5 then 0, as at units 1 through 8, so the protocol words separate neither the gateway family nor the model. | Proven |
| SU-13 | Two SUN2000-family children behind an EMMA (units 3 and 4) answer the model read with one model token, the same at both units and other than `SUN2000-50KTL-M3`, so the tuple of this page does not match them. Their own contract is on the [EMMA observation](emma-observed-identity-v1.md). | Proven |
| SU-14 | That model block holds NUL bytes and then printable residue that reaches the end of the extent with no trailing NUL padding, whereas the model block of units 1 through 8 holds 14 NUL padding bytes after the text (read table above), and the S-Dongle child's residue is followed by NUL padding (SU-11). | Proven |
| SU-15 | The protocol words at both EMMA children read 5 then 0, as at units 1 through 8 and at the S-Dongle child (SU-12). | Proven |
| SU-16 | The firmware text at the EMMA children is not the 8 characters read at units 1 through 8: it shares its leading part with key 2 of its listing entry and differs after that part, so it is not a prefix of key 2, which SU-03 found at units 1 through 8. SU-04, the statement that the routed read carries only the leading part of the version, is therefore a statement about the SmartLogger path only. | Proven |

The firmware component of the tuple is the value read at the routed unit, not
the listing's longer value, and the listing value gates nothing. Two builds that
share the leading part are therefore not distinguishable at the routed unit
(SU-05). Whether the leading part is enough to bind a register map is a
decision for the monitoring contract and the registry. Until it is made, no map
binds to this tuple.

## Optional groups: hybrid SUN2000 and LUNA2000

No hybrid SUN2000 and no LUNA2000 battery was observed, so every statement about
them is Unknown. The form of the contract is fixed so that nothing is inferred
from the inverter-only tuple above.

| Field | Contract |
| --- | --- |
| Required tuple | Unknown. A hybrid SUN2000 needs its own exact tuple of the same form (model, firmware, routed unit). The LUNA2000 group needs a separate exact identity read; neither is defined by this revision. |
| Forbidden identity | The parent inverter's identity, a hybrid model token, any child listing content, serial number or ESN, a writable alias, register readability, and a prefix or wildcard match. A battery group is never inferred from an inverter model. |
| Multiple-positive outcome | `AMBIGUOUS`; no selection, order, or priority. |
| Negative-overlap obligations | Executable fixtures against the inverter-only tuple above, SmartLogger, EMMA, and S-Dongle. No evidence exists. |

The existing optional-group rules still apply. An absent group yields Unknown
values, never numeric zero. A read exception on the group does not negate an
identified inverter, and last-known-good values are retained where a profile
permits. An inverter identity does not prove battery presence, and a gateway
listing proves neither inverter nor battery identity.

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| none | none | none | none |

This page rests on observations only: the routed-unit reads and the listing
described in the [SmartLogger observation](smartlogger-observed-inventory-v1.md),
and the S-Dongle child recorded on the
[S-Dongle observation](sdongle-observed-identity-v1.md). No vendor document was
consulted to write it. The monitoring contract that follows lists the vendor
interface definition it rests on in its own Documents consulted section, with
the title, version, and date of the document and a copyright note in force,
under the page conventions in the
[applicability and licensing page](../applicability-and-licensing.md).

**Copyright note.** Not applicable. No information on this page is derived from
a vendor document.

## Open questions

1. Is the leading eight-character firmware text enough to bind a register map,
   or does a map need the full text that only the listing carries? A listing
   cannot be identity, so a second routed read of the full text would have to
   be found. Its existence is Unknown.
2. Which other SUN2000 model tokens and firmware texts exist behind this and
   other gateway families? Each needs its own exact tuple and observation. One
   further child behind an S-Dongle has its own tuple (SU-10), and the two behind
   an EMMA have theirs (SU-13).
3. What does the protocol-word pair encode, and should it become a gate? Its
   encoding is Unknown.
4. Does a PLC or meter unit answer any SUN2000-shaped read other than an
   exception? Only the model read was issued there.
5. Which hybrid SUN2000 tuple and LUNA2000 group identity exist, and is the
   group read at the parent's routed unit or at a separate unit? No evidence
   exists.
