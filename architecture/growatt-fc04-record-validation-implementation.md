# Growatt FC04 record validation implementation

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

The reviewed modbusreg component provides offline proposed-record parsing and
symbolic comparison for the TL3-X MAX/MID/MAC families.
Nothing is stable before Helianthus 1.0.

| Evidence status | Reviewed boundary | Qualification and admission |
| --- | --- | --- |
| Proven within reported focused synthetic tests | Closed parsing, exact comparisons, field geometry checks and public denial | Synthetic software proof only |
| Hypothesis | A future independently reviewed tuple-to-schema mapping could support an owning runtime implementation | Requires separate public evidence and acceptance |
| Unknown | A current reviewed exact native tuple mapping for these families | Public admission remains `NO_ADMISSIBLE_PROFILE` |

Qualification and admission are separate axes; this component changes neither.

## Native authority

The native authority is the [Growatt Protocol II FC04 admission-record
proposal](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/growatt/protocol-ii-fc04-admission-record-v1.md).
The application API and lifecycle boundary belongs here, outside `protocols/`
and `types/`.

## Reviewed API and implementation boundary

`ParseGrowattFC04Record` accepts one JSON object with exactly eleven mandatory
scalar keys: `family`, `device_type`, `model_build_word_82`,
`model_build_word_83`, `reported_protocol_word`, `source_schema_ref`, `function`,
`offset`, `width_words`, `field_schema_ref`, and `tuple_evidence_ref`.
It returns a `GrowattFC04Record` and an error; no partially parsed record is
returned on error.
Duplicate keys, including escaped equivalents, unknown keys, nulls, wrong
types, coercions, trailing values, malformed references and invalid extents
are rejected.
Native words are unsigned 16-bit integers; family is MAX, MID or MAC, function
is 4, offset is 0 and width is 59 words.
References are nonempty exact identifiers without whitespace or control
characters; parsing does not resolve them or verify publication or review.

`CompareGrowattFC04Record` takes a proposed record, a coherent
`GrowattProtocolIIIdentityObservation`, symbolic tuple entries and symbolic
schemas, returning a diagnostic error.
It rechecks the full observation through the existing identity decoder,
resolves exactly one tuple entry by `tuple_evidence_ref` and one schema by
`source_schema_ref`, and compares every record field conjunctively.
Candidate ordering cannot select a winner among conflicting definitions.
Both model words remain separate in FC03 register order 82, 83; source document
edition remains metadata, separate from the reported protocol word at 88.

The caller supplies `GrowattFC04SymbolicSchema` operands with exact source and
field-definition references, document edition, amendment identity, function,
source extent and symbolic field extents.
Each field extent must have positive width and fit wholly inside the source
extent using non-wrapping arithmetic.
These operands supply geometry, without decoding, scaling, signedness, units
or enum rules; `FieldSchemaRef` identifies the exhaustive definitions, whose
existence and review cannot be established by caller assertions.
Caller-configured retry or deadline bounds and detached-view guarantees are
Unknown in this component's documented API.

The errors support `errors.Is`:

| Error | Diagnostic boundary |
| --- | --- |
| `ErrGrowattFC04Missing` | Absent fields or unresolved references |
| `ErrGrowattFC04Invalid` | Malformed input, failed equalities, invalid identity or field geometry; a field-definition reference disagreeing with the resolved source |
| `ErrGrowattFC04Ambiguous` | Multiple resolutions, including identical repetitions |

`ValidateGrowattFC04RecordAdmission` accepts JSON bytes and the native identity
observation, returning a status string and an error.
It always returns `NO_ADMISSIBLE_PROFILE`: well-formed records and identity
receive missing-evidence diagnostics, while malformed records or incoherent
identity receive their diagnostic error.
The reviewed public catalog is empty and has no caller population or approval
API; equality between caller-created symbolic operands establishes only that
their values satisfy the comparison.

## Retained state and loss states

The diagnostic has no cached decision or lifecycle state, retains no
observations and changes no existing decoder or retention rule.
A failed comparison cannot replace partial last-known-good native state.
An amendment requires a distinct exact source reference even when the edition
label is reused; changing that reference requires fresh comparison, and
conflicting amendments under one reference are ambiguous.
A later composition owner must preserve historical provenance, handle source
amendments and withdrawals, and revalidate current review before consumption.
This diagnostic cannot approve a cached mapping across a source transition.
Absent evidence is diagnosed as missing; reviewed applicability remains
Unknown, and no current, retained or invalidated admission lifecycle is
implemented by this stateless diagnostic.

## Synthetic verification

The modbusreg review reports independent synthetic controls for every
comparison axis: eleven omitted-comparison mutants and one admission-bypass
mutant each fail their corresponding negative control.
Its final focused selection passes five tests and 84 subtests.
These are reported synthetic proof of software mechanics, separate from
qualification and unknown reviewed applicability.

## Boundaries and remaining acceptance

The component adds no applicability value, typed telemetry constructor or
observer constructor, detector registration, transport, scheduling,
acquisition, profile admission, projection, gateway or runtime integration.
Existing trust/admission checks, eBUS MCP compatibility and GraphQL parity
remain unchanged.
The broader native-readiness parent remains open; this is a partial slice
referencing modbusreg issues #301 and #196.
Remaining acceptance includes reviewed public evidence, owning-runtime
integration, bounded acquisition/decoder acceptance and separately required
real-build qualification.
No hardware, passive-capture or live-device acceptance is claimed.
