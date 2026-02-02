/// Domain-specific exception hierarchy for EchoMirror
/// 
/// Provides typed exceptions for different failure scenarios,
/// enabling precise error handling and user-friendly messages.
library;

/// Base exception class for all app-specific errors
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// Creates an unknown/unexpected exception
  factory AppException.unknown(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) = UnknownException;

  /// User-friendly message for display
  String get userMessage => message;

  @override
  String toString() => '${runtimeType.toString()}($code): $message';
}

/// Exception for analysis-related failures (sentiment, emotion)
final class AnalysisException extends AppException {
  const AnalysisException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Unable to analyze your reflection. Please try again.';

  /// Empty input provided
  factory AnalysisException.emptyInput() => const AnalysisException(
    'Empty text provided for analysis',
    code: 'ANALYSIS_EMPTY_INPUT',
  );

  /// Model not loaded
  factory AnalysisException.modelNotLoaded() => const AnalysisException(
    'ML model not initialized',
    code: 'ANALYSIS_MODEL_NOT_LOADED',
  );

  /// Analysis timeout
  factory AnalysisException.timeout() => const AnalysisException(
    'Analysis took too long',
    code: 'ANALYSIS_TIMEOUT',
  );
}

/// Exception for storage-related failures (Hive, secure storage)
final class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Unable to save your data. Please try again.';

  /// Failed to initialize storage
  factory StorageException.initFailed({Object? error, StackTrace? stackTrace}) =>
      StorageException(
        'Failed to initialize storage',
        code: 'STORAGE_INIT_FAILED',
        originalError: error,
        stackTrace: stackTrace,
      );

  /// Failed to save data
  factory StorageException.saveFailed({Object? error, StackTrace? stackTrace}) =>
      StorageException(
        'Failed to save data',
        code: 'STORAGE_SAVE_FAILED',
        originalError: error,
        stackTrace: stackTrace,
      );

  /// Failed to load data
  factory StorageException.loadFailed({Object? error, StackTrace? stackTrace}) =>
      StorageException(
        'Failed to load data',
        code: 'STORAGE_LOAD_FAILED',
        originalError: error,
        stackTrace: stackTrace,
      );

  /// Data not found
  factory StorageException.notFound(String key) => StorageException(
    'Data not found: $key',
    code: 'STORAGE_NOT_FOUND',
  );
}

/// Exception for speech/voice-related failures
final class SpeechException extends AppException {
  const SpeechException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Voice recognition unavailable. Please type instead.';

  /// Speech recognition not available
  factory SpeechException.notAvailable() => const SpeechException(
    'Speech recognition not available on this device',
    code: 'SPEECH_NOT_AVAILABLE',
  );

  /// Microphone permission denied
  factory SpeechException.permissionDenied() => const SpeechException(
    'Microphone permission denied',
    code: 'SPEECH_PERMISSION_DENIED',
  );

  /// No speech detected
  factory SpeechException.noSpeechDetected() => const SpeechException(
    'No speech detected',
    code: 'SPEECH_NOT_DETECTED',
  );
}

/// Exception for camera/emotion detection failures
final class CameraException extends AppException {
  const CameraException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Camera unavailable. You can skip emotion capture.';

  /// Camera not available
  factory CameraException.notAvailable() => const CameraException(
    'Camera not available on this device',
    code: 'CAMERA_NOT_AVAILABLE',
  );

  /// Camera permission denied
  factory CameraException.permissionDenied() => const CameraException(
    'Camera permission denied',
    code: 'CAMERA_PERMISSION_DENIED',
  );

  /// No face detected
  factory CameraException.noFaceDetected() => const CameraException(
    'No face detected in image',
    code: 'CAMERA_NO_FACE',
  );
}

/// Exception for image generation failures (Replicate API)
final class ImageGenerationException extends AppException {
  const ImageGenerationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Couldn\'t generate artwork. Your story is ready without it.';

  /// API key not configured
  factory ImageGenerationException.apiKeyMissing() => const ImageGenerationException(
    'Replicate API key not configured',
    code: 'IMAGE_API_KEY_MISSING',
  );

  /// Network error
  factory ImageGenerationException.networkError({Object? error, StackTrace? stackTrace}) =>
      ImageGenerationException(
        'Network error during image generation',
        code: 'IMAGE_NETWORK_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );

  /// Generation failed
  factory ImageGenerationException.generationFailed(String reason) =>
      ImageGenerationException(
        'Image generation failed: $reason',
        code: 'IMAGE_GENERATION_FAILED',
      );
}

/// Exception for story generation failures
final class StoryGenerationException extends AppException {
  const StoryGenerationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Couldn\'t generate your echo story. Please try again.';

  /// Invalid genre
  factory StoryGenerationException.invalidGenre(String genre) =>
      StoryGenerationException(
        'Invalid genre: $genre',
        code: 'STORY_INVALID_GENRE',
      );

  /// Missing required data
  factory StoryGenerationException.missingData(String field) =>
      StoryGenerationException(
        'Missing required data: $field',
        code: 'STORY_MISSING_DATA',
      );
}

/// Unknown/unexpected exception
final class UnknownException extends AppException {
  const UnknownException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Something went wrong. Please try again.';
}
