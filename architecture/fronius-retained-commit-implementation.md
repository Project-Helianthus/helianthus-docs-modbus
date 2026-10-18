# Fronius retained commit implementation

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page describes the reviewed in-memory Fronius provider-family boundary in modbusreg PR #311, rather than the full proposed provider lifecycle.
Nothing is stable before Helianthus 1.0.

| Evidence status | Meaning here |
| --- | --- |
| Proven | The reviewed component provides an explicitly called Begin/Commit/Fail/Cancel boundary and detached atomic views; reported synthetic checks cover retained evidence and identity guards. |
| Hypothesis | Later composition can call the API and project identical retained envelopes through MCP and GraphQL; integration and consumer parity acceptance are not established. |
| Unknown | Device behavior, operational age policy, restart recovery and downstream projection behavior are not established. |

Qualification and admission are separate axes that this component does not change: offline replay provides no new live qualification, automatic runtime admission or write authority.

## Native authority

The [canonical Fronius provider commit contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/fronius-provider-commit.md) supplies the lifecycle authority and links the CC0 native contracts that own protocol facts and exact applicability.
The reviewed component implements the bounded in-memory portion of that contract; existing qualification-card bounds and exact applicability remain unchanged.

## Reviewed API and implementation boundary

`FroniusRetainedCommit` owns one eligible complete envelope and one latest-attempt diagnostic enum, with no persistent history.
Its zero value is usable, and the store must not be copied after use; callers must keep supplied inputs immutable during a method call.

`Begin(ctx, key, pollGeneration, deadlineIdentity)` supersedes the previous attempt and returns an opaque store-local token.
The caller supplies a context with a future finite deadline and nonzero poll and deadline identities.
`FroniusRetainedKey` binds requested function, received function, table, unit, opaque source identity, connection identity, transport family, transport generation, card identity and schema revision.
Unknown source, connection, generation or card/schema identity fails closed.

`Commit(token, registry, observation)` takes an existing `SunSpecQualificationObservation`, obtains its replay and calls the existing exact card's `Qualify`; it accepts no caller success flag.
Replay must produce the same complete observation, and every source view must agree with the active key and poll/deadline identity.
Validation and publication serialize with Begin, Fail, Cancel and View, and the context is checked again after replay before publication.
A successful commit closes the token and atomically replaces the envelope.

`Fail(token)` closes an active attempt as `failed`, while `Cancel(token)` closes it as `cancelled`; invalid active candidates also close as failed.
Foreign, superseded or already closed tokens return errors without changing a newer attempt.
Context cancellation or expiry is observed at the next operation, with no background task; a cancelled or expired active attempt cannot commit.
If explicit Cancel wins against Commit, publication is rejected; if Commit wins, its completed envelope remains history.

`View()` atomically returns a detached `FroniusRetainedView` containing the envelope, latest attempt, outcome and stale flag.
The latest attempt can differ from `Envelope.Attempt`, which retains the observation's original attempt provenance.

## Retained state and loss states

| State or loss condition | Reviewed meaning |
| --- | --- |
| Absent | The envelope is nil before the first complete success; absence is never zero measurements. |
| Latest-attempt success | A complete exact-card observation has committed; fresh means latest-attempt success only, not operational freshness. |
| Retained stale | Starting another same-key attempt marks the previous envelope stale; failure or cancellation retains its original attempt, commit age, raw words, ordered occurrences, source spans, capability and flavor unchanged. |
| Invalidated by key change | A key change immediately drops the prior envelope even if Begin is invalid; returning to the earlier key cannot reactivate it. |
| Unknown compatibility | Unknown source, connection, generation or card/schema identity fails closed. |

`CommittedAt` is a local commit instant, not a capture time or freshness policy; callers may apply a stricter age policy.
For a synthetic cycle A followed by same-key cycle B that fails, View reports B and `failed` with `Stale=true`, while the retained envelope still carries A; without a prior complete success, no envelope is returned.
Persistent history and restart recovery are not established by this boundary.

## Synthetic verification

The PR reports synthetic checks that independently vary every compatibility-key field, the cycle token, poll identity and deadline identity, with 16 disposable mutants failing assertions.
Its API documentation reports controls for complete replacement, partial and zero-value rejection, stale age preservation, detached inputs and views, mixed native source views, finite deadlines, foreign tokens and cancellation/commit ordering.
These are reported synthetic proof of the offline boundary, not qualification or hardware acceptance.

## Boundaries and remaining acceptance

The component adds no acquisition, planning, flavor selection, polling, transport registration, discovery, semantic promotion or gateway integration.
It preserves native authorization-scope provenance without adding an authentication, authorization, principal or permission check.
Existing eBUS MCP behavior is untouched; later integration must preserve MCP and GraphQL parity and make projection loss explicit, while eeBUS binding remains with its driver owner.
The implementation is a partial slice: modbusreg issue #201 remains open, with hardware, transport, integration, independent review and committed-head gates remaining acceptance work.
No hardware qualification or consumer parity acceptance is claimed; device behavior, operational age policy, restart recovery and downstream projection behavior remain Unknown.
