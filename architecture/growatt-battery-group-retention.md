# Growatt RS-485 battery group retention

This Helianthus lifecycle contract is released under AGPL-3.0-only. It
complements the CC0 native protocol contract. It is a proposed provider
contract, not an implemented driver, a stable API, or a qualification result.
Nothing is stable before Helianthus 1.0.

## Scope and evidence status

This page concerns only the Growatt `1xSxxP ESS` RS-485 battery family and the
exact revision tuple declared by the
[native contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/growatt/bms-rs485-1xsxxp-v202.md).
Its family, file revision `Rev2.01`, header version `V2.0`, and cumulative
revision `2.02` form one applicability key. No admitted wire word establishes
that revision. Growatt Protocol II FC04 and CAN are outside this contract.

Evidence status and admission are separate:

| Status | Basis and boundary |
| --- | --- |
| Proven by source inspection | The native contract fixes the FC03 spans and revision; the supplied decoder sources implement complete base and diagnostic decoding, independent copied raw storage, and no outbound authority. This proves source behavior only. |
| Hypothesis / proposed behavior | One acquisition owner can retain independently versioned base, cell, balance, identity and raw records across cycles under the rules below. No supplied source implements that lifecycle. |
| Unknown | Cross-cycle identity continuity on hardware, measurement simultaneity, freshness budgets, restart persistence, and consumer serialization. Synthetic cases prove none of these. |

No row establishes device qualification, runtime admission, profile promotion,
support, or permission to acquire. This page adds no discovery, retry policy,
acquisition range, request, authentication, or authorization check.

## Current native boundary

The native contract precedes every lifecycle rule here. The following public
source files explain the current boundary:

- [Typed base decoder](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/growatt_bms_rs485_typed.go): `DecodeGrowattBMSTypedReadOnlyStatus` requires a complete validated base observation and returns no partial status. `NativeObservation()` copies all four slices.
- [Diagnostic decoder](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/growatt_bms_rs485_multigroup.go): `DecodeGrowattBMSMultiGroupDiagnostic` requires a valid base from the same selected unit and exact revision and all three diagnostic slices in order. It returns no partial diagnostic and establishes no cross-observation identity continuity. `RawSlices()` returns independent copies.
- [RTU base observer](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/growatt_bms_rs485_rtu_observer.go): `Observe` performs only the four base reads in order, checks response provenance and lengths, and returns only after complete decoding. It owns no diagnostic acquisition, discovery, retries, or publication.

The diagnostic decoder's base reference is not proof that measurements were
simultaneous or acquired in one cycle. A future owner must establish that
association explicitly. Both decoded views report `OutboundAllowed() == false`.

## Existing groups and immutable evidence inventory

The names in the first column are proposed lifecycle keys. Current cell group
identifiers are their fixed offsets, not newly discovered packs or addresses.
All extents below come from the native contract; the diagnostic raw order
comes from `RawSlices()` in the diagnostic decoder.

| Proposed record key | Current native content | Immutable evidence retained on successful replacement |
| --- | --- | --- |
| `aggregate` | Entire typed base status: operating state, SOC, pack voltage/current, temperature, capacities, cycle count and the typed extension subset | All four exact base slices: `0x0001` / 7 words, `0x000D` / 29, `0x0100` / 12, `0x010D` / 2. Opaque words keep offsets and positions. No field-by-field base merge. |
| `battery-identity` | Battery ID from bits 8–13 of `0x001F`; bits 14–15 must be zero for diagnostics | Raw `0x001F` / 1, with source slice offset `0x000D` |
| `reported-group` | Entire raw reported group word at `0x0070`; no broader numeric domain is assigned | Raw `0x0070` / 1, source slice offset `0x0070` |
| `cells:0x0071` | First `CellVoltageGroups` entry, offset `0x0071`, exactly 16 unsigned millivolt words through `0x0080` | Raw `0x0071` / 16, source slice offset `0x0071` |
| `cells:0x0081` | Second entry, offset `0x0081`, exactly 16 unsigned millivolt words through `0x0090` | Raw `0x0081` / 16, source slice offset `0x0081` |
| `native-balance` | `NativeBalanceStates`, bits 0–15 in native order, from the base extension word `0x0109` | Raw `0x0109` / 1, source slice offset `0x0100`; the base typed extension still leaves this word opaque |

Diagnostic raw evidence is retained in this fixed order: `0x001F`, `0x0070`,
`0x0071`, `0x0081`, `0x0109`. Each raw record preserves selected unit, exact
revision tuple, FC03, offset, source slice offset and every word. A retained
typed record references the immutable raw record revisions that produced it;
raw replacement and its typed projection commit together. A raw record must
never be relabelled with another typed record's cycle or provenance.

Battery ID, reported group word and the two block ordinals are not selectors,
Modbus unit addresses, or proof of additional packs. No coalescing, further
block, inferred cell count, `0x010C` read, barcode read, or write is added.
Balance states convey observation only, not actuation or health.

