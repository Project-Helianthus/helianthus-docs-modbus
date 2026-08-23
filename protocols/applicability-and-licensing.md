# Protocol Applicability and Licensing

## Publication boundary

The text in this repository is an independently authored interoperability
specification published under CC0-1.0. It describes protocol facts needed to
build compatible software. It does not redistribute vendor manuals, register
tables, screenshots, firmware, or extracted prose.

The license of this specification does not change the copyright status of
material inspected while establishing a protocol fact. In particular,
vendor-authored material classified as `vendor-copyright-inspection-only` is
copyright-retained and must not be copied into source, fixtures, tests, or
documentation.

## Applicability classes

| Profile | Exact applicability | Evidence class | Initial disposition |
| --- | --- | --- | --- |
| `sunspec.core.readonly.v1` | SunSpec model chains using the explicitly listed model identifiers and lengths | public interoperability standard facts | qualified offline |
| `fronius.sunspec.float.v1` | Fronius chain with Common Model 1 and three-phase float inverter Model 113, plus the listed optional standard models | vendor-copyright-inspection-only plus sanitized interoperability fixtures | qualified offline flavor |
| `huawei.smartlogger.readonly.v1` | SmartLogger V300R024C10 and V300R025C10 branches that pass an exact structured firmware gate | vendor-copyright-inspection-only | offline candidate, default denied |
| `huawei.sdongle.readonly.v1` | SDongleA-05, SDongleB-03, and SDongleB-06 only within an explicitly listed V100 or V200 branch | vendor-copyright-inspection-only | offline candidate, default denied |
| `huawei.emma.readonly.v1` | EMMA SmartHEMS R024 SPC100 or later, or R025 SPC102 or later, compared only within the matching branch | vendor-copyright-inspection-only | offline candidate, default denied |
| `growatt.protocol2.tl3x.readonly.v1` | Growatt Protocol II v1.24 TL3-X class covering MAX, MID, and MAC register ranges | vendor-copyright-inspection-only | offline candidate, default denied |

`Qualified offline` proves deterministic fixture decoding. It does not prove a
particular installation, firmware image, endpoint, or live support state.
`Offline candidate` is not registered for automatic detection or acquisition.

## Admission rules

Profile admission requires an exact endpoint and unit observation, an exact
family and version gate, a complete read-only fixture, and negative-overlap
fixtures against every other candidate. A missing discriminator, unknown
version, conflicting detector, malformed field, partial inventory, or
unlicensed required fact produces `insufficient_evidence` and no send.

Function-code readability, a vendor string, a writable name, a serial number,
registration material, or registration order is never sufficient. Profiles do
not inherit or fall back between vendor families.

## Architecture separation

These pages define wire and applicability contracts only. They do not define a
gateway scheduler, registry implementation, public API, canonical energy
semantics, deployment configuration, or consumer binding.
