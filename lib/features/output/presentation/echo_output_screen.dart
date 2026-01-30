import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/image_service.dart';
import '../../../providers/providers.dart';
import '../../../shared/models/reflection.dart';
import '../../../shared/models/echo_response.dart';
import '../widgets/story_display.dart';
import '../widgets/narrative_elements_card.dart';

class EchoOutputScreen extends ConsumerStatefulWidget {
  final Reflection? reflection;
  final EchoResponse? echoResponse;

  const EchoOutputScreen({
    super.key,
    this.reflection,
    this.echoResponse,
  });

  @override
  ConsumerState<EchoOutputScreen> createState() => _EchoOutputScreenState();
}

class _EchoOutputScreenState extends ConsumerState<EchoOutputScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TtsService _ttsService = TtsService.instance;
  
  bool _isSpeaking = false;
  bool _isGeneratingImage = false;
  String? _generatedImagePath;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _ttsService.onComplete = () {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    };
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final echoResponse = widget.echoResponse;
    final reflection = widget.reflection;

    if (echoResponse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Echo')),
        body: const Center(child: Text('No echo response available')),
      );
    }

    final genreGradient = AppColors.getGenreGradient(echoResponse.genre);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Your Echo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(gradient: genreGradient),
                child: Stack(
                  children: [
                    // Genre icon watermark
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Icon(
                        _getGenreIcon(echoResponse.genre),
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    // Genre badge
                    Positioned(
                      top: 100,
                      left: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getGenreIcon(echoResponse.genre),
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              echoResponse.genre.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                onPressed: _toggleNarration,
                tooltip: _isSpeaking ? 'Stop' : 'Listen',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareEcho,
                tooltip: 'Share',
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Narrative elements
                      NarrativeElementsCard(
                        narrativeElements: echoResponse.narrativeElements,
                        genre: echoResponse.genre,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      // Story
                      StoryDisplay(
                        story: echoResponse.story,
                        genre: echoResponse.genre,
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      // Generated Image (if available)
                      if (_generatedImagePath != null ||
                          echoResponse.localImagePath != null)
                        _buildGeneratedImage(
                          _generatedImagePath ?? echoResponse.localImagePath!,
                        ),

                      // Generate Image Button
                      if (_generatedImagePath == null &&
                          echoResponse.localImagePath == null)
                        _buildGenerateImageButton(),

                      const SizedBox(height: 24),

                      // Original reflection card
                      if (reflection != null) ...[
                        Text(
                          'Your Original Reflection',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reflection.text,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (reflection.emotionData != null) ...[
                                  const SizedBox(height: 12),
                                  _buildEmotionChip(reflection.emotionData!),
                                ],
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        icon: const Icon(Icons.home),
        label: const Text('Home'),
      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5),
    );
  }

  Widget _buildEmotionChip(EmotionData emotionData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getEmotionColor(emotionData.dominantEmotion).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Detected emotion: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          Text(
            emotionData.dominantEmotion,
            style: TextStyle(
              color: _getEmotionColor(emotionData.dominantEmotion),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            ' (${(emotionData.confidence * 100).toInt()}%)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedImage(String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generated Artwork',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildGenerateImageButton() {
    return Card(
      child: InkWell(
        onTap: _isGeneratingImage ? null : _generateImage,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: _isGeneratingImage
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.image,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isGeneratingImage
                          ? 'Generating artwork...'
                          : 'Generate Artwork',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      _isGeneratingImage
                          ? 'This may take a minute'
                          : 'Create a visual representation of your echo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (!_isGeneratingImage)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Future<void> _toggleNarration() async {
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _ttsService.speakWithGenre(
        widget.echoResponse!.story,
        widget.echoResponse!.genre,
      );
    }
  }

  Future<void> _generateImage() async {
    setState(() => _isGeneratingImage = true);

    try {
      final imageService = ImageService.instance;
      await imageService.initialize();

      if (!imageService.hasApiKey) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add Replicate API key in settings'),
            ),
          );
        }
        return;
      }

      final storyService = ref.read(storyServiceProvider);
      final prompt = storyService.generateImagePrompt(widget.echoResponse!);

      final imagePath = await imageService.generateImage(prompt: prompt);

      if (imagePath != null && mounted) {
        setState(() => _generatedImagePath = imagePath);

        // Update the echo response with the image path
        final updatedEcho = widget.echoResponse!.copyWith(
          localImagePath: imagePath,
        );
        await ref
            .read(echoResponsesProvider.notifier)
            .addEchoResponse(updatedEcho);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate image')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingImage = false);
      }
    }
  }

  Future<void> _shareEcho() async {
    try {
      // Capture screenshot
      final image = await _screenshotController.capture();
      if (image == null) return;

      // Save to temp file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/echo_share.png');
      await file.writeAsBytes(image);

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My EchoMirror story: ${widget.echoResponse!.genre}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  IconData _getGenreIcon(String genre) {
    return switch (genre.toLowerCase()) {
      'cyberpunk' => Icons.memory,
      'fantasy' => Icons.auto_awesome,
      'horror' => Icons.visibility,
      'solarpunk' => Icons.eco,
      _ => Icons.auto_awesome,
    };
  }

  Color _getEmotionColor(String emotion) {
    return switch (emotion.toLowerCase()) {
      'happy' => AppColors.happy,
      'sad' => AppColors.sad,
      'angry' => AppColors.angry,
      'anxious' || 'fearful' => AppColors.anxious,
      'calm' => AppColors.calm,
      _ => AppColors.neutral,
    };
  }
}
