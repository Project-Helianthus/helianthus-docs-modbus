# S-Dongle Qualification Disposition V1

This Helianthus architecture and admission guidance is released under
AGPL-3.0-only. It complements, but does not alter, the CC0 protocol contract.

## Scope

This record defines the disposition of one bounded read-only S-Dongle
qualification. It does not identify an installation, configure an inverter, or
admit a runtime profile.

## Sanitized qualification boundary

TCP reachability was established. Two independent, bounded basic Read Device
Identification requests expired: one at three seconds and one at ten seconds.
No subsequent Modbus request was sent.

Those outcomes do not identify a family, establish a capability, prove device
absence, establish MEI incompatibility, or describe inverter configuration.
They leave identity and capability as insufficient evidence.

## Disposition

The profile remains `PRE_LIVE_INSUFFICIENT_EVIDENCE`, default denied, and
unregistered for runtime acquisition. The completed qualification is at a hard
stop: it must not retry, fall back to another register read, or use a private
function code.

FC0x41 and FC0x17 remain no-send. The boundary permits neither a write nor an
allocation operation.

## Requalification gate

A future qualification requires a new bounded read-only run and evaluates the
documented candidate in this order:

1. basic Read Device Identification;
2. FC03 protocol version and type/search/change-sequence reads;
3. after an exact model gate, FC03 operating-system version and capacity reads;
4. only after the exact model, firmware, and protocol tuple is satisfied, a
   bounded extended Read Device Identification inventory; and
5. a final type/search/change-sequence read that proves the inventory remained
   stable.

Any timeout, malformed response, unavailable required discriminator, unstable
inventory, conflicting candidate, or failed bound stops the run at insufficient
evidence. It does not authorize a fallback or partial admission.

## Publication boundary

This record excludes network coordinates, serial and ESN values, credentials,
registration material, timestamps, raw captures, and source provenance. Public
evidence records only the bounded outcome needed to preserve admission safety.
