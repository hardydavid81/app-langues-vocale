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
    setState(() => _isThinking = true);
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey',
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
                      "Tu es un partenaire de conversation pour apprendre les langues. Réponds toujours dans la même langue que l'utilisateur, de façon naturelle et courte (2-3 phrases max). Message de l'utilisateur : $userMessage"
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
          _aiText = "Erreur API (${response.statusCode})";
          _isThinking = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiText = "Erreur : $e";
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
      setState(() => _isListening = false);
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
        child: Pad
