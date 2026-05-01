#!/usr/bin/env bash
set -euo pipefail

if command -v sk >/dev/null 2>&1; then
  finder=sk
else
  finder=fzf
fi

repo=$(ghq list | "$finder" --reverse --header='ghq → tmux session') || exit 0
[ -z "$repo" ] && exit 0

session=$(basename "$repo" | tr '.:' '__')
path="$(ghq root)/$repo"

if ! tmux has-session -t="$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -c "$path"
fi

tmux switch-client -t "$session"
