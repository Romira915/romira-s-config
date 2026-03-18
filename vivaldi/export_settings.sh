#!/usr/bin/env bash
set -euo pipefail

# Vivaldiの設定（マウスジェスチャー・キーボードショートカット等）をOS別にエクスポートする
# Usage: ./export_settings.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$(uname -s)" in
    Darwin)
        PREFS_FILE="$HOME/Library/Application Support/Vivaldi/Default/Preferences"
        OS_NAME="mac"
        ;;
    Linux)
        PREFS_FILE="$HOME/.config/vivaldi/Default/Preferences"
        OS_NAME="linux"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        PREFS_FILE="$LOCALAPPDATA/Vivaldi/User Data/Default/Preferences"
        OS_NAME="windows"
        ;;
    *)
        echo "Error: Unsupported OS" >&2
        exit 1
        ;;
esac

OUTPUT_FILE="${SCRIPT_DIR}/vivaldi_actions_${OS_NAME}.json"

if [[ ! -f "$PREFS_FILE" ]]; then
    echo "Error: Vivaldi Preferences not found at: $PREFS_FILE" >&2
    exit 1
fi

python3 -c "
import json, sys

with open(sys.argv[1], 'r') as f:
    prefs = json.load(f)

vivaldi = prefs.get('vivaldi', {})

exported = {}

# マウスジェスチャー・ショートカットのマッピング (sync対象外)
if 'actions' in vivaldi:
    exported['actions'] = vivaldi['actions']

# マウスジェスチャー設定
if 'mouse_gestures' in vivaldi:
    exported['mouse_gestures'] = vivaldi['mouse_gestures']

# チェインコマンド
if 'chained_commands' in vivaldi:
    exported['chained_commands'] = vivaldi['chained_commands']

if not exported:
    print('Warning: No customized settings found (using defaults)', file=sys.stderr)
    sys.exit(0)

with open(sys.argv[2], 'w') as f:
    json.dump(exported, f, indent=2, ensure_ascii=False)

print(f'Exported to: {sys.argv[2]}')
for key, value in exported.items():
    if isinstance(value, list) and len(value) > 0 and isinstance(value[0], dict):
        print(f'  {key}: {len(value[0])} commands')
    elif isinstance(value, dict):
        print(f'  {key}: {len(value)} keys')
" "$PREFS_FILE" "$OUTPUT_FILE"
