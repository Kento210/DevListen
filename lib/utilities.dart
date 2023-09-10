import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();

speak(String text) async {
  await flutterTts.speak(text);
}

// 音声を停止する関数
Future<void> stopSpeaking() async {
  await flutterTts.stop();
}

Future<String> fetchContent(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load content');
  }
}

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

const int charsPerMinute = 5000;

String calculateReadingTime(String text) {
  int totalSeconds = (text.length / charsPerMinute * 60).ceil();
  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;
  return '$minutes分$seconds秒';
}
