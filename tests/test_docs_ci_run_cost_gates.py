"""Docs CI cost gates: receiver workflow concurrency and no local Combined Ref caller."""

from __future__ import annotations

import pathlib

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
DOCS_CI = ROOT / ".github/workflows/docs-ci.yml"
COMBINED_REF = ROOT / ".github/workflows/platform-contracts-combined-ref.yml"


def load(path: pathlib.Path):
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def test_main_pushes_cancel_superseded_runs_but_never_the_nightly_run():
    workflow = load(DOCS_CI)
    concurrency = workflow["concurrency"]
    assert concurrency["group"] == "${{ github.workflow }}-${{ github.event_name }}-${{ github.ref }}"
    assert concurrency["cancel-in-progress"] == (
        "${{ github.event_name == 'pull_request' || github.event_name == 'push' }}"
    )
    triggers = workflow[True]
    assert set(triggers) == {"pull_request", "push", "schedule", "workflow_dispatch"}
    assert triggers["push"]["branches"] == ["main"]


def test_receiver_workflow_has_no_local_combined_ref_caller():
    text = DOCS_CI.read_text(encoding="utf-8")
    assert "uses: ./.github/workflows/platform-contracts-combined-ref.yml" not in text
    assert "platform-contracts-combined-ref.yml" not in text
    assert not COMBINED_REF.exists()
    workflow = load(DOCS_CI)
    assert "platform-contracts-combined-ref" not in workflow["jobs"]
    docs = workflow["jobs"]["markdown-checks"]
    assert docs["name"] == "Docs Checks"
    checkout_paths = [
        step["with"]["path"]
        for step in docs["steps"]
        if step.get("uses", "").startswith("actions/checkout@")
    ]
    assert "checkouts/docs-modbus" in checkout_paths
    assert "checkouts/docs-modbus-base" in checkout_paths
    assert "checkouts/docs" in checkout_paths


NN03_MERGED_REVISION = "ff8fccc7d5fbcbfe1e156fce302549d04a2f6228"


def test_hosted_and_local_callers_use_the_merged_nn03_revision():
    workflow = load(DOCS_CI)
    docs = workflow["jobs"]["markdown-checks"]
    platform = [
        step
        for step in docs["steps"]
        if step.get("with", {}).get("path") == "checkouts/docs"
    ]
    assert len(platform) == 1
    assert platform[0]["with"]["repository"] == "Project-Helianthus/helianthus-docs"
    assert platform[0]["with"]["ref"] == NN03_MERGED_REVISION
    local = (ROOT / "scripts/ci_local.sh").read_text(encoding="utf-8")
    assert f'nn03_revision="{NN03_MERGED_REVISION}"' in local
    assert 'echo "NN03 platform revision ${actual_nn03}"' in local
    assert 'git -C "${HELIANTHUS_DOCS_ROOT}" rev-parse HEAD' in local
