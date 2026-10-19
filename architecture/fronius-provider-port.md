# Fronius provider-port composition contract

This Helianthus application architecture proposal is released under
AGPL-3.0-only and complements the CC0 native contracts. Nothing is stable before
Helianthus 1.0.

## Authority and evidence boundary

Protocol facts require the public native
[qualification contract](../protocols/fronius/qualification-readiness-v1.md)
and [SunSpec flavor contract](../protocols/fronius/sunspec-float-v1.md) first.
Their exact applicability remains authoritative; referring to the Fronius
family here does not qualify additional family members.

The merged [offline cycle source](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/fronius_offline_provider.go)
provides `FroniusOfflineProvider.Run/View/Cancel`. The
[cycle contract](fronius-offline-provider-cycle.md) and
[retained component](fronius-retained-commit-implementation.md) explain its
native ownership boundary. Where the cycle page describes a proposed API, the
concrete source establishes only the existing cycle API, not this wrapper.

| Evidence class | Claim supported here | Independent acceptance |
| --- | --- | --- |
| Proven | Supplied merged source exposes the native request, reader, result and cycle types below; `Run` calls the reader at most once, checks cancellation before considering its result, checks exact attempt echo and sizes, then delegates to the retained owner | Source inspection only; no newly executed replay or runtime proof |
| Hypothesis | The I25 interface, configured adapter and lifecycle rules on this page are proposed requirements | Implementation and concurrent transition acceptance remain open |
| Unknown | Production composition, consumer parity, operational freshness policy, restart recovery and physical behavior | No qualification, support or integration acceptance |

This is an independent composition-layer contract. It consumes no I25 code,
unmerged sibling file or PR. Reconcile its final API spelling with I25 at code
merge. This companion can merge first and has no special merge hold. It is a
partial slice toward modbusreg issue #201 and Project #2; neither parent nor
common production Provider/gateway composition is completed here.

## Proposed typed port and configured adapter

The following is a proposed Go declaration surface in the consuming registry
package, over already merged native types. It is not an implementation or a
new common production Provider interface. All new declarations and methods use
the I25 prefix; existing native names are consumed unchanged.

```go
type I25FroniusProvider interface {
    I25Refresh(context.Context, FroniusOfflineRequest) (I25FroniusView, error)
    I25Cancel() (I25FroniusView, error)
    I25Retire() (I25FroniusView, error)
    I25View() I25FroniusView
}

type I25FroniusConfig struct {
    I25Registry       SunSpecDecoderRegistry
    I25Reader         FroniusOfflineReader
    I25MaxWords       uint32
    I25MaxOccurrences uint32
    I25MaxSourceViews uint32
}

type I25FroniusView struct {
    I25Lifetime uint64
    I25Retired  bool
    I25Busy     bool
    I25Eligible bool
    I25Native   FroniusRetainedView
}

func I25NewFroniusAdapter(I25FroniusConfig) (*I25FroniusAdapter, error)
```

`I25FroniusAdapter` is the concrete implementation of `I25FroniusProvider`.
It privately owns one zero-value `FroniusOfflineProvider`, the supplied registry,
reader, immutable ceilings and lifecycle synchronization. Do not copy an adapter
after use or expose its native owner for competing calls. Construction validates
configuration, creates no attempt and invokes the reader zero times. No default
registry, decoder, source, deadline or bounds are inferred. The supplied registry
must already be usable for the native card; its contents remain immutable for
the adapter lifetime. Clone supported mutable configuration at construction;
otherwise require exclusive immutable ownership rather than pretend a shallow
copy detaches mutable registry internals.

The adapter adds no scanner, parser, retained store or acquisition owner. Its
reader consumes supplied synthetic/public evidence through the existing chain
scanner and card path. Existing `FroniusOfflineReadRequest` carries
`Attempt`, `MaxWords`, `MaxOccurrences`, `MaxSourceViews`;
`FroniusOfflineReadResult` echoes that exact `Attempt` and carries
`SunSpecQualificationObservation`. `Run` remains the sole validation/commit
path. Neither the wrapper nor its callback may manufacture a positive verdict.

