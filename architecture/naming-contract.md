# Modbus decoded value naming contract

This is a bounded implementation-name contract, not new native evidence or a
qualification decision. The naming grammar is owned by the public
[eBUS naming contract](https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/main/architecture/naming.md).
The correspondence below is historical documentation, never a runtime fallback
key, alias, duplicate field or migration instruction. Before the schema freeze,
changes are coordinated across consumers without a migration path.

## Huawei monitoring decoded outputs

The following rows cover every decoded output in the supplied bounded inventory;
profile and decoder namespaces, indexes, offsets, quantities, value classes,
units, scales, polarity, evidence grades and access do not change. The
[monitoring contract](../protocols/huawei/monitoring-readonly-v1.md) is the native
fact source. Proven, Hypothesis and Unknown describe evidence, not qualification.
The M3 and M1 profile families have different observations and grades.

| Current implementation name | Contract name | Disposition and proof / open question |
| --- | --- | --- |
| `pv_string_voltage` | `pv_string_voltage` | Unchanged, provisional: indexed string voltage; vocabulary and identity need review. |
| `pv_string_current` | `pv_string_current` | Unchanged, provisional: indexed string current; vocabulary and identity need review. |
| `energy_accumulated` | `energy_accumulated` | Unchanged, provisional: M3 lifetime yield is Proven, but total accumulation for M1 remains Hypothesis; `energy_total` is not yet adopted. |
| `energy_current_hour` | `energy_current_hour` | Unchanged, provisional: period semantics need confirmation. |
| `energy_current_day` | `energy_current_day` | Unchanged, provisional: period semantics need confirmation. |
| `input_power` | `input_power` | Unchanged, provisional: vocabulary and polarity remain open. |
| `active_power` | `active_power` | Unchanged, provisional: vocabulary and polarity remain open; the positive-only projection is preserved. |
| `device_status` | `status` | Supported rename: M1 power group offset 32089, one U16 state code; the sole admitted `grid_connected` enumeration and Hypothesis grade remain unchanged. M3 power group remains refused and its state Unknown. |

The implementation definitions are in the public
[monitoring profile](https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/huawei_sun2000_monitoring.go).
A rename does not change admission, promote an evidence grade, establish hardware
qualification, or authorize writes. Failed or absent groups retain available
partial last-known-good fields and never become fabricated zero values.

## Native identities and remaining exports

SunSpec point IDs such as `W`, `WH`, and `V_SF`, and TEDAPI method and field
spellings, remain unchanged native evidence identifiers, separate from decoded
value names. They are not newly invented canonical value names. All other
exported names stay unchanged in this release; the source inventory does not
enumerate all decoded outputs, structural and native identities, or dynamic
consumer paths. Their individual classification remains open, not inferred from
this table. Inventory extension is tracked in
[modbusreg issue 393](https://github.com/Project-Helianthus/helianthus-modbusreg/issues/393).

## Consumer correspondence

The inventory lists `ebusgateway/cmd/gateway/huawei_pv_semreg.go` for both
bounded-map names. The source switches on both old suffixes: the status branch
accepts only `grid_connected`, and the energy branch publishes generated energy.
The consumer must coordinate the supported status rename; energy remains
unchanged pending evidence. Other inventory matches are lexical candidates, not
proof of bindings or complete closure. The gateway's generic Modbus provider,
MCP and GraphQL surfaces and the Matter target profiles require coordinated
consumer review. Generic schema and passthrough consumers in HA integration,
ebus-vdev and vrc-explorer have no established direct match in this inventory;
that is not proof of absence. Preserve eBUS MCP compatibility and GraphQL parity.
