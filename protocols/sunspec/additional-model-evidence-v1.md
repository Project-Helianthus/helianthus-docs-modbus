# SunSpec Additional Model Documentary Evidence V1

## Native contract and evidence status

The [read-only core V1](read-only-core-v1.md) is the native authority for the
admitted decoder catalog, model headers, declared block extents, and rejection
rules. This note preserves additional documentary evidence; it does not extend
that contract. The [V1 model-family guide](read-only-core-v1-model-families.md)
explains the existing catalog without adding decoder tuples.

`Proven` here means that a statement is recorded in the inspected public
documentation snapshot. It does not mean independently verified upstream
content, device behavior, or qualification. Device availability, decoding on a
device, control behavior, and write authority are `Unknown` from this evidence.
Any proposed device applicability remains `Hypothesis` pending separate
evidence and qualification; this note qualifies no family or operation.

## Retained documentary facts

The [original documentary note](https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/main/protocols/sunspec/additional-model-evidence-v1.md)
records grid/control model identifiers **125 through 145** in the Apache-2.0
[SunSpec model catalog](https://github.com/sunspec/models). This range is
documentary-only. It is outside the admitted V1 decoder catalog and is not a
missing decoder to enable. A control-related catalog name creates no operation
or write permission.

The source also records the standard signature request context: **FC03, PDU
offset 40000, quantity 2 registers**. This is documentary read-request context,
not an instruction to probe an installation or an admitted acquisition plan.
It establishes no unit, transport endpoint, retry policy, or device response.

The source's integer and FLOAT AC-meter families and environmental families
are already covered by the core V1 catalog. Its model-header and declared-length
statements are covered by the core's chain structure. Those duplicated facts
remain at the linked native contract rather than being a second catalog here.

## Provenance and publication boundary

The [migration inventory](https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/main/development/modbus-sunspec-deduplication.md)
separates this documentary range and signature context from executable decoder
admission. The source note attributes its catalog statements to an inspected
upstream revision. The public source and catalog links above are moving
references, including the catalog's default branch; they do not reproduce that
revision immutably or establish that today's upstream content is identical.

The catalog is attributed as Apache-2.0 input inspected for protocol facts.
This independently stated note is CC0-1.0 under the repository's
[license policy](../../LICENSE) and
[applicability and licensing contract](../applicability-and-licensing.md).
Inspection-only attribution does not relicense upstream material. No vendor
manual, upstream table, generated model file, or extracted description is
redistributed. Helianthus application policy remains in its separate AGPL lane.

## Version and safety limits

The [read-only V2 contract](read-only-core-v2.md) has a distinct schema revision
and model scope. It is not a replacement for V1 and does not admit the
documentary range 125 through 145. This note supplies no decoder key or fallback
between V1 and V2.

These documentary facts do not establish device availability, executable
decoding, control behavior, or write authority. They authorize no device
operation, control, Modbus write, automatic discovery, or runtime admission.
Missing or conflicting evidence remains fail-closed under the native contracts;
unknown blocks retain their native raw evidence. A failed acquisition or
admission must retain available evidence and separately labelled partial
last-known-good state, without presenting it as a newly admitted result.
Moving this evidence changes no eBUS MCP or GraphQL consumer behavior.
