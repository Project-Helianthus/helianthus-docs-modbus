# EMMA provider identity and optional inventory transactions

This Helianthus application architecture guidance is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page proposes a future provider transaction boundary for the EMMA family.
It defines no implemented acquisition lifecycle, native qualification, new
profile namespace, or stable API. Nothing is stable before Helianthus 1.0.
All current automatic admission remains disabled. This is a partial contract
slice for modbusreg issues #201 and #199; it does not close either parent.

The canonical native sources are the
[Huawei gateway read-only contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md)
(EMMA candidate, Child inventory, and Collision and failure rules) and the
[Huawei qualification readiness contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/qualification-readiness-v1.md)
(EMMA qualification card and Shared resolution and negative overlap).
They alone supply native addresses, exact identity predicates, encoding,
pagination and limits. This page adds no version or model wildcard, probe,
register address, or capability inheritance.

| Evidence status | Current basis and limit |
| --- | --- |
| Proven, source inspection only | The native contract separates the complete FC03 identity tuple from optional basic/extended MEI. Optional MEI failure does not negate validated identity; MEI success alone cannot identify EMMA. This is no live-device proof. |
| Proven, current code interface | `EvaluateHuaweiEMMAOfflineIdentity` evaluates supplied strings without transport and always defaults to denied. `ParseHuaweiEMMAOfflineInventory` consumes detached pages and caller-supplied before/after guards; it performs no acquisition. |
| Hypothesis / proposed behavior | Every transaction input, output, ownership rule and transition below is a future integration requirement, not a claim about current provider behavior. |
| Unknown | A qualified EMMA inventory-guard acquisition procedure, correlated live acquisition, capability fixtures, lifecycle race behavior and consumer integration are not established by these sources. |

Qualification is a separate axis. The current EMMA card remains
`QUALIFICATION_EVIDENCE_BLOCKED`, with the missing evidence named by the
qualification contract. A matched identity or complete inventory changes none
of that card's safety fields and proves no telemetry, control, hardware or
support capability. Shared cross-family resolution still applies independently;
a local identity match cannot bypass a conflicting or failed class result.

## Proposed inputs, outputs and integration seam

The later `helianthus-modbusreg` integration seam composes the existing
transport-free evaluator and parser, rather than replacing their native rules:

- Identity input: an owned, complete FC03 tuple with raw request/response
  extents and decoded offering, family variant and software version, all from
  one parent source, connection generation, attempt and source revision. The
  caller validates the exact native target, lengths and encoding, without
  reusing tuple components from earlier attempts, before invoking
  `EvaluateHuaweiEMMAOfflineIdentity(offering, model, firmware)`.
- Optional inventory input: an explicit enumeration selection, detached ordered
  pages and native guard-before/guard-after evidence for that same context.
  Only a fully collected candidate is passed to
  `ParseHuaweiEMMAOfflineInventory`. Basic MEI enrichment cannot replace
  extended child enumeration or identify the family.
- Transaction context: opaque parent-source key, source revision, connection
  generation, attempt generation, cancellation state, deadline and finite
  remaining retry allowance. The parent-source key identifies an independently
  owned source, not a credential or an authorization principal. It is never
  inferred from an ESN or offering string.
- Commit input: the frozen candidate plus its expected context and the current
  per-parent context, compared atomically before publication. A generation is
  local correlation metadata, not a native wire transaction identifier.
- Decision output: one immutable envelope with the attempt outcome, explicit
  identity and inventory results below, qualification result, admission flags,
  evidence references, missing-evidence/rejection reasons, and separately
  labelled last-known-good references. Completion order cannot alter its
  meaning; use native page order and a defined field order rather than map
  iteration or wall-clock order.

The proposed decision fields are independent:

| Output | Meaning |
| --- | --- |
| `identity_match` | `true`, `false`, or `unknown` for this attempt's complete FC03 tuple; only `true` allows an identity commit in the unchanged context. A timeout or missing tuple is unknown; a validated mismatch is false. |
| `inventory_status` / `inventory_complete` | `not_requested`, `blocked`, `pending`, `complete`, `failed`, or `stale`; completeness is true only after an entire candidate passes native validation and the commit fence. No pages is not proof of an empty inventory. |
| `qualification` | Explicit result of the separate qualification evaluation, including missing evidence; never derived from identity match or inventory completeness. Current EMMA remains evidence blocked. |
| Safety flags | `default_denied=true`; `catalog_registered=false`, `automatic_runtime_admission=false`, `live_qualified=false`, `support_claim=false`, `write_authority=false`. No transaction can promote these. |
| `commit_outcome` | Identity committed, inventory committed, no commit, or stale/rejected completion, with a bounded reason. Retained historical evidence is not a successful current attempt. |

