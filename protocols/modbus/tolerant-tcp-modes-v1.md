# Tolerant TCP Framing and Device-Identification Modes V1

## Scope and evidence basis

This is the transport contract for two opt-in modes of the Helianthus Modbus TCP
transport, written for logger-class devices. It records how a caller selects
each mode, what stays strict by default, the bounds, what the tolerant decoder
guarantees, and the vocabulary of named deviations it reports. The strict
reading these modes depart from is stated in the
[Modbus wire reference](modbus-phase-one-wire-v1.md), sections "Modbus TCP ADU"
and "FC2B/MEI0E Read Device Identification". This page does not change that
reference, which remains the statement of the protocol, and it does not change
the separate [private-function transport contract](private-function-codes.md).

The modes were added to the transport library by helianthus-modbus issue 123
and its pull request 124, which is merged. The behaviour that motivates them is
recorded on the
[SmartLogger observation](../huawei/smartlogger-observed-inventory-v1.md); its
statement identifiers (SL-nn) are cited below instead of repeating its values.
This page defines no register map, listing decoder, profile, acquisition
schedule, or admission. Which device classes may use a mode, how a count object
or an attribute is read, and which anomalies a profile accepts belong to the
registry and the consuming driver. The historical V1 name implies no stability
before Helianthus 1.0.

| Grade | Meaning on this page |
| --- | --- |
| Proven | About the library: read directly from the merged source and its offline tests, which replay sanitized recorded responses and synthetic pages through an in-memory peer. About a device: as graded on the SmartLogger observation, for the observed installation only. |
| Hypothesis | Reasoned from the source or from observed structure, and not exercised by a test or by a second independent reading. |
| Unknown | No evidence. |

Grades are separate from parser acceptance, identity matching, admission,
qualification, and support. No live device was connected to the library for this
change, so nothing here is a device-compatibility, qualification, or support
claim. If this page conflicts with the merged library, the library controls and
this page requires correction.

## Strict behaviour and defaults

Both modes are off unless a caller selects them. The zero value of each selector
is strict, so every existing caller, and every endpoint or plan that sets
nothing, reads as it did before the modes existed.

| ID | Statement | Grade |
| --- | --- | --- |
| TM-01 | The framing selector `TCPFraming` has the zero value `TCPFramingStrict`, and the decoding selector `DeviceIDDecoding` has the zero value `DeviceIDDecodingStrict`. | Proven |
| TM-02 | Strict framing accepts an MBAP length of 2 to 254, which is a PDU of at most 253 bytes and an ADU of at most 260 bytes, as the wire reference states. Any other length fails as a malformed response at field `length`, offset 4, and the endpoint then requires a reconnect. The failure is a plain protocol error, not a frame error that carries raw bytes. | Proven |
| TM-03 | Strict decoding validates each page against the wire reference and stops at the first deviation with a named malformed-response error. It publishes only a complete validated aggregate. | Proven |
| TM-04 | Strict decoding rejects a response PDU above 253 bytes (`response_length`) under either framing mode. | Proven |
| TM-05 | Strict reading rejects the logger-class responses that the SmartLogger observation records: an over-full basic reply fails at `requested_category`, a count-only first inventory page fails at `object_header`, and a 263-byte page fails the framing check at `length`. The replay of the sanitized responses asserts all three. | Proven |

## Selection

A caller selects framing once per endpoint and decoding once per plan. The two
selectors are independent.

| Mode | Selector | Granularity | Validation |
| --- | --- | --- | --- |
| Tolerant framing | `TCPEndpointConfig.Framing`, carried into `TCPTransportConfig.Framing` for every connection the endpoint opens. `NewTCPStreamDecoderWithFraming` builds a bare decoder. | Per endpoint: every connection and every unit identifier behind it. | An unknown value is rejected at construction. Tolerant framing needs a buffered-byte bound (`MaxBufferedBytes`) of 4103 to 65536 bytes, and the transport read buffer is sized to the largest frame the mode accepts. |
| Tolerant decoding | `TCPDeviceIDPlan.Decoding` | Per plan: one FC2B/MEI0E traversal. | An unknown value is rejected when the plan is enqueued, with field `device_id_decoding`, and nothing is queued. The value is carried through owner reservations, tombstones, and retries. |

