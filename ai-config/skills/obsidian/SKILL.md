---
name: obsidian
description: Obsidian CLIを使ったVault操作（ノート作成・検索・タスク管理・デイリーノート・プロパティ操作等）
allowed-tools:
  # ノート操作
  - Bash(obsidian read:*)
  - Bash(obsidian create:*)
  - Bash(obsidian append:*)
  - Bash(obsidian prepend:*)
  - Bash(obsidian open:*)
  - Bash(obsidian move:*)
  - Bash(obsidian rename:*)
  # デイリーノート
  - Bash(obsidian daily:*)
  # 検索
  - Bash(obsidian search:*)
  # タスク
  - Bash(obsidian task:*)
  # プロパティ
  - Bash(obsidian propert:*)
  # タグ・リンク分析
  - Bash(obsidian tag:*)
  - Bash(obsidian link:*)
  - Bash(obsidian backlink:*)
  - Bash(obsidian orphan:*)
  - Bash(obsidian deadend:*)
  - Bash(obsidian unresolved:*)
  # ファイル・フォルダ情報
  - Bash(obsidian file:*)
  - Bash(obsidian folder:*)
  # テンプレート
  - Bash(obsidian template:*)
  # ブックマーク
  - Bash(obsidian bookmark:*)
  # コマンド実行
  - Bash(obsidian command:*)
  # プラグイン（情報取得・有効化・無効化）
  - Bash(obsidian plugin:*)
  # Base（データベース）
  - Bash(obsidian base:*)
  # バージョン・履歴
  - Bash(obsidian diff:*)
  - Bash(obsidian history:*)
  # 同期
  - Bash(obsidian sync:*)
  # その他情報取得
  - Bash(obsidian alias:*)
  - Bash(obsidian hotkey:*)
  - Bash(obsidian help:*)
  - Bash(obsidian vault:*)
  - Bash(obsidian version:*)
  - Bash(obsidian outline:*)
  - Bash(obsidian wordcount:*)
  - Bash(obsidian random:*)
  - Bash(obsidian recent:*)
  - Bash(obsidian tab:*)
  - Bash(obsidian workspace:*)
  - Bash(obsidian snippet:*)
  - Bash(obsidian theme:*)
---

# Obsidian CLI Professional

Obsidian CLI (`obsidian`) を使ってVaultを操作する。CLIはObsidianアプリと通信して動作するため、**Obsidianが起動中であること**が前提。

## 前提条件

- Obsidianアプリが起動中であること
- CLI: `/opt/homebrew/bin/obsidian`
- Vault名が1つの場合、`vault=` パラメータは省略可能

## 基本構文

```
obsidian <command> [options] [vault="Vault名"]
```

- `file=<name>`: ファイル名（wikilink的に名前解決される）
- `path=<path>`: 正確な相対パス（`folder/note.md`）
- 値にスペースを含む場合はクォート: `name="My Note"`
- `\n` で改行、`\t` でタブ
- 大半のコマンドは `file`/`path` 省略時にアクティブファイルを対象にする

## コマンドリファレンス

### ノート操作

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `read` | ファイル内容を読む | `file=`, `path=` |
| `create` | 新規ファイル作成 | `name=`, `path=`, `content=`, `template=`, `overwrite`, `open` |
| `append` | ファイル末尾に追記 | `file=`, `path=`, `content=`, `inline` |
| `prepend` | ファイル先頭に追記 | `file=`, `path=`, `content=`, `inline` |
| `open` | ファイルをObsidianで開く | `file=`, `path=`, `newtab` |
| `move` | ファイル移動 | `file=`, `path=`, `to=` |
| `rename` | ファイル名変更 | `file=`, `path=`, `name=` |
| `delete` | ファイル削除 | `file=`, `path=`, `permanent` |

### デイリーノート

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `daily` | デイリーノートを開く/作成 | `paneType=tab\|split\|window` |
| `daily:read` | デイリーノート内容を読む | - |
| `daily:append` | デイリーノート末尾に追記 | `content=`, `inline`, `open` |
| `daily:prepend` | デイリーノート先頭に追記 | `content=`, `inline`, `open` |
| `daily:path` | デイリーノートのパスを取得 | - |

### 検索

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `search` | Vault内テキスト検索 | `query=`, `path=`, `limit=`, `total`, `case`, `format=text\|json` |
| `search:context` | マッチ行のコンテキスト付き検索 | 同上 |
| `search:open` | Obsidianの検索ビューを開く | `query=` |

### タスク管理

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `tasks` | タスク一覧 | `file=`, `path=`, `done`, `todo`, `status=`, `verbose`, `daily`, `format=` |
| `task` | タスク表示・操作 | `ref=path:line`, `toggle`, `done`, `todo`, `status=`, `daily` |

### プロパティ（frontmatter）

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `properties` | プロパティ一覧 | `file=`, `name=`, `counts`, `sort=count`, `format=yaml\|json\|tsv` |
| `property:read` | プロパティ値を読む | `name=`, `file=`, `path=` |
| `property:set` | プロパティを設定 | `name=`, `value=`, `type=text\|list\|number\|checkbox\|date\|datetime`, `file=` |
| `property:remove` | プロパティを削除 | `name=`, `file=`, `path=` |

### タグ・リンク分析

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `tags` | タグ一覧 | `file=`, `counts`, `sort=count`, `format=` |
| `tag` | タグ情報 | `name=`, `total`, `verbose` |
| `links` | アウトゴーイングリンク | `file=`, `total` |
| `backlinks` | バックリンク | `file=`, `counts`, `total`, `format=` |
| `orphans` | 被リンクなしファイル | `total`, `all` |
| `deadends` | 発リンクなしファイル | `total`, `all` |
| `unresolved` | 未解決リンク | `total`, `counts`, `verbose`, `format=` |

