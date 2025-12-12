import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class TriviaApiService {
  static const _baseUrl = 'https://opentdb.com/api.php?amount=5&type=multiple';

  Future<List<Question>> fetchBonusQuestions(int territoryId) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode != 200) {
        return _fallbackQuestions(territoryId);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      int id = 1000; // offset bonus IDs

      return results.map((raw) {
        final incorrect = List<String>.from(raw['incorrect_answers'] as List);
        final correct = raw['correct_answer'] as String;
        final options = [...incorrect, correct]..shuffle();
        final correctIndex = options.indexOf(correct);

        return Question(
          id: id++,
          territoryId: territoryId,
          category: raw['category'] as String? ?? 'General',
          text: raw['question'] as String,
          options: options,
          correctIndex: correctIndex,
        );
      }).toList();
    } catch (_) {
      return _fallbackQuestions(territoryId);
    }
  }

  List<Question> _fallbackQuestions(int territoryId) {
    return [
      Question(
        id: 2001,
        territoryId: territoryId,
        text: 'Which canal once powered most of downtown Syracuse factories?',
        options: [
          'Erie Canal',
          'Oswego Canal',
          'Cayuga-Seneca Canal',
          'Mohawk River'
        ],
        correctIndex: 0,
        category: 'Local History',
      ),
      Question(
        id: 2002,
        territoryId: territoryId,
        text: 'How many steps lead up to the JMA Wireless Dome student entrance?',
        options: ['84', '102', '75', '110'],
        correctIndex: 1,
        category: 'Campus Lore',
      ),
      Question(
        id: 2003,
        territoryId: territoryId,
        text: 'Which Westcott venue is known for its mural-lined alley?',
        options: [
          'The 443',
          'Westcott Theater',
          'Funk ’n Waffles',
          'Munjed’s'
        ],
        correctIndex: 1,
        category: 'Arts & Culture',
      ),
    ];
  }
}
