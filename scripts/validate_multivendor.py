#!/usr/bin/env python3
import itertools
import json
import struct
from copy import deepcopy
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "conformance" / "multivendor-offline-v1.json"
FIXED_LENGTHS = {
    1: {65, 66}, 101: {50}, 102: {50}, 103: {50},
    111: {60}, 112: {60}, 113: {60}, 120: {26}, 121: {30},
    122: {44}, 123: {24}, 124: {24}, 201: {105}, 202: {105},
    203: {105}, 204: {105}, 211: {124}, 212: {124}, 213: {124},
    214: {124}, 305: {36}, 306: {4}, 307: {11}, 308: {4},
}
CONTRACT_REVISIONS = {
    "sunspec-fronius-float-v1.1-positive": "sunspec.models.v1+fronius.float.v1.1",
    "huawei-smartlogger-spc191-candidate": "huawei.smartlogger.v1",
    "huawei-sdongle-r025-candidate": "huawei.sdongle.v1",
    "huawei-emma-r025-candidate": "huawei.emma.v1",
    "growatt-protocol2-tl3x-candidate": "growatt.protocol2.v1.24.tl3x",
}


def fail(message: str) -> None:
    raise SystemExit(message)


def put_ascii(words: list[int], offset: int, extent: int, value: str) -> None:
    data = value.encode("ascii")
    if len(data) > extent * 2:
        fail("ASCII override exceeds declared words")
    data = data.ljust(extent * 2, b"\x00")
    words[offset:offset + extent] = [int.from_bytes(data[index:index + 2], "big") for index in range(0, len(data), 2)]


def read_ascii(words: list[int], offset: int, extent: int) -> str:
    data = b"".join(word.to_bytes(2, "big") for word in words[offset:offset + extent])
    return data.rstrip(b"\x00 ").decode("ascii")


def valid_sunspec_length(model: int, length: int) -> bool:
    if model in FIXED_LENGTHS:
        return length in FIXED_LENGTHS[model]
    if model == 160:
        return 8 <= length <= 65528 and (length - 8) % 20 == 0
    if model == 302:
        return 5 <= length <= 65530 and length % 5 == 0
    if model == 303:
        return 1 <= length <= 65533
    if model == 304:
        return 6 <= length <= 65532 and length % 6 == 0
    return model == 65535 and length == 0


def expand_block(block: dict) -> list[int]:
    model, length = block["model"], block["length"]
    if not valid_sunspec_length(model, length):
        fail(f"invalid SunSpec decoder key {model}/{length}")
    words = [block.get("fill", 0)] * length
    for override in block.get("word_overrides", []):
        if not 0 <= override["offset"] < length:
            fail("word override exceeds block")
        words[override["offset"]] = override["value"]
    for override in block.get("ascii_overrides", []):
        if override["offset"] + override["words"] > length:
            fail("ASCII override exceeds block")
        put_ascii(words, override["offset"], override["words"], override["value"])
    for override in block.get("float32_overrides", []):
        if override["offset"] + 2 > length:
            fail("float override exceeds block")
        high, low = struct.unpack(">HH", struct.pack(">f", override["value"]))
        words[override["offset"]:override["offset"] + 2] = [high, low]
    return words


def classify_fronius(fixture: dict) -> dict:
    source = fixture["input"]
    signature = b"".join(word.to_bytes(2, "big") for word in source["signature_words"])
    if signature != b"SunS":
        fail("invalid SunSpec signature")
    blocks = source["blocks"]
    pairs = [(block["model"], block["length"]) for block in blocks]
    expected_pairs = [(1, 65), (113, 60), (120, 26), (121, 30), (122, 44), (123, 24), (160, 88), (124, 24), (65535, 0)]
    if pairs != expected_pairs or blocks[-1] != {"model": 65535, "length": 0, "fill": 0}:
        fail("Fronius V1.1 chain or terminal drift")
    expanded = {block["model"]: expand_block(block) for block in blocks}
    mppt = expanded[160]
    if len(mppt) != 8 + 20 * mppt[6]:
        fail("Model 160 count and length disagree")
    model_113 = expanded[113]
    power = struct.unpack(">f", struct.pack(">HH", model_113[20], model_113[21]))[0]
    common = expanded[1]
    return {
        "profile": "fronius.sunspec.float.v1",
        "disposition": "qualified_offline",
        "manufacturer": read_ascii(common, 0, 16),
        "model": read_ascii(common, 16, 16),
        "version": read_ascii(common, 40, 8),
        "active_power_w": power,
        "send": False,
    }


