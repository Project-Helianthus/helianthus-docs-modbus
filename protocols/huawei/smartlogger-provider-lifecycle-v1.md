# SmartLogger provider transaction lifecycle V1

## Scope and evidence status

This is a proposed native provider ownership contract for one bounded
SmartLogger inventory refresh. It specifies transaction mechanics; it does not
enable a provider. The current registry disposition remains
`NO_ADMISSIBLE_PROFILE`, with zero automatic admission, no catalog registration,
no live qualification, no support claim, and no write authority. Injecting a
transport or successfully exercising synthetic mechanics changes none of these.

| Evidence label | Claim and limit |
| --- | --- |
| Proven | The public native contracts below specify the read sequence, exact candidate tuples, parser rules, and ceilings. This is documentary evidence, not proof of an implemented lifecycle or device behavior. |
| Hypothesis | A future provider implementing the ownership and commit rules here can isolate failed refreshes and obsolete completions. Implementation and independent behavioral evidence remain required. |
| Unknown | Connected qualification, production acquisition, runtime concurrency behavior, and public-surface replay are not established here. |

These labels are separate from qualification, acquisition, and admission.
`QUALIFICATION_TEST_READY` describes offline procedure preparation only.
The historical V1 name implies no stability before Helianthus 1.0. This page
adds no authorization gate; it preserves existing trust and admission boundaries.

## Public native sources and precedence

The protocol facts come from the existing public native contracts first:

- [Gateway read-only candidates](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/gateway-readonly-v1.md): SmartLogger identity, encoding, counter guard, pagination, native child evidence, and no-send private functions.
- [Qualification readiness](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/qualification-readiness-v1.md): caller-run bracket, exact self entry and firmware tuples, child encoding, ceilings, and offline qualification limits.
- [Qualification evidence checklist](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/qualification-evidence-checklist.md): current disposition, missing evidence, last-known-good retention, and separate family acceptance.

The following ownership rules are proposed provider requirements, not newly
observed wire facts. They do not relax any source predicate. An unresolved
encoding or count interpretation stays insufficient evidence rather than
selecting whichever interpretation permits completion.

## Frozen request plan and immutable completion

The native provider owns the plan, staging inventory, completion, and atomic
replacement of its last-complete inventory. The transport performs only the
bounded exchanges requested by that plan; it does not select profiles or
interpret child capability. Callers and consumers never receive mutable aliases
to provider-owned records or transport response buffers.

| Record / field | Required meaning and ownership |
| --- | --- |
| Plan: refresh token | Unique local attempt identity, fixed before the first exchange; never reused by a successor refresh. It is not a wire transaction identifier. |
| Plan: provider and connection generation | Captures the owning provider instance and transport generation. Reconnect or replacement invalidates the old generation's authority to commit. |
| Plan: identity context | Captures the opaque routing context, logical unit 0, parent profile context and source revision. Candidate self model and exact firmware must later validate against this context; missing profile admission remains denied. Public examples contain no real routing coordinates. |
| Plan: operations and limits | Freezes the counter-before, extended-MEI continuation policy, counter-after, absolute deadline, and ceilings below. A validated continuation cursor is transaction state, not permission to mutate the plan or add probes. |
| Completion: correlation and outcome | Copies the frozen plan identity, terminal stage/reason, consumed budgets and generation fence result. Exactly one terminal completion exists per accepted refresh, including failure or cancellation. A busy refusal starts no refresh. |
| Completion: native evidence | Owns detached copies of actually received native responses, parsed attributes, counter values when available, provenance and version context. Missing responses stay absent; malformed or partial evidence is diagnostic only, never a usable partial inventory. |
| Completion: history | Retains original acquisition history and monotonic observation/completion markers. A failed attempt records its own outcome separately and never rewrites the previous successful inventory's observation marker. |
| Last-complete inventory | A detached, immutable snapshot associated with its original identity context, source revision, generation and coherent counter bracket. Consumers receive detached views; later buffer reuse or caller mutation cannot alter history. |

