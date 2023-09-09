// FlutterのMaterialデザインライブラリをインポート
import 'package:flutter/material.dart';
// HTTPリクエストを行うためのライブラリをインポート
import 'package:http/http.dart' as http;
// テキストを音声に変換するためのライブラリをインポート
import 'package:flutter_tts/flutter_tts.dart';

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

  @override
  Widget build(BuildContext context) {
    // ScaffoldウィジェットでUIを構築
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Speech App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            ElevatedButton(
              onPressed: () async {
                content = await fetchContent(url);
                speak(content);
              },
              child: Text('Fetch and Speak'),
            ),
            // 音声を止めるボタンを追加
            // このボタンを押すと、音声の読み上げが停止します
            ElevatedButton(
              onPressed: () {
                stopSpeaking();
              },
              child: Text('Stop Speaking'),
            ),
          ],
        ),
      ),
    );
  }
}




