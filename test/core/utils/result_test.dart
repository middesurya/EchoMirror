import 'package:flutter_test/flutter_test.dart';
import 'package:echo_mirror/core/utils/result.dart';
import 'package:echo_mirror/core/errors/app_exception.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('isSuccess returns true', () {
        const result = Success(42);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('valueOrNull returns data', () {
        const result = Success('hello');
        expect(result.valueOrNull, 'hello');
      });

      test('errorOrNull returns null', () {
        const result = Success(42);
        expect(result.errorOrNull, isNull);
      });

      test('map transforms the value', () {
        const result = Success(10);
        final mapped = result.map((x) => x * 2);
        expect(mapped, isA<Success<int>>());
        expect((mapped as Success<int>).data, 20);
      });

      test('flatMap chains Results', () {
        const result = Success(10);
        final chained = result.flatMap((x) => Success(x.toString()));
        expect(chained, isA<Success<String>>());
        expect((chained as Success<String>).data, '10');
      });

      test('getOrElse returns the value', () {
        const result = Success(42);
        expect(result.getOrElse(0), 42);
      });

      test('fold calls onSuccess', () {
        const result = Success(42);
        final folded = result.fold(
          onSuccess: (x) => 'success: $x',
          onFailure: (e) => 'failure: ${e.message}',
        );
        expect(folded, 'success: 42');
      });

      test('onSuccess executes callback', () {
        var called = false;
        const result = Success(42);
        result.onSuccess((_) => called = true);
        expect(called, isTrue);
      });

      test('onFailure does not execute callback', () {
        var called = false;
        const result = Success(42);
        result.onFailure((_) => called = true);
        expect(called, isFalse);
      });
    });

    group('Failure', () {
      final error = AnalysisException.emptyInput();
      
      test('isFailure returns true', () {
        final result = Failure<int>(error);
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('valueOrNull returns null', () {
        final result = Failure<String>(error);
        expect(result.valueOrNull, isNull);
      });

      test('errorOrNull returns error', () {
        final result = Failure<int>(error);
        expect(result.errorOrNull, error);
      });

      test('map propagates failure', () {
        final result = Failure<int>(error);
        final mapped = result.map((x) => x * 2);
        expect(mapped, isA<Failure<int>>());
        expect((mapped as Failure<int>).error, error);
      });

      test('flatMap propagates failure', () {
        final result = Failure<int>(error);
        final chained = result.flatMap((x) => Success(x.toString()));
        expect(chained, isA<Failure<String>>());
      });

      test('getOrElse returns default', () {
        final result = Failure<int>(error);
        expect(result.getOrElse(99), 99);
      });

      test('getOrElseCompute computes from error', () {
        final result = Failure<String>(error);
        final value = result.getOrElseCompute((e) => 'error: ${e.code}');
        expect(value, 'error: ANALYSIS_EMPTY_INPUT');
      });

      test('fold calls onFailure', () {
        final result = Failure<int>(error);
        final folded = result.fold(
          onSuccess: (x) => 'success: $x',
          onFailure: (e) => 'failure: ${e.code}',
        );
        expect(folded, 'failure: ANALYSIS_EMPTY_INPUT');
      });

      test('onFailure executes callback', () {
        var called = false;
        final result = Failure<int>(error);
        result.onFailure((_) => called = true);
        expect(called, isTrue);
      });

      test('onSuccess does not execute callback', () {
        var called = false;
        final result = Failure<int>(error);
        result.onSuccess((_) => called = true);
        expect(called, isFalse);
      });
    });

    group('ResultUtils', () {
      test('combine succeeds when all results succeed', () {
        final results = [
          const Success(1),
          const Success(2),
          const Success(3),
        ];
        final combined = ResultUtils.combine(results);
        expect(combined, isA<Success<List<int>>>());
        expect((combined as Success<List<int>>).data, [1, 2, 3]);
      });

      test('combine fails on first failure', () {
        final error = AnalysisException.emptyInput();
        final results = [
          const Success(1),
          Failure<int>(error),
          const Success(3),
        ];
        final combined = ResultUtils.combine(results);
        expect(combined, isA<Failure<List<int>>>());
        expect((combined as Failure<List<int>>).error, error);
      });

      test('tryCatch catches exceptions', () {
        final result = ResultUtils.tryCatch<int>(() {
          throw Exception('test error');
        });
        expect(result, isA<Failure<int>>());
      });

      test('tryCatch returns success on no exception', () {
        final result = ResultUtils.tryCatch(() => 42);
        expect(result, isA<Success<int>>());
        expect((result as Success<int>).data, 42);
      });

      test('tryCatchAsync catches async exceptions', () async {
        final result = await ResultUtils.tryCatchAsync<int>(() async {
          throw Exception('async error');
        });
        expect(result, isA<Failure<int>>());
      });
    });

    group('Pattern Matching', () {
      test('switch expression works with Success', () {
        const Result<int> result = Success(42);
        final message = switch (result) {
          Success(data: final d) => 'Got $d',
          Failure(error: final e) => 'Error: ${e.message}',
        };
        expect(message, 'Got 42');
      });

      test('switch expression works with Failure', () {
        final Result<int> result = Failure(AnalysisException.emptyInput());
        final message = switch (result) {
          Success(data: final d) => 'Got $d',
          Failure(error: final e) => 'Error: ${e.code}',
        };
        expect(message, 'Error: ANALYSIS_EMPTY_INPUT');
      });
    });
  });

  group('AppException', () {
    test('AnalysisException.emptyInput has correct code', () {
      final exception = AnalysisException.emptyInput();
      expect(exception.code, 'ANALYSIS_EMPTY_INPUT');
      expect(exception.userMessage, isNotEmpty);
    });

    test('StorageException.saveFailed preserves original error', () {
      final original = Exception('disk full');
      final exception = StorageException.saveFailed(error: original);
      expect(exception.originalError, original);
      expect(exception.code, 'STORAGE_SAVE_FAILED');
    });

    test('All exception types have userMessage', () {
      final exceptions = [
        AnalysisException.emptyInput(),
        StorageException.notFound('key'),
        SpeechException.notAvailable(),
        CameraException.noFaceDetected(),
        ImageGenerationException.apiKeyMissing(),
        StoryGenerationException.invalidGenre('unknown'),
        const UnknownException('test'),
      ];

      for (final exception in exceptions) {
        expect(exception.userMessage, isNotEmpty);
      }
    });
  });
}
