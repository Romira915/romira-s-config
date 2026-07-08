# REFERENCE — New Relic ダッシュボード JSON スキーマ

`newrelic-dashboard` スキルの参照資料。ダッシュボード JSON の構造・可視化タイプ・`rawConfiguration` のオプション・NerdGraph でのエクスポート/作成をまとめる。

サンプル内の `<newrelic_account_id>` は personal.md から取得した実値に置換して使う。

---

## 1. ダッシュボード JSON の階層

インポート用の JSON は次の入れ子構造:

```
dashboard
├── name                 (string) ダッシュボード名
├── description          (string|null)
├── permissions          (string) "PUBLIC_READ_WRITE" | "PUBLIC_READ_ONLY" | "PRIVATE"
├── pages[]              1 ページ以上
│   ├── name             (string) ページ名（タブ名）
│   ├── description       (string|null)
│   ├── widgets[]        ページ上のチャート群
│   │   ├── title        (string) チャートタイトル
│   │   ├── layout       {row, column, width, height}  ← グリッド位置（必須）
│   │   ├── visualization {id: "<viz id>"}             ← チャート種別
│   │   ├── rawConfiguration {...}                     ← クエリ・表示設定
│   │   └── linkedEntityGuids (array|null)             ← facet クリック連携（通常 null）
│   └── variables[]      (任意) テンプレート変数
└── variables[]          （pages と同階層に置く実装もある。基本は使わないなら省略可）
```

### UI インポート時に不要なフィールド

`get_dashboard`（MCP）や `Copy JSON`（UI）が返す `id` / `guid` / `accountId` / `createdAt` / `updatedAt` / `owner` / `permalink` などは **新規インポートでは付けない**（New Relic が採番する）。付いていてもインポーターが無視するが、雛形はクリーンにしておく。

### MCP `get_dashboard` の制約

MCP の `get_dashboard` は widget の `layout` を返さない簡易ビュー。**そのままではインポートできない**。既存ダッシュボードを丸ごと複製したい場合は UI の `...` → `Copy JSON` を使う。MCP は「既存構成の参照（visualization.id・NRQL の書き方の確認）」用途に留める。

---

## 2. widget の最小形

```json
{
  "title": "スループット",
  "layout": { "row": 1, "column": 1, "width": 4, "height": 3 },
  "visualization": { "id": "viz.line" },
  "rawConfiguration": {
    "nrqlQueries": [
      {
        "accountIds": [<newrelic_account_id>],
        "query": "SELECT count(*) FROM Transaction TIMESERIES"
      }
    ]
  }
}
```

- `nrqlQueries[].accountIds` は配列。対象アカウント ID を必ず入れる。
- `layout` は 12 カラムグリッド（`TEMPLATE.md` 参照）。

---

## 3. 可視化タイプ一覧（visualization.id）

| id | 用途 | 主な NRQL の形 |
|---|---|---|
| `viz.line` | 時系列（折れ線） | `... TIMESERIES` |
| `viz.area` | 時系列（塗り） | `... TIMESERIES` |
| `viz.stacked-bar` | 積み上げ時系列 | `... FACET x TIMESERIES` |
| `viz.bar` | カテゴリ別（横棒） | `... FACET x` |
| `viz.pie` | 構成比 | `... FACET x` |
| `viz.billboard` | 単一 KPI（大きな数値、閾値色分け可） | 集計 1 値（`SELECT count(*) ...`） |
| `viz.table` | 表 | `... FACET ...` / 複数カラム SELECT |
| `viz.bullet` | 目標値に対する達成度 | 集計 1 値（`limit` 指定） |
| `viz.histogram` | 分布 | `histogram(...)` |
| `viz.heatmap` | ヒートマップ | `histogram(...) FACET ...` |
| `viz.funnel` | ファネル | `funnel(...)` |
| `viz.json` | 生 JSON 表示 | 任意 |
| `viz.markdown` | 見出し・説明文（クエリ不要） | — (`text` を使う) |
| `logger.log-table-widget` | ログ生表示（Logs UI 相当） | `FROM Log SELECT ...` |

社内ではログ監視で `logger.log-table-widget` と `viz.line`（`FACET` + `TIMESERIES`）の組み合わせがよく使われる。

---

## 4. rawConfiguration の主なオプション

widget 種別ごとに使うキー。使わないキーは省略してよい（New Relic が既定を補完する）。

### 共通（時系列・チャート系）

```json
"rawConfiguration": {
  "nrqlQueries": [{ "accountIds": [<newrelic_account_id>], "query": "..." }],
  "platformOptions": { "ignoreTimeRange": false },
  "legend": { "enabled": true },
  "facet": { "showOtherSeries": false },
  "yAxisLeft": { "zero": true },
  "yAxisRight": { "zero": true },
  "thresholds": { "isLabelVisible": true },
  "markers": {
    "displayedTypes": {
      "deployments": true,
      "relatedDeployments": true,
      "criticalViolations": false,
      "warningViolations": false
    }
  }
}
```

- `platformOptions.ignoreTimeRange`: `true` にするとページ上部の時間ピッカーを無視し、NRQL 内の `SINCE/UNTIL` を優先。
- `markers`: デプロイやアラート違反のマーカー表示。

### `viz.billboard`（KPI + 閾値色分け）

```json
"rawConfiguration": {
  "nrqlQueries": [{ "accountIds": [<newrelic_account_id>],
    "query": "SELECT percentage(count(*), WHERE error IS true) AS 'Error rate' FROM Transaction SINCE 1 hour ago" }],
  "thresholds": [
    { "alertSeverity": "WARNING", "value": 1 },
    { "alertSeverity": "CRITICAL", "value": 5 }
  ]
}
```

