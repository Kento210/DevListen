import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart' show parse;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';

// 非同期関数でURLからコンテンツを取得
Future<String> fetchContent(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load content');
  }
}

// 重要な単語を抽出する関数
List<String> extractImportantWords(String text) {
  String filteredText = text.replaceAll(RegExp(r'[^一-龯ぁ-んァ-ンー]'), ' ');
  List<String> words = filteredText.split(' ').where((word) => word.isNotEmpty).toList();
  Map<String, int> frequency = {};

  for (String word in words) {
    if (frequency.containsKey(word)) {
      frequency[word] = frequency[word]! + 1;
    } else {
      frequency[word] = 1;
    }
  }

  List<MapEntry<String, int>> sortedWords = frequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sortedWords.sublist(0, min(5, sortedWords.length)).map((entry) => entry.key).toList();
}

// 一分間に読める文字数（この数値は調整が必要かもしれません）
const int charsPerMinute = 5000;

// テキストの文字数から読むのにかかる時間（秒）を計算
String calculateReadingTime(String text) {
  int totalSeconds = (text.length / charsPerMinute * 60).ceil();
  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;
  return '$minutes分$seconds秒';
}

FlutterTts flutterTts = FlutterTts();

// テキストを音声に変換する関数
speak(String text) async {
  await flutterTts.speak(text);
}

// 音声を停止する関数
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
  String url = '';
  String content = '';
  List<String> importantWords = [];
  WebViewController? _webViewController;
  bool showImportantWords = true;  // このフラグで重要ワードの表示を制御
  bool showReadingTime = true;     // このフラグで読むのにかかる時間の表示を制御

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DevListen'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
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
            TextField(
              decoration: InputDecoration(labelText: 'Enter URL'),
              onChanged: (value) {
                setState(() {
                  url = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (showImportantWords)  // このif文で表示を制御
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
              if (showReadingTime)  // このif文で表示を制御
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






