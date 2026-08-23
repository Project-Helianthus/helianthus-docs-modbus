# Helianthus Modbus Documentation

This public repository is the canonical home for Helianthus Modbus-native
protocol contracts, device notes, and redacted interoperability material.

Current protocol contracts:

- [Generic private function-code transport](protocols/modbus/private-function-codes.md)
- [Tesla TEDAPI over Modbus RTU](protocols/tesla/tedapi.md)
- [Protocol applicability and licensing](protocols/applicability-and-licensing.md)
- [SunSpec read-only core](protocols/sunspec/read-only-core-v1.md)
- [Fronius SunSpec float flavor](protocols/fronius/sunspec-float-v1.md)
- [Huawei gateway read-only candidates](protocols/huawei/gateway-readonly-v1.md)
- [Growatt Protocol II read-only candidate](protocols/growatt/protocol-ii-readonly-v1.md)

Protocol pages are public contracts. They define bounded, fail-closed behavior
and do not expose private device identity or unsafe control procedures.