### テンプレート

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `templates` | テンプレート一覧 | `total` |
| `template:read` | テンプレート内容を読む | `name=`, `resolve`, `title=` |
| `template:insert` | アクティブファイルにテンプレート挿入 | `name=` |

### ファイル・フォルダ情報

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `files` | ファイル一覧 | `folder=`, `ext=`, `total` |
| `file` | ファイル情報 | `file=`, `path=` |
| `folders` | フォルダ一覧 | `folder=`, `total` |
| `folder` | フォルダ情報 | `path=`, `info=files\|folders\|size` |

### ブックマーク

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `bookmark` | ブックマーク追加 | `file=`, `subpath=`, `folder=`, `search=`, `url=`, `title=` |
| `bookmarks` | ブックマーク一覧 | `total`, `verbose`, `format=` |

### コマンド実行

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `command` | 任意のObsidianコマンドを実行 | `id=` (必須) |
| `commands` | 利用可能なコマンドID一覧 | `filter=` |
| `hotkeys` | ホットキー一覧 | `total`, `verbose`, `format=`, `all` |

### プラグイン管理

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `plugins` | プラグイン一覧 | `filter=core\|community`, `versions`, `format=` |
| `plugins:enabled` | 有効なプラグイン一覧 | 同上 |
| `plugin` | プラグイン情報 | `id=` |
| `plugin:enable` | プラグイン有効化 | `id=` |
| `plugin:disable` | プラグイン無効化 | `id=` |
| `plugin:install` | プラグインインストール | `id=`, `enable` |
| `plugin:uninstall` | プラグイン削除 | `id=` |
| `plugin:reload` | プラグイン再読込（開発用） | `id=` |

### Base（データベース）

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `bases` | Base一覧 | - |
| `base:query` | Baseクエリ | `file=`, `view=`, `format=json\|csv\|tsv\|md\|paths` |
| `base:views` | Baseビュー一覧 | - |
| `base:create` | Baseアイテム作成 | `file=`, `view=`, `name=`, `content=`, `open` |

### バージョン・履歴

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `diff` | バージョン差分 | `file=`, `from=`, `to=`, `filter=local\|sync` |
| `history` | 履歴バージョン一覧 | `file=` |
| `history:list` | 履歴のあるファイル一覧 | - |
| `history:read` | 履歴バージョン読取 | `file=`, `version=` |
| `history:restore` | 履歴復元 | `file=`, `version=` |

### 同期

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `sync:status` | 同期ステータス | - |
| `sync:history` | 同期履歴 | `file=` |
| `sync:read` | 同期バージョン読取 | `file=`, `version=` |
| `sync:restore` | 同期バージョン復元 | `file=`, `version=` |
| `sync` | 同期の一時停止/再開 | `on`, `off` |

### その他

| コマンド | 説明 |
|---|---|
| `outline` | 見出し構造表示 (`format=tree\|md\|json`) |
| `wordcount` | 文字数・単語数カウント |
| `aliases` | エイリアス一覧 |
| `random` / `random:read` | ランダムノートを開く/読む |
| `recents` | 最近開いたファイル |
| `vault` / `vaults` | Vault情報 |
| `tabs` | 開いているタブ一覧 |
| `workspace` | ワークスペース構造 |
| `snippets` / `snippets:enabled` | CSSスニペット一覧 |
| `themes` / `theme` | テーマ一覧・情報 |
| `version` | Obsidianバージョン |

### 開発者向け

| コマンド | 説明 |
|---|---|
| `eval code=<js>` | JavaScript実行 |
| `dev:dom selector=<css>` | DOM要素クエリ |
| `dev:console` | コンソールメッセージ表示 |
| `dev:screenshot path=<file>` | スクリーンショット |
| `devtools` | DevTools切替 |

## よくあるワークフロー

### デイリーノートに追記

```bash
obsidian daily:append content="- 14:00 ミーティングメモ\n  - 議題1について合意"
```

### 未完了タスクの確認と完了

```bash
# 今日のデイリーノートの未完了タスク
obsidian tasks daily todo

# タスクを完了にする
obsidian task path="Daily/2026/03/2026-03-18.md" line=15 done
```

### テンプレートからノート作成

```bash
obsidian create name="新しいノート" template="DailyNoteTemplate" open
```

### Vault分析

```bash
# 孤立ノート（どこからもリンクされていない）
obsidian orphans

# 未解決リンク（リンク先が存在しない）
obsidian unresolved verbose

# タグ使用状況
obsidian tags counts sort=count
```

### プロパティ操作

```bash
# 読み取り
obsidian property:read name="tags" file="MyNote"

# 設定
obsidian property:set name="status" value="done" type=text file="MyNote"
```

### 検索してコンテキスト付きで表示

```bash
obsidian search:context query="アーキテクチャ" path="Private/Develop" limit=5
```

### コマンドIDを調べて実行

```bash
# コマンド一覧を絞り込み
obsidian commands filter="daily"

# コマンド実行
obsidian command id="daily-notes"
```

## 注意事項

- **破壊的操作（`delete`, `history:restore`, `sync:restore`, `plugin:uninstall`）は実行前にユーザーに確認すること**
- **`eval` は任意のJSを実行するため、必要な場合のみ使用すること**
- ファイル直接編集（Read/Edit/Write）よりCLIを優先する。CLIはObsidianのインデックス・リンク・メタデータ更新を正しく処理する
- 出力フォーマットは用途に応じて選択: パース→`json`、表示→`text`/`tree`、エクスポート→`csv`/`tsv`
- `obsidian help <command>` で個別コマンドの詳細ヘルプを確認できる
