import re
from pathlib import Path

import pytest

from scripts.check_public_domain_boundary import unpublishable_attribution, violations


def document(root: Path, text: str) -> None:
    path = root / "protocols" / "vendor" / "wire.md"
    path.parent.mkdir(parents=True)
    path.write_text(text)


@pytest.mark.parametrize(
    "text",
    [
        "Run scan --preset recommended",
        "The planner chooses slots",
        "Helianthus publishes GraphQL",
        "[Application](../../development/client.md)",
    ],
)
def test_rejects_application_material_in_cc0(tmp_path: Path, text: str) -> None:
    document(tmp_path, text)
    assert violations(tmp_path)


def test_keeps_wire_facts_and_source_attribution(tmp_path: Path) -> None:
    document(
        tmp_path,
        "# Wire\nRequest: 09 GG II ADDRESS CODE\n[Types](../../types/overview.md)\n## Sources\n- VRC Explorer captures (payload only)\n",
    )
    assert violations(tmp_path) == []


def test_source_section_does_not_allow_cli_arguments(tmp_path: Path) -> None:
    document(tmp_path, "## Sources\nRun --execute\n")
    assert violations(tmp_path)


def test_source_section_does_not_allow_application_contracts(tmp_path: Path) -> None:
    document(tmp_path, "## Sources\nThe GraphQL API reports planner rows\n")
    assert violations(tmp_path)


def test_application_schema_cannot_be_placed_in_cc0(tmp_path: Path) -> None:
    path = tmp_path / "protocols" / "b524-operation-reads-artifact-schema-v1.json"
    path.parent.mkdir()
    path.write_text("{}")
    assert violations(tmp_path)


def test_negative_scope_statement_is_not_application_policy(tmp_path: Path) -> None:
    document(
        tmp_path,
        "This wire reference contains no\nHelianthus scheduler, profile, qualification, gateway, or semantic policy.\n",
    )
    assert violations(tmp_path) == []


def test_checks_types_as_well_as_protocols(tmp_path: Path) -> None:
    path = tmp_path / "types" / "wire.md"
    path.parent.mkdir()
    path.write_text("Use the VRC Explorer Browser")
    assert violations(tmp_path)


def test_attribution_guard_covers_agpl_documents_too(tmp_path: Path) -> None:
    path = tmp_path / "architecture" / "contract.md"
    path.parent.mkdir()
    path.write_text("Source: UNPUBLISHED-semantic-notes.md")
    assert unpublishable_attribution(tmp_path)


@pytest.mark.parametrize("citation", ["R7_DEEP", "R7-analysis-notes.md"])
def test_rejects_bare_local_analysis_citations(tmp_path: Path, citation: str) -> None:
    document(tmp_path, f"## Evidence\n- {citation}: local analysis\n")
    assert unpublishable_attribution(tmp_path)


@pytest.mark.parametrize(
    "text",
    [
        "The historical V1 name implies no stability before Helianthus 1.0.",
        "Helianthus 1.0.",
        "The registry companion is helianthus-modbusreg issue 353.",
        "Recorded as Helianthus operation-registry facts at commit 9fa7cd8.",
        "Words that Helianthus does not consume are retained as native evidence.",
        "Helianthus-specific architecture remains under the separate license lane.",
        "Terminal field labels used by Helianthus are Helianthus recovered labels.",
        "[Naming](https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/architecture/naming-contract.md)",
    ],
)
def test_allows_project_names_citations_and_public_urls(tmp_path: Path, text: str) -> None:
    document(tmp_path, text)
    assert violations(tmp_path) == []


@pytest.mark.parametrize(
    "text",
    [
        "The rules below are Helianthus operation requirements.",
        "The rules below are Helianthus lifecycle requirements.",
        "Rejected by Helianthus decoder policy.",
        "This is the transport contract for the Helianthus Modbus TCP transport.",
    ],
)
def test_rejects_project_named_application_contracts(tmp_path: Path, text: str) -> None:
    document(tmp_path, text)
    assert violations(tmp_path)


def test_hand_call_sentence_is_not_an_application_contract(tmp_path: Path) -> None:
    document(
        tmp_path,
        "Models 707, 708, and 709 are registers in the modbusreg namespace, "
        "with no SemReg element, and are decoded and callable by hand through "
        "MCP and GraphQL.\n",
    )
    assert violations(tmp_path) == []


def test_other_graphql_text_stays_an_application_contract(tmp_path: Path) -> None:
    document(tmp_path, "The GraphQL planner admits this profile.\n")
    assert violations(tmp_path)


