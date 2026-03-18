---
name: gog
description: Google CLI (gog) を使ってGmail, Drive, Calendar, Tasks, Sheets等を操作する
allowed-tools: Bash(gog:*)
---

# gog - Google CLI Skill

Google非公式CLI `gog` (v0.12.0) を使い、ユーザーのGoogle Workspaceリソースを操作する。

## gog 概要

gog は Gmail / Calendar / Chat / Drive / Docs / Slides / Sheets / Tasks / Contacts / People / Forms / App Script をカバーするCLI。

### グローバルフラグ（常用）

| フラグ | 用途 |
|---|---|
| `-j, --json` | JSON出力（スクリプト向け） |
| `-p, --plain` | TSV出力（パース向け） |
| `--results-only` | JSON時にページネーション等を省略 |
| `--select=FIELDS` | JSONフィールド選択（ドットパス対応） |
| `-n, --dry-run` | 変更せず、実行予定を表示 |
| `-y, --force` | 確認スキップ |
| `--no-input` | プロンプトなし（CI向け） |
| `-a, --account=EMAIL` | アカウント指定 |

### トップレベルコマンド

| コマンド | エイリアス | 説明 |
|---|---|---|
| `gmail` | `mail, email` | Gmail操作 |
| `drive` | `drv` | Google Drive |
| `calendar` | `cal` | Google Calendar |
| `tasks` | `task` | Google Tasks |
| `sheets` | `sheet` | Google Sheets |
| `chat` | - | Google Chat |
| `docs` | `doc` | Google Docs |
| `slides` | `slide` | Google Slides |
| `contacts` | `contact` | Google Contacts |
| `people` | `person` | Google People |
| `forms` | `form` | Google Forms |
| `appscript` | `script` | Google Apps Script |
| `groups` | `group` | Google Groups |
| `keep` | - | Google Keep (Workspace only) |
| `auth` | - | 認証管理 |
| `config` | - | 設定管理 |

### ショートカット（エイリアス）

| コマンド | 実体 |
|---|---|
| `send` | `gmail send` |
| `ls` | `drive ls` |
| `search` | `drive search` |
| `download` / `dl` | `drive download` |
| `upload` / `up` | `drive upload` |
| `login` | `auth add` |
| `logout` | `auth remove` |
| `status` / `st` | `auth status` |
| `me` / `whoami` | `people me` |
| `open` | URLを生成（オフライン） |

## 主要コマンド詳細

### Gmail

```
gmail search <query>       # Gmail検索クエリでスレッド検索
gmail get <messageId>      # メッセージ取得
gmail send                 # メール送信 (--to, --subject, --body, --cc, --bcc, --attach)
gmail drafts list          # 下書き一覧
gmail labels list          # ラベル一覧
gmail archive <messageId>  # アーカイブ
gmail mark-read <id>       # 既読にする
gmail trash <id>           # ゴミ箱へ
gmail attachment <msgId> <attachId>  # 添付DL
```

### Drive

```
drive ls                   # ファイル一覧 (--parent=FOLDER_ID)
drive search <query>       # 全文検索
drive get <fileId>         # メタデータ取得
drive download <fileId>    # ダウンロード (--out=PATH)
drive upload <localPath>   # アップロード (--parent, --name)
drive mkdir <name>         # フォルダ作成
drive delete <fileId>      # ゴミ箱へ (--permanent で完全削除)
drive share <fileId>       # 共有 (--email, --role)
drive permissions <fileId> # 権限一覧
drive url <fileId>         # Web URL表示
```

### Calendar

```
calendar events [calId]    # イベント一覧 (--from, --to, --max)
calendar event <calId> <eventId>   # イベント詳細
calendar create <calId>    # 作成 (--summary, --start, --end, --description)
calendar update <calId> <eventId>  # 更新
calendar delete <calId> <eventId>  # 削除
calendar search <query>    # イベント検索
calendar freebusy          # 空き状況
calendar conflicts         # 競合検出
calendar calendars         # カレンダー一覧
```

### Tasks

```
tasks lists list           # タスクリスト一覧
tasks list <listId>        # タスク一覧
tasks add <listId>         # タスク追加 (--title, --notes, --due)
tasks done <listId> <id>   # 完了にする
tasks undo <listId> <id>   # 未完了に戻す
tasks delete <listId> <id> # 削除
```

### Sheets

```
sheets get <spreadsheetId> <range>     # 値を読み取り
sheets update <spreadsheetId> <range> [values]  # 値を更新
sheets append <spreadsheetId> <range> [values]  # 値を追加
sheets clear <spreadsheetId> <range>   # 値をクリア
sheets metadata <spreadsheetId>        # メタデータ
sheets create <title>                  # 新規作成
sheets export <spreadsheetId>          # エクスポート (--format=csv|xlsx|pdf)
```

### Chat

```
chat spaces list           # スペース一覧
chat messages list <space> # メッセージ一覧
chat messages send <space> # メッセージ送信 (--text)
chat dm send <userId>      # DM送信
```

## 実行ルール

### 基本方針

1. **読み取り操作はそのまま実行**する
2. **書き込み・変更操作は `--dry-run` で先にプレビュー**し、ユーザーに確認してから本実行する
3. **出力は `--json --no-input` を基本**とし、結果をパースして分かりやすく要約する
4. **不明なサブコマンドのフラグは `gog <command> <subcommand> --help` で都度確認**する

### 安全レベル分類

| レベル | 操作例 | 対応 |
|---|---|---|
| **安全** | search, list, get, events, freebusy, metadata | そのまま実行 |
| **注意** | send, upload, create, update, share, append | `--dry-run` でプレビュー → 確認後に本実行 |
| **危険** | delete, trash, clear, unshare | `--dry-run` でプレビュー → 明示的な確認後に本実行 |

### 終了コード

| コード | 意味 |
|---|---|
| 0 | 成功 |
| 1 | 一般エラー |
| 2 | 使い方エラー |
| 3 | 結果なし |
| 4 | 認証必要 |
| 5 | 見つからない |
| 6 | 権限不足 |
| 7 | レート制限 |
| 8 | リトライ可能エラー |

### 動的ヘルプ取得

スキーマが巨大（2.4MB）なため、全コマンドの詳細をここには記載しない。
特定コマンドのフラグや使い方が不明な場合は、以下で都度確認する：

```bash
gog <command> <subcommand> --help
gog schema <command>  # 機械可読なJSON仕様
```

## 応答フォーマット

- 取得結果は日本語で要約して提示する
- JSON出力をそのまま貼り付けず、必要な情報を抽出して見やすく整形する
- 大量の結果は件数を示し、主要なものだけを表示する
- エラー時は終了コードと原因を説明し、対処法を提案する