def candidate_result(profile: str) -> dict:
    return {"profile": profile, "disposition": "offline_candidate", "send": False}


def classify_smartlogger(fixture: dict) -> dict | None:
    value = fixture["input"]
    if (
        value.get("unit") == 0
        and value.get("change_before") == value.get("change_after")
        and value.get("self_model") == "SmartLogger"
        and value.get("software") in {"V300R024C10SPC191", "V300R024C10SPC210"}
        and value.get("inventory_complete") is True
    ):
        return candidate_result("huawei.smartlogger.readonly.v1")
    return None


def classify_sdongle(fixture: dict) -> dict | None:
    value = fixture["input"]
    if (
        value.get("unit") == 100
        and value.get("model") in {"SDongleA-05", "SDongleB-03", "SDongleB-06"}
        and value.get("software") == "V200R025C00SPC120"
        and value.get("protocol") == "D5.0"
        and value.get("search_state") == 0
        and value.get("sequence_stable") is True
    ):
        return candidate_result("huawei.sdongle.readonly.v1")
    return None


def classify_emma(fixture: dict) -> dict | None:
    value = fixture["input"]
    software = value.get("software", "")
    admitted_software = software == "V100R024C00SPC100" or software == "V100R025C00SPC102"
    if (
        value.get("unit") == 0
        and value.get("offering") == "EMMA"
        and value.get("model") == "EMMA"
        and admitted_software
        and value.get("self_device_id") == 0
        and value.get("product_type") == "HEMS"
        and value.get("inventory_complete") is True
    ):
        return candidate_result("huawei.emma.readonly.v1")
    return None


def classify_growatt(fixture: dict) -> dict | None:
    value = fixture["input"]
    if (
        isinstance(value.get("unit"), int)
        and 1 <= value["unit"] <= 254
        and value.get("protocol_document") == "II-v1.24"
        and value.get("family") == "TL3-X"
        and value.get("device_type") == 6
        and value.get("firmware_words") == [16706, 17220, 17734, 18248, 18762, 19276]
        and value.get("model_words") == [21577, 16705]
        and value.get("protocol_version") == 207
    ):
        return candidate_result("growatt.protocol2.tl3x.readonly.v1")
    return None


def classify_fixture(fixture: dict) -> dict | None:
    classifiers = {
        "sunspec-fronius-float-v1.1-positive": classify_fronius,
        "huawei-smartlogger-spc191-candidate": classify_smartlogger,
        "huawei-sdongle-r025-candidate": classify_sdongle,
        "huawei-emma-r025-candidate": classify_emma,
        "growatt-protocol2-tl3x-candidate": classify_growatt,
    }
    classifier = classifiers.get(fixture["id"])
    if classifier is None:
        fail(f"no classifier for {fixture['id']}")
    return classifier(fixture)


