import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../roadmap/data/roadmap_repository.dart';
import '../../roadmap/domain/roadmap_model.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.watch(roadmapRepositoryProvider));
});

final libraryRoadmapsProvider = StreamProvider<List<RoadmapModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(libraryRepositoryProvider).watchLibraryRoadmaps(user.uid);
});

class LibraryRepository {
  LibraryRepository(this._roadmapRepository);

  final RoadmapRepository _roadmapRepository;

  Stream<List<RoadmapModel>> watchLibraryRoadmaps(String userId) {
    return _roadmapRepository.watchUserRoadmaps(
      userId: userId,
      onlyLearning: true,
    );
  }
}