`I25Lifetime` is a nonzero adapter-local generation, distinct from
`FroniusRetainedToken`, poll generation, deadline identity and native chain
revision. It is not a globally unique identity: a handle also belongs to its
particular adapter instance. Retirement permanently invalidates that lifetime;
it never reactivates. A new adapter has a new instance identity and no inherited
envelope, even if numeric generations coincide. Refuse overflow rather than
reuse a lifetime. No method accepts an arbitrary caller token or targets
another adapter.

## Bounded calls, publication and refusal

| Input or resource | Required finite boundary and refusal |
| --- | --- |
| Configured registry and reader | Already supplied, immutable registry of finite size and nonnil offline reader; native card/schema compatibility required. Missing or unusable configuration refuses creation. No registry loading or plugin discovery. |
| Configured ceilings | Positive `I25MaxWords`, `I25MaxOccurrences`, `I25MaxSourceViews`; no overflow or implicit unlimited value. Respect the native card's total-word/occurrence ceilings and `MaxSunSpecPhaseOneChainWords` source-view ceiling used by `Run`. No larger protocol allowance. |
| Refresh request | Native `FroniusOfflineRequest`: exact `Key`, nonzero `PollGeneration` and `DeadlineIdentity`, positive `MaxWords`, `MaxOccurrences`, `MaxSourceViews` no greater than the configured ceilings and native limits. Never clamp, rewrite or silently replace a caller bound. |
| Context | Nonnil, active, future finite deadline. A derived cancellable context preserves that original deadline; never extend it or substitute background context. |
| Reader work | At most one synchronous callback per accepted refresh; zero retries, fallback, detached tasks or unbounded streams. Bound supplied record extents, aggregate words, occurrences, views, identity/diagnostic storage and scanner work before allocation/iteration. The reader must cooperate with cancellation; a deadline cannot interrupt arbitrary blocking code. |
| Native result | Exact attempt echo, complete observation, and sizes within the accepted bounds before native replay/cloning. Zero, partial, malformed, mismatched or extra-chain evidence cannot commit. |
| Concurrency and storage | At most one admitted refresh per adapter; concurrent refresh refuses busy without queueing or superseding. One native retained envelope, one current attempt, fixed lifecycle metadata; no growing history or retained arbitrary callback error strings. |

Apply configured-ceiling refusals inside an adapter-owned reader guard passed
to `Run`: it rejects before invoking the configured reader. Thus an otherwise
admitted refresh still reaches native `Begin` and its key fence even when a
request exceeds configured ceilings. Native invalid contexts, identities,
card inputs, zero bounds and native-limit excess already refuse before the
reader. Do not introduce wrapper preflight that bypasses the incompatible-key
invalidation rule. Busy and retired calls are lifecycle refusals: they are not
new native attempts and change no native key or history.

Register the cancellable refresh context under lifecycle synchronization before
entering `Run`. Cancellation or retirement during the interval before native
`Begin` must still prevent publication. Do not hold a lifecycle mutex across
the callback: `I25Cancel`, `I25Retire` and `I25View` must remain callable. After
reader-guard entry, record the supplied `Attempt.Token` under lifecycle
synchronization and recheck retirement/context before invoking the configured
reader. Cancellation also targets only that recorded active native token
through `Cancel`; the derived context covers the earlier interval. Keep busy
until `Run` returns, even after cancellation. A subsequent refresh cannot race
with delayed cleanup from its predecessor. Terminal cleanup must compare the
captured adapter instance/lifetime and attempt before clearing state.

Native publication and cancellation retain the existing owner's serialization.
If cancellation wins before commit, no candidate publishes; if commit wins,
later cancellation cannot relabel its success. Retirement marks the adapter
permanently retired and cancels its outstanding context before returning; it
does not wait for an uncooperative reader. A late completion cannot reactivate
the adapter. A commit that won the native race remains historical evidence,
but a retired adapter always reports `I25Eligible=false`.

