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

final math.Random _rng = math.Random();

final Map<String, List<Map<String, String>>> wordBank = {
  "Anglais": [
    {"word": "Hello", "fr": "Bonjour"},
    {"word": "Cat", "fr": "Chat"},
    {"word": "Friend", "fr": "Ami"},
    {"word": "Happy", "fr": "Heureux"},
    {"word": "Water", "fr": "Eau"},
    {"word": "Beautiful", "fr": "Beau/Belle"},
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
    {"word": "One", "fr": "Un"},
    {"word": "Two", "fr": "Deux"},
    {"word": "Three", "fr": "Trois"},
    {"word": "Four", "fr": "Quatre"},
    {"word": "Five", "fr": "Cinq"},
    {"word": "Mother", "fr": "Mère"},
    {"word": "Father", "fr": "Père"},
    {"word": "Brother", "fr": "Frère"},
    {"word": "Sister", "fr": "Sœur"},
    {"word": "Child", "fr": "Enfant"},
    {"word": "Eat", "fr": "Manger"},
    {"word": "Drink", "fr": "Boire"},
    {"word": "Sleep", "fr": "Dormir"},
    {"word": "Walk", "fr": "Marcher"},
    {"word": "Speak", "fr": "Parler"},
    {"word": "See", "fr": "Voir"},
    {"word": "Come", "fr": "Venir"},
    {"word": "Go", "fr": "Aller"},
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
  ],
  "Espagnol": [
    {"word": "Hola", "fr": "Bonjour"},
    {"word": "Gato", "fr": "Chat"},
    {"word": "Amigo", "fr": "Ami"},
    {"word": "Feliz", "fr": "Heureux"},
    {"word": "Agua", "fr": "Eau"},
    {"word": "Hermoso", "fr": "Beau"},
    {"word": "Casa", "fr": "Maison"},
    {"word": "Perro", "fr": "Chien"},
    {"word": "Sol", "fr": "Soleil"},
    {"word": "Luna", "fr": "Lune"},
    {"word": "Libro", "fr": "Livre"},
    {"word": "Amor", "fr": "Amour"},
    {"word": "Tiempo", "fr": "Temps"},
    {"word": "Comida", "fr": "Nourriture"},
    {"word": "Familia", "fr": "Famille"},
    {"word": "Pan", "fr": "Pain"},
    {"word": "Música", "fr": "Musique"},
    {"word": "Árbol", "fr": "Arbre"},
    {"word": "Mar", "fr": "Mer"},
    {"word": "Cielo", "fr": "Ciel"},
    {"word": "Pájaro", "fr": "Oiseau"},
    {"word": "Flor", "fr": "Fleur"},
    {"word": "Escuela", "fr": "École"},
    {"word": "Trabajo", "fr": "Travail"},
    {"word": "Noche", "fr": "Nuit"},
    {"word": "Día", "fr": "Jour"},
    {"word": "Bueno", "fr": "Bon"},
    {"word": "Grande", "fr": "Grand"},
    {"word": "Pequeño", "fr": "Petit"},
    {"word": "Rápido", "fr": "Rapide"},
    {"word": "Lento", "fr": "Lent"},
    {"word": "Color", "fr": "Couleur"},
    {"word": "Rojo", "fr": "Rouge"},
    {"word": "Azul", "fr": "Bleu"},
    {"word": "Verde", "fr": "Vert"},
  ],
  "Italien": [
    {"word": "Ciao", "fr": "Bonjour"},
    {"word": "Gatto", "fr": "Chat"},
    {"word": "Amico", "fr": "Ami"},
    {"word": "Felice", "fr": "Heureux"},
    {"word": "Acqua", "fr": "Eau"},
    {"word": "Bello", "fr": "Beau"},
    {"word": "Casa", "fr": "Maison"},
    {"word": "Cane", "fr": "Chien"},
    {"word": "Sole", "fr": "Soleil"},
    {"word": "Luna", "fr": "Lune"},
    {"word": "Libro", "fr": "Livre"},
    {"word": "Amore", "fr": "Amour"},
    {"word": "Tempo", "fr": "Temps"},
    {"word": "Cibo", "fr": "Nourriture"},
    {"word": "Famiglia", "fr": "Famille"},
    {"word": "Pane", "fr": "Pain"},
    {"word": "Musica", "fr": "Musique"},
    {"word": "Albero", "fr": "Arbre"},
    {"word": "Mare", "fr": "Mer"},
    {"word": "Cielo", "fr": "Ciel"},
    {"word": "Uccello", "fr": "Oiseau"},
    {"word": "Fiore", "fr": "Fleur"},
    {"word": "Scuola", "fr": "École"},
    {"word": "Lavoro", "fr": "Travail"},
    {"word": "Notte", "fr": "Nuit"},
    {"word": "Giorno", "fr": "Jour"},
    {"word": "Buono", "fr": "Bon"},
    {"word": "Grande", "fr": "Grand"},
    {"word": "Piccolo", "fr": "Petit"},
    {"word": "Veloce", "fr": "Rapide"},
    {"word": "Lento", "fr": "Lent"},
    {"word": "Colore", "fr": "Couleur"},
    {"word": "Rosso", "fr": "Rouge"},
    {"word": "Blu", "fr": "Bleu"},
    {"word": "Verde", "fr": "Vert"},
  ],
  "Allemand": [
    {"word": "Hallo", "fr": "Bonjour"},
    {"word": "Katze", "fr": "Chat"},
    {"word": "Freund", "fr": "Ami"},
    {"word": "Glücklich", "fr": "Heureux"},
    {"word": "Wasser", "fr": "Eau"},
    {"word": "Schön", "fr": "Beau"},
    {"word": "Haus", "fr": "Maison"},
    {"word": "Hund", "fr": "Chien"},
    {"word": "Sonne", "fr": "Soleil"},
    {"word": "Mond", "fr": "Lune"},
    {"word": "Buch", "fr": "Livre"},
    {"word": "Liebe", "fr": "Amour"},
    {"word": "Zeit", "fr": "Temps"},
    {"word": "Essen", "fr": "Nourriture"},
    {"word": "Familie", "fr": "Famille"},
    {"word": "Brot", "fr": "Pain"},
    {"word": "Musik", "fr": "Musique"},
    {"word": "Baum", "fr": "Arbre"},
    {"word": "Meer", "fr": "Mer"},
    {"word": "Himmel", "fr": "Ciel"},
    {"word": "Vogel", "fr": "Oiseau"},
    {"word": "Blume", "fr": "Fleur"},
    {"word": "Schule", "fr": "École"},
    {"word": "Arbeit", "fr": "Travail"},
    {"word": "Nacht", "fr": "Nuit"},
    {"word": "Tag", "fr": "Jour"},
    {"word": "Gut", "fr": "Bon"},
    {"word": "Groß", "fr": "Grand"},
    {"word": "Klein", "fr": "Petit"},
    {"word": "Schnell", "fr": "Rapide"},
    {"word": "Langsam", "fr": "Lent"},
    {"word": "Farbe", "fr": "Couleur"},
    {"word": "Rot", "fr": "Rouge"},
    {"word": "Blau", "fr": "Bleu"},
    {"word": "Grün", "fr": "Vert"},
  ],
  "Portugais": [
    {"word": "Olá", "fr": "Bonjour"},
    {"word": "Gato", "fr": "Chat"},
    {"word": "Amigo", "fr": "Ami"},
    {"word": "Feliz", "fr": "Heureux"},
    {"word": "Água", "fr": "Eau"},
    {"word": "Bonito", "fr": "Beau"},
    {"word": "Casa", "fr": "Maison"},
    {"word": "Cachorro", "fr": "Chien"},
    {"word": "Sol", "fr": "Soleil"},
    {"word": "Lua", "fr": "Lune"},
    {"word": "Livro", "fr": "Livre"},
    {"word": "Amor", "fr": "Amour"},
    {"word": "Tempo", "fr": "Temps"},
    {"word": "Comida", "fr": "Nourriture"},
    {"word": "Família", "fr": "Famille"},
    {"word": "Pão", "fr": "Pain"},
    {"word": "Música", "fr": "Musique"},
    {"word": "Árvore", "fr": "Arbre"},
    {"word": "Mar", "fr": "Mer"},
    {"word": "Céu", "fr": "Ciel"},
    {"word": "Pássaro", "fr": "Oiseau"},
    {"word": "Flor", "fr": "Fleur"},
    {"word": "Escola", "fr": "École"},
    {"word": "Trabalho", "fr": "Travail"},
    {"word": "Noite", "fr": "Nuit"},
    {"word": "Dia", "fr": "Jour"},
    {"word": "Bom", "fr": "Bon"},
    {"word": "Grande", "fr": "Grand"},
    {"word": "Pequeno", "fr": "Petit"},
    {"word": "Rápido", "fr": "Rapide"},
    {"word": "Lento", "fr": "Lent"},
    {"word": "Cor", "fr": "Couleur"},
    {"word": "Vermelho", "fr": "Rouge"},
    {"word": "Azul", "fr": "Bleu"},
    {"word": "Verde", "fr": "Vert"},
  ],
  "Arabe": [
    {"word": "مرحبا", "fr": "Bonjour"},
    {"word": "قطة", "fr": "Chat"},
    {"word": "صديق", "fr": "Ami"},
    {"word": "سعيد", "fr": "Heureux"},
    {"word": "ماء", "fr": "Eau"},
    {"word": "جميل", "fr": "Beau"},
    {"word": "بيت", "fr": "Maison"},
    {"word": "كلب", "fr": "Chien"},
    {"word": "شمس", "fr": "Soleil"},
    {"word": "قمر", "fr": "Lune"},
    {"word": "كتاب", "fr": "Livre"},
    {"word": "حب", "fr": "Amour"},
    {"word": "وقت", "fr": "Temps"},
    {"word": "طعام", "fr": "Nourriture"},
    {"word": "عائلة", "fr": "Famille"},
    {"word": "خبز", "fr": "Pain"},
    {"word": "موسيقى", "fr": "Musique"},
    {"word": "شجرة", "fr": "Arbre"},
    {"word": "بحر", "fr": "Mer"},
    {"word": "سماء", "fr": "Ciel"},
    {"word": "طائر", "fr": "Oiseau"},
    {"word": "زهرة", "fr": "Fleur"},
    {"word": "مدرسة", "fr": "École"},
    {"word": "عمل", "fr": "Travail"},
    {"word": "ليل", "fr": "Nuit"},
    {"word": "يوم", "fr": "Jour"},
  ],
  "Japonais": [
    {"word": "こんにちは", "fr": "Bonjour"},
    {"word": "猫", "fr": "Chat"},
    {"word": "友達", "fr": "Ami"},
    {"word": "幸せ", "fr": "Heureux"},
    {"word": "水", "fr": "Eau"},
    {"word": "綺麗", "fr": "Beau"},
    {"word": "家", "fr": "Maison"},
    {"word": "犬", "fr": "Chien"},
    {"word": "太陽", "fr": "Soleil"},
    {"word": "月", "fr": "Lune"},
    {"word": "本", "fr": "Livre"},
    {"word": "愛", "fr": "Amour"},
    {"word": "時間", "fr": "Temps"},
    {"word": "食べ物", "fr": "Nourriture"},
    {"word": "家族", "fr": "Famille"},
    {"word": "パン", "fr": "Pain"},
    {"word": "音楽", "fr": "Musique"},
    {"word": "木", "fr": "Arbre"},
    {"word": "海", "fr": "Mer"},
    {"word": "空", "fr": "Ciel"},
    {"word": "鳥", "fr": "Oiseau"},
    {"word": "花", "fr": "Fleur"},
    {"word": "学校", "fr": "École"},
    {"word": "仕事", "fr": "Travail"},
    {"word": "夜", "fr": "Nuit"},
  ],
  "Chinois": [
    {"word": "你好", "fr": "Bonjour"},
    {"word": "猫", "fr": "Chat"},
    {"word": "朋友", "fr": "Ami"},
    {"word": "开心", "fr": "Heureux"},
    {"word": "水", "fr": "Eau"},
    {"word": "漂亮", "fr": "Beau"},
    {"word": "家", "fr": "Maison"},
    {"word": "狗", "fr": "Chien"},
    {"word": "太阳", "fr": "Soleil"},
    {"word": "月亮", "fr": "Lune"},
    {"word": "书", "fr": "Livre"},
    {"word": "爱", "fr": "Amour"},
    {"word": "时间", "fr": "Temps"},
    {"word": "食物", "fr": "Nourriture"},
    {"word": "家庭", "fr": "Famille"},
    {"word": "面包", "fr": "Pain"},
    {"word": "音乐", "fr": "Musique"},
    {"word": "树", "fr": "Arbre"},
    {"word": "海", "fr": "Mer"},
    {"word": "天空", "fr": "Ciel"},
    {"word": "鸟", "fr": "Oiseau"},
    {"word": "花", "fr": "Fleur"},
    {"word": "学校", "fr": "École"},
    {"word": "工作", "fr": "Travail"},
    {"word": "夜晚", "fr": "Nuit"},
  ],
};

