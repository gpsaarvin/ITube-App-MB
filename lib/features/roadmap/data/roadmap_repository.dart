import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/phase_model.dart';
import '../domain/roadmap_model.dart';
import '../domain/topic_model.dart';
import '../domain/video_model.dart';
import 'openrouter_service.dart';
import 'youtube_service.dart';

final roadmapRepositoryProvider = Provider<RoadmapRepository>((ref) {
  return RoadmapRepository(
    firestore: FirebaseFirestore.instance,
    openRouterService: ref.watch(openRouterServiceProvider),
    youTubeService: ref.watch(youTubeServiceProvider),
  );
});

final roadmapStreamProvider = StreamProvider.family<RoadmapModel?, String>(
  (ref, roadmapId) =>
      ref.watch(roadmapRepositoryProvider).watchRoadmap(roadmapId),
);

final roadmapGenerationProvider =
    AsyncNotifierProvider<RoadmapGenerationNotifier, RoadmapModel?>(
  RoadmapGenerationNotifier.new,
);

class RoadmapRepository {
  RoadmapRepository({
    required FirebaseFirestore firestore,
    required OpenRouterService openRouterService,
    required YouTubeService youTubeService,
  })  : _firestore = firestore,
        _openRouterService = openRouterService,
        _youTubeService = youTubeService;

  final FirebaseFirestore _firestore;
  final OpenRouterService _openRouterService;
  final YouTubeService _youTubeService;

  CollectionReference<Map<String, dynamic>> get _roadmaps =>
      _firestore.collection('roadmaps');

  Future<RoadmapModel> generateRoadmap({
    required String topic,
    required String userId,
  }) async {
    final response = await _openRouterService.generateRoadmap(topic);
    final title = response['title']?.toString().trim().isNotEmpty == true
        ? response['title'].toString()
        : topic;
    final phasesJson = (response['phases'] ?? []) as List<dynamic>;
    final phases = phasesJson
        .map((phase) => PhaseModel.fromJson(Map<String, dynamic>.from(phase)))
        .toList();

    final doc = _roadmaps.doc();
    final roadmap = RoadmapModel(
      id: doc.id,
      userId: userId,
      title: title,
      topic: topic,
      phases: phases,
      addedToLearning: false,
      createdAt: DateTime.now(),
    );
    await doc.set(roadmap.toJson());
    return roadmap;
  }

  Stream<RoadmapModel?> watchRoadmap(String roadmapId) {
    return _roadmaps.doc(roadmapId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return RoadmapModel.fromJson(data, snapshot.id);
    });
  }

  Stream<List<RoadmapModel>> watchUserRoadmaps({
    required String userId,
    required bool onlyLearning,
  }) {
    Query<Map<String, dynamic>> query = _roadmaps.where(
      'userId',
      isEqualTo: userId,
    );
    if (onlyLearning) {
      query = query.where('addedToLearning', isEqualTo: true);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => RoadmapModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> setAddedToLearning(String roadmapId, bool value) async {
    await _roadmaps.doc(roadmapId).update({'addedToLearning': value});
  }

  Future<void> updatePhases(String roadmapId, List<PhaseModel> phases) async {
    await _roadmaps.doc(roadmapId).update({
      'phases': phases.map((phase) => phase.toJson()).toList(),
    });
  }

  Future<void> updateRoadmap(RoadmapModel roadmap) async {
    await _roadmaps.doc(roadmap.id).set(roadmap.toJson());
  }

  Future<void> updateTopicWatched({
    required RoadmapModel roadmap,
    required int phaseIndex,
    required int topicIndex,
    required bool watched,
  }) async {
    final updated = _updateTopic(
      roadmap: roadmap,
      phaseIndex: phaseIndex,
      topicIndex: topicIndex,
      update: (topic) => topic.copyWith(isWatched: watched),
    );
    await updatePhases(updated.id, updated.phases);
  }

  Future<RoadmapModel> updateTopicVideo({
    required RoadmapModel roadmap,
    required int phaseIndex,
    required int topicIndex,
    required VideoModel video,
  }) async {
    final updated = _updateTopic(
      roadmap: roadmap,
      phaseIndex: phaseIndex,
      topicIndex: topicIndex,
      update: (topic) => topic.copyWith(video: video),
    );
    await updatePhases(updated.id, updated.phases);
    return updated;
  }

  Future<RoadmapModel> refreshVideos(RoadmapModel roadmap) async {
    RoadmapModel updated = roadmap;
    for (var phaseIndex = 0; phaseIndex < roadmap.phases.length; phaseIndex++) {
      final phase = roadmap.phases[phaseIndex];
      for (var topicIndex = 0; topicIndex < phase.topics.length; topicIndex++) {
        final topic = phase.topics[topicIndex];
        final video = await _youTubeService.searchVideo(topic.searchQuery);
        if (video != null) {
          updated = await updateTopicVideo(
            roadmap: updated,
            phaseIndex: phaseIndex,
            topicIndex: topicIndex,
            video: video,
          );
        }
      }
    }
    return updated;
  }

  RoadmapModel _updateTopic({
    required RoadmapModel roadmap,
    required int phaseIndex,
    required int topicIndex,
    required TopicModel Function(TopicModel topic) update,
  }) {
    final phases = List<PhaseModel>.from(roadmap.phases);
    final phase = phases[phaseIndex];
    final topics = List<TopicModel>.from(phase.topics);
    topics[topicIndex] = update(topics[topicIndex]);
    phases[phaseIndex] = phase.copyWith(topics: topics);
    return roadmap.copyWith(phases: phases);
  }

  YouTubeService get youTubeService => _youTubeService;
}

class RoadmapGenerationNotifier extends AsyncNotifier<RoadmapModel?> {
  @override
  Future<RoadmapModel?> build() async => null;

  Future<void> generate(String topic) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw Exception('You need to sign in to generate a roadmap.');
      }
      final repository = ref.read(roadmapRepositoryProvider);
      final roadmap = await repository.generateRoadmap(
        topic: topic,
        userId: user.uid,
      );
      state = AsyncData(roadmap);
      unawaited(_loadVideos(roadmap));
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> _loadVideos(RoadmapModel roadmap) async {
    final repository = ref.read(roadmapRepositoryProvider);
    RoadmapModel current = roadmap;

    for (var phaseIndex = 0; phaseIndex < roadmap.phases.length; phaseIndex++) {
      final phase = roadmap.phases[phaseIndex];
      for (var topicIndex = 0; topicIndex < phase.topics.length; topicIndex++) {
        final topic = phase.topics[topicIndex];
        final video = await repository.youTubeService.searchVideo(
          topic.searchQuery,
        );
        if (video != null) {
          current = await repository.updateTopicVideo(
            roadmap: current,
            phaseIndex: phaseIndex,
            topicIndex: topicIndex,
            video: video,
          );
          state = AsyncData(current);
        }
      }
    }
  }
}
