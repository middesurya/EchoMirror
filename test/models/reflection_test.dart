import 'package:flutter_test/flutter_test.dart';
import 'package:echo_mirror/shared/models/reflection.dart';

void main() {
  group('Reflection', () {
    test('should create reflection with required fields', () {
      final reflection = Reflection(
        id: 'test-id',
        text: 'Test reflection text',
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      expect(reflection.id, equals('test-id'));
      expect(reflection.text, equals('Test reflection text'));
      expect(reflection.createdAt, equals(DateTime(2024, 1, 15, 10, 30)));
    });

    test('should create reflection with all fields', () {
      final emotionData = EmotionData(
        dominantEmotion: 'happy',
        confidence: 0.85,
        emotionScores: {'happy': 0.85, 'neutral': 0.15},
      );

      final sentimentData = SentimentData(
        sentiment: 'positive',
        score: 0.7,
        keywords: ['great', 'wonderful'],
        themes: ['work', 'growth'],
      );

      final reflection = Reflection(
        id: 'test-id',
        text: 'Test reflection text',
        createdAt: DateTime.now(),
        voiceRecordingPath: '/path/to/recording.m4a',
        imagePath: '/path/to/image.jpg',
        emotionData: emotionData,
        sentimentData: sentimentData,
        echoResponseId: 'echo-123',
      );

      expect(reflection.voiceRecordingPath, equals('/path/to/recording.m4a'));
      expect(reflection.imagePath, equals('/path/to/image.jpg'));
      expect(reflection.emotionData?.dominantEmotion, equals('happy'));
      expect(reflection.sentimentData?.sentiment, equals('positive'));
      expect(reflection.echoResponseId, equals('echo-123'));
    });

    test('should serialize to JSON correctly', () {
      final reflection = Reflection(
        id: 'test-id',
        text: 'Test text',
        createdAt: DateTime(2024, 1, 15),
        emotionData: EmotionData(
          dominantEmotion: 'happy',
          confidence: 0.9,
          emotionScores: {'happy': 0.9},
        ),
      );

      final json = reflection.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['text'], equals('Test text'));
      expect(json['emotionData']['dominantEmotion'], equals('happy'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'text': 'Test text',
        'createdAt': '2024-01-15T00:00:00.000',
        'voiceRecordingPath': null,
        'imagePath': null,
        'emotionData': {
          'dominantEmotion': 'sad',
          'confidence': 0.75,
          'emotionScores': {'sad': 0.75, 'neutral': 0.25},
        },
        'sentimentData': null,
        'echoResponseId': null,
      };

      final reflection = Reflection.fromJson(json);

      expect(reflection.id, equals('test-id'));
      expect(reflection.emotionData?.dominantEmotion, equals('sad'));
      expect(reflection.emotionData?.confidence, equals(0.75));
    });

    test('should copyWith create new instance with updated fields', () {
      final original = Reflection(
        id: 'test-id',
        text: 'Original text',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        text: 'Updated text',
        echoResponseId: 'echo-456',
      );

      expect(updated.id, equals(original.id));
      expect(updated.text, equals('Updated text'));
      expect(updated.echoResponseId, equals('echo-456'));
      expect(original.text, equals('Original text')); // Original unchanged
    });
  });

  group('EmotionData', () {
    test('should serialize and deserialize correctly', () {
      final emotionData = EmotionData(
        dominantEmotion: 'angry',
        confidence: 0.6,
        emotionScores: {'angry': 0.6, 'sad': 0.3, 'neutral': 0.1},
      );

      final json = emotionData.toJson();
      final restored = EmotionData.fromJson(json);

      expect(restored.dominantEmotion, equals('angry'));
      expect(restored.confidence, equals(0.6));
      expect(restored.emotionScores.length, equals(3));
    });
  });

  group('SentimentData', () {
    test('should serialize and deserialize correctly', () {
      final sentimentData = SentimentData(
        sentiment: 'negative',
        score: -0.5,
        keywords: ['terrible', 'awful'],
        themes: ['health'],
      );

      final json = sentimentData.toJson();
      final restored = SentimentData.fromJson(json);

      expect(restored.sentiment, equals('negative'));
      expect(restored.score, equals(-0.5));
      expect(restored.keywords, contains('terrible'));
      expect(restored.themes, contains('health'));
    });
  });
}