final Map<String, List<Map<String, String>>> phraseBank = {
  "Anglais": [
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
  ],
  "Espagnol": [
    {"word": "¿Cómo estás?", "fr": "Comment vas-tu ?"},
    {"word": "¿Cómo te llamas?", "fr": "Comment tu t'appelles ?"},
    {"word": "Mucho gusto", "fr": "Enchanté"},
    {"word": "No entiendo", "fr": "Je ne comprends pas"},
    {"word": "¿Puedes ayudarme?", "fr": "Peux-tu m'aider ?"},
    {"word": "¿Dónde está el baño?", "fr": "Où sont les toilettes ?"},
    {"word": "¿Cuánto cuesta?", "fr": "Combien ça coûte ?"},
    {"word": "Quisiera...", "fr": "Je voudrais..."},
    {"word": "Hasta luego", "fr": "À plus tard"},
    {"word": "Que tengas un buen día", "fr": "Bonne journée"},
    {"word": "¿Qué hora es?", "fr": "Quelle heure est-il ?"},
    {"word": "Tengo hambre", "fr": "J'ai faim"},
    {"word": "Tengo sed", "fr": "J'ai soif"},
    {"word": "Estoy cansado", "fr": "Je suis fatigué"},
    {"word": "¿De dónde eres?", "fr": "D'où viens-tu ?"},
    {"word": "Hablo un poco", "fr": "Je parle un peu"},
    {"word": "¿Puedes repetir?", "fr": "Peux-tu répéter ?"},
    {"word": "Más despacio por favor", "fr": "Plus lentement s'il te plaît"},
    {"word": "Está delicioso", "fr": "C'est délicieux"},
    {"word": "Felicidades", "fr": "Félicitations"},
  ],
  "Italien": [
    {"word": "Come stai?", "fr": "Comment vas-tu ?"},
    {"word": "Come ti chiami?", "fr": "Comment tu t'appelles ?"},
    {"word": "Piacere di conoscerti", "fr": "Enchanté"},
    {"word": "Non capisco", "fr": "Je ne comprends pas"},
    {"word": "Puoi aiutarmi?", "fr": "Peux-tu m'aider ?"},
    {"word": "Dov'è il bagno?", "fr": "Où sont les toilettes ?"},
    {"word": "Quanto costa?", "fr": "Combien ça coûte ?"},
    {"word": "Vorrei...", "fr": "Je voudrais..."},
    {"word": "A dopo", "fr": "À plus tard"},
    {"word": "Buona giornata", "fr": "Bonne journée"},
    {"word": "Che ore sono?", "fr": "Quelle heure est-il ?"},
    {"word": "Ho fame", "fr": "J'ai faim"},
    {"word": "Ho sete", "fr": "J'ai soif"},
    {"word": "Sono stanco", "fr": "Je suis fatigué"},
    {"word": "Di dove sei?", "fr": "D'où viens-tu ?"},
    {"word": "Parlo un po'", "fr": "Je parle un peu"},
    {"word": "Puoi ripetere?", "fr": "Peux-tu répéter ?"},
    {"word": "Più lentamente per favore", "fr": "Plus lentement s'il te plaît"},
    {"word": "È delizioso", "fr": "C'est délicieux"},
    {"word": "Congratulazioni", "fr": "Félicitations"},
  ],
  "Allemand": [
    {"word": "Wie geht es dir?", "fr": "Comment vas-tu ?"},
    {"word": "Wie heißt du?", "fr": "Comment tu t'appelles ?"},
    {"word": "Freut mich", "fr": "Enchanté"},
    {"word": "Ich verstehe nicht", "fr": "Je ne comprends pas"},
    {"word": "Kannst du mir helfen?", "fr": "Peux-tu m'aider ?"},
    {"word": "Wo ist die Toilette?", "fr": "Où sont les toilettes ?"},
    {"word": "Wie viel kostet das?", "fr": "Combien ça coûte ?"},
    {"word": "Ich hätte gern...", "fr": "Je voudrais..."},
    {"word": "Bis später", "fr": "À plus tard"},
    {"word": "Schönen Tag noch", "fr": "Bonne journée"},
    {"word": "Wie spät ist es?", "fr": "Quelle heure est-il ?"},
    {"word": "Ich habe Hunger", "fr": "J'ai faim"},
    {"word": "Ich habe Durst", "fr": "J'ai soif"},
    {"word": "Ich bin müde", "fr": "Je suis fatigué"},
    {"word": "Woher kommst du?", "fr": "D'où viens-tu ?"},
    {"word": "Ich spreche ein bisschen", "fr": "Je parle un peu"},
    {"word": "Kannst du das wiederholen?", "fr": "Peux-tu répéter ?"},
    {"word": "Langsamer bitte", "fr": "Plus lentement s'il te plaît"},
    {"word": "Das ist lecker", "fr": "C'est délicieux"},
    {"word": "Herzlichen Glückwunsch", "fr": "Félicitations"},
  ],
  "Portugais": [
    {"word": "Como você está?", "fr": "Comment vas-tu ?"},
    {"word": "Qual é o seu nome?", "fr": "Comment tu t'appelles ?"},
    {"word": "Prazer em conhecê-lo", "fr": "Enchanté"},
    {"word": "Não entendo", "fr": "Je ne comprends pas"},
    {"word": "Você pode me ajudar?", "fr": "Peux-tu m'aider ?"},
    {"word": "Onde fica o banheiro?", "fr": "Où sont les toilettes ?"},
    {"word": "Quanto custa?", "fr": "Combien ça coûte ?"},
    {"word": "Eu gostaria de...", "fr": "Je voudrais..."},
    {"word": "Até mais tarde", "fr": "À plus tard"},
    {"word": "Tenha um bom dia", "fr": "Bonne journée"},
    {"word": "Que horas são?", "fr": "Quelle heure est-il ?"},
    {"word": "Estou com fome", "fr": "J'ai faim"},
    {"word": "Estou com sede", "fr": "J'ai soif"},
    {"word": "Estou cansado", "fr": "Je suis fatigué"},
    {"word": "De onde você é?", "fr": "D'où viens-tu ?"},
    {"word": "Eu falo um pouco", "fr": "Je parle un peu"},
    {"word": "Pode repetir?", "fr": "Peux-tu répéter ?"},
    {"word": "Mais devagar por favor", "fr": "Plus lentement s'il te plaît"},
    {"word": "Está delicioso", "fr": "C'est délicieux"},
    {"word": "Parabéns", "fr": "Félicitations"},
  ],
  "Arabe": [
    {"word": "كيف حالك؟", "fr": "Comment vas-tu ?"},
    {"word": "ما اسمك؟", "fr": "Comment tu t'appelles ?"},
    {"word": "تشرفنا", "fr": "Enchanté"},
    {"word": "لا أفهم", "fr": "Je ne comprends pas"},
    {"word": "هل يمكنك مساعدتي؟", "fr": "Peux-tu m'aider ?"},
    {"word": "أين الحمام؟", "fr": "Où sont les toilettes ?"},
    {"word": "كم الثمن؟", "fr": "Combien ça coûte ?"},
    {"word": "أريد...", "fr": "Je voudrais..."},
    {"word": "إلى اللقاء", "fr": "À plus tard"},
    {"word": "يوم سعيد", "fr": "Bonne journée"},
    {"word": "كم الساعة؟", "fr": "Quelle heure est-il ?"},
    {"word": "أنا جائع", "fr": "J'ai faim"},
    {"word": "أنا عطشان", "fr": "J'ai soif"},
    {"word": "أنا متعب", "fr": "Je suis fatigué"},
    {"word": "من أين أنت؟", "fr": "D'où viens-tu ?"},
    {"word": "أتكلم قليلا", "fr": "Je parle un peu"},
    {"word": "هل يمكنك التكرار؟", "fr": "Peux-tu répéter ?"},
    {"word": "ببطء من فضلك", "fr": "Plus lentement s'il te plaît"},
    {"word": "شكرا جزيلا", "fr": "Merci beaucoup"},
    {"word": "مبروك", "fr": "Félicitations"},
  ],
  "Japonais": [
    {"word": "元気ですか", "fr": "Comment vas-tu ?"},
    {"word": "お名前は何ですか", "fr": "Comment tu t'appelles ?"},
    {"word": "はじめまして", "fr": "Enchanté"},
    {"word": "わかりません", "fr": "Je ne comprends pas"},
    {"word": "手伝ってくれますか", "fr": "Peux-tu m'aider ?"},
    {"word": "トイレはどこですか", "fr": "Où sont les toilettes ?"},
    {"word": "いくらですか", "fr": "Combien ça coûte ?"},
    {"word": "お願いします", "fr": "Je voudrais / S'il vous plaît"},
    {"word": "また後で", "fr": "À plus tard"},
    {"word": "良い一日を", "fr": "Bonne journée"},
    {"word": "何時ですか", "fr": "Quelle heure est-il ?"},
    {"word": "お腹が空きました", "fr": "J'ai faim"},
    {"word": "喉が渇きました", "fr": "J'ai soif"},
    {"word": "疲れました", "fr": "Je suis fatigué"},
    {"word": "出身はどこですか", "fr": "D'où viens-tu ?"},
    {"word": "少し話せます", "fr": "Je parle un peu"},
    {"word": "もう一度言ってください", "fr": "Peux-tu répéter ?"},
    {"word": "ゆっくり話してください", "fr": "Plus lentement s'il te plaît"},
    {"word": "おいしいです", "fr": "C'est délicieux"},
    {"word": "おめでとう", "fr": "Félicitations"},
  ],
  "Chinois": [
    {"word": "你好吗", "fr": "Comment vas-tu ?"},
    {"word": "你叫什么名字", "fr": "Comment tu t'appelles ?"},
    {"word": "很高兴认识你", "fr": "Enchanté"},
    {"word": "我不明白", "fr": "Je ne comprends pas"},
    {"word": "你能帮我吗", "fr": "Peux-tu m'aider ?"},
    {"word": "洗手间在哪里", "fr": "Où sont les toilettes ?"},
    {"word": "多少钱", "fr": "Combien ça coûte ?"},
    {"word": "我想要...", "fr": "Je voudrais..."},
    {"word": "回头见", "fr": "À plus tard"},
    {"word": "祝你今天愉快", "fr": "Bonne journée"},
    {"word": "现在几点", "fr": "Quelle heure est-il ?"},
    {"word": "我饿了", "fr": "J'ai faim"},
    {"word": "我渴了", "fr": "J'ai soif"},
    {"word": "我累了", "fr": "Je suis fatigué"},
    {"word": "你是哪里人", "fr": "D'où viens-tu ?"},
    {"word": "我会说一点", "fr": "Je parle un peu"},
    {"word": "你能再说一遍吗", "fr": "Peux-tu répéter ?"},
    {"word": "请说慢一点", "fr": "Plus lentement s'il te plaît"},
    {"word": "很好吃", "fr": "C'est délicieux"},
    {"word": "恭喜", "fr": "Félicitations"},
  ],
};

