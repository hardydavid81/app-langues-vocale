import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class Character {
  final String name;
  final String emoji;
  final String personality;
  final String ttsLocale;
  const Character(this.name, this.emoji, this.personality, this.ttsLocale);
}

const List<Character> characters = [
  Character(
    "Pierre",
    "🇫🇷",
    "Tu es Pierre, un Parisien blasé et un peu snob. Tu soupires souvent, tu trouves tout 'pas terrible', et tu glisses des mots français par-ci par-là même en parlant la langue cible.",
    "fr-FR",
  ),
  Character(
    "Kevin",
    "🤠",
    "Tu es Kevin, un cowboy texan hyper enthousiaste. Tu dis 'yeehaw', tu compares tout à des chevaux ou du barbecue, et tu es exagérément amical.",
    "en-US",
  ),
  Character(
    "Giovanni",
    "🇮🇹",
    "Tu es Giovanni, un Italien passionné et dramatique. Tu parles avec de grands gestes (decris-les entre parentheses), tu t'exclames souvent 'Mamma mia!', et tu adores la nourriture.",
    "it-IT",
  ),
  Character(
    "Yuki",
    "🇯🇵",
    "Tu es Yuki, energique et suraigüe, style personnage d'anime. Tu es toujours super enthousiaste, tu utilises plein de kawaii et de superlatifs.",
    "ja-JP",
  ),
  Character(
    "Angus",
    "🏴",
    "Tu es Angus, un Ecossais bourru des Highlands. Tu es direct, un peu grognon mais chaleureux au fond, et tu mentionnes souvent le mauvais temps ou le whisky.",
    "en-GB",
  ),
];

// Uniquement 2 langues pour cette version de l'app : Anglais et Français.
// Pour une autre paire de langues, il suffit de dupliquer ce fichier et de
// changer languageLocales, _languages, et le contenu des banques ci-dessous.
final Map<String, String> languageLocales = {
  "Anglais": "en-US",
  "Français": "fr-FR",
};

final math.Random _rng = math.Random();

// Chaque entrée : "word" = mot dans la langue pratiquée, "fr" = traduction française.
// Pour la banque "Français", on dérive automatiquement l'inverse de la banque
// "Anglais" (word=français, fr=anglais) pour éviter de dupliquer les données.
List<Map<String, String>> _deriveFrench(List<Map<String, String>> englishList) {
  return englishList.map((e) => {"word": e["fr"]!, "fr": e["word"]!}).toList();
}

final List<Map<String, String>> _englishWords = [
  {"word": "Hello", "fr": "Bonjour"},
  {"word": "Cat", "fr": "Chat"},
  {"word": "Friend", "fr": "Ami"},
  {"word": "Happy", "fr": "Heureux"},
  {"word": "Water", "fr": "Eau"},
  {"word": "Beautiful", "fr": "Beau"},
  {"word": "House", "fr": "Maison"},
  {"word": "Dog", "fr": "Chien"},
  {"word": "Sun", "fr": "Soleil"},
  {"word": "Moon", "fr": "Lune"},
  {"word": "Book", "fr": "Livre"},
  {"word": "Love", "fr": "Amour"},
  {"word": "Time", "fr": "Temps"},
  {"word": "Food", "fr": "Nourriture"},
  {"word": "Family", "fr": "Famille"},
  {"word": "Bread", "fr": "Pain"},
  {"word": "Music", "fr": "Musique"},
  {"word": "Tree", "fr": "Arbre"},
  {"word": "Sea", "fr": "Mer"},
  {"word": "Sky", "fr": "Ciel"},
  {"word": "Bird", "fr": "Oiseau"},
  {"word": "Flower", "fr": "Fleur"},
  {"word": "School", "fr": "École"},
  {"word": "Work", "fr": "Travail"},
  {"word": "Night", "fr": "Nuit"},
  {"word": "Day", "fr": "Jour"},
  {"word": "Good", "fr": "Bon"},
  {"word": "Big", "fr": "Grand"},
  {"word": "Small", "fr": "Petit"},
  {"word": "Fast", "fr": "Rapide"},
  {"word": "Slow", "fr": "Lent"},
  {"word": "Color", "fr": "Couleur"},
  {"word": "Red", "fr": "Rouge"},
  {"word": "Blue", "fr": "Bleu"},
  {"word": "Green", "fr": "Vert"},
  {"word": "Mother", "fr": "Mère"},
  {"word": "Father", "fr": "Père"},
  {"word": "Brother", "fr": "Frère"},
  {"word": "Sister", "fr": "Sœur"},
  {"word": "Child", "fr": "Enfant"},
  {"word": "Head", "fr": "Tête"},
  {"word": "Hand", "fr": "Main"},
  {"word": "Eye", "fr": "Œil"},
  {"word": "Mouth", "fr": "Bouche"},
  {"word": "Rain", "fr": "Pluie"},
  {"word": "Wind", "fr": "Vent"},
  {"word": "Snow", "fr": "Neige"},
  {"word": "Today", "fr": "Aujourd'hui"},
  {"word": "Tomorrow", "fr": "Demain"},
  {"word": "Yesterday", "fr": "Hier"},
  {"word": "Thanks", "fr": "Merci"},
  {"word": "Please", "fr": "S'il vous plaît"},
  {"word": "Yes", "fr": "Oui"},
  {"word": "No", "fr": "Non"},
  {"word": "Sorry", "fr": "Désolé"},
  {"word": "Name", "fr": "Nom"},
];

