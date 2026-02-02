import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Log severity levels
enum LogLevel {
  debug(0, '🔍', 'DEBUG'),
  info(1, 'ℹ️', 'INFO'),
  warning(2, '⚠️', 'WARN'),
  error(3, '❌', 'ERROR');

  final int priority;
  final String emoji;
  final String label;

  const LogLevel(this.priority, this.emoji, this.label);
}

/// A single log entry with metadata
class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;
  final String? tag;

  const LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
    this.error,
    this.stackTrace,
    this.context,
    this.tag,
  });

  Map<String, dynamic> toJson() => {
    'message': message,
    'level': level.label,
    'timestamp': timestamp.toIso8601String(),
    if (error != null) 'error': error.toString(),
    if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    if (context != null) 'context': context,
    if (tag != null) 'tag': tag,
  };

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('${level.emoji} ${level.label}');
    if (tag != null) buffer.write(' [$tag]');
    buffer.write(': $message');
    if (error != null) buffer.write('\n  Error: $error');
    if (context != null) buffer.write('\n  Context: ${jsonEncode(context)}');
    return buffer.toString();
  }
}

/// Centralized logging service with structured output
/// 
/// Features:
/// - Severity levels (debug, info, warning, error)
/// - Contextual metadata
/// - In-memory log buffer for debugging
/// - JSON export for crash reporting
/// - Production-safe (only errors in release mode)
class AppLogger {
  AppLogger._();
  
  /// Singleton instance
  static final AppLogger instance = AppLogger._();

  /// Maximum number of logs to keep in memory
  static const int _maxLogBuffer = 500;

  /// In-memory log buffer (circular)
  final Queue<LogEntry> _logs = Queue<LogEntry>();

  /// Minimum log level to record (debug in dev, info in release)
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Whether to print logs to console
  bool _consoleOutput = kDebugMode;

  /// Optional callback for external crash reporting (Firebase, Sentry, etc.)
  void Function(LogEntry)? _crashReporter;

  /// Configure the logger
  void configure({
    LogLevel? minLevel,
    bool? consoleOutput,
    void Function(LogEntry)? crashReporter,
  }) {
    if (minLevel != null) _minLevel = minLevel;
    if (consoleOutput != null) _consoleOutput = consoleOutput;
    if (crashReporter != null) _crashReporter = crashReporter;
  }

  /// Log a debug message (development only)
  void debug(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
  }) {
    _log(message, level: LogLevel.debug, tag: tag, context: context);
  }

  /// Log an info message
  void info(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
  }) {
    _log(message, level: LogLevel.info, tag: tag, context: context);
  }

  /// Log a warning message
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _log(
      message,
      level: LogLevel.warning,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Log an error message
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _log(
      message,
      level: LogLevel.error,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Internal logging method
  void _log(
    String message, {
    required LogLevel level,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    // Skip if below minimum level
    if (level.priority < _minLevel.priority) return;

    final entry = LogEntry(
      message: message,
      level: level,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      context: context,
      tag: tag,
    );

    // Add to buffer (circular)
    _logs.add(entry);
    while (_logs.length > _maxLogBuffer) {
      _logs.removeFirst();
    }

    // Console output
    if (_consoleOutput) {
      _printEntry(entry);
    }

    // Send errors to crash reporter
    if (level == LogLevel.error && _crashReporter != null) {
      _crashReporter!(entry);
    }
  }

  /// Print a log entry to console with colors (debug mode)
  void _printEntry(LogEntry entry) {
    final output = entry.toString();
    
    // Use debugPrint for better output handling
    debugPrint(output);
    
    // Print stack trace separately if present
    if (entry.stackTrace != null && entry.level == LogLevel.error) {
      debugPrint('Stack trace:\n${entry.stackTrace}');
    }
  }

  /// Get all logs as a list
  List<LogEntry> get logs => _logs.toList();

  /// Get logs filtered by level
  List<LogEntry> getLogsByLevel(LogLevel level) =>
      _logs.where((e) => e.level == level).toList();

  /// Get logs filtered by tag
  List<LogEntry> getLogsByTag(String tag) =>
      _logs.where((e) => e.tag == tag).toList();

  /// Export all logs as JSON string
  String exportLogsAsJson() {
    final logList = _logs.map((e) => e.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(logList);
  }

  /// Export logs as plain text
  String exportLogsAsText() =>
      _logs.map((e) => e.toString()).join('\n\n');

  /// Clear all logs
  void clear() => _logs.clear();

  /// Get count of logs by level
  Map<LogLevel, int> get logCounts {
    final counts = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      counts[level] = _logs.where((e) => e.level == level).length;
    }
    return counts;
  }
}

/// Convenience top-level functions for logging
void logDebug(String message, {String? tag, Map<String, dynamic>? context}) =>
    AppLogger.instance.debug(message, tag: tag, context: context);

void logInfo(String message, {String? tag, Map<String, dynamic>? context}) =>
    AppLogger.instance.info(message, tag: tag, context: context);

void logWarning(
  String message, {
  String? tag,
  Object? error,
  StackTrace? stackTrace,
  Map<String, dynamic>? context,
}) =>
    AppLogger.instance.warning(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );

void logError(
  String message, {
  String? tag,
  Object? error,
  StackTrace? stackTrace,
  Map<String, dynamic>? context,
}) =>
    AppLogger.instance.error(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
