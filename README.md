# Helianthus Modbus Documentation

This public repository is the canonical home for Helianthus Modbus-native
protocol contracts, device notes, and redacted interoperability material.

Current protocol contracts:

- [Generic private function-code transport](protocols/modbus/private-function-codes.md)
- [Tesla TEDAPI over Modbus RTU](protocols/tesla/tedapi.md)
- [Protocol applicability and licensing](protocols/applicability-and-licensing.md)
- [SunSpec read-only core V1](protocols/sunspec/read-only-core-v1.md)
- [SunSpec read-only core V1 model families](protocols/sunspec/read-only-core-v1-model-families.md)
- [SunSpec DER read-only contract V2](protocols/sunspec/read-only-core-v2.md)
- [SunSpec nested count-driven layout contract](protocols/sunspec/nested-layout-contract-v1.md)
- [Fronius SunSpec float flavor](protocols/fronius/sunspec-float-v1.md)
- [Huawei gateway read-only candidates](protocols/huawei/gateway-readonly-v1.md)
- [Growatt Protocol II read-only candidate](protocols/growatt/protocol-ii-readonly-v1.md)
- [ShineWiLan-X2 transparent Modbus bridge](protocols/growatt/shinewilan-x2-bridge-v1.md)
- [Growatt 1xSxxP ESS BMS RS485 read-only candidate](protocols/growatt/bms-rs485-1xsxxp-v202.md)
- [Growatt WIT family and protocol qualification matrix](protocols/growatt/wit-family-protocol-matrix-v1.md)

Protocol pages are public contracts. They define bounded, fail-closed behavior
and do not expose private device identity or unsafe control procedures.

Architecture and admission records:

- [S-Dongle qualification disposition](architecture/sdongle-qualification-disposition-v1.md)
