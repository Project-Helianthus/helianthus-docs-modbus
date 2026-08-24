#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
fixture_root=$(mktemp -d)
trap 'rm -rf "$fixture_root"' EXIT

source_document="$repo_root/architecture/sdongle-qualification-disposition-v1.md"
fixture_document="$fixture_root/admission.md"

cp "$source_document" "$fixture_document"
"$repo_root/scripts/check_docs.sh" --check-sdongle-admission "$fixture_document"

for leak in \
  'gateway.example.internal:1502' \
  'a:1502' \
  'port 1502' \
  '0123456789abcdef0123456789abcdef01234567' \
  '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'; do
  cp "$source_document" "$fixture_document"
  printf '\n%s\n' "$leak" >> "$fixture_document"
  if "$repo_root/scripts/check_docs.sh" --check-sdongle-admission "$fixture_document"; then
    echo "admission leak was accepted: $leak" >&2
    exit 1
  fi
done
