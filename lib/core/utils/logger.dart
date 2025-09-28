import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Enhanced logger utility for the application with structured logging
class AppLogger {
  static const String _tag = 'OurBungPlay';

  /// Log levels

  /// Log debug message
  void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    _log(LogLevel.debug, message, error, stackTrace, additionalData);
  }

  /// Log info message
  void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    _log(LogLevel.info, message, error, stackTrace, additionalData);
  }

  /// Log warning message
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    _log(LogLevel.warning, message, error, stackTrace, additionalData);
  }

  /// Log error message
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    _log(LogLevel.error, message, error, stackTrace, additionalData);
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final logMessage = '[$_tag] [$timestamp] $levelStr: $message';

    // Use developer.log for better structured logging
    developer.log(
      message,
      time: DateTime.now(),
      level: _getLogLevelValue(level),
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );

    // Also print to debug console for development
    if (kDebugMode) {
      debugPrint(logMessage);

      if (error != null) {
        debugPrint('[$_tag] ERROR DETAILS: $error');
      }

      if (stackTrace != null) {
        debugPrint('[$_tag] STACK TRACE: $stackTrace');
      }

      if (additionalData != null && additionalData.isNotEmpty) {
        debugPrint('[$_tag] ADDITIONAL DATA: $additionalData');
      }
    }
  }

  /// Get numeric log level value for developer.log
  int _getLogLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  /// Log network request
  void logNetworkRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
  }) {
    if (kDebugMode) {
      info(
        'Network Request: $method $url',
        additionalData: {
          'method': method,
          'url': url,
          'headers': headers,
          'body': body,
        },
      );
    }
  }

  /// Log network response
  void logNetworkResponse(
    String method,
    String url,
    int statusCode, {
    Map<String, dynamic>? headers,
    dynamic body,
    Duration? duration,
  }) {
    if (kDebugMode) {
      final level = statusCode >= 400 ? LogLevel.error : LogLevel.info;
      _log(
        level,
        'Network Response: $method $url - $statusCode',
        null,
        null,
        {
          'method': method,
          'url': url,
          'statusCode': statusCode,
          'headers': headers,
          'body': body,
          'duration': duration?.inMilliseconds,
        },
      );
    }
  }

  /// Log user action
  void logUserAction(
    String action, {
    String? userId,
    Map<String, dynamic>? parameters,
  }) {
    info(
      'User Action: $action',
      additionalData: {
        'action': action,
        'userId': userId,
        'parameters': parameters,
      },
    );
  }

  /// Log performance metric
  void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? additionalData,
  }) {
    info(
      'Performance: $operation took ${duration.inMilliseconds}ms',
      additionalData: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        ...?additionalData,
      },
    );
  }
}

/// Legacy Logger class for backward compatibility
class Logger {
  static const String _tag = 'OurBungPlay';

  static void debug(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 500, // Debug level
    );
  }

  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
    );
  }

  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
}