## Proposed producer and consumer boundary

One native acquisition owner serializes commits and owns continuity, cycle
allocation, applicability and immutable snapshots. It may receive asynchronous
completions but does not create another poller for each group. These are
conceptual inputs and outputs, not new exported interfaces:

| Boundary | Required content and rule |
| --- | --- |
| Producer cycle context | Opaque source-instance token, owner epoch, monotonically increasing cycle number, selected unit, FC03, exact revision tuple and coherent native identity evidence. Tokens are internal correlation, not public installation identifiers or wire transaction IDs. |
| Base completion | Explicit success with one complete decoded base and its native slices, or explicit failure/not-attempted with a bounded reason. Missing completion is pending until the cycle closes, then incomplete. |
| Diagnostic completion | Explicit success with one complete decoded diagnostic, its raw slices and the exact successful base record reference from this cycle; otherwise explicit failure/not-attempted/incomplete. A failed base prevents diagnostic success in that cycle. |
| Consumer snapshot | Deterministic fixed-order record envelope containing applicability, each record's last-success cycle and revision, immutable evidence reference, latest attempt cycle/outcome, and availability/freshness state. Values are present only when a successful applicable record exists. |

Each record has its own monotonically increasing replacement revision; an
unchanged value on a new complete success still receives a new revision.
Attempt metadata can change without changing the last-success revision.
Base and diagnostic revisions need not advance together. The diagnostic
records have independent keys and evidence references, but the current
decoder requires them to advance together on a successful diagnostic bundle.
Independent versioning does not imply independent fragment admission.

The output states are `absent` (no accepted value), `current` (successful in
the latest owner cycle), `retained` (applicable earlier success), and `invalidated`
(earlier evidence cannot apply to this source context). A pending attempt
does not make an earlier value current. Closing a failed or incomplete cycle
leaves last-success data retained with the new attempt outcome. This contract
does not assign a wall-clock freshness limit; absent an independently defined
budget, consumers must not describe retained data as fresh. Even `current`
denotes cycle membership, not a wall-clock freshness guarantee. The owner must
close pending cycles at a predeclared bounded completion deadline; this page
adds no numerical deadline or retry budget.

An invalidated record exposes no applicable value. Historical raw evidence
may remain segregated for diagnosis under its original context; it must not
appear as current or retained data of the replacement source. This contract
does not define persistence or a historical-storage API.
Suspended applicability due to unknown identity uses `invalidated` with an
explicit reason until coherent continuity is re-established; it exposes no value.

## Proposed commit and retention rules

1. At cycle start, mark prior successes retained and allocate a unique cycle
   within the current owner epoch. Accept only completions for that active
   cycle and epoch. Once a cycle closes or a newer cycle begins, its late
   completions cannot commit. Retransmitted identical completions are
   idempotent; conflicting duplicates reject that completion and cannot
   overwrite an accepted record.
2. Validate source context and continuity before committing any data. The
   continuity key includes source instance, owner epoch, selected unit,
   function, all four revision components, and the native offline identity
   tuple: MCU version, BMS company/generation, pack company/generation,
   topology at `0x001F`, and cell-series count at `0x0029`. A changed key
   invalidates applicability of every old record. A restart or source
   replacement starts a new epoch; equal numerical telemetry is not continuity.
3. A complete coherent base success atomically replaces only `aggregate`
   and its four raw slices. Failure or malformed/partial base retains the
   prior applicable aggregate and all diagnostic records, with failed attempt
   metadata. No supplied field is merged into an old aggregate. Missing or
   contradictory identity instead suspends applicability: old data cannot be
   exposed as applicable until coherent continuity is re-established. Unknown
   continuity never selects another pack or reuses its values.
4. A complete diagnostic success replaces its five listed diagnostic records
   and their raw evidence atomically, after comparison of Battery ID and
   reported group word with the accepted diagnostic identity. A changed
   identity invalidates the prior diagnostic lineage; only a complete coherent
   candidate may start a new lineage. Competing duplicate identities within a
   cycle or contradictory identity evidence admit no diagnostic replacement.
   None of these cases renumbers blocks or inherits an old group's values.
   If base continuity remains coherent, aggregate applicability is unaffected
   by a reported-group change. A changed `0x001F` topology is already a
   whole-context change under rule 2.
5. Any incomplete, failed or malformed diagnostic bundle retains all prior
   applicable diagnostic records, including the failed cell group and its
   raw evidence. A good-looking sibling block in that failed bundle cannot
   refresh independently: the current native contract emits no partial
   diagnostic facts. A qualified base may still refresh. If no prior success
   exists, diagnostic records remain absent, not zero-filled. Partial received
   words are failure evidence only, never replacement last-known-good data.
6. Complete means exact ordered slices, exact word counts, validated encoding,
   coherent applicability and an explicit successful decoder result. Field
   omission, null, an empty list, timeout or a default-initialized result is
   not success. A present, validated zero replaces a prior nonzero value.
   Never use truthiness as presence, nor use zero to fill missing fields.
