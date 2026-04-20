---
name: obsidian
description: Obsidian Vault を操作する（obsidian CLI）。ノート・タスク・デイリーノート・検索・プロパティ・タグの読み書きに使う。Obsidian アプリ起動中が前提。
allowed-tools:
  - Bash(obsidian:*)
---

# Obsidian CLI Professional

Obsidian CLI (`obsidian`) を使って Vault を操作する。CLI は Obsidian アプリと通信するため **Obsidian が起動中であること** が前提。

## 前提条件

- Obsidian アプリが起動中
- Vault が 1 つの場合、`vault=` パラメータは省略可能

## 基本構文

```
obsidian <command> [options] [vault="Vault名"]
```

- `file=<name>`: ファイル名（wikilink 的に名前解決される）
- `path=<path>`: 正確な相対パス（`folder/note.md`）
- 値にスペースを含む場合はクォート: `name="My Note"`
- `\n` で改行、`\t` でタブ
- 大半のコマンドは `file`/`path` 省略時にアクティブファイルを対象にする

## 情報の参照方法

- **コマンドリファレンス**: 同ディレクトリの `REFERENCE.md` を Read する（ノート操作・デイリー・検索・タスク・プロパティ・タグ・リンク分析・テンプレート・ブックマーク・コマンド実行・プラグイン・Base・履歴・同期・開発者向け などを網羅）
- **個別コマンドの詳細**: `obsidian help <command>` を叩く
- **機械可読な仕様**: `obsidian schema <command>` で JSON が得られる

## 実行方針

- **出力フォーマット**: パース用途は `format=json`、表示用途は `text`/`tree`、エクスポートは `csv`/`tsv`
- **ファイル直接編集 (Read/Edit/Write) より CLI を優先**: CLI は Obsidian のインデックス・リンク・メタデータ更新を正しく処理する
- **破壊的操作は実行前にユーザーへ確認**: `delete`, `history:restore`, `sync:restore`, `plugin:uninstall` など
- **`eval` は任意の JS を実行する**ため、必要な場合のみ使用

## 頻出ワークフロー

### デイリーノートに追記

```bash
obsidian daily:append content="- 14:00 ミーティングメモ\n  - 議題1について合意"
```

### 未完了タスクの確認・完了

```bash
obsidian tasks daily todo
obsidian task path="Daily/2026/03/2026-03-18.md" line=15 done
```

### テンプレートからノート作成

```bash
obsidian create name="新しいノート" template="DailyNoteTemplate" open
```

### Vault 分析

```bash
obsidian orphans                         # 孤立ノート
obsidian unresolved verbose              # 未解決リンク
obsidian tags counts sort=count          # タグ使用状況
```

### プロパティ操作

```bash
obsidian property:read name="tags" file="MyNote"
obsidian property:set name="status" value="done" type=text file="MyNote"
```

### 検索してコンテキスト付きで表示

```bash
obsidian search:context query="アーキテクチャ" path="Private/Develop" limit=5
```

### コマンドID 経由で任意の Obsidian コマンド実行

```bash
obsidian commands filter="daily"
obsidian command id="daily-notes"
```
