// Flutterの基本ライブラリをインポート
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// HTTPリクエスト用のライブラリ
import 'package:http/http.dart' as http;
// テキストを音声に変換するライブラリ
import 'package:flutter_tts/flutter_tts.dart';
// WebViewを使用するためのライブラリ
import 'package:webview_flutter/webview_flutter.dart';
// Webプラットフォームでiframeを使用するためのライブラリ
import 'dart:html' as html;
import 'dart:ui' as ui;

// URLからコンテンツを非同期に取得する関数
Future<String> fetchContent(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load content');
  }
}

// FlutterTtsのインスタンスを作成
FlutterTts flutterTts = FlutterTts();

// テキストを音声に変換する関数
speak(String text) async {
  await flutterTts.speak(text);
}

// 音声を停止する関数
stopSpeaking() async {
  await flutterTts.stop();
}

// アプリのエントリーポイント
void main() {
  // Webプラットフォームでiframeを使用する場合の設定
  if (kIsWeb) {
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..width = '640'
      ..height = '360'
      ..src = 'https://example.com'
      ..style.border = 'none';

    // iframeをFlutter Webで使用するための設定
    ui.platformViewRegistry.registerViewFactory(
      'example-iframe',
      (int viewId) => iFrameElement,
    );
  }

  runApp(MyApp());
}

// ステートレスウィジェット MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

// ステートフルウィジェット MyHomePage
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// MyHomePageのステート
class _MyHomePageState extends State<MyHomePage> {
  String url = '';
  String content = '';
  WebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DevListen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // URLを入力するテキストフィールド
            TextField(
              decoration: InputDecoration(labelText: 'Enter URL'),
              onChanged: (value) {
                setState(() {
                  url = value;
                });
              },
            ),
            // 操作ボタンを配置するRow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // コンテンツを取得して音声で読み上げるボタン
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
                // 音声を停止するボタン
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
                // WebViewをリセットするボタン
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
            // WebViewまたはiframeを表示する領域
            Expanded(
              child: url.isNotEmpty
                  ? kIsWeb
                      ? HtmlElementView(
                          viewType: 'example-iframe',
                        )
                      : WebView(
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

