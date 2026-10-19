# SUN2000 offline provider port composition contract

This application architecture contract is released under AGPL-3.0-only. It
complements the CC0 native evidence contract. Nothing is stable before
Helianthus 1.0.

## Native authority and scope

The public [SUN2000 native disposition](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/inverter-battery-readonly-v1.md)
and [detection input contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/sun2000-detection-input-v1.md)
come first. Both remain default denied. This page proposes the first
family-local offline provider cycle: one explicit refresh obtains bounded bytes
from an injected fake supplier and invokes `ParseSun2000EvidenceInput`.
Validated documentary input remains detached; an unsuccessful attempt retains
the previous structurally valid record separately, with its original receipt.

The merged [native parser source](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/sun2000_evidence_input.go)
is the implementation authority for existing API behavior. Its
[implementation companion](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/sun2000-evidence-input-validator-implementation.md)
describes that component's narrower boundary. Neither implements the wrapper
proposed here. This is a composition-layer contract, not a restatement of an
existing component or another family's cycle.

| Claim status | Evidence and limit |
| --- | --- |
| Proven | Supplied merged parser source checks structure, object budgets and reference coherence, performs zero I/O, and exposes detached typed views. |
| Hypothesis | The I13-prefixed port and concrete adapter below are the proposed local composition over those native types. Their implementation and final API spelling require reconciliation at code merge. |
| Unknown | Real provenance, documentary completeness, exact map applicability, freshness, runtime integration, acquisition and physical qualification. |

These statuses never confer qualification. Every wrapper view has admission
`NO_ADMISSIBLE_PROFILE`, readiness `NO_GO`, and denied status. A successful
parse is only structural validity. The wrapper does not implement the native
contract's detector evaluation, candidate ranking, or detector result envelope.
It never constructs a qualified profile, selects an exact register map, emits
native telemetry, probes, registers a catalog entry, or admits a runtime.

## Proposed local API and concrete adapter

The following is an API specification, not executable implementation evidence.
All new types, methods, fields and helpers use the `I13`/`i13` prefix. Existing
native APIs and standard context/error types are consumed unchanged.

```go
type I13Sun2000Provider interface {
    I13Refresh(context.Context) (I13Sun2000View, error)
    I13RetainedView() I13Sun2000View
    I13Retire()
}

type I13Sun2000Config struct {
    I13Subject    string
    I13Source     string
    I13Generation uint64
    I13Limits     Sun2000EvidenceInputLimits
}

type I13Sun2000Request struct {
    I13Config  I13Sun2000Config
    I13Attempt uint64
}

type I13Sun2000Supplier func(context.Context, I13Sun2000Request) ([]byte, error)

type I13Sun2000Receipt struct {
    I13Subject    string
    I13Source     string
    I13Generation uint64
    I13Attempt    uint64
}

type I13Sun2000Record struct {
    I13Receipt I13Sun2000Receipt
    I13Bytes   []byte
    I13Input   Sun2000EvidenceInput
}

type I13Sun2000Attempt struct {
    I13Receipt I13Sun2000Receipt
    I13Reason  string
}

type I13Sun2000View struct {
    I13Latest    *I13Sun2000Attempt
    I13Retained  *I13Sun2000Record
    I13Retired   bool
    I13Admission string
    I13Readiness string
    I13Denied    bool
}

func I13NewSun2000Provider(I13Sun2000Config, I13Sun2000Supplier) (I13Sun2000Provider, error)
```

The proposed concrete implementation is `i13Sun2000Provider`, returned only by
`I13NewSun2000Provider`. Its `I13Refresh`, `I13RetainedView` and `I13Retire`
methods implement this interface. Its private state owns a frozen configuration,
supplier, single-flight flag, retirement fence, monotonic attempt counter,
latest attempt and optional retained record. No global registry or sibling
implementation is imported. The interface and adapter belong together in the
future I13 implementation's own new file; this page supplies their independent
contract and does not claim that file exists on main.

This is not the common production `Provider` interface, whose composition is
absent here, and not the M02 gateway registry. No socket, device adapter,
active acquisition, background scheduler, registration or native qualification
is introduced. Production interface and gateway completion are not claimed.

## Creation, bounds and refresh transaction

Construction performs no callback. It rejects a nil supplier, empty or invalid
UTF-8 subject/source, either label longer than 128 bytes, generation zero, and
invalid parser budgets. Labels are caller-local synthetic identifiers, never
coordinates or physical identity. Configuration is copied and immutable.

