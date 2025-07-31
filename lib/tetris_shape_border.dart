// Matrices 4x4 (igual a tu lógica de shapes, pero en forma de grid para dibujo)
import 'dart:math';

import 'package:Tetris/values.dart';
import 'package:flutter/material.dart';

const Map<Tetromino, List<List<int>>> _shapeMatrix = {
  Tetromino.I: [
    [0, 0, 0, 0],
    [1, 1, 1, 1],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
  Tetromino.O: [
    [0, 1, 1, 0],
    [0, 1, 1, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
  Tetromino.T: [
    [0, 1, 0, 0],
    [1, 1, 1, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
  Tetromino.S: [
    [0, 1, 1, 0],
    [1, 1, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
  Tetromino.Z: [
    [1, 1, 0, 0],
    [0, 1, 1, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
  Tetromino.J: [
    [1, 0, 0, 0],
    [1, 1, 1, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
  Tetromino.L: [
    [0, 0, 1, 0],
    [1, 1, 1, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
};

class TetrisShapeBorder extends ShapeBorder {
  final Tetromino type;
  final double blockGap;
  final double cornerRadius;

  const TetrisShapeBorder({
    required this.type,
    this.blockGap = 2.0,
    this.cornerRadius = 4.0,
  });

  Path _buildPath(Rect rect) {
    final matrix = _shapeMatrix[type]!;
    const gridSize = 4;

    // Calcula tamaño de celda para que quepan dentro del rect (centrado)
    final totalGap = blockGap * (gridSize - 1);
    final maxCell = (min(rect.width, rect.height) - totalGap) / gridSize;
    final cellSize = maxCell;

    final pieceWidth = gridSize * cellSize + totalGap;
    final offsetX = rect.center.dx - pieceWidth / 2;
    final offsetY = rect.center.dy - pieceWidth / 2;

    Path path = Path();
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (matrix[r][c] == 1) {
          final dx = offsetX + c * (cellSize + blockGap);
          final dy = offsetY + r * (cellSize + blockGap);
          final blockRect =
              Rect.fromLTWH(dx, dy, cellSize, cellSize).deflate(0);
          path.addRRect(RRect.fromRectAndRadius(
              blockRect, Radius.circular(cornerRadius)));
        }
      }
    }

    // Unión de todos los bloques para área activa
    return Path.combine(PathOperation.union, path, Path());
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _buildPath(rect);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // No pinta nada aquí; el relleno se hace en el widget que usa este border.
  }

  @override
  ShapeBorder scale(double t) => this;
}
