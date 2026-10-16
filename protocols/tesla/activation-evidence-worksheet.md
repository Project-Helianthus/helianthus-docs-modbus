# Tesla Gen3 activation evidence worksheet

## Scope and present disposition

This unfilled worksheet prepares publishable evidence for the Gen3 HSC family
activation question in docs-modbus #158. It is the partial documentation slice
tracked by docs-modbus #164, with transport observation work in modbus #38.
No second-site result is supplied. Activation evidence and live qualification
remain **Unknown**; completing a worksheet alone grants no authority.

This is an evidence intake form, not an exchange implementation, sender recipe,
or instruction to alter a device. Later installation, credential use, reset,
or state-changing work requires separate operator confirmation at action time.
No such action is authorized here. Negative controls below are evidence
requirements, not live fault-injection instructions.

## Public native contract and evidence grades

Read the native contracts before interpreting observations:

- [Gen3 HSC transport contract](gen3-hsc-rtu.md), especially its
  [serial and activation wording](gen3-hsc-rtu.md#serial-and-activation).
- [TEDAPI EVSE operation catalog](tedapi.md), for profile-scoped RTU framing
  and native payload retention.
- [Private-function transport contract](../modbus/private-function-codes.md),
  for raw transport evidence, correlation, quarantine, and admission boundaries.
- [Read-acquisition activation gate](gen3-read-acquisition-v1.md#activation-prerequisite-and-the-current-no_send-gate),
  which explicitly leaves exchange clarification to #158 and observation to #38.

| Claim | Evidence grade and limit |
| --- | --- |
| Configured Gen3 serial format, bounded Modbus RTU envelopes, and profile-scoped private functions | Established native specification facts in the contracts above; not a new observation or qualification result. |
| Reported `TESLA` / `PASS` activation | **Hypothesis** about the actual exchange. The HSC page describes device-originated tokens and NUL termination; the read-acquisition page specifies an injected witness byte comparison but explicitly leaves side of origin, timing, and reset repetition unresolved. Those assertions are not second-site evidence. |
| Actual token bytes, terminators, side of origin, order, framing, causality, and reset behavior at a second site | **Unknown**. Do not prefill observations from the reported hypothesis or from a passing offline comparator. |
| A future bounded native observation | **Proven** only for the fact directly supported by publishable evidence, with its stated family/version and limits; qualification remains a separate decision. |

This worksheet does not resolve the tension in the existing activation wording
or amend either contract. A counterexample must be retained and referred to
#158 rather than coerced into the expected token sequence. No activation byte
values or extra handshake steps are invented here. RTU framing facts do not
establish that activation bytes themselves are RTU frames.

## Preconditions and observation bounds

Every result field starts as **Unknown**. Fill only from admissible evidence;
use Unknown with a reason for unavailable or redacted information. Absence of
an observation is not an observed absence. Publish family wording only.

| Required field | Result |
| --- | --- |
| Synthetic case label and independently reviewed public evidence reference | Unknown |
| Family and applicable protocol/operation version; basis for version applicability without identity data | Unknown |
| Observation method, directional visibility, clock resolution, and byte-loss limitations | Unknown |
| Explicitly configured serial format; evidence it was in effect | Unknown |
| Prior state: fresh session, already active, recovery, reset, or unavailable; basis for that classification | Unknown |
| Other initiators present or excluded; basis for attribution of each direction | Unknown |
| Start/end conditions, byte/frame count cap, duration cap, and stop conditions | Unknown |
| Read-only allowlist, retry bound, and whole-observation deadline for any separately admitted read acquisition; no discovery or implicit retry | Unknown |
| Whether observation itself could change state; separate action-time authorization satisfied, without names or credentials | Unknown |

Passive observation must remain distinct from a separately admitted read.
If preconditions or bounds cannot be established, record the limitation and
withhold admission. Do not turn this form into permission to send candidates.

## Ordered native evidence ledger

Duplicate the unfilled row for every observed segment, including unrelated,
partial, malformed, and missing-terminal evidence. Preserve arrival order and
direction separately; do not concatenate two directions into one token string.

| Segment order | Direction and attribution basis | Complete bounded native bytes and completeness | Relative monotonic offset/gap and uncertainty | Framing/integrity result | Context and outcome |
| --- | --- | --- | --- | --- | --- |
| Unknown | Unknown | Unknown | Unknown | Unknown | Unknown |

For each segment require:

- Exact native bytes, including delimiters, terminators, unknown members, and
  leading/trailing bytes; distinguish a complete segment from a truncated one.
- The observed sender and receiver roles, sequence relative to the preceding
  segment, and whether any response or acknowledgement is actually visible.
- Whether it is unframed serial data, an RTU candidate, or Unknown; record
  boundaries, lengths, inter-byte/inter-frame gaps, and CRC result where
  applicable. Do not force activation into the FC100 payload schema.
- Preconditions and lifecycle context before and after the segment; distinguish
  elapsed offsets from interpretation. A matching byte string or valid CRC
  alone proves neither activation nor a successful application operation.

Keep an exact native record in its authorized evidence lane. Public material
must contain only independently publishable facts or clearly labeled synthetic
fixtures. Never attach private captures, identities, serials, coordinates,
wall-clock capture times, device fingerprints, credentials, or restricted
source material. If sanitization removes bytes, identify the omitted field and
projection loss without exposing its contents; the public projection is not an
exact native record and cannot prove a byte-for-byte exchange. A synthetic
fixture demonstrates structure only and cannot establish second-site behavior.

## Independent repeats and negative controls

Each row needs its own case label, preconditions, ordered ledger, evidence
grade, and limitations. Replaying one record is not an independent repeat.
Record the number of independent sessions and which conditions differ.

| Evidence requirement | Result |
| --- | --- |
| Independent initial-session observations: count, direction/order consistency, byte/framing differences, and failures | Unknown |
| Independent recovery/reset observations, when separately authorized: whether the sequence reappears and prior readiness is lost | Unknown |
| Idle or no-sequence baseline: bounded observation and any independently known readiness state | Unknown |
| Offline missing, partial, reordered, or wrong-direction token cases: rejection without readiness or send authority | Unknown |
| Offline late, cancelled, expired, or prior-generation witness cases: no successor admission | Unknown |
| Incomplete visibility or competing-initiator case: attribution remains Unknown, no inferred activation | Unknown |
| Contradictory or unsuccessful independent observations, including alternative explanations | Unknown |

Controls must distinguish correlation from causation. If no safe independent
readiness criterion exists, activation remains Unknown even when a sequence
repeats. Offline negative cases test fail-closed policy only; they do not
establish how real firmware behaves.

## Transport observation, admission, and acquisition authority

modbus #38 may expose bounded raw bytes, their observed direction and order,
relative receipt offsets, completeness, transport errors, and endpoint
lifecycle context. Where supported it may report framing/integrity diagnostics.
Unavailable direction or timing stays Unknown. These are transport observations;
the hook must not infer a Tesla profile from a function code, label a token
match as proven device activation, send a handshake, or bypass admission.

The registry separately selects endpoint, unit, profile/version, and operation,
checks qualification and response policy, and rejects missing or ambiguous
evidence with `NO_SEND`. Acquisition separately requires a current bounded
witness and the lifecycle/admission rules of the read-acquisition contract.
An injected byte-comparison success cannot settle the physical exchange
questions. This worksheet closes neither #158 nor #38 and changes no current
activation gate or production-witness availability claim.

Preserve available partial native evidence and the last-known-good qualified
read state with its provenance and freshness. A failed observation must not
replace a valid sibling record with invented data or promote historical state
to current authority. Reset, timeout, cancellation, profile loss, or uncertain
generation keeps admission closed until the owning contracts are satisfied;
retained history cannot authorize a successor exchange.

## Review disposition and licensing boundary

| Required review field | Result |
| --- | --- |
| Supported facts and publishable evidence links, each with applicability and grade | Unknown |
| Hypotheses, counterexamples, missing evidence, and projection loss | Unknown |
| Registry qualification decision, independently from observation grade | Unknown |
| Remaining acquisition prerequisites and no-send disposition | Unknown |
| #158 clarification proposal and #38 observation gaps; parent acceptance remaining | Unknown |

Follow [protocol applicability and licensing](../applicability-and-licensing.md):
independently authored native facts remain in the protocol specification lane;
application policy and implementation retain their separate licensing lane.
This worksheet redistributes no vendor source and grants no source relicensing.
The [current-limit operation contract](gen3-current-limit-operation-v1.md)
continues to govern that separate path. No setter, password procedure,
namespace, MCP/GraphQL contract, runtime implementation, or live qualification
is introduced by this worksheet.
