#!/bin/sh
# Claude Code statusLine command
# Shows: cwd (~/shortened) | git branch [status] | model | ctx used%

input=$(cat)

# --- directory (basename only) ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""' | sed 's|\\|/|g')
cwd=$(basename "$cwd")
# Show ~ when at $HOME
[ "$cwd" = "$(basename "$HOME")" ] && cwd="~"

# --- git info (--no-optional-locks to avoid stalling) ---
git_branch=""
git_indicators=""
git_dir=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // "."')
git_dir=$(echo "$git_dir" | sed 's|\\|/|g')
if git -C "$git_dir" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$git_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
                || git -C "$git_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  ind=""
  # Untracked files
  if git -C "$git_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | grep -q .; then
    ind="${ind}?"
  fi
  # Unstaged modifications
  if ! git -C "$git_dir" --no-optional-locks diff --quiet 2>/dev/null; then
    ind="${ind}*"
  fi
  # Staged changes
  if ! git -C "$git_dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
    ind="${ind}+"
  fi
  # Ahead/behind upstream
  upstream=$(git -C "$git_dir" --no-optional-locks rev-parse --abbrev-ref '@{u}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$git_dir" --no-optional-locks rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)
    behind=$(git -C "$git_dir" --no-optional-locks rev-list --count "HEAD..@{u}" 2>/dev/null || echo 0)
    [ "$ahead" -gt 0 ] && ind="${ind}^"
    [ "$behind" -gt 0 ] && ind="${ind}v"
  fi

  [ -n "$ind" ] && git_indicators=" [$ind]"
fi

# --- model ---
model=$(echo "$input" | jq -r '.model.display_name // ""')

# --- context: show used% (warn color if >= 70%) ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- assemble line ---
# dim white for directory
dir_part=$(printf '\033[2;37m%s\033[0m' "$cwd")

# dim green for git branch, yellow indicators if dirty
if [ -n "$git_branch" ]; then
  if [ -n "$git_indicators" ]; then
    git_part=$(printf '  \033[2;32m%s\033[2;33m%s\033[0m' "$git_branch" "$git_indicators")
  else
    git_part=$(printf '  \033[2;32m%s\033[0m' "$git_branch")
  fi
else
  git_part=""
fi

# dim cyan for model name
if [ -n "$model" ]; then
  model_part=$(printf '  \033[2;36m%s\033[0m' "$model")
else
  model_part=""
fi

# context usage: dim yellow normally, dim red if >= 80%
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    ctx_part=$(printf '  \033[2;31mctx:%d%%\033[0m' "$used_int")
  else
    ctx_part=$(printf '  \033[2;33mctx:%d%%\033[0m' "$used_int")
  fi
else
  ctx_part=""
fi

printf "%b%b%b%b" "$dir_part" "$git_part" "$model_part" "$ctx_part"