These are conceptual fields, not a new exported implementation or versioned
schema. Any later MCP and GraphQL surfaces must consume the same committed
envelope, freshness and reasons, retain eBUS MCP compatibility, and never
independently upgrade missing inventory or admission. Projection loss must be
explicit: a child summary cannot substitute for native pages, guard evidence,
attributes, version context or unknown values. No consumer API changes are
implemented here; eeBUS output binding remains driver-owned.

## Proposed acquisition and commit boundary

Begin with bounded, explicitly allowlisted FC03 identity acquisition using only
the native contract's tuple. No unit scan or family fallback is implied. On a
validated match, atomically commit identity if the context is still current.
Identity is an independent component; inventory need not be requested.

Optional enumeration begins only after that match and only when the caller
can supply a documented, qualified EMMA guard acquisition procedure. The
current parser's guard parameters are not evidence of a native guard address.
Do not borrow the SmartLogger counter or S-Dongle sequence. With that procedure
unknown, mark inventory blocked and send no speculative guard read; retain the
identity. A caller assertion of guard equality without native evidence is
insufficient.

Stage every inventory page in an attempt-local candidate. Apply the native
pagination, duplicate-address, object, count, attribute, guard and resource
limits without widening them. At inventory commit, require a complete validated
candidate, the matching committed identity evidence, no cancellation or expired
deadline, and equality of parent-source key, source revision, connection and
attempt generations. Native before/after guard equality and the local commit
fence are distinct requirements. Neither substitutes for the other. The
inventory self entry must agree with the committed FC03 family variant and
software version wherever those fields are supplied; conflicting evidence
rejects the candidate rather than selecting a preferred identity. Checking
and publishing must be atomic with respect to disconnect, replacement and a
new attempt.

Never merge pages across attempts or append a partial candidate to an earlier
inventory. Replacing a complete inventory is one atomic operation for its
parent. Duplicate child addresses reject the whole candidate, not just the
second record. Stable child keys retain the native contract's parent profile,
routing address, model/product type and source revision; optional identifiers
alone do not establish stable identity.

## Proposed transitions and synthetic cases

All cases use symbolic, synthetic contexts: parent P or Q, revisions R and S,
and attempt tokens A and B. They are manual contract examples, not executed
tests or observed device behavior. In every row qualification remains separate
and automatic admission remains false.

| State / event | Identity result and commit | Inventory result and retained state | Source basis / proposed addition |
| --- | --- | --- | --- |
| Start P/R/A; complete valid FC03 tuple | Match; commit identity only if fence holds | Not requested unless explicitly selected | Native EMMA identity rule; proposed identity commit |
| Valid identity; optional MEI times out | Match remains valid in unchanged context | Failed, incomplete; discard candidate pages; retain any same-context complete inventory as last-known-good, explicitly stale for this attempt | Native optional-MEI rule; proposed retention |
| FC03 tuple fails or is missing; apparently valid MEI arrives | False for mismatch or unknown for missing tuple; no new identity commit | Blocked, incomplete; diagnostic inventory evidence cannot substitute for identity or refresh prior inventory | Native MEI insufficiency; proposed fence |
| Valid identity; optional inventory omitted or guard procedure unknown | Match remains valid | Not requested or blocked respectively; incomplete, no invented empty list | Native optionality and caller-supplied guards; proposed blocked outcome |
| P/R/A; guard changes during enumeration | Identity remains valid if its context is unchanged | Failed, incomplete; discard whole candidate; prior complete inventory remains separately labelled | Native guard rejection; proposed component isolation |
| P/R/A; two children share a routing address | Identity remains valid | Failed, incomplete; no deduplication, overwrite or partial publication | Native duplicate-address rejection |
| P/R/A finishes after attempt B supersedes it | Historical match may be retained as evidence, but A cannot refresh active identity | Stale, incomplete for A; no commit or replacement of B's state | Proposed attempt-generation fence |
| P/R/A; complete valid enumeration and unchanged fence | Match still current | Complete; atomically replace only P's inventory from this candidate | Native full-validation requirement; proposed commit |
| Disconnect while P/R/A is in flight | Retain historical identity; mark unavailable, never current on the next connection without reacquisition | Cancel A; late completion is stale; retain historical inventory without current completeness | Proposed connection-generation fence |
| P changes revision R to S while A is in flight | Invalidate current eligibility of R evidence; reacquire the entire tuple for S | Reject A's completion; retain R only as historical; no child keys or pages migrate to S | Native revision-scoped child identity; proposed replacement fence |
| P is replaced independently while Q has a valid committed result | Retire P's context and increment its generation even if replacement reuses revision label R; Q remains unchanged | Cancel only P's candidates, retain its historical evidence; Q's inventory is neither cleared nor merged with P | Proposed per-parent source ownership |
| Any page/count/byte/deadline bound, malformed record or non-optional acquisition failure | No fabricated identity or profile; an independently committed identity is retained only as evidence with explicit freshness | Failed, incomplete; no partial child list becomes complete | Native bounds and fail-closed rules; proposed evidence retention |

