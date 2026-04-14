import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AnalysisResultCard extends StatelessWidget {
  const AnalysisResultCard({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No insights available.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.mutedText),
              ),
            )
          else
            ...items.map(
              (item) => ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(item),
              ),
            ),
        ],
      ),
    );
  }
}
