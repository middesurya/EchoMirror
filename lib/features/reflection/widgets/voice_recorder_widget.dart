import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_colors.dart';

class VoiceRecorderWidget extends ConsumerStatefulWidget {
  final Function(String text) onTranscription;
  final Function(String? path) onRecordingPath;

  const VoiceRecorderWidget({
    super.key,
    required this.onTranscription,
    required this.onRecordingPath,
  });

  @override
  ConsumerState<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends ConsumerState<VoiceRecorderWidget> {
  final SpeechService _speechService = SpeechService.instance;

  bool _isListening = false;
  bool _isInitialized = false;
  String _partialText = '';
  String _fullText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechService.onResult = (text) {
        setState(() {
          _fullText = text;
          _partialText = '';
        });
        widget.onTranscription(text);
      };

      _speechService.onPartialResult = (text) {
        setState(() {
          _partialText = text;
        });
      };

      _speechService.onError = (error) {
        setState(() {
          _errorMessage = error;
          _isListening = false;
        });
      };

      _speechService.onListeningStarted = () {
        setState(() => _isListening = true);
      };

      _speechService.onListeningStopped = () {
        setState(() => _isListening = false);
      };

      final success = await _speechService.initialize();
      setState(() {
        _isInitialized = success;
        if (!success) {
          _errorMessage = 'Speech recognition not available';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Microphone button
        GestureDetector(
          onTap: _isInitialized ? _toggleListening : null,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: _isListening
                  ? const LinearGradient(
                      colors: [AppColors.tertiary, AppColors.secondary],
                    )
                  : AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? AppColors.tertiary : AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: _isListening ? 24 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 48,
              color: Colors.white,
            ),
          )
              .animate(
                target: _isListening ? 1 : 0,
              )
              .scale(
                duration: 200.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.1, 1.1),
              ),
        ),

        const SizedBox(height: 16),

        // Status text
        Text(
          _getStatusText(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _isListening
                    ? AppColors.tertiary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),

        // Listening animation
        if (_isListening)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                      delay: (index * 100).ms,
                    )
                    .scaleY(
                      duration: 300.ms,
                      begin: 0.3,
                      end: 1.0,
                    ),
              ),
            ),
          ),

        // Partial transcription
        if (_partialText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _partialText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  String _getStatusText() {
    if (!_isInitialized) {
      return 'Initializing...';
    }
    if (_isListening) {
      return 'Listening... Tap to stop';
    }
    if (_fullText.isNotEmpty) {
      return 'Tap to continue recording';
    }
    return 'Tap to start speaking';
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
    } else {
      setState(() {
        _errorMessage = null;
      });

      // Also start audio recording for saving
      final recordingPath = await _speechService.startRecording();
      widget.onRecordingPath(recordingPath);

      await _speechService.startListening(
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
      );
    }
  }

  @override
  void dispose() {
    if (_isListening) {
      _speechService.stopListening();
      _speechService.stopRecording();
    }
    super.dispose();
  }
}
