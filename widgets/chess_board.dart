import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chess_game/logic/chess_game.dart';
import 'package:chess_game/widgets/chess_piece.dart';

class ChessBoard extends StatefulWidget {
  final ChessGame game;
  final VoidCallback onMove;

  const ChessBoard({super.key, required this.game, required this.onMove});

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  Point<int>? _selectedSquare;
  List<Point<int>> _legalMoves = [];

  @override
  void didUpdateWidget(covariant ChessBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.game.gameState == GameState.checkmate || widget.game.gameState == GameState.stalemate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showGameOverDialog());
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title;
        String content;
        if (widget.game.gameState == GameState.checkmate) {
          title = "Checkmate!";
          content = widget.game.isWhiteTurn ? "Black wins!" : "White wins!";
        } else {
          title = "Stalemate!";
          content = "The game is a draw.";
        }
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  widget.game.resetGame();
                  _selectedSquare = null;
                  _legalMoves = [];
                });
                widget.onMove();
              },
            ),
          ],
        );
      },
    );
  }

  void _onSquareTapped(int row, int col) {
    if (widget.game.gameState == GameState.checkmate || widget.game.gameState == GameState.stalemate) {
      return;
    }

    setState(() {
      if (_selectedSquare == null) {
        // If no piece is selected, select the tapped piece if it's the current player's turn
        if (widget.game.board[row][col] != '' && widget.game.isWhite(widget.game.board[row][col]) == widget.game.isWhiteTurn) {
          _selectedSquare = Point(row, col);
          _legalMoves = widget.game.getLegalMoves(row, col);
        }
      } else {
        // If a piece is already selected
        final from = _selectedSquare!;
        final to = Point(row, col);

        // Check if the tapped square is a legal move
        final isLegalMove = _legalMoves.any((move) => move.x == to.x && move.y == to.y);

        if (isLegalMove) {
          widget.game.movePiece(from.x, from.y, to.x, to.y);
          widget.onMove(); // Notify parent to rebuild
        }
        
        // Reset selection
        _selectedSquare = null;
        _legalMoves = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final piece = widget.game.board[row][col];
        final isWhiteSquare = (row + col) % 2 == 0;
        final isSelected = _selectedSquare?.x == row && _selectedSquare?.y == col;
        final isLegalMove = _legalMoves.any((move) => move.x == row && move.y == col);
        final kingPos = widget.game.isWhiteTurn ? widget.game.whiteKingPos : widget.game.blackKingPos;
        final isInCheck = widget.game.gameState == GameState.check && kingPos?.x == row && kingPos?.y == col;

        return GestureDetector(
          onTap: () => _onSquareTapped(row, col),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.green
                  : isInCheck
                      ? Colors.red.shade700
                      : (isWhiteSquare ? Colors.grey[300] : Colors.grey[600]),
              border: Border.all(color: Colors.black, width: 0.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (piece.isNotEmpty)
                  ChessPieceWidget(
                    piece: piece,
                    isWhiteSquare: isWhiteSquare,
                  ),
                if (isLegalMove)
                  Container(
                    decoration: BoxDecoration(
                      color: piece.isEmpty ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    width: piece.isEmpty ? 20 : 50,
                    height: piece.isEmpty ? 20 : 50,
                  ),
              ],
            ),
          ),
        );
      },
      itemCount: 64,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
