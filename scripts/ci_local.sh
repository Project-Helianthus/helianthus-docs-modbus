#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

platform_toolchain_mode="${PLATFORM_TOOLCHAIN_MODE:-supported}"
platform_docs_ebus_repository="${PLATFORM_DOCS_EBUS_REPOSITORY:-Project-Helianthus/helianthus-docs-ebus}"
case "${platform_toolchain_mode}" in
  exact|supported) ;;
  *)
    echo "PLATFORM_TOOLCHAIN_MODE must be exact or supported." >&2
    exit 2
    ;;
esac

echo "==> verify pinned workflow/schema gate tools"
if ! command -v actionlint >/dev/null 2>&1; then
  echo "actionlint v1.7.7 is required: go install github.com/rhysd/actionlint/cmd/actionlint@v1.7.7" >&2
  exit 2
fi
actionlint_version="$(python3 scripts/check_workflow_shells.py actionlint-version)"
if [ "$(printf '%s\n' "$actionlint_version" | sed -n '1p')" != "v1.7.7" ]; then
  echo "actionlint must report v1.7.7." >&2
  exit 2
fi
if ! command -v jv >/dev/null 2>&1; then
  echo "jv v0.7.0 is required: go install github.com/santhosh-tekuri/jsonschema/cmd/jv@v0.7.0" >&2
  exit 2
fi
if [ "$(jv --version | sed -n '1p')" != "github.com/santhosh-tekuri/jsonschema/cmd/jv v0.7.0" ]; then
  echo "jv must report v0.7.0." >&2
  exit 2
fi
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "ShellCheck is required for the separate workflow run-step check." >&2
  exit 2
