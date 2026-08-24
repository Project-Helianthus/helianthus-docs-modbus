# ShineWiLan-X2 Transparent Modbus Bridge V1

## Scope

This contract describes a transparent bridge from a Modbus TCP client to one
or more downstream Modbus RTU units. It defines only the bridge boundary. It
does not define an inverter register map, a vendor semantic profile, device
identity, firmware applicability, or runtime support.

The bridge is transport infrastructure. A downstream device requires its own
independent protocol profile and qualification.

## Request mapping

The client sends one Modbus TCP application data unit. The bridge uses the
MBAP Unit Identifier as the downstream Modbus RTU unit address and forwards
the request PDU without changing its function code, register offset, quantity,
or payload.

Only Unit Identifiers 1 through 247 are admitted for this response-bearing
bridge contract. Unit Identifier 0 is RTU broadcast and is `NO_SEND`; values
above 247 are reserved or outside the admitted unicast range and are also
`NO_SEND`.

The Transaction Identifier and Protocol Identifier belong to the Modbus TCP
side and are not downstream register semantics. The downstream RTU frame adds
the serial framing and integrity field required by Modbus RTU. The bridge must
not infer a unit, scan unit addresses, substitute a default unit, or route by
vendor name.

## Response mapping

A normal downstream response is returned to the requesting Modbus TCP
transaction with the same Unit Identifier and the downstream response PDU.
An exception response preserves the downstream exception function and code.

A response with the wrong unit, an unrelated transaction, a malformed PDU, an
invalid length, a timeout, or a disconnect is not correlated to the request.
No partial response is published and no alternate unit is tried implicitly.

## Read-only boundary

The read-only candidate surface consists of FC03 holding-register reads and
FC04 input-register reads. Register offsets are zero-based PDU offsets and
quantities remain subject to standard Modbus bounds and to the independently
qualified downstream profile.

This contract does not authorize FC05, FC06, FC0F, FC10, FC17, private
functions, device configuration, address allocation, or any other operation
that may change downstream state. Unsupported or undocumented operations are
`NO_SEND`.

## Identity and admission

Bridge reachability, a successful transaction, a Unit Identifier, or readable
registers do not establish a downstream vendor, family, model, firmware, or
capability profile. The bridge has no semantic registry profile of its own.

Each downstream unit must be qualified independently against one exact
protocol contract. Unknown identity, incomplete version evidence, overlapping
profiles, or an unqualified register map produces `insufficient_evidence` and
no semantic admission. Registration order and first response never select a
profile.

## Transparency limits

Transparency means preservation of the addressed Modbus PDU across the bridge
boundary. It does not imply timing equivalence, multi-client arbitration,
automatic retries, downstream discovery, cache coherence, or support for every
function code.

A caller must use bounded deadlines and one in-flight request per bridge
session unless an independently qualified bridge contract proves stronger
concurrency behavior. A retry is a new explicit transaction and must not widen
the unit, function, register, or quantity.

## Failure behavior

Malformed MBAP framing, an invalid Unit Identifier, invalid PDU bounds,
downstream exception, timeout, disconnect, or response mismatch fails closed.
The failure does not authorize a unit scan, a protocol fallback, a write, or a
different vendor profile.

Unknown but structurally valid downstream data remains owned by the selected
downstream protocol profile. The bridge does not decode, normalize, or assign
semantics to register values.
