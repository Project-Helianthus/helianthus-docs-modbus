# S-Dongle provider routing proposal

This application architecture proposal is released under AGPL-3.0-only. It
does not change the CC0 native protocol contract. All interfaces and transitions
below are future work; nothing is stable before Helianthus 1.0. This page
specifies a transport-free decision record, not an implemented provider.

## Current evidence and authority

The [native gateway contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md)
defines the protocol facts first: logical gateway unit 100 permits candidate
basic MEI and its listed read-only FC03 gateway observations. Extended MEI is
restricted to a separately qualified child unit in 1 through 247. It never
becomes a gateway probe. SmartLogger, S-Dongle and EMMA remain separate families;
they cannot substitute for one another or resolve a collision by first match.

The [qualification disposition](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/sdongle-qualification-disposition-v1.md)
records insufficient evidence and a hard stop, not successful identification.
Its completed qualification cannot be resumed by this proposal. A future
qualification needs fresh bounded read-only evidence under that disposition.

The [offline observation evaluator](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/huawei_sdongle_observation.go)
checks already-decoded observations without transport and always returns a
default-denied result. Its input checks include unit, exact model/firmware,
protocol baseline, completed search, equal before/after sequence and capacity.
An offline match proves only acceptance by that evaluator, never qualification
or runtime admission.

There is a current source discrepancy: the evaluator also accepts the exact
tuple which the native contract and qualification disposition keep documentary
and default denied. Keep those exact tuple sets distinct as defined by the
linked sources; do not union them, infer a newer-compatible range, or broaden
an exact model discriminator into a family claim. This proposal conservatively
withholds that documentary tuple even if an evaluator reports a match. Resolving
the discrepancy is separate work. Exact discriminators remain native evidence;
family names in this page are routing classes, not new admitted model lists.

| Evidence status | Meaning here | Qualification and admission |
| --- | --- | --- |
| Proven | The cited contracts establish the gateway/child boundary and the evaluator's transport-free, default-denied behavior | No successful device qualification or runtime admission follows |
| Hypothesis | The proposed plan, decision and invalidation rules can support a future provider | No implementation or operational validation yet |
| Unknown | Actual child route, child request support, missing identity/firmware, or unresolved conflicting evidence | Withhold selection; do not discover missing facts by sending |

## Proposed input plan

One immutable input describes one candidate request decision. No input contains
a socket, connection recipe, credential, principal or permission check. This
proposal adds no authentication or authorization gate to the 0.7 work.

| Field | Required meaning and rejection boundary |
| --- | --- |
| Selected candidate identity | Explicit family, native exact model/product discriminator and exact firmware, plus the offline evidence disposition. Missing, documentary-only or conflicting identity cannot select a route. Preserve native fields rather than replacing them with the family label. |
| Protocol baseline | Independently decoded baseline required by the native contract. A firmware match cannot supply a missing baseline. |
| Role | Exactly `gateway` or `child`; never inferred from a readable unit or a request response. |
| Unit | Gateway is logical 100. Child is an explicitly evidenced unit in 1 through 247, distinct from gateway 100 for this proposal. Numeric overlap cannot authorize gateway extended MEI; ambiguous role/unit evidence is withheld. |
| Allowed request family | One explicit basic-MEI, documented read-only gateway-FC03, or separately evidenced child-read family. Include the exact documented request scope and finite bounds as evidence references, not executable bytes. No wildcard read, inferred range or private function code. |
| Source revision | Immutable opaque evidence revision, not a software version or a substitute for native identity. All identity, protocol, allowlist and route evidence must refer to a coherent revision. A changed or unresolved revision invalidates the old selection. |
| Child routing context | For a child only: parent selection, child native model/product identity, routing unit, child evidence revision, separate qualification disposition, and inventory guard. Gateway evidence alone cannot fill these fields. |
| Evidence bounds | Explicit read-only allowlist, finite deadline, retry bound and applicable inventory limits from the native contract. Missing bounds withhold a plan. This page grants no retries to an already stopped qualification. |

The proposed selection key includes family, exact native identity and firmware,
protocol baseline, role, unit, request scope and source revision. A child key
also includes its parent selection and child routing context. ESN alone is not
a stable child key. Changed guards or revisions cannot be hidden behind an
unchanged gateway identity.

## Proposed decision result and transitions

The result records the complete selection key, evaluated source revision,
evidence references, reason, and one outcome below. Preserve deterministic
field meanings and reasons across consumers. Evaluate all conflicts before
producing `planned`; missing or contradictory evidence dominates a possible
match. The same input evidence must give the same result.

| Outcome | Meaning | Transport effect |
| --- | --- | --- |
| `planned` | A hypothetical read fits the proposed role, evidence and allowlist constraints | None; it remains default denied and is not runtime admission |
| `no-send` | A known prohibited request or stopped qualification: gateway extended MEI, private functions, fallback after timeout, or a request outside its explicit allowlist | None; no alternate request is synthesized |
| `withheld` | Required evidence is missing, stale, unknown, inconsistent or colliding | None; no partial admission or acquisition plan for an alternative candidate |

These are proposed documentary outcomes, not new values on the current
evaluator API. Evaluator reasons remain intact alongside the proposed reason;
do not translate `matched` to `planned` without the independent evidence checks.
`planned` cannot transition to execution in this contract. Future runtime
admission, provider scheduling and transport integration require separate work.

