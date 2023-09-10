/*
  utilities.dart:
  非同期関数とユーティリティ関数を格納

  speak():
  テキストを音声に変換して読み上げる関数
  stopSpeaking():
  音声の読み上げを停止する関数
  fetchContent():
  指定されたURLからコンテンツを非同期に取得する関数

  extractImportantWords():
  与えられたテキストから重要な単語を抽出する関数
  calculateReadingTime():
  テキストの文字数から読むのにかかる時間（秒）を計算する関数
*/

import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

// FlutterTtsのインスタンスを作成
FlutterTts flutterTts = FlutterTts();

// テキストを音声に変換して読み上げる関数
Future<void> speak(String text) async {
  await flutterTts.speak(text);
}

// 音声の読み上げを停止する関数
Future<void> stopSpeaking() async {
  await flutterTts.stop();
}

// 指定されたURLからコンテンツを非同期に取得する関数
Future<String> fetchContent(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load content');
  }
}

// 与えられたテキストから重要な単語を抽出する関数
List<String> extractImportantWords(String text) {
  // 非漢字・非ひらがな・非カタカナをスペースに置き換え
  String filteredText = text.replaceAll(RegExp(r'[^一-龯ぁ-んァ-ンー]'), ' ');
  // 単語に分割
  List<String> words = filteredText.split(' ').where((word) => word.isNotEmpty).toList();
  // 単語の出現頻度をカウント
  Map<String, int> frequency = {};

  for (String word in words) {
    if (frequency.containsKey(word)) {
      frequency[word] = frequency[word]! + 1;
    } else {
      frequency[word] = 1;
    }
  }

  // 出現頻度で単語をソート
  List<MapEntry<String, int>> sortedWords = frequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // 出現頻度の高い単語を返す
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

