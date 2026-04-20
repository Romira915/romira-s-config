---
name: stg-manual-test-ab
description: Jira チケットから STG マニュアルテストを設計・実行しエビデンスと Jira コメント下書きを作成する（agent-browser 版）。agent-browser ベースの STG 検証依頼に使う。
allowed-tools:
  - Bash(agent-browser:*)
  - Bash(mkdir:*)
  - Bash(rm:*)
  - Bash(ls:*)
  - Bash(mv:*)
  - Bash(which:*)
  - mcp__claude_ai_Atlassian_Rovo__getJiraIssue
  - mcp__claude_ai_Atlassian_Rovo__searchJiraIssuesUsingJql
---

# STG マニュアルテスト実行スキル (agent-browser CLI 版)

Jira チケットの仕様からテストケースを設計し、[agent-browser CLI](https://github.com/vercel-labs/agent-browser) で STG 環境のマニュアルテストを実行、スクリーンショットを取得して Jira コメントの下書きを作成する。

Playwright MCP 版の `stg-manual-test` と並存。CLI ベースで軽量・高速、`snapshot -i` で得られる `@e<N>` ref による決定的操作が特徴。

## 引数

- `$ARGUMENTS` に Jira チケットキーまたは URL（例: `PTA-1290`）。省略時はユーザーに確認。

## 前提条件

- `agent-browser` コマンドが PATH 上にある（`which agent-browser`）
- テスト対象 STG 画面のログイン情報が利用可能
- カレント配下に `evidence/` ディレクトリ作成可能

## 参照ファイル

- **コメント下書きフォーマット・スクショ命名規則**: 同ディレクトリの `TEMPLATE.md` を Read
- **STG 固有の agent-browser ノウハウ（ログイン/mailcatcher/BaseMachina/batch）**: 同ディレクトリの `NOTES.md` を Read
- **agent-browser CLI 一般のコマンド・セレクタ・認証・トラブルシューティング**: `~/.claude/skills/agent-browser/REFERENCE.md` を Read
- **STG ドメイン・テストアカウント等のユーザー固有値**: `~/.claude/personal.md` の `stg-manual-test` セクションを Read

## 手順

### Step 1: テストケース設計

1. Jira チケットの説明・コメント・添付資料を `getJiraIssue` で読み込む
2. 仕様から **テスト対象操作 / パターン分類（正常系・異常系）/ 期待結果** を抽出
3. テストケース一覧を作成し、ユーザーにレビューを求める：
   ```
   | # | アクション | 入力条件 | 期待結果 |
   ```
4. ユーザー承認後に Step 2

### Step 2: テスト環境・データ確認

1. ユーザーに以下を確認：
   - **STG ドメイン** / **テスト対象 URL** / **テストデータ状態** / **結果確認方法**（mailcatcher、画面、DB 等）
2. エビデンスディレクトリ作成: `mkdir -p evidence/<チケットキー>/`
3. **セッション名**: `stg-<チケットキー>` を全 `agent-browser` 呼び出しに付ける（cookie/localStorage 永続化）
4. **スクショ保存先**:
   ```bash
   export AGENT_BROWSER_SCREENSHOT_DIR="$(pwd)/evidence/<チケットキー>"
   ```

### Step 3: テスト実行

各テストケースについて snapshot-ref パターンで実施：

```bash
agent-browser --session-name stg-<TICKET> open "<テスト対象URL>"
agent-browser --session-name stg-<TICKET> wait 1500
agent-browser --session-name stg-<TICKET> snapshot -i -c   # ref 確定
agent-browser --session-name stg-<TICKET> fill @e3 "<入力値>"
agent-browser --session-name stg-<TICKET> screenshot --full test<N>_input.png
agent-browser --session-name stg-<TICKET> click @e5
agent-browser --session-name stg-<TICKET> wait 1500
agent-browser --session-name stg-<TICKET> snapshot -i      # ページ変更後は必ず再取得
agent-browser --session-name stg-<TICKET> get text @e<M>   # 結果取得
agent-browser --session-name stg-<TICKET> screenshot --full test<N>_<内容>_upper.png
```

- 初回ログイン手順、mailcatcher 操作、BaseMachina 連携、batch 実行は `NOTES.md` 参照
- ref は snapshot ごとに再割り当てされるため stale な ref を使わない（ページ遷移後は必ず再 snapshot）
- **テストデータ変更が必要な場合**: 変更前にユーザー確認、テスト後に必ず復元
- **副作用ある操作**（メール送信、データ更新等）は実行前にユーザー確認

### Step 4: コメント下書き作成

`TEMPLATE.md` のフォーマットに従い `evidence/<チケットキー>/comment_draft.md` を生成。

### Step 5: 結果報告

1. OK/NG 件数のサマリ
2. `comment_draft.md` のパス提示
3. **Jira への投稿はユーザー指示を待つ**（自動投稿しない）

## 注意事項

- テストケース設計の段階でユーザーレビューを挟む（いきなり実行しない）
- テストデータ変更時はユーザー確認＋テスト後復元
- 副作用ある操作は実行前にユーザー確認
- ブラウザセッションが切れたら再ログイン（`NOTES.md` のログイン手順）
- コメント下書きは、チケット既存のテスト結果コメント形式があればそれに合わせる
- Jira 自動投稿しない（`addCommentToJiraIssue` を allowed-tools に含めない）
