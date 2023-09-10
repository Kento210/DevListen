/*
  my_home_page.dart:
  ウィジェットを格納
*/

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' show parse;
import '/utilities.dart';  // utilities.dartをインポートで、speakやstopSpeakingなどの関数を利用

// MyHomePageウィジェットの定義
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// MyHomePageの状態を管理するクラス
class _MyHomePageState extends State<MyHomePage> {
  String url = '';  // 入力されたURLを保存
  String content = '';  // フェッチしたコンテンツを保存
  List<String> importantWords = [];  // 重要な単語を保存
  WebViewController? _webViewController;  // WebViewのコントローラ
  bool showImportantWords = true;  // 重要な単語を表示するかどうかのフラグ
  bool showReadingTime = true;  // 読むのにかかる時間を表示するかどうかのフラグ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DevListen'),
        actions: [
          // 右上のポップアップメニュー
          PopupMenuButton(
            itemBuilder: (context) => [
              // 重要な単語の表示を切り替えるスイッチ
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
              // 読むのにかかる時間の表示を切り替えるスイッチ
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
            // URLを入力するテキストフィールド
            TextField(
              decoration: InputDecoration(labelText: 'Enter URL'),
              onChanged: (value) {
                setState(() {
                  url = value;
                });
              },
            ),
            // 各種操作ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // コンテンツをフェッチして読み上げるボタン
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
                // 読み上げを停止するボタン
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
            // 重要な単語と読むのにかかる時間の表示エリア
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
            // WebViewの表示エリア
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

