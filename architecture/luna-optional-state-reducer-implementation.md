# LUNA optional-group state reducer implementation

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page describes the reviewed documentary-observation reducer in
helianthus-modbusreg for the Huawei LUNA2000 optional battery family and its
independently identified SUN2000 parent.

| Evidence status | Basis and boundary |
| --- | --- |
| Proven | The reviewed component reduces supplied documentary observations, retains bounded history and preserves profile denial; this is a source-level implementation boundary, not proof of battery behavior. |
| Hypothesis | Applying these retention decisions in downstream composition remains design intent; runtime integration is not established. |
| Unknown | Native battery presence/absence encoding, register applicability, monitoring values, scales and live behavior are not established. |

Evidence status, qualification and admission are separate axes; this component
does not change qualification or admission.
Nothing is stable before Helianthus 1.0.

## Native authority

The public [native optional-group contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/luna2000-optional-group-v1.md)
is the authority this application guidance complements, without revising its
denied profile disposition.

## Reviewed API and implementation boundary

`ReduceLunaOptionalState(prior LunaOptionalState, in LunaOptionalInput) LunaOptionalState`
is an explicitly called pure reducer of caller-supplied documentary observations.
Its zero state is `unknown`.

`LunaOptionalBinding` carries exact parent and group model, firmware and unit
identity tokens, an explicit attachment relation, separate parent and group
epochs, and an evidence revision identifying the public source/version and
applicability contract.
Identity comes from supplied identity evidence; inventory labels, aliases and
routing addresses cannot establish it.
`ParentIdentified` reports independent documentary parent identification, while
`EpochsAssociated` asserts an explicitly established coherent association;
equal epoch strings alone do not establish that association.
`Binding` is the caller's current association, while `ObservationParentEpoch`
and `ObservationGroupEpoch` retain the observation's originating association.

`Evidence` supplies bounded references, native outcome descriptions and original
`ObservedAt` ticks; references are not dereferenced by this component.
Raw native evidence remains with its supplying owner; the reducer provides no
payload decoder, schema normalization, universal projection or battery
monitoring values.

Every evaluation requires a finite positive `LunaOptionalPolicy` and explicit
time on one caller-defined nonnegative monotonic tick basis, with
`Started <= Now < Deadline`.

| Caller policy field | Bound |
| --- | --- |
| `MaxRecords` | Evidence references in this evaluation |
| `MaxBytes` | Aggregate charged evidence bytes, including the complete binding per reference; also bounds a retained current binding |
| `Deadline` | Exclusive absolute deadline for evaluation/completion time |
| `FreshnessAge` | Inclusive maximum age of each historical record |
| `RetentionAge` | Inclusive maximum age before eviction |
| `HistoryRecords` | Retained historical record count |
| `HistoryBytes` | Charged bytes retained in history |

These are logical evidence bounds, not a heap accounting guarantee, CPU-time
measurement or retry authorization; no device-derived defaults are supplied.
The result exposes read-only accessors, and `History()` returns a detached slice;
editing input slices cannot mutate prior results.

## Retained state and loss states

Each historical record retains its original binding, event, evidence reference,
native outcome and observation time.
`Applicable` means only that the partition has not been fenced and still matches
the current binding; `Fresh` measures only the record's age, and neither means
qualification or a current battery value.

Retired observation epochs are rejected before binding or event interpretation,
allowing only age-based history maintenance.
A change to exact parent/group identity, attachment, either epoch or evidence
revision fences history before event interpretation and yields `identity changed`.
Fenced records cannot become applicable again, even if old identity tokens recur.
Missing identity or incoherent association yields `unknown` and fences history.

| Input after binding checks | Observation state and loss boundary |
| --- | --- |
| Documentary presence with valid bounded references | `present-unqualified`; a subsequent valid presence can start this state under a new partition after identity change |
| Inventory-only or missing observation | `unknown`; missing is never absent |
| Optional failure, malformed evidence or invalid evaluation after established presence | `temporarily unreadable`; independently identified parent evidence survives |
| Same failure without established presence | `unknown` |
| Unknown event, including attempted absence or qualified events | `unknown`; no new evidence accepted |
| Age expiry alone | Observation label persists; records become stale or are evicted |

Failures retain successful-record ages and may add separately timed failure
records only when valid and within bounds; there is no whole-group age refresh.
Missing or invalid policy ages and retains history under the last accepted
policy without extending it.
Future-dated records, empty references/outcomes, over-budget input and expired
deadlines cannot refresh history.
Eviction considers newest inserted records first within count, byte and age
bounds, returning retained records in insertion order; evicted evidence cannot
be reconstructed or revived by a later policy.

Every outcome remains `NO_ADMISSIBLE_PROFILE`, with catalog registration,
automatic runtime admission, qualification, support claim and write authority
false.
There are no absence or qualified event constants, and caller booleans cannot
enable those transitions.

## Synthetic verification

The companion change reports synthetic tests and detached mutation controls;
these are synthetic proof of reducer decisions only, not qualification.
Unknown: mutation-testing execution results and a mutation score are not reported.
The reported tests establish no transport conformance, passive capture evidence,
hardware qualification, device acceptance or runtime integration.

## Boundaries and remaining acceptance

The reducer adds no acquisition, native presence decoder, registration,
scheduling, transport, gateway integration, decoding or numerical battery
telemetry.
Existing trust and admission boundaries remain in place; the API introduces no
authentication or authorization gate.
Existing eBUS MCP and GraphQL surfaces are untouched; downstream composition
must separately preserve their parity, native provenance, partial last-known-good
semantics and explicit projection loss.
The driver-owned eeBUS output binding remains unchanged.
Future per-field numerical monitoring requires its own accepted native contract
and implementation.

This is a partial contribution associated with modbusreg issue #199 and Project 2;
the parent remains open, and reducer verification does not complete parent
acceptance.
No hardware acceptance is claimed.
