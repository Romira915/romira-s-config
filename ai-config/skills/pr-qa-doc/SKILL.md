---
name: pr-qa-doc
description: PR の変更内容から STG/PROD などの QA 確認事項を Markdown で書き出す。煽り強調禁止・結果＝エビデンス・コマンド/出力 → 判定の 2 段、というフォーマット規約を守る。出力先は cwd に応じて Repo の docs/ または Obsidian Vault 配下を提案する。
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh api repos:*), Bash(git rev-parse:*), Bash(git remote:*), Bash(ls:*), Bash(mkdir:*), Bash(screencapture:*), Bash(osascript:*), Bash(sips:*), Read, Write, Edit, mcp__plugin_chrome-devtools-mcp_chrome-devtools__new_page, mcp__plugin_chrome-devtools-mcp_chrome-devtools__navigate_page, mcp__plugin_chrome-devtools-mcp_chrome-devtools__list_pages, mcp__plugin_chrome-devtools-mcp_chrome-devtools__take_snapshot, mcp__plugin_chrome-devtools-mcp_chrome-devtools__fill_form, mcp__plugin_chrome-devtools-mcp_chrome-devtools__fill, mcp__plugin_chrome-devtools-mcp_chrome-devtools__click, mcp__plugin_chrome-devtools-mcp_chrome-devtools__wait_for, mcp__plugin_chrome-devtools-mcp_chrome-devtools__select_page, mcp__plugin_chrome-devtools-mcp_chrome-devtools__close_page
---

# pr-qa-doc

PR の変更内容から QA 確認事項を設計し、フォーマット規約に従った Markdown ファイルとして書き出す。Jira コメントにそのまま貼って使える形にする。

## 引数

`/pr-qa-doc <PR>` の形で呼ばれる。`<PR>` は以下のいずれか:

- フル URL: `https://github.com/<owner>/<repo>/pull/<number>`
- `<owner>/<repo>#<number>`
- `#<number>` または `<number>`（cwd がそのリポジトリ内のとき）

引数が省略されたら、`gh pr view --json url,number,headRefName` で「現在のブランチに紐づく PR」を試みる。それも無ければユーザーに PR を聞く。

## 手順

### 1. PR 情報の取得

```sh
gh pr view <PR> --json title,body,baseRefName,headRefName,files,number,url
gh pr diff <PR>
```

PR description（body）と diff から以下を抽出する:

- Jira チケット番号（例: `<PROJ>-NNNN`）。description のリンクから検出
- 変更されたファイルの種別（routing / config / VCL / terraform / view / helper など）
- description に記された検証観点・Phase 戦略・前後 PR との関係

### 2. QA シナリオの設計

差分が触れた箇所そのものの挙動を直接確認するシナリオに絞る。下記は**書かない**:

- 事前確認（デプロイ反映、apply 完了、ブランチコミット同期）
- CI が通っていること（マージ前に確認済み前提）
- コード grep の結果（コードレビューで担保済み）
- PR が触れていない隣接サービス・隣接パスのリグレッション

代わりに、差分の種類から以下のような観点を組む（例）:

| 差分の種類 | 確認観点の例 |
|---|---|
| routing.rb の host 制約追加 | 新ホストで受け付け / 旧ホスト挙動維持 / ドメイン別出力の整合性 |
| settings.yml の URL 追加 | 出力 URL が想定通り（ホストに応じた切替が成立しているか） |
| Fastly VCL の path 追加 | 該当 path でバックエンドルーティング / 認証パス / 異常系応答 |
| terraform ALB host_header | listener rule で新ホスト受信 / 旧ホスト維持 |
| view (meta tags など) | canonical / og / twitter card がリクエストドメインに応じて出るか |
| 末尾スラッシュ・大文字小文字・認証ヘッダ等の境界入力 | 異常系で 1〜2 項目だけ含める |

### 3. 出力先の決定

cwd を判定して保存先を提案する:

```sh
git rev-parse --show-toplevel 2>/dev/null
ls .obsidian 2>/dev/null
ls docs 2>/dev/null
```

- **Obsidian Vault 内**（`.obsidian/` が cwd または親に存在）: `Work/開発/<project>/<Jira-no>-<環境>-QA結果.md`
  - `<project>` は PR タイトル・本文・既存ディレクトリ名から推定。曖昧なら聞く
  - 同名ファイルが既にあれば追記提案。無ければ新規作成
