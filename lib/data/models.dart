import 'dart:ui';

class Question {
  final int id;
  final int territoryId;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String category;

  Question({
    required this.id,
    required this.territoryId,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.category,
  });

  Question copyWith({
    int? id,
    int? territoryId,
    String? text,
    List<String>? options,
    int? correctIndex,
    String? category,
  }) {
    return Question(
      id: id ?? this.id,
      territoryId: territoryId ?? this.territoryId,
      text: text ?? this.text,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      category: category ?? this.category,
    );
  }
}

class Territory {
  final int id;
  final String name;
  final String landmark;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final double control; // 0.0 - 1.0 player influence
  final int challengers;
  final List<String> hotCategories;
  final Color accent;

  const Territory({
    required this.id,
    required this.name,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.control,
    required this.challengers,
    required this.hotCategories,
    required this.accent,
  });

  Territory copyWith({
    int? id,
    String? name,
    String? landmark,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? control,
    int? challengers,
    List<String>? hotCategories,
    Color? accent,
  }) {
    return Territory(
      id: id ?? this.id,
      name: name ?? this.name,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      control: control ?? this.control,
      challengers: challengers ?? this.challengers,
      hotCategories: hotCategories ?? this.hotCategories,
      accent: accent ?? this.accent,
    );
  }
}
