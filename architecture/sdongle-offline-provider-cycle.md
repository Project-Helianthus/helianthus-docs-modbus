# S-Dongle offline provider-cycle contract

This application architecture contract is released under AGPL-3.0-only. It
complements the CC0 native protocol contract. Nothing is stable before
Helianthus 1.0. The cycle below is proposed acceptance behavior, not evidence
that a provider-cycle implementation or a new exported signature exists.

## Authority and evidence status

The [canonical native gateway contract](../protocols/huawei/gateway-readonly-v1.md)
is the authority for protocol facts and the gateway/child boundary. The
[qualification disposition](sdongle-qualification-disposition-v1.md) preserves
the completed qualification's hard stop. This page adds no protocol facts,
qualified family members or live-read recipe.

The merged [route decision implementation boundary](sdongle-route-decision-implementation.md)
documents the existing component, `DecideSDongleRoute(SDongleRoutePlan)
SDongleRouteDecision`. The [provider routing proposal](sdongle-provider-routing.md)
supplies the broader retention and invalidation contract. This page composes
that component; it does not replace its validation or outcome precedence.

| Evidence status | Basis and limit |
| --- | --- |
| Proven | The merged component page documents native input/result types, detached evidence, documentary outcomes and unconditional default denial. These are component claims, not cycle implementation evidence. |
| Hypothesis | All cycle sequencing, lookup, bounds, cancellation and envelope rules below are required acceptance behavior pending implementation and review. No exact new API signature is asserted as Proven. |
| Unknown | Concrete storage, callback implementation, runtime freshness, actual child support and physical behavior. Missing evidence cannot be inferred by the cycle. |

Evidence status, qualification, freshness and admission are independent. A
caller assertion of current evidence cannot establish qualification; successful
offline evaluation cannot admit a profile.

## Family-local seam and supplied records

One explicit invocation requests one `SDongleRouteKey` and supplies a nonnil
offline lookup callback. The callback accepts that requested key and the
invocation's cancellation/deadline context and returns one `SDongleRoutePlan`
or an error. These are behavioral requirements, not a declaration of a new
exported Go function or callback type.

The lookup operates only over caller-supplied, already-decoded native records.
It is a family-local offline provider seam, not the future gateway Provider
registry M02, a global provider API, transport adapter or acquisition owner.
There is no request encoder, send callback, fallback scan, scheduler, automatic
registration or admission. It cannot resume a stopped qualification. eeBUS
output remains driver-owned.

Existing native inputs are `SDongleRouteKey`, `SDongleRouteSelection`,
`SDongleChildRoute`, `SDongleRoutePlan`, `HuaweiSDongleOfflineObservation`,
`SDongleRouteEvidence`, `SDongleRouteReference` and `SDongleRouteBounds`.
A plan retains `Key`, `Observation`, `Evidence`, `Bounds`, `TimedOut` and
`QualificationStopped`. The component result is `SDongleRouteDecision`, with
`Outcome`, `Reason`, `EvaluatorReason`, `Key`, `Observation`, `Evidence` and
`Bounds`. Do not substitute a projected family label for native identity.

## Finite work and invocation order

Before invoking the callback, require a nonnil context and callback, a complete
structurally valid requested key, a positive finite cycle deadline, and explicit
positive input limits. Caller limits cover record count, reference count,
individual string size, total supplied bytes and copy/evaluation work; they
must be enforced on the supplied store before lookup and on its result before
copying/evaluation. Missing or exceeded limits fail closed, without lookup for
invalid caller input. A callback cannot hide an unbounded search behind this
interface. The exact configuration types remain subject to API review.

The effective deadline is the earlier of the context deadline and the finite
caller cycle deadline. It bounds lookup plus validation, copying and evaluation,
not each step separately. There is at most one callback invocation and no cycle
retry. The callback must cooperate with context cancellation and use bounded
offline work. A deadline check cannot forcibly terminate an arbitrary callback;
an implementation must not claim bounded completion for a noncooperating
callback or launch orphan work to simulate it.

Apply this fixed precedence:

1. Validate caller inputs and finite bounds. Invalid input returns an invalid
   input failure, even if the context is already cancelled; callback count is
   zero. Known request prohibitions remain documentary controls, not permission
   to send or a reason to look for another route.
2. Check cancellation and the effective deadline immediately before lookup.
   If stopped, return cancellation/deadline failure with zero callbacks.
