import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';
import '../widgets/reflection_card.dart';
import '../widgets/mood_chart.dart';
import '../widgets/animated_reflection_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflections = ref.watch(reflectionsProvider);
    final recentReflections = reflections.take(5).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'EchoMirror',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => Navigator.pushNamed(context, AppRouter.history),
                tooltip: 'History',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
                tooltip: 'Settings',
              ),
            ],
          ),

          // Welcome Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to explore your inner world?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2),
                ],
              ),
            ),
          ),

          // Main Reflection Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedReflectionButton(
                onPressed: () => Navigator.pushNamed(context, AppRouter.reflectionInput),
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
          ),

          // Mood Overview (if has data)
          if (reflections.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Mood Journey',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    const MoodChart(),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ),
          ],

          // Recent Reflections Header
          if (recentReflections.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Echoes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.history),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
            ),

          // Recent Reflections List
          if (recentReflections.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final reflection = recentReflections[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: ReflectionCard(
                      reflection: reflection,
                      onTap: () {
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
                      },
                    ),
                  ).animate().fadeIn(
                        duration: 400.ms,
                        delay: (1000 + index * 100).ms,
                      ).slideY(begin: 0.2);
                },
                childCount: recentReflections.length,
              ),
            ),

          // Empty State
          if (reflections.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reflections yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your first reflection to discover\nyour echo story',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