The following ceilings are proposed wrapper policy, not native protocol facts
or parser defaults. Every input and retained allocation has an explicit bound.

| Input or resource | Bound and refusal |
| --- | --- |
| Subject/source labels | Each 1–128 UTF-8 bytes; source identifies a supplier revision, not native evidence provenance. |
| Generation | Positive `uint64`, allocated without reuse by the composing caller; no wraparound. |
| Attempt | Starts at 1, increases for each admitted refresh; exhaustion refuses without callback. |
| One supplier response | `MaxBytes` is positive and at most 1,048,576 bytes. The fake supplier must obey it before allocating/returning; the adapter independently rejects oversized responses before copying or parsing. |
| JSON objects per response | `MaxRecords` is positive and at most 4,096; the native parser counts every object, including envelope, reference, candidate, wrapper, alternative and typed unit/map value. |
| JSON arrays/strings | Byte-bounded by `MaxBytes`; array entries are not individually counted as objects unless they are objects. There is no separate native per-string cap. |
| Nesting | Native parser rejects nesting beyond 64; wrapper adds no recursion or traversal of external references. |
| Per record/history | Each retained record has at most one bounded original byte copy and one parsed snapshot. One retained record and one latest attempt receipt only; no unbounded history, batch, queue or rejected-byte archive. |
| In-flight work | At most one supplier invocation per refresh and one refresh per instance; zero retries, fallback calls or automatic refreshes. During replacement at most the old and prospective bounded record coexist. |
| Context/callback | Nil context is refused. Cancellation is checked before callback, after callback, and at commit after parsing. Callback must terminate cooperatively on cancellation; no detached goroutine or forced wall-clock termination is promised. |
| Errors/diagnostics | Adapter reasons are fixed bounded codes; native parser errors are bounded static messages. Supplier error text and rejected bytes are never echoed or retained. |

A refresh first checks context, retirement, busy state and counter exhaustion
under the state fence. A refusal returns a detached current view plus error,
does not call the supplier, and does not overwrite the latest admitted attempt.
Refusal reasons are `I13_NIL_CONTEXT`, `I13_RETIRED`, `I13_BUSY` and
`I13_ATTEMPT_EXHAUSTED`, checked in that order after a non-nil context; an
already cancelled context returns `I13_CANCELLED` before callback admission.
Construction errors use `I13_INVALID_CONFIG`.
An admitted call freezes its receipt from subject, source, generation and attempt
before the callback. The request carries that receipt's identity and parser
limits by value. The caller must not mutate the supplier's response during the
call; the adapter copies accepted-size bytes before parsing and retains no
supplier-owned buffer.

The adapter calls the fake supplier exactly once with that context and request.
On return it checks cancellation and retirement before considering bytes or
supplier error. A supplier error rejects even when bytes also exist. Otherwise
it checks the byte bound and calls
`ParseSun2000EvidenceInput` with the unchanged native limits. It checks the
parsed `Subject()` against the configured subject. This extra join is required:
the parser checks unit context against envelope subject but does not know the
wrapper's configured subject.

Before committing, it rechecks context and the lifecycle fence. Retirement or
cancellation discards a prospective record. A committed structural success
atomically replaces the retained record and latest attempt; it records
`I13_STRUCTURALLY_VALID`. No zero `Sun2000EvidenceInput` is presented as valid.
An error atomically updates only the latest admitted attempt, preserving the
old record and its bytes, native input and original receipt. The attempt carries
its own receipt and a fixed reason, such as `I13_SUPPLIER_ERROR`,
`I13_BYTE_LIMIT`, `I13_INVALID_INPUT`, `I13_SUBJECT_MISMATCH`, `I13_CANCELLED`
or `I13_RETIRED`. Error precedence is retirement, cancellation, supplier error,
byte bound, parser error, then subject mismatch at the applicable fences.
Do not turn malformed input into a partially parsed or partial admitted record.

`I13RetainedView` performs zero callbacks and returns a deep detached copy of
both receipts, optional pointers and retained bytes, with native typed views
using their existing copying accessors. Caller mutation cannot change state.
A view is a historical observation, not a lease or evidence of freshness.

`I13Retire` is idempotent, fences future commits immediately, schedules nothing
and performs no I/O. It preserves the retained historical record. An already
running cooperative callback may still return; its completion cannot commit a
record and releases single-flight state. Retirement does not forcibly interrupt
arbitrary supplier code. Races linearize at the state fence: cancellation or
retirement observed before commit wins; a completed prior commit is history.