A gateway timeout records the failure and stops the affected run. It cannot
transition to child scanning, an inferred child unit, another family's route,
an extended-MEI fallback or an automatic retry. Unknown firmware, malformed
observations, inconsistent inventory or exhausted bounds likewise cannot
produce a partial profile. Existing qualified evidence is not created by a
failure or by retaining an older observation.

## Proposed retention and invalidation

Retain native observations, evaluator reasons, source revisions, guard evidence
and their prior association as historical last-known-good data. Retention does
not make data current or permit new acquisition. A semantic projection must
identify any omitted native fields and stale/unknown state; keep the native
evidence separately rather than overwriting it with a projected family label.

| Change while gateway identity stays equal | Retain | Invalidate and require before a new plan |
| --- | --- | --- |
| Child routing unit changes | Old child observation under its old key, marked stale; independently valid gateway observations | Old child selection and all pending decisions referencing it. Require fresh, separately qualified route, child identity and coherent revision; never relabel old data with the new unit. |
| Child identity, parent relation or source revision changes | Historical evidence and reason for replacement | Child key, cached match, request allowlist association and derived current child projections. Re-evaluate the complete child context. |
| Guard changes, search becomes incomplete, capacity reconciliation fails, or inventory becomes unstable | Partial last-known-good observations with their original provenance and validity | Decisions depending on that inventory, including other children sharing its guard. No partial inventory success; require coherent bounded evidence again. |
| Only one independent child route is invalidated, with no shared guard change | Gateway and other children's evidence whose dependencies remain demonstrably valid | Affected child only. If dependency independence cannot be established, withhold all dependent child plans. |
| Gateway identity, baseline or governing source revision changes | Old gateway/child evidence as historical records | All dependent child selections as well as affected gateway selections. Rebuild evidence; no inherited admission. |

In-flight decision records are immutable and become stale, not rewritten. A
future executor would need its own freshness contract; this page supplies no
executor. A later good observation cannot retroactively turn a stopped run or
an old `no-send`/`withheld` result into success.

## Synthetic contract examples

Labels `G`, `C`, `rA` and `rB` below are synthetic references, not device
identifiers. `G` means one complete exact tuple in the native contract's offline
candidate set with its independent baseline and consistent status/guard/capacity
evidence. `C` means separately evidenced child identity and route, never inferred
from `G`. These conditional examples assert no actual qualified child exists.
Each row is a manual contract example, not a runtime test or wire recipe.

| Case | Input difference / evidence | Proposed outcome and reason |
| --- | --- | --- |
| Gateway basic MEI | G, gateway, unit 100, explicitly allowlisted basic MEI, coherent rA and bounded evidence | `planned`; documentary plan only, default denied |
| Gateway FC03 | G, gateway, unit 100, one of the native contract's listed read-only gateway observations, explicit scope and bounds, rA | `planned`; readability or search status alone could not establish G |
| Gateway extended MEI | Same G and unit 100, extended inventory request | `no-send`; gateway role excludes extended MEI even with an offline match |
| Separately evidenced child read | G and C, child role, synthetic unit 7, separate route qualification and matching guard/revision, explicitly evidenced bounded child extended-MEI read | `planned`; conditional child-only plan, no scan or automatic registration |
| Stale child selection | Same G; C moved from synthetic unit 7 at rA to unit 8 at rB, but input still selects rA | `withheld`; retain unit-7 data as stale, invalidate its pending plan; unit 8 needs fresh complete evidence |
| Unknown firmware | G's firmware replaced by an unrecognized value; other fields unchanged | `withheld`; no range, prefix, or presumed compatibility |
| Documentary tuple | Exact documentary/default-denied tuple from the disposition, including when the supplied evaluator returns matched | `withheld`; source discrepancy cannot confer qualification |
| Cross-family collision | Same selection evidence also matches another Huawei family, SunSpec/Fronius or Growatt | `withheld`; insufficient evidence, no priority or fallback |
| Gateway timeout | Prior plan recorded a bounded timeout in the gateway qualification run | `no-send` for continuation; no child scan, extended MEI or alternative register retry |
| Baseline or guard absent | Exact offline tuple but missing protocol baseline, or inconsistent before/after sequence | `withheld`; independent discriminators cannot be inferred |

## Review boundary and remaining work

The native contract supports request boundaries, exact discriminators, collision
rejection and bounded inventory; the disposition supports the timeout hard stop
and separate child qualification. The evaluator supports only offline decoded
checks and default denial. Proposed input fields, outcomes, keys, revision
coherence, retention and invalidation are architectural choices constrained by
those sources, not claims that those APIs or transitions already exist.

Remaining gaps include resolving the documentary-tuple discrepancy, publishable
child qualification and route evidence, a runtime freshness contract, executable
provider behavior and independent acceptance. No W specification, gateway
selection implementation or inverter detector is supplied here. No automatic
registration, credential checks, write operations or output binding is added.
Existing eBUS MCP compatibility and GraphQL parity are requirements for future
integration: expose equivalent evidence, reasons and stale state without
promoting this plan into a capability; this page establishes neither integration.

This is a partial contract contribution to the provider-routing parent. Manual
source/claim/example/link review and document readability cannot establish
semantic correctness, transport behavior, profile admission, hardware acceptance
or parent completion. Full gates and independent review remain separate.
