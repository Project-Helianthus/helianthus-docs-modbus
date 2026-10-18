# Fronius offline provider cycle

This Helianthus application contract is released under AGPL-3.0-only. It
complements the CC0 native contracts. Nothing is stable before Helianthus 1.0.

## Authority and evidence status

Protocol facts and exact applicability belong to the canonical native
[qualification-readiness contract](../protocols/fronius/qualification-readiness-v1.md)
and [SunSpec flavor contract](../protocols/fronius/sunspec-float-v1.md).
This page adds no protocol facts, applicability expansion or live-read recipe.

The [provider commit contract](fronius-provider-commit.md) defines the wider
application lifecycle. The merged ZD
[retained commit component page](fronius-retained-commit-implementation.md)
describes the existing in-memory component used here. Those are distinct
authorities: native contracts own protocol acceptance; the component owns
retained state, token fencing and detached views.

| Evidence class | Scope here | Separate qualification and admission state |
| --- | --- | --- |
| Proven | The merged component exposes `FroniusRetainedCommit` and the native input/result names described below; source inspection supports these component claims | No new replay execution or live qualification is claimed |
| Hypothesis | All cycle composition, callback ordering and work-budget requirements below are proposed acceptance behavior; no exact new exported API signature is established | Offline success grants no automatic runtime admission or write authority |
| Unknown | Production cycle implementation, integration, operational age policy, persistence, restart recovery and consumer parity | No device support or physical acceptance follows |

This contract can merge before its code companion. It does not depend on that
companion's output. Code merge requires reviewed agreement on behavior and the
eventual signature; this page is not evidence that a cycle implementation exists.

## Existing inputs, results and owner

The cycle is a family-local offline application seam over supplied native
records. It composes one existing `FroniusRetainedCommit`, an injected reader
returning `SunSpecQualificationObservation` plus an error, and the existing
`SunSpecDecoderRegistry`. The reader consumes bounded supplied evidence through
the existing native decoder/card path. It opens no transport and owns no
acquisition, polling or retry loop. There is no second parser or retained store.

Existing component methods are `Begin(ctx, key, pollGeneration,
deadlineIdentity)`, `Commit(token, registry, observation)`, `Fail(token)`,
`Cancel(token)` and `View()`. Their existing argument names describe component
calls, not a proposed exported cycle signature. The native types are:

| Type | Role |
| --- | --- |
| `FroniusRetainedKey` | Compatibility key for eligible retained evidence |
| `FroniusRetainedToken` | Opaque, store-local, single-use attempt token |
| `FroniusRetainedAttempt` | Key, token, poll/deadline identities and original finite deadline |
| `SunSpecQualificationObservation` | Complete exact-card native result, never a partial success flag |
| `FroniusRetainedEnvelope` | Observation, original attempt and `CommittedAt` |
| `FroniusRetainedView` | Detached envelope or absence, latest attempt, outcome and `Stale` |

The caller retains the same owner across cycles and does not copy it after use.
Inputs remain immutable during calls; callback results must be immutable during
validation. `View()` supplies the detached result boundary. Native raw words,
occurrence order, decoder keys/opaque dispositions, source spans, capability,
flavor and provenance remain with the observation. No field projection or
semantic promotion is introduced; unavailable evidence never becomes zero.

## Finite work and callback preconditions

Before callback invocation require a nonnil owner, nonnil callback, usable
decoder registry, explicit exact-card key and nonzero poll/deadline identities.
Require a nonnil, active caller context with a future finite deadline, plus
explicit finite input and work ceilings. No background context substitution,
deadline extension or inferred compatibility is permitted.

The ceilings must bound supplied record count, total words, per-record extent,
occurrence count, identity/diagnostic sizes and validation/reader work. They
must remain within the canonical native card's limits; this contract introduces
no larger protocol allowance. Reject missing, zero, overflowing or incompatible
ceilings and oversized supplied input before callback work. Check ceilings
before copying or iterating input. Native validation remains authoritative even
when input is within a size ceiling.

