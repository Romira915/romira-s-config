---
name: pr
description: Create a pull request for the current branch with auto-generated title and body
allowed-tools: Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh repo view:*)
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

## 注意事項

- ベースブランチは `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` で自動検出
- `--fill` は使わない（全コミットを分析して適切なタイトル・本文を生成する）
- リベースやforce pushは行わない（破壊的操作は別途ユーザーが指示すべき）
- タイトル・本文はユーザーの言語に合わせる
