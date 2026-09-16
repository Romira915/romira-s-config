# Jiraの画像付きQAコメントを下書きにする

## 共有範囲と完了条件

- JiraへQAコメントと画像を共有する依頼では、画像をJiraの添付・メディア保存先へアップロードし、対応するエビデンス欄に配置したコメント下書きまで作成する。文書作成だけの依頼ではアップロードしない。
- 画像入りHTMLのクリップボードやlocalhost・ローカルファイル参照だけを共有完了としない。アップロード成功・メディアID・本文内の配置を確認する。
- コメントの保存・送信は明示指示がある場合だけ行う。下書きと投稿済みを区別して報告する。既存の下書きは無断で置き換えない。

## 操作経路の選択

1. 利用可能なコネクタのツール定義を確認する。添付とADFコメントの両方を扱え、認証済みならその機能を使う。
2. 添付APIがなく、ログイン済みブラウザの操作が許可されている場合は、下記のファイルアップロード手順を優先する。APIトークンの追加発行は前提にしない。既に得た対象チケット・画像・投稿の許可を再度求めない。
3. ブラウザが未許可なら適用される操作手段の切り替えルールに従う。未ログインならログインだけを依頼する。

ブラウザ拡張が接続しているタブと、Playwright MCP／Chrome DevTools MCPが別途起動したブラウザは同じとは限らない。別ツールに `about:blank` だけが見える場合、ログイン済みタブが失われたと判断せず、接続済み拡張のタブを使う。ブラウザのCookieを外部へ取り出す必要はない。

## ブラウザによる本文入力と画像アップロード

以下はNode.jsを使えるブラウザREPLで確認した操作。実行環境のブラウザAPIドキュメントを先に読み、同じメソッドが公開されている場合に使う。`evaluate` はDOMの読取り・検証だけに使い、書込みは正規エディタの貼り付け操作で行う。利用不能なAPIを推測で呼ばない。

### 1. 入力と接続を確定する

- チケットURL、QA文書、画像の絶対パス、各画像を置く表の行番号を確定する。ヘッダ行は0、最初の確認ケースは1。案件固有の値は今回の依頼・文書から取得し、このreferenceへ固定しない。
- ランタイムの公開APIでブラウザとタブを列挙し、対象URLのログイン済みタブを選ぶ。以下の `jiraTab` はその取得済みハンドル。タブIDを過去ログから転用しない。
- コメント編集欄を開いてDOM snapshotを取り、編集欄と表の構造を確認する。以下の `#ak-editor-textarea` は実機で確認したIDであり、現在のDOMにもある場合だけ使う。
- 既存の他者・ユーザー作成の下書きは置き換えない。以下の全選択は空欄または自分が今回作った下書きだけを対象とする。

### 2. QA本文をHTMLとして一度に貼り付ける

QA文書をヘッダ、見出し、リスト、7列表を維持したHTMLに変換する。HTMLを単純な文字列置換だけで生成する場合は、本文中の `<`、`&`、コードブロックを壊していないことを確認する。画像タグとローカル画像リンクはこの貼り付け用HTMLから除く。各エビデンスセル末尾に、画像の挿入先となる空の `<p></p>` を1つ置く。元のQA文書の画像参照は変更しない。

```js
// qaHtml: 上記条件で準備し、元文書と照合したHTML文字列
var editor = jiraTab.playwright.locator('#ak-editor-textarea');
await jiraTab.clipboard.write([
  { entries: [{ mimeType: 'text/html', text: qaHtml }] },
]);
await editor.click();
await editor.press('ControlOrMeta+a');
await editor.press('ControlOrMeta+v');
```

別のツール呼出しで表が1つ、行数がケース数+1、全行7列であることと本文を確認する。HTMLが文字列として表示されていたら画像挿入へ進まない。

### 3. ファイルchooserでまとめてアップロードする

画像のbase64クリップボード転送を標準経路にしない。複数枚だけでなく1枚の転送でも接続切断が観測されており、一般的なサイズ上限は未確定。正規の「画像、動画、またはファイルを追加」→「アップロード」と公開filechooser APIを優先する。Finder・Previewの往復は不要。

