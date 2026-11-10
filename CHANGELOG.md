# Changelog

## Unreleased

- Breaking: the Huawei monitoring decoded state name changes from
  `device_status` to `status` in the coordinated consumer wave. Before 1.0
  there is no alias, duplicate field, compatibility shim or migration step.
  The accumulated energy name remains provisional pending profile-wide evidence.
  See the [naming contract](architecture/naming-contract.md).
