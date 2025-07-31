import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:Tetris/board.dart';
import 'package:Tetris/values.dart';

class Piece {
  final Tetromino type;

  // Índice de rotación 0..3
  int rotationIndex = 0;

  // Pivote (columna, fila)
  Point<int> pivot;

  Piece({ required this.type })
      : pivot = Point(columns ~/ 2, -2);

  // Estados predefinidos para cada Tetromino:
  static final Map<Tetromino, List<List<Point<int>>>> _allShapes = {
    Tetromino.I: [
      [Point(-2,0), Point(-1,0), Point(0,0), Point(1,0)],
      [Point(0,-2), Point(0,-1), Point(0,0), Point(0,1)],
      [Point(-2,0), Point(-1,0), Point(0,0), Point(1,0)],
      [Point(0,-2), Point(0,-1), Point(0,0), Point(0,1)],
    ],
    Tetromino.J: [
      [Point(-1,0), Point(0,0), Point(1,0), Point(1,1)],
      [Point(0,-1), Point(0,0), Point(0,1), Point(1,-1)],
      [Point(-1,-1),Point(-1,0), Point(0,0), Point(1,0)],
      [Point(0,1), Point(0,0), Point(0,-1),Point(-1,1)],
    ],
    Tetromino.L: [
      [Point(-1,0), Point(0,0), Point(1,0), Point(-1,1)],
      [Point(0,-1), Point(0,0), Point(0,1), Point(1,1)],
      [Point(1,-1), Point(-1,0), Point(0,0), Point(1,0)],
      [Point(0,-1), Point(0,0), Point(0,1), Point(-1,-1)],
    ],
    Tetromino.O: [
      [Point(0,0), Point(1,0), Point(0,1), Point(1,1)],
      [Point(0,0), Point(1,0), Point(0,1), Point(1,1)],
      [Point(0,0), Point(1,0), Point(0,1), Point(1,1)],
      [Point(0,0), Point(1,0), Point(0,1), Point(1,1)],
    ],
    Tetromino.S: [
      [Point(-1,1), Point(0,1), Point(0,0), Point(1,0)],
      [Point(1,1), Point(1,0), Point(0,0), Point(0,-1)],
      [Point(-1,1), Point(0,1), Point(0,0), Point(1,0)],
      [Point(1,1), Point(1,0), Point(0,0), Point(0,-1)],
    ],
    Tetromino.T: [
      [Point(-1,0), Point(0,0), Point(1,0), Point(0,1)],
      [Point(0,-1), Point(0,0), Point(0,1), Point(1,0)],
      [Point(-1,0), Point(0,0), Point(1,0), Point(0,-1)],
      [Point(0,-1), Point(0,0), Point(0,1), Point(-1,0)],
    ],
    Tetromino.Z: [
      [Point(-1,0), Point(0,0), Point(0,1), Point(1,1)],
      [Point(1,-1), Point(1,0), Point(0,0), Point(0,1)],
      [Point(-1,0), Point(0,0), Point(0,1), Point(1,1)],
      [Point(1,-1), Point(1,0), Point(0,0), Point(0,1)],
    ],
  };

  // Obtiene los offsets del estado actual
  List<Point<int>> get _currentOffsets =>
      _allShapes[type]![rotationIndex];

  // Calcula las posiciones absolutas (índices 1D) de los cuatro bloques
  List<int> get positions => _currentOffsets.map((off) {
        final x = pivot.x + off.x;
        final y = pivot.y + off.y;
        // conv 2D→1D
        return y * columns + x;
      }).toList();

  Color get color => tetrominoColors[type]!;

  // ------------------------------------------------------------------
  // MOVIMIENTO
  // ------------------------------------------------------------------
  bool _isCollision(Point<int> testPivot, List<Point<int>> testOffsets) {
    for (var off in testOffsets) {
      final x = testPivot.x + off.x;
      final y = testPivot.y + off.y;
      // límites
      if (x < 0 || x >= columns || y >= rows) return true;
      // colisión solo si y>=0
      if (y >= 0 && gameBoard[y][x] != null) return true;
    }
    return false;
  }

  void move(Direction dir) {
    final delta = {
      Direction.left:  Point(-1, 0),
      Direction.right: Point( 1, 0),
      Direction.down:  Point( 0, 1),
    }[dir]!;

    final testPivot = Point(pivot.x + delta.x, pivot.y + delta.y);
    if (!_isCollision(testPivot, _currentOffsets)) {
      pivot = testPivot;
    }
  }

  // ------------------------------------------------------------------
  // ROTACIÓN
  // ------------------------------------------------------------------
  void rotateCW() {
    final next = (rotationIndex + 1) % 4;
    if (!_isCollision(pivot, _allShapes[type]![next])) {
      rotationIndex = next;
    }
  }

  void rotateCCW() {
    final next = (rotationIndex + 3) % 4;
    if (!_isCollision(pivot, _allShapes[type]![next])) {
      rotationIndex = next;
    }
  }

  // ------------------------------------------------------------------
  // AL Aterrizar: fijar al tablero
  // ------------------------------------------------------------------
  void fixToBoard() {
    for (var off in _currentOffsets) {
      final x = pivot.x + off.x;
      final y = pivot.y + off.y;
      if (y >= 0 && y < rows && x >= 0 && x < columns) {
        gameBoard[y][x] = type;
      }
    }
  }
}
