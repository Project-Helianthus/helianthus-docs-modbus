# SunSpec Nested Layout Contract V1

## Scope

This contract defines the offline decoder boundary for a count-driven nested SunSpec occurrence.
It is an implementation-oriented structural contract, not a model-admission, product-support, or runtime contract.

## Template selection

An immutable schema template is selected only by the exact schema revision and model identifier.
A declared length never selects a template and is never an expanded-layout cache key.
A template describes only static fields, named count locations, and permitted nested group shapes; it does not represent an occurrence-specific expanded layout.

## Per-occurrence validation

A layout is instantiated for one occurrence only after every documented count and its declared length validate together.
The decoder reads each count only from the documented occurrence-relative offset, validates its permitted domain and sentinel state, and uses checked arithmetic to verify the exact declared length and available raw extent.

It must not infer counts from a declared length, an activation point, or trailing words.
A nested group does not establish a parent, child, sibling, or repeat relationship outside that occurrence.

## Hierarchical paths and offsets

Nested facts retain all group and point indices.
`Crv[2].MustTrip.Pt[5].Hz` is a hierarchical path, not a flattened repeat index.
The path identifies both its group hierarchy and the point inside the group; a single repeat index cannot substitute for that information.

Offsets are relative to the occurrence and map each decoded point to exact source spans.
A source span records its logical view, PDU offset, and word count.
An occurrence may have fragmented source spans, so a decoder must not synthesize one contiguous source coordinate when the raw input does not have one.

## Bounds and allocation

Checked arithmetic applies before every extent, aggregate, fact-count, or allocation decision.
The implementation must bound declared length, per-occurrence raw words, aggregate chain extent, emitted facts, and allocated layout state before it expands a nested group.
It must reject overflow, underflow, partial groups, source-span overrun, and any count/length mismatch.

Zero is valid only when the selected model contract explicitly permits it.
No memory or fact capacity may be reserved from an unvalidated count, and no implementation may silently truncate a count or calculated extent.

## Failure and isolation

Invalid geometry remains raw-only with zero typed facts.
The occurrence and its raw source spans remain available for inspection, but no partial typed facts are emitted.
A future valid occurrence is evaluated independently; an invalid one does not poison a different occurrence.

V1 templates, caches, and outputs remain isolated and unchanged.
V1 and later revisions must not share template selection, expanded-layout cache entries, or typed outputs.

## No-send boundary

All decoded fields are observed state only.
This contract creates no runtime, vendor, transport, gateway, live-I/O, write, send, or operation behavior.
It does not admit a profile, catalog entry, acquisition path, or device.

## Bounded examples

Models 707, 708, and 709 are bounded examples only and do not define Model 710 or any other model.
Their model-specific documents define their individual count locations, fields, and point spans.
This generic contract neither restores their typed decoding nor supplies a decoder for them.

## Compatibility

A model-specific contract and a separate registry change are required before a new nested model can emit typed facts.
That change must preserve this contract's per-occurrence validation, hierarchical paths, source spans, bounds, raw-only failure behavior, and V1 isolation.
