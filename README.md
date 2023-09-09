# DevListen README （最終更新 9/10 5:04）

# 開発ルール

開発を行う際は下記のブランチルールに従う

また、常に最新のdevelopeブランチの状態になるようmerge処理を行う

### ブランチ

- main: 現在デプロイされているプロダクト
- develope: 開発中バージョンの中心

開発を行う際は`develope`ブランチからブランチを派生して開発するものとする。

また、ブランチを作成する場合は下記の命名規則に従うものとする。

`develope/[IssueID]`

例: `develop/issue#0`

### Issueについて

作業する内容についてIssueを作成して作業するものとする。

### PRについて

各開発が終了した際はdevelopeブランチへPRを出すものとする。

また、PRを出した場合は各個人が自己レビューを行う。

PR申請者以外がレビューを行い問題ないと判断された場合はMerge処理を行う

### デブロイについて

Mainブランチが外部に公開する最新プロダクトとして更新された際にデブロイ作業を行うものとする.

# 開発手法

個人開発となるが、どんどん要件を満たす機能を作って組み上げるアジャイル開発を方針とする。

# やりたいこと

- ios + webの多プラットフォームに展開できるアプリを作りたい。
- 技術記事（Qiita、Zennなど）の記事を取得し、音声で聞けるようにする。
- 使いやすいUIをFigmaでデザインし、Swiftでフロントに起こしたい。

# 実装する機能

### #1 URLからコンテンツを取得し、音声に変化して出力する機能

**バックエンド：**

HTTPリクエストで内容を取得、成功ならスターテスコード200を返し、それ以外は例外を投げる。

音声をテキストに変換してユーザに返す。

**テスト用フロント：**

最低限のURLとコンテンツを保持するString変数を持つ（url, content）

最低限のテキストフィールドと開始ボタン、停止ボタンを実装する。

### #3 ユーザ体験を向上させるために小さなWebViewを実装する。

`webview_flutter`を使用し、記事を普通に読むことができるWebViewを実装。

UIも同時に実装し、調節を行う。

URLを参照してWebViewをリセットするボタンも実装する。

### #5 flutter web (Chrome)プラットフォームで動作可能なように改良する。

`KIsWeb`を使用してWebプラットフォームかを判別しWebでは`IFrameElement`を動作するように実装。

テキストのボタンは`ElevatedButton.styleFrom`で中央寄せに変更。

### #6 取得した内容より重要単語を抽出して表示する自作言語解析機能を追加。

取得情報よりプレーンテキストを抽出、言語解析を行なって内容を出力できるように改良。

簡単な文章解析アルゴリズム（分割、頻度計算、スコア選定、選択）を用い、上位10個をボタンの上に表示するようにする。

これだけでは不十分 + バグが発生する可能性を考慮し、アルファベット、数字、特殊文字を除外した上で最頻出の分を探索するように実装する。

### #7 文字数から読む時間を推定する機能

全体の文字数を取得、一分間に読むことができる字数で割ることで実装。

重要ワードと読むのにかかる機能のUIを一部改善する。

### #8 Firebase App Distributionで試験的にデプロイを行う。