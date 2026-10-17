# Growatt Protocol II FC04 Admission Record V1

## Scope and current evidence

This page proposes a future exact-profile admission record and validation
algorithm for the TL3-X MAX/MID/MAC families. It supplies no successful record,
allowlisted tuple, decoder, constructor, acquisition, or runtime admission.
`NO_ADMISSIBLE_PROFILE` remains the current result: no exact tuple and no typed
field. The historical V1 name does not declare stability; nothing is stable
before Helianthus 1.0.

The native evidence contracts precede this proposal:

- [Protocol II read-only candidate](protocol-ii-readonly-v1.md)
- [Protocol II source and profile evidence matrix](protocol-ii-source-profile-matrix-v1.md)

| Evidence status | Claim | Separate qualification/admission consequence |
| --- | --- | --- |
| Proven within the published native contract | FC03 identity positions are device type at 43, model-build words at 82 and 83, and reported protocol word at 88; the schema-only FC04 slice is offset 0, width 59 words | Establishes positions and mechanics, not applicability to a device tuple |
| Hypothesis / proposed contract | The exact joins below could support future admission after independent public evidence review | No admission or acquisition is enabled by this page |
| Unknown | An exact device-type, both-model-build-word, reported-protocol tuple bound to the FC04 schema | No current public typed profile or real-build qualification |

The source document revision `1.24` is not the device-reported register value
at FC03 offset 88. Do not parse, encode, round, or substitute that document
revision into the identity tuple. Family selection, readable registers,
firmware text, and input assertions cannot establish the missing mapping.

## Proposed public record fields and equality joins

All fields below are mandatory, scalar, and exact. No wildcard, range,
family-wide default, coercion, fallback, or ordered best-match selection is
permitted. Native words are unsigned 16-bit integers; keep both model-build
words in register order without concatenating or normalizing them. Offsets are
zero-based PDU offsets and widths count 16-bit register words.
`family` is one exact family label, `function` is a function-code integer,
`offset` is a nonnegative integer, and `width_words` is a positive integer.
Each reference is a nonempty, exact catalog identifier, never executable input.

`R` denotes an untrusted proposed record, `I` the coherent native FC03 identity
observation accepted under the existing identity contract, `E` an independently
reviewed public tuple-to-schema evidence entry, and `S` its exact source schema.
These are symbolic operands, not populated examples. The public record contains
no serial, endpoint, unit address, firmware identifier, installation metadata,
or acquisition time. It is a profile mapping, not a replacement native identity
record; the existing full identity gate still applies in the runtime owner.

| Required field in R | Required equality and validation | Single-field symbolic falsifier; disposition |
| --- | --- | --- |
| `family` | Equals I's selected family and E's exact family within the TL3-X MAX/MID/MAC scope | Replace only R.family with a different symbolic family; mismatch → invalid |
| `device_type` | Equals I's FC03 word 43 and E.device_type | Replace only R.device_type with a distinct in-range word; mismatch → invalid |
| `model_build_word_82` | Equals I's FC03 word 82 and E.model_build_word_82 | Replace only R.model_build_word_82 with a distinct in-range word; mismatch → invalid |
| `model_build_word_83` | Equals I's FC03 word 83 and E.model_build_word_83 | Replace only R.model_build_word_83 with a distinct in-range word; mismatch → invalid |
| `reported_protocol_word` | Equals I's FC03 word 88 and E.reported_protocol_word; no derivation from document revision | Replace only R.reported_protocol_word with a distinct in-range word; mismatch → invalid |
| `source_schema_ref` | Resolves one exact schema edition and amendment identity; equals E.source_schema_ref and S's identity | Replace only R.source_schema_ref with another schema identity; mismatch → invalid |
| `function` | Equals E.function and S.function and is exactly FC04 | Replace only R.function with FC03; invalid |
| `offset` | Equals E.offset and S.offset; this proposal covers only 0 | Replace only R.offset with a distinct nonnegative offset; invalid |
| `width_words` | Equals E.width_words and S.width_words; this proposal covers only 59 | Replace only R.width_words with a distinct positive width; invalid |
| `field_schema_ref` | Resolves one exact field-definition edition within S; equals E.field_schema_ref | Replace only R.field_schema_ref with a different field-definition reference; mismatch → invalid |
| `tuple_evidence_ref` | Resolves one current, independently reviewed, publishable E binding every preceding field together | Replace only R.tuple_evidence_ref with an unreviewed assertion reference; missing / insufficient evidence |

The exact source schema reference must distinguish amendments even when a
vendor reuses its document revision label. A title, mutable locator, family
label, document revision alone, or caller-supplied schema name is insufficient.
The field-schema reference identifies the exhaustive field definitions, their
offsets, widths, word order, signedness, scaling, units, enum/invalid handling,
and opaque remainder policy. It cannot extend typing to unlisted words. These
references identify reviewed public definitions; their strings alone do not
prove that definitions or tuple evidence exist.

