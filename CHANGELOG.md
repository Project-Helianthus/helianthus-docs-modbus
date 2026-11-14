# Changelog

## Unreleased

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
