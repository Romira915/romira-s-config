---
name: release-calendar
description: service-releaseカレンダーにリリース予定を登録・追記する
allowed-tools: Bash(gog calendar:*), Bash(gog cal:*), Bash(gh pr view:*), mcp__claude_ai_Atlassian__getJiraIssue, AskUserQuestion
---

# release-calendar — service-release カレンダー登録スキル

service-release カレンダーにリリース予定イベントを登録する。

## 入力情報の収集

ユーザーから以下の情報を収集する。不足している場合は質問する。

1. **開始日時** — イベントの開始日時（例: `2026-04-07 14:00`）
2. **リポジトリ名** — 1つ以上（例: `example-service`, `example-api`）
3. **チケット情報** — 各チケットにつき以下の3点:
   - チケットタイトル
   - Jira URL
   - PR URL

ユーザーが引数やメッセージで情報を渡してきた場合はそこから抽出し、不足分のみ質問する。

### PR URLからの情報自動取得

PR URLが提供された場合、`gh pr view` でbodyを取得し、Jira URLを自動抽出する。

```bash
gh pr view <PR番号> --repo <owner>/<repo> --json title,body
```

- **リポジトリ名**: PR URLのリポジトリ部分から取得
- **Jira URL**: PRのbodyから `https://example.atlassian.net/browse/` で始まるURLを抽出
- **チケットタイトル**: 抽出したJira URLからJiraチケットのsummaryを取得して使用する（PRタイトルではなくJiraのタイトルを使うこと）

これにより、ユーザーはPR URLと日時だけで登録できる。

## イベントフォーマット

### タイトル

```
${repo1}, ${repo2}... リリース
```

リポジトリが1つの場合はカンマなし: `example-service リリース`

### 説明（description）

チケットごとに以下の形式で記載し、チケット間は `---` で区切る。
複数リポジトリの場合、リポジトリ間は `----------`（ハイフン10個）で区切る。

```
チケットキー: Jiraタイトル
Jira URL
PR URL
---
チケットキー2: Jiraタイトル2
Jira URL2
PR URL2
```

例: `TICKET-XXXX: magazine では 別ドメインでも iframe埋め込みを許可する`

末尾に余分な改行や区切り線を入れない。

### 時間

- 開始: ユーザー指定の日時
- 終了: 開始から **30分後**
- タイムゾーン: Asia/Tokyo

## 実行手順

### Step 1: カレンダーID取得

```bash
gog calendar calendars --json --no-input
```

結果から `service-release` カレンダーのIDを取得する。
見つからない場合はユーザーに報告して中断する。

### Step 2: 時間帯の競合チェック

指定された時間帯に既存イベントがないか確認する。

```bash
gog calendar events <calId> --from "<start_iso>" --to "<end_iso>" --json --no-input
```

#### 競合がない場合
→ Step 3 へ進む

#### 競合がある場合

既存イベントを確認し、以下のルールで判断する:

1. **同じリポジトリ名が含まれるイベントがある場合**
   → 「同じリポジトリのリリースが既にこの時間帯に登録されています」と警告し、続行するか確認する

2. **自分が作成したイベントの場合**（creatorが自分のメールアドレス）
   → 既存イベントの description の末尾に `---` 区切りで新しいチケット情報を追記する（Step 3b）
   → 既存の summary にないリポジトリ名があれば summary も更新する

3. **他の人が作成したイベントの場合**
   → 「この時間帯には既に別のリリースが登録されています: {イベント概要}」と表示し、追記してよいか確認する
   → 承認されたら Step 3b へ、拒否されたら別の時間を提案する

### Step 3a: 新規イベント作成

```bash
gog calendar create <calId> \
  --summary "<title>" \
  --from "<start_iso>" \
  --to "<end_iso>" \
  --description "<description>" \
  --dry-run --no-input
```

dry-run の結果をユーザーに見せて確認後、`--dry-run` を外して本実行する。

### Step 3b: 既存イベントへの追記

既存イベントの description を取得し、末尾に新しいチケット情報を追加する。
リポジトリが異なる場合は `----------` で区切る。

```bash
gog calendar update <calId> <eventId> \
  --summary "<updated_title>" \
  --description "<updated_description>" \
  --dry-run --no-input
```

dry-run の結果をユーザーに見せて確認後、本実行する。

### Step 4: 完了報告

登録・更新が完了したら、以下を報告する:
- イベントタイトル
- 日時（開始〜終了）
- 登録したチケット数

### Step 5: ゲスト招待

イベント作成・更新後、必ず `user@example.com` をゲストに招待する。
ユーザーが追加のゲストを希望した場合は、合わせて追加する。

```bash
gog calendar update <calId> <eventId> \
  --attendees "<email1>,<email2>" \
  --send-updates "all" \
  --dry-run --no-input
```

dry-run の結果をユーザーに見せて確認後、本実行する。

**注意**: `--add-attendee` フラグは動作しない（"no updates provided" エラーになる）。`--attendees` を使用すること。既存のゲストがいる場合は、既存のゲストも含めてカンマ区切りで全員指定する必要がある。

## 注意事項

- 日時の入力が曖昧な場合（「明日の午後」等）は具体的な日時を確認する
- `--json` の結果はそのまま貼り付けず、必要な情報だけ整形して提示する
- 書き込み操作は必ず `--dry-run` でプレビュー後に本実行する
- gog calendar の時間指定フラグは `--from`/`--to`（`--start`/`--end` は存在しない）
