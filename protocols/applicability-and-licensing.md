# Protocol Applicability and Licensing

## Publication boundary

The protocol material in `protocols/`, including this independently authored
interoperability specification, is published under CC0-1.0. It describes
protocol facts needed to build compatible software. Repository policy,
development guidance, CI tooling, and Helianthus-specific architecture remain
under the separate license lane defined in `LICENSE`. This protocol material
does not redistribute vendor manuals, register tables, screenshots, firmware,
or extracted prose.

The license of this specification does not change the copyright status of
material consulted while establishing a protocol fact. Vendor-authored material
stays copyright-retained by its author and is never copied into source,
fixtures, tests, or documentation. Official vendor documentation may be
consulted, cited, and attributed under the next section.

## Official vendor documentation

Official vendor documentation is documentation that the vendor itself has
published officially and publicly, such as an interface definition or a product
manual that anyone can obtain from the vendor without an agreement or an
account. A page may rest on such a document when it names the consulted
document and its version in a Documents consulted section. Material that is not
official vendor documentation, including a copy from a third party and a
document obtained under an agreement or behind an account, is outside this
policy: it is not cited, not listed as consulted, and not a source of facts
unless the repository owner decides otherwise. The owner decisions taken so far
are recorded in the independent reference works section below. The policy
applies to every vendor family in this repository.

Consulting and citing an official vendor document is allowed. Copying it is
not. A page does not reproduce or quote the vendor's register map, tables,
labels, descriptions, screenshots, or prose. When the external document exists,
the page states only the following, in its own words:

- what Helianthus reads and uses, as the exact facts it relies on, such as an
  offset, a quantity, a value form, or a unit rule;
- derived notes, which are findings that the document does not state in one
  place, such as a discovered version gate or an element deduced by reading
  several versions of the document; and
- observations from operator-owned installations, graded Proven, Hypothesis, or
  Unknown on the page as before.

What this repository publishes under CC0-1.0 in `protocols/` is what the vendor
has not published officially and publicly, or what Helianthus consolidated from
many documents into a structure of its own. Information derived from a vendor
document keeps a vendor attribution, including a consolidation of many
documents.

| Content | Basis | Published as | The page carries |
| --- | --- | --- | --- |
| Behavior established by observation, and any fact the vendor has not published officially and publicly | observation or deduction | CC0-1.0 | a Documents consulted section that reads `none` when no document was consulted |
| A consolidation of several documents into a structure of Helianthus's own, such as a cross-document matrix | official vendor documents | CC0-1.0 for the structure; vendor attribution for the information derived from the documents | the copyright note and a Documents consulted section listing every consulted document version |
| What Helianthus reads and uses from a document, and notes derived from it | one or more official vendor documents | CC0-1.0 for the page's own expression; vendor attribution for the information derived from the documents | the copyright note and a Documents consulted section listing every consulted document version |
| The vendor document itself: its register map, tables, labels, screenshots, firmware, and prose | not applicable | not published in this repository | no copy; identity only, in the Documents consulted section |

A document is a source for what to read and how to interpret it. A fact that
only a document states is documentary and is never graded Proven. A document
does not make a claim qualified, admitted, or supported: those states keep their
own requirements, which are identity tuples, observation fixtures, and
executable negative overlap, and admission stays fail-closed. This policy
changes where a page may take facts from. It changes no admission, disposition,
qualification, or support state.

Pages written before this policy that describe a vendor document as
inspection-only are read under this policy. Each such statement is revised on
its page when that page next rests on a document. Until then those pages keep
their wording, and this section decides what it means.

## Page conventions for consulted documents

A page that describes a vendor device or family carries both conventions below:
in full form when it consulted a document, in empty form when it did not.
Existing pages adopt them when they are next revised. The SmartLogger and
S-Dongle observation pages and the SUN2000 identity page adopt them in their
empty form with this change.

### Documents consulted section

The section has the heading `## Documents consulted`. It follows the contract
and evidence sections and comes before `## Open questions`, or last when the
page has no such section. It holds a table, then the copyright note.

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| the title, as the document states it | the version or revision label, as the document states it | the date, as the document states it | the rows, sections, or derived notes of the page that rely on the document |

- One row per document version. A page that consulted several versions of one
  document lists each version as its own row. A version is an exact value: each
  row cites one version, and the row order carries no priority. That exactness
  identifies the document. It does not bound the device software that the
  document's facts apply to, which the citation identity and software floors
  section below states.
