import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../data/library_repository.dart';
import '../../roadmap/data/roadmap_repository.dart';
import '../../../core/constants/app_colors.dart';
import 'library_item_card.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roadmapsAsync = ref.watch(libraryRoadmapsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(libraryRoadmapsProvider),
        child: roadmapsAsync.when(
          data: (roadmaps) {
            if (roadmaps.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  SvgPicture.network(
                    'https://www.svgrepo.com/show/350865/bookmark.svg',
                    height: 140,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No roadmaps saved yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Generate one to start learning.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/roadmap/generate'),
                    child: const Text('Generate one'),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: roadmaps.length,
              itemBuilder: (context, index) {
                final roadmap = roadmaps[index];
                return Dismissible(
                  key: ValueKey(roadmap.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    ref
                        .read(roadmapRepositoryProvider)
                        .setAddedToLearning(roadmap.id, false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from library.')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LibraryItemCard(
                      roadmap: roadmap,
                      onTap: () => context.go('/roadmap/${roadmap.id}'),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
