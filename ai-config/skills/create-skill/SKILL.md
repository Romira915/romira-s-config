---
name: create-skill
description: Create a new Claude Code skill and register it
allowed-tools: Bash(mkdir:*), Bash(ln:*), Bash(ls:*)
---

# スキル作成スキル

ユーザーの要望に基づいて新しい Claude Code スキルを作成・登録する。

## 手順

1. **ヒアリング**: どんなスキルを作りたいか確認（名前、用途、必要なツール）
2. **SKILL.md 作成**: 以下のパスにスキル定義を作成
   - `~/.config/romira-s-config/ai-config/skills/<skill-name>/SKILL.md`
3. **シンボリックリンク作成**: `~/.claude/skills/` にリンクを貼る
   - `ln -s ~/.config/romira-s-config/ai-config/skills/<skill-name> ~/.claude/skills/<skill-name>`
4. **確認**: `ls -la ~/.claude/skills/` でリンクが正しいことを確認

## SKILL.md フォーマット

```markdown
---
name: <skill-name>
description: <1行の説明>
allowed-tools: <許可するツール（例: Bash(git status:*), Bash(git push:*)）コマンド単位で最小限に>
---

# スキル名

## Instructions

手順をここに記述
```

## 注意事項

- スキルの実体は必ず `~/.config/romira-s-config/ai-config/skills/` に置く
- `~/.claude/skills/` には実体を置かず、シンボリックリンクのみ
- プロジェクトの `.claude/skills/` にはスキルを置かない（グローバル管理）
