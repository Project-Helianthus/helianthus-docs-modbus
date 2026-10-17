# Fronius provider commit and failed refresh

This Helianthus application lifecycle proposal is released under AGPL-3.0-only.
It leaves the native CC0 protocol contracts unchanged. Nothing is stable before
the Helianthus 1.0 release.

## Status and current evidence

This page specifies future provider behavior for the Fronius inverter family.
It adds no implementation, discovery, automatic runtime admission, dependency
pin, write operation, or hardware qualification. It does not widen the exact
applicability of an existing qualification card to an entire family.

The public native contracts are the authority for protocol facts:

- [Qualification readiness](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/fronius/qualification-readiness-v1.md)
  defines the bounded card, complete-chain outcomes, native evidence and
  qualification boundary.
- [SunSpec float flavor](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/fronius/sunspec-float-v1.md)
  defines the exact observed geometry and applicability. Its exact applicability
  tuple remains authoritative; this page does not reproduce device identifiers.

Current implementation evidence is narrower than this proposed lifecycle:

- [Chain plan](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/sunspec_chain_plan.go):
  `NewSunSpecChainPlan` validates explicit finite bounds, base candidates and
  exact decoder keys; requests carry plan, chain-instance and sequence identity.
  The request function is FC03. This file alone does not establish cancellation
  handling or provider storage behavior.
- [Qualification card](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/sunspec_fronius_qualification_card.go):
  `NewReplayChain`, `Qualify` and `replayExactAcquisition` require source-backed
  replay of the exact card plan, a complete terminal snapshot, and equality of
  replayed words, occurrences and source views. Extra views after the terminator
  are rejected. The card checks requested and received function, table and unit,
  and requires the exact observed flavor before returning an observation.

| Evidence class | Meaning here | Independent qualification state |
| --- | --- | --- |
| Proven | The cited native contracts and inspected interfaces define the current offline boundary; this is source inspection, not a newly executed replay | An offline match remains `live_qualified=false` |
| Hypothesis | Every provider interface, transition and retained-result rule below is a proposed design | No runtime or hardware acceptance follows |
| Unknown | Provider integration, concurrency behavior, persistent storage and consumer behavior have not been demonstrated | No support or automatic admission claim |

The native contract retains an authorization-scope provenance field. This
proposal preserves existing native evidence without introducing any credential,
principal, authentication, permission or authorization check. Authentication
and authorization remain later lifecycle subjects.

## Fixed acquisition and selection boundary

The existing card remains read-only: FC03, holding registers, Unit Identifier 1,
base-candidate set exactly `[40000]`, maximum 512 chain words, maximum 64 model
occurrences and at most 125 words per read. A generic planner's wider accepted
parameter range does not widen these card limits. The required ordered geometry
is `1/65`, `113/60`, `120/26`, `121/30`, `122/44`, `123/24`, `160/88`,
`124/24`, then `ffff/0`, as defined by the native contracts.

Only explicitly configured bounded reads within this card may be proposed.
No source, base, unit, function or profile scan is introduced. There is no
automatic retry or fallback in this proposal; a new attempt requires a fresh
cycle with a finite deadline and the same explicit acquisition boundary.

Generic three-phase monitoring capability, exact vendor-flavor match and
hardware qualification are separate results. A complete generic capability
match alone cannot produce a Fronius qualification observation. Required
non-sentinel facts and their declared units must remain valid. Unknown models,
duplicate occurrences and unsupported lengths keep their native dispositions;
they cannot be removed to force an exact match. Multiple positive flavor
candidates are a proposed fail-closed ambiguity outcome, never a first-match
selection. The cited card does not establish such a multi-candidate resolver.

## Proposed identities and retained envelope

These are conceptual provider interfaces, not new exported registry APIs.

`Begin(context)` creates a fresh private candidate and an unrepeatable cycle
token. Its immutable context binds the card/schema selection, explicit plan
bounds and acquisition identity. A retained bundle binds three related identities:

| Identity | Required coherence | Across refresh cycles |
| --- | --- | --- |
| Source compatibility key | Requested and received function, table, unit, opaque source/connection identity, transport generation and card/schema selection | Must match before an old observation may be reused for the active source |
| Attempt identity | Cycle token, poll generation and deadline identity, with a finite expiration | Fresh per cycle; old observations retain their original values |
| Request identity | Planner-issued plan, instance and sequence identity, purpose, exact address and quantity; response evidence covers precisely that request | Never transplanted into another attempt or fabricated by the provider |

