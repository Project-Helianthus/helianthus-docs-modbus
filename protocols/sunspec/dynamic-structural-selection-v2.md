# SunSpec V2 Dynamic Structural Selection Contract

## Scope and classification

This contract defines one offline structural classification for exactly Model
707 under `sunspec.models@90b4a331-v2`. A `structural_candidate` is a
post-payload observation state. It is not `admitted`, has no decoder key,
emits no typed fact, and does not establish a product or profile.

The state describes only the structural validity of one complete occurrence.
It is not a decoder selection, catalog entry, runtime activation, or support
claim.

## Post-payload candidate rule

A `structural_candidate` is considered only after the complete occurrence
payload and every ordered source span are present. It must never be selected
from a header, model identifier, declared length, or any partial payload.

The candidate rule requires all of the following:

- exact V2 schema revision and Model 707 identifier;
- a header whose declared `L` equals the complete occurrence payload extent;
- `P` from occurrence-word offset 5 and `C` from occurrence-word offset 6;
- `P` and `C` each in the inclusive range 0 through 65534, excluding
  `0xffff`; and
- checked `L = 7 + C*(4 + 9*P)`, within the existing isolated extent boundary,
  with every occurrence word covered by exact ordered source spans.

`P` and `C` are never inferred from `L`, an activation point, trailing words,
or a model-specific length list. The candidate rule does not enumerate Model
707 lengths and does not create decoder keys for those lengths.

## Failure and raw retention

Any wrong identifier or revision, unavailable count, count/length mismatch,
overflow, extent excess, partial payload, or incomplete source coverage is not
a `structural_candidate`. The complete occurrence remains raw-only with its
wire order, declared length, ordinal, raw words, and exact source spans.

Failure does not emit a partial fact, infer a replacement count, or alter a
different occurrence.

## Acquisition and terminal boundary

The existing generic chain obtains payload fragments from the declared header
length before this classification. A `structural_candidate` does not cause a
new request, retry, reconnect, deadline extension, or read-plan change. It
cannot bypass the existing address, occurrence, total-word, or per-request
bounds.

A candidate does not terminate a chain. Only the existing terminal marker has
terminal meaning; after a completed non-terminal occurrence, the chain retains
its current next-header behavior.

## Isolation and no activation

V1 selection, keys, raw outputs, and behavior remain unchanged. Models 708 and
709 remain outside this contract and do not become candidates through Model
707 data or structure.

This contract creates no operation, write, send authority, vendor activation,
catalog activation, transport behavior, gateway behavior, or live I/O.
