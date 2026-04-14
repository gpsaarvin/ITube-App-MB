import 'video_model.dart';

class TopicModel {
  const TopicModel({
    required this.title,
    required this.description,
    required this.searchQuery,
    this.video,
    this.isWatched = false,
  });

  final String title;
  final String description;
  final String searchQuery;
  final VideoModel? video;
  final bool isWatched;

  TopicModel copyWith({
    String? title,
    String? description,
    String? searchQuery,
    VideoModel? video,
    bool? isWatched,
  }) {
    return TopicModel(
      title: title ?? this.title,
      description: description ?? this.description,
      searchQuery: searchQuery ?? this.searchQuery,
      video: video ?? this.video,
      isWatched: isWatched ?? this.isWatched,
    );
  }

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      searchQuery: (json['searchQuery'] ?? '') as String,
      video: json['video'] == null
          ? null
          : VideoModel.fromJson(Map<String, dynamic>.from(json['video'])),
      isWatched: (json['isWatched'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'searchQuery': searchQuery,
      'video': video?.toJson(),
      'isWatched': isWatched,
    };
  }
}
