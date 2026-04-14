import 'package:flutter/material.dart';

import '../domain/phase_model.dart';

class PhaseTile extends StatelessWidget {
  const PhaseTile({
    super.key,
    required this.phase,
    required this.index,
    required this.children,
  });

  final PhaseModel phase;
  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(
          'Phase ${index + 1}: ${phase.title}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(phase.description),
        children: children,
      ),
    );
  }
}
