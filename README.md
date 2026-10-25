# Helianthus Modbus Documentation

This public repository is the canonical home for Helianthus Modbus-native
protocol contracts, device notes, native-evidence boundaries, and synthetic
interoperability material.

Current protocol contracts:

- [Generic private function-code transport](protocols/modbus/private-function-codes.md)
- [Tolerant TCP framing and device-identification modes](protocols/modbus/tolerant-tcp-modes-v1.md)
- [Tesla TEDAPI over Modbus RTU](protocols/tesla/tedapi.md)
- [Tesla legacy Wall Connector RS-485 contract](protocols/tesla/legacy-wall-connector-rs485.md)
- [Tesla Wall Connector Gen3 HSC RTU contract](protocols/tesla/gen3-hsc-rtu.md)
- [Tesla Gen3 current-limit admission and outcome contract V1](protocols/tesla/gen3-current-limit-operation-v1.md)
- [Tesla Gen3 read-path acquisition lifecycle contract V1](protocols/tesla/gen3-read-acquisition-v1.md)
- [Protocol applicability and licensing](protocols/applicability-and-licensing.md)
- [SunSpec read-only core V1](protocols/sunspec/read-only-core-v1.md)
- [SunSpec read-only core V1 model families](protocols/sunspec/read-only-core-v1-model-families.md)
- [SunSpec DER read-only contract V2](protocols/sunspec/read-only-core-v2.md)
- [SunSpec nested count-driven layout contract](protocols/sunspec/nested-layout-contract-v1.md)
- [SunSpec V2 Model 707 nested template contract](protocols/sunspec/der-trip-lv-template-v2.md)
- [SunSpec V2 Model 707 typed-fact projection contract](protocols/sunspec/der-trip-lv-typed-fact-projection-v2.md)
- [SunSpec V2 dynamic structural selection](protocols/sunspec/dynamic-structural-selection-v2.md)
- [Fronius SunSpec float flavor](protocols/fronius/sunspec-float-v1.md)
- [Huawei gateway read-only candidates](protocols/huawei/gateway-readonly-v1.md)
- [Huawei SmartLogger observed identity and inventory](protocols/huawei/smartlogger-observed-inventory-v1.md)
- [Huawei S-Dongle observed single-inverter identity](protocols/huawei/sdongle-observed-identity-v1.md)
- [Huawei EMMA observed gateway identity](protocols/huawei/emma-observed-identity-v1.md)
- [Growatt Protocol II read-only candidate](protocols/growatt/protocol-ii-readonly-v1.md)
- [Growatt Protocol II source and profile evidence matrix](protocols/growatt/protocol-ii-source-profile-matrix-v1.md)
- [ShineWiLan-X2 transparent Modbus bridge](protocols/growatt/shinewilan-x2-bridge-v1.md)
- [Growatt 1xSxxP ESS BMS RS485 read-only candidate](protocols/growatt/bms-rs485-1xsxxp-v202.md)
- [Growatt WIT family and protocol qualification matrix](protocols/growatt/wit-family-protocol-matrix-v1.md)
- [OutBack AXS Port SunSpec read-only boundary](protocols/outback/axs-port-sunspec-readonly-v1.md)

Protocol pages are public contracts. They define bounded, fail-closed behavior
and do not expose private device identity or unsafe control procedures.

Architecture and admission records:

- [S-Dongle qualification disposition](architecture/sdongle-qualification-disposition-v1.md)
