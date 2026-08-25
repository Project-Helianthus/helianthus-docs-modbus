# Protocol Applicability and Licensing

## Publication boundary

The protocol material in `protocols/`, including this independently authored
interoperability specification, is published under CC0-1.0. It describes
protocol facts needed to build compatible software. Repository policy,
development guidance, CI tooling, and Helianthus-specific architecture remain
under the separate license lane defined in `LICENSE`. This protocol material
does not redistribute vendor manuals, register tables, screenshots, firmware,
or extracted prose.

The license of this specification does not change the copyright status of
material inspected while establishing a protocol fact. In particular,
vendor-authored material classified as `vendor-copyright-inspection-only` is
copyright-retained and must not be copied into source, fixtures, tests, or
documentation.

## Applicability classes

| Profile | Exact applicability | Evidence class | Initial disposition |
| --- | --- | --- | --- |
| `sunspec.core.readonly.v1` | SunSpec model chains using the explicitly listed model identifiers and lengths | public interoperability standard facts | specified; downstream qualification required |
| `sunspec.der.readonly.v2` | Common 1/66 plus Models 701/153, 702/50, 713/7, and 714 at the exact pinned V2 schema revision | public Apache-2.0 model catalogue and independently stated interoperability facts | offline decoder contract; runtime, vendor, and catalog admission default denied |
| `fronius.sunspec.float.v1` | manufacturer `Fronius`, model `Symo GEN24 10.0`, version `1.41.11-1`, and the exact V1.1 chain | vendor-copyright-inspection-only plus sanitized interoperability facts | specified flavor; downstream qualification required |
| `huawei.smartlogger.readonly.v1` | SmartLogger with exact firmware `V300R024C10SPC191` or `V300R024C10SPC210` | vendor-copyright-inspection-only | offline candidate, default denied |
| `huawei.sdongle.readonly.v1` | SDongleA-05, SDongleB-03, or SDongleB-06 with exact firmware `V200R025C00SPC120` and protocol D5.0 | vendor-copyright-inspection-only | offline candidate, default denied |
| `huawei.emma.readonly.v1` | SmartHEMS `EMMA-A01` or `EMMA-A02`, with R024C00 SPC100+ or R025C00 SPC102+ in the same branch | vendor-copyright-inspection-only | offline candidate, default denied |
| `growatt.protocol2.tl3x.readonly.v1` | Growatt Protocol II v1.24 TL3-X class covering MAX, MID, and MAC register ranges | vendor-copyright-inspection-only | offline candidate, default denied |
| `growatt.shinewilan-x2.bridge.v1` | ShineWiLan-X2 transparent Modbus TCP to downstream Modbus RTU bridge boundary | vendor-copyright-inspection-only | transport contract only; no semantic profile or downstream admission |
| `growatt.bms.rs485.1xsxxp.v2_02.readonly.v1` | exact 1xSxxP ESS tuple: Rev2.01 file family, V2.0 header, cumulative changes through 2.02 | vendor-copyright-inspection-only | protocol specified; registry NO_GO pending an exact permitted clean-room fixture |
| `growatt.wit.family-protocol-matrix.v1` | exact WIT commercial family rows plus the isolated WIT 100KTL3-H / DTC 5601 VPP V2.01 tuple | vendor-copyright-inspection-only | qualification matrix only; all operations NO_SEND and registry NO_GO |

No disposition in this table proves a particular installation, firmware image,
endpoint, or live support state. `Offline candidate` is not registered for
automatic detection or acquisition.

The SunSpec V2 offline contract is pinned to the public Apache-2.0 SunSpec model
catalogue at commit
`90b4a331dcca1d6eac69c1bead952fddcc5852e0`. That upstream license applies to
the catalogue input. The independently stated protocol contract in this
repository remains CC0-1.0 and does not reproduce upstream descriptions,
tables, labels, or generated model files.

## Admission rules

Downstream profile admission requires an exact endpoint and unit observation,
an exact family and version gate, a complete read-only fixture, and executable
negative-overlap tests against every other candidate. A missing discriminator,
unknown version, conflicting detector, malformed field, partial inventory, or
unlicensed required fact produces `insufficient_evidence` and no send.

Function-code readability, a vendor string, a writable name, a serial number,
registration material, or registration order is never sufficient. Profiles do
not inherit or fall back between vendor families.

## Architecture separation

These pages define wire and applicability contracts only. They do not define a
gateway scheduler, registry implementation, public API, canonical energy
semantics, deployment configuration, or consumer binding.
