# Wall Connector Gen 3 HSC RTU — compatibility landing

The [RS-485 site-controller protocol specification](rs485-site-controller-protocol.md)
is normative for the external port. It defines the link layer, start-up,
functions 100–105 and their firmware applicability, including the per-build
schemas in Appendix A. The [TEDAPI message specification](tedapi-specification.md)
defines the messages carried by function 100.

The Gen 3 driver does not fall back to legacy SLIP or interpret legacy frames
as Gen 3. See the separate [legacy RS-485 contract](legacy-wall-connector-rs485.md).

## Serial and activation

Use the [link parameters](rs485-site-controller-protocol.md#2-link-layer) and
[start-up state machine](rs485-site-controller-protocol.md#3-start-up-exchange)
for the identified firmware. Attempts, restarts and re-evaluation when
conditions change are firmware-specific; start-up is not a once-per-power rule.

## Driver support

The wire specification does not add driver functions or grant admission.
The [read-acquisition contract](gen3-read-acquisition-v1.md) requires an
explicit endpoint, configured node, compatible operation and bounded
single-flight correlation. The driver can qualify a later build on the
`wc3_24_44` line at or above `wc3_24_44_3` only when activation, private-function
and operation-schema capabilities agree. A version label alone grants no
operation. An unidentified, below-floor, or capability-incompatible build does
not qualify, and nothing is sent. `compatible_candidate` and `unknown` are
driver dispositions, not firmware applicability or qualification.

The driver retains complete bounded native payloads and unknown fields with
profile, version, function, direction and outcome. It can keep function-101
and function-102 payloads raw without treating their wire schemas as undefined.

## EVSE current-limit records

<a id="exact-24443-body-and-evidence-contract"></a>

For message bodies and application behaviour, use the TEDAPI specification's
[message catalogue](tedapi-specification.md#6-message-catalogue),
[behavioural rules](tedapi-specification.md#7-behavioural-rules-and-state-machines)
and [message schema](tedapi-specification.md#9-message-schema-definitions).
On firmware 26.34.0 a zero current or zero timeout removes the provisional
limit. This does not establish zero semantics for other builds, turn an omitted
field into a typed zero, or add a driver command.

Persistent and provisional limits remain distinct. The driver keeps the
provisional mutation on the exact operation version `wc3_24_44_3` and requires
correlated readback rather than acknowledgement alone. The
[current-limit operation contract](gen3-current-limit-operation-v1.md) governs
admission and confirmation; persistent settings are not a driver setter, and
generic enable and disable are outside its scope. The driver rejects malformed
encodings and duplicate documented singular members while retaining unknown
members as native bytes. A readback alone does not establish that an intervening
actor did not change the provisional state.

## Read-only current-limit projection

A read-only projection reports only already-injected records for `wc3_24_44_3`.
The projection is `READ_ONLY`: it always reports `outbound_allowed` as `false`,
constructs no request, performs no acquisition, and never sends a frame.

Its optional persistent object retains the integer-A `max_output_current_amps`
fact with the bounded family-6 t7 request and t8 terminal payloads. Its optional
provisional object retains `limit_current_max_amps`, `limit_timeout_s`, and
`inhibit_charging` with all four bounded payloads: t25 request, t26 acknowledgement,
t27 readback request, and t28 readback terminal. A provisional object is
available only when that complete correlated sequence is retained.

Each object is validated independently. An invalid object is not projected, but
a complete qualified sibling remains available even when the provider reports
an error. If neither object qualifies, the projection returns no projected data
with a structured error.

The projection does not define a setter, must not infer a watt limit, and does
not make zero timeout interoperable. It does not expose a result for another
operation version or interpret function-101 or function-102 payloads.

## Safety boundary

This page grants no operation authority. An explicitly called provisional set
or withdrawal whose capability is independently qualified is admitted without
explicit operator confirmation at action time. Profile, version, generation,
and dispatch checks remain admission conditions. Separate operator approval
stays only for an agent or test acting on a real installation.
