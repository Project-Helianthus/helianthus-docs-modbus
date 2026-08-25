# AGENTS.md

## Purpose and ownership

`helianthus-docs-modbus` is the public documentation home for Modbus protocol
and vendor-profile evidence used by Helianthus. It owns publishable protocol
facts, vendor evidence, qualification boundaries, and operator-safety guidance.
It does not own Modbus runtime code, registry implementation, gateway
composition, protocol-neutral semantics, or consumer/output bindings.

Preserve the distinction between observed, inferred, qualified, promoted,
unsupported, and unknown. Do not represent a candidate capability as proven.
Document native evidence and any projection loss explicitly. Never publish
credentials, personal data, serials, private network coordinates, device
fingerprints, private captures, restricted material, or unsafe write recipes.

## Workflow

1. Reconcile `origin/main`, the working tree, related issues, branches, pull
   requests, reviews, and checks before editing.
2. Use one scoped issue and an `issue/<number>-<slug>` branch created from
   current `origin/main`. Keep unrelated work out of the branch.
3. Make factual claims traceable to publishable evidence; mark gaps as
   hypothesis or unknown. Keep public fixtures and examples self-contained.
4. Run `./scripts/check_docs.sh` and relevant link or rendering checks before
   pushing. Include the exact commands and results in the pull request.
5. Open a linked pull request. State scope, evidence basis, validation,
   documentation-gate impact, and residual risk.
6. Resolve valid P0-P2 findings, then obtain a fresh exact-HEAD
   `NO_BLOCKING_FINDINGS` review verdict. P3/P4 findings are triaged as fix,
   backlog, or by design.
7. Squash merge only after applicable checks are green and the exact-HEAD
   blocker review is clear. Verify remote `main`, issue, PR, and branch state,
   then stop at the requested boundary.

## Safety boundaries

Documentation must keep reads bounded and fail-closed: discovery and
qualification require explicit read-only allowlists, bounded retries, and
version-aware evidence. Any real installation, credential use, destructive or
irreversible action, safety-relevant control, or live-device write requires
explicit operator confirmation at action time. Public documentation must not
depend on private repositories, private artifacts, local network access, or
personal laboratory equipment.