- 先に実行環境のfile uploadドキュメントを読む。
- 元画像の絶対パス・配置先行・画像を識別する一意キーを一覧にする。同名ファイルや非同期の完了順に依存しない。必要なら一時ディレクトリへ一意なファイル名で無加工コピーし、元パスとの対応を保持する。
- 通常は同じエビデンス行の画像をまとめて選択する。投稿とADF更新が許可されている場合は、全画像を一括アップロードし、投稿後に取得したmediaノードを対応行へ配置できる。下書き依頼では、この方法のために一度投稿してはならない。
- ピッカーを開いた後、別の状態確認でアップロードボタンが存在することを確認してからchooserを待つ。

```js
// imagePaths: 今回の許可済み画像の絶対パス配列
// 待機Promiseには直ちに失敗ハンドラーを付ける。
// 未処理の拒否でREPL状態を失わないようにする。
var chooserPromise = jiraTab.playwright.waitForEvent('filechooser', {
  timeoutMs: 10000,
}).catch(error => ({ error: String(error) }));
await jiraTab.playwright.getByRole('button', {
  name: 'アップロード', exact: true,
}).click();
var chooser = await chooserPromise;
if (chooser.error) throw new Error(chooser.error);
if (imagePaths.length > 1 && !(await chooser.isMultiple())) {
  throw new Error('複数選択に非対応。1件ずつ選択する');
}
await chooser.setFiles(imagePaths);
```

`Not allowed` は同じ操作で再試行しない。公開troubleshootingで必要条件を確認し、拡張のファイルアクセス権限等が不足している場合は具体的な設定を案内する。権限を無断で変更しない。画像クリップボードはfilechooserが使えず、小さい1枚で成功を確認できた場合の代替に限る。切断した転送方式を繰り返さない。

### 4. アップロード完了と対応を確認する

別のツール呼出しで、予定枚数、各画像の空でないmedia ID、画像読込み完了（`img.complete && img.naturalWidth > 0`）、現在のDOMにあればアップロード完了状態を確認する。元パス → 一意キー → 行 → media IDの対応を保持する。

- 完了前に挿入先を移動したり、同じファイルを再アップロードしない。
- ファイル名だけでなく、画像表示・寸法等を元画像と照合する。同名ファイルを完了順で割り当てない。
- 状態が変わらないときはエラー表示と接続を確認する。接続切断後はランタイムの復旧手順に従い、同じブラウザの新しい状態を取得する。古いタブの反復操作を避ける。

### 5. 配置がずれた場合は同じメディアを移動する

```js
// mediaId: DOMから実際に取得したID。値を作らない。
await editor.locator('img[data-fileid="' + mediaId + '"]').click();
await editor.press('ControlOrMeta+x');
await targetEvidenceCell.locator('p').last().click(); // 確認済みの空段落
await editor.press('ControlOrMeta+v');
```

移動前に全行のmedia IDを記録し、移動後に同じIDが移動元から消え、移動先に1つあることを確認する。`targetEvidenceCell` は手順3と同じ方法で取得する。画像の再アップロードは不要。

本文が画像で分断された場合は、段落末尾へ画像を移動して本文を元文書どおりに戻す。投稿済みでADF編集コネクタが使える場合は次節の方法でも修復できる。

### 6. 下書き／投稿を分岐する

- 下書き依頼：保存しない。アップロード済み・未送信と報告し、継続が必要なタブをランタイム所定のhandoff操作で保持する。
- 投稿依頼：今回の依頼または既存の会話で投稿まで許可されていれば、下記検証後に保存する。二重投稿を避けるため、保存中・タイムアウトの場合は現在のコメントを再取得して成否を確定してから再試行する。
- 保存操作後は編集欄が閉じることを確認する。ショートカットが成功したと決めつけず、残っていれば表示中の保存ボタンを使う。API反映が遅れる場合は投稿本文が画面にあるか確認し、再取得してコメントIDを確定する。コメント配列の末尾を最新と仮定しない。
- 保存後は、コネクタの `getJiraIssue` 相当で `fields: ["comment", "attachment"]`、`responseContentFormat: "adf"` を取得し、追加コメントのIDと添付の存在を確認する。ツール名・引数はその時点の定義を読む。巨大な応答全体を出力せず、対象コメントID・各行のmedia ID・添付IDだけを出す。

### 7. 投稿済みADFの画像配置・修復

対象チケットから取得した対象コメントのADFを使う。`commentId` を必ず指定して更新し、新しいコメントを追加しない。承認されている今回の投稿の整形だけに適用し、他のコメントを変更しない。