Invoke the callback at most once, only after successful `Begin`, with that
attempt's exact `FroniusRetainedKey`, opaque token, poll/deadline identities,
original caller context and accepted bounds. The callback cannot choose a new
key, renew the deadline, mint a token or commit on its own. It must honor context
cancellation and finite work limits; a deadline cannot forcibly terminate an
arbitrary blocking callback. Production acceptance must demonstrate bounded
cooperative completion, without detached work surviving cancellation. No
automatic retry, fallback, scan or unbounded input stream is allowed.

Invalid input invokes the callback zero times. Once a nonnil owner and intended
key are available, apply the existing `Begin` key fence before returning a
preflight failure: changed keys drop incompatible history even if context or
other input is invalid. If `Begin` succeeds but another precondition fails,
close that token with `Fail`, or `Cancel` when its context has ended. Do not
leave a pending attempt or return the old key's envelope as eligible. A nil
owner cannot expose retained state and returns an input error. The final API
must make this preflight ordering explicit without weakening component guards.

## Cycle ordering and outcomes

The following is proposed composition over the merged component, not new
component behavior. Callback execution holds no component lock; final methods
serialize publication and token invalidation inside the existing owner.

| Order / event | Required action and observable result |
| --- | --- |
| Begin | Validate/fence as above, call `Begin` once; on error stop without callback. A successful begin supersedes any older token and records `pending`. Same-key history is stale while pending. |
| Read | Invoke the bound offline callback once. No prefix is published. After return check caller cancellation/expiry before interpreting the callback result. |
| Cancellation or deadline first | Call `Cancel(token)`; publish no candidate, even if callback returned a complete observation. Component expiry can already have closed it as `cancelled`. Return cancellation/deadline error with a detached view. |
| Callback error, context still active | Call `Fail(token)` and return the error with a detached view. If both observation and error are returned, discard candidate eligibility; the observation cannot commit. Do not retain arbitrary callback error text in the owner. |
| Callback success | Call `Commit(token, registry, observation)`; no caller success flag bypasses replay. Zero, partial, rejected or mismatched observations fail native exact-card validation and cannot replace history. |
| Commit error | Return the error and current detached view; do not retry or issue another terminal action that could hide the original result. Active invalid candidates close as `failed`; expiry closes as `cancelled`; an inactive token cannot change a newer attempt. |
| Commit success | Token closes as `succeeded`; one complete envelope atomically replaces compatible history with its own attempt and local commit instant. Return `View()`. |
| Supersession during callback | The old callback may finish, but its Commit/Fail/Cancel cannot change the newer attempt. Report inactive/superseded completion; never retry it against the newer token. |

Cancellation observed after a callback error takes precedence for closing the
attempt. A race after that check is resolved by the component's active-token
and context checks. If cancellation/invalidation wins before publication, no
commit occurs. If commit wins first, its completed envelope remains history;
later cancellation cannot relabel that success. Return errors must distinguish
input, callback, cancellation/deadline, native validation and inactive-token
failure without claiming a new stable error enum. A returned `View()` is an
atomic current view, potentially of a newer cycle; it is not guaranteed to
describe the callback that just returned. Preserve that distinction in results.

## Identity, retention and loss review

Every field below is an independent acceptance axis. Equality of measurements
or all other fields never compensates for one incompatible field.

