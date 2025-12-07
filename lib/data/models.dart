class Level {
  final int id;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final int difficulty; // 1-5

  Level({
    required this.id,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    required this.difficulty,
  });
}

class Question {
  final int id;
  final int levelId;
  final String text;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.id,
    required this.levelId,
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

class UserProgress {
  final int levelId;
  final bool completed;
  final int bestScore;

  UserProgress({
    required this.levelId,
    required this.completed,
    required this.bestScore,
  });
}
