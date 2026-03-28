#!/usr/bin/env bash
set -euo pipefail

# VivaldiのOS別設定をインポートする
# Vivaldi を終了した状態で実行すること
# Usage: ./import_settings.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$(uname -s)" in
    Darwin)
        PREFS_FILE="$HOME/Library/Application Support/Vivaldi/Default/Preferences"
        VIVALDI_PROC="Vivaldi"
        OS_NAME="mac"
        ;;
    Linux)
        PREFS_FILE="$HOME/.config/vivaldi/Default/Preferences"
        VIVALDI_PROC="vivaldi"
        OS_NAME="linux"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        PREFS_FILE="$LOCALAPPDATA/Vivaldi/User Data/Default/Preferences"
        VIVALDI_PROC="vivaldi.exe"
        OS_NAME="windows"
        ;;
    *)
        echo "Error: Unsupported OS" >&2
        exit 1
        ;;
esac

INPUT_FILE="${SCRIPT_DIR}/vivaldi_actions_${OS_NAME}.json"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Settings file not found: $INPUT_FILE" >&2
    exit 1
fi

if [[ ! -f "$PREFS_FILE" ]]; then
    echo "Error: Vivaldi Preferences not found at: $PREFS_FILE" >&2
    exit 1
fi

# Vivaldiが起動中かチェック
is_vivaldi_running() {
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            tasklist //FI "IMAGENAME eq $VIVALDI_PROC" 2>/dev/null | grep -qi "$VIVALDI_PROC"
            ;;
        *)
            pgrep -x "$VIVALDI_PROC" > /dev/null 2>&1
            ;;
    esac
}

if is_vivaldi_running; then
    echo "Error: Vivaldi is running. Please quit Vivaldi before importing." >&2
    exit 1
fi

# バックアップ作成
BACKUP_FILE="${PREFS_FILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$PREFS_FILE" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

python3 -c "
import json, sys

with open(sys.argv[1], 'r') as f:
    prefs = json.load(f)

with open(sys.argv[2], 'r') as f:
    imported = json.load(f)

vivaldi = prefs.setdefault('vivaldi', {})

for key, value in imported.items():
    vivaldi[key] = value
    if isinstance(value, list) and len(value) > 0 and isinstance(value[0], dict):
        print(f'  Imported {key}: {len(value[0])} commands')
    elif isinstance(value, dict):
        print(f'  Imported {key}: {len(value)} keys')

with open(sys.argv[1], 'w') as f:
    json.dump(prefs, f, ensure_ascii=False, separators=(',', ':'))

print('Import complete.')
" "$PREFS_FILE" "$INPUT_FILE"