一括アップロードした場合は、取得したmediaノードを一意キーで対応付けて各行のエビデンスセルへ移す。非mediaノードとその順序を保持し、mediaのID・寸法・collectionを変更しない。更新前後のmedia ID集合と総数が一致し、各IDが予定行にあることを検証する。

以下は画像によって説明文が分断された場合だけの修復例：

```js
// comment: IDを照合して取得したコメント。bodyはADFオブジェクト。
var table = comment.body.content.find(node => node.type === 'table');
for (var row of table.content.slice(1)) {
  var cell = row.content[6];
  if (!cell.content.every(node => ['paragraph', 'mediaSingle'].includes(node.type))) {
    throw new Error('リスト・コード等があるため、この単純結合は適用しない');
  }
  var media = cell.content.filter(node => node.type === 'mediaSingle');
  var inline = cell.content.filter(node => node.type === 'paragraph')
    .flatMap(node => node.content || []);
  cell.content = [{ type: 'paragraph', content: inline }, ...media];
}
// addCommentToJiraIssue相当の定義を確認して渡す引数:
var updateArgs = {
  cloudId, issueIdOrKey, commentId: comment.id,
  contentFormat: 'adf', commentBody: JSON.stringify(comment.body),
};
```

元々別段落だった説明を無条件に結合しない。元のQA文書と照合して、挿入で分断された段落だけに適用する。mediaノードのID・寸法・collectionは取得値を保持し、任意のURLや新しいIDで置き換えない。保存後の `collection` が空文字でも独断で変更しない。

### 8. 完了判定（再読込で確認）

保存済みコメントを再読込する。対象QA表を本文の識別可能な文言で特定し、全行7列・予定ケース数・エビデンスセルごとのmedia ID一致・`img.complete && img.naturalWidth > 0` を確認する。再読込直後の `loaded: false` はロード中の可能性があるので、別の読取りで完了を待つ。

API上の添付登録と、再読込後の画像表示の両方を確認して投稿済みとする。報告にはチケットのコメント直リンクを付ける。別アカウントで確認していなければ「他ユーザーから閲覧確認済み」とは書かない。

## 失敗時の分岐

| 現象 | 次の操作 | 避けること |
|---|---|---|
| 添付APIが見つからない | 許可済み・ログイン済みブラウザのfilechooser APIを確認 | APIトークン発行を必須と断定 |
| ファイルchooserの `Not allowed` | 公開troubleshootingで必要権限を確認し、不足設定を具体的に案内 | 同じsetFilesの反復、無断で拡張権限変更 |
| `native pipe closed`／ブラウザ unavailable | ランタイムの復旧手順に従い、同じブラウザへ再接続。画像転送はfilechooserへ変更 | 古いbrowser IDの反復、原因未確認でJira障害と断定 |
| コメント欄をクリックしてもeditorがない | DOMと画面を確認し、アクセシビリティ操作等の別の正規操作を1回試す | 同じクリック・Enter・再読込を根拠なく反復 |
| 画像数0 | 次の呼出しで状態確認。カーソルを動かさない | 即時再貼り付け、別行への先行操作 |
| 別行へ画像が入った | 実media IDで切取り・正しいセルに貼り付け・ID照合 | 名前だけで識別、重複アップロード |
| 本文途中に画像が入った | 元文書と照合し、段落の後ろへ再配置。必要なら取得ADFを修復 | 画像があるだけで合格扱い |
| 保存の結果が不明 | コメントを再取得してID・本文・mediaを照合 | 無条件で新規コメントを再送 |

## 手順変更時の回帰確認

新たなチケット投稿をテスト目的で勝手に作らない。ローカルでコード例の構文・referenceリンク・固有情報の混入を確認し、次の承認済み共有時に下記を実機確認する。

1. 空の編集欄へヘッダ・見出し・7列表を貼り付け、元文書と一致する。
2. 異なる画像と同名画像を含む複数ファイルをアップロードし、完了順によらず予定行へ対応付けられる。
3. 各行のmedia IDが一意で、画像・行の対応と本文が維持される。
4. 移動修復が必要な場合、同じmedia IDのまま正しいセルへ移動する。
5. 投稿許可がない場合は下書きで止まる。許可がある場合は1コメントとして保存され、再読込後も画像と添付を確認できる。
