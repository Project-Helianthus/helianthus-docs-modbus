# Changelog

## Unreleased

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
