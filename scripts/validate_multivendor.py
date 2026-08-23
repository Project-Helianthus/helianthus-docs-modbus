#!/usr/bin/env python3
import itertools
import json
import struct
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
    if any(not fixture.get("contract_revision") for fixture in fixtures):
        fail("every fixture needs its own contract revision")
    for fixture in fixtures:
        if fixture.get("expected", {}).get("send") is not False:
            fail(f"{fixture['id']}: documentation fixture must be no-send")

    fronius = fixtures[0]
    if fronius.get("encoding") != "word-fill-v1":
        fail("Fronius fixture encoding is not deterministic")
    if classify_fronius(fronius) != fronius["expected"]:
        fail("Fronius expanded decode does not match expected output")

    profiles = [fixture["expected"]["profile"] for fixture in fixtures]
    matrix = document.get("overlap_matrix", {})
    if matrix.get("profiles") != profiles:
        fail("overlap matrix profile order drift")
    expected_pairs = {tuple(sorted(pair)) for pair in itertools.combinations(profiles, 2)}
    actual_pairs = {tuple(sorted(pair)) for pair in matrix.get("pairs", [])}
    if actual_pairs != expected_pairs or len(matrix.get("pairs", [])) != len(expected_pairs):
        fail("overlap matrix is not complete and unique")
    if matrix.get("expected") != {"profile": None, "disposition": "insufficient_evidence", "send": False}:
        fail("overlap must be insufficient evidence and no-send")


if __name__ == "__main__":
    main()
