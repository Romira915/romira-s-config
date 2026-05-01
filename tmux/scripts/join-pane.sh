#!/usr/bin/env bash
set -euo pipefail

if command -v sk >/dev/null 2>&1; then
  finder=sk
else
  finder=fzf
fi

current="$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}')"

panes=$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} [#{window_name}] #{pane_current_command}' \
  | grep -Fv "${current} " || true)

[ -z "$panes" ] && exit 0

selected=$(printf '%s\n' "$panes" | "$finder" --reverse --header='join pane from') || exit 0
[ -z "$selected" ] && exit 0

target=$(printf '%s' "$selected" | awk '{print $1}')
tmux join-pane -h -s "$target"
