---
name: opencode-skill-audit
description: ai-config/skills や opencode スキル一覧をレビューし、重複・命名・説明・使い分け・allowed-tools の改善案を出す。opencode 設定編集全般は customize-opencode を使う。
---

# opencode-skill-audit

opencode / Claude Code 向けスキル群を監査し、重複・命名・説明・発動条件・権限の改善点を整理するレビュー専用スキル。

## 対象

- `ai-config/skills/` 配下のスキル
- `.opencode/skills/` 配下のスキル
- `~/.config/opencode/skills/` 配下のスキル
- `~/.claude/skills/` など外部読み込みされるスキル

## 見る観点

1. **重複**: 似た目的のスキルが複数ないか。統合・改名・使い分け明確化のどれがよいか。
2. **命名**: 初見で用途が分かるか。略語が分かりにくくないか。
3. **description**: 「何をするか」と「いつ使うか」が明確か。隣接スキルとの境界が書かれているか。
4. **手順**: 実行前確認、ユーザー承認、成果物、禁止事項が明確か。
5. **allowed-tools / permission**: 必要最小限か。危険・広すぎる権限がないか。
6. **関連スキル**: `pr` / `pr-qa-doc` / `stg-manual-test` など、連続しやすいスキル間の相互参照があるか。

## 出力方針

- まず「対応推奨」「様子見」「削除・統合候補」に分けて短く整理する。
- 修正が必要な場合も、ユーザーが明示的に依頼するまでは編集しない。
- opencode 自体の設定ファイルや MCP / plugin / agent を編集する場合は、ビルトインの `customize-opencode` を使う。
