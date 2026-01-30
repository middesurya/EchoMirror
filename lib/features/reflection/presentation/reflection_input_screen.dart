import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/emotion_service.dart';
import '../../../core/services/sentiment_service.dart';
import '../../../core/services/story_service.dart';
import '../../../providers/providers.dart';
import '../../../shared/models/reflection.dart';
import '../widgets/voice_recorder_widget.dart';
import '../widgets/camera_capture_widget.dart';
import '../widgets/genre_selector.dart';

class ReflectionInputScreen extends ConsumerStatefulWidget {
  const ReflectionInputScreen({super.key});

  @override
  ConsumerState<ReflectionInputScreen> createState() => _ReflectionInputScreenState();
}

class _ReflectionInputScreenState extends ConsumerState<ReflectionInputScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  String? _voiceRecordingPath;
  String? _capturedImagePath;
  bool _isProcessing = false;
  String _processingStage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Reflection'),
        actions: [
          TextButton.icon(
            onPressed: _canSubmit() ? _processReflection : null,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate'),
          ),
        ],
      ),
      body: _isProcessing
          ? _buildProcessingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Text(
                    "What's on your mind?",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 8),
                  Text(
                    'Share your thoughts through voice or text. Optionally capture your expression.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                  const SizedBox(height: 24),

                  // Input Method Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic, size: 20),
                              SizedBox(width: 8),
                              Text('Voice'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Text'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Tab Content
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Voice Tab
                        VoiceRecorderWidget(
                          onTranscription: (text) {
                            setState(() {
                              _textController.text = text;
                            });
                          },
                          onRecordingPath: (path) {
                            setState(() {
                              _voiceRecordingPath = path;
                            });
                          },
                        ),
                        // Text Tab
                        _buildTextInput(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Transcribed/entered text display
                  if (_textController.text.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your reflection',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _textController.text,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(),
                  ],

                  const SizedBox(height: 24),

                  // Camera Capture Section
                  Text(
                    'Capture your expression (optional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A selfie helps us understand your emotional state better.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  CameraCaptureWidget(
                    onImageCaptured: (path) {
                      setState(() {
                        _capturedImagePath = path;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Genre Selector
                  Text(
                    'Choose your story genre',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const GenreSelector(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      focusNode: _textFocusNode,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: 'Write about your day, feelings, thoughts...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated processing indicator
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 48,
              color: Colors.white,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: 1500.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.1, 1.1),
              )
              .then()
              .scale(
                duration: 1500.ms,
                begin: const Offset(1.1, 1.1),
                end: const Offset(1.0, 1.0),
              ),

          const SizedBox(height: 32),

          Text(
            _processingStage,
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _textController.text.trim().isNotEmpty && !_isProcessing;
  }

  Future<void> _processReflection() async {
    if (!_canSubmit()) return;

    setState(() {
      _isProcessing = true;
      _processingStage = 'Analyzing your reflection...';
    });

    try {
      // Create reflection object
      final reflectionId = const Uuid().v4();
      var reflection = Reflection(
        id: reflectionId,
        text: _textController.text.trim(),
        createdAt: DateTime.now(),
        voiceRecordingPath: _voiceRecordingPath,
        imagePath: _capturedImagePath,
      );

      // Analyze sentiment
      setState(() => _processingStage = 'Understanding your emotions...');
      final sentimentService = ref.read(sentimentServiceProvider);
      final sentimentData = await sentimentService.analyze(reflection.text);

      // Analyze face emotion if image captured
      EmotionData? emotionData;
      if (_capturedImagePath != null) {
        setState(() => _processingStage = 'Reading your expression...');
        final emotionService = ref.read(emotionServiceProvider);
        emotionData = await emotionService.analyzeImage(_capturedImagePath!);
      }

      // Update reflection with analysis
      reflection = reflection.copyWith(
        sentimentData: sentimentData,
        emotionData: emotionData,
      );

      // Generate echo story
      setState(() => _processingStage = 'Weaving your echo story...');
      final storyService = ref.read(storyServiceProvider);
      final selectedGenre = ref.read(selectedGenreProvider);
      final echoResponse = await storyService.generateEcho(
        reflection: reflection,
        preferredGenre: selectedGenre,
      );

      // Link echo to reflection
      reflection = reflection.copyWith(echoResponseId: echoResponse.id);

      // Save to storage
      await ref.read(reflectionsProvider.notifier).addReflection(reflection);
      await ref.read(echoResponsesProvider.notifier).addEchoResponse(echoResponse);

      // Navigate to output screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.echoOutput,
          arguments: {
            'reflection': reflection,
            'echoResponse': echoResponse,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing reflection: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
