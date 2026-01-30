import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class StoryDisplay extends StatelessWidget {
  final String story;
  final String genre;

  const StoryDisplay({
    super.key,
    required this.story,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = story.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    final genreGradient = AppColors.getGenreGradient(genre);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Story title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: genreGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_stories,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Echo Story',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Story paragraphs
        ...paragraphs.asMap().entries.map((entry) {
          final index = entry.key;
          final paragraph = entry.value;
          
          // Check if it's a special marker
          if (paragraph.startsWith('[') && paragraph.endsWith(']')) {
            return _buildEndMarker(context, paragraph);
          }
          if (paragraph.startsWith('~') && paragraph.endsWith('~')) {
            return _buildEndMarker(context, paragraph);
          }
          if (paragraph.contains('🌱')) {
            return _buildEndMarker(context, paragraph);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              paragraph,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    letterSpacing: 0.3,
                  ),
            ).animate().fadeIn(delay: (300 + index * 150).ms),
          );
        }),
      ],
    );
  }

  Widget _buildEndMarker(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.2,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    ).animate().fadeIn(delay: 1500.ms);
  }
}
