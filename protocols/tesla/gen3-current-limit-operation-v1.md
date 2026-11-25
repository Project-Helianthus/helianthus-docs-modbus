# Tesla Gen3 current-limit admission and outcome contract V1

## Scope and evidence status

This contract defines driver admission, native records and outcomes for the
Tesla Wall Connector Gen 3 FC100 current-limit path. The driver's only setter
of `evse.limit.allocated_current` is the independently qualified provisional
operation on the exact operation version `wc3_24_44_3`.
The persistent settings write (t7 to t8) is not a setter.
FC101, FC102, enable, and disable stay outside. An explicitly called
provisional set or withdrawal whose capability is independently qualified and
whose profile, version, generation, and dispatch checks pass is admitted
without explicit operator confirmation at action time. Separate operator
approval stays only for an agent or test acting on a real installation. The
standalone t27 read is also a read observation of the acquisition lifecycle.

The [TEDAPI message specification](tedapi-specification.md#64-family-6-wall-connector)
(§§6.4.4, 6.4.10–6.4.11, 6.6.2, 7.1, 7.8 and 9.3) defines the message schema
and behavior. The [RS-485 site-controller protocol specification](rs485-site-controller-protocol.md#5-function-code-100-tedapitunnel)
(§§2.5, 5 and 11.2) defines the FC100 framing and terminal envelopes. Firmware
`26.34.0` and `26.42.0` have a same-tag t25 RS-485 reply, not a specified t26
ACK; neither is admitted by this driver setter. The specifications do not
establish the provisional setter's t26 terminal or its time and value
semantics on `24.44.3`. The driver's t26 contract requires independent
qualification of that exact operation; it is not a wire coverage claim.

Driver admission is limited to `wc3_24_44_3`. A known HSC version,
`compatible_candidate`, successful parsing, or a read-only capability does not
qualify a current-limit operation. An unknown terminal or field interpretation
refuses dispatch. Legacy Wall Connector RS-485 is outside this contract.

## Ownership and consumers

| Consumer | Required boundary |
| --- | --- |
| `helianthus-modbus` T2a/T2b | Vendor-neutral private-function exchange, raw framing/integrity, single-flight correlation, lifecycle generation, quarantine, and bounded recovery. No Tesla body interpretation or global FC-to-vendor dispatch. |
| `helianthus-modbusreg` M3/M4, issues #200/#202 | Profile and operation admission, exact request construction, terminal/body validation, and ownership of immutable correlated operation records. A vitals executor or a native payload container alone is insufficient. |
| gateway G7b/G12 | Supply action authority and interlock inputs; compose the admitted operation; retain distinct outcomes and evidence references. An injected read-only projection grants no send authority. |

This page defines the documentation gate for those consumers. It does not
implement their APIs, endpoint opening, persistence backend, scheduling,
protocol-neutral promotion, or output bindings. The existing configured
production endpoint's standard read path admits FC03/FC04 only. Its separate
opt-in private-function path requires upstream admission; enabling transport
does not qualify this current-limit operation.

## Admission preconditions

Every required input must be present, internally consistent, and checked again
at dispatch. A failed or unknown precondition is `REJECTED`, `NO_SEND`, with
the reason retained. Admission is scoped to exactly one
`(endpoint, unit-id, vendor-profile, operation)` selection.

| Required input | Fail-closed rule |
| --- | --- |
| Action authority | For an operation admitted through the semantic operation route (helianthus-docs), the route's runtime intent owner supplies the authority evidence that binds target, operation, values, and validity interval. Explicit authority binds the selected target, operation, values, and validity interval. Offline fake/replay authority cannot authorize live I/O. Live authority binds the route target, operation, values and validity interval; a cached read, configured endpoint, or document is insufficient. A qualified explicit provisional set or withdrawal is admitted without explicit operator confirmation at action time. Separate operator approval stays only for an agent or test acting on a real installation. Profile, version, generation, and dispatch checks remain admission conditions. |
| Profile and version | Explicit Gen3 identity, exact HSC profile compatibility, `wc3_24_44_3` operation schema, and independently qualified capability for the selected operation. Unknown, conflicting, legacy, or unenumerated operation versions deny dispatch. |
| Endpoint and generation | Explicit unicast node and configured endpoint, current nonzero lifecycle generation, compatible HSC activation state, and no fence/quarantine. No discovery, broadcast, profile fallback, or inferred default target. |
| Single-flight ownership | One serialized initiator and one in-flight exchange per endpoint. The mutation and its readback remain bound to one operation identity and the same lifecycle generation; no competing local mutation may interleave. This does not exclude an external actor. |
| Values and scope | Allocated current of at least 6 A sends t25 with that current, a timeout of 900 seconds, and inhibit false. Allocated current 0 A pauses: t25 carries current 6 A, a timeout of 900 seconds, and inhibit true. Allocated current from 1 A through 5 A is refused before send. The driver uses the configured-current value of the latest t28 in the same lifecycle generation as its bound; the encoded current, including 6 A for a pause, must not exceed it. Non-integer requests are refused before any read or mutation. With no t28 yet in the generation, the owner reads t27 to t28 first. Absent current or unsupported field semantics deny dispatch. |
| Interlocks | The interlocks are the semantic guard recheck (epoch, generation, binding, and capability revisions) and the station's own protections. No further interlock policy applies; a caller may add a precondition on a published status fact. This contract supplies no fault register, bit mask, or charging-state inference. |
| Timing and response policy | A finite monotonic operation deadline covers mutation and any required readback. Each exchange has an explicit positive timeout, finite response-count/byte bound, and recovery budget. Remaining time must cover the next admitted phase. Mutation retries are zero; read retries require an explicit read-only allowlist and finite budget. |
| Evidence and duplicate guard | The retained-record owner can freeze the admitted intent and correlate every phase. A local idempotency identity and bounded duplicate-retention policy are supplied before transmission. Missing retention capacity or duplicate ambiguity denies dispatch. |

The provisional timeout is a station request value, not the host deadline.
The 900-second timeout, whole-ampere admission and minimum nonzero set of
6 A are driver requirements, not general firmware limits. Wire integer
capacity is not a safe device maximum. This contract defines no universal
maximum amperage or settling delay. The owning registry must require qualified
inputs for those gaps; it must not fill them from names or successful decoding.
Discovery and qualification reads require explicit read-only allowlists,
bounded retries and version-aware evidence.

## Registry-owned request and response framing

Transport receives only the selected unit, FC100, bounded raw request payload,
and generic response policy. It owns RTU framing and CRC; the registry owns the
length envelope, operation family/tags, exact body, and normal-response policy.
No raw external request may bypass operation admission.

The [configured production endpoint contract](../modbus/private-function-codes.md#configured-production-read-and-private-function-endpoint)
defines the opt-in private exchange, shared read/private single-flight and
generation fence, per-frame bounds, caller classifier, and separate immutable
raw evidence. FC100 is within its user-defined function-code range; that
transport eligibility supplies no operation or write authority.

For 24.44.3, FC100 requests use `length:u8 | message[length]` with exact
length equality and at most 252 payload bytes including length. The driver
requires that framing and a maximum 256-byte ADU in both directions. It
validates the terminal envelope
before decoding the body. The station's reply encoding limit does not specify
whether the length byte is included (RS-485 §2.5).

| Intent / phase | Request and terminal | Meaning and boundary |
| --- | --- | --- |
| Persistent installation settings | Family 6, t7 ConfigureSettings → t8 returned settings | `settings` field 1 carries `WCSettings`, whose `maxOutputCurrentAmps` field 1 is signed int32 amperes. t8 returns settings, not an empty ACK. This is not a driver mutation. |
| Provisional mutation | Family 6, t25 SetProvisional; schema response t26 | t25 field 1 carries `provOpParams`: `limitCurrentMaxAmps` (uint32 A), `limitTimeoutS` (uint32 s), and `inhibitCharging` (bool), in fields 1–3. The t26 schema body is empty; it is not a guarantee of a t26 terminal on RS-485. |
| Provisional readback | Family 6, t27 GetProvisional → t28 returned state | t27 has an empty body. t28 field 1 carries the provisional parameters and field 2 carries `configuredCurrentLimitAmps` (uint32 A). It does not return effective or pilot current. |

On 26.34.0 and 26.42.0 a successful t25 reply carries the request tag and its
parameters in canonical form, omitting members encoded with default values. It does
not establish the applied state; read t27/t28. A correlated family 4, tag 1
terminal carries a numeric TEDAPI status and is rejection, not an ACK; a
Modbus exception is separate (TEDAPI §5; RS-485 §11.2).

On 26.34.0 and 26.42.0 t7 can store installation settings in factory state;
acceptance with settings already stored and the effect of omitting settings
members are not specified (TEDAPI §7.8). No current-only t7 send is admitted.
On 26.34.0 the t28 field 2 reports 32 A independently of the installation
setting or provisional limit. Its meaning is not specified, so the field
alone does not establish the stored capacity or qualify as a driver bound.

Required request values must be explicit. Malformed encodings, wrong wire
types and duplicate documented singular fields reject typed interpretation.
Unknown response members stay native and unknown request members confer no
write authority.

Only an integrity-valid, transport-correlated normal response in the active
generation may enter the selected operation decoder. A request echo or
intermediate response is not an ACK or readback and must not extend the
deadline. Generic Modbus exceptions retain their numeric status separately
from registry-decoded application errors; neither is successful current data.
Malformed, wrong-tag, duplicate-terminal, unrelated, late, or over-bound
responses cannot satisfy the operation.

## Outcomes and confirmation limits

Keep outcome class, transmission certainty, and effect certainty separately.
The classes below describe the evidence available at completion, not a Boolean
success flag. Earlier ACK evidence remains available if a later readback fails.

| Class | Required evidence | Permitted conclusion |
| --- | --- | --- |
| `ACK` | Valid correlated family-6 t26 in the exact qualified operation; no error status | Acknowledgement received; no applied-value confirmation. This may be an intermediate phase while required readback is pending. |
| `READBACK` | Valid correlated t8, or t28 linked to retained t25/t26/t27 | Returned settings/provisional state. Retain requested and returned values separately; compare only qualified comparable fields as match, mismatch or unknown. Mismatch is not confirmation. |
| `TIMEOUT` | An admitted exchange timeout or the operation deadline expired without the required terminal/readback; available send/receipt evidence retained | No completion within the applicable time bound. If the mutation may have been sent, effect is indeterminate even if no response arrived. |
| `INDETERMINATE` | Possible mutation transmission plus cancellation, short write, endpoint loss, invalid correlation, or other failure preventing reliable completion | The device may have changed state. No success, safe rollback, or automatic resend follows. |
| `REJECTED` | Failed admission before send, or a valid correlated exception/application-error terminal | Record rejection source and numeric status where present. Only a proven pre-send rejection establishes that this attempt did not transmit. An error terminal does not by itself prove absence of side effects. |

If the transport proves that no transmission occurred, cancellation or deadline
exhaustion before dispatch is a pre-send rejection. If transmission cannot be
excluded, record possible transmission and indeterminate effect. A readback
timeout after ACK is `TIMEOUT` with the ACK retained; a readback transport
failure is `INDETERMINATE` with the ACK retained.

Apply these driver outcome rules:

- A readback exception or application error after ACK is overall `INDETERMINATE`, with readback-phase `REJECTED` evidence and the ACK retained. It does not reject the preceding mutation or prove absence of its effect.
- An exchange timeout before the operation deadline is `TIMEOUT`, not the `INDETERMINATE` outcome class; preserve the earlier timeout cause and any ACK. Effect remains indeterminate if mutation transmission cannot be excluded.
- Mutation and confirmation readback must use the same lifecycle generation. The retained owner must reject cross-generation completion; reads after recovery are reconciliation evidence and cannot complete the original operation.

On 26.34.0 `limitTimeoutS` in t28 is remaining seconds, not an echo of the
requested duration. Do not compare the two as an equality test. A reply with
no timeout on that build does not report an active timed limit; do not treat
absence as an explicit zero or synthesize a deadline. The specification does
not define t28 reporting of the flag as confirmation of an ordinary timed
inhibit; the post-reset inhibit indication is not such confirmation. The t28
schema carries no nonce, timestamp or generation counter. Even a matching
readback reports returned values; it cannot prove causal application or exclusion of an
intervening actor. Persistent, provisional, configured, and effective/pilot
current remain distinct. Neither ACK nor matching t8/t28 establishes charging
current, watt limit, hardware qualification, or protocol-neutral promotion.
Projection that omits raw bytes, phase details, unknown fields, or mismatch
evidence must expose that loss and retain an evidence reference.

## Immutable correlated evidence

Freeze the admitted request and context before any possible transmission.
For each phase retain immutable exact request/response ADU bytes and native
payloads, selected profile and both profile/operation versions, operation and
phase identity, configured endpoint label, unit/function, lifecycle generation,
correlation identifier, integrity and decoding results, monotonic send/receipt
bounds, deadline, retry disposition, transmission certainty, and outcome.
Retain the authority/interlock decision and evidence references without
embedding credentials or personal identifiers in public material.

The operation record links the persistent pair or provisional set/ACK/readback
sequence, preserving requested values, returned values, absent-at-wire fields,
configured current, and comparison separately. Retain intermediate frames and
unknown members within admitted bounds. Failures retain available evidence;
never invent response bytes, fill unavailable values with zero, or drop a valid
ACK because readback failed. Exhausted storage or sequence bounds are failures,
not permission to truncate a successful record.

The retained-record owner defensively copies bytes on input and output. A
payload container, redacted summary, or replay result without request,
generation, and phase linkage does not meet this operation contract. Late
evidence is a separately linked immutable quarantine event; it cannot rewrite
a completed outcome or become evidence for a successor request. Closed,
replaced, or fenced generations remain historical and cannot authorize new I/O.

Runtime evidence may contain sensitive native data and needs access-controlled
retention. Public examples must be self-contained and synthetic; publication
must exclude credentials, personal data, serials, network coordinates, device
fingerprints, restricted material, and installation captures.

## Quarantine and recovery

Timeout after possible transmission, partial/short write, cancellation after
possible transmission, endpoint loss, invalid integrity, unrelated/late frame,
or ambiguous correlation fences the affected lifecycle generation. Admit no
successor exchange while fenced or quarantined. Recovery must have an explicit
finite attempt/time/byte budget, quarantine stale evidence, and establish a
successor generation with valid profile and HSC activation state before fresh
admission. Failed or unproven recovery leaves the endpoint unavailable.

Local generation numbers are not wire transaction identifiers. RTU separation
alone does not prove that a delayed identical terminal belongs to a new
request. The transport/registry combination must supply a qualified stale-frame
exclusion boundary; if it cannot, no successor current-limit operation is
admitted. This contract does not invent a drain interval or device reset
procedure. A valid correlated exception is terminal rejection evidence;
malformed or late exceptions enter quarantine.

Recovery never resends the mutation, changes to another profile, performs a
rollback, or restores an assumed previous setting. Bounded, explicitly
allowlisted read-only reconciliation may report current state after recovery;
it does not resolve historical causality or authorize a new write. A new
mutation requires fresh authority, interlock checks, deadline, and evidence.

## Idempotency and retry boundary

Idempotency is a local duplicate guard, not a Tesla wire guarantee. Bind a
caller-supplied identity to the target, original generation, exact operation,
version, values, and admitted intent. The same identity with different intent
is rejected. A duplicate of an in-flight operation returns its status without
another send; a completed duplicate returns historical evidence without
another send or a fresh-state claim. A generation change never rebinds the
retained attempt to the successor. After the bounded retention window, an old
identity must not silently become a new write; require a new explicit intent.

No automatic mutation retry is admitted, including after timeout, ACK-only
completion, readback mismatch, or indeterminate outcome. Repeating the same
amperage is not evidence of idempotence; a provisional request may affect a
timeout and persistent settings may have additional effects not qualified
here. While a limit other than the release is in force, the owner re-sends
the same triple every 300 seconds. A renewal is the same native request,
never a new semantic operation, and it is not a mutation retry. Release is
t25 with the configured current, a timeout of 900 seconds, and inhibit false,
after which renewal stops. Missing, zero or invalid configured current
prevents release dispatch. Confirm release only with the matching t28 in the
same lifecycle generation. This is driver withdrawal policy, not a general
wire command to remove a limit. A retry of an allowlisted read cannot replay
a mutation or acquire control authority.

On 26.34.0 the station counts down once per second and returns to its hardware
variant's default limit on expiry. A valid renewed request reloads the timer.
Zero current or zero timeout removes the limit on that build; neither value
authorizes a zero-timeout send in this driver. A timed inhibit ends when its
time runs out. These behaviors are not specified for 26.42.0, and the electrical
response to an active inhibit is not specified by TEDAPI §7.1.3. Do not extend
these rules to `wc3_24_44_3` without qualification. Device-side deduplication
and exactly-once execution are not specified. For managed operations the
[semantic mapping](gen3-semreg-mapping-v1.md#field-rules) defines a conservative
publication cutoff, not an exact station deadline.

## Read-only and state-changing boundary

Offline decoding, synthetic request construction, fake exchanges, and viewing
retained evidence cause no device I/O. The injected
`modbus.v1.tesla.gen3.evse.current_limit.get` projection remains read-only with
`outbound_allowed=false`; it neither acquires records nor constructs/sends
requests. A t27 acquisition is a read-only exchange requiring its own bounded
admission; it is different from that injected projection.

t7 and t25 are state-changing intents. Neither this contract, a request
builder, a readback match, nor a gateway option decision grants live authority.
Offline conformance must cover missing authority/interlocks/upper limits,
wrong versions/generations, ACK-only, readback match/mismatch, pre/post-send
timeouts, cancellation/short write, exceptions, duplicate identities, and
late-frame recovery without automatic mutation retry.

## Bench verification boundary

Record a bench verification level separately from admission and live
qualification. It does not gate implementation, publication, promotion or
operation.
A recorded result that contradicts this page is a defect report against this page.
A bench run is a state-changing action performed by a person who confirms it
at action time.

Keep a current-only settings body outside driver admission: omitted-field
handling and safe updates to existing settings are not specified. Do not infer
a live setter from the t26 schema or equate a same-tag reply with readback.
Enable and disable are outside this contract. A reported or configured limit
is not an effective charging current; do not infer fault, interlock or
charging-state semantics without a defined field. This page still refuses a universal maximum.
