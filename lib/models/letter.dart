import 'package:flutter/material.dart';

enum ActivityType {
  pronunciation,
  syllables,
  wordFormation,
  wordReading,
  dragDrop,
  memory,
  writing
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced
}

class Letter {
  final String character;
  final String name;
  final String phoneme;
  final List<String> syllables;
  final List<String> exampleWords;
  final String imagePath;
  final String audioPath;
  final Color primaryColor;
  final bool isUnlocked;
  final int stars;
  final List<Activity> activities;

  const Letter({
    required this.character,
    required this.name,
    required this.phoneme,
    required this.syllables,
    required this.exampleWords,
    required this.imagePath,
    required this.audioPath,
    required this.primaryColor,
    this.isUnlocked = false,
    this.stars = 0,
    this.activities = const [],
  });

  Letter copyWith({
    String? character,
    String? name,
    String? phoneme,
    List<String>? syllables,
    List<String>? exampleWords,
    String? imagePath,
    String? audioPath,
    Color? primaryColor,
    bool? isUnlocked,
    int? stars,
    List<Activity>? activities,
  }) {
    return Letter(
      character: character ?? this.character,
      name: name ?? this.name,
      phoneme: phoneme ?? this.phoneme,
      syllables: syllables ?? this.syllables,
      exampleWords: exampleWords ?? this.exampleWords,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      primaryColor: primaryColor ?? this.primaryColor,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      stars: stars ?? this.stars,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'name': name,
      'phoneme': phoneme,
      'syllables': syllables,
      'exampleWords': exampleWords,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'primaryColor': primaryColor.value,
      'isUnlocked': isUnlocked,
      'stars': stars,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      character: json['character'],
      name: json['name'],
      phoneme: json['phoneme'],
      syllables: List<String>.from(json['syllables']),
      exampleWords: List<String>.from(json['exampleWords']),
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      primaryColor: Color(json['primaryColor']),
      isUnlocked: json['isUnlocked'] ?? false,
      stars: json['stars'] ?? 0,
      activities: (json['activities'] as List?)
          ?.map((a) => Activity.fromJson(a))
          .toList() ?? [],
    );
  }
}

class Activity {
  final String id;
  final String name;
  final String description;
  final ActivityType type;
  final DifficultyLevel difficulty;
  final bool isCompleted;
  final int score;
  final int maxScore;
  final String instruction;
  final Map<String, dynamic> data;

  const Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.difficulty,
    this.isCompleted = false,
    this.score = 0,
    this.maxScore = 100,
    required this.instruction,
    this.data = const {},
  });

  Activity copyWith({
    String? id,
    String? name,
    String? description,
    ActivityType? type,
    DifficultyLevel? difficulty,
    bool? isCompleted,
    int? score,
    int? maxScore,
    String? instruction,
    Map<String, dynamic>? data,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      instruction: instruction ?? this.instruction,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'difficulty': difficulty.toString(),
      'isCompleted': isCompleted,
      'score': score,
      'maxScore': maxScore,
      'instruction': instruction,
      'data': data,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == json['type']
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == json['difficulty']
      ),
      isCompleted: json['isCompleted'] ?? false,
      score: json['score'] ?? 0,
      maxScore: json['maxScore'] ?? 100,
      instruction: json['instruction'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  double get progressPercentage => maxScore > 0 ? score / maxScore : 0.0;
}

class WordFormationData {
  final List<String> availableSyllables;
  final String targetWord;
  final String imageUrl;
  final String audioUrl;

  const WordFormationData({
    required this.availableSyllables,
    required this.targetWord,
    required this.imageUrl,
    required this.audioUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'availableSyllables': availableSyllables,
      'targetWord': targetWord,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }

  factory WordFormationData.fromJson(Map<String, dynamic> json) {
    return WordFormationData(
      availableSyllables: List<String>.from(json['availableSyllables']),
      targetWord: json['targetWord'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
    );
  }
}