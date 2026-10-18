# S-Dongle route decision implementation boundary

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

The reviewed component in helianthus-modbusreg PR #308 is a pure, explicitly
called S-Dongle route decision for the Huawei provider family.
Nothing is stable before Helianthus 1.0.

| Evidence status | Reviewed boundary |
| --- | --- |
| Proven | The component produces a documentary `planned`, `no-send` or `withheld` decision, preserves original evaluator reasons and detached native evidence, and withholds the documentary tuple. |
| Hypothesis | Later composition can consume the detached record; scheduling, lifecycle and transport integration remain separate work. |
| Unknown | Actual child support, physical behavior and runtime freshness are not established. |

Qualification and runtime admission are separate axes; this component changes
neither and grants no runtime admission.

## Native authority

[S-Dongle provider routing](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/sdongle-provider-routing.md)
defines the routing decision boundary and retains the linked
[native gateway contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md)
as protocol authority, alongside the
[qualification disposition](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/sdongle-qualification-disposition-v1.md)
and its completed run's hard stop.
This application page establishes no additional protocol facts or qualified
devices.

## Reviewed API and implementation boundary

`DecideSDongleRoute(SDongleRoutePlan) SDongleRouteDecision` consumes a selected
key, an already-decoded gateway observation, caller-supplied evidence and
bounds, plus timeout and stopped-qualification indicators.
The observation is passed unchanged to the existing offline evaluator.

`SDongleRouteKey` includes routing family, exact native model and firmware,
independent protocol major/minor, explicit gateway or child role, unit, request
class, scope and opaque source revision.
The S-Dongle family is a routing class, including for a child, and does not
replace the selected device's native identity.
For a gateway the observation's native identity must equal the selected key;
for a child it must equal `Key.Child.Parent`, a complete gateway selection.
`Evidence.Key` must equal the whole key, including every parent field, child
evidence revision, separate qualification disposition and before/after guards.

Identity, protocol and allowlist references require nonempty references at the
key's revision; additional `References` must be nonempty with no empty entry.
A child also requires a route reference at that revision distinct from its
identity reference, independently supplied child identity, firmware, baseline,
unit and qualified-route assertions, and agreement of parent, child and selected
revision and of both guards with the evaluated gateway guard.
Gateway evidence alone cannot supply child routing evidence, and gateway
decisions require an empty child context.

`SDongleRouteBounds` requires a positive finite deadline no greater than
15 seconds, explicit `RetryBounded`, and positive page, object and byte limits.
Unsigned `MaxRetries` is a finite maximum; zero is valid only with
`RetryBounded`.
Child inventory limits cannot exceed 121 pages, 121 objects and 32768 bytes;
the deadline cap also applies conservatively to gateway decisions.
These documentary bounds grant no retry authority, cannot resume stopped
qualification and cannot authorize partial inventory success.

The result exposes `Outcome`, route `Reason`, original `EvaluatorReason`,
selected key, original observation, evidence and bounds, including on rejection.
Fields are values except `Evidence.References`, whose slice is copied; changing
an input or returned record cannot rewrite another result.

| Outcome | Reviewed meaning |
| --- | --- |
| `planned` | Complete coherent evidence fits a documentary request class; `DefaultDenied()` remains true. |
| `no-send` | Timeout, stopped qualification, private function, extended MEI at gateway role or unit 100, or a request outside the explicit scope mapping. |
| `withheld` | Evidence is incomplete, stale, contradictory, mismatched, documentary-only or outside required bounds. |

Known prohibitions are checked first; otherwise evaluator rejection and evidence
validation precede scope classification, and missing evidence cannot plan.
The evaluator's broader tuple catalog is unchanged; its original reason,
including `matched` for a withheld documentary tuple, remains intact.
An offline match cannot become qualification or runtime admission.
The component creates no fallback, inferred unit, scan or alternate family.

## Retained state and loss states

The component is stateless: callers retain historical last-known-good
observations under their original key and validity, and own partial acquisition
and retention.
It neither overwrites retained state nor merges partial observations into a new
qualification.

| Evidence condition | Retention and decision boundary |
| --- | --- |
| Absent or unknown | Missing evidence withholds a decision; actual child support and runtime freshness remain Unknown. |
| Current | `Current` is a caller assertion; the component has no clock or freshness acquisition mechanism. |
| Retained | Rejected results retain detached native evidence and the original evaluator reason; historical observations retain their original association and validity. |
| Stale or changed association | Stale assertions, conflicting candidates, missing evidence or changed associations withhold the decision; consumers must mark old evidence stale and re-evaluate when any key, source revision or guard changes. |

An immutable result cannot later become current through another read.
Source revision is neither firmware nor a software release.

## Synthetic verification

PR #308 reports focused synthetic coverage of 99 selected tests and subtests.
It reports that disposable controls rejected all 27 executed mutants, including
every scalar key field, gateway extended MEI, matched-as-admitted and
documentary-tuple widening.
These are synthetic proof of the reported component boundary, not device
qualification, acquisition, runtime admission or hardware acceptance.

## Boundaries and remaining acceptance

The component adds no executable bytes, transport, scheduling, profile
registration, admission or output binding, and no authentication or
authorization gate.
Existing trust and admission checks, eBUS MCP compatibility and GraphQL parity
are unchanged; future consumers must preserve equivalent native evidence,
reasons and stale state, with no consumer integration or parity implementation
claimed here.
The evaluator discrepancy remains separate work.

This is a partial implementation contribution referencing helianthus-modbusreg
issue #300; provider parent issue #201 stays open.
Runtime providers, independent review, full committed checks and physical
acceptance remain separate work; no hardware acceptance is claimed.
