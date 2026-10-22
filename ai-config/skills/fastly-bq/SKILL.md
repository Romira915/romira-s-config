---
name: fastly-bq
description: Fastly access logs の BigQuery テーブル（テーブル FQN は personal.md から取得）のカラム定義・サンプル SQL を提示し、BigQuery MCP 等があれば dry run でスキャン量を確認したうえで実行する。Fastly ログを SQL で調査したいときに使う。
allowed-tools: Read
---

# fastly-bq

Fastly アクセスログの BigQuery テーブル情報を提示し、SQL を素早く組み立てる。実行手段があれば、スキャン量の条件を満たす範囲で実行まで行う。

## テーブル情報

BigQuery プロジェクト・データセット・テーブル名は個人/所属固有のためスキル内に直書きしない。ランタイムで `~/.claude/personal.md` の `fastly-bq` セクションを Read し、以下の値を取得する:

- `<project_id>`
- `<dataset>`
- `<table>`
- `<table_fqn>` = `` `<project_id>.<dataset>.<table>` ``
- `<user_id_mapping>`: `user_type` ごとに `user_id` がどの DB テーブル・列の値か

以降サンプル SQL では `<table_fqn>` プレースホルダで参照する。

### パーティション

`timestamp` カラム（TIMESTAMP 型、UTC 格納）で日次パーティション。
クエリ時は必ず `timestamp` で範囲を絞ること（フルスキャン防止）。

### タイムゾーン方針（JST 固定）

- **BigQuery の TIMESTAMP は UTC で格納される**
- 本スキルでは **指定・表示ともに JST (Asia/Tokyo)** で統一する
- 指定側: `TIMESTAMP("YYYY-MM-DD HH:MM:SS", "Asia/Tokyo")` または `TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo")`
- 表示側: `DATETIME(timestamp, "Asia/Tokyo") AS timestamp_jst` で JST の DATETIME に変換

### カラム一覧

| カラム名 | 型 | 説明 |
| --- | --- | --- |
| `timestamp` | TIMESTAMP | リクエスト日時（UTC 格納） |
| `client_ip` | STRING | クライアント IP |
| `geo_country` | STRING | 国コード |
| `geo_city` | STRING | 都市名 |
| `host` | STRING | リクエスト Host ヘッダ |
| `url` | STRING | リクエスト URL |
| `request_method` | STRING | HTTP メソッド |
| `request_protocol` | STRING | HTTP プロトコル |
| `request_referer` | STRING | Referer |
| `request_user_agent` | STRING | User-Agent |
| `request_cookie` | STRING | Cookie ヘッダ |
| `response_state` | STRING | Fastly レスポンス状態 |
| `response_status` | INTEGER | HTTP ステータスコード |
| `response_reason` | STRING | ステータス Reason |
| `response_body_size` | INTEGER | レスポンスボディサイズ (bytes) |
| `fastly_server` | STRING | Fastly サーバ |
| `fastly_is_edge` | BOOLEAN | エッジサーバか |
| `is_shield` | INTEGER | シールド経由フラグ |
| `x_cache` | STRING | キャッシュ状態 (HIT / MISS 等) |
| `geo_proxy_description` | STRING | Proxy 情報 |
| `user_type` | STRING | ユーザ種別 |
| `user_id` | STRING | ユーザ ID。対応する DB の列は `user_type` ごとに異なる（`<user_id_mapping>` 参照） |
| `client_class_bot` | BOOLEAN | bot 判定 |
| `tls_ja4` | STRING | JA4 フィンガープリント |

## 使い方

ユーザーが Fastly ログに関する調査・集計・SQL を求めたら、以下の手順で対応する。

1. **personal.md を Read して `<table_fqn>` を解決**
2. **テーブル名・必要なカラム・パーティション条件を簡潔に提示**
3. **ユーザー要望に合わせたサンプル SQL を提示**: 以下のテンプレートから用途に合ったものを選び、`<table_fqn>` を実値に置換して埋める
4. **フルスキャン防止**: 必ず `timestamp` で期間を絞る SQL にする
5. **タイムゾーンは JST 固定**: 条件指定も SELECT での表示も `Asia/Tokyo` を使う
6. **LIMIT**: 調査用クエリは `LIMIT 1000` など上限を付ける

### 実行手段

下記「スキャン量確認」の条件を満たせば、MCP 経由での実行を事前確認なしで行ってよい。実行手段と認証状況はツール・ユーザー環境によって異なるため、その場で使えるものを確認して選ぶ。

