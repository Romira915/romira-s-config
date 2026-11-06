---
name: herdr-workers
description: Herdr 上でワーカー AI エージェント（claude / codex / gemini / opencode 等）を起動し、指示・待機・結果回収・終了までを操作する。オーケストレータ（herdr-orchestrate）から呼ばれるほか、「Herdr で codex を1つ立ててこれをやらせて」のような単発の委任にも使う。HERDR_ENV=1 の環境でのみ動作する。
allowed-tools: Read, Bash(herdr agent:*), Bash(herdr pane:*), Bash(herdr tab:*), Bash(herdr status:*), Bash(herdr --help), Bash(herdr --skill), Bash(test:*), Bash(jq:*), Bash(sh ~/.claude/skills/herdr-workers/scripts/*:*)
---

# Herdr ワーカー操作

Herdr のペインにワーカーエージェントを立て、プロンプトを渡し、結果を読み、自分が作ったものだけを片付ける。タスク分解や担当の割り当ては扱わない（それは `herdr-orchestrate` の責務）。

## 前提確認（毎回最初に実行）

1. `test "${HERDR_ENV:-}" = 1` を確認する。失敗したら「Herdr 内で動いていない」と伝えて止まる。
2. コマンド構文の正本はインストール済みバイナリ。初回は `herdr agent`、`herdr pane`、`herdr tab` をサブコマンドなしで実行して書式を確認する。素の `herdr` は TUI を起動するので実行しない。作成系コマンド（`tab create` 等）を引数なしで試さない。
3. 詳細な挙動（状態の意味、ID の扱い、`--machine` など）が必要なら `herdr --skill` を読む。

## スクリプトの場所

`<skill_dir>` はこの SKILL.md があるディレクトリ。どの AI ツールのスキルディレクトリから読み込まれたかに合わせて解決する（例: `~/.claude/skills/herdr-workers`、`~/.codex/skills/herdr-workers`）。

## 実行ディレクトリ（run dir）

1回のオーケストレーション（または単発委任）ごとに、作業ファイル置き場を作る。Vault やリポジトリの中には置かない。

```sh
RUN_DIR="${TMPDIR:-/tmp}/herdr-orch/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
```

`$RUN_DIR/manifest.jsonl` に、このスキルで作ったタブ・ペイン・エージェント名を記録する（スクリプトが追記する）。後片付けはこの記録だけを対象にする。

## 1. ワーカーを起動する

```sh
sh <skill_dir>/scripts/spawn-worker.sh \
  --run-dir "$RUN_DIR" --name <worker-name> --kind <kind> \
  [--cwd <dir>] [--tab <tab_id>] [--direction right|down] [-- <agent-args...>]
```

- 出力（JSON 1行）: `{"name":..., "kind":..., "pane_id":..., "tab_id":..., "created_tab":bool, "ready":bool}`。起動に失敗しても、作ったペイン・タブの ID は出力する。
- 終了コード: `0` 入力受付可、`3` 起動時のダイアログで停止（`ready:false`、名前は使える）、`1` その他の失敗、`2` 引数誤り。
- `--tab` 省略時は、呼び出し元と同じワークスペースに専用タブ（ラベル `workers`）を `--no-focus` で作り、そのルートペインで起動する。2体目以降は `--tab <1体目の tab_id>` を渡すと、そのタブのペインを分割して並べる。
- `--cwd` 省略時は呼び出し元の `$PWD`。
- `<worker-name>` は `[a-z][a-z0-9_-]{0,31}` で、稼働中エージェント間で一意にする（例: `impl-api`, `review-codex`）。
- モデル指定はエージェント本体の引数として `--` の後ろに渡す。各 CLI のフラグは `<cli> --help` で確認する（例: `-- --model <model>`、`-- -m <model>`）。
- 終了コード `3` のときは `herdr agent read <name> --source visible` で画面を見る。フォルダの信頼確認や新しい MCP サーバの利用確認などが出やすい。権限を与える選択肢はユーザーに確認してから選ぶ。回答後は `herdr agent wait <name>` で `idle` を確認してから指示を渡す（ダイアログを閉じた直後は `blocked` が残ることがある）。
- 1体目が失敗しても、出力の `tab_id` を2体目以降の `--tab` に渡す。

ユーザーの作業タブを分割してワーカーを並べたいと明示された場合だけ、`--tab "$HERDR_TAB_ID"` を渡す。

## 2. 指示を渡す

```sh
herdr agent prompt <name> "<prompt>" --wait --timeout <ms>
```

- プロンプトは、ワーカーが会話履歴を持たない前提で自己完結させる（目的、対象ファイル、完了条件、やってはいけないこと、報告形式）。
- 長いプロンプトは `$RUN_DIR/<name>.prompt.md` に書き、「`<path>` を読んで指示に従って」と短く渡す。macOS では1行入力の長さ上限で拒否されることがある。
- `--wait` は最初に落ち着いた状態（`idle` / `done` / `blocked`）まで待つ。並列で走らせるときは各ワーカーに `--wait` なしで投げてから、手順3でまとめて待つ。
- `agent_blocked` / `agent_prompt_stalled` / `timeout` が返っても、届いていないとは限らない。再送する前に必ず `herdr agent get` と `herdr agent read` で状態を見る。

## 3. 待つ

```sh
herdr agent wait <name> --timeout <ms>
```

- 複数ワーカーは1体ずつ順に `wait` すればよい（先に終わったものは即座に返る）。
- `blocked` が返ったら画面を読み、何を求められているか確認する。ファイル書き込みやコマンド実行の承認など、ユーザーの判断が要るものは勝手に承認しない。
- `unknown` は完了の証拠ではない。`agent read` で中身を確かめる。

## 4. 結果を読む

```sh
herdr agent read <name> --source recent-unwrapped --lines 200
```

- 応答が長くて読み切れないときだけ、追加で「回答を `$RUN_DIR/<name>.result.md` に Markdown で書き出し、パスだけ返して」と頼み、そのファイルを Read する。最初の指示からファイル出力を求めない。
- ワーカーの報告は主張にすぎない。「テストが通った」「バグを見つけた」などは、差分・テスト出力・該当コードなど一次情報で確認してから採用する。

## 5. 追加指示・中断

- 追加の指示は同じ `<name>` に `agent prompt` する（文脈が続く）。
- 中断: `herdr agent send-keys <name> esc`、強制停止は `ctrl+c`。
- ペインの生の操作（テストやサーバの実行）は `herdr pane run` / `herdr pane wait-output` を使う。エージェントの状態判定が要らない処理にエージェントを立てない。

## 6. 後片付け

```sh
sh <skill_dir>/scripts/cleanup-workers.sh --run-dir "$RUN_DIR" [--keep <name>...]
```

- manifest に記録されたペイン・タブだけを閉じる。ユーザーや他のクライアントが作ったペイン・タブは閉じない。
- 閉じる前にワーカーの結果を回収し終えていることを確認する。ユーザーが画面で確認したいと言ったワーカーは `--keep` で残す。
- worktree を作った場合、その削除（`herdr worktree remove`）は未コミットの変更を失うおそれがあるため、ユーザーに確認してから行う。

## 禁止事項

- `herdr server stop`、Herdr 本体プロセスの kill、`workspace close --group` を実行しない。
- 自分が作っていないワークスペース・タブ・ペインを閉じない。
- `--trust-repository` をエラー回避のために付けない（ユーザーがリポジトリを確認したときだけ）。
- `git worktree add` / `herdr worktree create` はユーザーの明示的な許可を得てから実行する。
