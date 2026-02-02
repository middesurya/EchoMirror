/// Functional error handling pattern inspired by Rust's Result type
/// 
/// Provides explicit success/failure states without exceptions,
/// enabling exhaustive pattern matching and cleaner error propagation.
library;

import '../errors/app_exception.dart';

/// Sealed class representing either a successful result or a failure
sealed class Result<T> {
  const Result();

  /// Returns true if this is a Success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure
  bool get isFailure => this is Failure<T>;

  /// Get the success value or null
  T? get valueOrNull => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>() => null,
  };

  /// Get the error or null
  AppException? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(error: final e) => e,
  };

  /// Transform the success value
  Result<R> map<R>(R Function(T) transform) => switch (this) {
    Success<T>(data: final d) => Success(transform(d)),
    Failure<T>(error: final e) => Failure(e),
  };

  /// Transform the success value with a function that returns a Result
  Result<R> flatMap<R>(Result<R> Function(T) transform) => switch (this) {
    Success<T>(data: final d) => transform(d),
    Failure<T>(error: final e) => Failure(e),
  };

  /// Get the value or a default
  T getOrElse(T defaultValue) => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>() => defaultValue,
  };

  /// Get the value or compute a default
  T getOrElseCompute(T Function(AppException) compute) => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>(error: final e) => compute(e),
  };

  /// Execute a callback on success
  Result<T> onSuccess(void Function(T) action) {
    if (this case Success<T>(data: final d)) {
      action(d);
    }
    return this;
  }

  /// Execute a callback on failure
  Result<T> onFailure(void Function(AppException) action) {
    if (this case Failure<T>(error: final e)) {
      action(e);
    }
    return this;
  }

  /// Fold the result into a single value
  R fold<R>({
    required R Function(T) onSuccess,
    required R Function(AppException) onFailure,
  }) => switch (this) {
    Success<T>(data: final d) => onSuccess(d),
    Failure<T>(error: final e) => onFailure(e),
  };
}

/// Represents a successful result containing data
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed result containing an error
final class Failure<T> extends Result<T> {
  final AppException error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> && runtimeType == other.runtimeType && error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Extension to convert Future<T> to Future<Result<T>>
extension FutureResultExtension<T> on Future<T> {
  /// Wraps a Future in a Result, catching any exceptions
  Future<Result<T>> toResult() async {
    try {
      return Success(await this);
    } catch (e, stackTrace) {
      return Failure(
        AppException.unknown(
          'Unexpected error: $e',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// Utility functions for Result
class ResultUtils {
  ResultUtils._();

  /// Combines multiple Results into a single Result containing a list
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final values = <T>[];
    for (final result in results) {
      switch (result) {
        case Success<T>(data: final d):
          values.add(d);
        case Failure<T>(error: final e):
          return Failure(e);
      }
    }
    return Success(values);
  }

  /// Runs a function and catches any exceptions as a Result
  static Result<T> tryCatch<T>(T Function() fn) {
    try {
      return Success(fn());
    } catch (e, stackTrace) {
      return Failure(
        AppException.unknown(
          'Operation failed: $e',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Runs an async function and catches any exceptions as a Result
  static Future<Result<T>> tryCatchAsync<T>(Future<T> Function() fn) async {
    try {
      return Success(await fn());
    } catch (e, stackTrace) {
      return Failure(
        AppException.unknown(
          'Async operation failed: $e',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
