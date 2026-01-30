import 'package:flutter_test/flutter_test.dart';
import 'package:echo_mirror/core/services/story_service.dart';
import 'package:echo_mirror/shared/models/reflection.dart';

void main() {
  final storyService = StoryService.instance;

  group('StoryService', () {
    test('should generate echo for cyberpunk genre', () async {
      final reflection = Reflection(
        id: 'test-1',
        text: 'Had a stressful day at work dealing with endless meetings.',
        createdAt: DateTime.now(),
        emotionData: EmotionData(
          dominantEmotion: 'anxious',
          confidence: 0.8,
          emotionScores: {'anxious': 0.8, 'neutral': 0.2},
        ),
      );

      final echo = await storyService.generateEcho(
        reflection: reflection,
        preferredGenre: 'cyberpunk',
      );

      expect(echo.genre, equals('cyberpunk'));
      expect(echo.story, isNotEmpty);
      expect(echo.story.toLowerCase(), contains('neo'));
      expect(echo.narrativeElements.archetype, isNotEmpty);
    });

    test('should generate echo for fantasy genre', () async {
      final reflection = Reflection(
        id: 'test-2',
        text: 'I felt so happy today after spending time with family.',
        createdAt: DateTime.now(),
        emotionData: EmotionData(
          dominantEmotion: 'happy',
          confidence: 0.9,
          emotionScores: {'happy': 0.9, 'neutral': 0.1},
        ),
      );

      final echo = await storyService.generateEcho(
        reflection: reflection,
        preferredGenre: 'fantasy',
      );

      expect(echo.genre, equals('fantasy'));
      expect(echo.story, isNotEmpty);
      expect(echo.narrativeElements.power, isNotEmpty);
    });

    test('should generate random genre when not specified', () async {
      final reflection = Reflection(
        id: 'test-3',
        text: 'Just a regular day.',
        createdAt: DateTime.now(),
      );

      final echo = await storyService.generateEcho(reflection: reflection);

      expect(StoryService.genres, contains(echo.genre));
    });

    test('should include narrative elements in echo', () async {
      final reflection = Reflection(
        id: 'test-4',
        text: 'Feeling sad about recent changes.',
        createdAt: DateTime.now(),
        emotionData: EmotionData(
          dominantEmotion: 'sad',
          confidence: 0.85,
          emotionScores: {'sad': 0.85, 'neutral': 0.15},
        ),
      );

      final echo = await storyService.generateEcho(
        reflection: reflection,
        preferredGenre: 'horror',
      );

      expect(echo.narrativeElements.archetype, isNotEmpty);
      expect(echo.narrativeElements.setting, isNotEmpty);
      expect(echo.narrativeElements.power, isNotEmpty);
      expect(echo.narrativeElements.conflict, isNotEmpty);
      expect(echo.narrativeElements.resolution, isNotEmpty);
    });

    test('should generate image prompt', () {
      final echo = storyService.generateEcho(
        reflection: Reflection(
          id: 'test-5',
          text: 'Test',
          createdAt: DateTime.now(),
          emotionData: EmotionData(
            dominantEmotion: 'happy',
            confidence: 0.9,
            emotionScores: {'happy': 0.9},
          ),
        ),
        preferredGenre: 'solarpunk',
      );

      // Wait for async
      echo.then((e) {
        final prompt = storyService.generateImagePrompt(e);
        expect(prompt, isNotEmpty);
        expect(prompt.toLowerCase(), contains('solarpunk'));
      });
    });
  });
}
