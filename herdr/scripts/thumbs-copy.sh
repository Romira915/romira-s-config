#!/usr/bin/env bash
# ──────────────────────────────────────────────
# herdr thumbs-copy — tmux-thumbs 相当のヒントコピー
#
# herdr の [[keys.command]] (type="pane") から prefix+Space で起動する想定。
# フォーカス中ペインの可視テキストを読み取り、tmux-thumbs の `thumbs` バイナリで
# パス/URL/ハッシュ/IP 等にヒントを付けてキーボード選択し、クリップボードへコピーする。
#
# tmux 側の挙動対応:
#   通常ヒント        → コピー（@thumbs-command 相当）
#   大文字ヒント(upcase) → コピー + `open`（@thumbs-upcase-command 相当）
# ──────────────────────────────────────────────
set -uo pipefail

pane="${HERDR_ACTIVE_PANE_ID:-}"
if [ -z "$pane" ]; then
  echo "HERDR_ACTIVE_PANE_ID が未設定です" >&2
  sleep 1.5
  exit 1
fi

# herdr バイナリ（[[keys.command]] 経由なら HERDR_BIN_PATH が渡る）
herdr_bin="${HERDR_BIN_PATH:-herdr}"

# thumbs バイナリ: PATH 優先、無ければ tmux-thumbs プラグイン同梱物を使う
thumbs_bin="$(command -v thumbs 2>/dev/null || true)"
if [ -z "$thumbs_bin" ]; then
  thumbs_bin="$HOME/.tmux/plugins/tmux-thumbs/target/release/thumbs"
fi
if [ ! -x "$thumbs_bin" ]; then
  echo "thumbs バイナリが見つかりません: $thumbs_bin" >&2
  echo "tmux-thumbs を導入するか PATH に thumbs を通してください" >&2
  sleep 2.5
  exit 1
fi

# クリップボード書き込みと URL/パスのオープンは OS 共通ヘルパーに委譲する。
# このスクリプト側で OS ごとの分岐を持つと、tmux 側と対応がずれるため。
script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
clipboard_bin="$script_dir/clipboard-copy.sh"
if [ ! -x "$clipboard_bin" ]; then
  echo "クリップボードヘルパーが見つかりません: $clipboard_bin" >&2
  sleep 2
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# 可視テキストを thumbs に流し込み、選択結果を $tmp に書き出す。
#   -u : 同一マッチの重複ヒントを出さない
#   -c : ヒントを [] で囲んで視認性を上げる
#   -f '%U:%H' : "upcaseフラグ:本文" 形式（%U は必ず true/false なので先頭コロンで安全に分割できる）
# 未選択(Esc)で thumbs は exit 1 を返すので pipefail を || true で吸収する。
"$herdr_bin" pane read "$pane" --source visible --format text \
  | "$thumbs_bin" -u -c -f '%U:%H' --target "$tmp" || true

# 未選択なら何もしない
[ -s "$tmp" ] || exit 0

result="$(cat "$tmp")"
upcase="${result%%:*}"   # true / false
text="${result#*:}"      # 選択された本文（コロンを含んでも安全）

[ -n "$text" ] || exit 0

if [ "$upcase" = "true" ]; then
  # 大文字ヒントはコピーに加えて URL/パスを開く。
  printf '%s' "$text" | "$clipboard_bin" --open
else
  printf '%s' "$text" | "$clipboard_bin"
fi
