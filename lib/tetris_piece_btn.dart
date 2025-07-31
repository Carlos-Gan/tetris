
import 'package:Tetris/tetris_shape_border.dart';
import 'package:Tetris/values.dart';
import 'package:flutter/material.dart';

class TetrisPieceButton extends StatelessWidget {
  final Tetromino type;
  final VoidCallback onPressed;
  final String label;
  final double width;
  final double height;

  const TetrisPieceButton({
    super.key,
    required this.type,
    required this.onPressed,
    required this.label,
    this.width = 140,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final color = tetrominoColors[type]!;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: TetrisShapeBorder(type: type),
          child: Ink(
            decoration: ShapeDecoration(
              color: color,
              shape: TetrisShapeBorder(type: type),
              shadows: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                
              ),
            ),
          ),
        ),
      ),
    );
  }
}
