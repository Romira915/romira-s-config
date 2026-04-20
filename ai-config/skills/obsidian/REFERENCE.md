# Obsidian CLI コマンドリファレンス

`obsidian help <command>` で個別の詳細ヘルプが得られる。ここではスキル内で頻繁に参照する用途別に概要をまとめる。

## ノート操作

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

## デイリーノート

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `daily` | デイリーノートを開く/作成 | `paneType=tab\|split\|window` |
| `daily:read` | デイリーノート内容を読む | - |
| `daily:append` | デイリーノート末尾に追記 | `content=`, `inline`, `open` |
| `daily:prepend` | デイリーノート先頭に追記 | `content=`, `inline`, `open` |
| `daily:path` | デイリーノートのパスを取得 | - |

## 検索

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `search` | Vault内テキスト検索 | `query=`, `path=`, `limit=`, `total`, `case`, `format=text\|json` |
| `search:context` | マッチ行のコンテキスト付き検索 | 同上 |
| `search:open` | Obsidianの検索ビューを開く | `query=` |

## タスク管理

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `tasks` | タスク一覧 | `file=`, `path=`, `done`, `todo`, `status=`, `verbose`, `daily`, `format=` |
| `task` | タスク表示・操作 | `ref=path:line`, `toggle`, `done`, `todo`, `status=`, `daily` |

## プロパティ（frontmatter）

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `properties` | プロパティ一覧 | `file=`, `name=`, `counts`, `sort=count`, `format=yaml\|json\|tsv` |
| `property:read` | プロパティ値を読む | `name=`, `file=`, `path=` |
| `property:set` | プロパティを設定 | `name=`, `value=`, `type=text\|list\|number\|checkbox\|date\|datetime`, `file=` |
| `property:remove` | プロパティを削除 | `name=`, `file=`, `path=` |

## タグ・リンク分析

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `tags` | タグ一覧 | `file=`, `counts`, `sort=count`, `format=` |
| `tag` | タグ情報 | `name=`, `total`, `verbose` |
| `links` | アウトゴーイングリンク | `file=`, `total` |
| `backlinks` | バックリンク | `file=`, `counts`, `total`, `format=` |
| `orphans` | 被リンクなしファイル | `total`, `all` |
| `deadends` | 発リンクなしファイル | `total`, `all` |
| `unresolved` | 未解決リンク | `total`, `counts`, `verbose`, `format=` |

## テンプレート

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `templates` | テンプレート一覧 | `total` |
| `template:read` | テンプレート内容を読む | `name=`, `resolve`, `title=` |
| `template:insert` | アクティブファイルにテンプレート挿入 | `name=` |

## ファイル・フォルダ情報

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `files` | ファイル一覧 | `folder=`, `ext=`, `total` |
| `file` | ファイル情報 | `file=`, `path=` |
| `folders` | フォルダ一覧 | `folder=`, `total` |
| `folder` | フォルダ情報 | `path=`, `info=files\|folders\|size` |

## ブックマーク

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `bookmark` | ブックマーク追加 | `file=`, `subpath=`, `folder=`, `search=`, `url=`, `title=` |
| `bookmarks` | ブックマーク一覧 | `total`, `verbose`, `format=` |

## コマンド実行

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `command` | 任意のObsidianコマンドを実行 | `id=` (必須) |
| `commands` | 利用可能なコマンドID一覧 | `filter=` |
| `hotkeys` | ホットキー一覧 | `total`, `verbose`, `format=`, `all` |

## プラグイン管理

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

## Base（データベース）

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `bases` | Base一覧 | - |
| `base:query` | Baseクエリ | `file=`, `view=`, `format=json\|csv\|tsv\|md\|paths` |
| `base:views` | Baseビュー一覧 | - |
| `base:create` | Baseアイテム作成 | `file=`, `view=`, `name=`, `content=`, `open` |

## バージョン・履歴

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `diff` | バージョン差分 | `file=`, `from=`, `to=`, `filter=local\|sync` |
| `history` | 履歴バージョン一覧 | `file=` |
| `history:list` | 履歴のあるファイル一覧 | - |
| `history:read` | 履歴バージョン読取 | `file=`, `version=` |
| `history:restore` | 履歴復元 | `file=`, `version=` |

## 同期

| コマンド | 説明 | 主要パラメータ |
|---|---|---|
| `sync:status` | 同期ステータス | - |
| `sync:history` | 同期履歴 | `file=` |
| `sync:read` | 同期バージョン読取 | `file=`, `version=` |
| `sync:restore` | 同期バージョン復元 | `file=`, `version=` |
| `sync` | 同期の一時停止/再開 | `on`, `off` |

## その他

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

## 開発者向け

| コマンド | 説明 |
|---|---|
| `eval code=<js>` | JavaScript実行 |
| `dev:dom selector=<css>` | DOM要素クエリ |
| `dev:console` | コンソールメッセージ表示 |
| `dev:screenshot path=<file>` | スクリーンショット |
| `devtools` | DevTools切替 |

## RainLoop Webmail（mailcatcher）のスクロール用 JS

```javascript
// スクロールリセット
document.querySelectorAll('.content.g-scrollbox')[last]?.scrollTo(0, 0);
// 下にスクロール
document.querySelectorAll('.content.g-scrollbox')[last]?.scrollBy(0, 400);
```
