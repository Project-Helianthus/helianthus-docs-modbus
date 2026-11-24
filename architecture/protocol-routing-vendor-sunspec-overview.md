# SunSpec Protocol References

This AGPL-3.0 page indexes Helianthus acquisition and qualification contracts.
Implementation-neutral wire references remain separately under CC0-1.0 in
[the protocol directory](../protocols/sunspec/README.md).

- [`sunspec-model-chain-v1.md`](protocol-routing-vendor-sunspec-model-chain-v1.md) defines the
  SunSpec model-chain, retention, and capability-admission contract.
- [`fronius-observed-flavor-v1.md`](protocol-routing-vendor-fronius-observed-flavor-v1.md) defines
  the first exact vendor flavor layered after capability admission. The observed
  flavor is a `tested_on_hardware` record of one model and bounds nothing.
- [`fronius-observed-flavor-v1-1.md`](protocol-routing-vendor-fronius-observed-flavor-v1-1.md)
  defines a separate exact successor for the observed chain that includes
  standard Model `123/L24`; it does not replace or widen V1. The observed flavor
  is a `tested_on_hardware` record of one model and bounds nothing.
- [`fronius-observed-flavor-v1-2.md`](protocol-routing-vendor-fronius-observed-flavor-v1-2.md)
  defines a further exact successor that keeps the V1.1 ordered chain and
  admits one different exact Common firmware string; it does not replace or
  widen V1 or V1.1. The observed flavor is a `tested_on_hardware` record of one
  model and bounds nothing.
- [`additional-model-evidence-v1.md`](protocol-routing-vendor-sunspec-additional-model-evidence-v1.md)
  records the FMV3-M7-01 manufacturer-neutral candidate sets and read-only
  admission boundary for later standard-model expansion. The same page records
  the grid-support hand-write surface and the model 703 enter-service voltage
  thresholds.
- [`sunspec-model-chain-v1.md`](protocol-routing-vendor-sunspec-model-chain-v1.md)
  states the multi-register data-encoding rule. Models 708 and 709 refer to
  that rule for their 32-bit writable points.

The page is an independently authored contract. It does not redistribute
upstream specification text, model files, vendor manuals, or vendor register
tables. Helianthus scheduling, acquisition, vendor applicability, and runtime
activation policy remain under `docs/platform/` and are not relicensed by this
directory.
