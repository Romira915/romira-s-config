---
name: gog
description: Gmail / Drive / Calendar / Docs / Tasks / Sheets など Google Workspace を操作する（gog CLI）。Workspace リソースの読み取り・送信・更新の依頼に使う。
allowed-tools: Bash(gog:*)
---

# gog - Google CLI Skill

Google 非公式 CLI `gog` (v0.12.0) でユーザーの Google Workspace を操作する。

## グローバルフラグ（常用）

| フラグ | 用途 |
|---|---|
| `-j, --json` | JSON 出力（スクリプト向け） |
| `-p, --plain` | TSV 出力（パース向け） |
| `--results-only` | JSON 時にページネーション等を省略 |
| `--select=FIELDS` | JSON フィールド選択（ドットパス対応） |
| `-n, --dry-run` | 変更せず、実行予定を表示 |
| `-y, --force` | 確認スキップ |
| `--no-input` | プロンプトなし（CI 向け） |
| `-a, --account=EMAIL` | アカウント指定 |

## 情報の参照方法

- **トップレベル一覧・主要サブコマンド**: 同ディレクトリの `REFERENCE.md` を Read する
- **個別サブコマンドのフラグ・使い方**: `gog <command> <subcommand> --help` を都度実行する
- **機械可読仕様**: `gog schema <command>` で JSON が得られる

スキーマが巨大（2.4MB）なため全サブコマンドをスキル本体には書かない。不明なフラグが出たら都度 `--help` を叩く。

## 実行ルール

### 基本方針

1. **読み取り操作はそのまま実行**
2. **書き込み・変更操作は `--dry-run` で先にプレビュー**し、ユーザーに確認してから本実行
3. **出力は `--json --no-input` を基本**とし、結果をパースして要約
4. **不明なサブコマンドのフラグは `gog <command> <subcommand> --help` で都度確認**

### 安全レベル分類

| レベル | 操作例 | 対応 |
|---|---|---|
| **安全** | search, list, get, events, freebusy, metadata | そのまま実行 |
| **注意** | send, upload, create, update, share, append | `--dry-run` → 確認 → 本実行 |
| **危険** | delete, trash, clear, unshare | `--dry-run` → 明示的な確認 → 本実行 |

## 応答フォーマット

- 取得結果は日本語で要約
- JSON 出力をそのまま貼らず、必要な情報を抽出して整形
- 大量結果は件数を示し主要なものだけ表示
- エラー時は終了コードと原因を説明し、対処法を提案（終了コードの意味は `REFERENCE.md` を参照）
