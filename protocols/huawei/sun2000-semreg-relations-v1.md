# SUN2000 SemReg relations

## Relations

These relations are the logger-family PV gate and the native inverter register-space reads. A relation published when the resource of its own family exists is unknown otherwise, never an absence.

| relation | from | to | basis | evidence (public page and section) | validity scope |
| --- | --- | --- | --- | --- | --- |
| `pv.relation.system_inverter` | logger | inverter | `gate_rule` | logger-family PV gate | published for the inverter the gate names |
| `pv.relation.inverter_input` | inverter | input | `gate_rule` | logger-family PV gate | published for the input the gate names |
| `relation.relays` | logger | inverter | `gate_rule` | logger-family PV gate | published for the inverter the gate names |
| `pv.relation.inverter_phase` | inverter | phase | `gate_rule` | native pages that state per-phase values | phase values are phase dimensions of the inverter resource |
| `relation.relays` | inverter | battery | `native_observation` | native pages that document a battery read through the inverter register space | published when the battery resource of its own family exists, unknown otherwise |
| `relation.relays` | inverter | meter | `native_observation` | native pages that document a meter read through the inverter register space | published when the meter resource of its own family exists, unknown otherwise |

Phase values are published as phase dimensions of the inverter resource and are allocated by the driver. The inverter-to-battery and inverter-to-meter relays are published when that resource of its own family exists and are unknown otherwise.
