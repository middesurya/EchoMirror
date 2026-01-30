import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

/// Text-to-Speech service for narrating echo stories
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  // Callbacks
  Function()? onStart;
  Function()? onComplete;
  Function(String)? onError;
  Function(int, int)? onProgress;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configure TTS engine
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5); // Slightly slower for dramatic effect
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Set up handlers
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      onStart?.call();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      onComplete?.call();
    });

    _flutterTts.setErrorHandler((message) {
      _isSpeaking = false;
      onError?.call(message.toString());
    });

    _flutterTts.setProgressHandler((text, start, end, word) {
      onProgress?.call(start, end);
    });

    _isInitialized = true;
  }

  /// Speak text aloud
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();

    if (_isSpeaking) {
      await stop();
    }

    await _flutterTts.speak(text);
  }

  /// Speak with genre-appropriate voice settings
  Future<void> speakWithGenre(String text, String genre) async {
    if (!_isInitialized) await initialize();

    // Adjust voice settings based on genre
    switch (genre.toLowerCase()) {
      case 'cyberpunk':
        await _flutterTts.setSpeechRate(0.55);
        await _flutterTts.setPitch(0.9);
        break;
      case 'fantasy':
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setPitch(1.1);
        break;
      case 'horror':
        await _flutterTts.setSpeechRate(0.4);
        await _flutterTts.setPitch(0.85);
        break;
      case 'solarpunk':
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.05);
        break;
      default:
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
    }

    await speak(text);
  }

  /// Pause speaking
  Future<void> pause() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  /// Save speech to audio file
  Future<String?> saveToFile(String text, {String? filename}) async {
    if (!_isInitialized) await initialize();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio');
      await audioDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${audioDir.path}/${filename ?? 'narration_$timestamp'}.wav';

      // Note: synthesizeToFile may not be available on all platforms
      // This is a best-effort feature
      final result = await _flutterTts.synthesizeToFile(text, filePath);
      
      if (result == 1) {
        return filePath;
      }
      return null;
    } catch (e) {
      print('Error saving TTS to file: $e');
      return null;
    }
  }

  /// Get available voices
  Future<List<Map<String, String>>> getAvailableVoices() async {
    if (!_isInitialized) await initialize();

    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        return voices.map((v) {
          if (v is Map) {
            return {
              'name': v['name']?.toString() ?? '',
              'locale': v['locale']?.toString() ?? '',
            };
          }
          return <String, String>{};
        }).toList();
      }
    } catch (e) {
      print('Error getting voices: $e');
    }
    return [];
  }

  /// Set specific voice
  Future<void> setVoice(String name, String locale) async {
    if (!_isInitialized) await initialize();
    await _flutterTts.setVoice({'name': name, 'locale': locale});
  }

  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) await initialize();

    try {
      final languages = await _flutterTts.getLanguages;
      if (languages is List) {
        return languages.map((l) => l.toString()).toList();
      }
    } catch (e) {
      print('Error getting languages: $e');
    }
    return ['en-US'];
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    if (!_isInitialized) await initialize();
    await _flutterTts.setLanguage(language);
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) await initialize();
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) await initialize();
    await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) await initialize();
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
  }

  void dispose() {
    _flutterTts.stop();
  }
}