Native evidence is not replaced by a semantic projection. If a later consumer
omits attributes or cannot represent a native failure, it must document that
projection loss separately. Native runtime retention and public publication
are different boundaries: public examples contain only synthetic data.

## One in-flight refresh and bounded sequence

At most one refresh owns a provider's transaction slot. Concurrent callers are
refused as busy, without exchanges, implicit queuing, or replacement of the
active plan. The slot is released only after the terminal outcome is fixed and
the attempt can no longer commit. A successor cannot reuse unresolved exchanges
from an earlier transport generation; existing transport fencing must establish
that isolation, otherwise the provider remains unavailable. This contract adds
no transport recovery mechanism.

| Stage | Only permitted operation / validation |
| --- | --- |
| Plan | Freeze owner, refresh token, identity context, generation and limits; check cancellation, closure and existing admission. Current automatic production admission refuses without sending. |
| Counter-before | FC03, zero-based PDU offset 65521, quantity 1; retain the U16 counter. Failure ends the attempt. |
| Inventory | FC2B / MEI 0x0e / ReadDevId 0x03, starting ObjectID 0x87. Follow only validated `More`, `Next object ID`, and response object count from this attempt. |
| Counter-after | Only after a complete valid inventory, repeat the identical FC03 counter read in the same owner, identity context and generation. Require equality with counter-before. |
| Commit | Atomically recheck the active token, owner, generation, identity context, deadline, cancellation and closure, then replace last-complete with a detached snapshot. A check before transport I/O alone is insufficient. |

The published inventory ceilings are 15 seconds, 248 pages, 248 objects,
65536 response bytes and 247 children. All apply simultaneously, including the
declared U8 count and existing object mapping/order rules; the child ceiling
does not license extra objects, an extra wrap, or a new count interpretation.
The proposed provider uses one absolute refresh deadline no later than refresh
start plus 15 seconds, or an earlier caller deadline. This conservatively fits
the entire bracket within the published enumeration time ceiling. It never
resets on a page, counter read, cancellation, or reconnect. Page/object/byte/child
accounting retains the native inventory scope; the counter reads do not create
extra MEI pages. Before sending a continuation, ensure it can stay within the
remaining limits; reject a response that exceeds a ceiling. Reaching a ceiling
with work still required is exhaustion, not a truncated success.

The self entry must have exact model `SmartLogger` and firmware exactly
`V300R024C10SPC191` or `V300R024C10SPC210`. These are parallel exact tuples,
with no ordered or-later comparison. Preserve the existing bounded semicolon
attribute encoding and rejection rules: unknown/repeated keys, missing model,
malformed ASCII/attributes, duplicate objects or child addresses, wrong order,
count mismatch, cursor loops and a second wrap all invalidate the inventory.
Equal U16 counters are the existing guard, not proof that no intervening change
or counter wrap ever occurred.

There are no added probes, retries, register meanings, discovery scans, family
fallbacks or alternative functions. An unsuccessful bracket ends this refresh;
it does not automatically start another. FC0x41 and Huawei-specific FC0x17
remain default-denied and no-send.

## Terminal outcomes and retention

All failure rows retain any original last-complete snapshot and its history.
If none exists, inventory remains Unknown. Failed-attempt diagnostic evidence
does not become a child list or new native telemetry facts. Outcome names here
are descriptive provider states, not a new public API or admission result.

