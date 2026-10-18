# OutBack offline provider-cycle contract

This Helianthus application architecture proposal is released under
AGPL-3.0-only. It complements the native contracts without changing their
licensing. Nothing here is stable before Helianthus 1.0.

## Native authority and evidence status

The public native contract takes precedence over this application proposal:

- [Source/profile matrix](../protocols/outback/axs-port-source-profile-matrix-v1.md):
  source binding, finite selector, replay provenance and denied operations.
- [Native read-only boundary](../protocols/outback/axs-port-sunspec-readonly-v1.md):
  opaque caller evidence, incomplete extents and no partial typed output.

The [observation lifecycle](outback-observation-lifecycle.md) supplies the
application retention and invalidation requirements. Separately, the merged
[detached-record component page](outback-detached-record-implementation.md)
describes the existing component (ZD), including its API and limitations.
This page adds cycle composition around that component; it does not replace it.

| Evidence status | Claim and limit |
| --- | --- |
| Proven within the supplied component evidence | `NewOutBackDetachedRecord` creates a bounded detached diagnostic record; its association comparison does not fence publication. `Evaluate()` remains `NO_GO`; `TypedFacts()` and `Requests()` are empty. These are component claims, not newly executed tests or physical qualification. |
| Hypothesis, fixed as implementation acceptance below | A family-local offline holder can import supplied native records through a bounded diagnostic callback, retain one record and the latest cycle status, and fence replacement/cancellation. No implemented holder, reviewed new signature or runtime result is claimed. |
| Unknown | Unique public applicability evidence, a qualified read operation, concrete persistence, production registration and live qualification remain unestablished. |

Evidence status, structural completeness, association, freshness, qualification
and runtime admission are separate axes. A complete, currently associated record
is still opaque and denied admission. This contract can merge before its code
companion; code must agree with the behavior and reviewed signature before code
merge. No unmerged implementation is an evidence dependency.

## Existing types and proposed seam

Reuse `NewOutBackDetachedRecord(input, maxBytes)`, which returns
`(*OutBackDetachedRecord, error)`, with `OutBackDetachedRecordInput`:

- `Words`, `DeclaredWords`, `Present`, `Missing`, `Occurrences`, and `Source`.
- `OutBackWordSpan` carries `Offset` and `WordCount`.
- `OutBackDetachedOccurrence` carries `Ordinal`, `WireKey`, logical `Offset`,
  `Words`, `Present` and `Missing`; preserve slice order and duplicate occurrences.
- `OutBackSourceAssociation` carries `Key`, `Revision`, `PublicLocator`,
  `ContentIdentity`, `DeclaredLayout`, `SourceSetRevision`, `SelectorInputs`
  and `Available`.

Use the component's `AccountedBytes()`, `Complete()`, `RawWords()`,
`DeclaredWords()`, `PresentSpans()`, `MissingSpans()`, `Occurrences()`,
`SourceAssociation()` and `Association(current)` without redefining their
meaning. `OutBackAssociationCurrent` and `OutBackAssociationHistorical` are
existing comparison results. There is no native `unassociated` constant:
that proposed holder status means no retained association can be presented.
`ErrOutBackDetachedRecordBound` remains the constructor's bound failure.

The proposed seam is an OutBack-family offline holder with an injected,
non-nil diagnostic supplier returning `(OutBackDetachedRecordInput, error)`.
Cancellation and finite work limits must reach the supplier. The spelling of
new holder, callback, cycle and snapshot APIs remains subject to implementation
review; this is a behavioral contract, not a Proven exported signature.
The supplier imports caller-owned native evidence. It performs no Modbus read,
probe, discovery, retry or inferred acquisition. This seam is not the future
gateway Provider registry M02, a global provider API, a transport adapter or an
acquisition owner. eeBUS output remains driver-owned.

## Finite bounds, ownership and receipt

The following are required acceptance conditions for the proposed holder:

1. Require a positive practical finite record-byte bound, finite caller work
   and input limits, a finite cancellation/deadline budget and a non-nil
   supplier. Validate these before invoking it. Reject zero, absent,
   inconsistent or overflowed limits without a callback. An already cancelled
   attempt invokes no callback. Bounds are mandatory even for incomplete or
   malformed diagnostics; there is no default layout or 282-word default.
2. Permit at most one supplier invocation per attempt, with no automatic retry,
   queue or background accumulation. Explicit replacement retires the active
   attempt before another begins. Bound simultaneously executing callbacks;
   a callback that has not returned occupies that capacity even when retired.
   The holder must not launch unbounded replacement goroutines.
3. Caller input limits cover words, spans, occurrences, nested words/spans and
   all source strings before retention. Apply the same positive `maxBytes`
   through `NewOutBackDetachedRecord` to the entire returned input before
   copying/publishing. Missing extents never allocate missing words.
   `AccountedBytes()` is deterministic evidence accounting, not a heap quota or
   serialized envelope. Keep finite separate status/work limits; arithmetic
   overflow fails closed.