7. Preserve aggregate/group disagreement as independently sourced observations
   with their original cycles and evidence. Do not sum the fixed cell blocks
   into a replacement pack voltage, overwrite aggregate values, infer another
   topology, or declare fault/health from disagreement. If identity evidence
   itself contradicts, rules 2–4 fail closed instead of emitting repeated facts.

Retained values are historical context, not a newly qualified observation.
The current MCP status/diagnostic success shape must not be populated from a
failed attempt by substituting old values. A future retained envelope must
carry explicit age/cycle/applicability metadata separately from native success.
MCP and GraphQL consumers must receive equivalent record versions, presence,
outcomes and native evidence availability, with any projection loss explicit.
This ticket defines neither binding nor schema. It changes no eBUS MCP
compatibility behavior and creates no eeBUS output binding.

## Synthetic transition review

All cases below are invented family-level examples, not observations or
qualification fixtures. Cycles A, B and C are logical counters in one epoch,
not capture times. Each successful input assumes the complete native revision
and identity checks; ellipses never stand for an admissible partial payload.

| Case | Input / prior state | Required proposed retained view | Current-source basis and limit |
| --- | --- | --- | --- |
| Initial complete success | Cycle A has complete base and diagnostic successes | Aggregate, both cell blocks, balance, identities and raw records are current at A, each at its first replacement revision | Complete typed and diagnostic decoders; cross-cycle storage is proposed |
| One failed cell group after success | After A, B has complete base success, `0x0071` complete, `0x0081` timeout | Aggregate/raw base advance to B. Both cell groups, balance, diagnostic identities and diagnostic raw remain at A, retained; latest diagnostic attempt is failed at B | Incomplete diagnostic emits no facts; the apparently good first block does not bypass bundle admission |
| Valid zero | A had nonzero pack current; complete B base has signed current word zero. Complete B diagnostic has a zero cell word and balance word zero | Replace current with zero, keep all 16 cell positions including zero, and retain all-off balance bits with raw zero; mark successful B revisions | Typed current and unsigned cell words accept zero; balance bits preserve native off/on. Zero does not prove physical health |
| Malformed group | After A, B's second cell slice has 15 words instead of 16, or wrong offset/order | Diagnostic candidate rejected; A diagnostic values/raw retained. Complete B base can still advance | Diagnostic exact-count/order validation; no partial diagnostic return |
| Late old-cycle completion | A closed; B is active or complete; delayed A diagnostic arrives, even if numerically plausible | Reject late completion without changing values, evidence or success revisions. Only current-epoch/current-cycle completions can commit | Observer correlates individual responses; cycle fence is proposed and not supplied by the decoder |
| Changed source or revision | After A, source token, owner epoch, unit, function, any revision component or native identity key changes | Old records become inapplicable; new context starts absent. Unsupported revision/function cannot succeed. Same numbers do not restore old applicability | Exact revision/unit checks exist; cross-cycle key invalidation is proposed |
| Changed reported group | After A, coherent B base but a complete diagnostic reports a different `0x0070` word | Invalidate old diagnostic applicability; do not carry A cells into the new reported group. Accept a new diagnostic only with complete coherent evidence; base can remain applicable | Group word is evidence, never selector; continuity decision is proposed |
| Aggregate/group disagreement | B aggregate pack voltage differs from a calculation over retained A cells, or from complete B blocks | Keep native observations and cycles separate; no aggregate overwrite, freshness promotion or inferred whole-pack total | Native contract distinguishes base and diagnostic; relation, simultaneity and total-cell mapping remain unknown |
| Missing fields / no prior success | First cycle lacks a diagnostic completion, or base result omits required slices | On close, affected records are absent with incomplete outcome, not fabricated zeros. Later incomplete cycles retain only previously applicable successes | Complete decoder inputs required; lifecycle attempt state is proposed |
| Identity evidence unavailable | After A, B cannot establish coherent required identity | Preserve A evidence under its old context but suspend applicable values; no repeated diagnostic facts or implicit reassignment | Native identity/pack consistency fail-closed rule; suspension is proposed lifecycle policy |

## Remaining work and acceptance boundary

This is a partial architecture contract for issue #186 and Project #2,
Connect all drivers and native acquisition into the gateway composition.
It does not close the parent or consume another proposed implementation.

Implementation, deterministic lifecycle and race tests, native source continuity
evidence, binding design and parity checks, committed-head documentation gates,
independent review, and separately authorized hardware qualification remain
outstanding. Accepting a successful individual block from a failed diagnostic
bundle would first require a separate native-contract change and matching
validation; it is future work, not behavior admitted here.

Manual source/claim/table/example review and offline link-destination inspection
can validate this document's evidence boundaries. Document readability is not
semantic, transport, runtime, passive-capture, hardware or profile-admission
validation. No outbound authority follows from any retained record.
