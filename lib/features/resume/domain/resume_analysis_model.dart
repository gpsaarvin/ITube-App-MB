import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeAnalysisModel {
  const ResumeAnalysisModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.jobRole,
    required this.analyzedAt,
    required this.score,
    required this.strengths,
    required this.weaknesses,
    required this.missingKeywords,
    required this.suggestions,
  });

  final String id;
  final String userId;
  final String fileName;
  final String jobRole;
  final DateTime analyzedAt;
  final int score;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> missingKeywords;
  final List<String> suggestions;

  ResumeAnalysisModel copyWith({
    String? id,
    String? userId,
    String? fileName,
    String? jobRole,
    DateTime? analyzedAt,
    int? score,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? missingKeywords,
    List<String>? suggestions,
  }) {
    return ResumeAnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      jobRole: jobRole ?? this.jobRole,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      score: score ?? this.score,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      missingKeywords: missingKeywords ?? this.missingKeywords,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  factory ResumeAnalysisModel.fromJson(Map<String, dynamic> json, String id) {
    return ResumeAnalysisModel(
      id: id,
      userId: (json['userId'] ?? '') as String,
      fileName: (json['fileName'] ?? '') as String,
      jobRole: (json['jobRole'] ?? '') as String,
      analyzedAt: _readDate(json['analyzedAt']),
      score: (json['score'] ?? 0) as int,
      strengths: (json['strengths'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      missingKeywords: (json['missingKeywords'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fileName': fileName,
      'jobRole': jobRole,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
      'score': score,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'missingKeywords': missingKeywords,
      'suggestions': suggestions,
    };
  }

  Map<String, dynamic> toReportJson() {
    return {
      'userId': userId,
      'fileName': fileName,
      'jobRole': jobRole,
      'analyzedAt': analyzedAt.toIso8601String(),
      'score': score,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'missingKeywords': missingKeywords,
      'suggestions': suggestions,
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