3. Invoke the callback once with the unchanged requested key and context.
4. Check cancellation/deadline immediately after it returns, before accepting
   either its plan or error. Cancellation dominates a simultaneous lookup error
   or otherwise usable plan. Preserve error diagnostics without accepting data.
5. If still active and the callback returned an error, return lookup failure.
   Discard any accompanying plan as a candidate; do not evaluate it, retry,
   scan, or silently reuse an earlier ready result.
6. Enforce returned-input bounds, detach the plan and compare the entire
   requested key to the returned `Plan.Key` before calling the component.
   A mismatch is blocked without evaluation. Also require `Evidence.Key` to
   equal the entire requested key; no normalization or partial-key match.
7. Call `DecideSDongleRoute` once on the detached plan. Preserve its result and
   original reasons. Recheck cancellation/deadline before publishing a result;
   cancellation during validation/evaluation cannot publish readiness.

The plan's documentary `SDongleRouteBounds` are independently required by the
component: positive deadline at most 15 seconds, explicit `RetryBounded`,
finite `MaxRetries` (zero allowed), and positive `MaxPages`, `MaxObjects` and
`MaxBytes`. Child limits remain at most 121 pages, 121 objects and 32768 bytes.
The cycle deadline and copy/input limits do not replace these bounds or grant
the component's documentary retries to the callback.

## Complete identity and documentary controls

Compare each requested/returned field by exact value, including zero-valued
fields where structurally valid. No case folding, firmware range, wildcard,
first match, default parent or inferred unit is permitted.

| Key location | Fields that must all agree |
| --- | --- |
| Top-level `SDongleRouteKey` | `Family`, `Model`, `Firmware`, `ProtocolMajor`, `ProtocolMinor`, `Role`, `Unit`, `Request`, `Scope`, `Revision` |
| `Child.Parent` (`SDongleRouteSelection`) | `Family`, `Model`, `Firmware`, `ProtocolMajor`, `ProtocolMinor`, `Role`, `Unit`, `Request`, `Scope`, `Revision` |
| Remaining `Child` fields | `EvidenceRevision`, `Qualification`, `GuardBefore`, `GuardAfter` |

Apply the same complete comparison to `Evidence.Key`. Even an internally valid
plan for another revision, scope or child is not the requested plan. Request
equality is an additional cycle check; component coherence checks still apply:

| Condition | Required decision/control |
| --- | --- |
| Gateway-self | Explicit gateway role and native gateway unit; empty child context. Observation identity equals the selected gateway identity. |
| Child | Explicit child role, independently supplied child identity/baseline and distinct child unit; observation describes the complete parent selection, not the child. No inheritance from gateway readability. |
| Child coherence | Parent revision and `Child.EvidenceRevision` agree with selected revision; `Qualification` is the component-required qualified-route assertion, not qualification performed here. Both guards agree with each other and the gateway observation. |
| Evidence references | Identity, protocol and allowlist references are nonempty at the selected revision; additional references are nonempty with no empty entry. Child route reference is at that revision and distinct from its identity reference. |
| Stale/conflicting evidence | `Current` false or `Conflict` true blocks readiness; current is a caller assertion, not a clock check. Collisions never select the first family. |
| Wrong scope or prohibited request | Preserve component precedence: explicit scope rejection yields `no-send` only at its scope check; incomplete evidence can withhold earlier. Gateway extended inventory, private functions, `TimedOut` or `QualificationStopped` remain `no-send`. |
| Unknown identity, documentary tuple, guard mismatch or invalid bounds | Preserve component withholding and original evaluator reason; an evaluator match alone cannot yield readiness. |

The cycle envelope must distinguish requested identity, terminal cycle status,
failure/cancellation reason and an optional detached component decision. The
labels below describe required controls, not existing exported constants:

| Cycle control | Meaning |
| --- | --- |
| Ready | Active, successful lookup, exact key agreement and component `planned`; documentary route readiness only. |
| Denied | Component `no-send`, with original decision/reasons intact. |
| Blocked | Invalid input, lookup failure, bounds/key failure or component `withheld`; distinguish these causes and retain a decision only when evaluation occurred. |
| Cancelled/deadline | No usable current result, even if lookup/evaluation finished; no retry or implicit retained-result substitution. |