`I25View` returns detached native current-attempt and retained-envelope data
together with a coherent lifecycle view. Synchronize/recheck across lifecycle
changes so it cannot label an active native attempt with another lifetime.
`I25Eligible` means only eligible offline history for this active adapter and
key; it does not assert freshness, qualification or runtime admission. Pending,
failed or cancelled same-key refreshes may expose eligible stale history.
Retirement withholds eligibility without mutating original native evidence.
Never rewrite the native `Stale`, `Outcome`, attempt or receipt to express a
wrapper state. Without history, eligibility is false.

Return errors distinguish configuration/input refusal, busy, retired,
cancellation/deadline, reader failure, native validation and inactive completion.
These are semantic categories, not a promised new error enum. Native `Run`
normalizes callback errors to `offline reader failed`; do not promise original
callback text or cause recovery. A method's returned view is current state,
not proof that its own attempt committed. Never retry a failed terminal call
against a different token. Repeated retirement succeeds idempotently;
cancellation with no pending attempt is a no-op, and cancellation after a
completed commit leaves success intact. Cancellation on a retired adapter
returns its retired view without starting work. Retired refreshes refuse forever.

## Synthetic transition review

These are manual acceptance scenarios, not executed tests. An I25-prefixed fake
reader supplies native observations from synthetic replay through the existing
scanner/card, performs zero network/device work, and echoes the exact attempt.
Let K be a complete compatibility key, E the first complete envelope, and C
its symbolic original receipt (`Envelope.Attempt` and `CommittedAt`); C is not
a published capture time. Run each loss case both with E and with no history.

| Event | Required result and original-receipt check |
| --- | --- |
| Create then view | Active, not busy, no native envelope or attempt; no reader call. |
| First successful K refresh | One callback, exact echoed attempt, complete replay; native owner publishes E atomically. No partial prefix is visible. |
| Same-key partial chain | Fake reader returns incomplete/error evidence or a zero observation; refresh fails, E remains stale with C unchanged. No missing words or terminal marker are invented. |
| Same-key failed chain | Fake reader returns an error with or without a candidate, or native replay rejects it; E remains stale with C unchanged. The candidate is never spliced into E. |
| Same-key successful replacement | A complete new observation replaces all of E with its own receipt; no old words, flavor or provenance are relabeled. |
| Cancel before callback or during read | Cancel the registered context; configured reader is invoked zero times if native preflight has already observed cancellation, otherwise at most once cooperatively. No candidate may publish after cancellation wins. E remains stale at C. |
| Cancel after reader return, before commit | A fully successful candidate still cannot commit if native cancellation wins. E remains at C; without E, absence remains absence. |
| Cancel after committed success | Completed envelope and native outcome remain unchanged; no false cancellation label. |
| Retire while idle or reading | Permanently retired, eligibility false; original E/C remain available as detached history. An in-flight reader may return late but cannot restore eligibility or restart work. |
| Late completion from retired lifetime | Cleanup cannot clear or populate another adapter's attempt or history. Native inactive token cannot publish; a prior winning commit is historical only. |
| Key change K to L, including invalid new bounds/context | Native Begin drops incompatible E even when the new attempt fails; returning to K does not resurrect it. Busy/retired refusal is not a key-change attempt. |
| Oversized request or result | No configured reader call for excessive request ceilings; oversized returned evidence fails before replay/cloning. Compatible E retains C; incompatible history is already fenced. |
| Concurrent refresh | Busy refusal; no second callback, native Begin or key change. Cancelled-but-still-returning readers keep the slot busy. |
| Detached view mutation | Mutating a returned observation or nested collection cannot alter subsequent views, current attempt or E/C. |

The cancellation-after-return and stale-completion rows require controlled
barriers in future synthetic code tests. A finite watchdog diagnoses hangs;
elapsed timing alone does not prove ordering or bounded cooperation.

## Identity and projection-loss review

