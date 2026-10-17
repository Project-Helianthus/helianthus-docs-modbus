# OutBack observation retention across source conflicts

This Helianthus provider lifecycle proposal is released under AGPL-3.0-only.
It complements the native protocol contracts without changing their licensing
or admitting an OutBack AXS Port family profile. Nothing here is stable before
the Helianthus 1.0 release.

## Evidence and current behavior

The native documentation is authoritative before any application proposal:

- [Source/profile matrix](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/outback/axs-port-source-profile-matrix-v1.md):
  finite selector, conflicting layouts, operation matrix and replay provenance.
- [Native read-only boundary](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/outback/axs-port-sunspec-readonly-v1.md):
  immutable caller-supplied evidence, opaque words and no partial typed output.
- [Current decoder](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/outback_axs_sunspec.go):
  `Decode` returns an empty result and `ErrOutBackAXSSourceNotQualified`;
  raw evidence stays with the caller, unchanged.
- [Current selector](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/sunspec_outback_axs_flavor.go):
  `EvaluateSnapshot` returns `NO_GO`, `Matched()` is false, and chain/model
  accessors expose no selection. It creates no acquisition request.

**Proven within these sources:** the documented lengths conflict:
64110/282 versus 64110/420 and 64111/23 versus 64111/26. Complete geometry
does not establish applicability. Every current path schedules **zero requests**
and emits **zero typed facts**; writes and control remain `NO_SEND`.
This is source/code evidence, not device qualification or runtime test evidence.

**Hypothesis / proposed future work:** a provider can preserve detached raw
observations and atomically invalidate dependent views using the lifecycle
below. The current decoder does not implement a provider retention store,
transaction API or source-revision invalidation mechanism.

**Unknown:** a public compatibility source uniquely binding the family's exact
product/firmware inputs to one layout, and a separate qualified read operation.
No function code, table, absolute address, quantity, maximum response bytes,
timeout or retry bound is supplied by this proposal. Qualification and runtime
admission remain separate decisions; retaining evidence proves neither.

## Proposed record and interface boundary

The following are conceptual responsibilities, not new exported APIs or a new
namespace. They require implementation and independent validation later.

| Responsibility | Proposed retained information and constraint | Native basis |
| --- | --- | --- |
| Accept caller raw observation | Copy supplied bytes or words, preserving representation, order, occurrence boundaries, declared lengths, available spans and explicit missing spans. Detach all nested buffers and returned views; caller mutation cannot alter retained evidence. | Native read-only boundary: immutable raw retention and source spans. |
| Associate source revision | Freeze the source key, revision, public locator and content identity from the supplied immutable descriptor, plus selector inputs and the source-set revision used for evaluation. Missing metadata stays explicitly unavailable. | Matrix: complete immutable descriptor and replay provenance. |
| Preserve native provenance | Retain supplied request/response evidence and outcome, chain order, offsets and spans. Absent request coordinates or wire evidence remain absent; never synthesize a request from a block or copy another record's provenance. | Matrix: replay inventory; operation matrix is `NO_GO`. |
| Evaluate retained evidence | Return raw-retention disposition separately from selection (`NO_GO`), typed facts (none), and scheduled requests (zero). Completeness is structural metadata only. | Matrix selector and native failure boundary; current decoder and selector. |
| Replace source evidence | Publish a new immutable source-set revision and invalidate every dependent interpreted view atomically. Retain historical raw records with their original association. | Proposed transaction rule extending the native source-binding requirement. |

A source-set revision identifies the evaluated set of required descriptors and
their availability, not just a display name or payload digest. The association
includes source key, revision and content identity: changing any one requires
reevaluation. Same payload bytes never imply the same source or applicability.
Synthetic examples use symbolic revisions; no literal digest is needed.

`Opaque retained` means storage accepted a detached record; it is not a
successful decode, profile match or qualified operation. `Incomplete retained`
means only the supplied fragment is retained, explicitly incomplete. It is
proposed diagnostic retention, not a complete raw block or replay-qualified
candidate. A storage failure accepts no new record and leaves previous records
unchanged; it does not reopen selection or schedule a recovery read.

Storage capacity, eviction, durable persistence and caller-facing error shapes
remain future design gaps. This proposal supplies no retention duration or
promise of unlimited storage. A later retention policy must not silently change
historical attribution or promote fragments into complete observations.

## Proposed transactions and invalidation

Each acceptance freezes one raw record and its source association before
publishing a receipt. Each evaluation uses one immutable raw record and one
source-set revision. Its publication checks that the source-set revision is
still current. A concurrent replacement, withdrawal or loss of a required
source discards the in-flight interpreted result; it cannot publish against the
new revision. Raw retention can still succeed under its original association.
No transition in this section performs I/O.

| Event | Proposed atomic result | Raw history and selection |
| --- | --- | --- |
| New complete caller block | Publish detached opaque record and frozen association. | Preserve prior records; `NO_GO`, no typed facts. |
| Incomplete or malformed caller block | Publish diagnostic fragment with exact supplied extent and incompleteness, if storage accepts it. Never pad, join unrelated fragments or infer missing words. | Preserve prior complete raw evidence; `NO_GO`, no typed facts. |
| Source key, revision, content, declared layout or required availability changes | Advance source-set revision and invalidate dependent interpreted views together; reject stale evaluation publication. | Keep historical raw records attributable to their original revision; none supports a new selection. |
| Source withdrawn or unavailable | Mark association historical and current evaluation blocked; do not substitute an older or optional source. | Raw evidence survives as historical evidence; `NO_GO`, no typed facts. |
| Explicit later diagnostic comparison | Create a comparison referencing the original raw record and the new source set; never relabel or overwrite the original receipt. | Historical raw evidence cannot support a new selection; the comparison is diagnostic only. Current sources still yield `NO_GO`. |

