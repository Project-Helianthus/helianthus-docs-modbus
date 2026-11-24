# SunSpec controls

All writes use [register write](../modbus/register-write-v1.md). A point the source documents as writable gets an operation, through SemReg where SemReg has the element, and otherwise decoded and callable by hand through MCP and GraphQL in the modbusreg namespace. A device without the model, or without the rating point a conversion divides by, has no setter for that operation. The page sets no revert figure or renewal period of its own.

## SemReg setters

| SemReg operation | argument (SI) | SunSpec model | points written | conversion | release | readback |
| --- | --- | --- | --- | --- | --- | --- |
| `pv.operation.set_active_power_limit` | `pv.limit.active_power` (W) | 123 (with `WMax` of model 121) | one contiguous range `WMaxLimPct` through `WMaxLim_Ena` | percent = W / `WMax` x 100, scaled by `WMaxLimPct_SF`, rounded down | boolean `false` for `pv.limit.active_power_enabled` writes `WMaxLim_Ena` = 0 only | re-read of the written points; release re-reads only `WMaxLim_Ena` |
| `storage.operation.set_charge_limit` | `storage.limit.charge_power` (W) | 124 | `InWRte`, optional `InOutWRte_RvrtTms`, then `StorCtl_Mod` | percent of `WChaMax` | clears the matching `StorCtl_Mod` bit | re-read |
| `storage.operation.set_discharge_limit` | `storage.limit.discharge_power` (W) | 124 | `OutWRte`, optional `InOutWRte_RvrtTms`, then `StorCtl_Mod` | percent of `WDisChaMax`; `WChaMax` only with explicit evidence it equals `WDisChaMax`; otherwise withheld | clears the matching bit | re-read |

The Model 123 set writes one contiguous range `WMaxLimPct` through `WMaxLim_Ena` in one request. That range includes `WMaxLimPct_WinTms`, `WMaxLimPct_RvrtTms`, and `WMaxLimPct_RmpTms`, in the order the model definition gives them. `WMaxLim_Ena` is 1. `WMaxLimPct_WinTms` and `WMaxLimPct_RmpTms` hold the values read from the device before the write. `WMaxLimPct_RvrtTms` holds the requested duration, or the value read from the device before the write when no duration was requested. The percent is W divided by `WMax`, times 100, scaled by `WMaxLimPct_SF`, and rounded down so the device never exceeds the requested watts.

The enable-only release writes `WMaxLim_Ena` = 0 only in its own request and re-reads only `WMaxLim_Ena`. It is boolean `false` for `pv.limit.active_power_enabled`, with no watt argument, and it leaves `WMaxLimPct` and the timing points unwritten. Release establishes `pv.effect.release_active_power_limit` only from the observed false value on the matching subject.

Both Model 124 rates use the device's `InOutWRte_SF`. The raw register value is the floor of (requested W divided by the applicable rating W) times 100 divided by 10 raised to `InOutWRte_SF`. For 3,333 W with an 8,000 W applicable rating and scale -1, write raw 416. For charge the applicable rating is `WChaMax`. For discharge the applicable rating is `WDisChaMax`. Discharge uses percent of `WDisChaMax`. `WChaMax` is the discharge denominator only when explicit evidence shows it equals `WDisChaMax`. When the discharge denominator is unknown, the discharge setter is withheld. The revert-time points carry the duration the operation requests, except that model 123 with no requested duration keeps the device's value as stated in the table.

## Model 124 compound setting

The setting owner uses the published Model 124 point geometry to locate exact spans. The send order is directional rate, requested duration if present, and mode last, even though mode occurs earlier in the register map. Each listed span is its own function 16 request. One setting owner serializes this command for the discovered endpoint and model instance, reads the current mode and preserves its other direction and other bits, and writes no intervening status word or opposite rate. Validate every selected span and its entire encoding against that qualified instance before the first function 16.

For a semantic storage operation require the existing clear `storage.status.interlock` candidate for the same storage interface as the intended effect before any send. No clear `storage.status.interlock` candidate produces zero FC16 writes. Mode, charge state, or rating does not establish one. An unsupported or unencodable duration produces no write even when the rate is encodable. A later runtime rejection after the rate is attempted reports partially executed or uncertain and distinguishes the unattempted steps.

Recheck cancellation and the same invocation guard immediately before every remaining span. Cancellation between spans stops later writes. Refusal, cancellation, possible transmission without acknowledgement, or loss of the guard stops later writes. Preserve prior attempted evidence and the unattempted remainder. Only correlated readbacks of all intended points from the same admitted setting owner, endpoint and generation confirm the whole setting. Before any possible send, report no-send. If an earlier span may have applied, report partially executed or uncertain and distinguish the unattempted steps. Preserve each point's separate acknowledgement and readback evidence. The Model 123 contiguous set and the one-point releases and by-hand calls keep their own geometry.

## Points callable by hand

Each documented writable point of models 120 through 124 without a SemReg counterpart is independently decoded and callable by hand through MCP and GraphQL in the modbusreg namespace. A hand call selects that point's own admitted span and qualified readback. A standalone timing call operates on that point. Only points the model definition marks read-only are stated so. Model 122 measurements and status points are read-only.

| model | point | type | scale factor | unit | access | value range or symbols |
| --- | --- | --- | --- | --- | --- | --- |
| 123 | `Conn_WinTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `Conn_RvrtTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `Conn` | enum16 | none | none | RW | own admitted span |
| 123 | `WMaxLimPct_WinTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `WMaxLimPct_RmpTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `WMaxLimPct_RvrtTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `OutPFSet_WinTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `OutPFSet_RvrtTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `OutPFSet_RmpTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `VArPct_WinTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `VArPct_RvrtTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `VArPct_RmpTms` | uint16 | none | Secs | RW | own admitted span |
| 123 | `VArPct_Mod` | enum16 | none | none | RW | own admitted span |
| 124 | `WChaGra` | uint16 | `WChaDisChaGra_SF` | % WChaMax/sec | RW | own admitted span |
| 124 | `WDisChaGra` | uint16 | `WChaDisChaGra_SF` | % WChaMax/sec | RW | own admitted span |
| 124 | `InOutWRte_WinTms` | uint16 | none | Secs | RW | own admitted span |
| 124 | `InOutWRte_RvrtTms` | uint16 | none | Secs | RW | own admitted span |
| 124 | `InOutWRte_RmpTms` | uint16 | none | Secs | RW | own admitted span |
| 124 | `ChaGriSet` | enum16 | none | none | RW | own admitted span |
