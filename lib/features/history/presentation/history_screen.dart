import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../shared/models/reflection.dart';
import '../../home/widgets/reflection_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filterEmotion = 'all';
  String _filterSentiment = 'all';
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final reflections = ref.watch(reflectionsProvider);
    final filteredReflections = _filterReflections(reflections);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          if (_hasActiveFilters())
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: filteredReflections.isEmpty
          ? _buildEmptyState()
          : _buildReflectionsList(filteredReflections),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _hasActiveFilters() ? 'No reflections match filters' : 'No reflections yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasActiveFilters()
                ? 'Try adjusting your filters'
                : 'Start your first reflection',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildReflectionsList(List<Reflection> reflections) {
    // Group by date
    final grouped = <String, List<Reflection>>{};
    for (final reflection in reflections) {
      final key = _getDateKey(reflection.createdAt);
      grouped.putIfAbsent(key, () => []).add(reflection);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, groupIndex) {
        final dateKey = grouped.keys.elementAt(groupIndex);
        final group = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                dateKey,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ).animate().fadeIn(delay: (groupIndex * 100).ms),

            // Reflections for this date
            ...group.asMap().entries.map((entry) {
              final index = entry.key;
              final reflection = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key(reflection.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteConfirmation(reflection);
                  },
                  onDismissed: (direction) {
                    ref.read(reflectionsProvider.notifier).deleteReflection(reflection.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reflection deleted')),
                    );
                  },
                  child: ReflectionCard(
                    reflection: reflection,
                    onTap: () => _navigateToEcho(reflection),
                  ),
                ),
              ).animate().fadeIn(delay: ((groupIndex + index) * 50).ms).slideX(begin: 0.1);
            }),
          ],
        );
      },
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date);
    }
    return DateFormat('MMMM d, y').format(date);
  }

  List<Reflection> _filterReflections(List<Reflection> reflections) {
    return reflections.where((r) {
      // Filter by emotion
      if (_filterEmotion != 'all') {
        if (r.emotionData?.dominantEmotion.toLowerCase() != _filterEmotion.toLowerCase()) {
          return false;
        }
      }

      // Filter by sentiment
      if (_filterSentiment != 'all') {
        if (r.sentimentData?.sentiment.toLowerCase() != _filterSentiment.toLowerCase()) {
          return false;
        }
      }

      // Filter by date range
      if (_dateRange != null) {
        if (r.createdAt.isBefore(_dateRange!.start) ||
            r.createdAt.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _hasActiveFilters() {
    return _filterEmotion != 'all' ||
        _filterSentiment != 'all' ||
        _dateRange != null;
  }

  void _clearFilters() {
    setState(() {
      _filterEmotion = 'all';
      _filterSentiment = 'all';
      _dateRange = null;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Reflections',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Emotion filter
                Text(
                  'Emotion',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['all', 'happy', 'sad', 'angry', 'anxious', 'neutral']
                      .map((emotion) => FilterChip(
                            label: Text(emotion == 'all' ? 'All' : emotion.capitalize()),
                            selected: _filterEmotion == emotion,
                            onSelected: (selected) {
                              setModalState(() => _filterEmotion = emotion);
                              setState(() {});
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Sentiment filter
                Text(
                  'Sentiment',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['all', 'positive', 'negative', 'neutral']
                      .map((sentiment) => FilterChip(
                            label: Text(sentiment == 'all' ? 'All' : sentiment.capitalize()),
                            selected: _filterSentiment == sentiment,
                            onSelected: (selected) {
                              setModalState(() => _filterSentiment = sentiment);
                              setState(() {});
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Date range
                Text(
                  'Date Range',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateRange,
                    );
                    if (range != null) {
                      setModalState(() => _dateRange = range);
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _dateRange != null
                        ? '${DateFormat.MMMd().format(_dateRange!.start)} - ${DateFormat.MMMd().format(_dateRange!.end)}'
                        : 'Select dates',
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(Reflection reflection) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reflection?'),
        content: const Text(
          'This will permanently delete this reflection and its echo story.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToEcho(Reflection reflection) {
    final echoResponses = ref.read(echoResponsesProvider);
    final echo = echoResponses
        .cast<dynamic>()
        .firstWhere(
          (e) => e.reflectionId == reflection.id,
          orElse: () => null,
        );

    Navigator.pushNamed(
      context,
      AppRouter.echoOutput,
      arguments: {
        'reflection': reflection,
        'echoResponse': echo,
      },
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
