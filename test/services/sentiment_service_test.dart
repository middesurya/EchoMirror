import 'package:flutter_test/flutter_test.dart';
import 'package:echo_mirror/core/services/sentiment_service.dart';

void main() {
  final sentimentService = SentimentService.instance;

  group('SentimentService', () {
    test('should return positive sentiment for happy text', () async {
      final result = await sentimentService.analyze(
        'I am so happy today! Everything is wonderful and amazing.',
      );

      expect(result.sentiment, equals('positive'));
      expect(result.score, greaterThan(0.2));
      expect(result.keywords, isNotEmpty);
    });

    test('should return negative sentiment for sad text', () async {
      final result = await sentimentService.analyze(
        'I feel so sad and depressed. Everything is terrible.',
      );

      expect(result.sentiment, equals('negative'));
      expect(result.score, lessThan(-0.2));
    });

    test('should return neutral sentiment for factual text', () async {
      final result = await sentimentService.analyze(
        'I went to the store and bought some groceries.',
      );

      expect(result.sentiment, equals('neutral'));
      expect(result.score, closeTo(0.0, 0.3));
    });

    test('should detect negation', () async {
      final result = await sentimentService.analyze(
        'I am not happy at all.',
      );

      // Should be negative due to negation
      expect(result.sentiment, equals('negative'));
    });

    test('should detect intensifiers', () async {
      final resultNormal = await sentimentService.analyze('I am happy.');
      final resultIntense = await sentimentService.analyze('I am very happy.');

      expect(resultIntense.score.abs(), greaterThan(resultNormal.score.abs() * 1.1));
    });

    test('should extract themes', () async {
      final result = await sentimentService.analyze(
        'I love my job at the office. The project is going great.',
      );

      expect(result.themes, contains('work'));
    });

    test('should handle empty text', () async {
      final result = await sentimentService.analyze('');

      expect(result.sentiment, equals('neutral'));
      expect(result.score, equals(0.0));
    });

    test('should extract keywords', () async {
      final result = await sentimentService.analyze(
        'I am extremely excited and delighted about this wonderful opportunity.',
      );

      expect(result.keywords, isNotEmpty);
      expect(
        result.keywords.any((k) => ['excited', 'delighted', 'wonderful'].contains(k)),
        isTrue,
      );
    });
  });
}
