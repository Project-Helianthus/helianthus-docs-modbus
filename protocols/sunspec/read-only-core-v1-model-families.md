# SunSpec Read-Only Core V1 Model Families

## Scope

This guide explains the model families already covered by the executable
`sunspec.models@7abdf898-v1` catalog. It covers 28 distinct standard model
identifiers and 29 exact decoder tuples. It is a reading aid for the V1 core,
not a product compatibility list or an extension of the decoder catalog.

The core contract remains the authority for chain framing, exact lengths, value
sentinels, scale factors, and rejection rules. This page groups those existing
models by the kind of information they describe.

## Decoder Catalog Boundary

Every decoder selection uses model identifier, declared data-register length,
and the executable schema revision together. Model 1 length 66 is current and
length 65 is a compatibility tuple. The length-65 form is the current Common
layout without its final pad word; it is not a separate product family.

The `SunS` signature precedes Common Model 1, which occurs first and exactly
once. Each later block retains its observed order and occurrence. Unknown model
identifiers or lengths remain opaque blocks. A known identifier with a different
length is not decoded best-effort.

## Inverter Families

Models 101, 102, and 103 use integer values with declared scale factors. They
represent single-phase, split-phase, and three-phase inverter layouts,
respectively. The scale factor is part of the same model contract as the raw
measurement; a missing or unavailable factor does not create a substitute
number.

Models 111, 112, and 113 use IEEE FLOAT values. They represent single-phase,
split-phase, and three-phase inverter layouts, respectively. Integer-plus-scale
factor and FLOAT are separate wire encodings. They can describe comparable
measurements only after field-by-field decoding establishes matching quantity,
unit, phase, availability, and value.

## Inverter Extensions

Model 120 describes nameplate ratings. Model 121 describes basic settings, and
Model 122 describes extended measurements and status. Model 123 describes
immediate controls, Model 124 describes basic storage controls, and Model 160
adds repeated multiple-MPPT information.

These extensions are optional additions to a chain. Their absence is not an
error, and a malformed extension does not justify decoding a different length.
Models 123 and 124 are observed state only. Their presence does not add a write
method, control operation, or authorization.

## Meter Families

Models 201, 202, 203, and 204 use integer values with declared scale factors.
They represent, in order, single-phase, split-phase, three-phase wye, and
three-phase delta meter layouts. Models 211, 212, 213, and 214 represent the
same topology sequence with IEEE FLOAT values.

The topology label belongs to the wire model. A meter tuple is not selected by
manufacturer name, product label, registration order, or a partial set of
measurements.

## Environmental Families

Model 302 describes irradiance, Model 303 back-of-module temperature, and Model
304 inclinometer data. Model 305 describes location, Model 306 a reference
point, Model 307 base meteorological data, and Model 308 a compact
meteorological data set.

These models remain optional standard blocks. Their appearance does not identify
a device, infer an installation, or create an environmental profile outside the
exact decoder tuple.

## Safety and Non-Claims

This guide is read-only. It does not create a product, profile, or support
claim. It does not establish a manufacturer flavor, runtime admission,
automatic acquisition, telemetry publication, or consumer exposure.

No model family in this guide authorizes Modbus writes. A live observation still
requires the separate qualification and negative-overlap rules of the consuming
profile registry.
