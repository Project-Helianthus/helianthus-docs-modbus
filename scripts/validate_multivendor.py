#!/usr/bin/env python3
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "conformance" / "multivendor-offline-v1.json"


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    document = json.loads(FIXTURE.read_text(encoding="utf-8"))
    if document.get("schema") != "helianthus-modbus-protocol-conformance/v1":
        fail("unexpected conformance schema")
    if document.get("schema_revision") != "sunspec.models.v1":
        fail("unexpected SunSpec schema revision")

    fixtures = document.get("fixtures")
    if not isinstance(fixtures, list) or len(fixtures) != 7:
        fail("expected seven conformance fixtures")
    ids = [fixture.get("id") for fixture in fixtures]
    if len(set(ids)) != len(ids) or any(not value for value in ids):
        fail("fixture identifiers must be unique and non-empty")

    for fixture in fixtures:
        expected = fixture.get("expected", {})
        if expected.get("send") is not False:
            fail(f"{fixture['id']}: documentation fixture must be no-send")

    fronius = fixtures[0]
    if fronius.get("encoding") != "word-fill-v1":
        fail("Fronius fixture encoding is not deterministic")
    blocks = fronius["input"]["blocks"]
    pairs = [(block["model"], block["length"]) for block in blocks]
    expected_pairs = [(1, 65), (113, 60), (120, 26), (121, 30), (122, 44), (123, 24), (160, 88), (124, 24), (65535, 0)]
    if pairs != expected_pairs:
        fail("Fronius V1.1 chain geometry drift")
    for block in blocks:
        if block["length"] < 0 or block.get("fill") != 0:
            fail("invalid compact word-fill block")
        for override in block.get("word_overrides", []):
            if not 0 <= override["offset"] < block["length"]:
                fail("word override exceeds block")
        for override in block.get("ascii_overrides", []):
            if override["offset"] + override["words"] > block["length"]:
                fail("ASCII override exceeds block")
            if len(override["value"].encode("ascii")) > override["words"] * 2:
                fail("ASCII override exceeds declared words")
    mppt = next(block for block in blocks if block["model"] == 160)
    if mppt["length"] != 8 + 20 * mppt["word_overrides"][0]["value"]:
        fail("Model 160 count and length disagree")

    collisions = [fixture for fixture in fixtures if fixture["id"].startswith("collision-")]
    if len(collisions) != 2:
        fail("expected two collision fixtures")
    for collision in collisions:
        if collision["expected"] != {"profile": None, "disposition": "insufficient_evidence", "send": False}:
            fail("collision must be insufficient evidence and no-send")


if __name__ == "__main__":
    main()
