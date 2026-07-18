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

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
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

final Map<String, String> languageLocales = {
  "Anglais": "en-US",
  "Espagnol": "es-ES",
  "Italien": "it-IT",
  "Allemand": "de-DE",
  "Portugais": "pt-PT",
  "Arabe": "ar-SA",
  "Japonais": "ja-JP",
  "Chinois": "zh-CN",
};

final Map<String, List<Map<String, String>>> wordBank = {
  "Anglais": [
    {"word": "Hello", "fr": "Bonjour"},
    {"word": "Cat", "fr": "Chat"},
    {"word": "Friend", "fr": "Ami"},
    {"word": "Happy", "fr": "Heureux"},
    {"word": "Water", "fr": "Eau"},
    {"word": "Beautiful", "fr": "Beau/Belle"},
  ],
  "Espagnol": [
    {"word": "Hola", "fr": "Bonjour"},
    {"word": "Gato", "fr": "Chat"},
    {"word": "Amigo", "fr": "Ami"},
    {"word": "Feliz", "fr": "Heureux"},
    {"word": "Agua", "fr": "Eau"},
    {"word": "Hermoso", "fr": "Beau"},
  ],
  "Italien": [
    {"word": "Ciao", "fr": "Bonjour"},
    {"word": "Gatto", "fr": "Chat"},
    {"word": "Amico", "fr": "Ami"},
    {"word": "Felice", "fr": "Heureux"},
    {"word": "Acqua", "fr": "Eau"},
    {"word": "Bello", "fr": "Beau"},
  ],
  "Allemand": [
    {"word": "Hallo", "fr": "Bonjour"},
    {"word": "Katze", "fr": "Chat"},
    {"word": "Freund", "fr": "Ami"},
    {"word": "Glücklich", "fr": "Heureux"},
    {"word": "Wasser", "fr": "Eau"},
    {"word": "Schön", "fr": "Beau"},
  ],
  "Portugais": [
    {"word": "Olá", "fr": "Bonjour"},
    {"word": "Gato", "fr": "Chat"},
    {"word": "Amigo", "fr": "Ami"},
    {"word": "Feliz", "fr": "Heureux"},
    {"word": "Água", "fr": "Eau"},
    {"word": "Bonito", "fr": "Beau"},
  ],
  "Arabe": [
    {"word": "مرحبا", "fr": "Bonjour"},
    {"word": "قطة", "fr": "Chat"},
    {"word": "صديق", "fr": "Ami"},
    {"word": "سعيد", "fr": "Heureux"},
    {"word": "ماء", "fr": "Eau"},
    {"word": "جميل", "fr": "Beau"},
  ],
  "Japonais": [
    {"word": "こんにちは", "fr": "Bonjour"},
    {"word": "猫", "fr": "Chat"},
    {"word": "友達", "fr": "Ami"},
    {"word": "幸せ", "fr": "Heureux"},
    {"word": "水", "fr": "Eau"},
    {"word": "綺麗", "fr": "Beau"},
  ],
  "Chinois": [
    {"word": "你好", "fr": "Bonjour"},
    {"word": "猫", "fr": "Chat"},
    {"word": "朋友", "fr": "Ami"},
    {"word": "开心", "fr": "Heureux"},
    {"word": "水", "fr": "Eau"},
    {"word": "漂亮", "fr": "Beau"},
  ],
};

class CatSprite extends StatefulWidget {
  const CatSprite({super.key});

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
      duration: const Duration(milliseconds: 400),
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
          size: const Size(60, 66),
          painter: CatPainter(walkValue: _walkCycle.value),
        );
      },
    );
  }
}

class CatPainter extends CustomPainter {
  final double walkValue;
  CatPainter({required this.walkValue});

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

    canvas.drawLine(const Offset(-8, 24), const Offset(16, 26), whiskerPaint);
    canvas.drawLine(const Offset(-8, 30), const Offset(16, 30), whiskerPaint);
    canvas.drawLine(const Offset(-8, 36), const Offset(16, 33), whiskerPaint);
    canvas.drawLine(const Offset(54, 26), const Offset(78, 22), whiskerPaint);
    canvas.drawLine(const Offset(54, 30), const Offset(78, 28), whiskerPaint);
    canvas.drawLine(const Offset(54, 33), const Offset(78, 35), whiskerPaint);

    canvas.save();
    canvas.translate(62, 66);
    final tailAngle = (-8 + walkValue * 18) * math.pi / 180;
    canvas.rotate(tailAngle);
    canvas.translate(-62, -66);
    final tailPath = Path()
      ..moveTo(62, 66)
      ..quadraticBezierTo(92, 68, 92, 45)
      ..quadraticBezierTo(90, 30, 76, 32);
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