class CatSprite extends StatefulWidget {
  final Color patchColor;
  const CatSprite({super.key, this.patchColor = const Color(0xFF1A1A1A)});

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
          painter: CatPainter(walkValue: _walkCycle.value, patchColor: widget.patchColor),
        );
      },
    );
  }
}

class CatPainter extends CustomPainter {
  final double walkValue;
  final Color patchColor;
  CatPainter({required this.walkValue, this.patchColor = const Color(0xFF1A1A1A)});

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
  final double startX;
  final double startY;
  final String language;
  final String bankType;
  const WalkingCat({
    super.key,
    required this.startX,
    required this.startY,
    required this.language,
    required this.bankType,
  });

  @override
  State<WalkingCat> createState() => _WalkingCatState();
}

class _WalkingCatState extends State<WalkingCat> {
  late double _x;
  late double _y;
  double _dragStartX = 0;
  double _dragStartY = 0;
  bool _facingRight = true;
  final FlutterTts _catTts = FlutterTts();
  Map<String, String>? _bubbleWord;
  double _growth = 1.0;
  static const double _maxGrowth = 2.5;
  static const double _growthStep = 0.12;

  @override
  void initState() {
    super.initState();
    _x = widget.startX;
    _y = widget.startY;
  }

  @override
  void dispose() {
    _catTts.stop();
    super.dispose();
  }