A failed later identity attempt cannot overwrite last-known-good identity with
an empty tuple or silently treat that history as the current attempt's match.
A changed identity tuple also retires inventory associated with the prior
identity, even within the same source revision. A later success starts a fresh
candidate; earlier partial pages never become its initial inventory.

## Retry, disconnect and evidence ownership

The future provider acquisition coordinator owns the total deadline, finite
attempt allowance and cancellation for each parent transaction. Native total
enumeration and page/object/byte maxima remain hard ceilings. Transport retry
consumes that same allowance and deadline; neither parser, consumer, scheduler
nor reconnect may reset it or add nested retries. Each new enumeration attempt
starts from the canonical first object and obtains fresh guards. Exhaustion
returns failure without partial success. Exact identity-read timeout and retry
settings are unspecified here; missing finite settings block acquisition rather
than supplying an unbounded default. Disconnect cancels the attempt; reconnect
requires a new generation and bounded identity reacquisition, not resumption of
old pages. This proposal authorizes no live requests today.

The provider owns detached immutable evidence for each attempt before exposing
it. Caller buffers, parser inputs, staged pages and returned views must not
alias mutable storage. Preserve native bytes and decoded fields together with
request context, source revision, guards, order, exceptions, unknown attributes
and outcome; do not manufacture bytes for missing replies. Failed/partial
evidence remains diagnostic and cannot be returned as a complete inventory.
Public examples contain only synthetic family-level data. Runtime native
retention and public-artifact redaction are separate boundaries.

Last-known-good identity and inventory retain their own originating context,
completeness and freshness. A failure can update diagnostic status without
erasing those components, but retired or disconnected evidence is historical,
not current admission evidence. Storage eviction policy is future work; it
must not relabel a partial result as complete or erase the distinction between
missing and zero. Replacement of P cannot mutate evidence owned by Q.

## Review basis and remaining acceptance

Manual review of every proposed input/output, table row and synthetic case
uses the two canonical pages above and these current implementation seams:
[offline identity evaluator](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/huawei_emma.go)
and [offline inventory input/parser](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/huawei_emma_inventory.go).
The code establishes offline signatures and default denial; it does not prove
transaction orchestration, immutable transport storage, lifecycle fencing,
retry enforcement or consumer parity. Guard acquisition remains unknown.

Remaining parent acceptance includes provider implementation, independent
lifecycle/race and partial-retention tests, explicit finite retry settings,
qualified guard acquisition, capability and negative-overlap evidence,
MCP/GraphQL parity verification, transport and end-to-end replay, independent
review and separate hardware acceptance. Readability and offline link review
are documentation checks, not semantic or runtime validation. No new tests or
native qualification are supplied by this page.

This is neither the SmartLogger lifecycle nor the qualification checklist.
It changes no protocol/type contract, shared gate, or other provider lifecycle.
It introduces no credential, principal or permission check; authentication and
authorization remain later roadmap subjects. It grants no control or write
operation and no profile promotion.