| ID | Statement | Grade |
| --- | --- | --- |
| TM-06 | Each selector is fixed when the endpoint is constructed or the plan is enqueued. A retry restarts at the initial cursor with the same decoding, and the endpoint's framing applies to the reconnected socket. | Proven |
| TM-07 | One endpoint has one framing for all of its units, so a gateway that fronts children cannot be tolerant for one unit and strict for another. A caller that needs strict reading for a conforming device uses a separate endpoint for it. | Proven |

The four combinations are all valid:

| Framing | Decoding | Behaviour | Grade |
| --- | --- | --- | --- |
| Strict | Strict | The default. Conforming devices read exactly as before. | Proven |
| Strict | Tolerant | Pages that fit in 253 bytes decode with anomalies. A longer frame fails the framing check, the connection is renewed, and the retry restarts at the initial cursor. The replay decodes the count-only first page and then fails at the 263-byte page. | Proven |
| Tolerant | Tolerant | The logger-class combination. Every response in the sanitized replay is delivered and decoded. | Proven |
| Tolerant | Strict | An oversize frame is delivered and observed, and the strict decoder then rejects its PDU as malformed (TM-04). The received bytes stay on the wire response. | Proven |

Strict is the default for two reasons recorded with the change. The library
requires bounded, fail-closed reads and keeps vendor-specific admission in the
profile registry rather than in a global runtime default. Tolerance also belongs
to a device class, so the composing driver or profile selects it, framing per
endpoint and decoding per plan.

## Choosing a mode

The rules below are proposed consumer requirements. They are not library
behaviour, and they create no admission.

| Situation | Choose | Basis |
| --- | --- | --- |
| A conforming device, an unknown device, or any endpoint used for register reads only | Strict framing and strict decoding | No observation records a deviation. TM-01 makes this the default. |
| An endpoint that fronts a device class whose observation records a response PDU above 253 bytes on a read the profile admits | Tolerant framing on that endpoint | SL-14. Without it the connection is dropped at the first oversize response (SL-15). |
| An identification plan against a device class whose observation records page deviations, such as a count-only page, a declared-object field that is not a per-response count, or a basic reply that carries extra objects | Tolerant decoding on that plan | SL-05, SL-11, SL-13. Without it the traversal fails at the first deviating page (SL-15). |
| Register reads (FC03, FC04) on a tolerant endpoint | Nothing further | They stay strictly decoded under either framing mode (TM-14). |
| A failure under strict reading | Not a reason to retry in tolerant mode | A mode is configuration chosen by the profile or driver that owns the endpoint, before the first send. |

1. Choose by the recorded observation of a device class, never by trial. A
   strict failure on a device without such a record is insufficient evidence,
   not a prompt to widen the reader.
2. Scope tolerance narrowly: tolerant framing on the endpoint that fronts the
   logger-class device, tolerant decoding on the identification plans that read
   it, and neither elsewhere.
3. Tolerance admits bytes, not meaning. A delivered oversize PDU or a page with
   anomalies is native evidence. It supplies no identity, inventory, admission,
   or qualification.
4. Gate on named anomalies. A consumer lists the anomaly names it accepts for
   each operation, and treats every other name and every result with `Complete`
   false as insufficient evidence. Such a result is retained as native evidence
   and never replaces a last-complete inventory, in line with the
   [SmartLogger provider lifecycle](../huawei/smartlogger-provider-lifecycle-v1.md).

## Tolerant TCP framing

Tolerant framing reads each frame by its MBAP length, independently of
socket-read boundaries, while the PDU is at most `MaxTolerantPDUSize` (4096)
bytes.

| Quantity | Strict | Tolerant |
| --- | --- | --- |
| MBAP length field | 2 to 254 | 2 to 4097 |
| PDU | at most 253 bytes (`MaxPDUSize`) | at most 4096 bytes (`MaxTolerantPDUSize`) |
| ADU | at most 260 bytes | at most 4103 bytes |
| Buffered-byte bound | 7 to 65536 bytes | 4103 to 65536 bytes |
| Transport read buffer | 260 bytes | 4103 bytes |

All rows are Proven.

