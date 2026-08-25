# OutBack AXS Port SunSpec Read-Only Boundary V1

## Scope

This contract defines a bounded read-only interpretation for the OutBack AXS
Port SunSpec interface. It is an OutBack flavor over a SunSpec model chain; it
does not convert an OutBack device into a generic inverter profile.

Every value described here is observed state only. This contract creates no
write method, send authority, operation admission, automatic acquisition,
runtime activation, support claim, or consumer exposure.

## Chain selection

The chain must first satisfy the generic SunSpec Common Model boundary. The
OutBack flavor is a structural candidate only when the same chain contains
vendor Model 64110 with declared length 282. A different model identifier or a
different declared length is opaque and is not an OutBack match.

Model 64110 is a vendor boundary. It must not be substituted for a standard
SunSpec model, and standard model identifiers must not be used to infer the
OutBack flavor.

## Observed state

For Model 64110, this revision may retain only the three firmware-number words
at model offsets 2 through 4 and the observed temperature, scale, error, and
status words at offsets 278 through 282. Values retain their exact raw word
spans. Signed temperature values use the declared scale word only when that
scale is available and valid; otherwise the raw words remain unscaled.

The chain may also contain standard charge-controller Model 64111 with declared
length 23. Its values remain standard observed state under the generic SunSpec
rules. The presence of Model 64111 does not infer a relationship with any other
model occurrence, port, controller, or physical device.

All other Model 64110 words, all unknown models, and every wrong-length model
remain opaque. Unknown status or error bits retain raw numeric provenance; this
contract does not create inferred labels.

## Excluded fields and operations

Network settings, device addresses, hardware addresses, credentials, passwords,
mail settings, time settings, logging controls, configuration values, and all
read/write or write-only fields are excluded from output. They are `NO_SEND`.

No function in this contract writes a register, clears a log, changes a device
setting, requests a control action, or derives a control capability. A read-only
observation must not be reused as an authorization token for a later operation.

## Failure and ambiguity

Malformed headers, incomplete spans, invalid scale factors, conflicting model
occurrences, unknown vendor layout, or a collision with another selected vendor
flavor produces no profile match and no partial typed output. The raw block may
be retained with its source span.

The contract does not identify a network endpoint, unit identifier, installation,
or firmware support state. Qualification, runtime scheduling, catalog
registration, and any consumer projection require separate contracts.
