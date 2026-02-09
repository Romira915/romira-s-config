# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

個人の環境設定ファイル（dotfiles）を管理するリポジトリ。macOS、Linux(Ubuntu/WSL)、Windowsの各環境向けのセットアップスクリプトと設定ファイルを集約している。

## アーキテクチャ

### シンボリックリンク方式

設定ファイルはこのリポジトリ内に保持し、各OS向けのセットアップスクリプト（`Mac/mac_setup.sh`、`Ubuntu/ubuntu_setup.sh`）がホームディレクトリにシンボリックリンクを作成する。

主なリンク先:
- `git/.gitconfig` → `~/.gitconfig`
- `shell/.profile` → `~/.profile`
- `fish/config.fish` → `~/.config/fish/config.fish`
- `vim/.vimrc` → `~/.vimrc`
- `zsh/.zshrc` → `~/.zshrc`
- `tmux/.tmux.conf` → `~/.tmux.conf`

### シェル設定の階層構造

**POSIX系シェル (bash/zsh):**
- `shell/.profile` がエントリーポイント
- `shell/profile.d/` 配下のファイルを自動ソース（環境固有設定の分離、`.gitignore`でプライベートファイルを除外可能）
- `shell/system.profile.d/{darwin,linux,wsl}` でOS固有の設定を分岐

**Fish:**
- `fish/config.fish` がエントリーポイント（`bass source ~/.profile`でPOSIX設定を読み込み）
- `fish/config.d/*.fish` 配下のファイルを自動ソース
- `fish/system.config.d/wsl.fish` でWSL固有設定を分岐

### 環境セットアップの流れ

1. **Mac**: `Mac/mac_setup.sh` → シンボリックリンク作成 → zsh/fish設定 → Rust → Homebrew → Miniconda → Volta → TeX Live
2. **Ubuntu/WSL**: `Ubuntu/ubuntu_setup.sh` → apt基本パッケージ → 同様のツールチェーンインストール
3. **Windows**: `Windows10/` or `Windows11/` 配下のPowerShell/cmdスクリプト、`winget/`、`scoop/`、`chocolatey/` でパッケージ管理

### 主要ツールチェーン

Homebrewで管理されるCLIツール群（`homebrew/homebrew_setup.sh`）:
- Rust製ツール: zoxide, bat, ripgrep, fd, eza, git-delta, sk (skim), bottom, mcfly, sd, dust
- 開発ツール: ghq + sk でリポジトリ管理、gh (GitHub CLI)、starship (プロンプト)

## 設定追加時の注意

- POSIX互換の環境変数やエイリアスは `shell/.profile` または `shell/profile.d/` に追加（fishからも `bass` 経由で読み込まれる）
- fish固有の設定は `fish/config.d/` に `.fish` ファイルとして追加
- OS固有の設定は `shell/system.profile.d/` または `fish/system.config.d/` に追加
- プライベートな設定は `profile.d/.gitignore` / `config.d/.gitignore` でトラッキング除外可能