Vary each field independently with all others held equal. The expected behavior
comes from the native key/attempt contract, not measurement equality. The last
column names a production mutation future tests must catch; these are reasoned
test mappings, not executed mutation kills.

| Axis | Required independent variant | Mutation the variant must reject |
| --- | --- | --- |
| `RequestedFunction` | Change only requested function: key fence drops E; mismatched replay cannot commit | Omit requested-function equality |
| `ReceivedFunction` | Change only received function: same fence/rejection | Compare only requested function |
| `Table` | Change only table: same fence/rejection | Omit table equality |
| `UnitID` | Change only unit: same fence/rejection | Omit unit equality |
| `Source` | Change only opaque source: same fence/rejection; never interpret as locator | Omit source equality |
| `ConnectionID` | Change only connection: same fence/rejection despite identical words | Omit connection equality |
| `Transport` | Change only transport family: same fence/rejection | Omit transport equality |
| `TransportGeneration` | Change only generation: same fence/rejection | Omit generation equality |
| `CardID` | Change only card: drop history and refuse incompatible exact card | Omit card identity check |
| `Schema` | Change only schema: drop history and refuse incompatible registry/card revision | Omit schema equality |
| `PollGeneration` | Change only echoed poll identity: refuse; E keeps its original poll identity | Omit poll equality or relabel retained attempt |
| `DeadlineIdentity` | Change only echoed deadline identity: refuse; E keeps its original deadline identity | Omit deadline-identity equality |
| `Deadline` | Change only echoed finite deadline: exact attempt comparison refuses | Compare attempt without deadline |
| `Token` | Substitute foreign-owner, closed and superseded tokens independently: no publication or newer-state change | Accept matching numeric identities instead of opaque token |
| Adapter instance / `I25Lifetime` | Retired instance or stale captured generation cannot operate on a replacement instance | Reuse lifetime or omit instance guard in cleanup |
| Native request identity | Independently alter plan, chain instance, sequence, purpose, exact address and quantity in supplied replay: native acquisition/replay must reject transplantation | Bypass the corresponding native request identity check |
| Native chain revision | Change decoder/chain schema revision alone: require authoritative native validation; do not alias it to adapter lifetime or invent a wrapper revision field | Accept different revision based on equal words |

The wrapper consumes native replay; it does not claim to expose planner request
fields in `FroniusOfflineRequest`. Native request/revision variants belong in
the fake reader's supplied replay and existing scanner checks. Missing source
details about those internal fields remain Unknown, not invented adapter APIs.

Keep the complete native observation: raw words, ordered occurrences, decoder
keys/opaque dispositions, source spans, logical-view provenance, capability,
flavor, unavailable sentinels and original receipt. Preserve zero, absence,
unknown, unsupported and stale as distinct states. A failed refresh retains
partial last-known-good availability: the complete original envelope plus the
new failed attempt, never partial new facts presented as success. There is no
persistent archive or restart guarantee. Local commit age is not operational
freshness or a device capture timestamp.

## Composition and remaining acceptance

Every row keeps `live_qualified=false`, `automatic_runtime_admission=false`
and `write_authority=false`. Production admission stays denied/`NO_GO`;
offline success supplies no new Fronius applicability or runtime admission.
No socket, device access, active acquisition, background scheduler, native
qualification, registration or gateway M02 registry is introduced. Existing
native authorization-scope provenance is preserved without a new authorization
gate.

Future composition must preserve eBUS MCP compatibility and MCP/GraphQL parity
for current attempt, retained evidence, absence, stale state, age, retirement
and errors. If a consumer cannot represent one of these, declare the projection
loss and withhold unsupported output; do not invent a shared success boolean.
G5 D1-D5/O8 are unchanged. eeBUS output remains in `helianthus-eebusreg`.

Independent implementation review, synthetic per-axis and controlled transition
execution, committed-head checks, production integration, consumer parity and
physical acceptance remain separate. This page claims only a proposed local
port contract and manual source/transition/identity/loss/example/link review.