ROOT = Path(__file__).resolve().parents[1]
COMMIT_ID = re.compile(r"\b[0-9a-f]{40}\b")
# Match the token as written, including underscore-joined identifiers.
BANNED_RECORD_TERM = re.compile(r"ledger", re.IGNORECASE)
# Closed opaque-acquisition identifiers. Any other spelling, including the bare
# word, stays banned on the named pages and on the acquisition manifest.
OPAQUE_ACQUISITION_LEDGER_IDENTIFIERS = (
    "ledger_admission_atomic_open_to_closing_blocks_new_registration",
    "ledger_audit_tombstone_limit_finite_positive",
    "ledger_audit_tombstone_max_encoded_bytes_finite_positive",
    "ledger_audit_tombstone_max_encoded_bytes",
    "ledger_audit_tombstone_limit",
    "ledger_linearization_required",
    "ledger_mutation",
    "lowest_ledger_reserved_terminal_sequence_first",
    "immutable_non_owning_not_retained_ledger_state",
    "sealed_immutable_ledger_state_only",
    "shared_ledger_owned_pointer",
    "source_ledger_agreement",
    "m2_ledger",
)
OWNER_FOUNDATION = (
    "https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/main/"
    "docs/platform/modbus-foundation-profile-contract-v1.md"
)
JOURNAL_PAGES = (
    "docs/platform/opaque-runtime-acquisition-v1.md",
    "docs/platform/manifests/opaque-runtime-acquisition-v1.json",
    "protocols/tesla/activation-evidence-worksheet.md",
    "protocols/tesla/activation-observation-hook-v1.md",
    "protocols/huawei/smartlogger-provider-lifecycle-v1.md",
    "protocols/huawei/luna2000-optional-group-v1.md",
)
OPAQUE_ACQUISITION_RECORDS = {
    "docs/platform/opaque-runtime-acquisition-v1.md",
    "docs/platform/manifests/opaque-runtime-acquisition-v1.json",
}
PROSE_WITHOUT_COMMIT_IDS = (
    "architecture/protocol-routing-vendor-sunspec-model-chain-v1.md",
    "protocols/sunspec/sunspec-model-chain-v1.md",
    "protocols/sunspec/read-only-core-v1.md",
    "architecture/protocol-routing-vendor-sunspec-additional-model-evidence-v1.md",
    "architecture/protocol-routing-vendor-fronius-observed-flavor-v1-1.md",
    "protocols/applicability-and-licensing.md",
    "architecture/protocol-routing-vendor-huawei-candidate-evidence-v1.md",
)
FOUNDATION_LINK_PAGES = (
    "docs/platform/opaque-runtime-acquisition-v1.md",
    "docs/platform/fronius-sunspec-evidence-v1.md",
    "docs/platform/modbus-multivendor-boundaries.md",
    "development/modbus-sunspec-deduplication.md",
)
COMPANION_TEST_URL = (
    "https://github.com/Project-Helianthus/helianthus-docs-ebus/blob/main/"
    "tests/test_modbus_companion_contract.py"
)


def test_repository_license_link_is_not_an_application_crossing(tmp_path: Path) -> None:
    (tmp_path / "LICENSE").write_text("CC0-1.0\n", encoding="utf-8")
    document(tmp_path, "[the repository license policy](../../LICENSE)\n")
    assert violations(tmp_path) == []


def test_retained_wire_page_keeps_its_local_license_link() -> None:
    text = (ROOT / "protocols/modbus/modbus-phase-one-wire-v1.md").read_text(encoding="utf-8")
    assert "[the repository license policy](../../LICENSE)" in text
    assert "blob/main/LICENSE" not in text
    assert violations(ROOT) == []


def without_closed_acquisition_identifiers(text: str) -> str:
    for identifier in sorted(OPAQUE_ACQUISITION_LEDGER_IDENTIFIERS, key=len, reverse=True):
        text = text.replace(identifier, "")
    return text


def test_banned_record_term_matches_the_token_inside_an_identifier() -> None:
    assert BANNED_RECORD_TERM.search("m2_ledger")
    assert BANNED_RECORD_TERM.search("ledger_audit_tombstone_limit")
    assert BANNED_RECORD_TERM.search("shared_ledger_owned_pointer")


def test_named_pages_do_not_use_the_banned_record_term() -> None:
    for relative in JOURNAL_PAGES:
        text = (ROOT / relative).read_text(encoding="utf-8")
        if relative in OPAQUE_ACQUISITION_RECORDS:
            text = without_closed_acquisition_identifiers(text)
        assert BANNED_RECORD_TERM.search(text) is None, relative


def test_cited_prose_omits_bare_commit_identifiers() -> None:
    for relative in PROSE_WITHOUT_COMMIT_IDS:
        text = (ROOT / relative).read_text(encoding="utf-8")
        assert COMMIT_ID.search(text) is None, relative
    note = (ROOT / "protocols/sunspec/additional-model-evidence-v1.md").read_text(encoding="utf-8")
    assert "977614c944cd685bef75b5b12148e1110ed7653a" in note


def test_retained_foundation_contract_links_use_the_owner_url() -> None:
    for relative in FOUNDATION_LINK_PAGES:
        text = (ROOT / relative).read_text(encoding="utf-8")
        assert OWNER_FOUNDATION in text, relative
        assert "](./modbus-foundation-profile-contract-v1.md" not in text
        assert "](../docs/platform/modbus-foundation-profile-contract-v1.md" not in text
        assert "](../docs/platform/manifests/modbus-foundation-profile-contract-v1.json" not in text
    dedup = (ROOT / "development/modbus-sunspec-deduplication.md").read_text(encoding="utf-8")
    assert COMPANION_TEST_URL in dedup
    assert "](../tests/test_modbus_companion_contract.py" not in dedup
    assert "#L" not in dedup
