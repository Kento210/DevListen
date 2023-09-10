import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart' show parse;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';

// URLからコンテンツを非同期で取得する関数
Future<String> fetchContent(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load content');
  }
}

// 重要な単語をテキストから抽出する関数
List<String> extractImportantWords(String text) {
  // 不要な文字を削除
  String filteredText = text.replaceAll(RegExp(r'[^一-龯ぁ-んァ-ンー]'), ' ');
  // 単語に分割
  List<String> words = filteredText.split(' ').where((word) => word.isNotEmpty).toList();
  // 単語の出現回数をカウント
  Map<String, int> frequency = {};
  for (String word in words) {
    if (frequency.containsKey(word)) {
      frequency[word] = frequency[word]! + 1;
    } else {
      frequency[word] = 1;
    }
  }
  // 出現回数でソート
  List<MapEntry<String, int>> sortedWords = frequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  // 上位5つの単語を返す
  return sortedWords.sublist(0, min(5, sortedWords.length)).map((entry) => entry.key).toList();
}

// 一分間に読める文字数（この数値は調整が必要）
const int charsPerMinute = 5000;

// テキストの文字数から読むのにかかる時間（秒）を計算する関数
String calculateReadingTime(String text) {
  int totalSeconds = (text.length / charsPerMinute * 60).ceil();
  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;
  return '$minutes分$seconds秒';
}

// FlutterTTSのインスタンス
FlutterTts flutterTts = FlutterTts();

// テキストを音声で読み上げる関数
speak(String text) async {
  await flutterTts.speak(text);
}

// 音声の読み上げを停止する関数
stopSpeaking() async {
  await flutterTts.stop();
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

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







