import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';

class GenreSelector extends ConsumerWidget {
  const GenreSelector({super.key});

  static const List<Map<String, dynamic>> _genres = [
    {
      'id': 'cyberpunk',
      'name': 'Cyberpunk',
      'icon': Icons.memory,
      'description': 'Neon-lit dystopia',
      'colors': [Color(0xFF00FFFF), Color(0xFFFF00FF)],
    },
    {
      'id': 'fantasy',
      'name': 'Fantasy',
      'icon': Icons.auto_awesome,
      'description': 'Magical realms',
      'colors': [Color(0xFFD4AF37), Color(0xFF8B4513)],
    },
    {
      'id': 'horror',
      'name': 'Horror',
      'icon': Icons.visibility,
      'description': 'Eldritch mysteries',
      'colors': [Color(0xFF8B0000), Color(0xFF2D0A0A)],
    },
    {
      'id': 'solarpunk',
      'name': 'Solarpunk',
      'icon': Icons.eco,
      'description': 'Utopian future',
      'colors': [Color(0xFF7CB342), Color(0xFF558B2F)],
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGenre = ref.watch(selectedGenreProvider);

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          final genre = _genres[index];
          final isSelected = selectedGenre == genre['id'];
          final colors = genre['colors'] as List<Color>;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == _genres.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () {
                ref.read(selectedGenreProvider.notifier).state =
                    isSelected ? null : genre['id'] as String;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? colors
                        : [
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? colors.first : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.first.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        genre['icon'] as IconData,
                        size: 24,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        genre['name'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                      ),
                      Text(
                        genre['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white70
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2),
          );
        },
      ),
    );
  }
}
