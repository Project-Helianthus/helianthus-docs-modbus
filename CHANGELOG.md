# Changelog

## Unreleased

- The SunSpec read-only model-family page and the V2 read-only page name the
  monitoring facts for the decoded inverter, DER observed-state, MPPT, storage,
  and meter models, and for the V2 AC measurement, storage capacity, DC port,
  and battery models. An absent point is omitted, an unimplemented scale factor
  leaves its value absent, and a module role stays unknown unless a public
  model definition states the label meaning. The facts are read-only and add
  no request beyond the chain read that already exists.
- The Wall Connector Gen3 current-limit page records its six closing rows as
  bench verification. Each row has a level, not verified on hardware or
  verified on hardware, and starts not verified on hardware. No
  implementation, publication, promotion or operation waits for a row. A
  recorded result that contradicts the page is a defect report against the
  page. A bench run is a state-changing action performed by a person who
  confirms it at action time. Enable and disable stay outside this contract.
  A missing reported maximum stays unknown, and the page still refuses a
  universal maximum.
- The Wall Connector Gen3 current-limit operation contract names six on-site
  observations required before a live current limit or a live pause. Every
  row stays Unknown. The page authorizes no transmission, and neither a t7
  observation nor a t25 observation qualifies that operation. An on-site run
  of those observations, when one is later made, needs operator confirmation
  at action time. This change does not authorize that run, transmits nothing,
  and publishes no new number.
- The Gen3 HSC read-path lifecycle drives activation as an exchange on an
  injected driver: the device greeting, the host echo of that greeting, then
  the confirmation or a refusal and a new greeting. Readiness requires the
  confirmation after a host echo of the immediately preceding greeting. An
  explicitly configured readiness probe may use the first configured read only
  after silence for the whole activation timeout. An epoch pins one generation
  of the current endpoint instance, and a record is current only for the live
  epoch, endpoint instance, and generation. The production endpoint has a
  separate opt-in activation echo exchange on the same single-flight,
  generation, and fence boundary. A frame addressed to another node does not
  disable the HSC exchange state. The observation hook stays a listener; the
  host answer belongs to that transport exchange and to a registry-supplied
  driver. The echo window, the retry count, and the host-side turnaround are
  not established and must be measured.
- The Wall Connector Gen3 HSC activation exchange is observed once after the
  charger gets power: the device greeting `TESLA` followed by NUL, the host
  echo of those same six bytes, then the confirmation `PASS` followed by NUL
  or `FAIL` followed by NUL and a new greeting. A listener that sends nothing
  never sees the confirmation, and a greeting the host sends at any other time
  is ignored. The echo window and the retry count are not established and must
  be measured. A later recovery does not repeat the activation: it keeps that
  epoch and pins the successor generation. The acquisition witness admits
  readiness only for the greeting, the echo of those six bytes, and `PASS`
  followed by NUL. Restart after that activation does not wait for a second
  exchange. The observation
  hook stays a non-transmitting listener and does not treat the confirmation
  as a silent success witness.
- The Fronius and OutBack implementation pages name the declaring modbusreg
  packages `fronius` and `outback` and their import paths, and name package
  `sunspec` for the SunSpec identifiers they use. The moved identifiers use
  their current spellings, such as `fronius.RetainedCommit`,
  `fronius.OfflineRequest`, `outback.NewDetachedRecord`,
  `outback.DiagnosticSupplier`, `sunspec.DecoderRegistry` and
  `sunspec.NewChainPlan`, and the links to the moved source files point to
  `fronius/`, `outback/` and `sunspec/`. Protocol content is unchanged; there
  is no alias, compatibility shim or migration step.
- The Huawei-family implementation pages (EMMA, LUNA2000, S-Dongle and
  SmartLogger) name the declaring modbusreg package `huawei` and its import
  path `github.com/Project-Helianthus/helianthus-modbusreg/huawei`, use the
  moved spellings `huawei.SDongleOfflineObservation` and
  `huawei.SmartLoggerOfflineInventoryInput`, and link the moved source files.
  The naming contract scope reads `huawei.SUN2000MonitoringProfile`. Protocol
  content is unchanged; there is no alias, compatibility shim or migration step.
- Breaking: the Huawei monitoring decoded state name changes from
  `device_status` to `status` in the coordinated consumer wave. Before 1.0
  there is no alias, duplicate field, compatibility shim or migration step.
  The accumulated energy name remains provisional pending profile-wide evidence.
  See the [naming contract](architecture/naming-contract.md).
