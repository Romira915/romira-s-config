---
name: newrelic-dashboard
description: New Relic のダッシュボード JSON を AI が設計・生成する。New Relic MCP で entity / NRQL を調べ、インポート可能なダッシュボード JSON を組み立て、UI の「Import dashboard」で貼り付ける前提の成果物を作る。ダッシュボード作成・改修・チャート追加の依頼に使う。
allowed-tools:
  - Read
  - Write
  - mcp__newrelic__list_available_new_relic_accounts
  - mcp__newrelic__get_entity
  - mcp__newrelic__list_related_entities
  - mcp__newrelic__search_entity_with_tag
  - mcp__newrelic__list_dashboards
  - mcp__newrelic__get_dashboard
  - mcp__newrelic__execute_nrql_query
  - mcp__newrelic__natural_language_to_nrql_query
  - mcp__newrelic__convert_time_period_to_epoch_ms
---

# newrelic-dashboard

New Relic のダッシュボードを AI が設計・生成するスキル。New Relic MCP で実データ（アカウント・entity・NRQL の妥当性）を確認しながら、**UI の「Import dashboard」に貼り付けられるダッシュボード JSON** を組み立てる。

出力の最終形は「そのままインポートできる JSON ファイル」。人手の作業は New Relic UI での貼り付けだけになる粒度にする。

## 個人情報・固有値の読み込み（必須・最初に実行）

このリポジトリは public。アカウント ID や社内 entity 名などの固有値はスキル本文に直書きしない。ランタイムで `~/.claude/personal.md` の `newrelic-dashboard` セクションを Read し、以下を取得する:

- `<newrelic_account_id>` — 既定の New Relic アカウント ID（数値）
- （任意）よく使う entity 名・GUID・NRQL イベント種別などのメモ

personal.md に該当セクションが無い場合は、`list_available_new_relic_accounts`（下記）で候補を出してユーザーに確認する。

## 参照ファイル

- **ダッシュボード JSON スキーマ / 可視化タイプ一覧 / rawConfiguration / NerdGraph エクスポート**: 同ディレクトリの `REFERENCE.md` を Read
- **インポート用スターター JSON（雛形）とレイアウトグリッドの決め方**: 同ディレクトリの `TEMPLATE.md` を Read

## 前提の理解（重要）

- ダッシュボードの実体は **JSON**。UI の `...` メニュー → `Copy JSON` でエクスポート、`Import dashboard` でインポートできる（[docs](https://docs.newrelic.com/docs/query-your-data/explore-query-data/dashboards/dashboards-charts-import-export-data/)）。
- 階層は **dashboard → pages[] → widgets[]**。widget は `visualization.id` + `rawConfiguration`（`nrqlQueries` 等）+ `layout`（グリッド位置）で決まる。
- **New Relic MCP の `get_dashboard` は `layout` を返さない簡易ビュー**。インポート用 JSON を作るには `layout` を自分で付与する必要がある。既存 JSON を丸ごと欲しいときは MCP ではなく UI の `Copy JSON` を使うようユーザーに促す。
- **MCP にはダッシュボード作成の書き込みツールが無い**。したがってこのスキルの成果物は「JSON を生成 → ユーザーが UI でインポート」で完結させる（NerdGraph `dashboardCreate` を使える環境なら REFERENCE.md の代替手順を案内）。

## 手順

### Step 1: 要件ヒアリング

以下を確認する（不明なら質問する）:

1. **目的**: 何を監視したいか（例: バッチのエラー監視、API のレイテンシ、特定機能のログ追跡）
2. **対象 entity / サービス**: アプリ名・ホスト名・サービス名など
3. **アカウント**: personal.md の `<newrelic_account_id>` を既定にする。複数候補があれば `list_available_new_relic_accounts` で提示して選ばせる
4. **見たい指標と粒度**: 時系列/集計/生ログ、FACET 軸、時間範囲

### Step 2: entity と NRQL を実データで確認

**推測でクエリを書かない。** MCP で実在を確認してから JSON に落とす。

1. **entity 特定**: `get_entity`（`name_pattern` / `domains` / `types`）または `search_entity_with_tag` で対象 entity の GUID・正式名・accountId を取得。関連 entity は `list_related_entities`。
2. **既存ダッシュボードの流用検討**: `list_dashboards` で似たものを探し、あれば `get_dashboard` で構成（visualization.id・NRQL の書き方・FACET 軸）を参考にする。社内の既存ダッシュボードのクエリ慣習（`entity.guid` / `hostname` / `log_path` での絞り込み等）に合わせると馴染む。
3. **NRQL の妥当性確認**: 組み立てた NRQL を `execute_nrql_query` で実行し、カラム・結果が期待どおりか確認する。自信が無いときは `natural_language_to_nrql_query` で叩き台を得てから調整。
4. **時間範囲**: 絶対時刻が要るときは `convert_time_period_to_epoch_ms` で epoch ms に変換（NRQL の `SINCE ... UNTIL ...` に使う）。基本は `SINCE 30 minutes ago` 等の相対指定を優先。

### Step 3: ダッシュボード JSON を組み立てる

`TEMPLATE.md` の雛形をベースに、`REFERENCE.md` の可視化タイプと rawConfiguration を見ながら widget を並べる。

- **1 widget = 1 目的**。時系列は `viz.line`/`viz.area`、内訳は `viz.bar`/`viz.pie`、単一 KPI は `viz.billboard`（閾値は `thresholds`）、生ログは `logger.log-table-widget`、見出し/説明は `viz.markdown`。
- **`nrqlQueries[].accountIds` は必ず対象アカウント ID を入れる**（`[<newrelic_account_id>]`）。
- **`layout` を全 widget に付ける**（12 カラムグリッド。詰め方は `TEMPLATE.md`）。
- タイトル・ページ名は日本語可。目的が一目で分かる名前にする。
- 生成した JSON は `nr-dashboard-<用途>.json` などのファイルに `Write` で書き出す。

### Step 4: 検証

- JSON として妥当か（`python3 -m json.tool` 等でパースできるか）を確認。
- 各 widget の NRQL を `execute_nrql_query` で最終確認（Step 2 から変更した場合は必ず）。
- グリッドの重なり・はみ出し（`column + width - 1 <= 12`）が無いか確認。

### Step 5: ユーザーへの受け渡し

1. 生成した JSON ファイルのパスを提示。
2. **インポート手順を案内**: New Relic → All capabilities → Dashboards → 右上 `Import dashboard` → JSON を貼り付け → アカウントと権限を選択 → Save。
3. インポートは副作用があるためユーザーが手動で行う（スキルからは実行しない）。

## 注意事項

- **public リポジトリ規約**: アカウント ID・社内 entity 名・ホスト名などの固有値はスキル本文・サンプルに直書きしない。実値は personal.md から Read し、サンプル・雛形では `<newrelic_account_id>` 等のプレースホルダで書く。
- **推測でクエリを確定しない**: entity GUID も NRQL も MCP で実在・結果を確認してから JSON に入れる。
- **`get_dashboard` の JSON はそのままインポートできない**（`layout` 欠落）。既存を複製したいなら UI の `Copy JSON` をユーザーに使ってもらう。
- **エクスポート/スナップショット画像**（PDF/PNG/CSV、NerdGraph `dashboardCreateSnapshotUrl` 等）が必要な場合は `REFERENCE.md` の「エクスポート」節を参照。スナップショット URL は認証不要で公開・3 か月で失効する点に注意。
- 破壊的操作（既存ダッシュボードの上書き・削除）はしない。改修依頼でも「新規インポート用 JSON」を作り、反映はユーザーに委ねる。
