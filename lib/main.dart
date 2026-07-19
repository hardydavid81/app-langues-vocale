import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lettres Tombantes',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Distribution des lettres pondérée façon fréquence anglaise
// (les lettres courantes reviennent plus souvent).
const String _letterPool =
    "EEEEEEEEEEEEAAAAAAAAAARRRRRRRRRIIIIIIIIIOOOOOOOOOTTTTTTTTTNNNNNNNSSSSSSSLLLLLLLCCCCCUUUUUDDDDDPPPPPMMMMMHHHHHGGGGBBBFFFYYYWWWKKVVXXZZJJQQ";

// Liste de mots anglais valides (3 à 6 lettres) pour la détection.
final Set<String> _wordList = {
  "CAT","DOG","SUN","RUN","FUN","BAT","RAT","MAT","HAT","SIT","BIG","PIG","WIN",
  "TEN","TEA","SEA","EAT","ATE","TAP","TOP","POT","HOT","HOP","HIP","LIP","LID",
  "KID","RED","BED","LEG","LOG","FOG","JOG","JOB","JAM","HAM","HAS","HAD","BAD",
  "BAG","TAG","TAN","MAN","CAN","VAN","FAN","PAN","PEN","HEN","DEN","YES","YET",
  "NET","NEW","NOW","NOT","GOT","GET","LET","SET","BET","MET","WET","VET","ICE",
  "ACE","AGE","ARM","ART","EAR","EYE","OIL","OWL","OWN","OUT","OFF","ODD","ONE",
  "TWO","SIX","SKY","SAD","SAW","SEE","SAY","SHE","HIM","HIS","HER","WHO","WHY",
  "HOW","LOW","LOT","LEG","LAP","LAW","LAY","LIE","LIT","JOY","JAW","KEY","ARE",
  "AND","ANY","ASK","BUY","BUS","BOX","BOY","BOW","BAR","BAY","CAR","CAP","COW",
  "CUP","CUT","CRY","DAY","DIE","DIG","DIM","DRY","DUE","EGG","END","ERA","FAR",
  "FAT","FEW","FIT","FIX","FLY","FOR","FUR","GAP","GAS","GYM","ICY","INK","JOB",
  "TREE","CARE","RACE","FACE","LACE","LAKE","CAKE","MAKE","TAKE","WAKE","LOVE",
  "MOVE","GAME","NAME","SAME","TIME","LIME","LINE","FINE","WINE","MINE","NINE",
  "PINE","WORD","WORK","WORM","FORM","FARM","WARM","RAIN","MAIN","PAIN","GAIN",
  "BOOK","LOOK","COOK","HOOK","TOOK","MOON","SOON","POOL","COOL","TOOL","ROOM",
  "ZOOM","FOOD","GOOD","WOOD","HOOD","MOOD","STAR","CARD","YARD","HARD","PARK",
  "DARK","MARK","PART","CART","BALL","CALL","FALL","HALL","TALL","WALL","WELL",
  "TELL","BELL","SELL","SHELL","SMELL","GOLD","COLD","HOLD","SOLD","BOLD","FOLD",
  "MILK","SILK","FISH","WISH","DISH","BUSH","RUSH","PUSH","GOAT","BOAT","COAT",
  "ROAD","LOAD","TOAD","HEAD","READ","BEAD","LEAD","DEAL","MEAL","REAL","SEAL",
  "PLAY","STAY","GRAY","TRAY","SPRAY","AWAY","BABY","LADY","BODY","COPY","EASY",
  "BUSY","CITY","DUTY","FIFTY","JELLY","BERRY","MERRY","SORRY","HAPPY","MONEY",
  "HONEY","FUNNY","SUNNY","MUSIC","MAGIC","ROBOT","TIGER","APPLE","EAGLE","TABLE",
  "CABLE","GARDEN","MARKET","WINDOW","PENCIL","ANIMAL","PICNIC","YELLOW","PURPLE",
  "ORANGE","SILVER","GOLDEN","WINTER","SUMMER","SPRING","FRIEND","FAMILY","SCHOOL",
  "CHAIR","TABLE","HOUSE","MOUSE","LIGHT","NIGHT","RIGHT","FIGHT","SIGHT","MIGHT",
  "WATER","PAPER","EARTH","HEART","PLANT","PLANE","TRAIN","BRAIN","SPACE","PLACE",
  "GRAPE","STONE","PHONE","SMILE","WHILE","GREEN","QUEEN","STORM","CLOUD","BREAD",
  "DREAM","CREAM","GREAT","BEACH","TEACH","REACH",
};

