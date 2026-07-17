import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

const String geminiApiKey = "AQ.Ab8RN6LqDp3vKeNX7qCzGe-mSVuFFb8MmHmkxg-CqNe8ekC4yw";

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isThinking = false;
  String _userText = "";
  String _aiText = "Appuyez sur le micro et parlez";

  Future<void> _askGemini(String userMessage) async {
    setState(() {
      _isThinking = true;
    });
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$geminiApiKey',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Tu es un partenaire de conversation pour apprendre les langues. Reponds toujours dans la meme langue que l'utilisateur, de facon naturelle et courte, deux ou trois phrases maximum. Message de l'utilisateur : $userMessage"
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
          _aiText = reply;
          _isThinking = false;
        });
      } else {
        setState(() {
          _aiText = "Erreur API code " + response.statusCode.toString();
          _isThinking = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiText = "Erreur : " + e.toString();
        _isThinking = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Langues Vocale')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _userText.isEmpty ? "" : "Vous : " + _userText,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _isThinking
                  ? const CircularProgressIndicator()
                  : Text(
                      _aiText,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _listen,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _isListening ? Colors.red : Colors.blue,
                  child: const Icon(
                    Icons.mic,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
