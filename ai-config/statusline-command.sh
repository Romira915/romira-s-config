#!/bin/sh
# Claude Code statusLine command
# Inspired by starship config: directory + git branch/status + model

input=$(cat)

# --- directory ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
# Shorten home directory
cwd=$(echo "$cwd" | sed "s|^$HOME|~|")
# Truncate to last 5 path components with …/ prefix
depth=$(echo "$cwd" | tr -cd '/' | wc -c | tr -d ' ')
if [ "$depth" -gt 5 ]; then
  cwd="…/$(echo "$cwd" | rev | cut -d'/' -f1-5 | rev)"
fi

# --- git info (skip optional locks) ---
git_branch=""
git_status_str=""
if git -C "$(echo "$input" | jq -r '.cwd // .workspace.current_dir // "."')" \
       --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_dir=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // "."')
  git_branch=$(git -C "$git_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
                || git -C "$git_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  # Build status indicators
  indicators=""
  # Untracked
  if git -C "$git_dir" --no-optional-locks ls-files --others --exclude-standard --quiet 2>/dev/null | grep -q .; then
    indicators="${indicators}?"
  fi
  # Modified (unstaged)
  if ! git -C "$git_dir" --no-optional-locks diff --quiet 2>/dev/null; then
    indicators="${indicators}…"
  fi
  # Staged
  if ! git -C "$git_dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
    indicators="${indicators}+"
  fi
  # Ahead/behind
  upstream=$(git -C "$git_dir" --no-optional-locks rev-parse --abbrev-ref '@{u}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$git_dir" --no-optional-locks rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)
    behind=$(git -C "$git_dir" --no-optional-locks rev-list --count "HEAD..@{u}" 2>/dev/null || echo 0)
    [ "$ahead" -gt 0 ] && indicators="${indicators}⬆"
    [ "$behind" -gt 0 ] && indicators="${indicators}⬇"
  fi

  if [ -n "$indicators" ]; then
    git_status_str=" [$indicators]"
  fi
fi

# --- model ---
model=$(echo "$input" | jq -r '.model.display_name // ""')

# --- context usage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- assemble ---
# Format: [dir] [branch+status] model [ctx%]
dir_part=$(printf '\033[2;37m%s\033[0m' "$cwd")

if [ -n "$git_branch" ]; then
  git_part=$(printf ' \033[2;32m%s%s\033[0m' " $git_branch" "$git_status_str")
else
  git_part=""
fi

if [ -n "$model" ]; then
  model_part=$(printf ' \033[2;36m%s\033[0m' "$model")
else
  model_part=""
fi

if [ -n "$used_pct" ]; then
  ctx_part=$(printf ' \033[2;33mctx:%.0f%%\033[0m' "$used_pct")
else
  ctx_part=""
fi

printf "%b%b%b%b" "$dir_part" "$git_part" "$model_part" "$ctx_part"
