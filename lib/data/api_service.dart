import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class TriviaApiService {
  static const _baseUrl = 'https://opentdb.com/api.php?amount=5&type=multiple';

  Future<List<Question>> fetchBonusQuestions(int levelId) async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode != 200) return [];

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
        levelId: levelId,
        text: raw['question'] as String,
        options: options,
        correctIndex: correctIndex,
      );
    }).toList();
  }
}