Invalidation removes current eligibility, not the underlying native evidence.
Unrelated records are unchanged. A failed or partial submission never overwrites
the last complete retained raw record. There is currently no last-known-good
typed OutBack view: the selector has never admitted one. If a separately
qualified future implementation has such a view, source change must fence it
from current selection and emission; any historical copy must carry its original
association and invalidated status, never masquerade as current output.

## Synthetic acceptance cases

These are manual contract examples, not fixtures, executed tests or observed
devices. `A` is the owner-manual revision-C descriptor, `B` the application-note
revision-5 descriptor, and `R1`/`R2` are symbolic source-set revisions. Model
numbers below are native block identifiers, not device model claims. Each row
proposes retention behavior; its rejection boundary comes from the cited native
contracts and is consistent with the current unconditional decoder/selector.

**Every row currently schedules zero requests and emits zero typed facts.**
All selections are `NO_GO`; 64111 remains opaque in every case.

| Case and exact synthetic change | Proposed retention / transaction outcome | Selection boundary and source basis |
| --- | --- | --- |
| Source conflict: R1 contains A declaring 64110/282 and 64111/23, and B declaring 64110/420 and 64111/26; supplied block is complete 64110/282. | Retain detached bytes and both conflicting descriptors; mark source conflict, not a selected A layout. | Matrix finite selector: geometry cannot resolve conflicting applicability. |
| Same bytes, different source: submit identical complete 64110/282 words once associated with A/R1 and once with B/R2. | Keep distinct source associations even if storage shares immutable bytes. Invalidate an R1-dependent view before R2 publication; never relabel the A record as B evidence. | Matrix requires exact source binding; B's different length cannot be overridden by byte equality. |
| Source withdrawal: retain a complete block with A/R1, then withdraw A in R2. | Keep the R1 raw record and withdrawn association; invalidate dependent views in the R2 transaction. | Native source provenance is required; historical A cannot support a new selection. |
| Duplicate model: caller supplies two complete occurrences of 64110/282 in one chain. | Preserve both occurrences in supplied order, their offsets and spans; do not deduplicate or select the first. | Native chain selection and matrix reject duplicate/conflicting occurrence with no partial output. |
| Changed declared length: an R1 raw record declares 64110/282; a new submission declares 64110/420, or a replacement descriptor changes its declaration from 282 to 420. | Keep submissions distinct, preserving each declaration. Descriptor replacement advances revision and invalidates dependencies; never truncate, extend or reinterpret the old record in place. | Native wrong-length rejection and matrix source conflict; matching either length is insufficient. |
| Required source unavailable: R1 raw history exists; R2 cannot supply a required compatibility or operation descriptor. | Retain R1 history, record unavailable evidence at R2, fence dependent views; no fallback, fetch or probe. | Matrix selector requires all prerequisites and a separate operation; unavailable is not satisfied. |
| Incomplete raw input: declared 64110/282 with only a supplied prefix of 100 words. | Retain only the detached prefix as incomplete diagnostic evidence; retain any previous complete raw record separately. | Native incomplete-response/span rejection; no padding, partial typed output or acquisition. |
| Opaque accepted retention: one complete 64110/282 candidate with A and complete structural prerequisites. | Accept raw storage only, with original spans and descriptor; no typed labels or profile match. | Native retention permission and matrix missing compatibility/operation evidence. |
| Eventual reopening candidate: assume future unique public applicability evidence and a separately qualified read operation. | Requires a new reviewed contract and a new candidate with evidence bound to its qualified source set and operation; historical records remain diagnostic and cannot support the new selection. | Matrix's conjunctive prerequisites; this hypothetical case is not currently qualified and still has zero requests/facts today. |

## Reopening, consumers and remaining acceptance

Future reopening needs both a unique public source layout for exact
product/firmware applicability **and** a separately source-qualified read
operation specifying the entire function/table/address/quantity/response-size/
timeout/retry contract. Complete Common Model and model-chain prerequisites,
unambiguous occurrences, valid spans/scale and immutable provenance remain
required. Complete raw input alone is insufficient. Even later source agreement
does not itself authorize scheduling, retry, discovery or backfill.

This page adds no scheduler, transport, registry implementation, gateway
composition, eeBUS output binding or MCP/GraphQL field. Existing eBUS MCP
compatibility and GraphQL parity remain unchanged; neither consumer may derive
typed facts from opaque retention. Any future consumer projection must preserve
source revision, invalidation, unknown/opaque status and native evidence, and
declare projection loss through its own contract. No credential, principal,
authentication or permission check is introduced.

This is a partial contract contribution to helianthus-modbusreg issue #201,
tracked by helianthus-docs-modbus issue #185. No parent closure is claimed.
Provider implementation,
transaction/concurrency tests, public compatibility evidence, the separate read
operation, profile admission, transport conformance, consumer parity validation
and any hardware qualification remain outside this contract's evidence.
Readability and manual source review do not establish semantic or runtime
validation. No live or hardware smoke result is claimed.
