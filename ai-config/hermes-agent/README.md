# hermes-agent

Hermes Agent の共有設定を管理するディレクトリ。

## 管理対象

- `config.yaml` → `~/.hermes/config.yaml`

`~/.hermes/config.yaml` はこのリポジトリ内の `ai-config/hermes-agent/config.yaml` へのシンボリックリンクにする。

## 管理しないもの

以下はトークン・実行時状態・キャッシュを含むため git 管理しない。

- `~/.hermes/.env`
- `~/.hermes/auth.json`
- `~/.hermes/state.db*`
- `~/.hermes/sessions/`
- `~/.hermes/logs/`
- `~/.hermes/cache/`
- `~/.hermes/lsp/`

## 初回セットアップ

```sh
mkdir -p ~/.hermes
ln -sf ~/.config/romira-s-config/ai-config/hermes-agent/config.yaml ~/.hermes/config.yaml
```

既存の `~/.hermes/config.yaml` がある場合は、差し替え前にバックアップを取る。
