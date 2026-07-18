import 'package:flutter/material.dart';
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

class WalkingCat extends StatefulWidget {
  final double startX;
  final double startY;
  const WalkingCat({super.key, required this.startX, required this.startY});

  @override
  State<WalkingCat> createState() => _WalkingCatState();
}

class _WalkingCatState extends State<WalkingCat> {
  late double _x;
  late double _y;
  bool _facingRight = true;
  Duration _duration = const Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _x = widget.startX;
    _y = widget.startY;
    WidgetsBinding.instance.addPostFrameCallback((_) => _walkToNewSpot());
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
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(_facingRight ? 0 : 3.1416),
        child: const Text("🐱", style: TextStyle(fontSize: 28)),
      ),
    );
  }
}

class WalkingCatsBackground extends StatelessWidget {
  const WalkingCatsBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
      child: Stack(
        children: [
          WalkingCat(startX: size.width * 0.2, startY: size.height * 0.6),
          WalkingCat(startX: size.width * 0.6, startY: size.height * 0.7),
          WalkingCat(startX: size.width * 0.8, startY: size.height * 0.55),
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
          const Positioned.fill(child: WalkingCatsBackground()),
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