Every retained logical view and every source span must resolve to the same
source compatibility key and attempt identity within its bundle. Requested and
received function must both be FC03; table and unit must agree with the card.
Connection identity, transport generation, poll generation and deadline
identity cannot be rewritten to make an earlier chunk appear current. Matching
words or adjacent ranges alone are insufficient. The provider adds cycle
identity around the existing native evidence; it does not replace that evidence.

`RetainedResult` is one immutable envelope containing the complete native
qualification observation, its raw words, ordered occurrences, decoder keys or
opaque dispositions, source spans and logical-view provenance, plus the generic
capability outcome, exact flavor outcome, card identity, and original cycle
context. Candidate field identifiers retain their native meaning and units;
this envelope grants no semantic promotion. All unlisted and unavailable raw
values remain retained. Missing values never become numeric zero.

An atomic provider read returns a retained envelope (or absence) together with
its compatibility, freshness and latest-attempt outcome. A failed-attempt
diagnostic may name the failed new cycle, but cannot relabel the retained
observation with that cycle's poll or deadline identity. In-progress prefixes
may be diagnostics only and must never appear as retained observations.

## Proposed cycle and commit transitions

| Interface / transition | Required behavior | Current source basis and proposed extension |
| --- | --- | --- |
| `Begin(context)`: idle to collecting | Validate explicit card bounds; create a fresh chain and token; retain the previous complete envelope without modifying it | Card `NewReplayChain` and plan constructor exist; provider token and freshness tracking are proposed |
| `AcceptChunk(token, request, view)`: collecting to collecting | Admit only the next planner-issued request through native acquisition validation; preserve ordered views and source evidence; reject unexpected, duplicate, out-of-order or identity-mixed completion | Card replay asks for exactly one next request and uses `AdmitReplay`; provider token guard is proposed |
| Terminator accepted: collecting to complete candidate | Require the native complete snapshot including `ffff/0` and no extra source views; check all bounds and provenance; stop requesting chunks | Native contract and exact replay require completeness; provider staging state is proposed |
| `Select(token)`: complete candidate to selected or rejected | Evaluate generic capability separately, then require unique exact flavor and successful card `Qualify`; retain all negative/opaque evidence | Native matrix and `Qualify` define exact acceptance; explicit ambiguity handling is proposed |
| `Commit(token)`: selected to retained | Recheck active token, uncancelled unexpired deadline and unchanged source key; atomically replace the whole retained envelope and publish success with it | Immutable native observation exists; atomic provider replacement is proposed |
| `Fail(token, reason)`: any uncommitted state to failed | Close the token, stop further work, retain a bounded diagnostic, discard candidate eligibility; apply the failed-refresh rules below | Native invalid/incomplete replay produces no observation; failed-refresh storage policy is proposed |
| `Cancel(token)` or superseding `Begin`: uncommitted to cancelled | Invalidate the old token before any replacement cycle can commit; reject all subsequent callbacks for it | Cancellation and supersession ordering are proposed; not demonstrated by the cited files |

No selection or commit occurs before native terminal completion. A missing
terminator remains incomplete until cancellation or the finite deadline closes
the attempt as failed; it never becomes a partial positive result. A malformed
terminal length, zero model length, overflow or contradictory range fails the
candidate under the native contract. No later chunk repairs a failed attempt.

Commit is a single visibility point for the complete envelope and attempt
outcome. It must serialize against cancellation, supersession and source-key
change. If invalidation wins, even a fully decoded late result cannot commit.
If commit wins first, the completed historical result remains immutable; a
subsequent source change still removes its eligibility for the active source.
Consumers cannot observe new facts with old flavor, new metadata with old raw
evidence, or a new poll identity on old words. No persistent crash-atomicity
guarantee is specified here.

## Proposed failed-refresh and last-known-good rules

Starting a refresh marks the previous complete observation as last-known-good,
with refresh pending; it does not make that observation fresh for the new poll.
Failure, ambiguity, cancellation, incomplete replay or a generic-only result
cannot overwrite it with a partial or differently classified observation.
Only a complete, selected, successfully qualified candidate can replace it.

