---
name: release-calendar
description: service-release カレンダーにリリース予定イベントを登録・追記する。PR のリリース日時を共有カレンダーに載せたいときに使う。
allowed-tools: Bash(gh pr view:*), Bash(gh search prs:*), mcp__claude_ai_Atlassian_Rovo__getJiraIssue, mcp__claude_ai_Atlassian_Rovo__searchJiraIssuesUsingJql, mcp__claude_ai_Google_Calendar__list_calendars, mcp__claude_ai_Google_Calendar__list_events, mcp__claude_ai_Google_Calendar__get_event, mcp__claude_ai_Google_Calendar__create_event, mcp__claude_ai_Google_Calendar__update_event, AskUserQuestion
---

# release-calendar — service-release カレンダー登録スキル

service-release カレンダーにリリース予定イベントを登録する。

## 参照ファイル

- **タイトル・説明・時間のフォーマット**: 同ディレクトリの `TEMPLATE.md` を Read する
- **ユーザー個人のデフォルト値**（招待メールアドレスなど）: `~/.claude/personal.md` の `release-calendar` セクションを Read する

## 入力情報の収集

ユーザーから以下を収集。不足は質問する。

1. **開始日時** — 例: `2026-04-07 14:00`
2. **リポジトリ名** — 1つ以上
3. **チケット情報** — 各チケットにつき以下の3点:
   - チケットタイトル
   - Jira URL
   - PR URL

ユーザーが引数やメッセージで情報を渡してきた場合はそこから抽出し、不足分のみ質問する。

### PR URL からの情報自動取得

PR URL が提供された場合、`gh pr view` で body を取得し Jira URL を自動抽出する。

```bash
gh pr view <PR番号> --repo <owner>/<repo> --json title,body
```

- **リポジトリ名**: PR URL のリポジトリ部分から取得
- **Jira URL**: PR の body から Jira URL を抽出（ドメインは `~/.claude/personal.md` の Jira URL パターンに合わせる）
- **チケットタイトル**: 抽出した Jira URL から Jira の summary を取得（PR タイトルではなく Jira のタイトル）

これにより、ユーザーは PR URL と日時だけで登録できる。

## 実行手順

Google Calendar 操作は claude.ai の Calendar ツール（`mcp__claude_ai_Google_Calendar__*`）を使う。`calendarId` には service-release の ID、`timeZone` には `Asia/Tokyo` を指定する。

### Step 1: カレンダー ID 取得

`mcp__claude_ai_Google_Calendar__list_calendars` を実行し、結果から `service-release` カレンダーの ID を取得。見つからない場合はユーザーに報告して中断。

### Step 2: 時間帯の競合チェック

`mcp__claude_ai_Google_Calendar__list_events`（`calendarId` = service-release の ID、`startTime` / `endTime` に対象時間帯、`timeZone` = `Asia/Tokyo`）で既存イベントを取得する。

service-release カレンダーは複数チームがリリース予定を共有するものなので、同時間帯に複数イベントが並ぶのは通常運用。**競合とは「同じリポジトリが同時間帯にある」ことだけを指す。** 時間が重なっていても repo が違えば競合ではない。

**判定で禁止すること:**
- 別 repo のリリースが同時間帯／前後に並んでいることを理由に、その枠を「挟まれている」等として格下げ・忌避しない。repo が被っていなければその枠は問題なし。
- 「今日中で慌ただしい」「前後が混んでいる」のような repo 無関係の主観的理由で枠を下げない。

- **競合なし** → Step 3a
- **同じリポジトリ名を含む既存イベント** → リリース衝突の可能性があるため警告して続行可否を確認。ユーザーが追記を希望したら Step 3b へ
- **自分が作成した既存イベント**（creator がユーザー自身のメール、かつ今回のリリースと内容が合流可能）→ Step 3b で追記するか Step 3a で新規作成するかをユーザーに確認
- **他者が作成した既存イベント** → デフォルトは Step 3a で同時間帯に新規作成。ただし以下の 3 択をユーザーに提示して選ばせる:
  1. 同時間帯に新規作成（Step 3a）
  2. 既存イベントに追記（Step 3b）
  3. 別時間で新規作成（Step 3a、時間を変更）

### Step 2.5: 「被らない時間帯を探して」と頼まれた場合

登録対象の repo（複数可）が既存イベントと **同時間帯に被らない** 枠を探す。

- 判定軸は repo のみ。今後の予定を取得し、対象 repo を含むイベントがある時間帯だけを除外する。
- **最も早く空いている枠を最優先で提案する**（今日・直近の枠を含む）。前後に別 repo のリリースがあっても、その枠が repo 非衝突なら正面から推奨してよい。今日や直近という理由だけで後ろの日に回さない。
- 候補は「いつが空いているか」を端的に示し、最有力（最早の clean 枠）を 1 つ明示する。repo 衝突がある時間帯のみ理由付きで除外する。

### Step 3a: 新規イベント作成

`TEMPLATE.md` のフォーマットに沿って summary / description を組み立てる。`create_event` には dry-run 相当が無いため、**作成内容（タイトル・日時・description）をユーザーに提示して確認後**に `mcp__claude_ai_Google_Calendar__create_event` を実行する。ゲスト招待（Step 5）は `attendees` で同時に指定してよい。

### Step 3b: 既存イベントへの追記

既存イベントの description 末尾に新しいチケット情報を追加。リポジトリが異なる場合は `----------` で区切る（詳細は `TEMPLATE.md`）。既存の summary にないリポジトリ名があれば summary も更新。

更新内容をユーザーに提示して確認後、`mcp__claude_ai_Google_Calendar__update_event`（`eventId` 指定、`summary` / `description` を更新）を実行する。

### Step 4: 完了報告

- イベントタイトル
- 日時（開始〜終了）
- 登録したチケット数

### Step 5: ゲスト招待

`~/.claude/personal.md` の `release-calendar / イベント作成時に必ず招待するメールアドレス` を取得し、それを必ずゲストに追加する。ユーザーが追加ゲストを指定した場合は合わせて追加。

新規作成時は Step 3a の `create_event` で `attendees` に指定して一括登録してよい。既存イベントへ後からゲストを追加する場合は `mcp__claude_ai_Google_Calendar__update_event` の `addedAttendees` を使う（既存ゲストはそのまま残るため全員を再指定する必要はない）。

## 注意事項

- 日時が曖昧な場合（「明日の午後」等）は具体的な日時を確認
- ツールの生 JSON はそのまま貼らず、必要な情報だけ整形して提示
- 書き込み操作（`create_event` / `update_event`）は必ず作成・更新内容をユーザーに提示して確認後に本実行
- リリース待ちチケットを Jira から探す場合は `mcp__claude_ai_Atlassian_Rovo__searchJiraIssuesUsingJql` で `status = "リリース待ち" AND assignee = currentUser()` を照会する（Vault のロードマップ等ドキュメントを真実源にしない）
