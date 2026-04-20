---
name: release-calendar
description: service-release カレンダーにリリース予定イベントを登録・追記する。ユーザーが PR のリリース日時を共有カレンダーに載せたいときに起動する。
allowed-tools: Bash(gog calendar:*), Bash(gog cal:*), Bash(gh pr view:*), mcp__claude_ai_Atlassian__getJiraIssue, AskUserQuestion
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

### Step 1: カレンダー ID 取得

```bash
gog calendar calendars --json --no-input
```

結果から `service-release` カレンダーの ID を取得。見つからない場合はユーザーに報告して中断。

### Step 2: 時間帯の競合チェック

```bash
gog calendar events <calId> --from "<start_iso>" --to "<end_iso>" --json --no-input
```

- **競合なし** → Step 3a
- **同じリポジトリ名を含む既存イベント** → 警告して続行可否を確認
- **自分が作成した既存イベント**（creator がユーザー自身のメール）→ Step 3b で追記
- **他者が作成した既存イベント** → 「追記してよいか」確認し、承認されたら Step 3b へ、拒否されたら別時間を提案

### Step 3a: 新規イベント作成

`TEMPLATE.md` のフォーマットに沿って summary / description を組み立てる。

```bash
gog calendar create <calId> \
  --summary "<title>" \
  --from "<start_iso>" \
  --to "<end_iso>" \
  --description "<description>" \
  --dry-run --no-input
```

dry-run の結果をユーザーに見せて確認後、`--dry-run` を外して本実行。

### Step 3b: 既存イベントへの追記

既存イベントの description 末尾に新しいチケット情報を追加。リポジトリが異なる場合は `----------` で区切る（詳細は `TEMPLATE.md`）。既存の summary にないリポジトリ名があれば summary も更新。

```bash
gog calendar update <calId> <eventId> \
  --summary "<updated_title>" \
  --description "<updated_description>" \
  --dry-run --no-input
```

dry-run の結果をユーザーに見せて確認後、本実行。

### Step 4: 完了報告

- イベントタイトル
- 日時（開始〜終了）
- 登録したチケット数

### Step 5: ゲスト招待

`~/.claude/personal.md` の `release-calendar / イベント作成時に必ず招待するメールアドレス` を取得し、それを必ずゲストに追加する。ユーザーが追加ゲストを指定した場合は合わせて追加。

```bash
gog calendar update <calId> <eventId> \
  --attendees "<email1>,<email2>" \
  --send-updates "all" \
  --dry-run --no-input
```

dry-run の結果をユーザーに見せて確認後、本実行。

**注意**: `--add-attendee` フラグは動作しない（"no updates provided" エラーになる）。`--attendees` を使用すること。既存ゲストがいる場合は既存ゲストも含めカンマ区切りで全員指定する必要がある。

## 注意事項

- 日時が曖昧な場合（「明日の午後」等）は具体的な日時を確認
- `--json` の結果はそのまま貼らず、必要な情報だけ整形して提示
- 書き込み操作は必ず `--dry-run` でプレビュー後に本実行
