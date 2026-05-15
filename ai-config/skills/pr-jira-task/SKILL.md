---
name: pr-jira-task
description: 個人の Jira (Read で個人情報ファイルから取得) に開発タスクを起票する。テンプレート規約 (本文カスタムフィールド, Why ベース背景, issue link 連結) に従う。新規チケット起票やまとめて子チケット作成の依頼に使う。
allowed-tools: ToolSearch, AskUserQuestion, Read, mcp__claude_ai_Atlassian_Rovo__createJiraIssue, mcp__claude_ai_Atlassian_Rovo__createIssueLink, mcp__claude_ai_Atlassian_Rovo__editJiraIssue, mcp__claude_ai_Atlassian_Rovo__getJiraIssue, mcp__claude_ai_Atlassian_Rovo__getIssueLinkTypes
argument-hint: [親エピック key] [summary] — 引数なしで起動して対話的に詰めても可
---

# pr-jira-task

個人の Jira インスタンスに **開発タスク** を起票する。Jira インスタンスのドメイン・projectKey・カスタムフィールド ID は個人情報のためスキル内に直書きせず、ランタイムで `~/.claude/personal.md` から読み込む。

## Instructions

### 0. 個人情報読み込み（必須・最初に実行）

`~/.claude/personal.md` を Read で読み、以下の値を取得する:

- `Jira cloudId`
- `Jira projectKey`
- `開発タスク issueTypeName`（および `issueTypeId`）
- `本文を入れるカスタムフィールド ID`（例: `customfield_XXXXX`、テナント固有）
- `Jira チケット URL プレフィックス`

`personal.md` の「スキル別デフォルト値」セクション → `pr-jira-task` 配下にこれらが集約されている。値が無い場合はユーザーに確認する（スキル内には直書きしない）。

### 1. 入力収集

引数または対話で以下を集める。不足は `AskUserQuestion` で詰める。

| 項目 | 必須 | 内容 |
|---|---|---|
| 親エピック key | ✅ | 例: `XXXX-NNNN` |
| summary | ✅ | チケットタイトル。1 行で「何のチケットか」がわかる粒度 |
| 概要 | ✅ | 1〜2 文で「何をするか」 |
| ゴール | ✅ | 箇条書き 2〜5 個の達成条件。STG/PROD など環境別の合格条件も含めて具体に |
| 背景 (Why) | ✅ | 「やる価値（ユーザー / プロダクトにとっての価値）」「やらないと何が起きるか」を 1〜2 段落。**事実羅列で済ませない** |
| 注意事項 | 任意 | スコープ外・既知の制約・運用注意 |
| 対象URL/スクショ | バグ修正時のみ | 変更対象のURL、画面の状態 |
| 関連チケット keys | 任意 | 配列。**Relates** で issue link を貼る |
| 外部参考リンク | 任意 | Slack / Confluence / Design Doc 等、**Jira UI からたどれないもののみ** |

### 2. 規約チェック（書く前に思い出す）

- **本文は customfield (personal.md の値) に ADF JSON で書く**。標準 `description` は空 ADF doc で潰す
- **参考リンクに Jira UI で見える情報を書かない**（親エピック、関連 PR、関連子チケット等は Jira UI 右ペインや development integration で自動表示される）→ 代わりに `createIssueLink` で連結
- **背景は Why ベース**（事実だけ列挙しない）
- **煽り強調マーカー禁止**（`【最重要】` `最大ポイント` `深刻化` 等）
- **編集者主張禁止**（根拠ない断定）
- 概要・ゴールは簡潔に、見て即わかる粒度

関連 memory:
- `feedback_jira_description_concise.md`
- `feedback_no_ai_emphasis_markers.md`
- `feedback_no_editorializing_in_writing.md`
- `reference_jira_dev_template_field.md`

### 3. ドラフト確認

集めた情報からチケット ドラフト（概要・ゴール・背景・注意事項）をユーザーに見せ、起票前に確認を取る。

### 4. 起票

`mcp__claude_ai_Atlassian_Rovo__createJiraIssue` を以下で呼ぶ（`<cloudId>` 等は personal.md から取得した値で置換）:

```
cloudId: <cloudId>
projectKey: <projectKey>
issueTypeName: <開発タスクの issueTypeName>
parent: <親エピック key>
summary: <summary>
contentFormat: "adf"
additional_fields:
  <本文カスタムフィールド ID>: <ADF JSON 本文>
  description: {"type":"doc","version":1,"content":[{"type":"paragraph"}]}
```

createJiraIssue の引数で `additional_fields` 内にカスタムフィールド と `description` を入れる（API 仕様）。

### 5. issue link 作成

関連チケットがあれば、各キーに対して `mcp__claude_ai_Atlassian_Rovo__createIssueLink` を順次呼ぶ:

```
cloudId: <cloudId>
type: "Relates"
inwardIssue: <起票したチケット key>
outwardIssue: <関連チケット key>
```

`Relates` は双方向。明確な作業順依存があれば `Blocks` も検討。リンク種別が不明なら `getIssueLinkTypes` で確認。

### 6. 報告

起票結果を簡潔に報告:

```
[<key>](<URL プレフィックス><key>) 起票完了
Relates: <関連 key リスト>
```

## ADF JSON 組み立て

ADF (Atlassian Document Format) の主要要素:

### Heading (h2)
```json
{"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "概要"}]}
```

### Paragraph
```json
{"type": "paragraph", "content": [{"type": "text", "text": "本文"}]}
```

### Bullet list
```json
{"type": "bulletList", "content": [
  {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "項目1"}]}]}
]}
```

### Inline code mark
```json
{"type": "text", "text": "code", "marks": [{"type": "code"}]}
```

### Link mark
```json
{"type": "text", "text": "リンクテキスト", "marks": [{"type": "link", "attrs": {"href": "https://..."}}]}
```

### 空の description（標準フィールド潰し用）
```json
{"type": "doc", "version": 1, "content": [{"type": "paragraph"}]}
```

## テンプレート構造（本文カスタムフィールドの中身）

```
[heading: 概要]
[paragraph: 1〜2 文]

[heading: ゴール]
[bulletList: 達成条件 2〜5 個]

[heading: 背景]
[paragraph: Why（価値）]
[paragraph: Why（やらないと何が起きるか）]

[heading: 注意事項]  ← 任意
[bulletList: スコープ外 / 制約]

[heading: 参考リンク]  ← 外部リンクがある場合のみ
[bulletList: Slack / Confluence / Design Doc]
```

`参考リンク` セクションを **Jira UI で見える情報（親エピック、子チケット、関連 PR）で埋めない**。それらは issue link または development integration に任せる。

## 既知のハマりどころ

- 本文カスタムフィールドは textarea schema だが、API は **ADF JSON 必須**（markdown 文字列を渡すとエラー: 「操作値は Atlassian ドキュメントである必要があります」）
- `description` 標準フィールドに本文を入れるとテンプレートフィールドが空になる。**必ず本文カスタムフィールドに書く**
- `createJiraIssue` 直引数の `description` を markdown で書いてしまっても、後で `editJiraIssue` で本文カスタムフィールドに移して `description` を空 ADF で潰せば直せる
- `parent` 指定で「リンクされた作業項目」として親エピックが自動表示される（description に書く必要なし）
