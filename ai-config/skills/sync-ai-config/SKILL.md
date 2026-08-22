---
name: sync-ai-config
description: Claude Code / Codex の生きた設定ファイル（settings.json, config.toml）からアプリが書き込むローカル生成状態を除いた「意味のある設定差分」だけを抽出し、ワーキングツリーを変更せずgit indexへステージする。設定ファイルの差分をコミットしたいときに使う。
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git show:*), Bash(git hash-object:*), Bash(git update-index:*), Bash(git commit:*), Bash(jq:*), Bash(python3:*), Bash(mktemp:*), Read
---

# AI設定ファイル同期スキル

## 背景

`ai-config/claude-code/settings.json` と `ai-config/codex/config.toml` は、それぞれ `~/.claude/settings.json` / `~/.codex/config.toml` へのシンボリックリンク先で、アプリが直接読み書きする**生きたファイル**。Claude Code / Codex を使うたびに、アプリが書き込むローカル生成状態（プロジェクトの信頼状態、hookの信頼ハッシュ、marketplaceのタイムスタンプ、インストール済みアプリの絶対パスを含むMCPサーバー登録、キー順の入れ替わり等）が乗り、さらにモデル選択・推論強度・サービス tier のような個人の実行時設定も頻繁に変わるため、意味のある設定変更との判別が毎回手間になる。

このスキルは、既知のノイズを機械的に除いた「クリーン版」を作り、`git show HEAD:<path>` と比較して**本当に意味のある差分だけ**を可視化し、ステージまで行う。**ワーキングツリーの実ファイルは一切書き換えない**（アプリが使い続けられる状態を壊さない）。

## 対象ファイル

- `ai-config/codex/config.toml` (TOML)
- `ai-config/claude-code/settings.json` (JSON)

## 手順

### 1. config.toml の意味のある差分を抽出

1. 同ディレクトリの `filter_toml.py` で、ワーキングツリーと HEAD の両方からクリーン版を一時ファイルに出力する:
   ```sh
   current_tmp=$(mktemp)
   head_tmp=$(mktemp)
   python3 <スキルディレクトリ>/filter_toml.py ai-config/codex/config.toml > "$current_tmp"
   git show HEAD:ai-config/codex/config.toml | python3 <スキルディレクトリ>/filter_toml.py - > "$head_tmp"
   ```
2. 両方のクリーン版を比較する:
   ```sh
   diff "$head_tmp" "$current_tmp"
   ```
   HEAD に過去から残っている除外対象キーを削除差分として誤検出しないため、HEAD 側も必ず同じフィルタを通す
3. 差分がなければ「config.toml: 意味のある変更なし」とだけ報告して終了。ワーキングツリーはそのままにする
4. 差分があれば、その内容をユーザーに提示する。`filter_toml.py` の除外ルール（下記）に載っていないキー・テーブルが増減している場合は、それが除外すべきローカル状態なのか意図した設定変更なのかをユーザーに確認してから進める（自動で握りつぶさない）。一方、モデル選択・推論強度・サービス tier は既知の環境依存設定として自動除外する
5. 承認された内容でステージする（ワーキングツリーには触れない）:
   ```sh
   sha=$(git hash-object -w "$current_tmp")
   git update-index --cacheinfo 100644,$sha,ai-config/codex/config.toml
   ```
6. `git diff --cached HEAD -- ai-config/codex/config.toml` でステージ内容が意図通りか最終確認する

### 2. settings.json の意味のある差分を抽出

1. ワーキングツリーとHEADをそれぞれ `jq -S .`（キーを再帰的にソートして正規化）で比較する:
   ```sh
   diff <(git show HEAD:ai-config/claude-code/settings.json | jq -S .) <(jq -S . ai-config/claude-code/settings.json)
   ```
   キー順序だけの違いはここで吸収され、実質的な値の変更だけが差分として残る
2. 差分がなければ「settings.json: 意味のある変更なし」とだけ報告して終了
3. 差分があれば内容をユーザーに提示する
4. 承認されたら、正規化後のJSON自体をステージする（今後はソート済みキー順が正になるため、キー順だけのノイズは以後発生しなくなる）:
   ```sh
   tmp=$(mktemp)
   jq -S . ai-config/claude-code/settings.json > "$tmp"
   sha=$(git hash-object -w "$tmp")
   git update-index --cacheinfo 100644,$sha,ai-config/claude-code/settings.json
   ```

### 3. コミット

- ステージ内容を要約し、Why（なぜその設定に変えたか）を書いたコミットメッセージ案を提示してユーザーの確認を得てから `git commit` する
- push はこのスキルの範囲外。必要ならユーザーに別途指示を仰ぐ

## ノイズ除外ルール（config.toml, `filter_toml.py` にハードコード）

- ルートレベルキー: `notify`, `model`, `model_reasoning_effort`, `plan_mode_reasoning_effort`, `service_tier`
- テーブル全体除外: `tui.model_availability_nux`, `marketplaces.openai-bundled`, `marketplaces.openai-primary-runtime`, `mcp_servers.node_repl`（子テーブル含む）, `mcp_servers.computer-use`, `shell_environment_policy.set`, `hooks.state`（子テーブル含む）, `desktop`, `projects.*`
- 行単位除外（残すテーブル内でも）: `last_updated`, `last_revision`

このルールは `config.toml` 冒頭のコメントと、モデル選択等の実行時設定を共有管理しない運用方針をコード化したもの。ユーザーから「この差分は管理不要／ローカル状態」と指摘された場合は、その場のステージングだけで終わらせず、`filter_toml.py` の `EXCLUDE_*` とこの一覧を更新し、同じ差分を再現する回帰チェックを追加する。新しいノイズキー・テーブルが増えた場合も同じ手順で更新する。

モデル設定を明示的にリポジトリ管理したい依頼があった場合だけ、除外ルールの対象から一時的に外すか、ユーザー確認済みの差分を個別にステージする。

## 注意事項

- ワーキングツリーの `config.toml` / `settings.json` は生きた設定ファイルなので、`git checkout` 等で書き戻したり、フィルタ結果で上書きしたりしない
- 除外ルールに当てはまらない未知の差分は握りつぶさず、必ずユーザーに提示して判断を仰ぐ
- 対象ファイルが増えたら、このスキルに処理を追加する
