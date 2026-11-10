# EMMA local provider-port composition contract

This Helianthus application architecture guidance is released under
AGPL-3.0-only. It complements the CC0 native contract without changing it.
Nothing is stable before Helianthus 1.0.

## Authority, evidence and scope

The [public Huawei native read-only contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md)
first owns native identity predicates, encoding, extents and family limits.
The [native qualification contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/qualification-readiness-v1.md)
owns missing qualification evidence. This page changes neither contract and
introduces no register mapping, capability inheritance or acquisition recipe.

This is the canonical provider-port page in `helianthus-docs-modbus`; the
registry owns implementation, not a second provider-port contract.

| Evidence status | Basis and boundary |
| --- | --- |
| Proven, source inspection | The public [provider source](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/emma_provider_port.go), [offline cycle](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/emma_offline_provider.go) and [identity transition](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/emma_identity_transaction.go) establish the signatures and lifecycle described here. Source inspection is not executed integration evidence. |
| Hypothesis | A future acquisition owner can supply validated native records, cooperative work accounting and a consistent logical clock through this family-local port. |
| Unknown | Live correlation, qualified optional inventory guards, acquisition boundedness, physical behavior and production integration remain unknown. |

The [existing cycle contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/emma-offline-provider-cycle.md)
provides earlier requirements; its proposed API language is not proof that
every requirement is implemented. The
[identity component boundary](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/emma-identity-transaction-implementation.md)
describes consumed native value transitions. Merged source defines the actual
port and cycle signatures. This layer adds no native identity evaluator.

This is a family-local supplied-evidence port, neither the common production
`Provider` interface nor a gateway registry. It creates no socket, device work,
background scheduler, retry, inventory sender or registration. Identity success
leaves qualification evidence blocked and admission default denied. Production
readiness remains NO_GO independently of retained identity evidence.

## Implemented typed surface and configuration

```go
type I19EmmaProviderPort interface {
    I19Refresh(context.Context, EmmaIdentityContext, bool) (EmmaIdentityResult, error)
    I19SetContext(EmmaIdentityContext) error
    I19Retire()
    I19Latest() EmmaIdentityResult
    I19Identity() (EmmaIdentityInput, bool)
    I19RetainedIdentity() (EmmaRetainedIdentity, bool)
}

type I19EmmaProviderConfig struct {
    I19Bounds EmmaOfflineBounds
    I19Reader EmmaOfflineIdentityReader
    I19Now func() time.Time
}

func I19NewEmmaProvider(current EmmaIdentityContext, config I19EmmaProviderConfig) (*I19EmmaProvider, error)
```

The concrete `I19EmmaProvider` implements this interface over one private
`EmmaOfflineProvider`. Construction refuses nil reader/clock, zero reader work,
nonpositive input-byte allowance or an initial context rejected by the native
transition at the supplied clock time. It calls the clock, not the reader.
Configuration is copied by value. Replacing caller configuration fields cannot
replace callbacks or widen bounds; captured closure state remains caller-owned.
Do not copy the provider after construction. Callbacks must be cooperative,
bounded and safe for the caller's concurrency. Returned reader buffers remain
unchanged until refresh returns.

`MaxInputBytes` counts the aggregate Offering, Model, Firmware, Request and
Response bytes. Oversized input is discarded as failed evidence, never
truncated into a valid tuple. A reader error marks input failed while retaining
in-bound diagnostic evidence. `MaxReaderWork` is passed unchanged to the reader;
this cooperative contract cannot forcibly bound arbitrary callback execution.

The former adapter name and constructor, explicit cancel method, caller epoch,
refresh wrapper and retained-view API were unsupported proposals. They are not
exports of the merged provider. Proposed context/error string ceilings, horizon
validation, nondecreasing clock enforcement, attempt-reuse rejection, overflow
refusal and a busy single-flight rule are also not implemented port guarantees.

## Lifecycle, cancellation and publication

1. **Refresh.** `I19Refresh` refuses a nil refresh context, nil/uninitialized or
   retired provider, and an expected context unequal to the active context
   before calling the reader. Equality covers ParentSource, SourceRevision,
   ConnectionGeneration, Attempt, Deadline and Cancelled. An accepted call
   delegates to the actual native `Cycle` with frozen bounds, reader and clock.
   Native preflight may still refuse with zero reader calls. An accepted native
   cycle calls the synchronous reader once outside the publication lock.
2. **Concurrent work.** The port has no busy reservation. Native cycle tickets
   fence superseded completions; concurrent callers may invoke cooperative
   readers concurrently. This is not a queued scheduler or a promise of
   single-flight execution. A stale refresh refused before delegation does not
   supersede unrelated work.
3. **Cancellation.** The wrapped clock calls the supplied clock, then samples
   `context.Context.Err()` at each native clock fence, including completion
   before commit. If the refresh sequence and expected context still match,
   cancellation sets the native current context's Cancelled flag. The native
   transition then rejects before matching. The sequence check prevents an old
   cancellation from cancelling a replacement context or later refresh.
   Cancellation cannot interrupt a blocked reader. Cancellation after the final
   sample is a subsequent event; it is not atomic with native commit and cannot
   undo an already committed observation. If the native call returns no error,
   cancellation is observed and the result is uncommitted, the port returns the
   context error alongside that result. Preserve both, rather than equating an
   error alone with the native reason.
