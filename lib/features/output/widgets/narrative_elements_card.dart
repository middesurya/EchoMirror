import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/echo_response.dart';

class NarrativeElementsCard extends StatelessWidget {
  final NarrativeElements narrativeElements;
  final String genre;

  const NarrativeElementsCard({
    super.key,
    required this.narrativeElements,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ElementItem(
        icon: Icons.person,
        label: 'Archetype',
        value: narrativeElements.archetype,
      ),
      _ElementItem(
        icon: Icons.location_on,
        label: 'Setting',
        value: narrativeElements.setting,
      ),
      _ElementItem(
        icon: Icons.flash_on,
        label: 'Power',
        value: narrativeElements.power,
      ),
    ];

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Story Elements',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildElementChip(context, item, index);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElementChip(BuildContext context, _ElementItem item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                _capitalize(item.value),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms).scale(
          begin: const Offset(0.9, 0.9),
          duration: 200.ms,
        );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _ElementItem {
  final IconData icon;
  final String label;
  final String value;

  _ElementItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
