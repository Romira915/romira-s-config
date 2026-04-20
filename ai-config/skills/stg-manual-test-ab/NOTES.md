# STG マニュアルテスト固有の agent-browser ノウハウ

agent-browser CLI 一般のコマンド・認証・トラブルシューティングは `~/.claude/skills/agent-browser/REFERENCE.md` を参照。ここでは STG 検証で頻出する固有のテクニックのみ記述する。

## ログイン（セッション未作成の場合のみ）

```bash
agent-browser --session-name stg-<TICKET> open "https://<STGドメイン>/login"
agent-browser --session-name stg-<TICKET> snapshot -i
# snapshot 出力から @e<N> を特定（ユーザー名/パスワード/ログインボタン）
agent-browser --session-name stg-<TICKET> fill @e<N> "<ユーザー名>"
agent-browser --session-name stg-<TICKET> fill @e<M> "<パスワード>"
agent-browser --session-name stg-<TICKET> click @e<K>
agent-browser --session-name stg-<TICKET> wait 2000
agent-browser --session-name stg-<TICKET> snapshot -i  # 成功確認
```

- パスワードは可能な限り stdin 経由（`auth save --password-stdin`）
- 2 回目以降は `--session-name` 自動復元でログインスキップ

## バッチ実行

ユーザー判断を挟まない連続操作はレイテンシ削減に `batch`：

```bash
agent-browser --session-name stg-<TICKET> batch \
  "open https://<STG>/target" \
  "wait 1500" \
  "screenshot --full test1_before.png"
```

snapshot → ref 選定 → 操作 は LLM の判断が必要なので逐次実行する。

## ドメイン制限

```bash
agent-browser --session-name stg-<TICKET> \
  --allowed-domains "<STGドメイン>,<mailcatcherドメイン>" \
  open "https://<STG>/..."
```

## mailcatcher（RainLoop）操作

```bash
# メール本文をトップに戻す
agent-browser --session-name stg-<TICKET> eval \
  "document.querySelectorAll('.content.g-scrollbox')[document.querySelectorAll('.content.g-scrollbox').length-1]?.scrollTo(0, 0)"

# 指定テキストを含むリンクをクリック
agent-browser --session-name stg-<TICKET> eval \
  "[...document.querySelectorAll('a')].find(a => a.textContent.includes('対象リンク'))?.click()"
```

## BaseMachina でのアクション実行

- アクション一覧 URL は `~/.claude/personal.md` の `stg-manual-test / BaseMachina アクション一覧 URL` を参照
- リンク検索: `find text "<アクション名>"` または `eval` で textContent 検索 → click
- フォーム入力: `fill @e<N>`（snapshot で label/role から特定）
- iframe 内操作: `eval` で `document.querySelector('iframe').contentDocument...`
