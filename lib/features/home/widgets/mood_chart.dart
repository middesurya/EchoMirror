import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/providers.dart';
import '../../../core/theme/app_colors.dart';

class MoodChart extends ConsumerWidget {
  const MoodChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotionStats = ref.watch(emotionStatsProvider);
    
    if (emotionStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = emotionStats.values.fold<int>(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emotion bars
            ...emotionStats.entries.map((entry) {
              final percentage = entry.value / total;
              final color = _getEmotionColor(entry.key);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _capitalizeFirst(entry.key),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            Text(
              'Based on ${total} reflection${total == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return AppColors.happy;
      case 'sad':
        return AppColors.sad;
      case 'angry':
        return AppColors.angry;
      case 'anxious':
      case 'fearful':
        return AppColors.anxious;
      case 'surprised':
        return AppColors.tertiary;
      case 'calm':
        return AppColors.calm;
      default:
        return AppColors.neutral;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