def require_discriminators(fixture: dict) -> None:
    mutations = {
        "huawei-smartlogger-spc191-candidate": [
            ("unit", 1), ("change_before", 8), ("self_model", "EMMA"),
            ("software", "V300R025C10"), ("inventory_complete", False),
        ],
        "huawei-sdongle-r025-candidate": [
            ("unit", 0), ("model", "SmartLogger"), ("software", "V200R022C10"),
            ("protocol", "D4.0"), ("search_state", 1), ("sequence_stable", False),
        ],
        "huawei-emma-r025-candidate": [
            ("unit", 1), ("offering", "SmartHEMS"), ("model", "SmartLogger"),
            ("software", "V100R025C00SPC101"), ("self_device_id", 1),
            ("product_type", "SUN2000"), ("inventory_complete", False),
        ],
        "growatt-protocol2-tl3x-candidate": [
            ("unit", 0), ("protocol_document", "II-v1.20"), ("family", "MIX"),
            ("device_type", 7), ("firmware_words", [0] * 6),
            ("model_words", [0, 0]), ("protocol_version", 206),
        ],
    }
    for key, invalid in mutations.get(fixture["id"], []):
        mutated = deepcopy(fixture)
        mutated["input"][key] = invalid
        if classify_fixture(mutated) is not None:
            fail(f"{fixture['id']}: discriminator {key} is not enforced")


def main() -> None:
    document = json.loads(FIXTURE.read_text(encoding="utf-8"))
    if document.get("schema") != "helianthus-modbus-protocol-conformance/v1":
        fail("unexpected conformance schema")
    fixtures = document.get("fixtures")
    if not isinstance(fixtures, list) or len(fixtures) != 5:
        fail("expected five positive/candidate fixtures")
    ids = [fixture.get("id") for fixture in fixtures]
    if len(set(ids)) != len(ids) or any(not value for value in ids):
        fail("fixture identifiers must be unique and non-empty")
    if {fixture["id"]: fixture.get("contract_revision") for fixture in fixtures} != CONTRACT_REVISIONS:
        fail("fixture contract revisions do not match their profiles")
    for fixture in fixtures:
        if fixture.get("expected", {}).get("send") is not False:
            fail(f"{fixture['id']}: documentation fixture must be no-send")

    fronius = fixtures[0]
    if fronius.get("encoding") != "word-fill-v1":
        fail("Fronius fixture encoding is not deterministic")
    if classify_fronius(fronius) != fronius["expected"]:
        fail("Fronius expanded decode does not match expected output")

    for fixture in fixtures[1:]:
        if classify_fixture(fixture) != fixture["expected"]:
            fail(f"{fixture['id']}: classifier output mismatch")
        require_discriminators(fixture)

    profiles = [fixture["expected"]["profile"] for fixture in fixtures]
    fixtures_by_id = {fixture["id"]: fixture for fixture in fixtures}
    matrix = document.get("overlap_matrix", {})
    if matrix.get("profiles") != profiles:
        fail("overlap matrix profile order drift")
    expected_pairs = {tuple(sorted(pair)) for pair in itertools.combinations(profiles, 2)}
    actual_pairs = set()
    for pair in matrix.get("pairs", []):
        if pair.get("same_endpoint") is not True or pair.get("same_unit") is not True:
            fail("overlap fixture must normalize one endpoint and unit")
        pair_fixtures = [fixtures_by_id.get(value) for value in pair.get("fixture_ids", [])]
        if len(pair_fixtures) != 2 or any(value is None for value in pair_fixtures):
            fail("overlap fixture references unknown candidates")
        outputs = [classify_fixture(value) for value in pair_fixtures]
        if any(value is None for value in outputs):
            fail("overlap fixture does not contain two positive candidates")
        actual_pairs.add(tuple(sorted(value["profile"] for value in outputs)))
        if matrix.get("expected") != {"profile": None, "disposition": "insufficient_evidence", "send": False}:
            fail("overlap selector did not fail closed")
    if actual_pairs != expected_pairs or len(matrix.get("pairs", [])) != len(expected_pairs):
        fail("overlap matrix is not complete and unique")
    if matrix.get("expected") != {"profile": None, "disposition": "insufficient_evidence", "send": False}:
        fail("overlap must be insufficient evidence and no-send")


if __name__ == "__main__":
    main()