| ID | Statement | Grade |
| --- | --- | --- |
| TM-08 | A frame with a PDU of 254 to 4096 bytes is delivered whole, with its exact bytes, however the stream is fragmented. A conforming frame before or after it is delivered as before and is not reported as oversize. | Proven |
| TM-09 | An oversize PDU is reported in four places: `TCPADU.OversizePDU`, `WireResponse.OversizePDU`, the `oversize_pdu` detail on the `response_receive` event (which carries the raw ADU as hex), and the `OversizePDUResponses` counter in the endpoint metrics. | Proven |
| TM-10 | A length above 4097, a length below 2, a non-zero protocol identifier, and a truncated frame at the end of the stream fail with `*TCPFrameError`. Its `Raw` field keeps every byte the decoder received but did not deliver, in stream order: frames completed earlier in the same read, the buffered prefix, and the unconsumed remainder. It unwraps to the usual protocol error (malformed response, field `length`, `protocol_id`, or `truncated_adu`), and the decoder holds no bytes afterwards. | Proven |
| TM-11 | After a frame error the transport closes the socket and the endpoint requires a reconnect, so the connection is renewed on the existing recovery path. A retry then restarts at the initial cursor. | Proven |
| TM-12 | The mode relaxes only the length bound. The protocol identifier must still be zero, and a length outside the tolerant bound still fails. | Proven |
| TM-13 | The mode adds no function code, write, or new request shape. Every request on the wire in the replay is an FC2B/MEI0E read, and the library's read-only scope policy is unchanged. | Proven |
| TM-14 | FC03 and FC04 responses stay strictly decoded under tolerant framing. An oversize register response is delivered and observed through TM-09, classified as malformed, produces no logical view, and does not require a reconnect. | Proven |

## Tolerant device-identification decoding

Tolerant decoding turns a traversal from validate-or-reject into
decode-and-describe. `DecodeDeviceIDPage` decodes one response PDU of at most
4096 bytes. `NextDeviceIDPageRequest` builds the continuation, and
`AggregateTolerantDeviceID` folds a page chain into a `DeviceIDTolerantResult`.

| ID | Guarantee | Grade |
| --- | --- | --- |
| TM-15 | Every byte is kept. `DeviceIDPage.PDU` holds the whole response PDU, and a page returned together with an error still holds the received bytes. | Proven |
| TM-16 | Decode what parses. Objects are decoded to the end of the PDU regardless of the declared count. `UndecodedOffset` marks the start of any tail that does not parse, which stays in `PDU`. It equals the PDU length when nothing is left over. | Proven |
| TM-17 | Deviations are named, not rejected. Each deviation in the vocabulary below becomes an anomaly on the page, listed once in first-seen order. The library never rejects a page for an anomaly and does not judge whether one is acceptable. | Proven |
| TM-18 | Some replies remain errors: an exception reply, a different function, a different MEI type, a malformed exception length, and a PDU shorter than the 7-byte header. At the endpoint such a reply ends the traversal on the live socket and publishes no tolerant result. The received bytes stay on the wire response, and no reconnect is required. A response whose PDU is above 4096 bytes is not one of these decoder errors: it fails framing before decoding, as TM-11 states, and the connection is renewed. | Proven |
| TM-19 | Paging runs until more-follows is zero. Any non-zero more-follows value continues the stream while the next object identifier advances past the requested cursor. | Proven |
| TM-20 | Every traversal terminates. Besides the advancing cursor, an arbitrary-start extended stream may wrap backward (0xff to 0x00) at most once. The page count is bounded by `DeviceIDLimits.MaxSegments`, the object count by `MaxObjects`, and the value bytes by `MaxValueBytes`. The defaults are 256 pages, 256 objects, and 62464 value bytes, and a plan may lower a limit but not raise it. | Proven |
| TM-21 | Paging and aggregation follow the received bytes. Each page is decoded again from `PDU`, so editing the exported view fields of a page cannot steer the continuation or the result. | Proven |
| TM-22 | The aggregate keeps the first occurrence of each object identifier and names later ones as `duplicate_object`. `Complete` is true only when the last page carried more-follows zero. `Conformity` is the first page's. `Pages` keeps every page with all of its bytes, and `Anomalies` lists each page and traversal anomaly once, in first-seen order. | Proven |
| TM-23 | Aggregation validates the chain. The first request must not be a continuation, each page must carry the request its predecessor produced, and a page after the traversal closed is an error. Results are independent copies of their inputs. | Proven |
| TM-24 | A traversal stopped at a limit or at an unavailable continuation is published with `Complete` false, the objects decoded so far, and the matching traversal anomaly. | Proven |
| TM-25 | Each unit identifier's reply is decoded independently. The library does not compare replies across units, so detecting that a device answers every unit identically is left to the consumer. | Proven |

