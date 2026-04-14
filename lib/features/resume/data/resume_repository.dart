import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/resume_analysis_model.dart';
import '../../roadmap/data/openrouter_service.dart';

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  return ResumeRepository(
    firestore: FirebaseFirestore.instance,
    openRouterService: ref.watch(openRouterServiceProvider),
  );
});

final resumeAnalysisNotifierProvider =
    AsyncNotifierProvider<ResumeAnalysisNotifier, ResumeAnalysisModel?>(
  ResumeAnalysisNotifier.new,
);

final resumeHistoryProvider = StreamProvider<List<ResumeAnalysisModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(resumeRepositoryProvider).watchAnalyses(user.uid);
});

class ResumeRepository {
  ResumeRepository({
    required FirebaseFirestore firestore,
    required OpenRouterService openRouterService,
  })  : _firestore = firestore,
        _openRouterService = openRouterService;

  final FirebaseFirestore _firestore;
  final OpenRouterService _openRouterService;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('resumeAnalyses')
        .doc(userId)
        .collection('analyses');
  }

  Future<ResumeAnalysisModel> analyzeResume({
    required String userId,
    required String resumeText,
    required String jobRole,
    required String fileName,
  }) async {
    final response = await _openRouterService.analyzeResume(
      resumeText: resumeText,
      jobRole: jobRole,
    );

    final analysis = ResumeAnalysisModel(
      id: '',
      userId: userId,
      fileName: fileName,
      jobRole: jobRole,
      analyzedAt: DateTime.now(),
      score: (response['score'] ?? 0) as int,
      strengths: (response['strengths'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      weaknesses: (response['weaknesses'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      missingKeywords: (response['missingKeywords'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      suggestions: (response['suggestions'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );

    final doc = _collection(userId).doc();
    final stored = analysis.copyWith(id: doc.id);
    await doc.set(stored.toJson());
    return stored;
  }

  Stream<List<ResumeAnalysisModel>> watchAnalyses(String userId) {
    return _collection(userId)
        .orderBy('analyzedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ResumeAnalysisModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }
}

class ResumeAnalysisNotifier extends AsyncNotifier<ResumeAnalysisModel?> {
  @override
  Future<ResumeAnalysisModel?> build() async => null;

  Future<void> analyze({
    required String resumeText,
    required String jobRole,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw Exception('You need to sign in to analyze a resume.');
      }
      final repository = ref.read(resumeRepositoryProvider);
      final analysis = await repository.analyzeResume(
        userId: user.uid,
        resumeText: resumeText,
        jobRole: jobRole,
        fileName: fileName,
      );
      state = AsyncData(analysis);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }
}