4. A cooperative supplier must obey the caller's work, input and cancellation
   limits before creating its result. The holder cannot preempt arbitrary Go
   callback work or prevent its allocations using a byte check after return.
   Non-cooperative suppliers do not meet this contract; do not advertise a
   hard runtime bound merely because the constructor is bounded.
5. Returned mutable input is exclusively handed off until construction finishes;
   the supplier must not mutate it concurrently. The component detaches words,
   nested buffers and strings. Published snapshots use immutable records and
   copied mutable views; later caller/view mutation cannot change retention.
6. Retain at most one detached record and one bounded latest-status envelope.
   Replace records atomically; do not accumulate raw failed inputs, arbitrary
   error strings, callback closures or history. Status uses finite categories,
   attempt/generation identifiers and bounded metadata. Temporary constructor
   state may coexist with the old record within an explicit finite work budget.

The conceptual envelope separates retained-record association, completeness and
retention age from current association disposition, local generation/attempt,
latest outcome and denied admission. Retain the publication generation with
the record as well as its native association; local identifiers are bounded
metadata, not native source identities. It introduces no typed facts. Freeze a
caller-monotonic retention-age reference on actual record publication only;
failures, reads of the snapshot, cancellation and source changes cannot reset
it. Reject regressing age input rather than making a record appear younger.
This is age since import, not age since device observation; observation age and
freshness stay unknown unless independently supplied and preserved. No capture
time or wall-clock timestamp is inferred. Equal ordered inputs and event order
produce deterministic envelope contents; no random identity or error-text
projection is needed.

## Attempt, callback, error and cancellation order

All rules in this section are Hypothesis acceptance for the holder. The existing
component does not implement these transactions.

1. Validate configuration, callback and caller limits. Under the holder's
   synchronization, allocate a non-reused local attempt within the current
   association generation and freeze
   the supplied association and source-set/selector inputs. Counter exhaustion
   fails before callback; wraparound cannot revive an old attempt.
2. Invoke the supplier once, outside the publication lock, with cancellation
   and the finite caller budget. Do not hold a lock across caller work.
3. Cancellation, retirement or association replacement linearizes under the
   same publication synchronization. It fences the active attempt immediately,
   requests cooperative cancellation and records the latest status without
   touching the retained record's identity or age. A late completion cannot
   change either the record or a newer status.
4. On return, first check the attempt/generation fence and cancellation. If
   retired, discard input and error without construction or publication. If
   current but cancelled, publish only the cancelled status. Cancellation
   observed before publication wins over supplier error or successful input.
5. Otherwise a supplier error wins over its returned input: discard that input,
   retain the previous record and publish a bounded supplier-error category.
   Do not stringify or persist the arbitrary error. No constructor is called.
6. On an error-free return, require `input.Source` to equal the frozen attempt
   association on every axis. A mismatch is a source-conflict failure, not
   permission to stamp the expected source onto the returned words. Preserve
   the old record, or show unassociated if none exists.
7. Check finite input/work limits and construct with
   `NewOutBackDetachedRecord(input, maxBytes)`. A bound failure yields no
   candidate and preserves the old record. Structurally malformed but bounded
   input can yield an incomplete diagnostic record; do not repair it.
8. Recheck cancellation, current association and generation/attempt immediately
   before atomic publication. Replacement during construction discards the
   candidate. If publication wins before later cancellation, the published
   record remains with its original receipt and age; subsequent cancellation
   changes latest status only. Every failure/status publication also performs
   this final fence under the same synchronization; a racing old error cannot
   overwrite replacement or cancellation status.

A source update advances the association generation and retires an active
attempt even if its payload would be equal. A failed same-association attempt
does not advance that generation or demote the retained association.
No old completion may become current again after an association changes away
and back. Source updates, cancellation and snapshot reads perform no I/O.

## Retention, association and loss transitions

A complete import replaces the slot only after the final fence succeeds. An
incomplete diagnostic may occupy an empty slot or replace a previous incomplete
record; it never overwrites a retained complete record. In that latter case
retain only the complete record and latest incomplete status, discarding the
new fragment. This deliberate loss keeps the one-record bound while preserving
partial last-known-good state. Here “good” means complete raw retention, never
a qualified typed OutBack view. Failure never renews that record's age.

| Event | Required record and latest-status outcome |
| --- | --- |
| Complete import, matching available association | Publish detached record under its original association and new import-age reference; status complete-retained, association current. Admission remains denied. |
| Bounded incomplete or malformed input | Preserve exact extents in an eligible diagnostic slot, including gaps, overlaps and out-of-range spans; otherwise keep the complete record and report incomplete-not-replaced. Never pad, join, truncate, deduplicate or renumber. |
| Duplicate occurrences | Preserve each occurrence, ordinal, wire key, offset and nested spans in caller order if retained. Structural completeness does not establish unique native selection; admission remains denied. |
| Oversize, invalid limits or supplier error | No new record. Preserve prior association and age; latest outcome distinguishes pre-callback invalid input, bound failure and supplier error. |
| Replacement or cancellation before publication | Fence attempt, preserve prior record and age, publish the appropriate latest status. Discard late success and late error, including after a newer successful import. |
| Current association changes, is missing, unavailable or conflicting | Preserve original association and record age. Present historical when a record exists, unassociated when absent. Do not substitute a former descriptor for missing current evidence. |

