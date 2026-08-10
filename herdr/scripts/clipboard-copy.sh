#!/usr/bin/env bash
# herdr/tmux 共通のクリップボード書き込みヘルパー。
# OS 名だけでコマンドを固定すると、Ubuntu の Wayland/X11 や
# MSYS2 の実行環境差を吸収できないため、実行時に利用可能なコマンドを選ぶ。
set -euo pipefail

open_requested=false
case "${1:-}" in
  "") ;;
  --open) open_requested=true ;;
  *)
    echo "使い方: $0 [--open]" >&2
    exit 2
    ;;
esac

os_name="$(uname -s 2>/dev/null || true)"
is_wsl=false
if [ "$os_name" = "Linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
  is_wsl=true
fi

clipboard=()
case "$os_name" in
  Darwin*)
    if command -v pbcopy >/dev/null 2>&1; then
      clipboard=(pbcopy)
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    if command -v clip >/dev/null 2>&1; then
      clipboard=(clip)
    elif command -v clip.exe >/dev/null 2>&1; then
      clipboard=(clip.exe)
    fi
    ;;
  Linux*)
    if [ "$is_wsl" = true ] && command -v clip >/dev/null 2>&1; then
      clipboard=(clip)
    elif [ "$is_wsl" = true ] && command -v clip.exe >/dev/null 2>&1; then
      clipboard=(clip.exe)
    elif command -v wl-copy >/dev/null 2>&1; then
      clipboard=(wl-copy)
    elif command -v xclip >/dev/null 2>&1; then
      clipboard=(xclip -selection clipboard)
    elif command -v xsel >/dev/null 2>&1; then
      clipboard=(xsel --clipboard --input)
    fi
    ;;
esac

# 想定外の uname や、WSL 判定情報が取れない環境でも利用できるようにする。
if [ "${#clipboard[@]}" -eq 0 ]; then
  if command -v pbcopy >/dev/null 2>&1; then
    clipboard=(pbcopy)
  elif command -v clip >/dev/null 2>&1; then
    clipboard=(clip)
  elif command -v clip.exe >/dev/null 2>&1; then
    clipboard=(clip.exe)
  elif command -v wl-copy >/dev/null 2>&1; then
    clipboard=(wl-copy)
  elif command -v xclip >/dev/null 2>&1; then
    clipboard=(xclip -selection clipboard)
  elif command -v xsel >/dev/null 2>&1; then
    clipboard=(xsel --clipboard --input)
  fi
fi

if [ "${#clipboard[@]}" -eq 0 ]; then
  echo "クリップボードコマンドが見つかりません (pbcopy/clip/clip.exe/wl-copy/xclip/xsel)" >&2
  exit 1
fi

opener=()
case "$os_name" in
  Darwin*)
    command -v open >/dev/null 2>&1 && opener=(open)
    ;;
  MINGW*|MSYS*|CYGWIN*)
    command -v explorer.exe >/dev/null 2>&1 && opener=(explorer.exe)
    ;;
  Linux*)
    if [ "$is_wsl" = true ]; then
      if command -v explorer.exe >/dev/null 2>&1; then
        opener=(explorer.exe)
      elif command -v xdg-open >/dev/null 2>&1; then
        opener=(xdg-open)
      fi
    elif command -v xdg-open >/dev/null 2>&1; then
      opener=(xdg-open)
    fi
    ;;
esac

if [ "$open_requested" = true ]; then
  text="$(cat)"
  [ -n "$text" ] || exit 0
  printf '%s' "$text" | "${clipboard[@]}"

  if [ "${#opener[@]}" -gt 0 ]; then
    "${opener[@]}" "$text" >/dev/null 2>&1 &
  fi
else
  exec "${clipboard[@]}"
fi
