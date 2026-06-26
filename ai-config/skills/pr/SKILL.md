---
name: pr
description: 現在のブランチから PR を作成する。コミット群からタイトル・Summary・Test Plan を生成し `gh pr create --assignee @me` を実行。QA 確認事項の文書化は pr-qa-doc を使う。
allowed-tools: Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh repo view:*), Bash(git check-ignore:*)
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
   - `--assignee @me` を必ず付与
4. 作成後、PRのURLを表示

## PR本文フォーマット

```
Title: <変更の要約を簡潔に>（日本語）

## Summary
- 変更点を箇条書き

## Test Plan
- テスト方法・確認事項を箇条書き
```

## 作成後

- オートマージの設定やマージ操作は行わない（ユーザーが別途手動で行う）
- PR 作成後に STG/PROD の QA 確認事項を Markdown 化したい場合は `pr-qa-doc` スキルを案内する
- Jira チケット起点で STG マニュアルテストを実際に設計・実行し、エビデンスと Jira コメント下書きまで作る場合は `stg-manual-test` を使う

## 注意事項

- ベースブランチは `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` で自動検出
- `--fill` は使わない（全コミットを分析して適切なタイトル・本文を生成する）
- リベースやforce pushは行わない（破壊的操作は別途ユーザーが指示すべき）
- タイトル・本文はユーザーの言語に合わせる

## ハマりどころ

### ネストリポジトリ（親リポジトリの .gitignore 配下に別リポジトリがある場合）
- 例: `prtimes-dev-docker/web/prtimes-source` は `.gitignore` で除外されており、中身は別リポジトリ `PRTIMES/prtimes`（default branch: master）
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
