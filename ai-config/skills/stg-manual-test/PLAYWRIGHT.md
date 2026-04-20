# Playwright 操作ノウハウ

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
