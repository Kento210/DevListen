import 'package:flutter/material.dart';
/*
  main.dart:
  アプリケーションのエントリーポイント
*/

import '/my_home_page.dart';  // MyHomePageウィジェットが定義されているmy_home_page.dartをインポート
import '/utilities.dart';  // ユーティリティ関数（speak, stopSpeakingなど）が定義されているutilities.dartをインポート

// アプリケーションのエントリーポイント
void main() {
  runApp(MyApp());
}

// MyApp クラスはアプリケーションのルートウィジェットを定義する
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialAppウィジェットでアプリケーションの基本的なビジュアル構造を提供
    return MaterialApp(
      home: MyHomePage(),  // MyHomePageウィジェットをホームページとして設定
    );
  }
}