| Stage / event | Terminal or next outcome | Last-complete / successor rule |
| --- | --- | --- |
| Plan with current automatic admission denied | Refused, no send | No inventory or profile is created; injected mechanics do not bypass this decision. |
| Active refresh and concurrent caller | Busy refusal for caller; active refresh continues | Active ownership and retained snapshot are unchanged. |
| Valid page with continuation and remaining budget | Continue same refresh | Stage privately; do not publish or renew age. |
| All pages valid, equal counters, valid commit fence | Complete | Atomically replace with detached complete inventory; admission and qualification remain unchanged. |
| Counter-after differs from counter-before | Failed: incoherent bracket | Discard staged inventory from publication; retain original snapshot and age; no retry. |
| Malformed late page after valid earlier pages | Failed: invalid inventory | No partial replacement, appended children, or freshness renewal; retain original history. |
| Deadline, page, object, byte or child exhaustion | Failed: exhausted | Stop further exchanges; no partial success or renewed deadline. |
| Counter read failure, timeout, disconnect, exception or invalid identity | Failed: insufficient evidence | No fallback; keep old inventory only in its original identity/history context. |
| Cancel before commit | Cancelled | Stop further sends; fence pending callbacks. Keep original snapshot and observation marker. |
| Close before commit | Closed | Retire attempt and provider; later callbacks cannot commit. Close is terminal for this provider instance. |
| Reconnect or successor generation before commit | Retired: obsolete owner | Old completion cannot finish the new bracket, update its counters, release its slot, or replace its snapshot. |
| Late response/completion after terminal outcome | Already terminal; no state transition | Preserve diagnostic correlation to the original attempt without a second completion or inventory update. |

Commit, cancellation, close and generation retirement are serialized at the
publication boundary. Whichever transition wins fixes the outcome: cancellation
or retirement before commit prevents publication; cancellation after a completed
commit does not rewrite that historical success. No post-terminal callback may
mutate the immutable completion.

Freshness is measured from the retained successful observation, not the most
recent attempt. Its age continues to increase during and after failures; do not
stamp it as newly observed, substitute zero values, or erase unrelated valid
last-known-good observations. This page defines no new freshness threshold.

## Reconnect identity fencing and child boundary

A reconnect opens a new generation even if routing appears unchanged. Previously
retained inventory stays historical under its old identity; it is not evidence
that the new connection reaches the same parent. A new, independently complete
bracket must validate the self entry, exact firmware and identity context before
publishing a current snapshot. No old counter, page, child, or completion can
be spliced into it. If identity changes or cannot be established, old observations
remain detached history and cannot be relabeled as the new parent's inventory.

Child identity retains the native contract's parent profile, routing address,
model/product type and source revision. Each component matters independently;
an ESN alone is not stable child identity. An unadmitted parent context cannot
be promoted into an admitted profile by filling these fields. Child enumeration
never admits a child profile, establishes inverter/battery capability, authorizes
child-unit reads, or transfers qualification between families.

## Synthetic review examples and remaining acceptance

These are reasoned transition examples, not fixtures executed against runtime:

| Synthetic scenario | Independently expected result |
| --- | --- |
| Existing snapshot S; before counter 12; valid inventory; after counter 13 | Fail whole refresh; S and its original observation marker remain unchanged. |
| Existing S; first page valid; later page repeats a child address | Fail whole refresh despite earlier valid data; diagnostic bytes may remain, but no partial inventory is exposed. |
| Existing S; 248 pages consumed with continuation still required | Exhausted; no page 249 and no replacement or freshness renewal. |
| Refresh A owns generation A; cancellation or close wins before commit | A cannot publish, including when a valid response arrives afterward. |
| Retired A completes after successor B starts | A cannot change B's slot or evidence. B must obtain both counters and every page itself. |
| Complete detached S is returned; a caller changes its own copy | S's stored native evidence, history and identity remain unchanged. |

This is the transaction/ownership slice for issue #172. It neither replaces
K19/M51 behavioral tests nor closes the K34 evidence checklist. Registry
implementation, admission evidence, production acquisition, concurrency and
transport isolation tests, connected read-only qualification, hardware acceptance,
and end-to-end native/consumer replay remain separate acceptance work. Existing
eBUS MCP envelopes and GraphQL parity are unchanged; no new consumer surface or
semantic mapping is defined. G5 D1-D5/O8 remain J01-J17-owned: this page creates
no receipts, idempotency ledger, principal boundary or recovery redesign. It
closes no parent issue or release gate.
