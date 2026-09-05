# Fronius SunSpec Qualification Readiness V1

## Scope and evidence state

This procedure makes the existing observed Fronius SunSpec flavor reproducible
for an offline or operator-approved read-only qualification run. The exact
applicability tuple is manufacturer `Fronius`, model `Symo GEN24 10.0`, firmware
`1.41.11-1`, Unit Identifier 1, and flavor
`sunspec.flavor.fronius.gen24.float.observed@1.1.0`.

The generic three-phase SunSpec monitoring capability is evaluated separately
from this vendor tuple. A standard capability match does not establish the
Fronius flavor. The result remains `live_qualified=false` until an actual
hardware capture is run and assessed under operator control.

## Qualification card

The card identity is
`sunspec.qualification.fronius.gen24.float.readonly@1.0.0`. It permits only FC03
holding-register reads beginning at PDU offset 40000. The initial base-candidate
set is exactly `[40000]`; the maximum chain is 512 words and 64 model
occurrences; and each individual read is bounded by the protocol acquisition
adapter to at most 125 words. A caller supplies endpoint and capture identity,
which must remain consistent across the complete chain.

The expected ordered chain is:

```text
1/65
113/60
120/26
121/30
122/44
123/24
160/88
124/24
ffff/0
```

The terminal marker is part of the required result. The card has
`automatic_runtime_admission=false` and `write_authority=false`. It creates no
endpoint discovery, socket, retry policy, support claim, or gateway activation.

## Complete-chain replay matrix

Every row begins at the acquisition adapter and uses source-backed logical
views. Classification happens only after the terminal marker is accepted.

| Case | Required result |
| --- | --- |
| Exact tuple and exact chain | generic capability admitted; exact observed flavor matched; immutable qualification observation created |
| Structurally valid unknown model | retain the opaque occurrence, raw words, order, and source spans; generic capability may remain admitted; exact flavor does not match |
| Duplicate known model | retain each occurrence separately; exact flavor does not match |
| Known model with an unsupported length | retain it as `unsupported_length`; exact flavor does not match |
| Zero model length, nonzero terminal length, extent overflow, or contradictory source range | fail the chain terminally and produce no qualification observation |
| Missing payload chunk or terminal chunk | remain incomplete and produce no qualification observation |
| Unavailable sentinel in a required Model 113 fact | retain the raw value; reject the generic capability and exact flavor |
| Different manufacturer, model, or firmware | generic standard capability may remain admitted; exact Fronius flavor does not match |
| Different Unit Identifier, write function, or mixed capture provenance | reject the qualification card |

Unknown or duplicate occurrences must never be discarded merely to make the
observed chain appear exact. A missing chunk must never be inferred from a later
chunk, padded, or converted into a partial positive result.

## Typed native facts and retention

Only the following valid facts from the uniquely selected three-phase inverter
occurrence are eligible for later semantic consideration:

- `inverter.ac.current.total`
- `inverter.ac.current.phase_a`
- `inverter.ac.current.phase_b`
- `inverter.ac.current.phase_c`
- `inverter.ac.voltage.phase_a`
- `inverter.ac.voltage.phase_b`
- `inverter.ac.voltage.phase_c`
- `inverter.ac.power.active`
- `inverter.ac.frequency`
- `inverter.ac.energy_lifetime`
- `inverter.temperature.cabinet`
- `inverter.operating_state`
- `inverter.events.1`
- `inverter.events.2`

Each fact must have its declared unit, a valid non-sentinel value, and exact
source evidence. This list is a candidate boundary for a later semantic owner;
it is not a promotion or publication decision. All model words, including
unlisted fields and unavailable values, remain available as native raw evidence.
The qualification observation also retains occurrence order, decoder key or
opaque disposition, source spans, logical-view words, function, table, unit,
connection and transport generation, poll generation, deadline identity, and
authorization scope.

## Sanitized expected result

A successful synthetic replay has status `OFFLINE_REPLAY_MATCH`, the generic
three-phase monitoring capability, the exact flavor and chain above, the
fourteen candidate field identifiers, and retained-evidence markers for
`raw_words`, `occurrence_order`, `source_spans`, and
`logical_view_provenance`. Its safety fields are exactly:

```json
{
  "live_qualified": false,
  "automatic_runtime_admission": false,
  "write_authority": false
}
```

Synthetic values and identifiers are test data only. A public expected result
contains no installation endpoint, serial number, account, private capture, or
device fingerprint.

## Failure and requalification boundary

An offline match proves the decoder, acquisition adapter, qualification card,
and evidence retention are ready for a bounded read-only hardware experiment.
It does not prove a currently reachable device, a product support claim, a
gateway integration, consumer output, semantic publication, or successful
physical qualification.

A different product, firmware, Unit Identifier, chain geometry, or required
fact state remains unmatched until separately evidenced. Any real device access
requires a concrete operator-approved procedure at action time. This contract
defines no write, control, configuration, or safety-relevant operation.
