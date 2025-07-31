import 'package:Tetris/menu.dart';
import 'package:flutter/material.dart';
import 'package:Tetris/board.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Menu(),
        '/game': (context) => const GameBoard(),
      },
    );
  }
}
