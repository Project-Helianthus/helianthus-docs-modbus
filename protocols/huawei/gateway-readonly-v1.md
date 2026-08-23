# Huawei Gateway Read-Only Candidates V1

## Scope

SmartLogger, S-Dongle, and EMMA are three independent Huawei native Modbus
families. They are not SunSpec profiles and do not fall back to one another.
This contract defines offline, read-only candidate decoding and fail-closed
admission. All three candidates are disabled for automatic runtime admission.

## Shared encoding

Documented register addresses are zero-based PDU offsets. Numeric register
values are big-endian and most-significant word first. Strings occupy exactly
`quantity * 2` bytes; retain the raw extent, require ASCII, and strip only
terminal NUL or space padding.

Serial numbers, ESNs, registration keys, writable aliases, credentials, and
write-only search controls are excluded from detection and public output.

## SmartLogger candidate

The candidate targets unit 0 and requires all of:

- FC03 offset 65521, quantity 1, a stable U16 device-list change counter;
- FC2B, MEI 0x0e, ReadDevId 0x03, object 0x87 inventory;
- a self entry whose model identifies SmartLogger; and
- a structured firmware tuple admitted inside one exact V300 branch.

SPC210 Issue 49 and SPC191 Issue 52 are parallel branches. They are not ordered
by document number. Unknown V/R/C/SPC combinations remain insufficient.
Writable device name 65524, ESN 40713, basic MEI alone, and optional offering
strings are not detectors.

The change counter must be equal before and after child enumeration.

## S-Dongle candidate

The candidate targets logical unit 100 and requires all of:

- basic MEI product identity for an admitted S-Dongle model;
- FC03 offset 30068, quantity 2, U32 protocol version;
- FC03 offsets 37410 through 37412 for type, completed search state, and stable
  change sequence; and
- FC03 offset 37429, quantity 1, for capacity reconciliation.

Admitted documentary branches are V100R001C00SPC100 or later for the V100
interface, V100R001C00SPC124 or later for A-05 TCP, V200R022C10 or later for
A-05/B-06, and the separate V200R025 SPC120 branch for A-05/B-03/B-06.
Protocol baseline D5.0 is an independent gate.

Readability of unit 100, search status alone, or a serial number is
insufficient. Extended child inventory remains offline-only until the exact TCP
unit target is qualified.

## EMMA candidate

The candidate targets unit 0 and requires all of:

- FC03 offset 30000, quantity 15, offering name;
- FC03 offset 30222, quantity 20, EMMA-family model;
- FC03 offset 30035, quantity 15, structured software version;
- basic MEI identity; and
- an extended-MEI self entry with device ID 0 and HEMS product type.

R024 is admitted only at V100R024C00SPC100 or later within R024. R025 is
admitted only at V100R025C00SPC102 or later within R025. Branches are never
compared numerically across R values. Serial register 30015, model-register
readability, a SmartHEMS prefix, or basic MEI alone is insufficient.

## Child inventory

SmartLogger and EMMA use:

```text
FC2B / MEI 0x0e / ReadDevId 0x03 / ObjectID 0x87
```

Object 0x87 is the declared U8 device count. Objects 0x88 through 0xff describe
children 1 through 120; continuation may wrap once from 0xff to 0x00. `More`,
`Next object ID`, and response object count drive pagination. Reject cursor
loops, duplicate objects, duplicate child addresses, count mismatch, malformed
attributes, a second wrap, or a changing inventory guard.

A child record may contain model, software version, interface protocol,
device/address, feature version, product type, and parent relation. ESN is
sensitive and omitted from public facts. Stable child identity uses the parent
profile, routing address, model/product type, and source revision; it never uses
ESN alone.

Total enumeration is bounded to 15 seconds. SmartLogger and EMMA permit at most
248 pages, 248 objects, and 65536 response bytes. The S-Dongle candidate permits
at most 121 pages, 121 objects, and 32768 response bytes. Limit exhaustion is
insufficient evidence, never partial success.

## Private function codes

Huawei-defined FC0x41 and the Huawei-specific use of FC0x17 are profile-scoped
operations. Their payloads may be validated and retained only by an already
selected Huawei candidate codec. They do not identify a Huawei family and do
not reserve either function code globally.

Both functions are default-denied and no-send in this read-only profile.
Offline fixtures may prove bounds, exception handling, and unknown payload
retention, but must not execute file transfer, configuration, search, control,
or other state-changing sub-functions.

## Collision and failure rules

If any two Huawei candidates match one endpoint/unit observation, the result is
`insufficient_evidence`. A Huawei candidate colliding with SunSpec/Fronius or
Growatt is also insufficient. Timeout, disconnect, unstable inventory, unknown
version, malformed strings, or a non-optional Modbus exception produces no
send and no partial profile.
