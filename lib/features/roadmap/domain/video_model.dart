class VideoModel {
  const VideoModel({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.videoId,
    required this.duration,
  });

  final String id;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String videoId;
  final String duration;

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: (json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      channelName: (json['channelName'] ?? '') as String,
      thumbnailUrl: (json['thumbnailUrl'] ?? '') as String,
      videoId: (json['videoId'] ?? '') as String,
      duration: (json['duration'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelName': channelName,
      'thumbnailUrl': thumbnailUrl,
      'videoId': videoId,
      'duration': duration,
    };
  }
}
