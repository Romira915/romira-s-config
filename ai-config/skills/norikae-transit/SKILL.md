---
name: norikae-transit
description: 日本の鉄道・バスの乗換案内・時刻表検証。Yahoo!乗換案内（transit.yahoo.co.jp）をスクレイピングする norikae パッケージで経路・時刻・運賃・乗換を確認する。Google Maps API の transit モードが日本非対応の代替として、電車ルート案内・旅行プランの時刻検証に使う。
allowed-tools:
  - Bash(python3:*)
  - Bash(pip:*)
---

# norikae-transit

日本の鉄道・バスの乗換案内を検索・検証する。Google Maps API の transit モードは日本非対応のため、日本の電車・バスの経路が必要なときはこのスキルを使う。

## 背景（なぜこれを使うか）

- Google Maps API（MCP `@cablate/mcp-google-map` 等）の transit モードは**日本で使えない**（日本は Google Transit パートナー非参加のため "No transit route found" になる）
- Playwright で Google Maps Web 版をスクレイピングすれば成功するが低速・不安定
- norikae は Yahoo!乗換案内の検索結果を HTTP GET で取得しパースする軽量な非公式 Python パッケージ（PyPI・MIT）

## 前提

- Python 3.10+ / venv（OS に依存しない。Linux / macOS / Windows すべてで動作）
- 実行は `python -m norikae` 形式に統一する（venv 内の実行ファイルパスに依存しないポータブルな呼び出し）
- 標準のインストール先: `~/.local/share/norikae-venv`（未インストールなら下記セットアップを実行）

## セットアップ（初回のみ）

バージョンは動作検証済みの `1.0.0` に固定する:

```bash
python3 -m venv ~/.local/share/norikae-venv
~/.local/share/norikae-venv/bin/pip install "norikae==1.0.0"
```

> Windows の場合、venv の実行ファイルは `Scripts\` 配下になる（`~\.local\share\norikae-venv\Scripts\python.exe -m pip install "norikae==1.0.0"`）。以降の実行例は `<venv-python>` を自分の環境の venv python パスに読み替える。

## 実行

venv 内の python を `-m` で呼ぶ（パッケージのバイナリ名に依存しない）:

```bash
<venv-python> -m norikae --from <出発> --to <到着> [オプション]
```

例（Linux / macOS）:

```bash
~/.local/share/norikae-venv/bin/python -m norikae --from 四ツ谷 --to 新高島
```

> Python が PATH にあり、norikae がインストール済みの環境なら `python -m norikae ...` だけで動く。

### 主なオプション

| オプション | 説明 |
|---|---|
| `--at HH:MM` | 出発時刻を指定（当日として解釈。過ぎていれば翌日） |
| `--minutes N` | 今から N 分後 |
| `--via <駅>` | 経由駅（複数指定可） |
| `--max-summary N` | ルート候補の表示数（既定5） |
| `--max-detail N` | 詳細表示するルート数（既定3、0 で一覧のみ） |

### 出力の見方

- 一覧行: 発時刻 → 着時刻、所要、運賃、乗換回数
- 詳細: 列車名・番号、乗り場（番線）、乗車位置、途中停車駅と時刻、区間運賃

## 検証ワークフロー

1. プランの区間を 1 つずつ `--at` で指定して検証する
2. 乗換の成立は分割検索で確認する: 前区間の着駅 → 次の区間の発駅（例: 東京06:16→金沢 と 金沢09:05→加賀温泉 を別々に検索し、乗換時間の成立を確認）
3. 検索エンジンが推奨するルートがプランと違う場合、推奨はアルゴリズムの選好（乗換回数・時間の短さ）であり、プランが不可能とは限らない。分割検索で各レグの実在と乗換時間の成立を確認する
4. 将来日（数ヶ月先）のダイヤは参考扱い。検証結果をノートに記録するときは検証日を添える（例: 2026/8/4 の Yahoo!乗換案内で確認）

## 注意事項

- **非公式スクレイピング**: Yahoo!路線情報の利用規約上、転載・保存・大量アクセスは禁止。個人利用・軽度の確認用途に限る
- **未収録のバスあり**: 地域コミュニティバスは検索できない（例: 加賀市コミュニティバス「キャンバス」）。大手バス（北陸鉄道バス等）は収録される
- **施設名の曖昧さ**: 同名の他県施設に誤解釈される場合がある（例: 「富来」→ 大分県の富来神社）。その場合は「道の駅とぎ海街道」のような正式施設名で検索する
- **徒歩表示**: バスが未収録の区間は徒歩が表示される（例: 加賀温泉→粟津 徒歩46分）。徒歩が現実的でない場合は公式バス時刻表を確認する
- ダイヤ改正で時刻・列車番号は変わる。重要プランは直前にも再確認する

## 実例

```bash
# 現在時刻で東京→大阪
~/.local/share/norikae-venv/bin/python -m norikae --from 東京 --to 大阪

# 明日 9:30 発で金沢→和倉温泉、一覧のみ
~/.local/share/norikae-venv/bin/python -m norikae --from 金沢 --to 和倉温泉 --at 9:30 --max-summary 3 --max-detail 0

# 経由指定
~/.local/share/norikae-venv/bin/python -m norikae --from 東京 --to 加賀温泉 --via 金沢
```

## 他の環境への配置方法

このスキルは `SKILL.md` 1 ファイルのみで完結する。受け取り側の環境に合わせて配置する:

| 環境 | 配置先 |
|---|---|
| Claude Code（ユーザー） | `~/.claude/skills/norikae-transit/` |
| opencode（ユーザー） | `~/.config/opencode/skills/norikae-transit/` |
| プロジェクトローカル | `<repo>/.claude/skills/norikae-transit/` または `<repo>/.opencode/skills/norikae-transit/` |

配置後、初回セッションで「セットアップ」節のコマンドを 1 回実行すれば使えるようになる。個人・所属に依存する設定値は含まれていないため、そのまま配布してよい。