- **Git リポジトリ内**: `docs/qa/<Jira-no>-<環境>-QA.md`
  - `docs/` が無ければユーザーに作成可否を確認
- **判別不能**: ユーザーに保存場所を聞く

`<環境>` は PR description や差分から STG/PROD 等を推定。曖昧なら STG をデフォルトに。

### 4. Markdown の生成

以下のフォーマット規約を厳守する。

#### フォーマット規約

1. **タイトル**は短く。`# STG QA` のような最小形。`【最重要】` `【必須】` `⚠️ 注意` 等の煽り強調マーカーは**使わない**（見出し・本文どちらにおいても）
2. **チェック項目の構造**は「コマンド/観点 → 出力ブロック（結果＝エビデンス） → 判定」の 2 段。**「実測」「結果」「エビデンス」を別欄に分けない**
3. **出力ブロックがそのままエビデンス**。コマンドで取れる項目に「エビデンス: ここにスクショ貼付」枠を**作らない**。curl 出力は `grep -oE 'pattern'` のように **一致部分だけを切り出さない** — HTTP ヘッダー、HTML の該当行の前後数行、JSON の関連フィールドなど、**「何にマッチしたか」が読者にわかる文脈を残す**。grep が必要なら `grep -A 2 -B 2` で前後を含める or `sed -n` で範囲指定する
4. **スクショ枠を作るのは、ブラウザ表示・管理画面 UI など、テキスト出力で表現できない項目のみ**。スクショ枠は**コードブロックも見出しもプレースホルダ文言（「ここに画像を貼付」「ブラウザ確認待ち」等）も置かず、空行だけ**にする。検証者がただ画像をドラッグすれば貼り付けが完了する状態にする。**ドメイン移行/ホスト追随系のブラウザ項目（どのドメインで見ているかが核心の項目）は、URL バー（アドレスバー）が見えるスクショであることが前提**（撮り方は手順 6 を参照）
5. **検証時に消す手間が発生するプレースホルダを書かない**: `（ブラウザ確認待ち）` `[ ここにスクショ貼付 ]` `[ curl 出力を貼付 ]` 等の文言は不要。curl 出力枠が必要なら**空のコードブロック**（` ``` ` ↵ ` ``` `）だけ置く
6. **総合判定セクションを作らない**。各項目の判定で完結
7. **事前確認セクション（デプロイ済み・apply 済み・CI pass）を作らない**
8. **PR が触れていない隣接サービスの確認項目を入れない**
9. **手順・原因連鎖は順序付き箇条書きで書く**。`A → B → C` の散文や矢印連結ではなく `1. A` / `2. B` / `3. C` で 1 発で読めるようにする。矢印は 1 ステップ内の最小限の連動 (例: 「ボタン押下 → 200 で verify 完走」) に留める。エビデンス画像はステップ番号直下にインデントして添える

#### ドメイン移行系の特別ルール

ドメイン移行系（旧ドメイン → 新ドメインの並走運用）の PR は、ホスト応答型の出力（`canonical` / `og:url` / `og:image` / `twitter:url` / `twitter:image` 等）について **「受け付けドメインに応じて自ドメインを返す」のが仕様**となるケースがある。これを「化け」「NG」と判定しないための判定規約は、所属プロジェクト固有のため `~/.claude/personal.md` の `pr-qa-doc / ドメイン移行ルール` セクションを Read して参照する（旧/新ドメイン名・対象ヘッダ・合格条件など）。

該当する PR を扱う場合は、上記セクションを Read してから QA 項目を組む。

#### 検証ホストの決定（重要）

QA コマンド内で使う STG ホスト（例: 共有 STG `stg-<domain>` か 個人 STG `<username>.stg-<domain>` か。具体値は `personal.md` の `STG 環境ドメイン` を参照）は **ユーザー指示を最優先する**。

- **ユーザーが明示したホスト**（プロンプト・PR description・既存 QA ドキュメント内の記述）があればそれを使う。`personal.md` の `STG 環境ドメイン` で自動上書きしない
- **指示がない場合**は QA ドキュメント書き出し前にユーザーに確認する。最低限以下を提示:
  - 共有 STG（無印・`stg-<domain>`）
  - 個人 STG（`<username>.stg-<domain>` / personal.md の値）
