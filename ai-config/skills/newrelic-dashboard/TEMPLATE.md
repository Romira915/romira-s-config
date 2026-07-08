# TEMPLATE — インポート用ダッシュボード JSON 雛形

`newrelic-dashboard` スキルで使うスターター JSON とレイアウトグリッドの決め方。
`<newrelic_account_id>` は personal.md から取得した実値に、NRQL・タイトルは要件に合わせて置換する。

---

## レイアウトグリッドの決め方（12 カラム）

- ページは横 **12 カラム**。`layout.column` は 1〜12、`width` は 1〜12。
- `column + width - 1 <= 12` を守る（はみ出し禁止）。
- `row` は 1 始まり。同じ `row` に複数 widget を横並びできる。`height` は行の高さ（目安 3）。
- 次の行は前の行の最大 `height` 分だけ `row` を進める。

よく使う配置:

| レイアウト | 各 widget の width / column |
|---|---|
| 全幅 1 枚 | width 12, column 1 |
| 半分 2 枚 | width 6 → column 1 / column 7 |
| 3 分割 | width 4 → column 1 / 5 / 9 |
| 4 分割（KPI 帯） | width 3 → column 1 / 4 / 7 / 10 |

例: 1 行目に billboard を 4 枚（KPI 帯）、2 行目に全幅の時系列、3 行目に全幅のログ表。

```
row1: [bb col1 w3][bb col4 w3][bb col7 w3][bb col10 w3]   height 3
row4: [line col1 w12]                                     height 3
row7: [log  col1 w12]                                     height 4
```

（`row` は前行の `height` を足して進める: 1 → 1+3=4 → 4+3=7）

---

## スターター JSON（KPI 帯 + 時系列 + ログ表）

そのまま `python3 -m json.tool` でパースできる。NRQL は要件に合わせて必ず差し替え、各 widget の NRQL は `execute_nrql_query` で確認してから確定する。

```json
{
  "name": "<用途> モニタリング",
  "description": null,
  "permissions": "PUBLIC_READ_WRITE",
  "pages": [
    {
      "name": "Overview",
      "description": null,
      "widgets": [
        {
          "title": "",
          "layout": { "row": 1, "column": 1, "width": 12, "height": 1 },
          "visualization": { "id": "viz.markdown" },
          "rawConfiguration": { "text": "## <用途> モニタリング\n対象: <entity 名>" }
        },
        {
          "title": "リクエスト数 (直近1h)",
          "layout": { "row": 2, "column": 1, "width": 3, "height": 3 },
          "visualization": { "id": "viz.billboard" },
          "rawConfiguration": {
            "nrqlQueries": [
              { "accountIds": [<newrelic_account_id>],
                "query": "SELECT count(*) FROM Transaction SINCE 1 hour ago" }
            ]
          }
        },
        {
          "title": "エラー率",
          "layout": { "row": 2, "column": 4, "width": 3, "height": 3 },
          "visualization": { "id": "viz.billboard" },
          "rawConfiguration": {
            "nrqlQueries": [
              { "accountIds": [<newrelic_account_id>],
                "query": "SELECT percentage(count(*), WHERE error IS true) AS 'Error rate' FROM Transaction SINCE 1 hour ago" }
            ],
            "thresholds": [
              { "alertSeverity": "WARNING", "value": 1 },
              { "alertSeverity": "CRITICAL", "value": 5 }
            ]
          }
        },
        {
          "title": "平均レスポンスタイム",
          "layout": { "row": 2, "column": 7, "width": 3, "height": 3 },
          "visualization": { "id": "viz.billboard" },
          "rawConfiguration": {
            "nrqlQueries": [
              { "accountIds": [<newrelic_account_id>],
                "query": "SELECT average(duration) FROM Transaction SINCE 1 hour ago" }
            ]
          }
        },
        {
          "title": "スループット (件/分)",
          "layout": { "row": 2, "column": 10, "width": 3, "height": 3 },
          "visualization": { "id": "viz.billboard" },
          "rawConfiguration": {
            "nrqlQueries": [
              { "accountIds": [<newrelic_account_id>],
                "query": "SELECT rate(count(*), 1 minute) FROM Transaction SINCE 1 hour ago" }
            ]
          }
        },
        {
          "title": "リクエスト数の推移",
          "layout": { "row": 5, "column": 1, "width": 12, "height": 3 },
          "visualization": { "id": "viz.line" },
          "rawConfiguration": {
            "nrqlQueries": [
              { "accountIds": [<newrelic_account_id>],
                "query": "SELECT count(*) FROM Transaction FACET name TIMESERIES" }
            ],
            "legend": { "enabled": true },
            "yAxisLeft": { "zero": true },
            "platformOptions": { "ignoreTimeRange": false }
          }
        },
        {
          "title": "エラーログ",
          "layout": { "row": 8, "column": 1, "width": 12, "height": 4 },
          "visualization": { "id": "logger.log-table-widget" },
          "rawConfiguration": {
            "nrqlQueries": [
              { "accountIds": [<newrelic_account_id>],
                "query": "FROM Log SELECT timestamp, message, level WHERE level = 'ERROR' SINCE 30 minutes ago" }
            ]
          }
        }
      ]
    }
  ]
}
```

---

## 最小 JSON（1 ページ 1 チャートだけ欲しいとき）

```json
{
  "name": "<用途>",
  "description": null,
  "permissions": "PUBLIC_READ_WRITE",
  "pages": [
    {
      "name": "<ページ名>",
      "description": null,
      "widgets": [
        {
          "title": "<チャート名>",
          "layout": { "row": 1, "column": 1, "width": 12, "height": 3 },
          "visualization": { "id": "viz.line" },
          "rawConfiguration": {
            "nrqlQueries": [
              { "accountIds": [<newrelic_account_id>], "query": "<NRQL> TIMESERIES" }
            ]
          }
        }
      ]
    }
  ]
}
```

---

## 生成後チェックリスト

- [ ] `python3 -m json.tool nr-dashboard-*.json` でパースできる
- [ ] 全 widget に `layout` があり、`column + width - 1 <= 12`
- [ ] 全 `nrqlQueries[].accountIds` に対象アカウント ID が入っている
- [ ] 各 NRQL を `execute_nrql_query` で実行し結果を確認した
- [ ] `id` / `guid` / `accountId` / `owner` などの採番系フィールドを入れていない
