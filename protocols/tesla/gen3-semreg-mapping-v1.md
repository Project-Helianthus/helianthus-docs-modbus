# Tesla Gen3 SemReg mapping

## Operations

`evse.operation.set_allocated_current` has capability `evse.capability.set_allocated_current` on `evse.service.connector` and effect `evse.effect.set_allocated_current` on the connector subject for the quantity case. The route is t25 to t26, and the readback is t27 to t28. The same operation takes boolean `false` for `evse.limit.allocated_current_enabled` without a numeric argument on release, with `evse.effect.release_allocated_current` on the same connector.

Release sends only the documented triple with a valid nonzero configured current, then stops renewal and requires the matching release t28 before publishing false. Missing, zero or invalid configured current sends no release t25 and yields no confirmed release. A numeric set at the configured maximum is still a renewed set and 0 A still pauses.

Six amperes is the lowest charging current a charger can signal, so 1 A through 5 A is refused and 0 A requests a pause. The t25 native scalar is integer amperes. Require an exactly representable whole-ampere value with no truncation or rounding, and reject 6.5 A before any read or mutation. The pause encodes 6 A with inhibit and therefore needs a usable same-generation t28 configured bound of at least 6 A before t25. A cached 5 A bound yields no request, and a bound of 5 A first learned by the prerequisite t27 sends no t25.

The upper limit is the configured current of the latest t28 in the same lifecycle generation. A value refused before a read is needed sends nothing. Where the generation has no t28, the t27 to t28 limit read may run first, and a value above the limit then read sends no t25 and has no mutation retry. The t25 mutation is never retried. The t27 to t28 read keeps the bounded read acquisition rules of the [read acquisition contract](gen3-read-acquisition-v1.md). A recovered read cannot replay t25 or complete a mutation from a superseded generation.

An explicitly called set or withdrawal whose capability is independently qualified and whose profile, version, generation and dispatch checks pass still requires explicit operator confirmation at action time. Those checks are additional conditions, and an ordinary live caller, including a gateway or MCP caller, is not exempt. The operations are also decoded and callable by hand through MCP and GraphQL in the modbusreg namespace. Consumers write the SemReg elements through the semantic operation route.

## Field rules

Persistent `MaxOutputCurrentAmps` maps to `evse.limit.configured_current` on the charger. Provisional `LimitCurrentMaxAmps` maps to `evse.limit.allocated_current` on the connector. The native provisional triple is retained as the device reports it, also while charging is inhibited. An inhibited readback is mapped to 0 A at the connector, never to the 6 A the native triple carries in a pause. With inhibit false, a present nonzero current maps as reported while it has a current native allocation.

For a qualified managed mutation with a known nonzero timeout, anchor the lifetime to the actual t25 to t26 set acknowledgement. Its later t28 can qualify the value without renewing that lifetime. A t28 received 70 s after a 60 s provisional set withholds the current allocation and retains the expiry fact. At or after expiry withhold the current allocation, retain the expiry fact, and preserve the native evidence.

A known nonzero current with an unresolved zero timeout retains the native unresolved-expiry disposition without inventing a deadline. A returned zero current with inhibit false leaves `evse.limit.allocated_current` unknown and keeps the zero in native evidence. Configured current is read wherever the device reports it. The t28 configured-current field contributes by its receipt in the same epoch. A present nonzero configured-current field supplies amperes. A newer t28 with field 2 explicitly zero supersedes an earlier persistent t8 as unknown and retains the raw zero and evidence without publishing a numeric limit. A t28 omitting field 2 supplies no update and the earlier still-current t8 remains the candidate. Units are ampere. The injected read-only projection is the non-sending getter. The operations above are separate from it.

## Relations

`evse.relation.connector_phase` is a gate rule where the pages document per-phase values, `evse.relation.connector_session` is a gate rule where the pages document a session per connector, and `evse.relation.evse_meter` is configuration for the charger's own energy counter. Phase values are phase dimensions of the connector. The session episode is anchored on the session start the pages name. A relation the pages do not support is unknown with a reason naming the missing statement.
