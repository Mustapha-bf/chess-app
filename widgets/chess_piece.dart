import 'package:flutter/material.dart';

class ChessPieceWidget extends StatelessWidget {
  final String piece;
  final bool isWhiteSquare; // true when the square is light-colored

  const ChessPieceWidget({super.key, required this.piece, required this.isWhiteSquare});

  @override
  Widget build(BuildContext context) {
    final display = _getPieceUnicode(piece);
    // A piece is white if its character is uppercase.
    final isWhitePiece = piece.toUpperCase() == piece;

    // Set the piece color: white pieces are white, black pieces are black.
    final pieceColor = isWhitePiece ? Colors.white : Colors.black;

    return Text(
      display,
      style: TextStyle(
        fontSize: 40,
        color: pieceColor,
        shadows: [
          Shadow(
            blurRadius: 2.0,
            color: isWhitePiece ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
            offset: const Offset(1.0, 1.0),
          ),
        ],
      ),
    );
  }

  String _getPieceUnicode(String piece) {
    // Use distinct Unicode symbols for white (uppercase) and black (lowercase) pieces
    switch (piece) {
      case 'R':
        return '♖';
      case 'N':
        return '♘';
      case 'B':
        return '♗';
      case 'Q':
        return '♕';
      case 'K':
        return '♔';
      case 'P':
        return '♙';
      case 'r':
        return '♜';
      case 'n':
        return '♞';
      case 'b':
        return '♝';
      case 'q':
        return '♛';
      case 'k':
        return '♚';
      case 'p':
        return '♟';
      default:
        return '';
    }
  }
}