final List<Map<String, String>> _englishPhrases = [
  {"word": "How are you?", "fr": "Comment vas-tu ?"},
  {"word": "What is your name?", "fr": "Comment tu t'appelles ?"},
  {"word": "Nice to meet you", "fr": "Enchanté"},
  {"word": "I don't understand", "fr": "Je ne comprends pas"},
  {"word": "Can you help me?", "fr": "Peux-tu m'aider ?"},
  {"word": "Where is the bathroom?", "fr": "Où sont les toilettes ?"},
  {"word": "How much is it?", "fr": "Combien ça coûte ?"},
  {"word": "I would like...", "fr": "Je voudrais..."},
  {"word": "See you later", "fr": "À plus tard"},
  {"word": "Have a good day", "fr": "Bonne journée"},
  {"word": "What time is it?", "fr": "Quelle heure est-il ?"},
  {"word": "I am hungry", "fr": "J'ai faim"},
  {"word": "I am thirsty", "fr": "J'ai soif"},
  {"word": "I am tired", "fr": "Je suis fatigué"},
  {"word": "Where are you from?", "fr": "D'où viens-tu ?"},
  {"word": "I speak a little", "fr": "Je parle un peu"},
  {"word": "Can you repeat?", "fr": "Peux-tu répéter ?"},
  {"word": "Slower please", "fr": "Plus lentement s'il te plaît"},
  {"word": "It's delicious", "fr": "C'est délicieux"},
  {"word": "Congratulations", "fr": "Félicitations"},
];

final List<Map<String, String>> _englishNumbers = [
  {"word": "One", "fr": "Un"},
  {"word": "Two", "fr": "Deux"},
  {"word": "Three", "fr": "Trois"},
  {"word": "Four", "fr": "Quatre"},
  {"word": "Five", "fr": "Cinq"},
  {"word": "Six", "fr": "Six"},
  {"word": "Seven", "fr": "Sept"},
  {"word": "Eight", "fr": "Huit"},
  {"word": "Nine", "fr": "Neuf"},
  {"word": "Ten", "fr": "Dix"},
  {"word": "Twenty", "fr": "Vingt"},
  {"word": "Fifty", "fr": "Cinquante"},
  {"word": "Hundred", "fr": "Cent"},
  {"word": "Thousand", "fr": "Mille"},
];