| Axis | Required review case |
| --- | --- |
| `RequestedFunction` | Change it alone: Begin drops history; a mismatched source view cannot commit. |
| `ReceivedFunction` | Change it alone, even with unchanged requested function: same fence/rejection. |
| `Table` | Change it alone: same fence/rejection. |
| `UnitID` | Change it alone: same fence/rejection. |
| `Source` | Change the opaque identity alone: same fence/rejection; never interpret it as a locator. |
| `ConnectionID` | Change it alone: same fence/rejection, even with identical words. |
| `Transport` | Change the transport family alone: same fence/rejection. |
| `TransportGeneration` | Change it alone: same fence/rejection, including reconnection with equal values. |
| `CardID` | Change it alone: history drops; Commit still requires the existing exact card. |
| `Schema` | Change it alone: history drops; Commit still requires the exact card schema. |
| `PollGeneration` | New attempts retain old envelope provenance; any mismatched candidate source view is rejected. |
| `DeadlineIdentity` | New attempts retain old envelope provenance; any mismatched candidate source view is rejected. |
| Opaque token | Foreign-owner, superseded and closed tokens cannot publish or close a newer attempt. Matching numeric identities do not make tokens interchangeable. |
| Exact-card fixture | Complete native replay and equality with the supplied observation are required; generic capability alone, altered exact applicability, missing terminal evidence or extra views cannot pass. |

`Begin` irreversibly drops incompatible history, including on invalid new
context. Returning to an earlier key cannot restore it. With a compatible key,
failure, cancellation and pending refresh preserve the entire original envelope
and set `Stale=true`. `Envelope.Attempt` and `CommittedAt` remain original;
the latest `View.Attempt`/`Outcome` describe the refresh. `CommittedAt` is local
commit age, not a device capture timestamp. Success means latest-attempt success,
not an operational age guarantee. Without prior success the envelope stays
absent. There is no persistent archive or restart guarantee.

## Synthetic acceptance examples

These are symbolic manual review cases, not executed runtime tests or public
device fixtures. Let key K bind all compatibility axes, token A commit complete
exact-card observation E with original poll/deadline identities and local age C.
Every row retains `live_qualified=false`, `automatic_runtime_admission=false`
and `write_authority=false`, including a successful replacement.

| Case | Required retained result |
| --- | --- |
| Initial complete success | A commits E; envelope age C begins at that commit, with A's native provenance intact. |
| Same-key partial/rejected refresh B | Callback error, incomplete/zero result or exact-card rejection closes B without replacing E; E remains stale with A's identities and age C, never B's age. |
| Same-key cancellation B | Cancel wins before publication; even a late complete callback result cannot replace E. E remains stale with A and age C. Without E, absence remains absence. |
| Same-key supersession B by D | B's late completion cannot affect D; before D succeeds E remains stale at age C. A successful D replaces E wholly with D's evidence and new local age. |
| Key replacement K to L | Changing any single compatibility axis drops E immediately, even if L has identical measurements or an invalid context. Failure/cancellation for L leaves absence; returning to K still leaves absence until a new complete commit. |
| Successful same-key replacement B | Complete coherent exact-card result replaces E atomically with B's own envelope and commit age; no prefix, old words or old flavor is spliced into B. |
| Invalid callback/bounds | Callback is never invoked; the key fence still removes incompatible history. Compatible E remains stale with age C after the failed attempt. |

Review each source-view identity axis independently against the exact-card
fixture, and review partial, rejected, cancel, supersession and key-change
transitions with both prior success and absence. These are acceptance
obligations, not executed mutation kills or qualification evidence.

## Remaining production work and integration boundary

Implement and review the family-local cycle signature, preflight/key-fence
ordering, bounded callback contract, error ordering, race controls and synthetic
per-axis tests against this contract. Reuse the merged component; no global
provider API, gateway import, transport adapter, acquisition owner or automatic
admission belongs here. Future gateway Provider registry M02 is a separate
composition concern; this seam does not replace it. Concrete persistence and
live qualification remain outside this slice.

Later consumer integration must preserve MCP/GraphQL parity for absence, stale
history, age, failure and native evidence; any projection loss must be explicit.
Existing eBUS MCP compatibility, native trust/admission and G5 D1-D5/O8 remain
requirements, with no gateway wiring changed here. eeBUS output remains
driver-owned. Existing native provenance is preserved without introducing new
authentication or authorization checks.

This is a partial Project #2 contract slice. Full production behavior, consumer
parity, committed-head checks, independent review, transport and physical
qualification remain separate acceptance work. Offline evidence grants no
installation access or control authority.
