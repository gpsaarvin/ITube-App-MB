import 'topic_model.dart';

class PhaseModel {
  const PhaseModel({
    required this.title,
    required this.description,
    required this.topics,
  });

  final String title;
  final String description;
  final List<TopicModel> topics;

  PhaseModel copyWith({
    String? title,
    String? description,
    List<TopicModel>? topics,
  }) {
    return PhaseModel(
      title: title ?? this.title,
      description: description ?? this.description,
      topics: topics ?? this.topics,
    );
  }

  factory PhaseModel.fromJson(Map<String, dynamic> json) {
    final topicsJson = (json['topics'] ?? []) as List<dynamic>;
    return PhaseModel(
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      topics: topicsJson
          .map((topic) => TopicModel.fromJson(Map<String, dynamic>.from(topic)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'topics': topics.map((topic) => topic.toJson()).toList(),
    };
  }
}