For the same source compatibility key, the previous complete observation may
remain available explicitly as stale last-known-good after a failed refresh.
Its original raw evidence, poll generation and deadline identity remain intact;
an expired acquisition deadline cannot authorize new I/O or imply current data.
With no prior complete observation, retained observation stays absent. A
generic-only outcome may be exposed as a separate complete diagnostic, with
its own evidence and identity, but never combined with the old vendor flavor.

A change to any source-key component immediately prevents active reuse, even
if values look identical or the next refresh fails. The old envelope may remain
historical evidence labelled incompatible, but the active retained observation
is absent until a new complete exact-card result commits for the new key. A
transport reconnect with a new generation is such a change. Returning to an
earlier key does not automatically reactivate history; a new cycle is required.
Changing only poll generation or deadline identity is a normal refresh, not
permission to mix old and new chunks. Unknown source compatibility fails closed.

## Synthetic acceptance cases

These symbolic examples are design review cases, not executed replay tests.
`R0` denotes a prior complete observation for opaque source `A`, transport
generation `T0`, poll `P0` and deadline `D0`. A normal refresh uses `P1` and
`D1` with the same source key; all new views must share that new identity.

| Case | Candidate outcome | Retained result and evidence boundary |
| --- | --- | --- |
| Complete admitted offline observation | Ordered exact-card reads through `ffff/0`; valid generic capability, unique exact flavor and successful `Qualify`; active token at commit | Atomically install `R1` with all `P1/D1` views and raw evidence; offline replay match only; `live_qualified=false`, `automatic_runtime_admission=false`, `write_authority=false` |
| Failed later chunk | A valid prefix is followed by a failed read or invalid chunk | Close attempt; no new observation or prefix merge; `R0` stays stale last-known-good for the unchanged source key |
| Missing terminator | Payload arrives but terminal chunk does not | No selection; incomplete until finite deadline or cancellation, then failed/cancelled; `R0` stays stale, never completed by assumption |
| Generic-capability-only result | Complete native chain admits generic monitoring but does not match the exact vendor flavor | No Fronius commit; separate generic diagnostic keeps its own complete evidence; `R0` remains stale, with failed vendor refresh visible |
| Ambiguous flavor | More than one positive vendor-flavor candidate | Select none and fail the attempt; do not pick by order or publish an exact flavor; `R0` remains stale for the unchanged key |
| Changed acquisition provenance | New source, connection, transport generation, function, table, unit or card/schema context; or a mixed-identity chunk within the cycle | Source change makes `R0` historical and ineligible immediately; mixed chunks fail candidate validation; no active observation until a complete coherent result for the new key commits |
| Late completion after cancellation | Terminal callback or selection finishes after token cancellation or supersession | Ignore for commit, stop further candidate work; `R0` remains stale if compatible; a newer committed result is never overwritten |

If any retained view has the wrong function, table, unit, source, transport
generation, poll generation or deadline identity, reject the whole candidate.
These are independent review obligations; equality of the other fields cannot
compensate for one mismatch. They are reasoned requirements, not mutation-test
evidence. For every failing row without `R0`, observation remains absent.

## Integration boundaries and remaining evidence

MCP and GraphQL must eventually project the same retained envelope, absence,
staleness, incompatibility and refresh failure semantics. Neither may expose a
prefix as current, infer qualification from a generic capability, or drop native
evidence without making projection loss explicit. Existing eBUS MCP behavior
must remain compatible. This page defines no consumer API or output binding;
eeBUS output binding belongs in its driver repository.

The source/claim/transition/case review establishes only contract consistency.
Provider implementation, cancellation race tests, per-field provenance tests,
atomic reader tests, bounded diagnostic retention, consumer parity tests and
operational freshness policy remain future work. Persistence, restart recovery
and crash behavior are unknown. Readability or offline link inspection proves
neither runtime semantics nor native replay execution.

Hardware qualification, profile admission, live transport validation, gateway
composition and remaining Project #2 acceptance stay open. No pending
preservation specification, other provider implementation or SmartLogger policy
is a prerequisite or changed by this page. This proposal adds no live procedure
and grants no authority for device access or control.
