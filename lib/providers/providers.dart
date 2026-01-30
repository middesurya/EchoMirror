import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/storage_service.dart';
import '../core/services/speech_service.dart';
import '../core/services/emotion_service.dart';
import '../core/services/sentiment_service.dart';
import '../core/services/story_service.dart';
import '../core/services/image_service.dart';
import '../core/services/tts_service.dart';
import '../shared/models/reflection.dart';
import '../shared/models/echo_response.dart';

// Service Providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService.instance;
});

final emotionServiceProvider = Provider<EmotionService>((ref) {
  return EmotionService.instance;
});

final sentimentServiceProvider = Provider<SentimentService>((ref) {
  return SentimentService.instance;
});

final storyServiceProvider = Provider<StoryService>((ref) {
  return StoryService.instance;
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService.instance;
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService.instance;
});

// State Providers
final reflectionsProvider = StateNotifierProvider<ReflectionsNotifier, List<Reflection>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ReflectionsNotifier(storage);
});

class ReflectionsNotifier extends StateNotifier<List<Reflection>> {
  final StorageService _storage;

  ReflectionsNotifier(this._storage) : super([]) {
    _loadReflections();
  }

  void _loadReflections() {
    state = _storage.getAllReflections();
  }

  Future<void> addReflection(Reflection reflection) async {
    await _storage.saveReflection(reflection);
    state = [reflection, ...state];
  }

  Future<void> updateReflection(Reflection reflection) async {
    await _storage.saveReflection(reflection);
    state = state.map((r) => r.id == reflection.id ? reflection : r).toList();
  }

  Future<void> deleteReflection(String id) async {
    await _storage.deleteReflection(id);
    state = state.where((r) => r.id != id).toList();
  }

  void refresh() {
    _loadReflections();
  }
}

final echoResponsesProvider = StateNotifierProvider<EchoResponsesNotifier, List<EchoResponse>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return EchoResponsesNotifier(storage);
});

class EchoResponsesNotifier extends StateNotifier<List<EchoResponse>> {
  final StorageService _storage;

  EchoResponsesNotifier(this._storage) : super([]) {
    _loadEchoResponses();
  }

  void _loadEchoResponses() {
    state = _storage.getAllEchoResponses();
  }

  Future<void> addEchoResponse(EchoResponse response) async {
    await _storage.saveEchoResponse(response);
    state = [response, ...state];
  }

  Future<void> deleteEchoResponse(String id) async {
    await _storage.deleteEchoResponse(id);
    state = state.where((e) => e.id != id).toList();
  }

  EchoResponse? getForReflection(String reflectionId) {
    try {
      return state.firstWhere((e) => e.reflectionId == reflectionId);
    } catch (_) {
      return null;
    }
  }

  void refresh() {
    _loadEchoResponses();
  }
}

// Current Reflection State
final currentReflectionProvider = StateProvider<Reflection?>((ref) => null);

// Speech Recognition State
final isListeningProvider = StateProvider<bool>((ref) => false);
final transcribedTextProvider = StateProvider<String>((ref) => '');
final isRecordingProvider = StateProvider<bool>((ref) => false);

// Processing State
final isProcessingProvider = StateProvider<bool>((ref) => false);
final processingStageProvider = StateProvider<String>((ref) => '');

// Selected Genre
final selectedGenreProvider = StateProvider<String?>((ref) => null);

// Settings Providers
final selectedLanguageProvider = StateProvider<String>((ref) => 'en-US');
final ttsEnabledProvider = StateProvider<bool>((ref) => true);
final autoGenerateImageProvider = StateProvider<bool>((ref) => false);
final darkModeProvider = StateProvider<bool>((ref) => false);

// Statistics Provider
final emotionStatsProvider = Provider<Map<String, int>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getEmotionStatistics();
});

final sentimentStatsProvider = Provider<Map<String, int>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getSentimentStatistics();
});

// TTS Playback State
final isSpeakingProvider = StateProvider<bool>((ref) => false);

// Combined Analysis Provider
final reflectionAnalysisProvider = FutureProvider.family<Map<String, dynamic>, Reflection>((ref, reflection) async {
  final emotionService = ref.read(emotionServiceProvider);
  final sentimentService = ref.read(sentimentServiceProvider);

  EmotionData? emotionData;
  if (reflection.imagePath != null) {
    emotionData = await emotionService.analyzeImage(reflection.imagePath!);
  }

  final sentimentData = await sentimentService.analyze(reflection.text);

  return sentimentService.combinedAnalysis(
    emotionData: emotionData,
    sentimentData: sentimentData,
  );
});

// Echo Generation Provider
final generateEchoProvider = FutureProvider.family<EchoResponse, Reflection>((ref, reflection) async {
  final storyService = ref.read(storyServiceProvider);
  final selectedGenre = ref.read(selectedGenreProvider);

  return await storyService.generateEcho(
    reflection: reflection,
    preferredGenre: selectedGenre,
  );
});
