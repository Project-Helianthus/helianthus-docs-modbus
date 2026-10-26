# Huawei SUN2000 and LUNA2000 Read-Only Disposition V1

## Scope

SUN2000 (inverter) and LUNA2000 (battery, an optional group attached to an
inverter) are two Huawei native Modbus device classes. They are not SunSpec
profiles and do not fall back to SmartLogger, EMMA, S-Dongle, or each other.
This revision records a fail-closed disposition for each class. It defines no
register map, no decoder, and no acquisition.

## Evidence status

| Class | Evidence status | Model families | Firmware ranges | Registers |
| --- | --- | --- | --- | --- |
| SUN2000 | `unknown`; nothing is observed, inferred, or qualified | none covered; all unsupported | none covered; all unsupported | all unknown |
| LUNA2000 | `unknown`; nothing is observed, inferred, or qualified | none covered; all unsupported | none covered; all unsupported | all unknown |

Registers are classified unknown for model identity, firmware identity, unit
identity, monitoring values, scale and unit, access mode, and availability
markers. They are never inferred from another Huawei class.

The cells that read none covered and all unsupported state that this
disposition covers no model row yet and that no support claim exists. They set
no software limit. When a revision of this page rests on a consulted document,
its coverage is stated per documented model row as a software floor under the
[software applicability rule](monitoring-readonly-v1.md#software-applicability),
and a build that follows the floor is never refused for being unseen.

## Disposition

Both classes have the outcome `NO_ADMISSIBLE_PROFILE` in this revision.

The only candidate source is the vendor interface definition document named
`Huawei SUN2000 MODBUS Interface Definitions`. It is
`vendor-copyright-inspection-only` and no exact version is pinned, so no
register address, scale, unit, access mode, or string is published here or in
the registry. No model family and no firmware range is covered.

Both classes remain default denied: `catalog_registered=false`,
`automatic_runtime_admission=false`, `support_claim=false`, and
`write_authority=false`. No live qualification has been performed.

## Reopen requirements

A class is reopened only when all of these exist:

- a pinned vendor document name and version;
- a clean-room sanitized identity fixture;
- a clean-room sanitized monitoring fixture; and
- executable negative overlap against SmartLogger, EMMA, and S-Dongle.

The existence of this page satisfies only the registry's companion-page
requirement. It satisfies none of the four requirements above, and reopening
also requires a revision of this page that replaces the disposition with an
exact applicability contract.

The pinned document name and version identify the source that such a revision
rests on. They are its citation key and bound no coverage: the coverage of the
revision is the software floor of each model row that the document covers.

## Detection contract

A future profile selection requires all of: exact model identity, exact
firmware identity, unit identity, and a pinned register map.

Not identity: serial number, ESN, writable alias, register readability, a model
string in a SmartLogger or EMMA child inventory, or a prefix or wildcard model
match.

Exact firmware identity means the firmware string as read, retained exactly. It
is compared with the software floor of the model row that the pinned map covers,
under the software applicability rule, and never with a list of observed builds.

The default outcome is `INSUFFICIENT_EVIDENCE`. More than one positive
candidate for one endpoint and unit is `AMBIGUOUS` with no selection and no
ordering or priority rule. Every row selects no profile and emits zero native
facts. The table is a decision contract only; it is not executable detection.

### SUN2000 decision rows

| Row | Outcome | Reason |
| --- | --- | --- |
| `no_identity_evidence` | `INSUFFICIENT_EVIDENCE` | no model, firmware, or unit identity was read |
| `gateway_inventory_child_model_only` | `INSUFFICIENT_EVIDENCE` | a gateway child listing is not unit identity |
| `model_without_firmware` | `INSUFFICIENT_EVIDENCE` | model identity without a firmware identity read at the unit |
| `serial_or_esn_only` | `INSUFFICIENT_EVIDENCE` | serial number or ESN is never a qualification predicate |
| `firmware_without_model` | `INSUFFICIENT_EVIDENCE` | firmware identity without an exact model identity |
| `register_readability_only` | `INSUFFICIENT_EVIDENCE` | a successful read of any register is not identity |
| `battery_group_absent` | `INSUFFICIENT_EVIDENCE` | the optional group is absent; facts stay unknown, never numeric zero |
| `battery_group_exception` | `INSUFFICIENT_EVIDENCE` | an optional-group read exception does not negate an identified unit |
| `multiple_positive_candidates` | `AMBIGUOUS` | no winner is chosen by order or priority |
| `exact_identity_with_pinned_register_map` | `NO_ADMISSIBLE_PROFILE` | would be positive, but no pinned register map is admissible today |

### LUNA2000 decision rows

| Row | Outcome | Reason |
| --- | --- | --- |
| `no_identity_evidence` | `INSUFFICIENT_EVIDENCE` | no model, firmware, or unit identity was read |
| `gateway_inventory_child_model_only` | `INSUFFICIENT_EVIDENCE` | a gateway child listing is not unit identity |
| `parent_inverter_unidentified` | `INSUFFICIENT_EVIDENCE` | the parent inverter has no positive identity, so no battery profile is selected |
| `model_without_firmware` | `INSUFFICIENT_EVIDENCE` | model identity without a firmware identity read at the unit |
| `serial_or_esn_only` | `INSUFFICIENT_EVIDENCE` | serial number or ESN is never a qualification predicate |
| `register_readability_only` | `INSUFFICIENT_EVIDENCE` | a successful read of any register is not identity |
| `battery_group_absent` | `INSUFFICIENT_EVIDENCE` | the optional group is absent; facts stay unknown, never numeric zero |
| `battery_group_exception` | `INSUFFICIENT_EVIDENCE` | an optional-group read exception does not negate an identified unit |
| `multiple_positive_candidates` | `AMBIGUOUS` | no winner is chosen by order or priority |
| `exact_identity_with_pinned_register_map` | `NO_ADMISSIBLE_PROFILE` | would be positive, but no pinned register map is admissible today |

A SmartLogger or EMMA child inventory that lists a SUN2000 or LUNA2000 model
does not make either class a candidate of that gateway and does not select
either class.

## Optional groups

The SUN2000 battery attachment and the LUNA2000 battery unit presence are
optional groups. An absent group yields unknown values, never numeric zero. A
read exception on an optional group does not negate an already identified unit
and retains last-known-good values where a future profile permits.

## Safety

All writes and control paths are default denied. Huawei FC0x41 and FC0x17 are
`NO_SEND` for both classes, consistent with the profile-scoped rule in
[`gateway-readonly-v1.md`](gateway-readonly-v1.md). No fixture, decoder, or
catalog registration is created, and no support claim exists.

The SmartLogger, EMMA, and S-Dongle candidates are defined in
[`gateway-readonly-v1.md`](gateway-readonly-v1.md) and
[`qualification-readiness-v1.md`](qualification-readiness-v1.md).

## Observed identity applicability

Bounded read-only observation of a SmartLogger-family gateway has since
provided identity facts for one SUN2000 tuple. They are recorded, with their
grades and the exact tuple, in the
[SUN2000 identity contract](sun2000-observed-identity-v1.md). That page
supersedes the identity rows of the evidence-status table above for identity
only. It publishes the register offsets that this page deliberately omits, and
it states no register map. The statements above about covered families and
firmware describe profile admission with a pinned register map and are
unchanged: both classes keep the outcome `NO_ADMISSIBLE_PROFILE`, and the
LUNA2000 class has no observed tuple. The gateway-side rules for a child
listing are in the [gateway contract](gateway-readonly-v1.md).
