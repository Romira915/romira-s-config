---
name: pr
description: 現在のブランチから PR を作成する。Jira チケットがある場合は issue key をタイトルの prefix にし、コミット群から Summary・Test Plan を生成して `gh pr create --assignee @me` を実行。QA 確認事項の文書化は pr-qa-doc を使う。
allowed-tools: Read, Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(gh pr merge:*), Bash(gh repo view:*), Bash(git check-ignore:*)
---

# PR作成スキル

## 前提条件チェック

1. **ブランチ確認**: 現在のブランチがデフォルトブランチ（main/master）でないことを確認
   - デフォルトブランチにいる場合はエラーメッセージを出して終了（勝手にブランチを作らない）
2. **未コミット変更の確認**: `git status` で未コミット変更があれば警告し、先にコミットするよう促して終了
   - プロジェクトに `commit-session` スキルがあればそちらの利用を案内する

## PR作成手順

1. `git log` と `git diff <default-branch>...HEAD` でブランチ上の全変更を分析
2. リモートにpushされていなければ `git push -u origin <branch>` でpush
3. 変更内容からPRタイトルと本文を生成し、`gh pr create` で作成
   - 対象の Jira チケットがある場合、タイトルは `<jira_issue_key>: <変更の要約>` とする
   - 対象の Jira チケットがない場合、タイトルに prefix を付けず `<変更の要約>` とする
   - Jira issue key を特定できない場合は推測せず、prefix を付けない
   - Jira issue key を `[]` で囲まない。issue key の直後はコロンと半角スペースを1つ入れる
   - `--assignee @me` を必ず付与
   - 対象の Jira チケットがある場合は、PR 本文の先頭に `## JIRA` とチケット URL を記載
4. 作成後、PRのURLを表示

## PR本文フォーマット

```
Title: <jira_issue_key>: <変更の要約を簡潔に>（Jira がある場合）
Title: <変更の要約を簡潔に>（Jira がない場合）

## JIRA

<jira_issue_url>

## Summary
- 変更点を箇条書き

## Test Plan
- テスト方法・確認事項を箇条書き
```

- `## JIRA` は対象の Jira チケットがある場合のみ記載し、無い場合は見出しごと省略する
- ユーザーの依頼、既存文脈、ブランチ名、コミットメッセージから対象チケットを特定する
- チケット URL が既存文脈で分かっている場合はそれを使う
- issue key のみ分かっている場合は、そのときに限り `~/.claude/personal.md` を Read し、`pr-jira-task` の `Jira チケット URL プレフィックス` から URL を組み立てる
- 対象チケットを特定できない場合は URL を推測せず、`## JIRA` を省略する

## 作成後

- ユーザーから明示的な依頼がない限り、マージやオートマージの設定は行わない
- ユーザーからマージを明示的に依頼された場合は、PR のチェック結果とマージ可能状態を確認してから `gh pr merge` を実行する
- マージ方式はリポジトリの既存運用に合わせる。ブランチ削除やオートマージは、それぞれ明示的に依頼された場合のみ行う
- PR 作成後に STG/PROD の QA 確認事項を Markdown 化したい場合は `pr-qa-doc` スキルを案内する
- Jira チケット起点で STG マニュアルテストを実際に設計・実行し、エビデンスと Jira コメント下書きまで作る場合は `stg-manual-test` を使う

## 重要: GitHub上への書き込み（コメント・返信）は明示指示がない限り行わない

- レビューコメントへの返信（`gh api ... pulls/comments` へのPOST、`gh pr comment`等）、Issueへのコメント、PRへの新規コメント投稿は、ユーザーが明示的に依頼しない限り絶対に行わない。
- 「レビュー指摘に対応する」という依頼は、コード修正・コミット・push までを指す。修正が終わったことを GitHub 上で第三者（レビュアー等）に向けて報告する行為は含まれない。
- 対応が完了したら、チャット上でユーザーに完了報告するだけに留める。GitHubへの投稿が必要ならユーザーが自分で行うか、明示的に指示する。
- 迷ったら投稿しない。これは繰り返し指摘されている事項。

## 注意事項

- ベースブランチは `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` で自動検出
- `--fill` は使わない（全コミットを分析して適切なタイトル・本文を生成する）
- リベースやforce pushは行わない（破壊的操作は別途ユーザーが指示すべき）
- タイトル・本文はユーザーの言語に合わせる

## ハマりどころ

### ネストリポジトリ（親リポジトリの .gitignore 配下に別リポジトリがある場合）
- 例: あるディレクトリが親リポジトリの `.gitignore` で除外されており、中身が実は別の独立した Git リポジトリだった、というケースがある
- PR 作成・コミット操作は内側のリポジトリ内で `gh` / `git` を実行する
- 親リポジトリでブランチを作っても対象ファイルに影響しない — `git check-ignore -v <path>` で対象ファイルがどちらのリポジトリに属するか事前確認する

### 別タスクの変更が混在するワークツリーからの切り出し
- 別ブランチに staged 変更があり、今回のタスク分が unstaged にある場合:
  1. `git stash --keep-index` で unstaged 変更だけ退避
  2. `git checkout -b <新ブランチ> origin/<default-branch>` で clean な新ブランチ作成
  3. staged がついてきた場合は `git reset HEAD -- . && git checkout -- .` でクリーンに戻す
  4. `git checkout stash@{0} -- <対象ファイルのみ>` で該当ファイルだけ復元（stash には混在変更が入るのでファイル単位で選択）
  5. コミット・push・PR 作成
  6. 元ブランチに戻って `git stash pop` で退避分を復元

### 「この変更だけでPR」と言われたが、作業中ブランチに無関係な既存コミットが乗っている場合
- PR作成前に必ず `git log origin/<default-branch>..HEAD` で、今回のタスクと無関係なコミットが混入していないか確認する。
- 混入していたら、そのブランチのままPRを作らない。`git checkout -b <新ブランチ> origin/<default-branch>` で `default-branch` から新規ブランチを切り、対象の変更だけを再適用（該当ファイルを再編集するか `git cherry-pick`/`git checkout <元ブランチ> -- <path>` 等で持ってくる）してからコミット・push・PR作成する。
- 元の作業ブランチには触れない（切り離すだけで、既存コミットの削除やrebaseはしない）。