| 実行手段 | 例 | 使い方 |
| --- | --- | --- |
| BigQuery MCP（Claude Code） | Google 公式 BigQuery MCP のコネクタ（`mcp__<コネクタ名>__execute_sql_readonly`） | dry run は `dryRun: true` |
| BigQuery MCP（Codex） | Google 公式 BigQuery MCP を Codex のアプリとして追加したもの（`<アプリ名>.execute_sql_readonly`） | dry run は `dryRun: true` |
| BigQuery コネクタ（Codex 標準） | `bigquery.execute_sql_readonly` | dry run は `dryRun: true`。`maximumBytesBilled` も指定できる |
| `bq` CLI | `bq query --use_legacy_sql=false` | dry run は `--dry_run`。上限は `--maximum_bytes_billed`。認証（`gcloud auth login`）が必要 |

- ツール名は環境によって違う。固定の名前を前提にせず、利用可能なツールの一覧・定義から「SQL を実行でき、dry run 機能を持つ読み取り専用ツール」（名前が `execute_sql_readonly` で終わるもの等）を選ぶ
- 同じ環境に複数あるときは、対象プロジェクトに認証済みで dry run が使えるものを選ぶ。どれでも同じ条件で dry run と承認判断を行う
- **課金上限を指定できる手段では本実行時に指定する**: `maximumBytesBilled`（`bq` は `--maximum_bytes_billed`）があれば、dry run の値の 1.2 倍程度を上限に設定する。ただし承認なしで実行するクエリは 100GB を、承認済みのクエリは承認した量を超える値にしない。上限を超えるクエリは BigQuery 側で失敗し、課金されない。指定できない手段では dry run の確認だけで判断する
- 書き込み可能な実行ツールしかない場合は、SELECT 文だけを実行する
- **dry run 機能を持たない実行手段では本実行しない**。dry run できる別の手段（`bq --dry_run` 等）でスキャン量を確認できた場合だけ実行する
- MCP が未接続・再認証が必要・権限不足の場合は、その旨を報告して再接続を依頼する。勝手に別の手段（ブラウザ操作等）へ切り替えない
- 実行手段がなければ SQL を提示するだけにし、ユーザーが `bq query` や BigQuery コンソールで実行する

### 実行する場合のスキャン量確認（必須）

BigQuery はクエリが読む列 × パーティションのデータ量で課金されるため、実行前に必ずスキャン量を確認する。

1. **毎回 dry run する**: 本実行の前に、上記の実行手段の dry run 機能で `totalBytesProcessed` を取得する。SQL を変えたら dry run もやり直す
2. **100GB 以上は実行前に承認を得る**: dry run の結果が 100GB 以上なら実行せず、スキャン量・確認したい内容・軽い代替案（期間を短くする、読む列を減らす）をユーザーに示して承認を求める。100GB 未満ならスキャン量を報告したうえで実行してよい
3. **分割で基準をすり抜けない**: 同じ目的のクエリを期間などで分割して 1 本ずつ 100GB 未満にしても、合計が 100GB 以上なら承認を求める
4. **スキャン量を下げる手段を先に検討する**: スキャン量を減らせるのは `timestamp` の期間と SELECT・WHERE・GROUP BY で参照する列だけ。`LIMIT` や、`client_ip`・`user_id` などパーティション以外の列での絞り込みではスキャン量は減らない。`url` や `request_user_agent` のような長い文字列列は特に重い
5. **承認後も dry run と大きく違えば再確認する**: 承認時に示した量から SQL を変えてスキャン量が大きく増えた場合は、改めて承認を求める
6. **報告する**: 結果と一緒に、実行したクエリの課金スキャン量（`totalBytesBilled`）を報告する

## サンプル SQL テンプレート（JST 指定・JST 表示）

以下では `<table_fqn>` を personal.md から取得した実値に置換して使う。

### 1. 特定日のログを眺める（基本形）

```sql
SELECT
  DATETIME(timestamp, "Asia/Tokyo") AS timestamp_jst,
  host,
  url,
  request_method,
  response_status,
  client_ip,
  request_user_agent
FROM <table_fqn>
WHERE TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo") = TIMESTAMP("2026-04-23", "Asia/Tokyo")
ORDER BY timestamp DESC
LIMIT 1000;
```

### 2. 期間指定 + 特定 URL の調査