`alertSeverity` は `SUCCESS` / `WARNING` / `CRITICAL`。`value` を超えると色が変わる。

### `viz.table`

```json
"rawConfiguration": {
  "nrqlQueries": [{ "accountIds": [<newrelic_account_id>], "query": "FROM Transaction SELECT count(*), average(duration) FACET name" }],
  "facet": { "showOtherSeries": false }
}
```

### `viz.markdown`（見出し・注記。クエリ不要）

```json
{
  "title": "",
  "layout": { "row": 1, "column": 1, "width": 12, "height": 1 },
  "visualization": { "id": "viz.markdown" },
  "rawConfiguration": { "text": "## バッチ監視\n<サービス名> のエラー・実行状況" }
}
```

### `logger.log-table-widget`（ログ生表示）

```json
"rawConfiguration": {
  "nrqlQueries": [{ "accountIds": [<newrelic_account_id>],
    "query": "FROM Log SELECT timestamp, message, level WHERE `entity.guid` = '<APM_ENTITY_GUID>' SINCE 30 minutes ago" }]
}
```

---

## 5. テンプレート変数（任意）

ページ上部でフィルタを切り替えたいとき。`pages` と同階層（dashboard 直下）の `variables[]` に定義し、NRQL 内で `{{変数名}}` で参照する。

```json
"variables": [
  {
    "name": "hostname",
    "title": "Hostname",
    "type": "NRQL",
    "nrqlQuery": {
      "accountIds": [<newrelic_account_id>],
      "query": "FROM Log SELECT uniques(hostname) SINCE 1 day ago"
    },
    "replacementStrategy": "STRING",
    "isMultiSelection": true,
    "defaultValues": [{ "value": { "string": "*" } }]
  }
]
```

- `type`: `NRQL`（クエリで候補生成）/ `ENUM`（固定リスト）/ `STRING`（自由入力）。
- NRQL 側では `WHERE hostname = {{hostname}}` のように使う。
- 使わないなら `variables` ごと省略。

---

## 6. エクスポート（PDF / PNG / CSV / スナップショット）

（[docs](https://docs.newrelic.com/docs/query-your-data/explore-query-data/dashboards/dashboards-charts-import-export-data/) 準拠）

### UI から

- **PDF**: ダッシュボード右上 `...` → `Export dashboard as PDF`（カスタムビジュアライゼーションは非対応）。
- **CSV**: table チャート右上 `...` → `Export as CSV`（UTC 固定、`average()` 等の集計関数・`COMPARE WITH`・クロスアカウントは非対応）。

### NerdGraph API から（UI に無いオプション: カスタムサイズ・変数上書き・フィルタ）

**ダッシュボード全体を PDF/PNG スナップショット URL 化**（`guid` は **ページ GUID**。ダッシュボード GUID ではない）:

```graphql
mutation {
  dashboardCreateSnapshotUrl(
    guid: "<DASHBOARD_PAGE_GUID>"
    params: { format: PNG, display: { width: 1920, height: 1080 } }
  )
}
```

ページ GUID の探し方:

```graphql
{
  actor {
    entitySearch(query: "parentId = '<DASHBOARD_GUID>' AND tags.isDashboardPage = 'true'") {
      results { entities { guid name } }
    }
  }
}
```

**単一チャート画像**（widget はダッシュボード上に無くても、インラインで定義して画像化できる）:

```graphql
mutation {
  dashboardWidgetCreateSnapshotUrl(
    widget: {
      version: 1
      type: "declarative/widget"
      content: {
        type: "widget"
        props: { title: "Throughput" }
        content: {
          type: "visualization"
          id: "viz.line"
          props: {
            nrqlQueries: [{ accountIds: [<newrelic_account_id>], query: "SELECT count(*) FROM Transaction TIMESERIES" }]
            legend: { enabled: true }
          }
        }
      }
    }
  ) { url }
}
```

ダッシュボード JSON から `DeclarativeUiWidget` への対応:

| ダッシュボード JSON | DeclarativeUiWidget |
|---|---|
| `title` | `content.props.title` |
| `visualization.id` | `content.content.id` |
| `rawConfiguration.*` | `content.content.props.*`（同名） |
| `layout` / `id` / `linkedEntityGuids` | 含めない（スタンドアロン画像では不要） |

> **注意**: `dashboardCreateSnapshotUrl` / `dashboardWidgetCreateSnapshotUrl` が返す URL は **認証不要で公開・3 か月で失効**。共有は組織のデータポリシーに従うこと。旧 `staticChartUrl` は閾値・新チャート型に非対応なので新規では使わない。

### NerdGraph でダッシュボードを直接作成（インポートの代替）

UI 貼り付けの代わりに `dashboardCreate` mutation で作れる（要 NerdGraph 実行環境）。本スキルの New Relic MCP には書き込みツールが無いため、必要ならユーザーに NerdGraph（GraphQL Explorer / API キー）実行を案内する:

```graphql
mutation {
  dashboardCreate(
    accountId: <newrelic_account_id>
    dashboard: { name: "...", permissions: PUBLIC_READ_WRITE, pages: [ ... ] }
  ) {
    entityResult { guid }
    errors { description type }
  }
}
```

`dashboardCreate` の `pages/widgets` の構造は本 REFERENCE の JSON と同じ（`layout`・`visualization`・`rawConfiguration` を含める）。