final List<Map<String, String>> _englishVerbs = [
  {"word": "To eat", "fr": "Manger"},
  {"word": "To drink", "fr": "Boire"},
  {"word": "To sleep", "fr": "Dormir"},
  {"word": "To walk", "fr": "Marcher"},
  {"word": "To speak", "fr": "Parler"},
  {"word": "To see", "fr": "Voir"},
  {"word": "To come", "fr": "Venir"},
  {"word": "To go", "fr": "Aller"},
  {"word": "To read", "fr": "Lire"},
  {"word": "To write", "fr": "Écrire"},
  {"word": "To think", "fr": "Penser"},
  {"word": "To want", "fr": "Vouloir"},
  {"word": "To need", "fr": "Avoir besoin"},
  {"word": "To love", "fr": "Aimer"},
  {"word": "To work", "fr": "Travailler"},
  {"word": "To play", "fr": "Jouer"},
  {"word": "To learn", "fr": "Apprendre"},
  {"word": "To buy", "fr": "Acheter"},
];

final Map<String, List<Map<String, String>>> wordBank = {
  "Anglais": _englishWords,
  "Français": _deriveFrench(_englishWords),
};

final Map<String, List<Map<String, String>>> phraseBank = {
  "Anglais": _englishPhrases,
  "Français": _deriveFrench(_englishPhrases),
};

final Map<String, List<Map<String, String>>> numberBank = {
  "Anglais": _englishNumbers,
  "Français": _deriveFrench(_englishNumbers),
};

final Map<String, List<Map<String, String>>> verbBank = {
  "Anglais": _englishVerbs,
  "Français": _deriveFrench(_englishVerbs),
};

class CatSprite extends StatefulWidget {
  final Color patchColor;
  final Size size;
  final String tailStyle;
  final Duration cycleDuration;
  const CatSprite({
    super.key,
    this.patchColor = const Color(0xFF1A1A1A),
    this.size = const Size(60, 66),
    this.tailStyle = "classic",
    this.cycleDuration = const Duration(milliseconds: 400),
  });

  @override
  State<CatSprite> createState() => _CatSpriteState();
}

class _CatSpriteState extends State<CatSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _walkCycle;

  @override
  void initState() {
    super.initState();
    _walkCycle = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _walkCycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _walkCycle,
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: CatPainter(
            walkValue: _walkCycle.value,
            patchColor: widget.patchColor,
            tailStyle: widget.tailStyle,
          ),
        );
      },
    );
  }
}