  void _onTap() async {
    final bank = widget.bankType == "expressions" ? phraseBank : wordBank;
    final words = bank[widget.language] ?? bank["Anglais"]!;
    final chosen = words[_rng.nextInt(words.length)];
    setState(() {
      _bubbleWord = chosen;
      if (_growth < _maxGrowth) {
        _growth = (_growth + _growthStep).clamp(1.0, _maxGrowth);
      }
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

  void _onLongPressStart(LongPressStartDetails details) {
    _dragStartX = _x;
    _dragStartY = _y;
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final size = MediaQuery.of(context).size;
    setState(() {
      if (details.offsetFromOrigin.dx.abs() > 2) {
        _facingRight = details.offsetFromOrigin.dx > 0;
      }
      _x = (_dragStartX + details.offsetFromOrigin.dx)
          .clamp(0, size.width - 60);
      _y = (_dragStartY + details.offsetFromOrigin.dy)
          .clamp(0, size.height - 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration.zero,
      left: _x,
      top: _y,
      child: GestureDetector(
        onTap: _onTap,
        onLongPressStart: _onLongPressStart,
        onLongPressMoveUpdate: _onLongPressMoveUpdate,
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
              child: Transform.scale(
                scale: _growth,
                child: CatSprite(
                  patchColor: widget.bankType == "expressions"
                      ? const Color(0xFFFFC107)
                      : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Positioned(
              top: 66,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.bankType == "expressions" ? "Expressions" : "Mots",
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
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
        WalkingCat(
          startX: size.width * 0.25,
          startY: size.height * 0.6,
          language: language,
          bankType: "mots",
        ),
        WalkingCat(
          startX: size.width * 0.65,
          startY: size.height * 0.6,
          language: language,
          bankType: "expressions",
        ),
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
          Positioned.fill(child: WalkingCatsBackground(language: _selectedLanguage)),
        ],
      ),
    );
  }
}

