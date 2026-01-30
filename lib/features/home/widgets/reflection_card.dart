import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/reflection.dart';
import '../../../core/theme/app_colors.dart';

class ReflectionCard extends StatelessWidget {
  final Reflection reflection;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ReflectionCard({
    super.key,
    required this.reflection,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final emotionColor = _getEmotionColor(
      reflection.emotionData?.dominantEmotion ?? 'neutral',
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: emotionColor,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and emotion badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(reflection.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (reflection.emotionData != null)
                      _EmotionBadge(
                        emotion: reflection.emotionData!.dominantEmotion,
                        color: emotionColor,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Reflection text preview
                Text(
                  reflection.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                // Tags and indicators
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (reflection.voiceRecordingPath != null)
                      _IconTag(
                        icon: Icons.mic,
                        tooltip: 'Voice recording',
                      ),
                    if (reflection.imagePath != null)
                      _IconTag(
                        icon: Icons.face,
                        tooltip: 'Face capture',
                      ),
                    if (reflection.echoResponseId != null)
                      _IconTag(
                        icon: Icons.auto_awesome,
                        tooltip: 'Echo generated',
                        isPrimary: true,
                      ),
                    const Spacer(),
                    if (reflection.sentimentData != null)
                      _SentimentIndicator(
                        sentiment: reflection.sentimentData!.sentiment,
                        score: reflection.sentimentData!.score,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
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
      case 'calm':
        return AppColors.calm;
      default:
        return AppColors.neutral;
    }
  }
}

class _EmotionBadge extends StatelessWidget {
  final String emotion;
  final Color color;

  const _EmotionBadge({
    required this.emotion,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            emotion.capitalize(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTag extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isPrimary;

  const _IconTag({
    required this.icon,
    required this.tooltip,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isPrimary
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SentimentIndicator extends StatelessWidget {
  final String sentiment;
  final double score;

  const _SentimentIndicator({
    required this.sentiment,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final icon = switch (sentiment) {
      'positive' => Icons.trending_up,
      'negative' => Icons.trending_down,
      _ => Icons.trending_flat,
    };

    final color = switch (sentiment) {
      'positive' => AppColors.success,
      'negative' => AppColors.error,
      _ => AppColors.neutral,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${(score.abs() * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