class CatPainter extends CustomPainter {
  final double walkValue;
  final Color patchColor;
  final String tailStyle;
  CatPainter({
    required this.walkValue,
    this.patchColor = const Color(0xFF1A1A1A),
    this.tailStyle = "classic",
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(0, 20);

    final blackFill = Paint()..color = const Color(0xFF1A1A1A);
    final blackStroke = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final whiteFill = Paint()..color = Colors.white;
    final pinkFill = Paint()..color = const Color(0xFFFFC2D1);
    final whiskerPaint = Paint()
      ..color = const Color(0xFF1A1A1A).withOpacity(0.7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final patchFill = Paint()..color = patchColor;

    canvas.drawLine(const Offset(-8, 24), const Offset(16, 26), whiskerPaint);
    canvas.drawLine(const Offset(-8, 30), const Offset(16, 30), whiskerPaint);
    canvas.drawLine(const Offset(-8, 36), const Offset(16, 33), whiskerPaint);
    canvas.drawLine(const Offset(54, 26), const Offset(78, 22), whiskerPaint);
    canvas.drawLine(const Offset(54, 30), const Offset(78, 28), whiskerPaint);
    canvas.drawLine(const Offset(54, 33), const Offset(78, 35), whiskerPaint);

    // Queue (pivote autour du point d'attache au corps)
    canvas.save();
    canvas.translate(62, 66);
    final tailAngle = (-8 + walkValue * 18) * math.pi / 180;
    canvas.rotate(tailAngle);
    canvas.translate(-62, -66);
    final tailPath = Path()..moveTo(62, 66);
    switch (tailStyle) {
      case "hooked": // Chiffres : courte, avec un crochet à l'extrémité
        tailPath
          ..quadraticBezierTo(86, 58, 88, 42)
          ..quadraticBezierTo(78, 28, 90, 20);
        break;
      case "curled": // Expressions : s'enroule vers le bas
        tailPath
          ..quadraticBezierTo(90, 76, 86, 86)
          ..quadraticBezierTo(72, 88, 60, 80);
        break;
      case "stubby": // Verbes : courte et trapue
        tailPath
          ..quadraticBezierTo(78, 62, 79, 50)
          ..quadraticBezierTo(79, 40, 68, 39);
        break;
      case "classic": // Mots : arc classique
      default:
        tailPath
          ..quadraticBezierTo(88, 64, 90, 46)
          ..quadraticBezierTo(86, 30, 70, 26);
    }
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    void drawLeg(double x, double yTop, bool sameSide) {
      final angle = sameSide ? walkValue : 1 - walkValue;
      final tilt = (angle - 0.5) * 28 * math.pi / 180;
      canvas.save();
      canvas.translate(x + 3, yTop);
      canvas.rotate(tilt);
      canvas.translate(-(x + 3), -yTop);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, yTop, 6, 14),
        const Radius.circular(3),
      );
      canvas.drawRRect(rrect, blackFill);
      canvas.restore();
    }

    drawLeg(28, 68, true);
    drawLeg(38, 68, false);

    // Corps
    final bodyRect = Rect.fromCenter(center: const Offset(45, 62), width: 56, height: 40);
    canvas.drawOval(bodyRect, whiteFill);
    canvas.drawOval(bodyRect, blackStroke);
    canvas.save();
    canvas.clipPath(Path()..addOval(bodyRect));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(66, 55), width: 36, height: 44),
      patchFill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(35, 70), width: 20, height: 14),
      Paint()..color = const Color(0xFFFFC2D1).withOpacity(0.55),
    );
    canvas.restore();

    drawLeg(52, 76, true);
    drawLeg(62, 76, false);

    // Tete
    canvas.drawCircle(const Offset(35, 28), 26, whiteFill);
    canvas.drawCircle(const Offset(35, 28), 26, blackStroke);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: const Offset(35, 28), radius: 26)));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 20), width: 32, height: 36),
      patchFill,
    );
    canvas.restore();

    // Oreille gauche
    final earLeftFill = Path()
      ..moveTo(13, 10)
      ..quadraticBezierTo(9, -3, 18, -12)
      ..quadraticBezierTo(26, -2, 29, 8)
      ..quadraticBezierTo(21, 4, 13, 10)
      ..close();
    canvas.drawPath(earLeftFill, whiteFill);
    final earLeftStroke = Path()
      ..moveTo(13, 10)
      ..quadraticBezierTo(9, -3, 18, -12)
      ..quadraticBezierTo(26, -2, 29, 8);
    canvas.drawPath(earLeftStroke, blackStroke);

    // Oreille droite
    final earRightFill = Path()
      ..moveTo(39, 6)
      ..quadraticBezierTo(44, -6, 48, -14)
      ..quadraticBezierTo(57, -4, 57, 10)
      ..quadraticBezierTo(48, 4, 39, 6)
      ..close();
    canvas.drawPath(earRightFill, whiteFill);
    final earRightStroke = Path()
      ..moveTo(39, 6)
      ..quadraticBezierTo(44, -6, 48, -14)
      ..quadraticBezierTo(57, -4, 57, 10);
    canvas.drawPath(earRightStroke, blackStroke);

    // Interieur des oreilles (rose)
    final innerLeft = Path()
      ..moveTo(17, 6)
      ..quadraticBezierTo(16, -2, 20, -6)
      ..quadraticBezierTo(24, -1, 25, 7)
      ..quadraticBezierTo(21, 4, 17, 6)
      ..close();
    canvas.drawPath(innerLeft, pinkFill);
    final innerRight = Path()
      ..moveTo(43, 3)
      ..quadraticBezierTo(45, -4, 48, -9)
      ..quadraticBezierTo(53, -3, 53, 5)
      ..quadraticBezierTo(48, 2, 43, 3)
      ..close();
    canvas.drawPath(innerRight, pinkFill);

    // Joues
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(14, 35), width: 10, height: 7),
      Paint()..color = const Color(0xFFFFC2D1).withOpacity(0.85),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(46, 38), width: 10, height: 7),
      Paint()..color = const Color(0xFFFFC2D1).withOpacity(0.6),
    );

    // Yeux
    canvas.drawCircle(const Offset(22, 26), 5.5, blackFill);
    canvas.drawCircle(const Offset(38, 26), 5.5, blackFill);
    canvas.drawCircle(const Offset(20.5, 24), 1.6, whiteFill);
    canvas.drawCircle(const Offset(36.5, 24), 1.6, whiteFill);
    final smallHighlight = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(const Offset(24, 28), 0.9, smallHighlight);
    canvas.drawCircle(const Offset(40, 28), 0.9, smallHighlight);

    // Nez (triangle)
    final nosePath = Path()
      ..moveTo(26.5, 34)
      ..lineTo(33, 34)
      ..lineTo(29.75, 38.5)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFFF8FAB));
    canvas.drawPath(
      nosePath,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round,
    );

    // Bouche
    final mouthPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(29.75, 38.5)
        ..quadraticBezierTo(27.5, 42, 23, 40),
      mouthPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(29.75, 38.5)
        ..quadraticBezierTo(32, 42, 36.5, 40),
      mouthPaint,
    );

    // Moustaches pres du museau
    canvas.drawLine(const Offset(20, 34), const Offset(2, 32), whiskerPaint);
    canvas.drawLine(const Offset(20, 36), const Offset(2, 38), whiskerPaint);
    canvas.drawLine(const Offset(40, 34), const Offset(58, 32), whiskerPaint);
    canvas.drawLine(const Offset(40, 36), const Offset(58, 38), whiskerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CatPainter oldDelegate) => oldDelegate.walkValue != walkValue;
}