Source, subject, generation, supplier or budget replacement requires retiring
the old instance and constructing a new instance with a fresh generation. There
is no in-place reconfiguration. The new instance starts with no retained record;
old history stays with the retired instance and is never relabeled or silently
transferred. A late callback cannot populate the replacement. A composing caller
must not treat an old view as belonging to its new generation.

## Identity, native joins and projection loss

Wrapper identity is `(subject, source, generation, attempt)`, with the first
three identifying the instance and attempt identifying a single admitted call.
Receipt identity is independent of candidate tuple identity. Source is a local
supplier label, not the evidence record's native `source` field.

| Independently varied synthetic axis | Required boundary; reasoned defect caught |
| --- | --- |
| Configured subject | Envelope subject must match; omitting the wrapper subject check would permit a different envelope with internally consistent units. |
| Supplier source | Replace instance and generation; dropping source from receipts would conflate suppliers and relabel old history. |
| Generation | Replacement cannot accept an old callback/view; removing the retired-instance commit fence would permit late publication. |
| Attempt | Failed attempt receipt differs from retained receipt; overwriting retained receipt on error would misrepresent old input as new. |
| Evidence ID | Unique IDs and resolved wrapper/alternative references; omitting native duplicate/dangling-reference checks would splice unresolved claims. |
| Candidate ID | Unique within envelope, never a winner selector; removing duplicate-ID rejection would collapse distinct records. |
| Family state/value/alternative values | Native present family exactly SUN2000; dropping family from tuple identity would conflate different claims. Other families survive only as contradictory alternatives. |
| Model state/value/alternative values | Retain exact native strings without prefix matching; dropping model from tuple identity would reject distinct synthetic tuples as duplicates. Public examples publish no model claims. |
| Firmware state/value/alternative values | No ordering or inherited identity; dropping firmware from tuple identity would conflate differing observations. |
| Unit context | Each present or alternative unit context equals envelope subject; removing native context validation would permit cross-subject units. |
| Unit binding | Preserve independently; dropping binding from tuple identity would conflate units within one context. |
| Map document | Preserve independently; omitting document from tuple identity would conflate different documentary maps. |
| Map revision | Preserve independently; document-only comparison would conflate revisions. |
| Map applicability | Preserve independently; ignoring applicability would conflate different scopes. |
| Evidence source/locator/context/claim level | Preserve every value; treating resolved reference IDs as verified applicability would upgrade structural coherence to provenance. |
| Detail/reference order/alternative order | Detail and reference IDs do not distinguish native tuple identity; sorted alternative values remove ordering as a discriminator. Including these in identity would admit duplicate tuples under cosmetic changes. |

Native tuple identity includes all five wrapper states, typed values and sorted
alternative values. Candidate ID, detail and reference IDs are excluded; two IDs
cannot manufacture distinct candidates with an identical tuple. Reference joins
prove only local referential coherence. The parser does not enforce documentary
provenance, locator retention, evidence context applicability, completeness or
claim truth; the wrapper does not resolve these gaps. `Proven` in an evidence
record remains the referenced claim's level, never qualification.

Keep `missing`, `unavailable`, `present` and `contradictory`, nulls, references,
all alternatives, typed unit/map values and optional detail. Contradiction is
not repaired by order or recency. Unavailable evidence is not absent hardware;
unknown optional battery state is not zero. Replacement of an entire valid
snapshot does not merge fields from previous candidates. On error the previous
snapshot remains separately available, including its partial documentary fields.

Retaining original bounded bytes preserves serialization as documentary input;
it does not retain external documents behind locators. Native typed parsing
alone loses whitespace/key serialization and does not establish external evidence
retention. Any future projection omitting bytes, refs, alternatives, detail or
receipts must explicitly identify that loss and distinguish current failure from
retained historical validity. This contract changes no eBUS MCP envelope or
GraphQL surface. A later projection must preserve the same denial, null selection,
zero facts and retained/error meaning on both; eeBUS output remains owned by
helianthus-eebusreg. G5 D1–D5/O8 are unchanged.

## Synthetic transitions and self-contained example

All labels below are synthetic; generation and attempt numbers are local
counters, never observation times. Every row retains `NO_ADMISSIBLE_PROFILE`,
`NO_GO`, denied status, null profile selection, zero native facts and zero
network/device work. Catalog registration, automatic runtime admission, live
qualification, support claim, write authority and fallback remain false.

