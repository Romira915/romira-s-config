#!/usr/bin/env bash
set -euo pipefail

# macOSアプリの設定(defaults)をdotfilesリポジトリにエクスポートする
# Ansible の macos_defaults.yml (defaults import) と対になるスクリプト
# Usage: ./export_defaults.sh [app_name...]
#   引数なし: 全アプリをエクスポート
#   引数あり: 指定アプリのみ (例: ./export_defaults.sh raycast alttab)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script is macOS only" >&2
    exit 1
fi

# name domain output_path
APP_DEFS=(
    "alttab|com.lwouis.alt-tab-macos|alttab/com.lwouis.alt-tab-macos.plist"
    "rectangle|com.knollsoft.Rectangle|rectangle/com.knollsoft.Rectangle.plist"
    "raycast|com.raycast.macos|raycast/com.raycast.macos.plist"
)

lookup_app() {
    local name="$1"
    for def in "${APP_DEFS[@]}"; do
        if [[ "${def%%|*}" == "$name" ]]; then
            echo "$def"
            return 0
        fi
    done
    return 1
}

all_names() {
    for def in "${APP_DEFS[@]}"; do
        echo -n "${def%%|*} "
    done
}

export_app() {
    local def="$1"
    local name="${def%%|*}"
    local rest="${def#*|}"
    local domain="${rest%%|*}"
    local output="${REPO_DIR}/${rest#*|}"

    if ! defaults read "$domain" &>/dev/null; then
        echo "  SKIP: $name ($domain not found)" >&2
        return 1
    fi

    defaults export "$domain" "$output"
    echo "  OK: $name -> ${rest#*|}"
}

# 対象アプリの決定
if [[ $# -gt 0 ]]; then
    targets=("$@")
else
    targets=()
    for def in "${APP_DEFS[@]}"; do
        targets+=("${def%%|*}")
    done
fi

echo "Exporting macOS defaults..."

errors=0
for target in "${targets[@]}"; do
    def="$(lookup_app "$target")" || {
        echo "  ERROR: Unknown app '$target' (available: $(all_names))" >&2
        ((errors++))
        continue
    }
    export_app "$def" || ((errors++))
done

if [[ $errors -gt 0 ]]; then
    echo "Done with $errors error(s)"
    exit 1
fi
echo "Done"
