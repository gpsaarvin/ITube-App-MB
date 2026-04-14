import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/content_filter.dart';
import '../domain/video_model.dart';

final youTubeServiceProvider = Provider<YouTubeService>((ref) {
  return YouTubeService();
});

class YouTubeService {
  YouTubeService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://www.googleapis.com/youtube/v3',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

  final Dio _dio;
  final ContentFilter _contentFilter = ContentFilter();
  final Map<String, VideoModel> _cache = {};

  Future<VideoModel?> searchVideo(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty || _contentFilter.isBlocked(normalized)) {
      return null;
    }
    if (_cache.containsKey(normalized)) {
      return _cache[normalized];
    }

    VideoModel? video = await _search(normalized);
    if (video == null) {
      final parts = normalized.split(' ');
      if (parts.length > 3) {
        final shorter = parts.take(3).join(' ');
        video = await _search(shorter);
      }
    }

    if (video != null) {
      _cache[normalized] = video;
    }
    return video;
  }

  Future<Map<String, VideoModel?>> batchSearch(List<String> queries) async {
    final limiter = _AsyncLimiter(3);
    final results = <String, VideoModel?>{};

    await Future.wait(
      queries.map((query) async {
        await limiter.acquire();
        try {
          results[query] = await searchVideo(query);
        } finally {
          limiter.release();
        }
      }),
    );

    return results;
  }

  Future<VideoModel?> _search(String query) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'part': 'snippet',
          'type': 'video',
          'maxResults': 1,
          'key': ApiConstants.youtubeApiKey,
          'q': query,
        },
      );
      final items = response.data['items'] as List<dynamic>? ?? [];
      if (items.isEmpty) return null;
      final item = items.first as Map<String, dynamic>;
      final id = (item['id'] ?? {}) as Map<String, dynamic>;
      final snippet = (item['snippet'] ?? {}) as Map<String, dynamic>;
      final videoId = id['videoId']?.toString() ?? '';
      if (videoId.isEmpty) return null;

      final thumbnails = (snippet['thumbnails'] ?? {}) as Map<String, dynamic>;
      final thumbnail = (thumbnails['high'] ?? thumbnails['medium'] ?? {})
          as Map<String, dynamic>;
      final duration = await _fetchDuration(videoId);

      return VideoModel(
        id: videoId,
        title: snippet['title']?.toString() ?? 'Untitled video',
        channelName: snippet['channelTitle']?.toString() ?? 'Unknown channel',
        thumbnailUrl: thumbnail['url']?.toString() ?? '',
        videoId: videoId,
        duration: duration,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _fetchDuration(String videoId) async {
    try {
      final response = await _dio.get(
        '/videos',
        queryParameters: {
          'part': 'contentDetails',
          'id': videoId,
          'key': ApiConstants.youtubeApiKey,
        },
      );
      final items = response.data['items'] as List<dynamic>? ?? [];
      if (items.isEmpty) return '0:00';
      final content = (items.first as Map<String, dynamic>)['contentDetails']
          as Map<String, dynamic>;
      final isoDuration = content['duration']?.toString() ?? '';
      return _formatIsoDuration(isoDuration);
    } catch (_) {
      return '0:00';
    }
  }

  String _formatIsoDuration(String value) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(value);
    if (match == null) return '0:00';
    final hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '') ?? 0;
    final totalMinutes = hours * 60 + minutes;
    final minutesStr = totalMinutes.toString();
    final secondsStr = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      final hoursStr = hours.toString();
      final mm = minutes.toString().padLeft(2, '0');
      return '$hoursStr:$mm:$secondsStr';
    }
    return '$minutesStr:$secondsStr';
  }
}

class _AsyncLimiter {
  _AsyncLimiter(this.maxConcurrent);

  final int maxConcurrent;
  int _running = 0;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Future<void> acquire() {
    if (_running < maxConcurrent) {
      _running++;
      return Future.value();
    }
    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final next = _waitQueue.removeFirst();
      next.complete();
      return;
    }
    _running = (_running - 1).clamp(0, maxConcurrent);
  }
}