const int cols = 9;
const int rows = 15;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final math.Random _rng = math.Random();
  late List<List<String?>> _grid;
  late String _fallingLetter;
  int _fallingCol = cols ~/ 2;
  double _fallingRow = 0;
  Timer? _timer;
  int _score = 0;
  bool _gameOver = false;
  final Set<String> _clearingHighlight = {};

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _grid = List.generate(rows, (_) => List<String?>.filled(cols, null));
    _score = 0;
    _gameOver = false;
    _spawnLetter();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) => _tick());
  }

  String _randomLetter() {
    return _letterPool[_rng.nextInt(_letterPool.length)];
  }

  void _spawnLetter() {
    _fallingLetter = _randomLetter();
    _fallingCol = cols ~/ 2;
    _fallingRow = 0;
    if (_grid[0][_fallingCol] != null) {
      setState(() {
        _gameOver = true;
      });
      _timer?.cancel();
    }
  }

  void _tick() {
    if (_gameOver) return;
    final nextRow = _fallingRow.floor() + 1;
    final atBottom = nextRow >= rows;
    final blocked = !atBottom && _grid[nextRow][_fallingCol] != null;
    if (atBottom || blocked) {
      _lockLetter();
    } else {
      setState(() {
        _fallingRow += 1;
      });
    }
  }

  void _lockLetter() {
    final r = _fallingRow.floor();
    setState(() {
      _grid[r][_fallingCol] = _fallingLetter;
    });
    _checkWordsAndClear();
    _spawnLetter();
  }

  void _moveLeft() {
    if (_gameOver) return;
    final r = _fallingRow.floor();
    if (_fallingCol > 0 && (r >= rows || _grid[r][_fallingCol - 1] == null)) {
      setState(() {
        _fallingCol--;
      });
    }
  }

  void _moveRight() {
    if (_gameOver) return;
    final r = _fallingRow.floor();
    if (_fallingCol < cols - 1 && (r >= rows || _grid[r][_fallingCol + 1] == null)) {
      setState(() {
        _fallingCol++;
      });
    }
  }

  void _dropFast() {
    if (_gameOver) return;
    int r = _fallingRow.floor();
    while (r + 1 < rows && _grid[r + 1][_fallingCol] == null) {
      r++;
    }
    setState(() {
      _fallingRow = r.toDouble();
    });
    _lockLetter();
  }

  // Cherche tous les mots (horizontaux et verticaux) présents dans la grille,
  // les efface, puis applique la gravité pour combler les trous.
  void _checkWordsAndClear() {
    final Set<String> toClear = {};

    // Lignes horizontales
    for (int r = 0; r < rows; r++) {
      final rowStr = List.generate(cols, (c) => _grid[r][c] ?? '.').join();
      for (int start = 0; start < cols; start++) {
        for (int end = start + 3; end <= cols; end++) {
          final segment = rowStr.substring(start, end);
          if (!segment.contains('.') && _wordList.contains(segment)) {
            for (int c = start; c < end; c++) {
              toClear.add("$r,$c");
            }
          }
        }
      }
    }

    // Colonnes verticales
    for (int c = 0; c < cols; c++) {
      final colStr = List.generate(rows, (r) => _grid[r][c] ?? '.').join();
      for (int start = 0; start < rows; start++) {
        for (int end = start + 3; end <= rows; end++) {
          final segment = colStr.substring(start, end);
          if (!segment.contains('.') && _wordList.contains(segment)) {
            for (int r = start; r < end; r++) {
              toClear.add("$r,$c");
            }
          }
        }
      }
    }

    if (toClear.isEmpty) return;

    setState(() {
      for (final key in toClear) {
        final parts = key.split(',');
        final r = int.parse(parts[0]);
        final c = int.parse(parts[1]);
        _grid[r][c] = null;
      }
      _score += toClear.length * 10;
    });

    _applyGravity();
  }

  void _applyGravity() {
    setState(() {
      for (int c = 0; c < cols; c++) {
        final letters = <String>[];
        for (int r = 0; r < rows; r++) {
          if (_grid[r][c] != null) letters.add(_grid[r][c]!);
        }
        for (int r = 0; r < rows; r++) {
          _grid[r][c] = null;
        }
        int writeRow = rows - 1;
        for (int i = letters.length - 1; i >= 0; i--) {
          _grid[writeRow][c] = letters[i];
          writeRow--;
        }
      }
    });
    // Une chute peut recréer un mot : on revérifie une fois.
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _checkWordsAndClear();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1D2A),
      appBar: AppBar(
        title: const Text('Lettres Tombantes'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "Score : $_score",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: cols / rows,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = constraints.maxWidth / cols;
                      return Stack(
                        children: [
                          Container(color: const Color(0xFF10121C)),
                          for (int r = 0; r < rows; r++)
                            for (int c = 0; c < cols; c++)
                              if (_grid[r][c] != null)
                                Positioned(
                                  left: c * cellSize,
                                  top: r * cellSize,
                                  width: cellSize,
                                  height: cellSize,
                                  child: _LetterCell(letter: _grid[r][c]!, cellSize: cellSize),
                                ),
                          if (!_gameOver)
                            Positioned(
                              left: _fallingCol * cellSize,
                              top: _fallingRow * cellSize,
                              width: cellSize,
                              height: cellSize,
                              child: _LetterCell(
                                letter: _fallingLetter,
                                cellSize: cellSize,
                                falling: true,
                              ),
                            ),
                          if (_gameOver)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.75),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Partie terminée",
                                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Score : $_score",
                                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => setState(() => _startNewGame()),
                                        child: const Text("Rejouer"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(icon: Icons.arrow_back, onTap: _moveLeft),
                  _ControlButton(icon: Icons.arrow_downward, onTap: _dropFast),
                  _ControlButton(icon: Icons.arrow_forward, onTap: _moveRight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterCell extends StatelessWidget {
  final String letter;
  final double cellSize;
  final bool falling;
  const _LetterCell({required this.letter, required this.cellSize, this.falling = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(cellSize * 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: falling ? Colors.amber.shade600 : Colors.indigo.shade400,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black26, width: 1),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: cellSize * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.indigo,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

