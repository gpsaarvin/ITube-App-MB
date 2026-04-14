import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';

final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  return OpenRouterService();
});

class OpenRouterService {
  OpenRouterService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.openRouterBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Authorization': 'Bearer ${ApiConstants.openRouterApiKey}',
            'HTTP-Referer': 'https://itubelearn.app',
            'X-Title': 'iTube Learn',
            'Content-Type': 'application/json',
          },
        ),
      );

  final Dio _dio;

  static const String _roadmapPrompt =
      'You are an expert learning path designer. Given a topic, return a structured '
      'JSON learning roadmap with 4-6 phases. Each phase has a title, description, '
      'and 3-5 topics. Each topic has a title, description, and a YouTube search '
      'query (5-8 words). Return ONLY valid JSON, no markdown, no explanation.';

  static const String _resumePrompt =
      'Analyze this resume for ATS compatibility. Return ONLY valid JSON: '
      '{ score: int 0-100, strengths: string[], weaknesses: string[], '
      'missingKeywords: string[], suggestions: string[] } '
      'No markdown, no extra text.';

  Future<Map<String, dynamic>> generateRoadmap(String topic) async {
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': ApiConstants.openRouterModel,
        'messages': [
          {'role': 'system', 'content': _roadmapPrompt},
          {'role': 'user', 'content': topic},
        ],
        'temperature': 0.6,
      },
    );
    return _extractJson(response.data);
  }

  Future<Map<String, dynamic>> analyzeResume({
    required String resumeText,
    required String jobRole,
  }) async {
    final prompt = jobRole.trim().isEmpty
        ? resumeText
        : 'Target role: $jobRole\n\n$resumeText';
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': ApiConstants.openRouterModel,
        'messages': [
          {'role': 'system', 'content': _resumePrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.4,
      },
    );
    return _extractJson(response.data);
  }

  Map<String, dynamic> _extractJson(dynamic data) {
    final content =
        data['choices']?[0]?['message']?['content']?.toString() ?? '';
    final jsonString = _extractJsonString(content);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  String _extractJsonString(String content) {
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('OpenRouter response did not contain valid JSON.');
    }
    return content.substring(start, end + 1).trim();
  }
}
