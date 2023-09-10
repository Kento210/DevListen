import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' show parse;
import '/utilities.dart';  // utilities.dartをインポート

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = '';  // 入力されたURL
  String content = '';  // 取得したコンテンツ
  List<String> importantWords = [];  // 重要な単語のリスト
  WebViewController? _webViewController;  // WebViewのコントローラ
  bool showImportantWords = true;  // 重要な単語を表示するかどうか
  bool showReadingTime = true;  // 読むのにかかる時間を表示するかどうか

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DevListen'),
        actions: [
          // 右上のメニュー
          PopupMenuButton(
            itemBuilder: (context) => [
              // 重要な単語の表示切り替え
              PopupMenuItem(
                child: Row(
                  children: [
                    Text("Show Important Words"),
                    Switch(
                      value: showImportantWords,
                      onChanged: (value) {
                        setState(() {
                          showImportantWords = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // 読むのにかかる時間の表示切り替え
              PopupMenuItem(
                child: Row(
                  children: [
                    Text("Show Reading Time"),
                    Switch(
                      value: showReadingTime,
                      onChanged: (value) {
                        setState(() {
                          showReadingTime = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // URL入力フィールド
            TextField(
              decoration: InputDecoration(labelText: 'Enter URL'),
              onChanged: (value) {
                setState(() {
                  url = value;
                });
              },
            ),
            // ボタン群
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // コンテンツ取得と読み上げボタン
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      content = await fetchContent(url);
                      var document = parse(content);
                      var plainText = document.body!.text;
                      importantWords = extractImportantWords(plainText);
                      speak(plainText);
                      setState(() {});
                    },
                    child: Text('Fetch and Speak'),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                // 読み上げ停止ボタン
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
                // WebViewリセットボタン
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
            // 重要な単語と読むのにかかる時間の表示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (showImportantWords)
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '重要ワード:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(importantWords.join(', ')),
                    ],
                  ),
                ),
                if (showReadingTime)
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '読むのにかかる時間（推定）:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(calculateReadingTime(content)),
                    ],
                  ),
                ),
              ],
            ),
            // WebViewの表示
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
