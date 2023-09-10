import 'package:flutter/material.dart';
import '/my_home_page.dart';  // my_home_page.dartをインポート
import '/utilities.dart';  // utilities.dartをインポート

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








