import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../../library/data/library_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../resume/data/resume_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../roadmap/presentation/roadmap_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _recommendedTopics = const [
    'Python',
    'Machine Learning',
    'Web Development',
    'UI/UX Design',
    'Data Science',
    'Flutter',
  ];

  Future<void> _refresh() async {
    ref.invalidate(libraryRoadmapsProvider);
    ref.invalidate(resumeHistoryProvider);
  }

  void _goToGenerate(String topic) {
    if (topic.trim().isEmpty) return;
    final encoded = Uri.encodeComponent(topic.trim());
    context.go('/roadmap/generate?topic=$encoded');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final profileAsync = ref.watch(userProfileProvider);
    final roadmapsAsync = ref.watch(libraryRoadmapsProvider);
    final analysesAsync = ref.watch(resumeHistoryProvider);

    final name = profileAsync.valueOrNull?.name ??
        authUser?.displayName ??
        'Learner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('iTube Learn'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Welcome, $name',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _goToGenerate,
                    decoration: const InputDecoration(
                      hintText: 'Search a topic to learn',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _goToGenerate(_searchController.text),
                  child: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Recommended topics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recommendedTopics
                  .map(
                    (topic) => ActionChip(
                      label: Text(topic),
                      onPressed: () => _goToGenerate(topic),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Continue Learning',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            roadmapsAsync.when(
              data: (roadmaps) {
                if (roadmaps.isEmpty) {
                  return _emptySection(
                    context,
                    'No roadmaps saved yet',
                    'Generate a roadmap to start learning.',
                  );
                }
                return Column(
                  children: roadmaps.take(3).map((roadmap) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RoadmapCard(
                        roadmap: roadmap,
                        onTap: () => context.go('/roadmap/${roadmap.id}'),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _errorSection(
                context,
                'Could not load your library',
                error.toString(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Analyses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            analysesAsync.when(
              data: (analyses) {
                if (analyses.isEmpty) {
                  return _emptySection(
                    context,
                    'No resume analysis yet',
                    'Upload a resume to get feedback.',
                  );
                }
                return Column(
                  children: analyses.take(2).map((analysis) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '${analysis.score}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(analysis.fileName),
                        subtitle: Text(
                          DateFormatter.shortDate(analysis.analyzedAt),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _errorSection(
                context,
                'Could not load analyses',
                error.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySection(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.network(
            'https://www.svgrepo.com/show/354102/learning.svg',
            height: 120,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _errorSection(BuildContext context, String title, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