class WalkingCat extends StatefulWidget {
  final String language;
  final String bankType;
  final bool facingRight;
  final Size catSize;
  const WalkingCat({
    super.key,
    required this.language,
    required this.bankType,
    this.facingRight = true,
    this.catSize = const Size(60, 66),
  });

  @override
  State<WalkingCat> createState() => _WalkingCatState();
}

class _WalkingCatState extends State<WalkingCat> {
  final FlutterTts _catTts = FlutterTts();
  Map<String, String>? _bubbleWord;

  Map<String, List<Map<String, String>>> get _bank {
    switch (widget.bankType) {
      case "expressions":
        return phraseBank;
      case "chiffres":
        return numberBank;
      case "verbes":
        return verbBank;
      case "mots":
      default:
        return wordBank;
    }
  }

  Color get _patchColor {
    switch (widget.bankType) {
      case "expressions":
        return const Color(0xFFFFC107);
      case "chiffres":
        return const Color(0xFFE53935);
      case "verbes":
        return const Color(0xFF1E88E5);
      case "mots":
      default:
        return const Color(0xFF1A1A1A);
    }
  }

  String get _label {
    switch (widget.bankType) {
      case "expressions":
        return "Expressions";
      case "chiffres":
        return "Chiffres";
      case "verbes":
        return "Verbes";
      case "mots":
      default:
        return "Mots";
    }
  }

  // Chaque catégorie a sa propre forme de queue et sa propre vitesse de
  // balancement, pour que les 4 chats ne soient ni identiques ni synchronisés.
  String get _tailStyle {
    switch (widget.bankType) {
      case "chiffres":
        return "hooked";
      case "expressions":
        return "curled";
      case "verbes":
        return "stubby";
      case "mots":
      default:
        return "classic";
    }
  }

  Duration get _cycleDuration {
    switch (widget.bankType) {
      case "chiffres":
        return const Duration(milliseconds: 520);
      case "expressions":
        return const Duration(milliseconds: 380);
      case "verbes":
        return const Duration(milliseconds: 600);
      case "mots":
      default:
        return const Duration(milliseconds: 450);
    }
  }

  @override
  void dispose() {
    _catTts.stop();
    super.dispose();
  }

