# Fronius Observed SunSpec Chain V1 — Historical Evidence

## Scope and evidence status

This CC0-1.0 native-evidence note preserves the earlier observed Fronius
SunSpec chain. It is a historical observation, not a family support claim,
profile admission contract, or replacement for the accepted
[V1.1 float flavor](sunspec-float-v1.md). The
[SunSpec read-only core](../sunspec/read-only-core-v1.md) owns standard chain
framing and decoding; the
[applicability and licensing contract](../applicability-and-licensing.md)
keeps native protocol facts separate from application policy and qualification.

`Proven` here means established by the compared public documentation, not
independently reproduced on hardware. `Hypothesis` covers any proposed reason
for the difference between observations. `Unknown` includes applicability to
other devices, firmware, acquisition configurations, and present live state.
None of these evidence labels grants qualification or permission to send.

## Earlier ordered chain and acquisition context

The [earlier public observation](https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/main/protocols/sunspec/fronius-observed-flavor-v1.md)
records this ordered sequence, Proven as a documentary observation:

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

Each pair is `model-id/declared-length`; length counts data registers after
the model header. The final pair is the zero-length SunSpec terminal marker.
Model 123 is absent from this recorded chain. Preserve the sequence and each
declared length rather than treating it as an unordered set or filling in an
optional block.

The same earlier source records FC03 holding-register reads, unit ID `1`,
and normalized PDU offset `40000` for the SunSpec signature. These are
non-actionable observation context, not defaults, a read allowlist, or a
recipe for acquiring another endpoint. They do not select a transport,
construct a request, configure acquisition, or activate runtime work.

The original public preflight provenance is
[gateway issue #807](https://github.com/Project-Helianthus/helianthus-ebusgateway/issues/807).
The source constrains the observation by exact Common manufacturer, model,
and firmware strings; this note retains that constraint by citation without
republishing its device fingerprint. It establishes no broader Fronius
applicability. Endpoint, serial, private capture, and capture-time material
are not reproduced.

## Separate later observation

The [V1.1 source note](https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/main/protocols/sunspec/fronius-observed-flavor-v1-1.md)
describes a separate observation adding standard Model `123/L24`. The accepted
[destination geometry](sunspec-float-v1.md) records its full order:

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

That later observation does not amend the earlier sequence. In particular,
the earlier source's FC03/unit/signature context is not silently attributed to
the later revision. The cause of the structural difference is Unknown; a
firmware change, device change, or acquisition difference would be Hypothesis
without separate evidence. Neither observation proves optional-block presence
or absence across the family.

The [public migration inventory](https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/main/development/modbus-sunspec-deduplication.md)
explicitly distinguishes these revisions. Citations use moving public branch
links; this note records the compared documentary state and does not assert
that future source revisions remain identical.

## Qualification and preservation boundary

The earlier experimental flavor required an already admitted standard
three-phase monitoring capability, exact identity and firmware gates, the
complete ordered chain, and exactly one admitted `113/L60` source. It allowed
no case folding, prefix or version-range matching, subset matching,
reordering, model-ID-only fallback, or integer-plus-scale-factor substitution.
These are historical source constraints, not new native or runtime admission.
The accepted V1.1 geometry and its exact applicability remain unchanged.

The earlier source reports no documented quirk, semantic override, custom
model, or extension fact; standard SunSpec decoders remain authoritative.
Mismatch must not discard native model occurrences or acquisition provenance.
Failed acquisition or admission preserves available native evidence and
separately labelled partial last-known-good state, without turning stale or
incomplete evidence into a new match or partial successful publication.

This note grants no write, configuration, control, automatic activation,
gateway publication, or consumer binding. It provides no decoder fixture,
negative-overlap proof, live qualification, or transport/smoke evidence.
Downstream admission stays fail-closed under its owning contracts; documentary
preservation changes neither eBUS MCP compatibility nor GraphQL parity.
