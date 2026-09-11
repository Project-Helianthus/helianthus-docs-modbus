# Growatt Protocol II Source and Profile Evidence Matrix V1

## Scope

This matrix records source provenance and provider-local field disposition for
the [Protocol II read-only candidate](protocol-ii-readonly-v1.md). It defines
no operation, decoder, runtime admission, or write.

## Retained primary source

| Source ID | Title and version | Extent | SHA-256 | Evidence disposition |
| --- | --- | --- | --- | --- |
| `growatt-rtu-v1.24` | *Growatt Inverter Modbus RTU Protocol V1.24* | 85 pages | `fac88d609d74ff6b3c9c31ed65370d166d1fb17461e91b4b4855018fe232a320` | `vendor-copyright-inspection-only`; non-redistributed |

This matrix publishes only neutral facts necessary to state its qualification
boundary. It does not redistribute the source or vendor schema text.

## Bounded profile result

`NO_ADMISSIBLE_PROFILE`: there is no exact device-type, model-build, and
device-reported protocol-value tuple, and there is no typed field. The retained
source identifies the TL3-X MAX/MID/MAC map but does not bind those three values
together.

## Requested field disposition

`implemented` would require a publicly admitted exact tuple and is absent.
`unsupported` means this version enumerates no such operation; `unknown` means
the retained source does not establish the field for the selected tuple; and
`evidence-needed` means it supplies limited field mechanics but lacks a required
qualification fact.

| Requested provider-local fact | Disposition | Source-supported fact | Closure criterion |
| --- | --- | --- | --- |
| exact device type, model-build pair, and device-reported protocol value | evidence-needed | the source identifies the TL3-X MAX/MID/MAC map but does not map these three values together | publishable provider-owned evidence that binds one exact tuple to this FC04 schema |
| inverter run state | evidence-needed | schema-only synthetic fixture mechanics at offset 0 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| aggregate PV input power | evidence-needed | schema-only synthetic fixture mechanics at offsets 1-2 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| aggregate output power | evidence-needed | schema-only synthetic fixture mechanics at offsets 35-36 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| grid frequency | evidence-needed | schema-only synthetic fixture mechanics at offset 37 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| phase 1 grid voltage and output current | evidence-needed | schema-only synthetic fixture mechanics at offsets 38-39 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| phase 2 grid voltage and output current | evidence-needed | schema-only synthetic fixture mechanics at offsets 42-43 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| phase 3 grid voltage and output current | evidence-needed | schema-only synthetic fixture mechanics at offsets 46-47 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| generated energy today | evidence-needed | schema-only synthetic fixture mechanics at offsets 53-54 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| generated energy total | evidence-needed | schema-only synthetic fixture mechanics at offsets 55-56 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| total work time | evidence-needed | schema-only synthetic fixture mechanics at offsets 57-58 | the exact tuple plus an admitted bounded FC04 acquisition and decoder test |
| per-PV voltage | unknown | no selected-tuple applicability or bounded acquisition is established | an exact field definition, selected-tuple applicability, and bounded acquisition/decoder tests |
| per-PV current | unknown | no selected-tuple applicability, signedness, or bounded acquisition is established | an exact field definition, selected-tuple applicability and signedness, and bounded acquisition/decoder tests |
| per-PV power | unknown | no selected-tuple applicability or bounded acquisition is established | an exact field definition, selected-tuple applicability, and bounded acquisition/decoder tests |
| per-phase output power | unknown | no selected-tuple semantics, units, or composition are established | an exact field definition, selected-tuple applicability, units/composition, and bounded acquisition/decoder tests |
| line-to-line voltage | unknown | no selected-tuple semantics, units, or composition are established | an exact field definition, selected-tuple applicability, units/composition, and bounded acquisition/decoder tests |
| inverter temperature | evidence-needed | the source supplies 0.1 C at offset 93, but not signedness, invalid handling, or selected-tuple applicability | an exact field definition with signedness and invalid handling, selected-tuple applicability, and bounded acquisition/decoder tests |
| internal IPM temperature | unknown | no field-specific selected-tuple definition is established | an exact field definition, selected-tuple applicability, and bounded acquisition/decoder tests |
| boost temperature | unknown | no field-specific selected-tuple definition is established | an exact field definition, selected-tuple applicability, and bounded acquisition/decoder tests |
| power factor | unknown | no field-specific selected-tuple definition is established | an exact field definition, selected-tuple applicability, and bounded acquisition/decoder tests |
| derating | unknown | no field-specific selected-tuple definition is established | an exact field definition, selected-tuple applicability, enum/sentinel handling, and bounded acquisition/decoder tests |
| fault facts | unknown | no field-specific selected-tuple definition is established | an exact field definition, selected-tuple applicability, enum/bitfield/sentinel handling, and bounded acquisition/decoder tests |
| warning facts | unknown | no field-specific selected-tuple definition is established | an exact field definition, selected-tuple applicability, enum/bitfield/sentinel handling, and bounded acquisition/decoder tests |
| storage or battery overlays | unknown | no selected-tuple overlay definition is established | an exact overlay contract with selected-tuple applicability, bounded acquisition, and decoder tests |
| every otherwise unlisted offset 59-124 | unknown | no field-specific selected-tuple definition is established | an exact field definition, selected-tuple applicability, and bounded acquisition/decoder tests for each offset |
| FC06, FC16, and every other control operation | unsupported | this read-only version enumerates no control operation | a separate exact operation contract; this matrix does not authorize a real-device write |
