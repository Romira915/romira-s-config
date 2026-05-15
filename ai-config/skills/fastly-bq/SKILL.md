---
name: fastly-bq
description: Fastly access logs の BigQuery テーブル（テーブル FQN は personal.md から取得）のカラム定義・サンプル SQL を即座に提示する。Fastly ログを SQL で調査したいときに使う。
allowed-tools: Read
---

# fastly-bq

Fastly アクセスログの BigQuery テーブル情報を提示し、ユーザーが素早く SQL を書けるようにする。

## テーブル情報

BigQuery プロジェクト・データセット・テーブル名は個人/所属固有のためスキル内に直書きしない。ランタイムで `~/.claude/personal.md` の `fastly-bq` セクションを Read し、以下の値を取得する:

- `<project_id>`
- `<dataset>`
- `<table>`
- `<table_fqn>` = `` `<project_id>.<dataset>.<table>` ``

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
| `user_id` | STRING | ユーザ ID |
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

実行環境（`bq` CLI の有無・認証状況）はユーザー環境依存のため、スキル側では SQL を提示するだけで実行はしない（ユーザーが `bq query` や BigQuery コンソールで実行する）。

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
- **LIMIT を忘れない**: 調査クエリには原則 `LIMIT` を付ける
- **PII の扱い**: `client_ip`, `user_id`, `request_cookie` などは個人情報を含む可能性があるため、出力・共有には注意する
- **日付は今日のものを使う**: CLAUDE.md の `currentDate` をデフォルトの調査対象日として使うと良い（ユーザー指定があればそれを優先）
