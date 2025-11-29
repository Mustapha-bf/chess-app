import 'dart:math';

enum GameState { ongoing, check, checkmate, stalemate }

class ChessGame {
  List<List<String>> board;
  bool isWhiteTurn = true;
  GameState gameState = GameState.ongoing;
  Point<int>? whiteKingPos;
  Point<int>? blackKingPos;

  ChessGame() : board = _createInitialBoard() {
    whiteKingPos = const Point(7, 4);
    blackKingPos = const Point(0, 4);
  }

  static List<List<String>> _createInitialBoard() {
    return [
      ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
      ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
      ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
    ];
  }

  void resetGame() {
    board = _createInitialBoard();
    isWhiteTurn = true;
    gameState = GameState.ongoing;
    whiteKingPos = const Point(7, 4);
    blackKingPos = const Point(0, 4);
  }

  bool isWhite(String piece) {
    return piece.toUpperCase() == piece && piece != '';
  }

  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool isOpponent(int row, int col, bool isWhitePiece) {
    if (!isInBoard(row, col) || board[row][col] == '') return false;
    return isWhite(board[row][col]) != isWhitePiece;
  }

  bool isSquareEmpty(int row, int col) {
    if (!isInBoard(row, col)) return false;
    return board[row][col] == '';
  }

  List<Point<int>> getLegalMoves(int row, int col) {
    final piece = board[row][col];
    if (piece == '' || isWhite(piece) != isWhiteTurn) {
      return [];
    }

    List<Point<int>> pseudoLegalMoves;
    switch (piece.toLowerCase()) {
      case 'p':
        pseudoLegalMoves = _getPawnMoves(row, col, isWhiteTurn);
        break;
      case 'r':
        pseudoLegalMoves = _getRookMoves(row, col, isWhiteTurn);
        break;
      case 'n':
        pseudoLegalMoves = _getKnightMoves(row, col, isWhiteTurn);
        break;
      case 'b':
        pseudoLegalMoves = _getBishopMoves(row, col, isWhiteTurn);
        break;
      case 'q':
        pseudoLegalMoves = _getQueenMoves(row, col, isWhiteTurn);
        break;
      case 'k':
        pseudoLegalMoves = _getKingMoves(row, col, isWhiteTurn);
        break;
      default:
        pseudoLegalMoves = [];
    }

    // Filter out moves that would leave the king in check
    return pseudoLegalMoves.where((move) {
      return !_isMovePuttingKingInCheck(Point(row, col), move, isWhiteTurn);
    }).toList();
  }

  bool _isMovePuttingKingInCheck(Point<int> from, Point<int> to, bool isWhiteMove) {
    final piece = board[from.x][from.y];
    final capturedPiece = board[to.x][to.y];
    final kingPos = isWhiteMove ? whiteKingPos : blackKingPos;

    // Simulate the move
    board[to.x][to.y] = piece;
    board[from.x][from.y] = '';
    Point<int> newKingPos = (piece.toLowerCase() == 'k') ? to : kingPos!;

    bool inCheck = isKingInCheck(isWhiteMove, newKingPos);

    // Revert the move
    board[from.x][from.y] = piece;
    board[to.x][to.y] = capturedPiece;

    return inCheck;
  }

