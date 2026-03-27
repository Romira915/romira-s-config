#!/usr/bin/env bash
set -euo pipefail

# macOS向け設定ファイルを一括エクスポートする
# Usage: ./export_all.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script is macOS only" >&2
    exit 1
fi

errors=0

echo "=== macOS defaults (AltTab, Rectangle, Raycast) ==="
"$SCRIPT_DIR/export_defaults.sh" || ((errors++))

echo ""
echo "=== Vivaldi ==="
"$REPO_DIR/vivaldi/export_settings.sh" || ((errors++))

echo ""
if [[ $errors -gt 0 ]]; then
    echo "Completed with $errors error(s)"
    exit 1
fi
echo "All exports completed"