- `personal.md` の `STG 環境ドメイン` は **個人 STG のテンプレートとしての参照値**であり、QA の検証先デフォルトではない。共有 STG での確認が目的のドメイン移行系 QA では、無印を選ぶのが基本
- PR のホスト判定ロジックが触られている場合（例: ALB host header / Fastly host 制約 / routing host 制約）、検証ホストの命名（`<username>.` プレフィックスの有無）が結果に影響することがある。確認なく個人 STG に置き換えない

#### テンプレート

ファイル全体の骨格:

```markdown
# <環境> QA

- 検証日: <YYYY-MM-DD>

---

## A. <シナリオ群の見出し（例: `.com` 側の新規受け付け）>

### A-1. <観点の見出し（例: stg-<host>/<path>/ が 200）>

\`\`\`sh
curl -I https://example.com/path
\`\`\`

\`\`\`

\`\`\`

- 判定: ⬜️

### A-2. <UI 観点の見出し（ブラウザ確認）>

- 判定: ⬜️




---

## B. <シナリオ群の見出し>

...
```

各見出しはアルファベット + 番号で連番（A-1, A-2, B-1, ...）。

### 5. 書き出し

`Write` ツールで Markdown を保存し、保存パスをユーザーに報告する。`<Jira-no>` が取れていればファイル名に含める。

### 6. 検証（このスキルの基本範囲外。ユーザーが「実行」を指示したときのみ実施）

curl・ブラウザ確認などの実行は基本このスキルでは行わない。検証は書き出されたチェックリストに沿って別途実施し、出力ブロック内に結果を貼り、判定 `⬜️` を `✅` / `❌` に更新する運用。

ただしユーザーが明示的に「実行して」と指示した場合は、書き出した QA に沿って検証し、エビデンスと判定を埋める。その際のスクショ規約:

- **ホスト追随系の判定をテキスト URL だけで代替しない**。URL バーが見えるスクショを必ず添える。撮影できない制約に当たったら、省略・格下げせず**いったん中断してユーザーに確認する**（黙ってエビデンス水準を下げない）
- **DOM を改変して URL 等を表示させない**（バナー差し込み等）。改変したページは偽の証跡になる。ページ本文に元から URL が出る画面（配信管理画面など）は、その本文表示が改変なしの証跡になる
- **操作は chrome-devtools-mcp（実 Chrome の可視ウインドウ）を使う**。URL バー撮影には見えるウインドウが要るが、Playwright MCP は通常 headless で omnibox を撮れない。chrome-devtools-mcp の `new_page` を `isolatedContext` 付きで開き、分離コンテキストでログインしてユーザーの実セッションを汚さない。Playwright を使うなら headed 必須
- **`take_screenshot`（CDP / Playwright とも）は viewport（ページ本文）だけで omnibox が写らない**。URL バーは下記の OS ウインドウ撮影で撮る
- **保存先**: QA 画像は手順 3 で決めた QA ドキュメントと同じ場所基準で置く（Vault でも repo でも、ドキュメント隣の `images/<Jira-no>/` 等）。相対パスで埋め込む。撮影ツールの書き込み先が制限される場合（`/tmp` 不可等）は、書ける場所に撮ってから所定の場所へ移す
- **macOS でのウインドウ撮影方法**:
  1. AppleScript で**対象 URL を持つタブ／ウインドウを前面化**する（`set active tab index` ＋ `set index of window 1` ＋ `activate`。chrome-devtools-mcp が動かす実 Chrome は `Google Chrome`）
  2. `bounds of window 1`（x1,y1,x2,y2）を取得し、`screencapture -x -R<x1>,<y1>,<w>,<h>` で撮影（w=x2-x1, h=y2-y1）。複数ディスプレイで region がズレる場合だけ `screencapture -D<n>` で対象ディスプレイ全体を撮って crop に切り替える
  3. **撮った画像を Read して URL バーに想定ホストが写っているか必ず確認**してから判定・埋め込みに進む（撮れたつもりで進めない）
- 認証が要る画面（OTP 等）は OTP コードをユーザーに依頼する。状態変更を伴う操作（公開など）は自動実行せず手動に倒す

## 注意

- スキル発動時は cwd・PR の文脈で「適切な場所」が変わるので、保存前にユーザーへ保存先を提示して確認する
- フォーマット規約に違反する書き方（煽り強調・3 段欄分け・総合判定・関係ない隣接確認・事前確認セクション）が紛れていたら、書き出す前に削る
- Jira コメントへのコピペ前提なので、相対リンクや Vault 内特殊リンクは使わず標準 Markdown に留める
