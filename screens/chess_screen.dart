import 'package:flutter/material.dart';
import 'package:chess_game/widgets/chess_board.dart';
import 'package:chess_game/logic/chess_game.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  late ChessGame _game;

  @override
  void initState() {
    super.initState();
    _game = ChessGame();
  }

  void _rebuild() {
    setState(() {});
  }

  void _resetGame() {
    setState(() {
      _game.resetGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Center(
        child: ChessBoard(
          game: _game,
          onMove: _rebuild,
        ),
      ),
    );
  }
}
