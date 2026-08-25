# Growatt WIT Family and Protocol Qualification Matrix V1

## Scope

This contract separates Growatt WIT commercial family labels from transport
availability, protocol applicability, firmware gates, and runtime admission.
It is a qualification matrix, not a register map or semantic profile.

Each row is an independent, case-sensitive family branch.
A combined marketing page does not make HU, AU, XHU, worldwide, or US branches protocol aliases.
Power range, battery voltage class, market voltage, and a shared accessory do
not establish protocol equivalence.

## Family qualification matrix

| Exact family branch | Product context | Documented communication exposure | Protocol revision | Firmware gate | Disposition |
| --- | --- | --- | --- | --- | --- |
| `WIT 4-25K-HU` | worldwide, 380/400 Vac, low-voltage battery | Modbus TCP available; ShineWiLAN-X2 listed | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 4-25K-XHU` | worldwide, 380/400 Vac, high-voltage battery | Modbus TCP available; ShineWiLAN-X2 listed | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 29.9-50K-XHU` | worldwide, 380/400 Vac, high-voltage battery | ShineWiLan-X2 and ShineSEM-XA-R listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 50-100K-HU` | APAC, 380/400/415 Vac, high-voltage battery | ShineWiLan-X2 and ShineSEM-XA-R listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 50-100K-AU` | APAC, 380/400/415 Vac, high-voltage battery | ShineWiLan-X2 and ShineSEM-XA-R listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 50-100K-HU-US` | US branch; product context not established | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 50-100K-AU-US` | US branch; product context not established | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 63-125K-XHU` | worldwide, 380/400 Vac, high-voltage battery | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 28-55K-HU-US L2` | US L2, 208/220 Vac, high-voltage battery | ShineMaster listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 28-55K-AU-US L2` | US L2, 208/220 Vac, high-voltage battery | ShineMaster listed; wire exposure not established | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |
| `WIT 50-150K-XHU-US` | US, 277/480 Vac, high-voltage battery | not established by this contract | `UNKNOWN` | `UNKNOWN` | `INSUFFICIENT_EVIDENCE`; `NO_SEND` |

Product context is descriptive and is never an identity input.
Modbus TCP availability and a listed logger or bridge are transport facts only.
They do not establish a register map, firmware gate, identity tuple, or semantic profile.

## Explicit VPP V2.01 tuple

`WIT 100KTL3-H` with DTC `5601` is the only WIT tuple explicitly associated with VPP protocol `V2.01`.
The applicable document defines an RTU communication protocol. This tuple is
retained exactly; it is not shortened, widened, or treated as a prefix.

It does not admit `WIT 50-100K-HU`, `WIT 50-100K-AU`, or any other WIT row.
The VPP tuple has no qualified firmware gate in this contract. DTC readability,
an RTU response, an overlapping power rating, or the substring `WIT` is not
sufficient identity evidence.

Every VPP read, control, and write remains `NO_SEND`. The document includes
remote-dispatch authority, so its read and write surfaces must not be split or
partially enabled before an exact firmware gate, sanitized fixture, and
independent safety review exist.

## Protocol isolation

Growatt Protocol II v1.24 TL3-X does not apply to a WIT row by vendor or name similarity.
MAX, MID, and MAC Protocol II facts are not fallback facts for WIT.
Likewise, the WIT VPP tuple is not a fallback for Protocol II, the 1xSxxP ESS
BMS protocol, SunSpec, Fronius, or Huawei.

Registration order, first response, unit address, bridge type, marketing name,
or a shared register offset must not choose among protocols. An observation
that satisfies more than one candidate is ambiguous.

## Admission and failure behavior

No decoder, fixture, catalog registration, runtime admission, telemetry publication, or support claim is created.
Missing or conflicting evidence produces `INSUFFICIENT_EVIDENCE`, no match, and no send.

Qualification of one row requires all of:

- an exact case-sensitive model branch and independently bounded identity
  tuple;
- an exact applicable protocol revision;
- an exact firmware gate within that protocol branch;
- a permitted, sanitized read-only fixture with declared encoding and bounds;
- negative-overlap fixtures against every other Growatt, SunSpec/Fronius, and
  Huawei profile; and
- an operation allowlist that excludes every control and write.

Unknown firmware, an unlisted suffix, a nearby power range, a combined HU/AU
label, malformed identity, timeout, exception, or partial tuple remains
default-denied. No alias, family inheritance, first-match rule, or inferred
firmware ordering is permitted.

## Publication boundary

This independently stated page records bounded interoperability facts. It does
not reproduce vendor register tables, remote-dispatch procedures, screenshots,
source locators, private captures, endpoint coordinates, serial numbers, or
installation identity.
