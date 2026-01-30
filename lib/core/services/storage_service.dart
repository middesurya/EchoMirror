import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/models/reflection.dart';
import '../../shared/models/echo_response.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String _reflectionsBox = 'reflections';
  static const String _echoResponsesBox = 'echo_responses';
  static const String _settingsBox = 'settings';

  late Box<Reflection> _reflections;
  late Box<EchoResponse> _echoResponses;
  late Box<dynamic> _settings;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Register adapters
    Hive.registerAdapter(ReflectionAdapter());
    Hive.registerAdapter(EmotionDataAdapter());
    Hive.registerAdapter(SentimentDataAdapter());
    Hive.registerAdapter(EchoResponseAdapter());
    Hive.registerAdapter(NarrativeElementsAdapter());

    // Open boxes
    _reflections = await Hive.openBox<Reflection>(_reflectionsBox);
    _echoResponses = await Hive.openBox<EchoResponse>(_echoResponsesBox);
    _settings = await Hive.openBox<dynamic>(_settingsBox);

    _initialized = true;
  }

  // Reflections CRUD
  Future<void> saveReflection(Reflection reflection) async {
    await _reflections.put(reflection.id, reflection);
  }

  Reflection? getReflection(String id) {
    return _reflections.get(id);
  }

  List<Reflection> getAllReflections() {
    return _reflections.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Reflection> getReflectionsByDateRange(DateTime start, DateTime end) {
    return _reflections.values
        .where((r) => r.createdAt.isAfter(start) && r.createdAt.isBefore(end))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteReflection(String id) async {
    await _reflections.delete(id);
  }

  // Echo Responses CRUD
  Future<void> saveEchoResponse(EchoResponse response) async {
    await _echoResponses.put(response.id, response);
  }

  EchoResponse? getEchoResponse(String id) {
    return _echoResponses.get(id);
  }

  List<EchoResponse> getAllEchoResponses() {
    return _echoResponses.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  EchoResponse? getEchoResponseForReflection(String reflectionId) {
    try {
      return _echoResponses.values.firstWhere(
        (r) => r.reflectionId == reflectionId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteEchoResponse(String id) async {
    await _echoResponses.delete(id);
  }

  // Settings
  Future<void> saveSetting(String key, dynamic value) async {
    await _settings.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settings.get(key, defaultValue: defaultValue) as T?;
  }

  // Secure Storage for sensitive data
  Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Export all data (GDPR compliance)
  Future<Map<String, dynamic>> exportAllData() async {
    final reflections = getAllReflections().map((r) => r.toJson()).toList();
    final echoResponses =
        getAllEchoResponses().map((e) => e.toJson()).toList();

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'reflections': reflections,
      'echoResponses': echoResponses,
    };
  }

  // Delete all data (GDPR compliance)
  Future<void> deleteAllData() async {
    await _reflections.clear();
    await _echoResponses.clear();
    await _settings.clear();
    await _secureStorage.deleteAll();
  }

  // Statistics
  Map<String, int> getEmotionStatistics() {
    final stats = <String, int>{};
    for (final reflection in _reflections.values) {
      if (reflection.emotionData != null) {
        final emotion = reflection.emotionData!.dominantEmotion;
        stats[emotion] = (stats[emotion] ?? 0) + 1;
      }
    }
    return stats;
  }

  Map<String, int> getSentimentStatistics() {
    final stats = <String, int>{};
    for (final reflection in _reflections.values) {
      if (reflection.sentimentData != null) {
        final sentiment = reflection.sentimentData!.sentiment;
        stats[sentiment] = (stats[sentiment] ?? 0) + 1;
      }
    }
    return stats;
  }
}