```sql
SELECT
  DATETIME(timestamp, "Asia/Tokyo") AS timestamp_jst,
  host,
  url,
  response_status,
  x_cache,
  response_body_size,
  client_ip
FROM <table_fqn>
WHERE timestamp BETWEEN TIMESTAMP("2026-04-23 00:00:00", "Asia/Tokyo")
                   AND TIMESTAMP("2026-04-23 23:59:59", "Asia/Tokyo")
  AND url LIKE "/path/prefix/%"
ORDER BY timestamp DESC
LIMIT 1000;
```

### 3. ステータスコード別件数（エラー集計）

```sql
SELECT
  response_status,
  COUNT(*) AS cnt
FROM <table_fqn>
WHERE TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo") = TIMESTAMP("2026-04-23", "Asia/Tokyo")
GROUP BY response_status
ORDER BY cnt DESC;
```

### 4. 5xx エラーを絞り込む

```sql
SELECT
  DATETIME(timestamp, "Asia/Tokyo") AS timestamp_jst,
  host,
  url,
  response_status,
  response_reason,
  client_ip,
  request_user_agent
FROM <table_fqn>
WHERE TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo") = TIMESTAMP("2026-04-23", "Asia/Tokyo")
  AND response_status >= 500
ORDER BY timestamp DESC
LIMIT 1000;
```

### 5. キャッシュヒット率

```sql
SELECT
  x_cache,
  COUNT(*) AS cnt
FROM <table_fqn>
WHERE TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo") = TIMESTAMP("2026-04-23", "Asia/Tokyo")
GROUP BY x_cache
ORDER BY cnt DESC;
```

### 6. bot を除外したユニークユーザ数

```sql
SELECT
  COUNT(DISTINCT user_id) AS unique_users
FROM <table_fqn>
WHERE TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo") = TIMESTAMP("2026-04-23", "Asia/Tokyo")
  AND client_class_bot = FALSE
  AND user_id IS NOT NULL
  AND user_id != "";
```

### 7. User-Agent 別アクセス数 TOP 20

```sql
SELECT
  request_user_agent,
  COUNT(*) AS cnt
FROM <table_fqn>
WHERE TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo") = TIMESTAMP("2026-04-23", "Asia/Tokyo")
GROUP BY request_user_agent
ORDER BY cnt DESC
LIMIT 20;
```

### 8. 特定 IP の直近アクセス調査

```sql
SELECT
  DATETIME(timestamp, "Asia/Tokyo") AS timestamp_jst,
  host,
  url,
  request_method,
  response_status,
  request_user_agent
FROM <table_fqn>
WHERE TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo") = TIMESTAMP("2026-04-23", "Asia/Tokyo")
  AND client_ip = "1.2.3.4"
ORDER BY timestamp DESC
LIMIT 1000;
```

### 9. JST の「時」別アクセス数（時間帯集計）

```sql
SELECT
  EXTRACT(HOUR FROM timestamp AT TIME ZONE "Asia/Tokyo") AS hour_jst,
  COUNT(*) AS cnt
FROM <table_fqn>
WHERE TIMESTAMP_TRUNC(timestamp, DAY, "Asia/Tokyo") = TIMESTAMP("2026-04-23", "Asia/Tokyo")
GROUP BY hour_jst
ORDER BY hour_jst;
```

## 注意事項

- **タイムゾーンは JST 固定**: 条件指定は `TIMESTAMP("...", "Asia/Tokyo")` / `TIMESTAMP_TRUNC(..., "Asia/Tokyo")`、表示は `DATETIME(timestamp, "Asia/Tokyo")`。UTC のまま書かない
- **必ず timestamp で期間を絞る**: パーティションキーを使わないとフルスキャンでコストが跳ねる
- **実行前に dry run し、100GB 以上は承認を得る**: 詳細は「実行する場合のスキャン量確認」
- **LIMIT を忘れない**: 調査クエリには原則 `LIMIT` を付ける
- **`user_id` を DB と突き合わせる前に対応列を確認する**: `user_id` は列名が同じでも、DB の主キーや同名の `user_id` 列の値とは限らない。`<user_id_mapping>` に記載された列で突き合わせる。記載のない `user_type` は、ID の値が一致することだけを根拠に対応列と断定せず、コード上の設定箇所やユーザーへの確認で対応列を確かめてから使う
- **PII の扱い**: `client_ip`, `user_id`, `request_cookie` などは個人情報を含む可能性があるため、出力・共有には注意する
- **日付は今日のものを使う**: CLAUDE.md の `currentDate` をデフォルトの調査対象日として使うと良い（ユーザー指定があればそれを優先）
