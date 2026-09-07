# OutBack AXS Port SunSpec Read-Only Boundary V1

## Scope

This contract defines the bounded structural boundary for an OutBack AXS Port
SunSpec candidate. The source/profile decision is governed by
[the public source and profile matrix](axs-port-source-profile-matrix-v1.md).
It does not convert an OutBack device into a generic inverter profile.

Every value described here is observed state only. This contract creates no
write method, send authority, operation admission, automatic acquisition,
runtime activation, support claim, or consumer exposure.

## Source-pinned qualification

The pinned public corpus conflicts: the owner manual revision C declares `64110/282`, while application note revision 5 declares `64110/420`; it also disagrees on the 64111 length. The finite selector is therefore `NO_GO` until a
public product- and firmware-specific compatibility source identifies exactly
one layout and a separate source-pinned operation contract supplies bounded
read details.

A `64110/282` chain is an offline structural candidate only. It is not an
admitted profile, a runtime acquisition plan, or evidence that any product or
firmware implements the revision-C layout.

## Chain selection

When a later source-qualified operation exists, the chain must first satisfy
the generic SunSpec Common Model boundary. The revision-C structural candidate
requires exactly one vendor Model 64110 with declared length 282. A different
model identifier, a different declared length, a duplicate occurrence, or a
conflicting source layout is `NO_GO` and has no partial typed output.

Model 64110 is a vendor boundary. It must not be substituted for a standard
SunSpec model, and standard model identifiers must not be used to infer the
OutBack flavor.

## Observed state and requested-output dependencies

For the non-admitted revision-C candidate, the matrix records source spans for
firmware words 2 through 4 and temperature, scale, error and status words 278
through 282. These are `MISSING_EVIDENCE` outputs until the matrix selector and
read operation both qualify them. A future provider preserves exact raw word
spans; signed temperature uses a declared scale only when that scale is
available and valid. Otherwise raw words remain unscaled.

Model 64111 remains opaque. Its source length conflicts between the pinned
sources, so it does not infer a relationship with another model occurrence,
port, controller, or physical device and it creates no typed fact.

All other Model 64110 words, all unknown models, and every wrong-length model
remain opaque. Unknown status or error values retain raw numeric provenance;
this contract does not create inferred labels.

An implementation may retain a complete caller-supplied Model 64110 raw word
block and exact source spans only as immutable native observation evidence. The
raw block preserves its supplied order and must not acquire typed field labels,
a profile match, or control authority from this contract.

## Read operations and provenance

Neither pinned public source supplies an admitted read function, table, absolute address, quantity, response-size bound, timeout or retry bound. The
operation matrix is therefore `NO_GO`: no acquisition request may be issued.
A later source-pinned operation contract must provide all of those bounds.

Replay qualification fails closed on wrong product/profile/version, wrong or
duplicate model length, timeout, partial response, malformed header or length,
invalid scale, conflicting occurrences, unknown fields, or missing immutable
wire/source provenance. A provider retains immutable request and response bytes,
request coordinates and outcome, source key/URL/SHA-256, selector inputs,
model-chain order and raw word spans. Rejection creates no partial typed output.

## Excluded fields and operations

Configuration-like, network, address, hardware-address, credential, password,
mail, time, logging-control, and other untyped raw words remain native
observation data when supplied; they do not become typed facts or an operation
contract.

Every write or control operation remains `NO_SEND` until an operation-specific
contract defines its function, address, payload, and execution boundary. No
function in this contract writes a register, clears a log, changes a device
setting, requests a control action, or derives a control capability. A
read-only observation must not be reused as an authorization token for a later
operation.

## Failure and ambiguity

Malformed headers, incomplete spans, invalid scale factors, conflicting model
occurrences, unknown vendor layout, a collision with another selected vendor
flavor, or unresolved source conflict produces `NO_GO` and no partial typed output. The raw block may be retained with its source span.

The contract does not identify a network endpoint, unit identifier, installation,
or firmware support state. Qualification, runtime scheduling, catalog
registration, and any consumer projection require separate contracts.