  bool isKingInCheck(bool isWhiteKing, [Point<int>? kingPosition]) {
    final kingPos = kingPosition ?? (isWhiteKing ? whiteKingPos : blackKingPos);
    if (kingPos == null) return false;

    // Check for attacks from all opponent pieces
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != '' && isWhite(piece) != isWhiteKing) {
          // Get raw moves, not legal moves, to avoid infinite recursion
          List<Point<int>> moves;
          switch (piece.toLowerCase()) {
            case 'p':
              moves = _getPawnMoves(r, c, !isWhiteKing, forCheckDetection: true);
              break;
            case 'r':
              moves = _getRookMoves(r, c, !isWhiteKing);
              break;
            case 'n':
              moves = _getKnightMoves(r, c, !isWhiteKing);
              break;
            case 'b':
              moves = _getBishopMoves(r, c, !isWhiteKing);
              break;
            case 'q':
              moves = _getQueenMoves(r, c, !isWhiteKing);
              break;
            case 'k':
              moves = _getKingMoves(r, c, !isWhiteKing);
              break;
            default:
              moves = [];
          }
          if (moves.any((move) => move.x == kingPos.x && move.y == kingPos.y)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _updateGameState() {
    final inCheck = isKingInCheck(isWhiteTurn);
    bool hasLegalMoves = false;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] != '' && isWhite(board[r][c]) == isWhiteTurn) {
          if (getLegalMoves(r, c).isNotEmpty) {
            hasLegalMoves = true;
            break;
          }
        }
      }
      if (hasLegalMoves) break;
    }

    if (!hasLegalMoves) {
      gameState = inCheck ? GameState.checkmate : GameState.stalemate;
    } else {
      gameState = inCheck ? GameState.check : GameState.ongoing;
    }
  }

  List<Point<int>> _getPawnMoves(int row, int col, bool isWhitePiece, {bool forCheckDetection = false}) {
    final moves = <Point<int>>[];
    final direction = isWhitePiece ? -1 : 1;
    final startRow = isWhitePiece ? 6 : 1;

    // Captures (only for check detection, pawn moves forward differently)
    if (forCheckDetection) {
      for (var dCol in [-1, 1]) {
        moves.add(Point(row + direction, col + dCol));
      }
      return moves;
    }

    // Forward 1
    if (isSquareEmpty(row + direction, col)) {
      moves.add(Point(row + direction, col));
      // Forward 2 from start
      if (row == startRow && isSquareEmpty(row + 2 * direction, col)) {
        moves.add(Point(row + 2 * direction, col));
      }
    }

    // Capture diagonally
    for (var dCol in [-1, 1]) {
      final newRow = row + direction;
      final newCol = col + dCol;
      if (isOpponent(newRow, newCol, isWhitePiece)) {
        moves.add(Point(newRow, newCol));
      }
    }
    return moves;
  }

  List<Point<int>> _getSlidingMoves(int row, int col, bool isWhitePiece, List<Point<int>> directions) {
    final moves = <Point<int>>[];
    for (var d in directions) {
      for (var i = 1; i < 8; i++) {
        final newRow = row + i * d.x;
        final newCol = col + i * d.y;
        if (!isInBoard(newRow, newCol)) break;
        if (isSquareEmpty(newRow, newCol)) {
          moves.add(Point(newRow, newCol));
        } else {
          if (isOpponent(newRow, newCol, isWhitePiece)) {
            moves.add(Point(newRow, newCol));
          }
          break;
        }
      }
    }
    return moves;
  }

  List<Point<int>> _getRookMoves(int row, int col, bool isWhitePiece) {
    return _getSlidingMoves(row, col, isWhitePiece, [
      const Point(-1, 0), const Point(1, 0), const Point(0, -1), const Point(0, 1)
    ]);
  }

  List<Point<int>> _getBishopMoves(int row, int col, bool isWhitePiece) {
    return _getSlidingMoves(row, col, isWhitePiece, [
      const Point(-1, -1), const Point(-1, 1), const Point(1, -1), const Point(1, 1)
    ]);
  }

  List<Point<int>> _getQueenMoves(int row, int col, bool isWhitePiece) {
    return _getRookMoves(row, col, isWhitePiece)..addAll(_getBishopMoves(row, col, isWhitePiece));
  }

  List<Point<int>> _getKnightMoves(int row, int col, bool isWhitePiece) {
    final moves = <Point<int>>[];
    final knightMoves = [
      const Point(-2, -1), const Point(-2, 1), const Point(-1, -2), const Point(-1, 2),
      const Point(1, -2), const Point(1, 2), const Point(2, -1), const Point(2, 1)
    ];

    for (var move in knightMoves) {
      final newRow = row + move.x;
      final newCol = col + move.y;
      if (isInBoard(newRow, newCol) && !isWhite(board[newRow][newCol] == '' ? '' : board[newRow][newCol])) {
         if(isSquareEmpty(newRow, newCol) || isOpponent(newRow, newCol, isWhitePiece)){
            moves.add(Point(newRow, newCol));
         }
      }
    }
    return moves;
  }

  List<Point<int>> _getKingMoves(int row, int col, bool isWhitePiece) {
    final moves = <Point<int>>[];
    final kingMoves = [
      const Point(-1, -1), const Point(-1, 0), const Point(-1, 1), const Point(0, -1),
      const Point(0, 1), const Point(1, -1), const Point(1, 0), const Point(1, 1)
    ];

    for (var move in kingMoves) {
      final newRow = row + move.x;
      final newCol = col + move.y;
      if (isInBoard(newRow, newCol)) {
        if(isSquareEmpty(newRow, newCol) || isOpponent(newRow, newCol, isWhitePiece)){
           moves.add(Point(newRow, newCol));
        }
      }
    }
    return moves;
  }

  void movePiece(int fromRow, int fromCol, int toRow, int toCol) {
    final legalMoves = getLegalMoves(fromRow, fromCol);
    final isLegal = legalMoves.any((move) => move.x == toRow && move.y == toCol);

    if (isLegal) {
      final piece = board[fromRow][fromCol];
      board[toRow][toCol] = piece;
      board[fromRow][fromCol] = '';

      // Update king position
      if (piece.toLowerCase() == 'k') {
        if (isWhiteTurn) {
          whiteKingPos = Point(toRow, toCol);
        } else {
          blackKingPos = Point(toRow, toCol);
        }
      }

      isWhiteTurn = !isWhiteTurn;
      _updateGameState();
    }
  }
}