Endpoint publication:

| ID | Statement | Grade |
| --- | --- | --- |
| TM-26 | A tolerant traversal publishes `TCPDeviceIDCompletion.Tolerant` with `Decoding` set to tolerant and `Result` empty. A strict traversal publishes `Result` and leaves `Tolerant` empty. | Proven |
| TM-27 | `WireResponse.DeviceIDPage` returns a deep copy and is present only for a tolerant plan, where `DeviceIDSegment` is absent. | Proven |
| TM-28 | The replay of the sanitized inventory issues 13 requests from the initial cursor to the last page, completes, and keeps 13 pages and 13 objects, with 12 oversize observations in events and the counter. | Proven |

## Anomaly vocabulary

The names are stable, and consumers key on them. There are 15 page anomalies,
reported on the page where they occur, and 5 traversal anomalies, reported on
the aggregate. The condition for each is the wire shape alone.

### Page anomalies

| Name | Condition |
| --- | --- |
| `oversize_page` | The PDU is longer than 253 bytes. |
| `count_only_page` | The page has one object whose value is one byte, while its header declares more objects than the page carries. This is a wire-shape heuristic, and interpreting it belongs to the profile. |
| `object_count_mismatch` | The declared number of objects differs from the objects decoded. |
| `object_outside_requested_category` | An object lies outside the requested access category: for example a non-basic object in a basic reply, or a different object in an individual reply. |
| `object_outside_conformity` | An object lies outside the category that the page's own conformity level declares. It is checked only when the conformity value is known. |
| `reserved_object_id` | An object identifier is in 0x07 to 0x7f. |
| `oversize_object_value` | An object value is longer than 244 bytes, the most a conforming PDU can carry. |
| `object_order` | Object identifiers do not ascend within the page, apart from one 0xff to 0x00 wrap on an arbitrary-start extended stream. |
| `duplicate_object` | An object identifier was seen earlier in the page or in the traversal. The first occurrence is aggregated. |
| `truncated_object` | An object header or value runs past the end of the PDU. The bytes from `UndecodedOffset` stay undecoded in the page. |
| `access_code_mismatch` | The reply's read device id code differs from the request's. |
| `conformity_value` | The conformity byte is not 0x01, 0x02, 0x03, 0x81, 0x82, or 0x83. |
| `more_follows_value` | The more-follows byte is neither 0x00 nor 0xff. Any non-zero value continues the stream (TM-19). |
| `next_object_without_more_follows` | The next object identifier is non-zero while more-follows is zero. |
| `more_follows_without_progress` | More-follows is set, but the page has no object or its next object identifier does not advance past its last object. |

`oversize_page` and `oversize_object_value` are independent: a page can exceed
253 bytes while every value is at most 244 bytes, and the replay of a synthetic
page that packs three objects shows this. All rows are Proven.

### Traversal anomalies

| Name | Condition | Stops the traversal |
| --- | --- | --- |
| `conformity_change` | A page's conformity differs from the first page's. | No |
| `mandatory_object_missing` | A standard traversal (basic, regular, or extended access starting at object 0x00) closed without all of the objects 0x00, 0x01, and 0x02. Individual reads and arbitrary-start extended streams are not checked. | No, checked when the traversal closes, complete or not |
| `continuation_unavailable` | A page set more-follows, but no bounded continuation exists: individual access, a cursor that does not advance past the requested cursor, or a second extended wrap. | Yes, `Complete` false |
| `page_limit_reached` | The traversal reached `MaxSegments` while more-follows was still set. | Yes, `Complete` false |
| `aggregate_limit_reached` | The object-count or value-byte limit was reached. | Yes, `Complete` false |

All rows are Proven.

## Observed behaviours that motivate the modes

