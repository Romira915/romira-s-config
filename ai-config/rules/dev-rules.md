# 開発プロジェクト共通ルール

## Development Flow

- **mainブランチに直接コミットしない** — 必ず `main` からフィーチャーブランチを切って作業し、PRを作成すること
- **1メソッド追加 = 1テスト追加** — 新しいメソッドを追加したら必ず対応するテストも追加すること
- **日本語テスト名を使う場合** — `//noinspection NonAsciiCharacters` を追加してIDE警告を抑制する

## アーキテクチャ原則

### Handler の責務
Handler（Server Function）の役割は以下に限定する：
1. HTTPからInputを受け取る
2. HTTP非依存の適切なデータ形式に変換する
3. Serviceに処理を委譲する
4. 結果に応じてステータスコードとレスポンスを決定する

**バリデーションはService層で行う** — HandlerはHTTP層の変換のみを担当し、ビジネスロジック（バリデーション含む）はService層に委譲する
