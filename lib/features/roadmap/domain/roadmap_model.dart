import 'package:cloud_firestore/cloud_firestore.dart';

import 'phase_model.dart';

class RoadmapModel {
  const RoadmapModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.topic,
    required this.phases,
    required this.addedToLearning,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String topic;
  final List<PhaseModel> phases;
  final bool addedToLearning;
  final DateTime createdAt;

  int get totalTopics =>
      phases.fold(0, (sum, phase) => sum + phase.topics.length);

  int get watchedTopics => phases.fold(
    0,
    (sum, phase) => sum + phase.topics.where((topic) => topic.isWatched).length,
  );

  double get progress => totalTopics == 0 ? 0 : watchedTopics / totalTopics;

  RoadmapModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? topic,
    List<PhaseModel>? phases,
    bool? addedToLearning,
    DateTime? createdAt,
  }) {
    return RoadmapModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      phases: phases ?? this.phases,
      addedToLearning: addedToLearning ?? this.addedToLearning,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory RoadmapModel.fromJson(Map<String, dynamic> json, String id) {
    final phasesJson = (json['phases'] ?? []) as List<dynamic>;
    return RoadmapModel(
      id: id,
      userId: (json['userId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      topic: (json['topic'] ?? '') as String,
      phases: phasesJson
          .map((phase) => PhaseModel.fromJson(Map<String, dynamic>.from(phase)))
          .toList(),
      addedToLearning: (json['addedToLearning'] ?? false) as bool,
      createdAt: _readDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'topic': topic,
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'addedToLearning': addedToLearning,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
