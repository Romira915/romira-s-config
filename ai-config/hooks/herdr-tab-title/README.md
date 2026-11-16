# Herdr タブタイトル Hook

Claude Code と Codex の UserPromptSubmit Hook から共通の hook.py を呼び出し、セッションの最初の依頼を短いタブ名にします。

## 動作

- Herdr のペイン内で動作しているときだけ実行します。
- 起動時の `HERDR_TAB_ID` はペインを移動しても更新されないため、Hook 実行時に Herdr へ現在のペイン情報を問い合わせ、対象タブを特定します。タイトル生成中にペインが別のタブへ移動した場合は rename を中止します。
- 最初の依頼を、そのセッションで使っている Claude Code または Codex CLI に渡し、依頼の言語で短いタイトルを生成します。
- タイトル生成用に追加のモデル呼び出しがセッションごとに一度発生します。Claude Code ではツール無効、Codex では読み取り専用で実行します。
- Herdr が付けた連番ラベル、またはこの Hook が以前に付けたラベルだけを変更します。手動で付けた別名は保持します。
- Herdr CLI や生成 CLI が使えない場合、JSON を読めない場合、タイトルを生成できない場合は何も変更せず終了します。

Hook の共通実装は `ai-config/hooks/<hook-name>/` に配置し、各エージェントの設定ファイルから呼び出します。この Hook の構成は次のとおりです。

- 実装・説明: `ai-config/hooks/herdr-tab-title/`
- Claude Code の登録: `ai-config/claude-code/settings.json`
- Codex の登録: `ai-config/codex/hooks.json`
- Codex for Windows の登録: `ai-config/codex/hooks.windows.json`

Hook 本体は各ツールの hooks ディレクトリに `herdr-tab-title.py` として配置します。Mac・WSL・Windows のリンク設定は `romira-arcadia-ops` が管理します。

Claude Code と Codex の設定ファイルは、それぞれのホームディレクトリからこのリポジトリ内のファイルへリンクされています。

## 状態ファイル

Hook が最後に設定したタブ名とセッション ID を記録します。設定の正本はリポジトリ内に置き、実行時の状態は OS のユーザーデータ領域へ保存します。

- macOS / Linux: XDG_STATE_HOME が未設定なら ~/.local/state/romira-s-config/herdr-tab-title/
- Windows: %LOCALAPPDATA%/romira-s-config/herdr-tab-title/

## Codex の信頼確認

Codex は新しい Hook を実行する前に /hooks で定義の確認と信頼を求めることがあります。確認が済むまでは Hook を実行しません。