| Starting state and action | Supplier calls | Latest admitted attempt | Retained record |
| --- | --- | --- | --- |
| Construct subject `i13-subject-a`, source `i13-source-a`, generation 1 | 0 | None | None |
| Refresh with example below | 1 | Generation 1/attempt 1, structurally valid | Example bytes/input with original 1/1 receipt |
| Refresh with malformed bytes `{` | 1 | 1/2, invalid input | Original 1/1 unchanged, not relabeled 1/2 |
| Refresh returns bytes plus error | 1 | 1/3, supplier error | Original 1/1 unchanged |
| Already cancelled context | 0 | Prior attempt unchanged | Original 1/1 unchanged |
| Cancellation during callback, or after parse before commit | 1 | Next admitted receipt, cancelled | Original 1/1 unchanged |
| Oversized response or excessive object count | 1 | Next admitted receipt, byte limit or invalid input | Original 1/1 unchanged |
| Valid empty-candidate envelope for configured subject | 1 | Next admitted receipt, structurally valid | Replaces old input; no candidates fabricated |
| Concurrent refresh while busy | 0 for refused call | No overwrite by refused call | No overwrite by refused call |
| Retire while callback runs | No extra call | In-flight completion reports retired | Prior record remains historical |
| Refresh retired instance | 0 | Prior attempt unchanged | Historical record only |
| Replace source with `i13-source-b`, fresh generation 2 | 0 until explicit refresh | New instance has none | New instance has none; old 1/1 stays on old instance |
| Old callback returns after replacement | No extra call | Old instance's receipt only, retired | Cannot populate new instance |

This complete synthetic JSON is one candidate with partial documentary input:

```json
{
  "contract": "sun2000-detection-input-v1",
  "subject": "i13-subject-a",
  "evidence": [{
    "id": "i13-evidence-a",
    "source": "synthetic",
    "locator": "i13-example: family assertion SUN2000 for i13-subject-a",
    "context": "i13-subject-a",
    "claim_level": "Hypothesis"
  }],
  "candidates": [{
    "id": "i13-candidate-a",
    "family": {"state": "present", "value": "SUN2000", "refs": ["i13-evidence-a"], "alternatives": []},
    "model": {"state": "missing", "value": null, "refs": [], "alternatives": []},
    "firmware": {"state": "missing", "value": null, "refs": [], "alternatives": []},
    "unit": {"state": "missing", "value": null, "refs": [], "alternatives": []},
    "map": {"state": "missing", "value": null, "refs": [], "alternatives": []}
  }]
}
```

Use proposed limits `MaxBytes=4096`, `MaxRecords=16`. This example has eight JSON
objects: envelope, evidence reference, candidate and five wrappers. Expected
structural success retains the family claim and four missing wrappers, without
detecting a device. The locator's entire synthetic content is the stated family
assertion for that subject; it supplies no model, firmware, unit or map evidence.
The malformed second attempt keeps its own 1/2 rejection receipt while retained
bytes/input keep 1/1. Replacing envelope subject alone with `i13-subject-b` still
parses here, because unit is missing, but the wrapper must reject the mismatch.
Reducing `MaxRecords` to seven must fail native parsing; adding an unknown
`admitted` field must fail the closed schema. None changes admission.

## Acceptance and companion disposition

Manual acceptance compares existing API claims with the merged parser and native
contract, reviews every transition and independently varied identity axis,
counts the example's objects, and inspects public link destinations without
network access. Identity-table defects are reasoned falsifiers, not executed
mutant kills or an exhaustive executable test suite. Examples and proposed
bounds are synthetic contract requirements, not runtime or hardware evidence.

This independent companion can merge first and has no special merge hold or
build dependency on I13 code, a sibling PR or unmerged output. Reconcile final
API spelling and executable cancellation/retirement behavior with I13 at code
merge. Ordinary review and applicable gates remain. Refs
[docs-modbus issue #225](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/225),
[docs-modbus parent #199](https://github.com/Project-Helianthus/helianthus-docs-modbus/issues/199)
and [modbusreg parent #199](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/199):
this is a partial contract slice and closes neither parent.

Native qualification, documentary evaluation, common production Provider,
gateway composition, committed-head CI, runtime integration, acquisition,
transport/smoke and physical acceptance remain separate and unproven here.
There is no new namespace or authorization gate. Any new roadmap commitment
belongs to 0.11; nothing is stable before Helianthus 1.0.