Association comparison must cover each independent axis:

| Axis | Independent change that must remove current association |
| --- | --- |
| `Key` | Different source key, with identical payload and all other metadata unchanged. |
| `Revision` | Different source revision alone. |
| `PublicLocator` | Different public locator alone; equal content identity is insufficient. |
| `ContentIdentity` | Different content identity alone; equal locator is insufficient. |
| `DeclaredLayout` | Different opaque layout declaration alone; never reinterpret old words. |
| `SourceSetRevision` | Different evaluated source set alone. |
| `SelectorInputs` | Different selector inputs alone. |
| `Available` | Either original or current descriptor unavailable, even if strings match. |

Use native `Association(current)` for exact available-descriptor comparison.
Missing or conflicting current evidence must be represented separately by the
holder as non-current, even if one conflicting descriptor compares equal.
An unavailable original cannot become current merely by toggling current
availability. Current presentation also requires the retained publication
generation to match the current association generation. Changing away and back
cannot restore an old receipt to current; a new accepted import is required.
An import whose frozen source is unavailable may be retained diagnostically
but stays historical. Local generation/attempt fencing is additional to all eight axes;
it is not implied by `Association(current)`. Historical evidence never supports
new selection, and no re-evaluation rewrites its original receipt.

## Synthetic acceptance examples

These are manual transition examples, not runtime tests or observed devices.
`A` and `B` are synthetic descriptor values; `g1` and `g2` are local generations.
Age is a logical monotonic elapsed amount since import, not a capture time.
No digest, installation identity or transport coordinates are needed.
Every row requires `Evaluate()` = `NO_GO`, `TypedFacts()` empty and `Requests()`
empty. Writes/control remain `NO_SEND`.

| Sequence | Expected snapshot and loss |
| --- | --- |
| Success: g1 imports complete bounded words associated with A, then snapshot at age 4 | One complete opaque record associated with A; current only if A is available and unconflicted. Age 4, never a freshness or admission proof. |
| Incomplete after success: at age 5, same association supplies a prefix with explicit missing spans | Complete A record stays at age 5; latest incomplete-not-replaced, fragment discarded. With an initially empty slot the prefix alone could be retained diagnostically, still denied. |
| Malformed or duplicate input: empty slot receives bounded overlapping spans, or repeated wire keys with distinct ordinals | Preserve supplied malformed extents as incomplete, or ordered duplicate occurrences without selecting one. No repaired geometry or typed partial result. A retained complete record takes precedence over an incomplete candidate. |
| Failure: at age 6 supplier returns both input and error; next attempt exceeds byte bound at age 7 | Ignore the error-bearing input; then reject oversize before copy. A remains at ages 6 and 7 respectively with distinct latest outcomes, no refreshed receipt. |
| Cancel: at age 8 cancel g1 before its late successful callback returns | A remains age 8 with cancelled status; late input and error are discarded. Cancellation after publication would keep that already published receipt instead. |
| Replacement: at age 9 change current association A to B and start g2; g1 completes late | A remains age 9, historical; late g1 cannot overwrite g2 status. Only a fenced g2 import bound to B may replace it and start a new import age. That new record is still denied admission. |
| Missing/conflict: at age 10 current association is missing, or conflicts while one descriptor equals A | A remains original, historical and age 10; without a record show unassociated. Equal words or one matching descriptor cannot repair ambiguity. |
| Invalid call: absent finite work limit or nil callback | Zero callback invocations; old record and its age remain, latest pre-callback validation failure. No automatic retry. |

## Remaining production acceptance

Implementation review must reconcile the new signature, bounded status shape,
cooperative callback contract, linearization and retention policy with this
page. It must independently vary every association axis and exercise generation
reuse prevention, complete/incomplete input, duplicate occurrences, malformed
extents, oversize, supplier error with input, cancellation before/after
publication, replacement during callback/construction and late completions.
Detached ownership and empty requests/facts must hold throughout. These are
required future code checks, not tests executed by this documentation slice.

No acquisition plan, default read length, typed interpretation, successful
admission, global provider registration or persistence is established here.
Future gateway Provider registry M02 integration, concrete persistence,
transport conformance and live qualification require separate work. Existing
eBUS MCP compatibility and GraphQL parity remain unchanged; consumers cannot
project opaque evidence into typed facts. G5 D1-D5/O8 remain outside this seam
and retain their existing boundaries. No authentication or authorization gate
is introduced. No runtime, transport, passive-device or hardware smoke result
is claimed.

This page addresses [docs-modbus issue #217](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/217)
and advances [modbusreg issue #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201)
as a partial contract only. Neither parent closure nor implementation acceptance
is claimed. Ordinary required review and gates remain applicable.