- A row gives identity only: title, version, and date. It carries no excerpt,
  register table, description, link, line anchor, or digest, and no page number
  or other locator beyond what the independent reference works section below
  allows. A reader finds the document from its title and version at the vendor.
- The date is written as the document states it, as a year-month-day date, or
  as a year and month, or as a year, whichever the document gives. A document
  that states no date has the cell `not stated`. A document that states no
  version cannot be consulted under this policy.
- The Used for cell names what the page takes from the document: the rows or
  derived notes that rely on it, and any discovered version gate. It states the
  use in the page's own words.
- Empty form, when no document was consulted: the heading, the table with one
  row whose four cells read `none`, and one sentence stating the basis, such as
  observations only.

### Copyright note

The copyright note is a paragraph at the end of the Documents consulted section
that begins with the bold label `Copyright note.` Full form, with NAME replaced
by the vendor as the listed documents state it, and one note naming each vendor
whose document is listed:

> **Copyright note.** The information on this page that is derived from the
> documents listed above is attributed to NAME, which retains the copyright in
> those documents. This page states that information in its own words and does
> not reproduce the documents. The CC0-1.0 dedication of this page covers its
> own expression only and does not relicense those documents.

Empty form, when the section lists no document:

> **Copyright note.** Not applicable. No information on this page is derived
> from a vendor document.

### Registry pin of a consulted document

The registry pins a consulted document as document identity: the document title,
the document version, and the document date, each as the document states it and
each equal to the row on the page. The pin carries no excerpt, register table,
description, link, locator, or digest, and it grants no copy of the document.
It names which document a registry record rests on and nothing else.

A pin is one exact document version, with the same citation rule as the page
rows: it identifies the source and bounds no software applicability. A record
that rests on a document whose pin lacks the title, the version, or the date, or
whose pin differs from the page row in any of the three, has no consulted
document and cannot be admitted on that basis. A pin does not prove that the
document is current or that any device follows it. Observation fixtures,
identity tuples, and negative overlap remain required.

## Citation identity and software floors

Exact identity and applicability are separate. The title, issue or version, and
date of a consulted document are the citation key of its Documents consulted row
and of its registry pin, and the software string that a device returned is the
observation record. Both stay exact, and neither bounds the software that a fact
applies to.

