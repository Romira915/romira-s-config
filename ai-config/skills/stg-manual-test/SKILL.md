---
name: stg-manual-test
description: Jira チケットから STG マニュアルテストを設計・実行し、エビデンスと Jira コメント下書きを作成する。通常は agent-browser CLI、Playwright MCP 指定時のみ Playwright で実行する。
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

# STG マニュアルテスト実行スキル

Jira チケットの仕様からテストケースを設計し、STG 環境のマニュアルテストを実行、スクリーンショットを取得して Jira コメントの下書きを作成する。

## 実行方式の選択

- **通常は agent-browser CLI を使う**。CLI ベースで軽量・高速、`snapshot -i` で得られる `@e<N>` ref による決定的操作ができる。
- **Playwright MCP はユーザーが明示した場合だけ使う**（例: 「Playwright で実行して」「Playwright MCP 版で」）。
- 汎用的な Web 調査・スクショ取得・フォーム入力だけなら `agent-browser` スキルを使う。Jira 起点の STG テスト設計・エビデンス整理・コメント下書き作成まで必要な場合はこのスキルを使う。

## 引数

- `$ARGUMENTS` に Jira チケットキーまたは URL（例: `PTA-1290`）を指定。省略時はユーザーに確認。

## 参照ファイル

- **コメント下書きのフォーマット・テーブル記載ルール・スクショ命名規則**: 同ディレクトリの `TEMPLATE.md` を Read
- **agent-browser の STG 固有ノウハウ（ログイン/mailcatcher/BaseMachina/batch）**: 同ディレクトリの `NOTES.md` を Read
- **Playwright 操作ノウハウ（URL バー付きスクショ、mailcatcher スクロール、BaseMachina 等）**: Playwright MCP を使う場合のみ同ディレクトリの `PLAYWRIGHT.md` を Read
- **agent-browser CLI 一般のコマンド・セレクタ・認証・トラブルシューティング**: `agent-browser` スキルの `REFERENCE.md` を Read
- **STG ドメインや BaseMachina URL などユーザー固有値**: `~/.claude/personal.md` の `stg-manual-test` セクションを Read

## 前提条件

- agent-browser CLI 実行時: `agent-browser` コマンドが PATH 上にある（`which agent-browser`）
- Playwright MCP 実行時: Playwright MCP サーバーが起動している
- テスト対象の STG 画面にログイン済み（未ログインの場合はユーザーに手動ログインを依頼）
- カレント配下に `evidence/` ディレクトリを作成可能

## 手順

### Step 1: テストケース設計

1. Jira チケットの**説明・コメント・添付資料**を読み込む（Jira MCP が使える場合は `getJiraIssue` を使う）
2. 仕様から以下を抽出する：
   - **テスト対象の操作**（API 呼び出し、画面操作、バッチ実行 等）
   - **パターン分類**（正常系・異常系、パラメータの組み合わせ）
   - **期待結果**（表示内容、メール文面、DB 状態 等）
3. テストケース一覧を作成し、**ユーザーにレビューを求める**：
   ```
   | # | アクション | 入力条件 | 期待結果 |
   |---|-----------|---------|---------|
   | 1 | ... | ... | ... |
   ```
4. ユーザーの承認を得てから Step 2 に進む

### Step 2: テスト環境・テストデータの確認

1. ユーザーに以下を確認：
   - **STG ドメイン**（`~/.claude/personal.md` の `STG 環境ドメイン` から取得）
   - **テスト対象の画面 URL** またはアクションの実行方法
   - **テストデータの状態**（事前にデータ投入が必要か）
   - **結果確認方法**（mailcatcher、画面表示、DB 確認 等）
2. エビデンスディレクトリを作成: `evidence/<チケットキー>/`
3. agent-browser CLI 実行時はセッション名 `stg-<チケットキー>` を全 `agent-browser` 呼び出しに付ける（cookie/localStorage 永続化）
4. agent-browser CLI 実行時はスクショ保存先を設定:
   ```bash
   export AGENT_BROWSER_SCREENSHOT_DIR="$(pwd)/evidence/<チケットキー>"
   ```

### Step 3: テスト実行

各テストケースについて以下を繰り返す：

#### 3-1. 操作実行（agent-browser CLI）

通常は snapshot-ref パターンで実施する：

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

#### 3-2. 操作実行（Playwright MCP 指定時）

1. テスト対象の画面に遷移
2. テストパラメータを入力
3. **入力画面のスクショ取得** → `test<番号>_input.png`（命名は `TEMPLATE.md` 参照）
4. 操作を実行
5. レスポンスを確認

#### 3-3. 結果確認

1. 結果確認画面に遷移（mailcatcher、管理画面、フロント画面等）
2. 実際の結果が期待結果と一致するか確認
3. **結果画面のスクショ取得** → `test<番号>_<確認内容>_upper.png`
4. スクロールが必要なら追加スクショ → `test<番号>_<確認内容>_footer.png`

#### 3-4. テストデータの変更が必要な場合

- 変更前にユーザーの確認を取る
- テスト完了後は必ず元の状態に復元する

### Step 4: コメント下書き作成

`TEMPLATE.md` のフォーマットに従って `evidence/<チケットキー>/comment_draft.md` に Jira コメント用 Markdown を生成する。

### Step 5: ユーザーに結果報告

1. テスト結果のサマリ（OK/NG 件数）
2. `comment_draft.md` のパスを提示
3. **Jira への投稿はユーザーの指示を待つ**（自動投稿しない）

## 注意事項

- テストケース設計の段階でユーザーレビューを挟む（いきなり実行しない）
- テストデータを変更する場合はユーザーに確認し、テスト後に必ず復元する
- 副作用のある操作（メール送信、データ更新等）は実行前にユーザーの確認を取る
- ブラウザセッションが切れた場合はユーザーに再ログインを依頼する
- コメント下書きのフォーマットは、チケットに既存のテスト結果コメントがあればその形式に合わせる
