#!/usr/bin/env bash
set -euo pipefail

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -eq 0 ]; then
  uv run "$SCRIPT_DIR/../translate_markdown_to_khmer.py" "$SCRIPT_DIR"
else
  uv run "$SCRIPT_DIR/../translate_markdown_to_khmer.py" "$@"
fi
