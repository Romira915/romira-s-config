---
name: create-skill
description: 新しい Claude Code スキルを作成して `~/.claude/skills/` に登録する。新規スキル作成の依頼に使う。
allowed-tools: Bash(mkdir:*), Bash(ln:*), Bash(ls:*), Bash(grep:*)
---

# スキル作成スキル

ユーザーの要望に基づいて新しい Claude Code スキルを作成・登録する。

このリポジトリは **public** にホストされているので、SKILL.md には個人・所属が判別できる情報を一切書かない。固有値は `~/.claude/personal.md` に逃がし、スキル側は Read で読み込む設計にする。

## 手順

1. **ヒアリング**: 名前 / 用途 / 必要なツール / 参照する外部リソースを確認
2. **固有情報の切り出し**: スキル本文に出てくる値のうち、下記「直書き禁止」に該当するものを特定し、personal.md 参照方式に分離する（後述）
3. **SKILL.md 作成**: `~/.config/romira-s-config/ai-config/skills/<skill-name>/SKILL.md` に書き出す
4. **personal.md 追記文面の提示**: 固有値を出す場合、personal.md の `## スキル別デフォルト値` 配下に追加する文面をユーザーに提示（直接編集はせず、ユーザーに貼り付けてもらう）
5. **シンボリックリンク作成**: `ln -s ~/.config/romira-s-config/ai-config/skills/<skill-name> ~/.claude/skills/<skill-name>`
6. **登録確認**: `ls -la ~/.claude/skills/<skill-name>` でリンクの向き先を確認
7. **固有情報の最終チェック**: 後述の grep で残骸が無いことを確認

## 固有情報の扱い（必読）

### 直書き禁止のもの

| カテゴリ | 例 |
|---|---|
| 個人/同僚の識別子 | 氏名、メール、Slack ID、GitHub ハンドル |
| 所属の識別子 | 社名、サービス名、社内ドメイン、社内ツール URL |
| 外部サービスの固有 ID | BigQuery プロジェクト/データセット/テーブル名、Jira cloudId / projectKey / customfield ID / issueTypeId、Atlassian テナント名 |
| 内部リソース名 | 社内リポジトリ名、社内パス、内部 STG ドメイン、内部メールカチャ URL |

サンプル SQL・URL・チケット ID 例なども含めて、**固有値はすべて `<placeholder>` で抽象化**して書く。

### 既存スキルの参照パターン（参考）

新規スキルは以下のいずれかのパターンに揃える:

- `pr-jira-task/SKILL.md` の「個人情報読み込み（必須・最初に実行）」節 — Jira の cloudId / projectKey / customfield ID 等を personal.md から Read
- `fastly-bq/SKILL.md` の「テーブル情報」節 — BigQuery FQN を `<table_fqn>` プレースホルダで書き、ランタイムで personal.md から解決
- `stg-manual-test/SKILL.md` の「参照ファイル」節 — STG ドメイン・BaseMachina URL 等を personal.md から取得

### スキル本文での書き方サンプル

```markdown
## 設定値

以下は personal.md の `<skill-name>` セクションから Read で取得する:

- `<jira_project_key>`
- `<api_endpoint>`
- `<table_fqn>`
```

そして手順の最初に「`~/.claude/personal.md` を Read して上記値を取得」と明記する。

### personal.md 追記文面のテンプレート

ユーザーに提示する文面は以下の形:

````markdown
### <skill-name>
- key1: `<value1>`
- key2: `<value2>`
````

## SKILL.md フォーマット

```markdown
---
name: <skill-name>
description: <1行の説明>
allowed-tools: <許可するツール。コマンド単位で最小限に。例: Bash(git status:*), Bash(git push:*)>
---

# スキル名

## Instructions

手順をここに記述
```

## 完成後の固有情報チェック

コミット前に必ず実行:

```sh
grep -iE "<対象の固有語をパイプ区切りで列挙>" ai-config/skills/<skill-name>/*
```

何かヒットしたら personal.md に逃がして書き直してからコミットする。

## 注意事項

- スキルの実体は必ず `~/.config/romira-s-config/ai-config/skills/` に置く
- `~/.claude/skills/` には実体を置かず、シンボリックリンクのみ
- プロジェクトの `.claude/skills/` にはスキルを置かない（グローバル管理）
- **クロスプラットフォーム対応**: スキルは macOS / Linux / Windows で動作するように設計する
  - OS 固有のパス（`/opt/homebrew/bin/` 等）をハードコードしない
  - コマンドは PATH から解決される前提で記述する（例: `/opt/homebrew/bin/obsidian` ではなく `obsidian`）
  - OS 依存の処理が必要な場合はスキル内で分岐を明記する
- **allowed-tools は最小権限**: `Bash(git:*)` のようなワイルドカードを避け、`Bash(git status:*)` のようにコマンド単位で許可する
