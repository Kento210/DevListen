// FlutterのMaterialデザインライブラリをインポート
import 'package:flutter/material.dart';
// HTTPリクエストを行うためのライブラリをインポート
import 'package:http/http.dart' as http;
// テキストを音声に変換するためのライブラリをインポート
import 'package:flutter_tts/flutter_tts.dart';
// マークダウン表示のためのライブラリをインポート
import 'package:flutter_markdown/flutter_markdown.dart';
// webview_flutterパッケージをインポート
import 'package:webview_flutter/webview_flutter.dart';

// 非同期関数でURLからコンテンツを取得
Future<String> fetchContent(String url) async {
  // HTTP GETリクエストを送信
  final response = await http.get(Uri.parse(url));
  // ステータスコードが200（成功）なら内容を返す
  if (response.statusCode == 200) {
    return response.body;
  } else {
    // それ以外の場合は例外を投げる
    throw Exception('Failed to load content');
  }
}

// FlutterTtsクラスのインスタンスを作成
FlutterTts flutterTts = FlutterTts();

// 非同期関数でテキストを音声に変換
speak(String text) async {
  await flutterTts.speak(text);
}

// 音声を停止する非同期関数
stopSpeaking() async {
  await flutterTts.stop();
}

// アプリケーションのエントリーポイント
void main() {
  runApp(MyApp());
}

// MyAppクラス（ステートレスウィジェット）
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialAppウィジェットを返す
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

// MyHomePageクラス（ステートフルウィジェット）
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// _MyHomePageStateクラス（ステートオブジェクト）
class _MyHomePageState extends State<MyHomePage> {
  // URLとコンテンツを保持するための変数
  String url = '';
  String content = '';
  WebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    // ScaffoldウィジェットでUIを構築
    return Scaffold(
      appBar: AppBar(
        title: Text('DevListen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // URLを入力するためのテキストフィールド
            TextField(
              decoration: InputDecoration(labelText: 'Enter URL'),
              onChanged: (value) {
                // テキストが変更されたらステートを更新
                setState(() {
                  url = value;
                });
              },
            ),
            // ボタンを押すとコンテンツを取得して音声で読み上げる
            // 横並びにするためにRowウィジェットを使用
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      content = await fetchContent(url);
                      setState(() {});
                      speak(content);
                    },
                    child: Text('Fetch and Speak'),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      stopSpeaking();
                    },
                    child: Text('Stop Speaking'),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_webViewController != null) {
                        _webViewController!.loadUrl(url);
                      }
                    },
                    child: Text('Reset WebView'),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),

            // WebViewを追加
            Expanded(
              child: url.isNotEmpty
                  ? WebView(
                      initialUrl: url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _webViewController = webViewController;
                      },
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}





