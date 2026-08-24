#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
fixture_root=$(mktemp -d)
trap 'rm -rf "$fixture_root"' EXIT

source_document="$repo_root/architecture/sdongle-qualification-disposition-v1.md"
fixture_document="$fixture_root/admission.md"
x2_document="$repo_root/protocols/growatt/shinewilan-x2-bridge-v1.md"
x2_fixture="$fixture_root/shinewilan-x2.md"

cp "$source_document" "$fixture_document"
"$repo_root/scripts/check_docs.sh" --check-sdongle-admission "$fixture_document"
grep -Fq 'Each retry began after at least five seconds of idle time.' "$source_document"

for leak in \
  'gateway.example.internal:1502' \
  'a:1502' \
  'gateway.internal:modbus' \
  'port 1502' \
  '192.0.2.1' \
  'TCP reachability was established' \
  '0123456789abcdef0123456789abcdef01234567' \
  '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'; do
  cp "$source_document" "$fixture_document"
  printf '\n%s\n' "$leak" >> "$fixture_document"
  if "$repo_root/scripts/check_docs.sh" --check-sdongle-admission "$fixture_document"; then
    echo "admission leak was accepted: $leak" >&2
    exit 1
  fi
done

cp "$x2_document" "$x2_fixture"
"$repo_root/scripts/check_docs.sh" --check-public-protocol "$x2_fixture"

for leak in \
  'https://example.invalid/vendor-manual' \
  '/Users/example/private-capture' \
  'sha256-deadbeef01234567'; do
  cp "$x2_document" "$x2_fixture"
  printf '\n%s\n' "$leak" >> "$x2_fixture"
  if "$repo_root/scripts/check_docs.sh" --check-public-protocol "$x2_fixture"; then
    echo "X2 protocol leak was accepted: $leak" >&2
    exit 1
  fi
done
