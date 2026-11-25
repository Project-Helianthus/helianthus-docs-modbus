# Wall Connector Gen 3 TEDAPI — compatibility landing

The [TEDAPI message specification](tedapi-specification.md) is normative for
HTTP and function-100 transports, access control, messages, behaviour and
schemas. The [RS-485 site-controller protocol specification](rs485-site-controller-protocol.md)
defines the serial link and functions 100–105. TEDAPI is not limited to EVSE
operations; the transport, firmware and access rules determine applicability.

### FC100 EVSE operation numbers

See the TEDAPI specification's [message catalogue](tedapi-specification.md#6-message-catalogue)
for operation numbers, bodies and units. A defined field does not establish a
meaning for an unspecified member, and a schema definition does not establish
device support.

## Driver support

The [read-acquisition contract](gen3-read-acquisition-v1.md) selects the
supported EVSE reads. Defined per-phase fields can remain native without a
semantic projection. Driver records retain complete bounded native payloads
with version, function, direction and outcome.

The [current-limit operation contract](gen3-current-limit-operation-v1.md)
governs the separately admitted provisional current-limit mutation. Persistent
installation settings are a defined TEDAPI operation, not a driver setter.
The specification does not enable additional driver operations or grant
operation authority, including generic enable or disable.
