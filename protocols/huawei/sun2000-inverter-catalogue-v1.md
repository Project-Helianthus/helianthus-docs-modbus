# Huawei SUN2000 Inverter Catalogue Dataset V1

## Scope and status

This page describes the Huawei SUN2000 inverter catalogue: a consulted-source
dataset that the registry holds as generated data (helianthus-modbusreg issue
359, pull request 360). It states what the dataset is and is not, how Helianthus
cites it, which decisions govern it, that it is inert until a registry change
consumes it, and how an entry is graded once it is consumed. It restates no
register offset, scale, unit, model row, floor, or dictionary entry and
reproduces no table of the dataset: the dataset is the place for them. The
historical V1 name implies no stability before Helianthus 1.0.

This page creates no admission and changes no disposition. Profile selection
for the SUN2000 and LUNA2000 classes stays `NO_ADMISSIBLE_PROFILE` under the
[inverter and battery disposition](inverter-battery-readonly-v1.md), the groups,
value forms, and grades of the
[monitoring contract](monitoring-readonly-v1.md) are unchanged, and
`catalog_registered=false`, `automatic_runtime_admission=false`,
`live_qualified=false`, `support_claim=false`, and `write_authority=false` are
unchanged.

The grades are those of the monitoring contract: Proven needs a live reading
that agreed with an independent check, Hypothesis is a fact that a document
states or an inference, and Unknown means that neither settles it. A fact that
only a document states is documentary and is never graded Proven. Grades are
separate from admission, qualification, and support.

## What the catalogue is

The catalogue is a consulted-source dataset. It records what a consulted
documentary work states about the Huawei SUN2000 inverter interface
definitions: which models a vendor edition lists and the minimum software it
documents for each, which register rows an edition defines and how far each row
may be trusted to decode, and the dictionaries and contradictions that come
with them. It is not an observation record, a profile, a detector, a
qualification, or a support claim, and its breadth says nothing about what an
installation answers.

It is generated, not written by hand. A deterministic registry tool reads the
Huawei PV inverter Modbus reference at reference baseline 2026-10-26.1, an
independent documentary work whose original writing is dedicated under CC0-1.0,
and writes the dataset as JSON. A byte-for-byte round-trip test checks the
committed files. The tool checks each card and each edition against the
accounting of the reference and refuses any count other than the baseline
counts below unless a reviewed change states the new ones.

| Part | What it holds | Count at the baseline |
| --- | --- | --- |
| Profile cards | the register rows of one source edition each, with its gates, core keys, and value-aligned read extents | 16 |
| Source editions | the vendor interface definitions behind the model tables, each named by title, issue, and date | 49 |
| Model rows | an exact source token, a model identifier, and a software floor | 2,401 |
| Read-only rows | register rows of the cards, each with a class | 3,115: 372 reviewed, 2,127 conditional, 596 raw-only, 20 conflict |
| Control rows | register rows that the document lists as writable or restricted, carried as readable configuration or no-send | 2,135: 1,910 readable configuration, 225 no-send |
| Core rows | read-only rows that a card marks with its core key and the gate of that key | 429 |
| Dictionaries | enumerations, bitmaps, sign conventions, sentinels, storage selectors, and alarm bits, each bound to an edition and a mode | not counted here |
| Quarantines | contradictions and anomalies, carried as flags on the rows they affect | not counted here |

A different reference baseline gives different counts, and a citation of the
dataset names the baseline it rests on.

## Model rows and software floors

- **Token.** The source token is kept exactly, punctuation included, and is
  compared whole. Tokens repeat across editions with different identifiers, so
  a token does not identify a model without its identifier, and no punctuation
  is normalized globally.
- **Identifier.** The model identifier is the one that the edition's table
  labels. A table ordinal that the edition does not label as an identifier is
  kept apart as a sequence number, the row has no identifier, and the row is
  flagged.
