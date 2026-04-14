import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../data/roadmap_repository.dart';
import '../domain/roadmap_model.dart';
import 'phase_tile.dart';
import 'video_card.dart';

class RoadmapDetailScreen extends ConsumerStatefulWidget {
  const RoadmapDetailScreen({super.key, required this.roadmapId});

  final String roadmapId;

  @override
  ConsumerState<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends ConsumerState<RoadmapDetailScreen> {
  bool _refreshing = false;

  Future<void> _refreshVideos(RoadmapModel roadmap) async {
    setState(() => _refreshing = true);
    await ref.read(roadmapRepositoryProvider).refreshVideos(roadmap);
    if (!mounted) return;
    setState(() => _refreshing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Videos refreshed.')),
    );
  }

  Future<void> _toggleWatched(
    RoadmapModel roadmap,
    int phaseIndex,
    int topicIndex,
    bool watched,
  ) async {
    await ref.read(roadmapRepositoryProvider).updateTopicWatched(
          roadmap: roadmap,
          phaseIndex: phaseIndex,
          topicIndex: topicIndex,
          watched: watched,
        );
  }

  @override
  Widget build(BuildContext context) {
    final roadmapAsync = ref.watch(roadmapStreamProvider(widget.roadmapId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roadmap'),
        actions: [
          if (roadmapAsync.valueOrNull != null)
            TextButton.icon(
              onPressed: _refreshing
                  ? null
                  : () => _refreshVideos(roadmapAsync.valueOrNull!),
              icon: _refreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('Refresh Videos'),
            ),
        ],
      ),
      body: roadmapAsync.when(
        data: (roadmap) {
          if (roadmap == null) {
            return const Center(child: Text('Roadmap not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                roadmap.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: roadmap.progress,
                backgroundColor: AppColors.border,
                color: AppColors.secondary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Text(
                '${roadmap.watchedTopics}/${roadmap.totalTopics} topics watched',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: 16),
              ...roadmap.phases.asMap().entries.map((entry) {
                final phaseIndex = entry.key;
                final phase = entry.value;
                return PhaseTile(
                  phase: phase,
                  index: phaseIndex,
                  children: phase.topics.asMap().entries.map((topicEntry) {
                    final topicIndex = topicEntry.key;
                    final topic = topicEntry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: topic.isWatched,
                            contentPadding: EdgeInsets.zero,
                            title: Text(topic.title),
                            subtitle: Text(topic.description),
                            onChanged: (value) => _toggleWatched(
                              roadmap,
                              phaseIndex,
                              topicIndex,
                              value ?? false,
                            ),
                          ),
                          if (topic.video == null)
                            const LoadingSkeleton(height: 100)
                          else
                            VideoCard(video: topic.video!),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
