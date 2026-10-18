# SUN2000 evidence input validator implementation

This Helianthus application architecture guidance is released under AGPL-3.0-only. It complements the CC0 native contract without changing it.

## Scope and evidence status

This page describes the reviewed offline SUN2000 evidence input validator for the Huawei provider family in modbusreg PR #315.
Nothing is stable before Helianthus 1.0.

| Evidence status | Basis and limit |
| --- | --- |
| Proven | The reviewed component parses structural evidence input with caller-supplied finite bounds and returns immutable typed records with detached views. |
| Hypothesis | A future explicit consumer is intended to check provenance, documentary completeness and map applicability; this parser does not perform those checks. |
| Unknown | Real evidence provenance, qualification, completeness and hardware acceptance are not established by structural validity or synthetic verification. |

Proven, Hypothesis and Unknown describe referenced claims only; qualification and admission are separate axes that this component does not change.
The native disposition remains `NO_ADMISSIBLE_PROFILE`, with existing admission flags false.

## Native authority

The public [SUN2000 detection input contract](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/protocols/huawei/sun2000-detection-input-v1.md) is the native authority cited by the implementation companion requirement.
The parser implements a structural boundary, not the contract's detector evaluation or result envelope.

## Reviewed API and implementation boundary

`ParseSun2000EvidenceInput(data []byte, limits Sun2000EvidenceInputLimits) (Sun2000EvidenceInput, error)` is explicitly called offline with supplied JSON bytes.
`Sun2000EvidenceInputLimits` exposes `MaxBytes` and `MaxRecords`; both must be positive and have no device-derived defaults.
`MaxBytes` bounds supplied bytes; `MaxRecords` counts every JSON object, including envelope, evidence, candidates, wrappers, alternatives, unit and map values.
Arrays consume no records but remain byte-bounded; nesting beyond 64 levels is rejected for parser resource protection.
Errors contain one bounded static message without echoing caller fields, values, identifiers or malformed JSON.

A successful parse returns `Sun2000EvidenceInput` with `Subject()`, `Evidence()` and `Candidates()` accessors.
Evidence records expose identifier, source, locator, context and claim level; candidates expose identifier and typed `Family()`, `Model()`, `Firmware()`, `Unit()` and `Map()` wrappers.
Wrappers expose `State()`, optional `Detail()`, `Refs()`, `Alternatives()` and `(value, present)` through `Value()`.
Unit values expose `Context()` and `Binding()`; map values expose `Document()`, `Revision()` and `Applicability()`.
Record fields are private, slices and nested views are detached, strings and typed scalar records are immutable, and no input buffer is retained.

The parser enforces closed case-sensitive keys, required fields and exact JSON types, rejects repeated JSON keys and identifiers, resolves reference identifiers and checks wrapper coherence.
Contradictions require distinct typed alternatives and the exact union of their references; reference order does not select a candidate.
Unit contexts, including contradictory alternatives, must equal the envelope subject.
Present family is exactly `SUN2000`; other nonempty native family strings are allowed only as contradictory alternatives.
Duplicate candidate structures with different identifiers are rejected using all five wrapper states, values and sorted alternative values, excluding detail and reference identifiers.
This identity comparison is structural and does not evaluate candidate completeness.

## Retained state and loss states

The snapshot retains typed evidence metadata and candidate wrappers; it neither resolves locators nor verifies evidence retention.
The documented wrapper states are `missing`, `unavailable`, `present` and `contradictory`; the tests exercise them independently.
A zero snapshot is not validated input, and an error returns an empty snapshot.
The caller must check the error and retain its prior valid snapshot where its own lifecycle contract permits it.
Current, retained and invalidated lifecycle states, cross-attempt identity fences and partial last-known-good storage policy remain Unknown for this component; they are not defined by its documented snapshot boundary.
The stated structural identity constraints do not establish lifecycle continuity.
Later MCP and GraphQL projections must preserve native denial and evidence meaning on both surfaces, with projection loss explicit; this component adds neither projection.

## Synthetic verification

The implementation PR reports synthetic negative controls, identity-axis tests and mutation evidence.
Its API documentation reports self-contained synthetic family, firmware, binding and map labels and independent exercise of the four wrapper states.
These are synthetic proof of the reported structural scope, not device qualification or hardware acceptance.
Mutation operators, execution totals and per-axis mutation results are Unknown in the reported evidence; no such coverage claim is made here.
A structure-valid synthetic candidate with all five fields present remains an unverified claim.

## Boundaries and remaining acceptance

The component does not resolve locators, verify retention, inspect private evidence, qualify provenance, assess map applicability, evaluate completeness, rank candidates or return a detector result envelope.
It adds no detector, catalog entry, register map, decoder, transport, read schedule, gateway integration, MCP projection or GraphQL projection; registration and application surfaces remain unchanged.
Structural validity establishes no acquisition, support, write authority or profile admission.
This page is the public architecture companion required before or with modbusreg PR #315 to release its documentation merge hold.
This is a partial parent slice: Refs modbusreg #296 and #199; the parent integration issue stays open.
Parent integration, evidence qualification, acquisition and physical acceptance remain separate work, and no hardware acceptance is claimed.