- **Floor.** The floor of a row is the minimum software that the edition
  documents for the row. When the row states none, the floor is the
  document-wide requirement that covers the row, and the row says so: at the
  baseline, 2,282 rows take a row minimum and 119 take a document-wide
  requirement. No row states a maximum or a range. The comparison of a build
  with a floor, within a branch and across branches, and the grade of a build
  that no observation has seen are the
  [software applicability rule](monitoring-readonly-v1.md#software-applicability).
  The cover label of an edition and the release package that carries it are not
  floors.
- **Wire alias.** Where a device reports a model token differently from the
  source, the catalogue records the reported form as an alias of one model row,
  with its evidence and its scope. The alias holds only within that scope: the
  exact model identifier, the source edition, and the endpoint scope that it
  records. At the baseline each alias rests on an operator report whose raw
  capture is not part of the catalogue, so none of them is Proven on that
  evidence.
- **Flags.** A model row can carry a flag, for a sequence ordinal and for a row
  minimum that the document writes as a merged cell or in a form outside the
  branch form.

## Register rows and classes

The class of a read-only row states what a consumer may do with the row at most.
It never grants decoding by itself.

| Class | Decode definition in the dataset | Rule |
| --- | --- | --- |
| `reviewed` | yes: the literal gain and unit cells | decodes only inside a consuming profile that admits it |
| `conditional` | yes: the literal gain and unit cells | decodes only inside a consuming profile that admits it and only where the named gates and row conditions of the row hold |
| `raw-only` | none; the literal cells are kept as evidence | never decodes; a read, where a profile admits one, is native evidence |
| `conflict` | none; the literal cells are kept as evidence | never decodes; the reference records a conflict on the row |

A control row carries its literal cells only and no decode definition, whatever
its access mode.

- A `readable-configuration` row is one that the document lists as read-write,
  with a documented FC03 read and a documented status. It may be read as raw
  evidence only by a profile that admits that read.
- A `no-send` row is write-only, restricted, conflicting, or without a
  documented read. It is never requested.
- The catalogue grants no write. The write denial and the operator approval at
  action time stay in force for every row.

Other rules of the rows:

- A row whose source gives no address carries an unspecified-address status and
  no offset, and is never requested.
- A row of the EMMA endpoint class never enters a read map of an inverter.
- A read extent is a run of documented words that ends on a value boundary,
  with the hole that follows it in the source. An extent is no snapshot or
  response guarantee, and the row contract of every word in it still applies.
  The shared extent rule of the monitoring contract stays in force.

## Dictionaries and quarantines

A dictionary is bound to the edition and the mode of the card that carries it,
and it is never moved to another edition, another mode, or another family. A
consumer does not guess the meaning of a code that a dictionary does not list.

A quarantine records a contradiction of the reference, an anomaly of a source
edition, or a finding of the generator. The generator flags the rows that a
quarantine affects and never resolves it, never corrects an index silently, and
keeps the literal and the contradicting statement apart. Only a recorded
decision or an observation resolves a quarantine, and a flagged aspect of a row
stays Unknown until then.

## Citation form

A public row that cites a document consulted through a reference work carries
the title, the issue or baseline, the date, and the physical page, as the owner
decisions of 2026-10-26 on helianthus-docs-modbus issue 256 provide and the
[independent reference works section](../applicability-and-licensing.md#independent-reference-works)
of the licensing page records. No digest appears in public text.

| What is cited | Form | Never carried |
| --- | --- | --- |
| The reference work | its title, its reference baseline tag, and its date, in one Documents consulted row; the baseline tag is the citation key | a digest, a link, an archive path |
| A vendor document consulted through it | its title, issue, and date as the document states them, and, in the Used for cell, the physical page of the document on which each relied-on fact stands, counted from the cover | a digest, a link, a line anchor, any other locator |
| A document in the registry | the document identity pin: title, version, and date, each equal to the page row | an excerpt, a locator, a digest |

- The catalogue data names every edition by title, issue, and date and every
  row by its physical page, and carries nothing else that locates the document.
  Two source copies that share a title, an issue, and a date are one citation:
  the catalogue marks them as copies, and only the private sidecar tells them
  apart.
- Where the reference binds a fact to a digest of a vendor document, a private
  sidecar outside the public repositories keeps the digest, and no public row,
  pin, or dataset file depends on it.
- A citation of the dataset never uses a commit identifier, a pinned file link,
  or a line anchor. The baseline tag identifies the source.

## Governing decisions

| Decision | Recorded on | Effect on the catalogue |
| --- | --- | --- |
| The whole inverter catalogue enters as data, every documented model row and software release expressed as floors, and qualification stays on the owned families | the operator decision of 2026-10-25 on helianthus-modbusreg issue 359 | the dataset covers the documented models of the reference, and its breadth is no qualification |
| Software knowledge is a floor per model row | helianthus-docs-modbus issue 256, in the [citation identity and software floors section](../applicability-and-licensing.md#citation-identity-and-software-floors) of the licensing page | every model row carries a floor and no maximum; an unseen build at or above a floor inherits with grade Hypothesis; only a recorded observation narrows |
| An independent reference work is a consulted source class | helianthus-docs-modbus issue 256, in the [independent reference works section](../applicability-and-licensing.md#independent-reference-works) of the licensing page | the dataset is cited through the reference work by its baseline tag; the vendor documents it cites keep their rights |
| Public rows cite the physical page, and digests stay out of public text | the owner decision of 2026-10-26 on helianthus-docs-modbus issue 256 | each row carries its page; digests live in a private sidecar |
| A Huawei-authored interface definition recovered from a third-party mirror is official vendor documentation | the decision recorded on helianthus-docs-modbus issue 242, applied by the owner decision of 2026-10-26 on issue 256 | the SUN2000MB V200R023C10 Modbus Interface Definitions, Issue 02, dated 2024-02-01, enters like any other edition and is cited by title, issue, date, and page; the catalogue marks its source class as mirrored, and the mirror origin stays a private provenance note |
| Official vendor documentation may be consulted and cited, never copied | the [applicability and licensing page](../applicability-and-licensing.md) | the dataset copies no vendor text, table, label, or link, and vendor attribution stays with the information derived from the documents |
| A row grants no decoding beyond its class | helianthus-modbusreg issue 359 | `raw-only` and `conflict` rows never decode, and control rows carry no decode definition |

## Inert until consumed

1. **Nothing reads the dataset.** No selection path, decoding path, detection,
   read plan, or provider reads it. It registers no profile, selects nothing,
   admits nothing, and grants no write. The two hand-written SUN2000 monitoring
   profiles and every disposition are unchanged by it, and no fact of the
   monitoring contract moves because the dataset exists.
2. **Consumers are registry follow-ups.** A registry change reads the dataset
   only through one of two follow-ups, both to be filed: the selection change,
   which would choose a model row from a routed model token or its recorded
   wire alias, a model identifier, and a software floor, and the monitoring
   profiles built on the catalogue. The public page text that those changes
   need follows with them, and this page then names their issue numbers.
3. **A consumer makes only what it reads live.** A follow-up that consumes part
   of the dataset leaves the rest inert. Every default-denied state stays
   until that follow-up meets its own admission, observation, and
   negative-overlap requirements.
4. **The gateway catalogue is a sibling, not a consumer.** helianthus-modbusreg
   issue 361 extends the same generator to the SmartLogger, S-Dongle, and EMMA
   editions. It is data only too and creates no consumer.
5. **Presence is not support.** A model row in the dataset is not detection,
   admission, or a support claim for that model.

## Grading once consumed

An entry of the dataset is documentary. The grade it carries is the grade of
the way the fact became known.

| Entry or situation | Grade |
| --- | --- |
| A fact that only the dataset states, such as a row definition or a floor | Hypothesis, never Proven on the document alone |
| The same fact, after a live reading decoded with the stated value form agreed with an independent check, as the monitoring contract defines Proven | Proven, for the observed units only |
| A build at or above a floor that no observation has seen | Hypothesis, inherited from the row |
| A wire alias | Hypothesis until an observation fixture records the reported form |
| A `raw-only` or `conflict` row, a quarantined aspect, or a code that a dictionary does not list | Unknown as a fact; a read, where a profile admits one, is native evidence |

The qualification bench is the three families of operator-owned installations
that the monitoring contract already records: the M3 series behind a
SmartLogger, the MAP0 series behind an EMMA, and the M1 series behind an
S-Dongle. A consuming profile can gain Proven grades only for these families,
through observation fixtures that meet the monitoring contract, exact identity,
and negative overlap. Every other family, model, and edition in the dataset
stays Hypothesis and unqualified.

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| Huawei PV inverter Modbus reference | reference baseline 2026-10-26.1 | 2026-10-26 | the description of the dataset: its parts and counts at the baseline, the model-floor structure, the row classes, the dictionaries, and the quarantines; no register, model, floor, or dictionary entry is restated |
| SUN2000MB V200R023C10 Modbus Interface Definitions | Issue 02 | 2024-02-01 | naming the edition recovered from third-party mirrors, whose card and model rows are in the dataset; the page restates no fact stated in it and cites no page |

The vendor editions behind the other cards and model tables are named, with
title, issue, and date, in the dataset itself. This page restates no fact of any
of them. A page that relies on a fact of an edition lists that edition in its
own Documents consulted section with the physical page of the fact. No value,
table, label, or text of the documents is reproduced here.

**Copyright note.** The information on this page that is derived from the
documents listed above is attributed to Huawei Technologies Co., Ltd., which
retains the copyright in those documents. This page states that information in
its own words and does not reproduce the documents. The CC0-1.0 dedication of
this page covers its own expression only and does not relicense those
documents.

**Reference note.** The facts that the Documents consulted section attributes
to the Huawei PV inverter Modbus reference were taken through that independent
documentary work, whose contributors dedicate its original writing under
CC0-1.0. The vendor documents it cites keep their rights, as the copyright note
states. This page restates those facts in its own words and carries over none
of the reference's engineer-review or operational-authorization clauses.

## Open questions

1. Which issue numbers do the selection change and the monitoring profiles
   built on the catalogue take? Both follow-ups are to be filed, and this page
   names them when they exist.
2. Does a recorded wire form of a model token hold at other builds and behind
   other gateways than the ones where it was reported? The alias scope bounds
   the claim, and nothing wider is known.
3. Which quarantines does an observation of the owned families resolve, and
   which stay open? None is resolved by the dataset.
