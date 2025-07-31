//Griddy

import 'package:flutter/material.dart';

int rows = 15;
int columns = 11;

enum Tetromino { L, J, I, O, S, Z, T }

enum Direction { left, right, down, up }

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Colors.blue,
  Tetromino.J: Colors.orange,
  Tetromino.I: Colors.cyan,
  Tetromino.O: Colors.yellow,
  Tetromino.S: Colors.green,
  Tetromino.Z: Colors.red,
  Tetromino.T: Colors.purple,
};