For the Huawei and Fronius rows of the table below, applicability is a floor per
model row. A fact documented for a row applies from that row's documented
minimum software onward and to the builds that follow it, and a fact observed on
a device applies from the observed build onward. A build above the floor that no
observation has seen inherits the row's facts, graded Hypothesis until an
observation grades them, and only a recorded observation narrows a fact. No page
refuses such a build for being unseen. Model values stay exact. The
[software applicability section of the Huawei monitoring contract](huawei/monitoring-readonly-v1.md#software-applicability)
states the rule in full, including the comparison within a branch, and the
other Huawei pages refer to it. The rows of other vendors keep their stated
tuples until their own revision.

## Independent reference works

An independent reference work is a documentary work, written by others, that
consolidates vendor documents, cites each fact to the vendor document it rests
on, and dedicates its own original writing under CC0-1.0. It is neither official
vendor documentation nor a vendor document. The repository owner admits it as a
consulted source class with helianthus-docs-modbus issue 256, on the terms
below. Two works are admitted: the Huawei PV inverter Modbus reference,
reference baseline 2026-10-26.1, which covers Huawei SUN2000 inverter interface
definitions (the inverter reference), and the Huawei gateway Modbus reference,
reference baseline 2026-10-26.1, which covers the SmartLogger, S-Dongle, and
EMMA interface definitions and their supporting documents (the gateway
reference). The baseline tag is the citation key of a reference work, as the
issue and date are for a vendor edition, so a citation is reproducible without a
digest.

- **Identity.** A page that took facts through a reference work lists it in its
  Documents consulted section as one row: title `Huawei PV inverter Modbus
  reference`, version `reference baseline 2026-10-26.1`, and date `2026-10-26`;
  or title `Huawei gateway Modbus reference`, version `reference baseline
  2026-10-26.1`, and date `2026-10-26`. Each vendor document that a reference
  work cites for an imported fact has its own row, with the title, issue, and
  date that the document states, under the official vendor documentation policy
  above.
- **Rights.** The original writing of each reference work is dedicated under
  CC0-1.0 by its contributors. The vendor documents it cites keep their rights,
  and the copyright note covers the information derived from them. The page adds
  the reference note below for each reference work it lists.
- **Cleanup on import.** Helianthus takes each fact together with the vendor
  document it rests on, restates it in its own words, and grades it as
  documentary: Hypothesis until an observation grades it, and never Proven on a
  document alone. It drops the engineer-review and operational-authorization
  logic of a reference work, because the work is a source and not a product:
  Helianthus's own admission rules, write denial, and operator approval at
  action time stay in force. It also drops the work's links to material outside
  itself, issue-tracker links among them, its source digests, its archive paths,
  and the dates of the historical reports it records, and it reads the work's
  firmware applicability statements under the citation identity and software
  floors section above: a documented row or edition minimum is a floor, an
  edition's cover label and a release package that carries a document are not,
  and a statement that an edition covers exact firmware bounds what the work
  reviewed, not what the facts apply to. A statement of a work that keeps a fact
  within one named branch, keeps a range from another edition, or withholds a
  section from an edition that omits it is read the same way: a fact documented
  from a build applies to the builds that follow it, and the silence of a
  following document is no recorded change.
- **What is not imported.** A reference work's record of operator reports and
  historical observations is not a source of facts, because the observation
  pages of this repository are the record of what operator-owned installations
  returned. Its restatement of the Helianthus floor policy is not a source for
  that policy either, which this page and the monitoring contract state. A
  client policy that a work writes as its own, such as a cap on the length of a
  read, is not a vendor statement: a page that adopts one says that it does and
  cites the work.
- **Quarantined conflicts.** A conflict that a reference work quarantines, such
  as two widths printed for one offset or two incompatible layouts for one
  block, stays quarantined on every page that touches it. The page carries both
  texts with their grades, reads and decodes neither, and lets no edition, issue
  number, or date select a winner.
- **Locators.** A row for a document consulted through a reference work names, in its Used for cell, the physical page of the document on which each relied-on fact stands, counted from the cover, as its only locator beyond the title, issue, and date.
  No digest of a consulted document appears in public text. Where a reference
  work binds a fact to a digest of the vendor document, a private sidecar
  outside this repository keeps that digest, and no public row depends on it.
- **Mirror-recovered editions.** The owner decision recorded on helianthus-docs-modbus issue 242 treats a Huawei-authored interface definition whose copy was recovered from a third-party mirror as official vendor documentation, cited by title, issue, date, and page, with the mirror origin kept as a private provenance note, so the SUN2000MB V200R023C10 Modbus Interface Definitions, Issue 02, 2024-02-01, which the inverter reference recovered that way, is admissible as a consulted document.

The reference note is a paragraph after the copyright note of a page that lists
a reference work, one note per work, beginning with the bold label
`Reference note.`, with NAME replaced by the title of the work:

> **Reference note.** The facts that the Documents consulted section attributes
> to the NAME were taken through that independent documentary work, whose
> contributors dedicate its original writing under CC0-1.0. The vendor documents
> it cites keep their rights, as the copyright note states. This page restates
> those facts in its own words and carries over none of the reference's
> engineer-review or operational-authorization clauses.

## Applicability classes

| Profile | Applicability | Evidence class | Initial disposition |
| --- | --- | --- | --- |
| `sunspec.core.readonly.v1` | SunSpec model chains using the explicitly listed model identifiers and lengths | public interoperability standard facts | specified; downstream qualification required |
| `sunspec.der.readonly.v2` | Common 1/66 plus Models 701/153, 702/50, 703/17, 713/7, 714 variable geometry, 715/7, 802/62, 803 variable geometry, and 804 variable geometry at the exact pinned V2 schema revision | public Apache-2.0 model catalogue and independently stated interoperability facts | offline decoder contract; runtime, vendor, and catalog admission default denied |
| `fronius.sunspec.float.v1` | manufacturer `Fronius` and model `Symo GEN24 10.0`, each exact, with the chain compared exactly: flavor 1.1.0 from firmware `1.41.11-1`, flavor 1.2.0 from `1.42.9-1`, each until a changed chain is recorded; the V1.1 chain is on the [flavor page](fronius/sunspec-float-v1.md), and that page, the [Fronius qualification card](fronius/qualification-readiness-v1.md), and the registry keep their exact-tuple comparison of the firmware until a registry follow-up replaces it with these floors | vendor-copyright-inspection-only plus sanitized interoperability facts | specified flavor; downstream qualification required |
| `huawei.smartlogger.readonly.v1` | SmartLogger at gateway unit 0, with an exact model and a software floor: model `SmartLogger` from `V300R001C00`, the minimum of the V300 line that every consulted SmartLogger edition with a V300 entry states, the editions with cover labels `V300R024C10SPC191` and `V300R024C10SPC210` among them, and model `Smart Logger` from the observed firmware `V300R023C10SPC620`, whose branch precedes V300R024C10 along the documented upgrade path and lies above that minimum; a build that follows a floor, or one of a branch with no documented relation to it, inherits with grade Hypothesis | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | identity contract for the observed tuple; the documentary entries remain an offline candidate with no observation; default denied |
| `huawei.sdongle.readonly.v1` | SDongleA-05, SDongleB-03, or SDongleB-06 from `V200R022C10`, the minimum that the consulted editions state for those models, whose cover labels `V200R025C00SPC120` and `V200R022CC10` identify the editions and are not floors, with protocol main revision 5 from D5.0 onward, plus, as a separate entry, one observed single-inverter path: gateway unit 100 and child unit 1, with no gateway model variant and no gateway software, so no floor relates it to the candidate | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | offline candidate, default denied; the candidate's own tuple has no connected observation, so its identity is Unknown; the observed tuple has an identity contract and nothing more, and the recorded persistent non-response is superseded for that identity only by a same-class run that matches the whole tuple on one connection generation |
| `huawei.emma.readonly.v1` | SmartHEMS, a model admitted by family through the catalogue rows of the family `EMMA`, which the consulted editions name without a model list, with `EMMA-A01` and `EMMA-A02` as the observed models and a model of the family beyond them graded Hypothesis until observed, from `SmartHEMS V100R024C00SPC100` onward in the R024C00 branch and from SPC102 onward in the R025C00 branch, the minima that the two editions state, a build that follows a floor, or one of a branch with neither a documented floor nor a documented relation, inheriting with grade Hypothesis, plus, as the observation of that candidate, one observed gateway at unit 0 whose model value, software branch, and suffix are withheld, with SUN2000-family inverters at their own routed units | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | offline candidate, default denied; the candidate's FC03 tuple is observed on one installation, so identity is Proven for it and Unknown elsewhere, and the earlier non-response is superseded for that identity only; capability, battery addressing, and the other observed model, any further model of the family, and the other branch are Unknown; the qualification card stays evidence blocked |
| `huawei.sun2000.readonly.v1` / `huawei.luna2000.readonly.v1` | no covered model family or firmware range; SUN2000 inverter and optional LUNA2000 battery | vendor-copyright-inspection-only | `NO_ADMISSIBLE_PROFILE`; default denied, no register map, no decoder |
| `huawei.sun2000.identity.observed.v1` | SUN2000 behind a SmartLogger-family gateway: model `SUN2000-50KTL-M3`, exact, with the firmware text `V200R023` read at one routed unit as the floor, so another firmware text inherits with grade Hypothesis; the LUNA2000 optional group has no observed tuple and stays Unknown | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | identity applicability only; profile selection stays `NO_ADMISSIBLE_PROFILE` because no register map is pinned; default denied |
| `huawei.gateway.power-meter.v1` | power meters listed as children of a Huawei gateway; make, model, and firmware are Unknown, the exposure of the meter groups is observed to answer on three paths (value form Hypothesis), and the electrical role is configuration | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | listing, class, and observed exposure facts only; every meter is `INSUFFICIENT_EVIDENCE`; no admitted meter tuple; default denied |
| Huawei SUN2000 inverter catalogue dataset (a dataset, not a profile), described on the [catalogue page](huawei/sun2000-inverter-catalogue-v1.md) | reference baseline 2026-10-26.1: 16 profile cards and 2,401 model rows, each an exact token and model identifier with a software floor and no maximum, so a build at or above a floor that no observation has seen inherits with grade Hypothesis; read-only rows of the classes reviewed, conditional, raw-only, and conflict, where raw-only and conflict never decode; control rows as readable configuration or no-send; dictionaries bound to an edition and a mode; quarantined contradictions carried, never resolved by the generator | independent reference work, original writing CC0-1.0, consulted over official vendor documents, with the reference baseline tag as its citation key and vendor attribution for the information derived from the documents; the mirror-recovered SUN2000MB edition is admitted under the decision recorded on helianthus-docs-modbus issue 242 | inert: no selection, decoding, or provider reads it until the registry follow-ups land (the selection by token or wire alias, identifier, and floor, helianthus-modbusreg issue 362, and the monitoring profiles built on the catalogue, to be filed after the qualification captures); nothing registered, admitted, qualified, or supported; default denied; once consumed, Proven only against an observation, Hypothesis from the document |
| `growatt.protocol2.tl3x.readonly.v1` | Growatt Protocol II v1.24 TL3-X class covering MAX, MID, and MAC register ranges | vendor-copyright-inspection-only | offline candidate, default denied |
| `growatt.shinewilan-x2.bridge.v1` | ShineWiLan-X2 transparent Modbus TCP to downstream Modbus RTU bridge boundary | vendor-copyright-inspection-only | transport contract only; no semantic profile or downstream admission |
| `growatt.bms.rs485.1xsxxp.v2_02.readonly.v1` | exact 1xSxxP ESS tuple: Rev2.01 file family, V2.0 header, cumulative changes through 2.02 | vendor-copyright-inspection-only | protocol specified; registry NO_GO pending an exact permitted clean-room fixture |
| `growatt.wit.family-protocol-matrix.v1` | exact WIT commercial family rows plus the isolated WIT 100KTL3-H / DTC 5601 VPP V2.01 tuple | vendor-copyright-inspection-only | qualification matrix only; all operations NO_SEND and registry NO_GO |
| `outback.axs.sunspec.readonly.v1` | OutBack AXS public sources conflict: owner manual Rev C gives 64110/282 and 64111/23; application note Rev 5 gives 64110/420 and 64111/26 | vendor-copyright-inspection-only | `NO_GO`; no product/firmware-qualified read operation or provider admission until a source-pinned compatibility and operation contract exists |

No disposition in this table proves a particular installation, firmware image,
endpoint, or live support state. `Offline candidate` is not registered for
automatic detection or acquisition. The SUN2000 and LUNA2000 disposition row
states that the disposition covers no model row yet. It sets no software limit,
and its wording moves with the registry's document-identity pins under the owner
decision recorded on helianthus-docs-modbus issue 242.

The label `vendor-copyright-inspection-only` in the evidence class column is a
copyright-status label: the vendor keeps the copyright in the material and the
material is not copied. The label name predates the policy in the previous
sections and is kept so that existing rows and checks stay stable. It does not
forbid consulting or citing an official vendor document, and a row does not
change because of it. Renaming the label is a decision for the repository
owner.

Rows with sanitized interoperability facts from observation state what one
operator-owned installation returned to bounded read-only requests that the
public gateway contract already defines. Each tuple in them is the exact record
of what was observed. Its model values are compared exactly, with no prefix,
wildcard, alias, or ordering. Its software values are floors under the citation
identity and software floors section above: a build that follows the observed
one inherits the tuple's facts with grade Hypothesis until an observation
records a change. A tuple observed on one installation is not a family-wide
claim. Their evidence is graded Proven, Hypothesis, or Unknown on the linked
pages, and that grade is separate from the disposition column, from
qualification, and from support. These rows rest on observations only: no vendor
text, table, label, or screenshot is copied, no offset or string in them is
taken from the vendor interface definition. A monitoring page that rests on that
definition lists it in its Documents consulted section under the page
conventions above.
The linked pages are the
[SmartLogger observation](huawei/smartlogger-observed-inventory-v1.md), the
[S-Dongle observation](huawei/sdongle-observed-identity-v1.md), the
[EMMA observation](huawei/emma-observed-identity-v1.md), the
[SUN2000 identity contract](huawei/sun2000-observed-identity-v1.md), and the
[power-meter contract](huawei/gateway-power-meter-v1.md).

The SunSpec V2 offline contract is pinned to the public Apache-2.0 SunSpec model
catalogue at commit
`90b4a331dcca1d6eac69c1bead952fddcc5852e0`. That upstream license applies to
the catalogue input. The independently stated protocol contract in this
repository remains CC0-1.0 and does not reproduce upstream descriptions,
tables, labels, or generated model files.

## Admission rules

Downstream profile admission requires an exact endpoint and unit observation,
an exact family and model with the software condition of its row, a complete
read-only fixture, and executable negative-overlap tests against every other
candidate. For a Huawei or Fronius row that condition is a floor. A missing
discriminator, a software build that its row does not cover (for a Huawei or
Fronius row, a build below the floor within the floor's branch), a conflicting
detector, a malformed field, a partial inventory, or an unlicensed required fact
produces `insufficient_evidence` and no send. For a Huawei or Fronius row, a
build that no observation has seen is not an unknown version: at or above the
floor, or of a branch with no documented relation to it, it inherits the known
behavior with grade Hypothesis under the citation identity and software floors
section above.

Function-code readability, a vendor string, a writable name, a serial number,
registration material, or registration order is never sufficient. Profiles do
not inherit or fall back between vendor families.

## Architecture separation

These pages define wire and applicability contracts only. They do not define a
gateway scheduler, registry implementation, public API, canonical energy
semantics, deployment configuration, or consumer binding.
