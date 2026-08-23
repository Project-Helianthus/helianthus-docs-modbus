# Fronius SunSpec Float Flavor V1

## Scope

This flavor qualifies one Fronius three-phase float SunSpec chain. It consumes
the standard SunSpec core and adds only manufacturer applicability and observed
chain geometry. It does not redefine standard units, sentinels, fields, or
capabilities.

## Exact chain geometry

The admitted offline fixture has this ordered model sequence:

```text
1/65
113/60
120/26
121/30
122/44
160/88
124/24
ffff/0
```

Each pair is `model-id/declared-length`. A different length selects a different
schema revision or remains opaque. Optional models may be absent on another
qualified Fronius product, but that product does not inherit this exact flavor
without its own applicability fixture.

## Applicability

Common Model 1 must identify the Fronius manufacturer family and provide a
non-sensitive model and version tuple compatible with the selected flavor.
Serial number is retained only as private provenance and is not a detector or a
public fact.

The chain must contain Model 113 with the exact admitted length. Model 103 is a
standard equivalent encoding candidate, not evidence for this float flavor.
Manufacturer identity without a valid chain, or a valid chain without the
manufacturer tuple, is insufficient evidence.

## Read-only result

Successful fixture decoding yields the standard fields that are valid in
Models 1, 113, 120, 121, 122, 160, and 124. Unknown blocks and unknown fields
retain raw extent and provenance.

This flavor creates no control operation. Model 121 and Model 124 values are
observations only. Automatic activation, live endpoint qualification, and
support publication require separate runtime evidence.