`DefaultDenied()` on every component result remains true. Every cycle control,
including Ready and all failures, must likewise expose default denial. Never
fabricate a component outcome or evaluator reason for a pre-evaluation failure.
Identical inputs and callback outcome produce the same envelope and reasons,
given the same cancellation/deadline observations. No generated wall-clock
value, map iteration order or consumer-specific rewriting may change it.

## Ownership, age and replacement

The caller owns the supplied store and its historical retention. Lookup must
return a coherent snapshot; it must not mutate that store during evaluation.
Detach the callback plan and returned decision, including `Evidence.References`
and any future mutable fields. Mutating callback storage, a retained record or
one returned result must not rewrite another. No mutable backing store escapes.

The cycle does not acquire, refresh, persist or merge observations. Preserve
original provenance, revision, guards, validity and caller-retained age metadata;
the native types supply no age clock. Invocation time, lookup success and Ready
must never reset evidence age. Do not invent an age field on the current native
API. Keep partial last-known-good records under their original keys on failure
or cancellation, with explicit stale/unknown state rather than promoted status.

Changing any key association or guard invalidates affected readiness. A parent
identity/revision change invalidates dependent children; a shared inventory
guard change invalidates every dependent route. Independently valid gateway or
other-child evidence survives only when dependency independence is established.
Replacement requires a new complete invocation, never relabelling retained
child data with a new unit/revision. Historical envelopes remain immutable.
Consumer projections must disclose omitted native fields and preserve native
records separately, including reasons, loss and stale/unknown state.

## Synthetic acceptance examples

`G` and `C` mean complete conditional gateway and independently evidenced child
records satisfying the linked component contract, not real devices or a claim
that a qualified child exists. `rA`/`rB` are opaque synthetic revisions. Age
descriptions below are retained metadata, not capture times. Each row assumes
finite bounds and an active context unless stated otherwise. These are manual
acceptance examples, not executed tests or request recipes.

| Case | Required result and retention |
| --- | --- |
| Gateway success | One lookup returns exact G at rA with coherent allowlisted evidence; component `planned` becomes Ready. Original age/provenance remain; default denied. |
| Child success | One lookup returns exact C, including every parent field, qualification assertion and both guards; conditional Ready remains denied. G and C retain separate identities and ages. |
| Failure | Lookup error with an accompanying plan blocks without evaluation. Prior partial last-known-good G/C retain original age and validity; neither becomes current or admitted. |
| Cancellation | Cancellation before lookup means zero calls; cancellation after lookup dominates its error/plan. Cancellation during evaluation prevents Ready. Older records keep their age and denied admission. |
| Replacement | C moves from synthetic unit 7/rA to unit 8/rB while G stays equal. Returning old rA for the new request blocks before evaluation. Old data stay under unit 7/rA, stale with original age; only a complete new snapshot can become documentary Ready, still denied. |
| Key mismatch | Alter any top-level field, any parent selection field, child revision, qualification or either guard in returned key or evidence key: block before evaluation, even if that alternative plan would be valid alone. |
| Guard/conflict/stale | Exact request association but unequal guards, `Conflict` true or `Current` false yields component `withheld`; preserve reasons and age, never fallback. |
| Documentary denial | Gateway extended inventory, timeout/stopped qualification or private function preserves `no-send`; a documentary tuple stays withheld even if evaluator matched. Wrong scope follows the component's evidence-before-scope precedence. All remain default denied. |
| Invalid input | Nil callback or missing finite caller bound fails before lookup; no inferred bound, no fabricated component decision, no age refresh. |

## Remaining production acceptance

This contract can merge independently of a cycle implementation. Implementation
merge requires agreement with these behaviors and review of the actual API
signature, cancellation/error ordering, complete key comparisons, finite work,
detachment and synthetic transition coverage. No nonexistent cycle source is
cited as current evidence. Registration, concrete persistence, acquisition,
transport, live qualification and runtime freshness remain separate work.

Native trust/admission boundaries and G5 D1-D5/O8 remain intact. Future consumers
must preserve eBUS MCP compatibility and GraphQL parity for equivalent native
evidence, reasons, age/loss and stale state. This page implements no binding,
authorization gate or automatic admission.

This is a partial contract contribution referencing
[docs-modbus issue #215](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/215)
and [modbusreg issue #201](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/201);
it closes no provider parent. Manual source/claim/transition/example/link and
publication review is documentation evidence only. Full committed checks,
independent review, runtime and hardware acceptance remain separate; offline
evidence is not physical qualification.
