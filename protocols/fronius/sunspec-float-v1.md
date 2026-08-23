# Fronius SunSpec Float Flavor V1

## Scope

This flavor specifies one Fronius three-phase float SunSpec V1.1 chain. It consumes
the standard SunSpec core and adds only manufacturer applicability and observed
chain geometry. It does not redefine standard units, sentinels, fields, or
capabilities.

## Exact chain geometry

The V1.1 chain has this ordered model sequence:

```text
1/65
113/60
120/26
121/30
122/44
123/24
160/88
124/24
ffff/0
```

Each pair is `model-id/declared-length`. A different length selects a different
schema revision or remains opaque. Optional models may be absent on another
Fronius product, but that product does not inherit this exact flavor without
its own applicability fixture.

## Applicability

Common Model 1 must contain manufacturer `Fronius`, model `Symo GEN24 10.0`,
and version `1.41.11-1`. Serial number is retained only as private provenance
and is not a detector or a public fact. Any other tuple is outside this flavor.

The chain must contain Model 113 with the exact admitted length. Model 103 is a
standard equivalent encoding candidate, not evidence for this float flavor.
Manufacturer identity without a valid chain, or a valid chain without the
manufacturer tuple, is insufficient evidence.

## Read-only result

Decoding this exact geometry yields the standard fields that are valid in
Models 1, 113, 120, 121, 122, 160, and 124. Unknown blocks and unknown fields
retain raw extent and provenance.

This flavor creates no control operation. Model 121 and Model 124 values are
observations only. Automatic activation, live endpoint qualification, and
support publication require separate runtime evidence.

Executable fixture decoding and negative-overlap proof belong to the consuming
profile registry. This page creates no profile admission by itself.
