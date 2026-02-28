#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

python3 "${ROOT_DIR}/scripts/diff/run_graph_json_paired_diff.py" \
  --repo-root "${ROOT_DIR}" \
  "$@"

