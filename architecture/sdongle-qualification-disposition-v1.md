# S-Dongle Qualification Disposition V1

This Helianthus architecture and admission guidance is released under
AGPL-3.0-only. It complements, but does not alter, the CC0 protocol contract.

## Scope

This record defines the disposition of one bounded read-only S-Dongle
qualification. It does not identify an installation, configure an inverter, or
admit a runtime profile.

## Sanitized qualification boundary

Two independent, bounded basic Read Device Identification requests expired: one
at three seconds and one at ten seconds. One separately authorized, bounded
FC03 Device Search Status request also expired at five seconds. No subsequent
Modbus request was sent at that stage.

One bounded retry matrix then alternated basic Read Device Identification and
FC03 Device Search Status four times. The matrix order was basic Read Device
Identification, FC03 Device Search Status, basic Read Device Identification,
and FC03 Device Search Status. Each request had a five-second deadline and at
least five seconds of idle time before the next request.
Each retry began after at least five seconds of idle time. All four requests
expired. No subsequent Modbus request was sent.

Those outcomes do not identify a family, establish a capability, prove device
absence, establish MEI incompatibility, or describe inverter configuration.
They leave identity and capability as insufficient evidence.

## Disposition

The target tuple `S-DongleA-05 / V200R022C10SPC312` remains
`PRE_LIVE_INSUFFICIENT_EVIDENCE`, default denied, and unregistered for runtime
acquisition. The tuple is qualification context, not Modbus identity proof.
The completed qualification is at a hard stop: it must not retry, fall back to
another register read, or use a private function code.

FC0x41 and FC0x17 remain no-send. The boundary permits neither a write nor an
allocation operation.

## Gateway-unit and child boundary

At the S-Dongle gateway unit, basic Read Device Identification and documented
read-only FC03 gateway registers are the only candidate probes. Extended Read
Device Identification inventory is not permitted at that unit.

Extended inventory applies only to a separately qualified child unit in the
range 1 through 247. A timeout at the gateway unit never authorizes a child-unit
scan, inferred child address, or extended-MEI fallback.

## Requalification gate

A future qualification requires a new bounded read-only run and evaluates the
documented candidate in this order:

1. basic Read Device Identification and a separately authorized minimal FC03
   gateway-status observation;
2. only after those observations provide required discriminators, exact model,
   firmware, and protocol gates using documented read-only gateway registers;
3. a separately qualified child routing context before any extended inventory;
4. only at that child unit, a bounded extended Read Device Identification
   inventory; and
5. a final read-only gateway-state observation that proves the documented guard
   remained stable.

Any timeout, malformed response, unavailable required discriminator, unstable
inventory, conflicting candidate, or failed bound stops the run at insufficient
evidence. It does not authorize a fallback or partial admission.

## Publication boundary

This record excludes network coordinates, serial and ESN values, credentials,
registration material, timestamps, raw captures, and source provenance. Public
evidence records only the bounded outcome needed to preserve admission safety.
