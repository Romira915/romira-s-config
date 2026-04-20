# gog コマンドリファレンス

スキーマが巨大 (2.4MB) なため全サブコマンドは掲載しない。詳細は `gog <command> <subcommand> --help` か `gog schema <command>` を参照。

## トップレベルコマンド

| コマンド | エイリアス | 説明 |
|---|---|---|
| `gmail` | `mail, email` | Gmail 操作 |
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

## ショートカット

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

## 主要サブコマンド（スニペット）

### Gmail

```
gmail search <query>                 # スレッド検索
gmail get <messageId>                # メッセージ取得
gmail send --to --subject --body [--cc --bcc --attach]
gmail drafts list / labels list
gmail archive / mark-read / trash <id>
gmail attachment <msgId> <attachId>  # 添付DL
```

### Drive

```
drive ls [--parent=FOLDER_ID]
drive search <query>
drive get <fileId> / download <fileId> [--out=PATH]
drive upload <localPath> [--parent --name]
drive mkdir <name>
drive delete <fileId> [--permanent]
drive share <fileId> [--email --role]
drive permissions <fileId> / url <fileId>
```

### Calendar

```
calendar events [calId] [--from --to --max]
calendar event <calId> <eventId>
calendar create <calId> --summary --from --to --description
calendar update <calId> <eventId>
calendar delete <calId> <eventId>
calendar search <query>
calendar freebusy / conflicts / calendars
```

注: 時間指定フラグは `--from`/`--to`（`--start`/`--end` は存在しない）。

### Tasks

```
tasks lists list
tasks list <listId>
tasks add <listId> --title --notes --due
tasks done / undo / delete <listId> <id>
```

### Sheets

```
sheets get <spreadsheetId> <range>
sheets update / append / clear <spreadsheetId> <range> [values]
sheets metadata <spreadsheetId>
sheets create <title>
sheets export <spreadsheetId> [--format=csv|xlsx|pdf]
```

### Chat

```
chat spaces list
chat messages list <space>
chat messages send <space> --text
chat dm send <userId>
```

## 終了コード

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
