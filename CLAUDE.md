# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

個人の環境設定ファイル（dotfiles）を管理するリポジトリ。macOS、Linux(Ubuntu/WSL)、Windowsの各環境向けのセットアップスクリプトと設定ファイルを集約している。

## アーキテクチャ

### シンボリックリンク方式

設定ファイルはこのリポジトリ内に保持し、Ansible (`romira-arcadia-ops/ansible/`) の `develop_macOS.yml` / `develop_ubuntu.yml` / `develop_windows.yml` がホームディレクトリにシンボリックリンクを作成する。

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

プロビジョニングは全 OS で Ansible (`romira-arcadia-ops/ansible/`) に集約済み。レガシーな setup スクリプト（`Mac/mac_setup.sh`、`Ubuntu/ubuntu_setup.sh`、`homebrew/homebrew_cask.sh` 等）は削除済み。

1. **Mac**: `ansible-playbook develop_macOS.yml`（Homebrew + Cask、シンボリックリンク、各種ツール）
2. **Ubuntu/WSL**: `ansible-playbook develop_ubuntu.yml`
3. **Windows**: `ansible-playbook develop_windows.yml`（Scoop、シンボリックリンク等）

このリポジトリ自体に残っている OS 固有のリソースは設定ファイルのみ:
- `macos/export_*.sh`: macOS の `defaults` コマンドエクスポート/復元スクリプト
- `Ubuntu/wsl.conf`: WSL 内 Ubuntu の `/etc/wsl.conf` ソース
- `wsl2/.wslconfig`: Windows ホスト側の WSL2 設定

### 主要ツールチェーン

Homebrewパッケージリストは Ansible (`romira-arcadia-ops/ansible/roles/brew/defaults/main.yml`) で一元管理。
- バージョンマネージャ: `mise`（旧 Volta から移行済み）
- Rust製ツール: zoxide, bat, ripgrep, fd, eza, git-delta, sk (skim), bottom, mcfly, sd, dust
- 開発ツール: ghq + sk でリポジトリ管理、gh (GitHub CLI)、starship (プロンプト)

## 設定追加時の注意

- POSIX互換の環境変数やエイリアスは `shell/.profile` または `shell/profile.d/` に追加（fishからも `bass` 経由で読み込まれる）
- fish固有の設定は `fish/config.d/` に `.fish` ファイルとして追加
- OS固有の設定は `shell/system.profile.d/` または `fish/system.config.d/` に追加
- プライベートな設定は `profile.d/.gitignore` / `config.d/.gitignore` でトラッキング除外可能
- **共有設定ファイルにOS固有の値を直接書かないこと。** `.gitconfig`、`.profile` 等はmacOS/Linux/WSL/Windowsで共有されている。OS固有の設定は `.local` ファイル（例: `~/.gitconfig.local`）や `system.profile.d/`、`system.config.d/` の環境分岐の仕組みを使う
