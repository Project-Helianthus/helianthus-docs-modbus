# helianthus-docs-modbus — local validation targets
#
# Usage:
#   make ci-local              # full local CI suite (ci_local.sh)

.PHONY: ci-local help

help:
	@echo "Available targets:"
	@echo "  ci-local            Run full local CI suite (scripts/ci_local.sh)"

ci-local:
	@bash scripts/ci_local.sh
