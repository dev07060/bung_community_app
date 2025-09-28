import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/app_exceptions.dart';
import '../utils/logger.dart';

/// Service for handling errors globally across the application
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  late final FirebaseCrashlytics _crashlytics;
  late final AppLogger _logger;

  /// Initialize the error handler service
  Future<void> initialize() async {
    _crashlytics = FirebaseCrashlytics.instance;
    _logger = AppLogger();

    // Set up global error handling
    await _setupGlobalErrorHandling();
  }

  /// Set up global error handling for Flutter and Dart
  Future<void> _setupGlobalErrorHandling() async {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      recordError(
        details.exception,
        details.stack,
        fatal: false,
        context: 'Flutter Framework Error',
      );
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(
        error,
        stack,
        fatal: true,
        context: 'Platform Error',
      );
      return true;
    };

    // Handle async errors
    runZonedGuarded(() {
      // App initialization will happen here
    }, (error, stack) {
      recordError(
        error,
        stack,
        fatal: false,
        context: 'Async Error',
      );
    });
  }

  /// Record an error to Crashlytics and local logging
  void recordError(
    dynamic error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      // Log locally first
      _logger.error(
        'Error recorded: $error',
        error: error,
        stackTrace: stackTrace,
        additionalData: {
          'fatal': fatal,
          'context': context,
          ...?additionalData,
        },
      );

      // Record to Crashlytics if not in debug mode
      if (!kDebugMode) {
        _crashlytics.recordError(
          error,
          stackTrace,
          fatal: fatal,
          information: [
            if (context != null) 'Context: $context',
            if (additionalData != null) 'Additional Data: $additionalData',
          ],
        );
      }
    } catch (e) {
      // Fallback logging if Crashlytics fails
      debugPrint('Failed to record error: $e');
      debugPrint('Original error: $error');
    }
  }

  /// Handle AppException with appropriate user feedback
  void handleAppException(
    AppException exception,
    BuildContext? context, {
    VoidCallback? onRetry,
    bool showSnackBar = true,
  }) {
    // Record the error
    recordError(
      exception,
      exception.stackTrace,
      context: 'App Exception: ${exception.code}',
      additionalData: {
        'error_type': exception.type.name,
        'error_code': exception.code,
      },
    );

    // Show user-friendly message
    if (context != null && showSnackBar) {
      _showErrorSnackBar(context, exception, onRetry: onRetry);
    }
  }

  /// Handle unknown errors and convert them to AppExceptions
  AppException handleUnknownError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) {
    AppException appException;

    if (error is AppException) {
      appException = error;
    } else if (error is SocketException) {
      appException = NetworkException.noConnection();
    } else if (error is TimeoutException) {
      appException = NetworkException.timeout();
    } else if (error is FormatException) {
      appException = ValidationException.invalidFormat('입력값');
    } else {
      appException = UnknownException.fromError(error, stackTrace);
    }

    // Record the error
    recordError(
      appException,
      stackTrace ?? appException.stackTrace,
      context: context ?? 'Unknown Error Handler',
      additionalData: {
        'original_error': error.toString(),
        'error_type': error.runtimeType.toString(),
      },
    );

    return appException;
  }

  /// Show error snack bar with retry option
  void _showErrorSnackBar(
    BuildContext context,
    AppException exception, {
    VoidCallback? onRetry,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Text(exception.userMessage),
        backgroundColor: _getErrorColor(exception.type),
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: '다시 시도',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Get appropriate color for error type
  Color _getErrorColor(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.auth:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.permission:
        return Colors.deepOrange;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.serverError:
        return Colors.red.shade700;
      case ErrorType.storage:
        return Colors.purple;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  /// Set custom keys for Crashlytics
  void setCustomKey(String key, dynamic value) {
    if (!kDebugMode) {
      _crashlytics.setCustomKey(key, value);
    }
  }

  /// Set user identifier for Crashlytics
  void setUserIdentifier(String userId) {
    if (!kDebugMode) {
      _crashlytics.setUserIdentifier(userId);
    }
  }

  /// Log custom message to Crashlytics
  void log(String message) {
    if (!kDebugMode) {
      _crashlytics.log(message);
    }
    _logger.info(message);
  }
}

/// Provider for ErrorHandlerService
final errorHandlerServiceProvider = Provider<ErrorHandlerService>((ref) {
  return ErrorHandlerService();
});

/// Extension to easily handle errors in Riverpod providers
extension ErrorHandlerExtension on Ref {
  void handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) {
    final errorHandler = read(errorHandlerServiceProvider);
    errorHandler.handleUnknownError(error, stackTrace, context: context);
  }
}

/// Mixin for widgets to easily handle errors
mixin ErrorHandlerMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    VoidCallback? onRetry,
    bool showSnackBar = true,
  }) {
    final errorHandler = ref.read(errorHandlerServiceProvider);

    if (error is AppException) {
      errorHandler.handleAppException(
        error,
        mounted ? this.context : null,
        onRetry: onRetry,
        showSnackBar: showSnackBar,
      );
    } else {
      final appException = errorHandler.handleUnknownError(
        error,
        stackTrace,
        context: context,
      );

      if (mounted && showSnackBar) {
        errorHandler.handleAppException(
          // Use this.context instead of context
          appException,
          this.context,
          onRetry: onRetry,
          showSnackBar: showSnackBar,
        );
      }
    }
  }

  void showErrorDialog(
    AppException exception, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(exception.userMessage),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              child: const Text('취소'),
            ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('다시 시도'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
