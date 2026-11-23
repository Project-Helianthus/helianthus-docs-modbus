# SunSpec Additional Model Documentary Evidence V1

## Native contract and evidence status

The [read-only core V1](read-only-core-v1.md) is the native authority for the
admitted decoder catalog, model headers, declared block extents, and rejection
rules. This note preserves additional documentary evidence; it does not extend
that contract. The [V1 model-family guide](read-only-core-v1-model-families.md)
explains the existing catalog without adding decoder tuples.

`Proven` here means that a statement is recorded in the inspected public
documentation snapshot. It does not mean independently verified upstream
content or device behavior. Device availability and source identity that this
note does not state stay `Unknown`.

## Retained documentary facts

The [original documentary note](https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/977614c944cd685bef75b5b12148e1110ed7653a/protocols/sunspec/additional-model-evidence-v1.md)
records grid/control model identifiers **125 through 145** in the Apache-2.0
[SunSpec model catalog](https://github.com/sunspec/models). Models 125 through
145 are registers in the
modbusreg namespace, with no SemReg element. Unknown device and source facts
remain unknown. This range is outside the admitted V1 decoder catalog.

The source also records the standard signature request context: **FC03, PDU
offset 40000, quantity 2 registers**. This is documentary read-request context,
not an instruction to probe an installation or an admitted acquisition plan.
It establishes no unit, transport endpoint, retry policy, or device response.

The source's integer and FLOAT AC-meter families and environmental families
are already covered by the core V1 catalog. Its model-header and declared-length
statements are covered by the core's chain structure. Those duplicated facts
remain at the linked native contract rather than being a second catalog here.

## Provenance and publication boundary

The [migration inventory](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/development/modbus-sunspec-deduplication.md)
separates this model range and signature context from the V1 decoder catalog. The source note attributes its catalog statements to an inspected
upstream revision. The public source and catalog links above are moving
references, including the catalog's default branch; they do not reproduce that
revision immutably or establish that today's upstream content is identical.

The catalog is attributed as Apache-2.0 input inspected for protocol facts.
This independently stated note is CC0-1.0 under the repository's
[license policy](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/LICENSE) and
[applicability and licensing contract](../applicability-and-licensing.md).
Inspection-only attribution does not relicense upstream material. No vendor
manual, upstream table, generated model file, or extracted description is
redistributed. Helianthus application policy remains in its separate AGPL lane.

## Version and safety limits

The [read-only V2 contract](read-only-core-v2.md) has a distinct schema revision
and model scope. It is not a replacement for V1 and does not list models 125
through 145. This note supplies no decoder key or fallback between V1 and V2.

Models 125 through 145 are registers in the modbusreg namespace, with no SemReg element. Unknown device
and source facts remain unknown. These facts do not establish device
availability where the documentation does not state it. Missing or conflicting
evidence remains fail-closed under the native contracts;
unknown blocks retain their native raw evidence. A failed acquisition or
admission must retain available evidence and separately labelled partial
last-known-good state, without presenting it as a newly admitted result.
Moving this evidence changes no consumer compatibility or parity obligation.
