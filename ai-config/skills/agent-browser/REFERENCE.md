# agent-browser コマンドリファレンス

`agent-browser` CLI で利用する主要コマンドと、認証・トラブルシューティングの詳細。SKILL.md から必要に応じて Read する。

## 主要コマンド

### ナビゲーション
| コマンド | 用途 |
| --- | --- |
| `open <url>` | ページ遷移 |
| `navigate back` / `navigate forward` | 戻る/進む |
| `reload` | リロード |
| `wait <ms>` | 固定時間待機 |
| `wait "<selector>"` | 要素出現待ち |

### ページ情報
| コマンド | 用途 |
| --- | --- |
| `snapshot -i -c` | インタラクティブ要素の木構造（compact） |
| `snapshot -i` | インタラクティブ要素の完全版 |
| `snapshot` | 全要素（使いすぎ注意） |
| `get text @eN` | 要素内テキスト |
| `get html @eN` | 要素HTML |
| `get value @eN` | input値 |
| `get attr @eN <name>` | 属性値 |
| `get url` / `get title` | ページURL/タイトル |

### 操作
| コマンド | 用途 |
| --- | --- |
| `click @eN` | クリック（`--new-tab` で新タブ） |
| `fill @eN "text"` | 既存値を消して入力 |
| `type @eN "text"` | 追記入力（clear なし） |
| `scroll down/up <px>` | スクロール |
| `drag @eA @eB` | ドラッグ |
| `upload @eN <path>` | ファイルアップロード |

### スクリーンショット
| コマンド | 用途 |
| --- | --- |
| `screenshot <name>.png` | 表示領域 |
| `screenshot --full <name>.png` | ページ全体 |
| `screenshot --annotate <name>.png` | インタラクティブ要素に番号付きオーバーレイ |

### バッチ / スクリプト
| コマンド | 用途 |
| --- | --- |
| `batch "cmd1" "cmd2" ...` | 複数コマンドを1プロセスで連続実行 |
| `eval "<js>"` | JavaScript をページ内で実行 |

## セマンティックロケータ（ref が使えない場面）

snapshot を取らず直接要素を指定したい場合：

```bash
agent-browser click "find role button"                 # 最初のbutton
agent-browser click "find text 'ログイン'"             # テキスト完全一致
agent-browser click "find label '検索'"                # aria-label
agent-browser fill "find role textbox[name='Email']" "..."
```

優先度: `@eN` ref > セマンティックロケータ > CSS セレクタ。

## 認証

### Chrome プロファイル再利用（ローカル開発で手軽）
```bash
agent-browser --profile Default open "https://..."
```
手元 Chrome のログイン状態を引き継ぐ。最速。

### 独立プロファイル
```bash
agent-browser --profile ~/.ab-profiles/myapp open "https://..."
```
タスク専用のプロファイルディレクトリ。cookie が永続化される。

### セッション自動保存（このスキルの基本）
```bash
agent-browser --session-name myapp open "https://..."
```

### auth vault（credentials を平文で渡したくない場合）
```bash
echo "パスワード" | agent-browser auth save myapp \
  --url "https://.../login" --username "user@example.com" --password-stdin
agent-browser auth login myapp
```
LLM はパスワード本体を見ない（stdin 経由）。

## トラブルシューティング

| 症状 | 対処 |
| --- | --- |
| ref が無効 / 要素なしエラー | 直前に `snapshot -i` を取り直す。ページ変更後は必須 |
| クリックが効かない | `is visible @eN` / `is enabled @eN` で状態確認。必要なら `scroll` |
| ページが読み込まれない | `wait <ms>` を増やす / `wait "<selector>"` で特定要素を待つ |
| セッションが切れる | `--session-name` が全コマンドに付いているか確認 |
| スクショが保存先に出ない | `AGENT_BROWSER_SCREENSHOT_DIR` 未設定 or 絶対パス未指定 |
| 想定外のドメインに遷移 | `--allowed-domains` を付けて次回から制限 |
| iframe 内の操作 | `eval` で `document.querySelector('iframe').contentWindow....` を書く |
