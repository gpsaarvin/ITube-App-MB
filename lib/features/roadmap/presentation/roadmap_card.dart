import 'package:flutter/material.dart';

import '../domain/roadmap_model.dart';
import '../../../core/constants/app_colors.dart';

class RoadmapCard extends StatelessWidget {
  const RoadmapCard({
    super.key,
    required this.roadmap,
    this.onTap,
  });

  final RoadmapModel roadmap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = roadmap.progress;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roadmap.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Chip(
                    label: Text(roadmap.topic),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text('${roadmap.phases.length} phases'),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                color: AppColors.secondary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% completed',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