    final bodyRect = Rect.fromCenter(center: const Offset(45, 62), width: 56, height: 40);
    canvas.drawOval(bodyRect, whiteFill);
    canvas.drawOval(bodyRect, blackStroke);
    canvas.save();
    canvas.clipPath(Path()..addOval(bodyRect));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(66, 55), width: 36, height: 44),
      blackFill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(35, 70), width: 20, height: 14),
      Paint()..color = const Color(0xFFFFC2D1).withOpacity(0.55),
    );
    canvas.restore();

    drawLeg(52, 76, true);
    drawLeg(62, 76, false);

    canvas.drawCircle(const Offset(35, 28), 26, whiteFill);
    canvas.drawCircle(const Offset(35, 28), 26, blackStroke);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: const Offset(35, 28), radius: 26)));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 20), width: 32, height: 36),
      blackFill,
    );
    canvas.restore();

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

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(14, 35), width: 10, height: 7),
      Paint()..color = const Color(0xFFFFC2D1).withOpacity(0.85),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(46, 38), width: 10, height: 7),
      Paint()..color = const Color(0xFFFFC2D1).withOpacity(0.6),
    );

    canvas.drawCircle(const Offset(22, 26), 5.5, blackFill);
    canvas.drawCircle(const Offset(38, 26), 5.5, blackFill);
    canvas.drawCircle(const Offset(20.5, 24), 1.6, whiteFill);
    canvas.drawCircle(const Offset(36.5, 24), 1.6, whiteFill);
    final smallHighlight = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(const Offset(24, 28), 0.9, smallHighlight);
    canvas.drawCircle(const Offset(40, 28), 0.9, smallHighlight);

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
  final double startX;
  final double startY;
  final String language;
  const WalkingCat({
    super.key,
    required this.startX,
    required this.startY,
    required this.language,
  });

  @override
  State<WalkingCat> createState() => _WalkingCatState();
}

class _WalkingCatState extends State<WalkingCat> {
  late double _x;
  late double _y;
  bool _facingRight = true;
  Duration _duration = const Duration(seconds: 3);
  final FlutterTts _catTts = FlutterTts();
  Map<String, String>? _bubbleWord;

  @override
  void initState() {
    super.initState();
    _x = widget.startX;
    _y = widget.startY;
    WidgetsBinding.instance.addPostFrameCallback((_) => _walkToNewSpot());
  }

  @override
  void dispose() {
    _catTts.stop();
    super.dispose();
  }

  void _onTap() async {
    final words = wordBank[widget.language] ?? wordBank["Anglais"]!;
    final chosen = words[DateTime.now().millisecond % words.length];
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

  void _walkToNewSpot() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final newX = 10 + (size.width - 60) * (DateTime.now().microsecond % 1000) / 1000;
    final newY = size.height * 0.5 +
        (size.height * 0.35) * ((DateTime.now().millisecond % 1000) / 1000);
    final distance = (newX - _x).abs();
    setState(() {
      _facingRight = newX > _x;
      _duration = Duration(milliseconds: 2000 + (distance * 15).toInt());
      _x = newX;
      _y = newY;
    });
    Future.delayed(
      _duration + Duration(milliseconds: 1500 + (DateTime.now().second % 5) * 500),
      _walkToNewSpot,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _duration,
      curve: Curves.easeInOut,
      left: _x,
      top: _y,
      child: GestureDetector(
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
              transform: Matrix4.rotationY(_facingRight ? 0 : 3.1416),
              child: const CatSprite(),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkingCatsBackground extends StatelessWidget {
  final String language;
  const WalkingCatsBackground({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        WalkingCat(startX: size.width * 0.2, startY: size.height * 0.6, language: language),
        WalkingCat(startX: size.width * 0.6, startY: size.height * 0.7, language: language),
        WalkingCat(startX: size.width * 0.8, startY: size.height * 0.55, language: language),
      ],
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
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;
  bool _isThinking = false;
  String _userText = "";
  final List<ChatMessage> _messages = [];

  final List<String> _languages = [
    "Anglais",
    "Espagnol",
    "Italien",
    "Allemand",
    "Portugais",
    "Arabe",
    "Japonais",
    "Chinois",
  ];
  String _selectedLanguage = "Anglais";
  Character _selectedCharacter = characters[0];

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _askGemini(String userMessage) async {
    setState(() {
      _isThinking = true;
      _messages.add(ChatMessage(userMessage, true));
    });
    _scrollToBottom();
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
                      "Tu es un partenaire de conversation pour apprendre les langues. " +
                          _selectedCharacter.personality +
                          " L'utilisateur pratique le " +
                          _selectedLanguage +
                          ". Reponds TOUJOURS en " +
                          _selectedLanguage +
                          " uniquement, meme si l'utilisateur ecrit dans une autre langue, en restant dans ton personnage, de facon courte, deux ou trois phrases maximum. Message de l'utilisateur : " +
                          userMessage
                }
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _messages.add(ChatMessage(reply, false));
          _isThinking = false;
        });
        _scrollToBottom();
        await _tts.setLanguage(_selectedCharacter.ttsLocale);
        await _tts.speak(reply);
      } else {
        setState(() {
          _messages.add(ChatMessage(
              "Erreur API code " +
                  response.statusCode.toString() +
                  " : " +
                  response.body,
              false));
          _isThinking = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage("Erreur : " + e.toString(), false));
        _isThinking = false;
      });
      _scrollToBottom();
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _userText = "";
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _userText = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      await _speech.stop();
      if (_userText.isNotEmpty) {
        _askGemini(_userText);
      }
    }
  }

  Widget _buildBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Langues Vocale'),
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
      body: Stack(
        children: [
          Positioned.fill(child: WalkingCatsBackground(language: _selectedLanguage)),
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          "Vous pratiquez : " +
                              _selectedLanguage +
                              " avec " +
                              _selectedCharacter.emoji +
                              " " +
                              _selectedCharacter.name +
                              "\nAppuyez sur le micro et parlez",
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildBubble(_messages[index]);
                        },
                      ),
              ),
              if (_isThinking)
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: _listen,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: _isListening ? Colors.red : Colors.blue,
                    child: const Icon(
                      Icons.mic,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
