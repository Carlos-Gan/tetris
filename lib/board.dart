// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Tetris/piece.dart';
import 'package:Tetris/pixel.dart';
import 'package:Tetris/values.dart';

// Tablero de juego: filas x columnas
typedef Board = List<List<Tetromino?>>;
Board gameBoard = List.generate(
  rows,
  (_) => List.generate(columns, (_) => null),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late Piece currentPiece;
  Timer? gameTimer;

  bool isGameOver = false;
  bool isPaused = false;
  bool isMusicPaused = false;
  int currentScore = 0;
  int maxScore = 0;

  // Audios de juego
  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _sfxPlayer;

  // Velocidad base en milisegundos
  static const int baseSpeed = 600;
  // Reducción de velocidad por cada 500 puntos
  static const int speedStep = 50;
  // Puntaje necesario para aumentar nivel
  static const int scoreThreshold = 500;

  @override
  void initState() {
    super.initState();
    // Inicializar la pieza antes de build
    currentPiece = Piece(
      type: Tetromino.values[Random().nextInt(Tetromino.values.length)],
    );

    // Música de fondo en loop
    _bgPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _bgPlayer.setVolume(0.5);
    _bgPlayer.play(AssetSource('sounds/musica.mp3'));

    // Player para efectos de sonido
    _sfxPlayer = AudioPlayer();

    // Cargar configuración y comenzar juego
    _loadSettings().then((_) {
      _startNewGame();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      maxScore = prefs.getInt('highScore') ?? 0;
      isMusicPaused = prefs.getBool('musicPaused') ?? false;
      if (isMusicPaused) {
        _bgPlayer.pause();
      }
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', maxScore);
  }

  Future<void> _saveMusicSetting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicPaused', isMusicPaused);
  }

  void _startNewGame() {
    setState(() {
      gameBoard = List.generate(
        rows,
        (_) => List.generate(columns, (_) => null),
      );
      currentScore = 0;
      isGameOver = false;
      isPaused = false;
      currentPiece = Piece(
        type: Tetromino.values[Random().nextInt(Tetromino.values.length)],
      );
    });
    _startGameLoop();
  }

  void _startGameLoop() {
    gameTimer?.cancel();
    if (isPaused) return;
    final speed = _computeSpeed();
    print('Current fall speed: ${speed}ms per tick');
    gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (isGameOver || isPaused) {
        timer.cancel();
        if (isGameOver) _onGameOver();
        return;
      }
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        clearLines();
        if (checkColision(Direction.down)) {
          checkLanding();
        } else {
          currentPiece.move(Direction.down);
        }
      });
    });
  }

  int _computeSpeed() {
    final levels = currentScore ~/ scoreThreshold;
    final speed = baseSpeed - levels * speedStep;
    return max(speed, 100);
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        gameTimer?.cancel();
        _bgPlayer.pause();
      } else {
        _bgPlayer.resume();
        _startGameLoop();
      }
    });
  }

  bool checkColision(Direction direction) {
    for (int pos in currentPiece.positions) {
      int row = pos ~/ columns;
      int col = pos % columns;
      int newRow = row + (direction == Direction.down ? 1 : 0);
      int newCol =
          col +
          (direction == Direction.left
              ? -1
              : direction == Direction.right
              ? 1
              : 0);
      if (newCol < 0 || newCol >= columns) return true;
      if (newRow >= rows) return true;
      if (newRow >= 0 && gameBoard[newRow][newCol] != null) return true;
    }
    return false;
  }

  void checkLanding() {
    for (int pos in currentPiece.positions) {
      int row = pos ~/ columns;
      int col = pos % columns;
      if (row >= 0 && row < rows && col >= 0 && col < columns) {
        gameBoard[row][col] = currentPiece.type;
      }
    }
    _spawnNewPiece();
  }

  void _spawnNewPiece() {
    setState(() {
      currentPiece = Piece(
        type: Tetromino.values[Random().nextInt(Tetromino.values.length)],
      );
    });
    if (_isGameOver()) {
      isGameOver = true;
      gameTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onGameOver();
      });
    }
  }

  bool _isGameOver() {
    for (var pos in currentPiece.positions) {
      int row = pos ~/ columns;
      int col = pos % columns;
      if (row >= 0 &&
          row < rows &&
          col >= 0 &&
          col < columns &&
          gameBoard[row][col] != null) {
        return true;
      }
    }
    return false;
  }

  void moveLeft() {
    if (!isPaused) {
      setState(() {
        if (!checkColision(Direction.left)) currentPiece.move(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!isPaused) {
      setState(() {
        if (!checkColision(Direction.right)) currentPiece.move(Direction.right);
      });
    }
  }

  void rotatePiece() {
    if (!isPaused) {
      setState(() {
        currentPiece.rotateCW();
      });
    }
  }

  void clearLines() {
    // Desplaza las filas usando un puntero de escritura (writeRow)
    int writeRow = rows - 1;
    for (int row = rows - 1; row >= 0; row--) {
      // ¿Está completa la fila?
      bool isComplete = gameBoard[row].every((cell) => cell != null);
      if (!isComplete) {
        // Copia la fila actual a writeRow
        gameBoard[writeRow] = gameBoard[row];
        writeRow--;
      } else {
        // Fila completa: suma puntos y suena el SFX
        currentScore += 100;
        if (currentScore > maxScore) {
          maxScore = currentScore;
          _saveHighScore();
        }
        if (!isMusicPaused) {
          _sfxPlayer.setVolume(0.5);
          _sfxPlayer.play(AssetSource('sounds/linea_1.mp3'));
          Future.delayed(const Duration(seconds: 2), () {
            _bgPlayer.setVolume(0.5);
            _bgPlayer.play(AssetSource('sounds/musica.mp3'));
            Future.delayed(const Duration(seconds: 2), () {
              _bgPlayer.setVolume(0.0);
              _bgPlayer.play(AssetSource('sounds/musica.mp3'));
              _bgPlayer.setVolume(0.5);
              _bgPlayer.resume();
            });
          });
        }
      }
    }

    // Rellena las filas vacías arriba
    for (int r = writeRow; r >= 0; r--) {
      gameBoard[r] = List<Tetromino?>.filled(columns, null);
    }

    // Ajusta el tick rate según la nueva puntuación
    _startGameLoop();
  }

  void _onGameOver() {
    if (!mounted) return;
    if (!isMusicPaused) {
      _sfxPlayer.play(AssetSource('sounds/perder.mp3'));
    }
    _bgPlayer.setVolume(0.0);
    _showGameOverDialog();
  }

  void _pauseGameForSettings() {
    if (!isPaused && !isGameOver) {
      setState(() {
        isPaused = true;
      });
      gameTimer?.cancel();
      _bgPlayer.pause();
    }
  }

  void _resumeGameAfterSettings() {
    if (!isGameOver && isPaused) {
      setState(() {
        isPaused = false;
      });
      _bgPlayer.resume();
      _startGameLoop();
    }
  }

  void _showSettingsMenu() async {
    bool pausedBySettings = false;
    if (!isPaused && !isGameOver) {
      _pauseGameForSettings();
      pausedBySettings = true;
    }
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[800],
      builder: (BuildContext ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              value: isMusicPaused,
              secondary: Icon(Icons.music_note),
              title: Text(
                isMusicPaused ? 'Reanudar música' : 'Pausar música',
                style: TextStyle(color: Colors.white),
              ),
              onChanged: (val) async {
                Navigator.of(ctx).pop();
                setState(() {
                  isMusicPaused = val;
                });
                await _saveMusicSetting();
                if (isMusicPaused) {
                  _bgPlayer.pause();
                } else {
                  _bgPlayer.resume();
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text(
                'Regresar al menú',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        );
      },
    ).whenComplete(() {
      if (pausedBySettings) {
        _resumeGameAfterSettings();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[800],
            title: const Text(
              'Game Over',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Your score: $currentScore',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startNewGame();
                },
                child: const Text(
                  'Restart',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _togglePause,
                  icon: Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'High Score: $maxScore',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      'Score: $currentScore',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _showSettingsMenu,
                  icon: Icon(Icons.settings, size: 30, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              itemCount: rows * columns,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ columns;
                int col = index % columns;
                if (currentPiece.positions.contains(index)) {
                  return Pixel(color: currentPiece.color, child: '');
                }
                if (gameBoard[row][col] != null) {
                  return Pixel(
                    color: tetrominoColors[gameBoard[row][col]!]!,
                    child: '',
                  );
                }
                return Pixel(color: Colors.grey[900]!, child: '');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 90.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: moveLeft,
                  icon: Icon(Icons.arrow_back, size: 35, color: Colors.white),
                ),
                IconButton(
                  onPressed: rotatePiece,
                  icon: Icon(Icons.rotate_right, size: 35, color: Colors.white),
                ),
                IconButton(
                  onPressed: moveRight,
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
