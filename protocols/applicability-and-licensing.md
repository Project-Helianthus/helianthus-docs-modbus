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
unless the repository owner decides otherwise. The policy applies to every
vendor family in this repository.

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
own requirements, which are exact tuples, observation fixtures, and executable
negative overlap, and admission stays fail-closed. This policy changes where a
page may take facts from. It changes no admission, disposition, qualification,
or support state.

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
  document lists each version as its own row. A version is an exact value: no
  range, prefix, ordering, or inheritance links two rows, and the row order
  carries no priority.
- A row gives identity only: title, version, and date. It carries no excerpt,
  register table, description, page number, locator, link, line anchor, or digest.
  A reader finds the document from its title and version at the vendor.
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

A pin is one exact document version, with the same exact-value rule as the page
rows. A record that rests on a document whose pin lacks the title, the version,
or the date, or whose pin differs from the page row in any of the three, has no
consulted document and cannot be admitted on that basis. A pin does not prove
that the document is current or that any device follows it. Observation
fixtures, exact tuples, and negative overlap remain required.

## Applicability classes

| Profile | Exact applicability | Evidence class | Initial disposition |
| --- | --- | --- | --- |
| `sunspec.core.readonly.v1` | SunSpec model chains using the explicitly listed model identifiers and lengths | public interoperability standard facts | specified; downstream qualification required |
| `sunspec.der.readonly.v2` | Common 1/66 plus Models 701/153, 702/50, 703/17, 713/7, 714 variable geometry, 715/7, 802/62, 803 variable geometry, and 804 variable geometry at the exact pinned V2 schema revision | public Apache-2.0 model catalogue and independently stated interoperability facts | offline decoder contract; runtime, vendor, and catalog admission default denied |
| `fronius.sunspec.float.v1` | manufacturer `Fronius`, model `Symo GEN24 10.0`, version `1.41.11-1`, and the exact V1.1 chain | vendor-copyright-inspection-only plus sanitized interoperability facts | specified flavor; downstream qualification required |
| `huawei.smartlogger.readonly.v1` | SmartLogger with three exact tuples and no range, prefix, or ordering between them: model `SmartLogger` with firmware `V300R024C10SPC191`, model `SmartLogger` with firmware `V300R024C10SPC210`, and model `Smart Logger` with firmware `V300R023C10SPC620` at gateway unit 0 | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | exact identity contract for the observed tuple; the two other tuples remain offline candidates with no observation; default denied |
| `huawei.sdongle.readonly.v1` | SDongleA-05, SDongleB-03, or SDongleB-06 with exact firmware `V200R025C00SPC120` and protocol D5.0, plus, as a separate exact tuple with no range, prefix, or ordering between the two, one observed single-inverter path: gateway unit 100 and child unit 1, with no gateway model variant | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | offline candidate, default denied; the candidate's own tuple has no connected observation, so its identity is Unknown; the observed tuple has an exact identity contract and nothing more, and the recorded persistent non-response is superseded for that identity only by a same-class run that matches the whole tuple on one connection generation |
| `huawei.emma.readonly.v1` | SmartHEMS `EMMA-A01` or `EMMA-A02`, with R024C00 SPC100+ or R025C00 SPC102+ in the same branch | vendor-copyright-inspection-only | offline candidate, default denied; no connected observation, so identity is Unknown |
| `huawei.sun2000.readonly.v1` / `huawei.luna2000.readonly.v1` | no covered model family or firmware range; SUN2000 inverter and optional LUNA2000 battery | vendor-copyright-inspection-only | `NO_ADMISSIBLE_PROFILE`; default denied, no register map, no decoder |
| `huawei.sun2000.identity.observed.v1` | SUN2000 behind a SmartLogger-family gateway: model `SUN2000-50KTL-M3` with firmware `V200R023` read at one routed unit, with no range, prefix, or ordering; the LUNA2000 optional group has no observed tuple and stays Unknown | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | exact identity applicability only; profile selection stays `NO_ADMISSIBLE_PROFILE` because no register map is pinned; default denied |
| `huawei.gateway.power-meter.v1` | power meters listed as children of a Huawei gateway; make, model, firmware, and exposure path are Unknown, and the electrical role is configuration | vendor-copyright-inspection-only plus sanitized interoperability facts from observation | listing and class facts only; every meter is `INSUFFICIENT_EVIDENCE`; no admitted meter tuple; default denied |
| `growatt.protocol2.tl3x.readonly.v1` | Growatt Protocol II v1.24 TL3-X class covering MAX, MID, and MAC register ranges | vendor-copyright-inspection-only | offline candidate, default denied |
| `growatt.shinewilan-x2.bridge.v1` | ShineWiLan-X2 transparent Modbus TCP to downstream Modbus RTU bridge boundary | vendor-copyright-inspection-only | transport contract only; no semantic profile or downstream admission |
| `growatt.bms.rs485.1xsxxp.v2_02.readonly.v1` | exact 1xSxxP ESS tuple: Rev2.01 file family, V2.0 header, cumulative changes through 2.02 | vendor-copyright-inspection-only | protocol specified; registry NO_GO pending an exact permitted clean-room fixture |
| `growatt.wit.family-protocol-matrix.v1` | exact WIT commercial family rows plus the isolated WIT 100KTL3-H / DTC 5601 VPP V2.01 tuple | vendor-copyright-inspection-only | qualification matrix only; all operations NO_SEND and registry NO_GO |
| `outback.axs.sunspec.readonly.v1` | OutBack AXS public sources conflict: owner manual Rev C gives 64110/282 and 64111/23; application note Rev 5 gives 64110/420 and 64111/26 | vendor-copyright-inspection-only | `NO_GO`; no product/firmware-qualified read operation or provider admission until a source-pinned compatibility and operation contract exists |

No disposition in this table proves a particular installation, firmware image,
endpoint, or live support state. `Offline candidate` is not registered for
automatic detection or acquisition.

The label `vendor-copyright-inspection-only` in the evidence class column is a
copyright-status label: the vendor keeps the copyright in the material and the
material is not copied. The label name predates the policy in the previous
sections and is kept so that existing rows and checks stay stable. It does not
forbid consulting or citing an official vendor document, and a row does not
change because of it. Renaming the label is a decision for the repository
owner.

Rows with sanitized interoperability facts from observation state what one
operator-owned installation returned to bounded read-only requests that the
public gateway contract already defines. Each exact tuple in them is an exact
value: no range, prefix, wildcard, ordering, or inheritance links two tuples,
and a tuple observed on one installation is not a family-wide claim. Their
evidence is graded Proven, Hypothesis, or Unknown on the linked pages, and
that grade is separate from the disposition column, from qualification, and
from support. These rows rest on observations only: no vendor text, table,
label, or screenshot is copied, no offset or string in them is taken from the
vendor interface definition. A monitoring page that rests on that definition
lists it in its Documents consulted section under the page conventions above.
The linked pages are the
[SmartLogger observation](huawei/smartlogger-observed-inventory-v1.md), the
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
an exact family and version gate, a complete read-only fixture, and executable
negative-overlap tests against every other candidate. A missing discriminator,
unknown version, conflicting detector, malformed field, partial inventory, or
unlicensed required fact produces `insufficient_evidence` and no send.

Function-code readability, a vendor string, a writable name, a serial number,
registration material, or registration order is never sufficient. Profiles do
not inherit or fall back between vendor families.

## Architecture separation

These pages define wire and applicability contracts only. They do not define a
gateway scheduler, registry implementation, public API, canonical energy
semantics, deployment configuration, or consumer binding.
