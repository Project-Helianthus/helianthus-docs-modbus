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
FIXTURE_SECTIONS = {
    "sunspec-fronius-float-v1.1-positive": "fronius",
    "huawei-smartlogger-spc191-candidate": "smartlogger",
    "huawei-sdongle-r025-candidate": "sdongle",
    "huawei-emma-r025-candidate": "emma",
    "growatt-protocol2-tl3x-candidate": "growatt",
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


def read_entry(source: dict, offset: int, quantity: int, phase: str | None = None) -> dict | None:
    matches = [entry for entry in source.get("reads", []) if entry.get("function") == 3 and entry.get("offset") == offset and entry.get("quantity") == quantity and entry.get("phase") == phase]
    return matches[0] if len(matches) == 1 else None


def mei_complete(source: dict, model: str, software: str, product: str, device_id: int | None = None) -> bool:
    mei = source.get("mei", {})
    self_entry = mei.get("self", {})
    return (
        mei.get("function") == 43 and mei.get("type") == 14
        and mei.get("read_code") == 3 and mei.get("start_object") == 135
        and mei.get("complete") is True and mei.get("declared_count") == mei.get("objects")
        and self_entry.get("model") == model and self_entry.get("software") == software
        and self_entry.get("product_type") == product
        and (device_id is None or self_entry.get("device_id") == device_id)
    )


def classify_fronius(observation: dict) -> dict | None:
    source = observation.get("fronius")
    if source is None or observation.get("unit") != 1:
        return None
    signature = b"".join(word.to_bytes(2, "big") for word in source.get("signature_words", []))
    if signature != b"SunS":
        return None
    blocks = source.get("blocks", [])
    expected_pairs = [(1, 65), (113, 60), (120, 26), (121, 30), (122, 44), (123, 24), (160, 88), (124, 24), (65535, 0)]
    if [(block.get("model"), block.get("length")) for block in blocks] != expected_pairs:
        return None
    if blocks[-1] != {"model": 65535, "length": 0, "fill": 0}:
        return None
    expanded = {block["model"]: expand_block(block) for block in blocks}
    if len(expanded[160]) != 8 + 20 * expanded[160][6]:
        return None
    common = expanded[1]
    manufacturer = read_ascii(common, 0, 16)
    model = read_ascii(common, 16, 16)
    version = read_ascii(common, 40, 8)
    if (manufacturer, model, version) != ("Fronius", "Symo GEN24 10.0", "1.41.11-1"):
        return None
    inverter = expanded[113]
    power = struct.unpack(">f", struct.pack(">HH", inverter[20], inverter[21]))[0]
    return {"profile": "fronius.sunspec.float.v1", "disposition": "qualified_offline", "manufacturer": manufacturer, "model": model, "version": version, "active_power_w": power, "send": False}


def candidate_result(profile: str) -> dict:
    return {"profile": profile, "disposition": "offline_candidate", "send": False}


def classify_smartlogger(observation: dict) -> dict | None:
    source = observation.get("smartlogger")
    if source is None or observation.get("unit") != 0:
        return None
    before, after = read_entry(source, 65521, 1, "before"), read_entry(source, 65521, 1, "after")
    software = source.get("mei", {}).get("self", {}).get("software")
    if before and after and before.get("type") == after.get("type") == "u16" and before.get("value") == after.get("value") and software in {"V300R024C10SPC191", "V300R024C10SPC210"} and mei_complete(source, "SmartLogger", software, "LOGGER", 0):
        return candidate_result("huawei.smartlogger.readonly.v1")
    return None


def classify_sdongle(observation: dict) -> dict | None:
    source = observation.get("sdongle")
    if source is None or observation.get("unit") != 100:
        return None
    protocol, kind = read_entry(source, 30068, 2), read_entry(source, 37410, 1)
    state, capacity = read_entry(source, 37411, 1), read_entry(source, 37429, 1)
    before, after = read_entry(source, 37412, 1, "before"), read_entry(source, 37412, 1, "after")
    self_entry = source.get("mei", {}).get("self", {})
    model, software = self_entry.get("model"), self_entry.get("software")
    if (
        protocol and protocol.get("type") == "u32" and protocol.get("value") == 500
        and kind and kind.get("type") == "u16" and kind.get("value") in {2, 3, 5}
        and state and state.get("value") == 0 and capacity and capacity.get("value") == source.get("mei", {}).get("declared_count")
        and before and after and before.get("value") == after.get("value")
        and model in {"SDongleA-05", "SDongleB-03", "SDongleB-06"}
        and software == "V200R025C00SPC120" and self_entry.get("protocol") == "D5.0"
        and mei_complete(source, model, software, "DONGLE")
    ):
        return candidate_result("huawei.sdongle.readonly.v1")
    return None


def classify_emma(observation: dict) -> dict | None:
    source = observation.get("emma")
    if source is None or observation.get("unit") != 0:
        return None
    offering, model_read = read_entry(source, 30000, 15), read_entry(source, 30222, 20)
    software_read = read_entry(source, 30035, 15)
    before, after = read_entry(source, 30801, 1, "before"), read_entry(source, 30801, 1, "after")
    if not all((offering, model_read, software_read, before, after)):
        return None
    software = software_read.get("value")
    if (
        offering.get("type") == model_read.get("type") == software_read.get("type") == "ascii"
        and offering.get("value") == model_read.get("value") == "EMMA"
        and software in {"V100R024C00SPC100", "V100R025C00SPC102"}
        and before.get("value") == after.get("value")
        and mei_complete(source, "EMMA", software, "HEMS", 0)
    ):
        return candidate_result("huawei.emma.readonly.v1")
    return None


def classify_growatt(observation: dict) -> dict | None:
    source = observation.get("growatt")
    unit = observation.get("unit")
    if source is None or not isinstance(unit, int) or not 1 <= unit <= 254:
        return None
    firmware, device_type = read_entry(source, 9, 6), read_entry(source, 43, 1)
    model, protocol = read_entry(source, 82, 2), read_entry(source, 88, 1)
    if (
        source.get("protocol_document") == "II-v1.24" and source.get("family") == "TL3-X"
        and firmware and firmware.get("type") == "words" and firmware.get("value") == [16706, 17220, 17734, 18248, 18762, 19276]
        and device_type and device_type.get("type") == "u16" and device_type.get("value") == 6
        and model and model.get("type") == "words" and model.get("value") == [21577, 16705]
        and protocol and protocol.get("type") == "u16" and protocol.get("value") == 207
    ):
        return candidate_result("growatt.protocol2.tl3x.readonly.v1")
    return None


CLASSIFIERS = [classify_fronius, classify_smartlogger, classify_sdongle, classify_emma, classify_growatt]


def observation_for(fixture: dict, unit: int | None = None) -> dict:
    return {"unit": fixture["input"]["unit"] if unit is None else unit, FIXTURE_SECTIONS[fixture["id"]]: fixture["input"]}


def classify_observation(observation: dict) -> list[dict]:
    return [result for classifier in CLASSIFIERS if (result := classifier(observation)) is not None]


def select_observation(observation: dict) -> dict:
    results = classify_observation(observation)
    if len(results) == 1:
        return results[0]
    if len(results) > 1:
        return {"profile": None, "disposition": "insufficient_evidence", "send": False}
    return {"profile": None, "disposition": "no_match", "send": False}


def require_mutation_rejection(fixture: dict) -> None:
    mutations = []
    if fixture["id"].startswith("sunspec-fronius"):
        for index in range(3):
            mutated = deepcopy(fixture)
            mutated["input"]["blocks"][0]["ascii_overrides"][index]["value"] = "invalid"
            mutations.append(mutated)
    else:
        reads = fixture["input"].get("reads", [])
        for index in range(len(reads)):
            mutated = deepcopy(fixture)
            mutated["input"]["reads"].pop(index)
            mutations.append(mutated)
        if "mei" in fixture["input"]:
            for key in ("function", "type", "read_code", "start_object", "complete", "declared_count", "objects"):
                mutated = deepcopy(fixture)
                mutated["input"]["mei"][key] = None
                mutations.append(mutated)
            for key in fixture["input"]["mei"]["self"]:
                mutated = deepcopy(fixture)
                mutated["input"]["mei"]["self"][key] = "invalid"
                mutations.append(mutated)
        for key in ("protocol_document", "family"):
            if key in fixture["input"]:
                mutated = deepcopy(fixture)
                mutated["input"][key] = "invalid"
                mutations.append(mutated)
    for mutated in mutations:
        if classify_observation(observation_for(mutated)):
            fail(f"{fixture['id']}: required discriminator is not enforced")


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
        result = select_observation(observation_for(fixture))
        if result != fixture["expected"]:
            fail(f"{fixture['id']}: executable classifier output mismatch")
        require_mutation_rejection(fixture)

    profiles = [fixture["expected"]["profile"] for fixture in fixtures]
    fixtures_by_id = {fixture["id"]: fixture for fixture in fixtures}
    expected_pairs = {tuple(sorted(pair)) for pair in itertools.combinations(profiles, 2)}
    actual_pairs = set()
    matrix = document.get("overlap_matrix", {})
    for pair in matrix.get("pairs", []):
        pair_fixtures = [fixtures_by_id.get(value) for value in pair.get("fixture_ids", [])]
        if len(pair_fixtures) != 2 or any(value is None for value in pair_fixtures):
            fail("overlap fixture references unknown candidates")
        pair_profiles = tuple(sorted(value["expected"]["profile"] for value in pair_fixtures))
        actual_pairs.add(pair_profiles)
        merged = {}
        for fixture in pair_fixtures:
            merged[FIXTURE_SECTIONS[fixture["id"]]] = fixture["input"]
        for unit_text, expected in pair.get("expected_by_unit", {}).items():
            observation = {"unit": int(unit_text), **merged}
            result = select_observation(observation)
            if expected == "insufficient_evidence":
                if result != matrix.get("ambiguous_expected"):
                    fail(f"{pair_profiles}: ambiguity did not fail closed")
            elif result.get("profile") != expected or result.get("send") is not False:
                fail(f"{pair_profiles}: unit-exclusive selection drift")
    if actual_pairs != expected_pairs or len(matrix.get("pairs", [])) != len(expected_pairs):
        fail("overlap matrix is not complete and unique")


if __name__ == "__main__":
    main()