The [SmartLogger observation](../huawei/smartlogger-observed-inventory-v1.md)
records bounded, read-only reads of one operator-owned installation of the
SmartLogger family. Its grades apply to that installation only. The rows below
pair each record with the mode element that reads it, and with the anomalies
that the replay of the sanitized responses reports.

| Observation | A strict reader | Mode element | Anomalies reported by the replay |
| --- | --- | --- | --- |
| SL-14: twelve of the 13 inventory responses are PDUs above 253 bytes, each holding one object above 244 bytes. | Fails at the framing check and drops the connection (SL-15). | Tolerant framing, with the oversize observation (TM-09). | `oversize_page`, `oversize_object_value` |
| SL-11 to SL-13: the declared-object field is not a per-response count, and the first page carries only a count object. | Fails at the object header (SL-15). | Tolerant decoding. | `object_count_mismatch`, `count_only_page` |
| SL-05: the basic reply carries objects beyond the basic category. | Fails at the requested category (SL-15). | Tolerant decoding, which keeps every object and byte. | `object_outside_requested_category`, `object_outside_conformity`, `reserved_object_id` |
| SL-07: a basic read answers identically whichever unit it names. | Not a strict failure. | Each reply is decoded independently, and the comparison is the consumer's (TM-25). | none |
| SL-16: the next object is the requested cursor plus 1 while more-follows is set, and the last page has more-follows 0x00. | Not a strict failure. | Paging until more-follows is zero (TM-19). | none |

Over the whole inventory the replay reports exactly `object_count_mismatch`,
`count_only_page`, `oversize_page`, and `oversize_object_value`. The basic reply
reports exactly the three anomalies in its row and no `mandatory_object_missing`.
These rows are Proven for the replay of the sanitized responses and say nothing
about other installations.

The observation lists six tolerance requirements for a reader of this logger.
The modes meet the first four, and the last two stay outside the transport:

| Requirement on the observation | Met by | Remaining boundary |
| --- | --- | --- |
| 1. Frame length of at least 263 bytes | Tolerant framing, PDU up to 4096 bytes. | The observation fixes only the lower bound. The library's bound is a design choice (see the limits below), and a consumer that wants a lower finite cap enforces it on the delivered PDU, because the library offers no setting between 253 and 4096. |
| 2. Declared-object field not required to equal the objects present | Tolerant decoding names the mismatch. Completeness comes from more-follows. | Completeness from the count object is a profile check. |
| 3. One object of up to 254 bytes per response | Tolerant decoding accepts it and names `oversize_object_value`. | None in the transport. |
| 4. Basic reply decoded as received, extra objects kept as opaque evidence | Tolerant decoding keeps every object and byte. | Whether a basic reply supplies or negates identity is a profile rule. |
| 5. Count object includes the self entry | Not a transport concern. | Registry. |
| 6. Attribute keys and their order | Not a transport concern. | Registry. |

## Limits and open questions

| ID | Statement | Grade |
| --- | --- | --- |
| TM-29 | The 4096-byte bound is a design bound of the library, not an observation. The largest observed PDU is 263 bytes (SL-14). | Proven |
| TM-30 | The 4096-byte bound leaves ample headroom for the pages of the SmartLogger family, which hold one entry object each. | Hypothesis |
| TM-31 | The largest PDU a logger-class device can send, and whether any other device class needs more than 4096 bytes, are not established. | Unknown |
| TM-32 | A peer that inflates the MBAP length stalls the tolerant reader only until the response deadline, after which the connection is renewed as before. | Hypothesis |
| TM-33 | `count_only_page` identifies a count-carrying page in other devices as it does in the sanitized replay. | Hypothesis |
| TM-34 | Device identification over Modbus RTU stays strict only. | Proven |
| TM-35 | Whether an RTU logger-class device needs a tolerant mode is not established. | Unknown |
| TM-36 | Behaviour of the tolerant modes against a connected logger-class device, including timing, is not established. The library was exercised only against replayed responses. | Unknown |
| TM-37 | Whether a device of another family deviates in the same ways, or in other ways that the vocabulary does not name, is not established. A deviation outside the vocabulary is not named by the library. | Unknown |

These modes change no admission. Every device class still needs its own profile
selection, operation allowlist, and qualification in the registry, and the
statuses recorded in the [gateway contract](../huawei/gateway-readonly-v1.md)
are unchanged.
