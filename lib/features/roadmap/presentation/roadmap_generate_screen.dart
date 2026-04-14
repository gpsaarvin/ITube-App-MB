import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/keyboard_dismiss.dart';
import '../../../core/utils/content_filter.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../data/roadmap_repository.dart';
import '../domain/roadmap_model.dart';
import 'phase_tile.dart';
import 'video_card.dart';

class RoadmapGenerateScreen extends ConsumerStatefulWidget {
  const RoadmapGenerateScreen({super.key, this.initialTopic});

  final String? initialTopic;

  @override
  ConsumerState<RoadmapGenerateScreen> createState() =>
      _RoadmapGenerateScreenState();
}

class _RoadmapGenerateScreenState
    extends ConsumerState<RoadmapGenerateScreen> {
  late final TextEditingController _controller;
  final ContentFilter _contentFilter = ContentFilter();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTopic ?? '');
    if ((widget.initialTopic ?? '').trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generate();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final topic = _controller.text.trim();
    if (topic.isEmpty) return;
    if (_contentFilter.isBlocked(topic)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This topic is not supported. Please try a different subject.',
          ),
        ),
      );
      return;
    }
    await ref.read(roadmapGenerationProvider.notifier).generate(topic);
  }

  Future<void> _saveToLibrary(RoadmapModel roadmap) async {
    await ref
        .read(roadmapRepositoryProvider)
        .setAddedToLearning(roadmap.id, true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to your library.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roadmapAsync = ref.watch(roadmapGenerationProvider);
    final roadmap = roadmapAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Roadmap'),
      ),
      floatingActionButton: roadmap == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _saveToLibrary(roadmap),
              icon: const Icon(Icons.bookmark_add),
              label: const Text('Save to Library'),
            ),
      body: KeyboardDismiss(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _generate(),
                    decoration: const InputDecoration(
                      hintText: 'Enter a topic to build a roadmap',
                      prefixIcon: Icon(Icons.auto_awesome),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _generate,
                  child: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (roadmapAsync.isLoading) _loadingSection(context),
            if (roadmapAsync.hasError)
              _errorSection(context, roadmapAsync.error.toString()),
            if (!roadmapAsync.isLoading && roadmap == null)
              _emptyPrompt(context),
            if (roadmap != null) _roadmapSection(context, roadmap),
          ],
        ),
      ),
    );
  }

  Widget _loadingSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Lottie.network(
            'https://assets6.lottiefiles.com/packages/lf20_1pxqjqps.json',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Building your roadmap...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _errorSection(BuildContext context, String error) {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Something went wrong: $error',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _emptyPrompt(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start with a topic you want to master.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'We will design a structured roadmap and match the best YouTube tutorials for each phase.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.mutedText),
        ),
      ],
    );
  }

  Widget _roadmapSection(BuildContext context, RoadmapModel roadmap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          roadmap.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        ...roadmap.phases.asMap().entries.map((entry) {
          final index = entry.key;
          final phase = entry.value;
          return PhaseTile(
            phase: phase,
            index: index,
            children: phase.topics.map((topic) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 8),
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
  }
}
