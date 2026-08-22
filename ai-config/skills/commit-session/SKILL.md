---
name: commit-session
description: セッション中に修正したファイルだけを、リポジトリに適用可能な検証へかけてコミット・pushする。作業の区切りで変更を反映したいときに使う。
allowed-tools: Read, Grep, Bash(test:*), Bash(find:*), Bash(git status:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(just --list:*), Bash(just format:*), Bash(just clippy:*), Bash(just test:*), Bash(python3:*)
---

# セッション変更のコミット・push

## 対象範囲

今回のセッションで修正したファイルだけを commit / push する。作業開始時の `git status --short` を記録し、開始時点から存在する変更・ユーザーが作成した未追跡ファイル・今回の作業と無関係な変更は対象外にする。`git add -A` や `git add .` は使わず、対象ファイルを明示して `git add` する。

## 検証コマンドの選択

コミット前に、変更ファイルとリポジトリの実際の構成に合う検証だけを実行する。検証コマンドを存在確認なしに固定実行してはならない。

1. `AGENTS.md`、`CLAUDE.md`、`README`、プロジェクト設定ファイルを読み、推奨される format / lint / test コマンドを確認する。
2. `Justfile` がある場合だけ `just --list` で利用可能なターゲットを確認する。`format`、`clippy`、`test` はターゲットが存在し、変更内容に関係するときだけ実行する。`clippy` はRustコードがある場合に限る。
3. `Justfile` がない場合は `just` を実行しない。プロジェクトに記載された別のコマンド、対象ファイルのパーサー・フォーマッター、対象スキルのテストなど、実行可能で変更に関係する検証へ切り替える。
4. 検証コマンドや対象ターゲットが存在しないことは「非該当」と扱い、失敗として扱わない。実行した検証、非該当だった検証、結果を報告する。
5. `git diff --check` は常に実行する。実在する検証コマンドが非ゼロ終了した場合は、修正して再検証するまで commit しない。

## commit / push

1. 検証後、セッション中に修正したファイルだけを明示して `git add` する。
2. ステージ内容を `git diff --cached` で確認する。
3. Why（なぜ変更するか）を含む簡潔な日本語コミットメッセージで commit する。
4. 現在のブランチへ通常の `git push` を実行する。
5. non-fast-forward などで拒否された場合は force push せず、merge / rebase が必要であることを報告する。ユーザーの明示指示がある場合だけ履歴統合を行う。

## 注意事項

- フォーマッターがファイルを変更した場合は、差分を確認してセッション対象外の変更を混ぜない。
- ステージ前のユーザー変更を上書き・破棄しない。
- 設定ファイルの同期が必要な場合は `sync-ai-config` のフィルタ手順を先に使い、実ファイルを直接書き戻さない。
