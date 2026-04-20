---
name: agent-browser
description: agent-browser CLI を使って任意の Web サイトで対話型のブラウザ自動化を実行する。ユーザーが URL 遷移・ページ調査・スクリーンショット取得・フォーム入力・スクレイピング等の汎用ブラウザタスクを依頼したときに起動する。
allowed-tools:
  - Bash(agent-browser:*)
  - Bash(mkdir:*)
  - Bash(ls:*)
  - Bash(which:*)
---

# agent-browser 対話型 Web 自動化スキル

[agent-browser CLI](https://github.com/vercel-labs/agent-browser) を使い、自然言語で依頼された汎用ブラウザタスクを **snapshot-ref パターン** で逐次実行する。

「このページを調べて」「〜のスクショを取って」「フォームに入力してボタンを押して」「〜の情報を抜き出して」といった汎用タスク向け。STG マニュアルテスト用途には専用スキル `stg-manual-test-ab` を使う。

## 引数

- `$ARGUMENTS` にタスクの説明（URL 含む）を指定。省略時はユーザーに「何をしたいか」「対象 URL」を確認する。

## 前提条件

- `agent-browser` コマンドが PATH 上にあること（`which agent-browser` で確認）
- 認証が必要なサイトの場合、事前に認証方針を決める（REFERENCE.md「認証」参照）

## 参照ファイル

- **コマンドリファレンス・セマンティックロケータ・認証・トラブルシューティング**: 同ディレクトリの `REFERENCE.md` を Read

## 実行原則

### 1. snapshot-ref パターンを徹底する

すべての操作は「snapshot → ref 特定 → action」の 3 ステップで行う。LLM が推測で CSS セレクタを書かない。

```bash
agent-browser snapshot -i -c    # @e1 button "Submit", @e2 textbox "Email", ...
agent-browser fill @e2 "..."
agent-browser click @e1
```

ページ遷移・DOM 大幅変更のたびに必ず再 snapshot する。ref は毎回再割り当てされ、stale な ref はエラーになる。

### 2. セッション名を付ける

全コマンドに `--session-name <タスク固有名>` を付け、cookie/localStorage を永続化する。原則 `browse-<短い識別子>`（例: `browse-hn`, `browse-myapp`）。

### 3. 副作用ある操作は事前確認

フォーム送信・ファイルアップロード/ダウンロード・認証情報入力・課金/購入はユーザー確認後に実行。

### 4. ドメイン制限を付ける

タスクで触れるドメインが明確な場合は `--allowed-domains` で誤操作防止：

```bash
agent-browser --session-name browse-hn \
  --allowed-domains "news.ycombinator.com" \
  open "https://news.ycombinator.com/"
```

## 手順

### Step 1: タスク理解

`$ARGUMENTS` またはユーザー入力から **対象 URL / ゴール / 必要な副作用** を抽出し、以下を 1〜2 行で確認：

```
タスク: <ゴール>
対象: <URL>
操作: <閲覧のみ / フォーム入力あり / ログインあり 等>
成果物: <要約 / スクリーンショット / 抽出データ 等>
```

副作用のある操作が含まれる場合は明示して承認を得る。

### Step 2: 環境準備

```bash
mkdir -p .browse-output/<タスク名>
export AGENT_BROWSER_SCREENSHOT_DIR="$(pwd)/.browse-output/<タスク名>"
agent-browser --version   # 疎通確認
```

### Step 3: 実行

典型フロー：

```bash
agent-browser --session-name browse-<X> \
  --allowed-domains "<host>" open "<URL>"
agent-browser --session-name browse-<X> wait 1500
agent-browser --session-name browse-<X> snapshot -i -c
agent-browser --session-name browse-<X> get text @e<N>
agent-browser --session-name browse-<X> screenshot --full overview.png

# 操作が必要なら
agent-browser --session-name browse-<X> fill @e3 "入力値"
agent-browser --session-name browse-<X> click @e5
agent-browser --session-name browse-<X> wait 1500
agent-browser --session-name browse-<X> snapshot -i   # 再取得必須
```

詳しいコマンドは `REFERENCE.md` を参照。

### Step 4: 成果物提示

1. パス一覧を提示（`.browse-output/<タスク名>/*.png` 等）
2. 判明した要点を 3〜5 行で要約
3. 追加操作が必要ならユーザー確認

## 注意事項

- 副作用のある操作は必ず事前確認（フォーム送信、購入、ファイル削除 等）
- 認証情報を平文で渡さない（stdin or auth vault）
- 公開サイト以外では `--allowed-domains` を推奨
- 成果物はカレントの `.browse-output/` 配下に保存しパスをユーザー提示
- 大量スクレイピング・レート制限違反になる使い方はしない
- ログイン済み社内ツール等を触る前に対象システムの利用規約・テスト範囲を確認

## 関連スキル

- `stg-manual-test-ab`: STG マニュアルテスト専用（Jira 連携、コメント下書き生成）
- `stg-manual-test`: 同上の Playwright MCP 版
