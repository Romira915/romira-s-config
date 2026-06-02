# Playwright 操作ノウハウ

## スクショに URL バーを含める

Playwright の `browser_take_screenshot` はページビューポートしか撮らないので「どの URL での挙動か」が画像に残らない。優先度順に 3 通り。

### 方法 1: macOS `screencapture -l <windowID>` (推奨・headed 時)

Playwright が headed モードで Google Chrome を駆動しているなら、ウィンドウ単位キャプチャでアドレスバーごと撮れる。

1. Chrome ウィンドウ ID を取得 (一度だけ取れば session 中固定)

```sh
cat > /tmp/list_chrome_windows.swift <<'EOF'
import Cocoa
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as! [[String: AnyObject]]
for w in list {
    guard let owner = w["kCGWindowOwnerName"] as? String, owner.contains("Chrome") else { continue }
    let id = w["kCGWindowNumber"] as? Int ?? 0
    let layer = w["kCGWindowLayer"] as? Int ?? -1
    let bounds = w["kCGWindowBounds"] as? [String: CGFloat] ?? [:]
    print("id=\(id) layer=\(layer) w=\(bounds["Width"] ?? 0) h=\(bounds["Height"] ?? 0)")
}
EOF
swift /tmp/list_chrome_windows.swift
# → id=31326 layer=0 w=1200.0 h=875.0 (layer=0 のウィンドウが対象)
```

2. キャプチャ前に Chrome を activate (occlude されてると `could not create image from window` で失敗するため)

```sh
osascript -e 'tell application "Google Chrome" to activate'
sleep 0.3
screencapture -l 31326 -x "/path/to/output.png"
```

前提:
- Playwright MCP が headed (今は npx 起動でデフォルト headed)
- ターミナルに「画面収録」権限が付与されている
- Chrome の前に他ウィンドウが被ると失敗する

### 撮影前に消す必要のあるブラウザ chrome 要素

Playwright MCP は Chrome を `--no-sandbox` で起動するため、ウィンドウ上部に黄色い警告バー (`サポートされていないコマンドラインフラグ --no-sandbox を使用しています`) が出る。これは Chrome 本体の UI なので **DOM 経由・Playwright API 経由では消せない**。

- `browser_press_key("Escape")` 等は効かない (page DOM にしか届かない)
- `osascript` で System Events 経由クリックも、Accessibility 権限が無いと `-25211` で弾かれる
- 結局 **ユーザーに手動で X クリックしてもらう** のが現実的。撮影開始前に「黄色バーが出ていたら X で閉じてください」と一声かける

同様に、ログイン成功直後の Chrome 「パスワードを保存しますか?」ネイティブダイアログも DOM 外。こちらは `browser_press_key("Escape")` が **稀に効く** (page にフォーカスがあるタイミングなら拾える) が、確実ではないので「Escape を試して、ダメなら手動でスキップ」が安全。

判断を急がない: 「2 回目の navigate で勝手に消えた」ように見えても、実はユーザーが裏で X クリックしてくれていることがある。自分の対策で消えたと早合点しない。

### 方法 2: DOM に URL overlay を挿入

headless 環境や `screencapture` が使えない場合のフォールバック。撮影前に DOM 上部へ overlay を挿入し、撮影後に削除する。

```js
const bar = document.createElement('div');
bar.id = '__url_overlay';
bar.textContent = location.href;
bar.style.cssText = 'position:fixed;top:0;left:0;right:0;background:#fff;border-bottom:2px solid #333;padding:8px 12px;font-family:monospace;font-size:14px;z-index:2147483647;color:#000;';
document.body.appendChild(bar);
```

```js
document.getElementById('__url_overlay')?.remove();
```

### 方法 3: ファイル名・Markdown 並記

`<JIRA-KEY>-NNNN-Cx-NN-<path-slug>.png`（`<JIRA-KEY>` は personal.md の projectKey）のように path をファイル名に込めつつ、Markdown で `URL: \`https://...\`` を画像直上に書く。視認性は最弱だが手間ゼロ。

## browser_take_screenshot の出力先

Playwright MCP の `browser_take_screenshot` に `filename` を渡すと **cwd 直下** に保存される (`.playwright-mcp/` ではない)。Obsidian Vault を cwd にしていると CLAUDE.md の「Vault 直下に断片を置くな」に違反するので、生成後すぐ `Images/` などに `mv` する。`/tmp/opencode/` を `filename` に絶対パス指定しても allowed roots 外で拒否されるため、後で動かすのが現実的。

## RainLoop Webmail（mailcatcher）のスクロール

```javascript
// スクロールリセット
document.querySelectorAll('.content.g-scrollbox')[last]?.scrollTo(0, 0);
// 下にスクロール
document.querySelectorAll('.content.g-scrollbox')[last]?.scrollBy(0, 400);
```

## メールの種類特定（複数メールから対象を探す場合）

メール一覧をループし、本文のキーワードで種類を判定してからスクショを取る。

## BaseMachina でのアクション実行

- アクション一覧 URL は `~/.claude/personal.md` の `stg-manual-test / BaseMachina アクション一覧 URL` を参照
- リンク検索: `page.evaluate` で `textContent` を検索してクリック
- フォーム入力: `page.getByRole('textbox', { name: '<aria-label>' })`
- iframe 内コンテンツ: `page.frameLocator('iframe').first()`