fi
gate_temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/docs-ebus-ci.XXXXXXXX")"
cleanup_workflow_lint() {
  local status=$?
  rm -rf -- "$gate_temp_dir" || :
  return "$status"
}
install_workflow_cleanup_trap() {
  local signal="$1" handler="$2" previous
  previous="$(trap -p "$signal")"
  if [ -n "$previous" ]; then
    # Decode Bash's quoted trap declaration without changing the caller's arguments.
    eval "set -- ${previous#trap -- }"
    previous="$1"
  else
    previous=:
  fi
  if [ "$signal" = EXIT ]; then
    # Both branches preserve the incoming status for the previous handler.
    printf -v handler 'if cleanup_workflow_lint; then\n%s\nelse\n%s\nfi' "$previous" "$previous"
  else
    printf -v handler '%s\n%s' "$previous" "$handler"
  fi
  # Quote the composed handler as data before installing it.
  printf -v handler 'trap -- %q %q' "$handler" "$signal"
  eval "$handler"
}
install_workflow_cleanup_trap EXIT ''
install_workflow_cleanup_trap INT 'exit 130'
install_workflow_cleanup_trap TERM 'exit 143'
echo "Workflow lint artifacts: ${gate_temp_dir} (removed on exit)"
workflow_lint_status=0
echo "==> actionlint (60-second limit; embedded ShellCheck disabled)"
python3 scripts/check_workflow_shells.py actionlint || workflow_lint_status=$?
echo "==> separate ShellCheck (60-second pass limit; all severities)"
python3 scripts/check_workflow_shells.py shellcheck --temp-dir "$gate_temp_dir" || {
  workflow_lint_status=$?
  # Preserve numbered source while the extracted files still exist. The pass
  # returns one status, so include every extracted script for diagnostic context.
  for workflow_script in "$gate_temp_dir"/*.bash "$gate_temp_dir"/*.sh; do
    [ -f "$workflow_script" ] || continue
    printf '\nExtracted workflow source: %s\n' "$workflow_script" >&2
    nl -ba "$workflow_script" >&2 || :
  done
}
if [ "$workflow_lint_status" -ne 0 ]; then
  exit "$workflow_lint_status"
fi
python3 -m pytest -q tests/test_workflow_shells.py
python3 -m pytest -q tests/test_workflow_lint_cleanup.py
echo "Pinned workflow/schema gate tools passed."

# A same-repository pull request may list heavy suites whose inputs did not
# change (CI_UNCHANGED_SUITES, computed by the trusted base copy of
# scripts/ci_suite_inputs.py from scripts/ci_suite_inputs.json). Only the
# listed suites' pytest modules are skipped; their cheap validators still run.
# Main pushes, the nightly run, manual dispatches, fork pull requests and local
# runs leave the variable empty and run every suite.
ci_suite_unchanged() {
  case " ${CI_UNCHANGED_SUITES:-} " in
    *" $1 "*)
      echo "Skipping the $1 suite: none of its inputs changed in this pull request (main pushes and the nightly run still run it)."
      return 0
      ;;
  esac
  return 1
}

echo "==> python readability ratchet"
python3 scripts/check_readability.py --self-test
python3 scripts/check_readability.py --check
python3 -m pytest -q tests/test_readability_gate.py

echo "==> verify markdown files are present"
count="$(git ls-files '*.md' | wc -l | tr -d ' ')"
if [ "${count}" -eq 0 ]; then
  echo "No markdown files found."
  exit 1
fi
echo "Found ${count} markdown files."

echo "==> check markdown for tabs and trailing spaces"
failed=0
if git grep -nI $'\t' -- '*.md'; then
  echo "Tab characters are not allowed in markdown files."
  failed=1
fi
if git grep -nI -E ' +$' -- '*.md'; then
  echo "Trailing spaces are not allowed in markdown files."
  failed=1
fi
if [ "${failed}" -ne 0 ]; then
  exit 1
fi

echo "==> enforce initiator/target terminology"
python3 - <<'PY'
from __future__ import annotations

import pathlib
import re
import subprocess
import sys

begin_marker = "<!-- legacy-role-mapping:begin -->"
end_marker = "<!-- legacy-role-mapping:end -->"

# Construct legacy terms without spelling them out literally in-repo.
terms = ["m" + "aster", "sl" + "ave"]
pattern = re.compile(r"\b(" + "|".join(map(re.escape, terms)) + r")\b", re.IGNORECASE)

md_files = subprocess.check_output(["git", "ls-files", "*.md"], text=True).splitlines()

def line_number(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1

def print_match(file_path: str, text: str, index: int, match_text: str) -> None:
    print(f"{file_path}:{line_number(text, index)}:{match_text}", file=sys.stderr)

failed = False

for file_path in md_files:
    path = pathlib.Path(file_path)
    text = path.read_text(encoding="utf-8")

    # Build allowed regions from legacy-role-mapping markers in this file.
    allowed_ranges: list[tuple[int, int]] = []
    search_start = 0
    while True:
        b = text.find(begin_marker, search_start)
        if b == -1:
            break
        e = text.find(end_marker, b)
        if e == -1:
            break
        allowed_ranges.append((b, e + len(end_marker)))
        search_start = e + len(end_marker)

    for match in pattern.finditer(text):
        in_allowed = any(s <= match.start() < e for s, e in allowed_ranges)
        if not in_allowed:
            if not failed:
                print(
                    "Legacy role terms found outside legacy-role-mapping regions.",
                    file=sys.stderr,
                )
            failed = True
            print_match(file_path, text, match.start(), match.group(0))

if failed:
    sys.exit(1)

print("Terminology gate passed.")
PY

# Checks that stay with their owners and are not invoked from this checkout:
# eBUS naming decomposition and the source-address check stay in
# helianthus-docs-ebus (NN05). The naming-surface suite stays in
# helianthus-docs (NN03). Platform suites and the combined-ref caller stay
# in helianthus-docs and helianthus-docs-eebus (NN03 and NN15). M6.25 tests
# stay in helianthus-docs-eebus (NN15). The Modbus Trusted Revision workflow
# and its contract stay in helianthus-docs-ebus. The companion check below
# runs in that checkout.

echo "==> private network address gate (docs must use placeholders)"
if [ -z "${HELIANTHUS_DOCS_ROOT:-}" ] || [ ! -f "${HELIANTHUS_DOCS_ROOT}/scripts/validate_platform_contracts.py" ]; then
  echo "HELIANTHUS_DOCS_ROOT must name the helianthus-docs checkout that provides scripts/validate_platform_contracts.py." >&2
  exit 2
fi
# Hosted Docs Checks check out this same merged NN03 revision and this script records it.
nn03_revision="ff8fccc7d5fbcbfe1e156fce302549d04a2f6228"
actual_nn03="$(git -C "${HELIANTHUS_DOCS_ROOT}" rev-parse HEAD)"
echo "NN03 platform revision ${actual_nn03}"
if [ "${actual_nn03}" != "${nn03_revision}" ]; then
  echo "HELIANTHUS_DOCS_ROOT is ${actual_nn03}; the exact merged NN03 revision is ${nn03_revision}." >&2
  exit 2
fi
PYTHONPATH="${HELIANTHUS_DOCS_ROOT}/scripts${PYTHONPATH:+:$PYTHONPATH}" python3 - <<'PY'
from __future__ import annotations

import pathlib
import subprocess
import sys

from validate_platform_contracts import _private_network_literals

md_files = subprocess.check_output(["git", "ls-files", "*.md"], text=True).splitlines()
failed = False

for file_path in md_files:
    text = pathlib.Path(file_path).read_text(encoding="utf-8")
    for _, offset in _private_network_literals(text):
        line = text.count("\n", 0, offset) + 1
        print(f"{file_path}:{line}: private network address found (redact and use a placeholder)", file=sys.stderr)
        failed = True

if failed:
    sys.exit(1)
print("Private network gate passed.")
PY

echo "==> check CC0 and AGPL documentation boundary"
python3 scripts/check_public_domain_boundary.py
python3 -m pytest -q -p no:cacheprovider tests/test_public_domain_boundary.py

echo "==> check semantic term qualifiers"
python3 scripts/check_semantic_term_qualifiers.py
python3 -m pytest -q -p no:cacheprovider tests/test_semantic_term_qualifiers.py

echo "==> check naming contract"
python3 -B scripts/check_naming_contract.py
python3 -B -m unittest discover -s tests -p test_naming_contract.py

echo "==> check documentation pages"
./scripts/check_docs.sh
./scripts/check_docs_test.sh

echo "==> check heavy-suite input classifier"
python3 -m pytest -q -p no:cacheprovider tests/test_ci_suite_inputs.py

echo "==> check opaque runtime acquisition companion contract"
# The opaque suite reads the helianthus-docs platform index. This receiver
# stores no prior platform selection. A missing or changed selection runs
# the suite; a recorded unchanged selection honors the ordinary skip.
platform_forces_opaque=0
if [ -z "${NN03_PRIOR_SELECTION:-}" ] || [ -z "${NN03_SELECTION:-}" ] || [ "${NN03_PRIOR_SELECTION}" != "${NN03_SELECTION}" ]; then
  platform_forces_opaque=1
fi
ci_unchanged_saved="${CI_UNCHANGED_SUITES-}"
if [ "$platform_forces_opaque" -eq 1 ]; then
  CI_UNCHANGED_SUITES=""
fi
if ! ci_suite_unchanged opaque_runtime_acquisition; then
  python3 -m pytest -q -p no:cacheprovider tests/test_opaque_runtime_acquisition_contract.py
fi
if [ "$platform_forces_opaque" -eq 1 ]; then
  if [ -n "${ci_unchanged_saved}" ]; then
    CI_UNCHANGED_SUITES="${ci_unchanged_saved}"
  else
    unset CI_UNCHANGED_SUITES
  fi
fi
if [ -z "${HELIANTHUS_DOCS_ROOT:-}" ] || [ ! -d "${HELIANTHUS_DOCS_ROOT}" ]; then
  echo "HELIANTHUS_DOCS_ROOT must be the helianthus-docs checkout." >&2
  exit 2
fi
if [ -z "${HELIANTHUS_DOCS_EBUS_ROOT:-}" ] || [ ! -d "${HELIANTHUS_DOCS_EBUS_ROOT}" ]; then
  echo "HELIANTHUS_DOCS_EBUS_ROOT must be the helianthus-docs-ebus checkout." >&2
  exit 2
fi
source_pin="$(git -C "${HELIANTHUS_DOCS_EBUS_ROOT}" rev-parse HEAD)"
opaque_args=(
  --root .
  --platform-root "${HELIANTHUS_DOCS_ROOT}"
  --source-pin "${source_pin}"
)
if [ -n "${MODBUS_PRIOR_ROOT:-}" ]; then
  opaque_args+=(--prior-root "${MODBUS_PRIOR_ROOT}")
fi
python3 scripts/validate_opaque_runtime_acquisition.py "${opaque_args[@]}"

echo "==> retained Modbus companion contract in helianthus-docs-ebus"
if [ -z "${DOCS_EBUS_ROOT:-}" ] || [ -z "${DOCS_EBUS_PRIOR_ROOT:-}" ]; then
  echo "DOCS_EBUS_ROOT and DOCS_EBUS_PRIOR_ROOT are required for the retained Modbus companion check." >&2
  exit 2
fi
if [ ! -d "${DOCS_EBUS_ROOT}" ] || [ ! -d "${DOCS_EBUS_PRIOR_ROOT}" ]; then
  echo "DOCS_EBUS_ROOT and DOCS_EBUS_PRIOR_ROOT must be directories." >&2
  exit 2
fi
docs_ebus_root_real="$(cd "${DOCS_EBUS_ROOT}" && pwd -P)"
docs_ebus_prior_real="$(cd "${DOCS_EBUS_PRIOR_ROOT}" && pwd -P)"
if [ "${docs_ebus_root_real}" = "${docs_ebus_prior_real}" ]; then
  echo "DOCS_EBUS_PRIOR_ROOT must differ from DOCS_EBUS_ROOT." >&2
  exit 2
fi
(
  cd "${DOCS_EBUS_ROOT}"
  python3 -m pytest -q -p no:cacheprovider tests/test_modbus_companion_contract.py tests/test_modbus_trusted_revision.py
  python3 scripts/validate_modbus_companion.py --root . --prior-root "${docs_ebus_prior_real}"
)

echo "==> run every other tests/test_*.py file (automatic discovery)"
# New test files need no line in this script. A file whose basename appears
# anywhere in this script keeps its dedicated invocation and is skipped here;
# every other file runs in its own interpreter, as the dedicated lines do.
# Read this script through its resolved path: BASH_SOURCE stays relative to the
# caller's directory, and the header already changed into the repository root.
gate_named_tests="$({ grep -oE '(^|[^A-Za-z0-9_])test_[A-Za-z0-9_]+\.py' "${repo_root}/scripts/ci_local.sh" \
  || [ "$?" -eq 1 ]; } | sed -E 's/^[^A-Za-z0-9_]//' | sort -u)"
for gate_test_file in tests/test_*.py; do
  [ -f "$gate_test_file" ] || continue
  gate_test_name="${gate_test_file#tests/}"
  case $'\n'"${gate_named_tests}"$'\n' in
    *$'\n'"${gate_test_name}"$'\n'*) continue ;;
  esac
  echo "--> ${gate_test_file}"
  gate_test_status=0
  python3 -m pytest -q -p no:cacheprovider "$gate_test_file" || gate_test_status=$?
  if [ "$gate_test_status" -eq 5 ]; then
    # pytest collected nothing: run load_tests-protocol files through unittest,
    # like the dedicated unittest steps. Do not rely on unittest's own exit
    # status for an empty run: require a nonzero test count, so an empty or
    # misnamed suite fails here instead of passing silently.
    gate_unittest_log="$(mktemp "${gate_temp_dir}/unittest.XXXXXXXX")"
    python3 -m unittest discover -s tests -p "$gate_test_name" -v 2>&1 | tee "$gate_unittest_log"
    if ! grep -qE '^Ran [1-9][0-9]* tests? in ' "$gate_unittest_log"; then
      echo "${gate_test_file}: neither pytest nor unittest collected any test (empty or misnamed suite)." >&2
      exit 5
    fi
  elif [ "$gate_test_status" -ne 0 ]; then
    exit "$gate_test_status"
  fi
done