The required E must publish the actual tuple-to-schema relationship and its
review disposition. An input record, synthetic fixture, successful decode,
vendor-name assertion, or copied schema reference cannot review itself. No
such E is established by the current anchors. Source provenance must respect
their publication and licensing boundary; inspection-only material is not
made redistributable by this proposal.

## Proposed fail-closed validation algorithm

1. Preserve native observations under their existing retention rules. Validate
   I with the existing coherent FC03 identity contract first; this reduced
   public record cannot bypass any of its required fields or overlap checks.
   Missing, malformed, inconsistent, or ambiguous identity stops admission.
2. Require every R field exactly once with its declared type and domain.
   Reject absent fields, malformed references, out-of-range words, unknown
   fields, duplicate keys, coercions, and invalid extents. Never repair inputs.
3. Resolve the source, field definitions, and tuple evidence in the independent
   reviewed public catalog. Require one current E and one exact S. Missing
   review or applicability is insufficient evidence. Multiple applicable
   entries or conflicting definitions are ambiguous even if one looks usable.
4. Apply every equality in the field table conjunctively. Join the whole tuple
   and schema in the same E; do not combine a device-type mapping from one
   entry with a model-build or protocol mapping from another. Confirm field
   definitions fit wholly in the declared FC04 extent and retain untyped words
   as native raw evidence where the owning contract permits.
5. Recheck that E, S, and the field definitions are still the reviewed current
   editions when consuming the decision. Any amendment or withdrawal makes
   the earlier decision unusable; a cached comparison cannot survive it.
6. Only a future owning implementation with the missing public evidence and
   its own acceptance proof could consume a valid decision. That decision
   would establish exact schema applicability only. Bounded acquisition,
   frame validation, decoding, transport safety, and real-build qualification
   remain separate requirements. Today every public attempt still ends at
   `NO_ADMISSIBLE_PROFILE`, producing no typed FC04 record or observer.

The public successful constructor remains absent. Zero values and externally
constructible applicability values continue to fail closed. The existing
unexported synthetic helper stays private and cannot establish real-build
qualification. These review examples do not introduce another helper or a
runtime success path.

## Dispositions and source transitions

These are proposed validation reasons, not new runtime API status values.
Every non-admitted outcome produces no newly typed record. Retention is never
permission to treat historical data as current.

| Condition or transition | Disposition | Evidence and publication consequence |
| --- | --- | --- |
| Any required field absent, E absent/unreviewed, or applicability unknown | Missing / insufficient evidence | Keep permitted native evidence; no admission |
| Any field has wrong type/domain, duplicate/unknown key, bad extent, unresolved malformed reference, or failed equality | Invalid | No admission; preserve permitted raw evidence and reason |
| Multiple candidate mappings, contradictory definitions, mixed identity snapshots, or competing profile match | Ambiguous | No admission; never resolve by ranking or registration order |
| Every comparison hypothetically holds but current public mapping is still absent | `NO_ADMISSIBLE_PROFILE` | Symbolic consistency and synthetic mechanics confer no admission |
| A future reviewed source, tuple mapping, or field definition is amended, superseded, or withdrawn | Invalidate current admission and derived applicability immediately | Retain historical raw evidence with its original source association; require fresh independent review and full revalidation |
| A subsequent acquisition fails or supplies only partial evidence | No new complete typed record | Preserve existing permitted partial last-known-good state with its historical/freshness status; do not replace it with partial new values or promote it to current admission |

A source amendment does not rewrite old raw words or erase their provenance.
Previously derived values may remain historical under the owner's retention
policy but cannot be presented as currently admitted. Revalidation must use the
new exact schema and reviewed mapping; identical title or revision text does
not carry approval forward. No recovery, receipt, or idempotency mechanism is
defined here.

## Symbolic review cases and remaining acceptance

The single-field falsifiers in the field table are independent reasoning cases.
For each row, hold all other symbols fixed and replace only the named field;
the equality/domain predicate must fail. This is a conditional proof obligation,
not a valid baseline tuple, executable fixture, or fabricated successful record.
Removing each field alone must yield missing evidence; making each reference
resolve to multiple conflicting definitions must yield ambiguity. Adding a
second conflicting E without changing R must also fail closed. An algorithm
that omits any named comparison, treats missing as default, accepts caller
review, or keeps admission after a source amendment violates this proposal.
For the amendment falsifier, hold R and the native observation fixed and change
only S's amendment identity; the prior decision must become unusable even if
the document's revision label is unchanged.

These are reasoned falsifiers, not executed mutation tests. This contract adds
no K21, M52, or S06 implementation/test evidence. Remaining acceptance includes
reviewed publishable tuple-to-schema evidence, owning-runtime validation and
negative tests, bounded FC04 acquisition/decoder proof, and any separately
required real-build qualification. The broader native-readiness parent remains
open. Existing admission/trust, eBUS MCP envelopes, and GraphQL parity remain
unchanged; this page supplies no projection, control operation, or live write.