4. **Replace context.** `I19SetContext(current)` serializes replacement and
   advances the private sequence. It does not validate replacement contexts or
   enforce increasing tokens. Callers must supply fresh attempt/connection
   tokens and never restore old contexts. Invalid contexts serve as fences;
   native preflight still refuses them. Parent replacement clears foreign
   history; same-parent revision/connection changes retain historical evidence
   with its original context and observation time. It returns an error for a
   nil, uninitialized or retired provider.
5. **Retire.** `I19Retire()` returns no value. It is terminal and idempotent,
   marks current context cancelled and forwards that fence to the native owner.
   Later refresh/context updates refuse. History survives; a callback may finish
   but cannot commit against the retired native context. Retirement after a
   commit does not erase that observation. A new lifetime requires a new port.

The native owner serializes commit against context changes. Its latest attempt
can contain a rejected same-parent completion after a context fence; the port
returns that native result rather than maintaining the old proposal's detached
pre-refresh publication cache. Never treat Latest's Committed flag alone as
current identity after lifecycle changes. Native cycle sequencing prevents an
older cycle from overwriting a newer cycle's result; the port's private sequence
is not an additional general publication fence.

## Identity, retained history and projection loss

`I19Latest()` returns the native latest-attempt `EmmaIdentityResult`.
`I19Identity()` returns `(EmmaIdentityInput, bool)`, not a result envelope. Its
boolean requires a committed latest attempt matching every active context field,
an unretired and uncancelled provider, and a nonzero supplied time strictly
before the current deadline. Deadline equality is expired. The getter calls the
clock but no reader. It does not enforce monotonic clock progression or prove
live freshness. A failed latest attempt makes current identity unavailable.

`I19RetainedIdentity()` returns `(EmmaRetainedIdentity, bool)` from the native
latest result, including after failure or retirement. History keeps its
originating Context, Input and ObservedAt. AttemptInput contains the separate
candidate, including partial or failed input; it never fills gaps in a retained
tuple. Native byte accessors return detached copies. Parent replacement clears
history instead of importing another parent's identity.

Preserve native Reason, FC03 evidence, MEIStatus, InventoryStatus, Committed,
InventoryAssociationInvalidated and retained history independently of Go errors.
MEI success cannot rescue missing FC03. Requested inventory is blocked and
incomplete; omitted inventory is not_requested. A valid replacement changing
offering, family variant, firmware, revision or connection preserves native
inventory-association invalidation without establishing inventory. Attempt or
deadline changes alone do not change native identity association.

A current-identity boolean loses failure reasons, raw evidence, diagnostic
status, inventory intent, association invalidation and age. Future MCP and
GraphQL projections must retain equivalent envelopes, explicit unknowns, reasons
and original age, and name projection loss. Existing eBUS MCP compatibility,
GraphQL parity and G5 D1-D5/O8 remain unchanged. eeBUS output remains owned by
`helianthus-eebusreg`. No consumer binding is implemented here.

## Supplied-evidence transition review

These are synthetic logical examples, not device observations or executed
runtime tests in this repository.

| Supplied event | Native result and retained-state boundary |
| --- | --- |
| Valid complete FC03, failed MEI, inventory requested | Identity may commit; MEI failure stays diagnostic; inventory blocked and incomplete; admission denied. |
| Later missing/failed FC03 or reader error, successful MEI | Current identity unavailable; prior same-parent identity retains its original observation time. |
| Complete native mismatch | Explicit mismatch; retained identity remains separately labelled history. |
| Oversized candidate | Failed evidence discarded rather than truncated; prior history survives. |
| Parent, revision, connection, attempt or deadline changes during reader | Native context rejection; parent change excludes foreign history. |
| Cancellation sampled at completion or retirement during reader | No match/commit against cancelled current context; retained age unchanged. |
| Cancellation only after final sample | No retroactive rollback; inspect returned committed result separately from later cancellation. |
| Newer native cycle supersedes old callback | Old result cannot overwrite newer cycle publication. |

Runtime acceptance must vary every context field independently, as well as
offering, family variant, firmware and each raw evidence buffer, and test the
named lifecycle fences against actual Cycle. The offline documentation guard
checks ownership, link integrity and the documented API; it makes no claim to
execute those runtime acceptance cases.

## Production acquisition boundary

Production acquisition over a supplied read-only session follows the native
[read pacing and production acquisition contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/read-pacing-v1.md)
and reads only the groups of the native
[monitoring contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/monitoring-readonly-v1.md). Both are
authoritative, and this section adds no protocol fact, read recipe, or wire
operation. The mapping onto this port is proposed acceptance (Hypothesis) for
the companion provider of
[modbusreg issue #349](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/349);
admission stays denied.

- **Cycle ordering.** One production refresh runs one native cycle: the EMMA's
  unit 0 groups once the native contract lists them as observed, then each
  listed and allowed inverter in ascending unit order. No guard exists, so the
  listing is read at creation and after each reconnect only.
- **Per-child isolation.** A failed inverter is withheld for that refresh only,
  and the gateway tuple and the sibling are unaffected. A failed listing
  re-read withholds every child for that refresh.
- **Retention and loss.** Each group keeps its last complete reading with its
  original age. The refused power group, the undecoded battery group, the
  planned site groups before observation, and every meter value are named
  losses and are never projected as zero, empty, or false.
- **Refusal signature.** A refresh in which every request ends with a reset or
  close after the write ends as insufficient evidence and backs off; it never
  scans or falls back.


## Acceptance boundary

Source inspection establishes the API correspondence above. Offline link and
ownership checks establish documentary consistency only. Independent review,
committed-head CI, public publication checks, production composition, qualified
acquisition and physical acceptance remain separate obligations. No transport,
smoke, native conformance or hardware PASS follows from this page.
