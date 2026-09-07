# OutBack AXS Port Public Source and Profile Matrix V1

## Purpose and publication boundary

This matrix records the public sources examined for the OutBack AXS Port
SunSpec candidate. It is an evidence and qualification record, not a register
map, fixture, operation recipe, support claim, or device observation. It does
not reproduce the vendor tables.

The two sources are vendor-copyright-inspection-only. The stated field facts
are limited to independently necessary interoperability identifiers, spans,
types and applicability outcomes. No vendor PDF, screenshot, endpoint, serial,
credential, network address, or private capture is included here.

## Pinned public sources

| Source key | Public title and version | Retrieval URL | SHA-256 | Relevant locator | Applicable facts |
| --- | --- | --- | --- | --- | --- |
| `outback.axs.owner-manual.rev-c` | *AXS Port SunSpec Modbus Interface Owner's Manual*, part `900-0138-01-00 Rev C`, April 2016; PDF metadata title `Microsoft Word - 900-0138-01-00 REV C.docx` | <https://www.outbackpower.com/downloads/documents/system_management/axs_port/axs_manual.pdf> | `2b770dadd723c2288f3cbd73ec93807cbaf4611fe3a27653dd256572ac155b88` | PDF pages 11-12, Table 1; PDF page 12, Table 2 | 64110 declares length 282. Its candidate read-only spans are firmware 2-4 (`uint16`), battery temperature 278 (`int16`), ambient temperature 279 (`int16`), temperature scale 280 (`int16`), error 281 (`uint16` bitfield), and status 282 (`uint16` bitfield). It depicts 64111 length 23. |
| `outback.axs.application-note.rev-5` | *SunSpec Data Blocks and the AXS Port*, Application Note, PDF metadata title `Microsoft Word - AXS App Note Rev 5.docx`, metadata creation date 2016-04-27 | <https://www.outbackpower.com/downloads/documents/system_management/axs_port/axs_app_note.pdf> | `9daf21413ea2c8bb1eeebe4eadc5f1c02da2337ccfc818f86fb3602109e76230` | PDF pages 2-5, Table 1; PDF page 6, Table 5 | 64110 declares length 420 and moves the observed temperature/error/status region. It depicts 64111 length 26. |

## Finite profile selector

A future provider receives the complete immutable source descriptor and the
raw response sequence. It selects `outback.axs.sunspec.readonly.v1` only when
all of the following are proved by an additional public, product- and
firmware-specific compatibility source:

1. the exact AXS product and firmware identify one of the two source keys;
2. the source's declared 64110 length and every requested source span agree
   with the complete model response;
3. the required Common Model and every model-chain prerequisite are complete;
   and
4. an operation-specific source supplies the read table, function, absolute
   start address, response-size bound, timeout and retry bound.

The existing public corpus does not satisfy items 1 or 4. It also contains the
explicit conflict `64110/282` versus `64110/420`, and `64111/23` versus
`64111/26`. Therefore the selector result is **`NO_GO`**. A `64110/282` chain
is an offline structural candidate only; it is not a product/profile/firmware
qualification. `64111` remains opaque in every outcome.

## Read-only operation matrix

| Operation | Function/table/start/quantity | Response, timeout and retry | Disposition |
| --- | --- | --- | --- |
| Source qualification read | Not specified by either pinned source | Not specified by either pinned source | `NO_GO`; no acquisition request is admitted. |
| 64110 candidate read | Not specified by either pinned source | Not specified by either pinned source | `NO_GO`; no function, address, quantity, response bound, timeout or retry is inferred. |
| 64111 read | Not specified by either pinned source | Not specified by either pinned source | `NO_GO`; opaque block only. |
| Write/control/configuration | No operation is admitted | No request is constructed | `NO_SEND`. |

A future operation contract must name a read-only function, table, absolute
start address, exact quantity, maximum response bytes, bounded timeout and
retry count. It must be source-pinned before a provider issues any request.

## Requested native-output and evidence inventory

| Requested output | Current disposition | Evidence dependency |
| --- | --- | --- |
| 64110 firmware major, mid and minor | `MISSING_EVIDENCE` | Exact product/firmware binding to the 282 or 420 source, plus an admitted read operation. |
| 64110 battery and ambient temperature | `MISSING_EVIDENCE` | Same binding and operation evidence; preserve signed raw words and only apply the selected source's valid scale. |
| 64110 temperature scale, error and status | `MISSING_EVIDENCE` | Same binding and operation evidence; status/error values remain numeric raw evidence unless a separate source licenses a meaning. |
| complete 64110 raw block and source spans | `MISSING_EVIDENCE` | Immutable response sequence and source descriptor from an admitted provider. |
| 64111 values | `MISSING_EVIDENCE` | A single compatible public source and an exact product/firmware binding; until then 64111 is opaque. |

No missing row is a scope exclusion, supported output, semantic fact, generic
inverter proof, or permission to synthesize a value.

## Qualification, replay and provenance outcomes

The provider must return `NO_GO` and no partial typed output for wrong product, unknown firmware, wrong source revision, wrong 64110 or 64111 length, duplicate or conflicting occurrence, malformed header or length, incomplete response, timeout, retry exhaustion, invalid scale, unknown field, or a response that cannot be bound to the selected source descriptor.

For every replay candidate, retain immutable copies of the request bytes,
response bytes, function/table/address/quantity, response-size result, timeout
and retry outcome, source URL, source SHA-256, source key, product/firmware
selector inputs, model-chain order, model offsets and raw word spans. A rejected
candidate retains no typed facts. Provenance is diagnostic evidence, never an
operation authorization token.

Every write, control, configuration, password, network and firmware-update path remains `NO_SEND`.