  void _onTap() async {
    final words = _bank[widget.language] ?? _bank["Anglais"]!;
    final chosen = words[_rng.nextInt(words.length)];
    setState(() {
      _bubbleWord = chosen;
    });
    final locale = languageLocales[widget.language] ?? "en-US";
    await _catTts.setLanguage(locale);
    await _catTts.speak(chosen["word"]!);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _bubbleWord = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          if (_bubbleWord != null)
            Positioned(
              top: -70,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black87, width: 1),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _bubbleWord!["word"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      _bubbleWord!["fr"]!,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(widget.facingRight ? 0 : 3.1416),
            child: CatSprite(
              patchColor: _patchColor,
              size: widget.catSize,
              tailStyle: _tailStyle,
              cycleDuration: _cycleDuration,
            ),
          ),
          Positioned(
            top: widget.catSize.height,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CatsHero extends StatelessWidget {
  final String language;
  const CatsHero({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    const catSize = Size(90, 100);
    // Grille 2x2 figée : chaque paire se fait face (le chat de gauche
    // regarde vers la droite, celui de droite regarde vers la gauche).
    Widget cell(String bankType, bool facingRight) {
      return Expanded(
        child: Center(
          child: WalkingCat(
            language: language,
            bankType: bankType,
            facingRight: facingRight,
            catSize: catSize,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                cell("mots", false),
                cell("chiffres", true),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                cell("expressions", false),
                cell("verbes", true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;
  bool _isTranslating = false;
  String? _translation;
  String? _errorText;

  final List<String> _languages = [
    "Anglais",
    "Français",
  ];
  String _selectedLanguage = "Anglais";
  Character _selectedCharacter = characters[0];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _translate(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _isTranslating = true;
      _translation = null;
      _errorText = null;
    });
    try {
      final url = Uri.parse(
        'https://gemini-proxyhardydavid-81workersdev.hardydavid-81.workers.dev',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Traduis le texte suivant entre le francais et l'anglais : si le texte est en francais, traduis-le en anglais ; si le texte est en anglais, traduis-le en francais. Reponds UNIQUEMENT avec la traduction, sans aucune explication, sans guillemets. Texte : " +
                          trimmed
                }
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated =
            (data['candidates'][0]['content']['parts'][0]['text'] as String)
                .trim();
        setState(() {
          _translation = translated;
          _isTranslating = false;
        });
        await _tts.setLanguage(_selectedCharacter.ttsLocale);
        await _tts.speak(translated);
      } else {
        setState(() {
          _errorText =
              "Erreur API code " + response.statusCode.toString();
          _isTranslating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorText = "Erreur : " + e.toString();
        _isTranslating = false;
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      await _speech.stop();
      if (_textController.text.trim().isNotEmpty) {
        _translate(_textController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Langues Vocale'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Center(
              child: DropdownButton<Character>(
                value: _selectedCharacter,
                dropdownColor: Colors.blue,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (Character? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCharacter = newValue;
                    });
                  }
                },
                items: characters.map<DropdownMenuItem<Character>>((Character c) {
                  return DropdownMenuItem<Character>(
                    value: c,
                    child: Text(c.emoji + " " + c.name),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: Colors.blue,
                underline: const SizedBox(),
                icon: const Icon(Icons.language, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                  }
                },
                items: _languages.map<DropdownMenuItem<String>>((String lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(lang),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Section héro : les 4 chats sont l'identité visuelle de l'app
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.indigo.shade50,
            child: CatsHero(language: _selectedLanguage),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: "Tapez ou parlez, en français ou en anglais...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _listen,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: _isListening ? Colors.red : Colors.indigo,
                        child: const Icon(Icons.mic, color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _translate(_textController.text),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Traduire"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isTranslating)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_errorText != null)
                    Text(_errorText!, style: const TextStyle(color: Colors.red)),
                  if (_translation != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _translation!,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.indigo),
                            onPressed: () async {
                              await _tts.setLanguage(_selectedCharacter.ttsLocale);
                              await _tts.speak(_translation!);
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


