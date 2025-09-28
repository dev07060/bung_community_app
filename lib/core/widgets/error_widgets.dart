import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/services/error_handler_service.dart';
import 'package:our_bung_play/core/services/network_service.dart';

/// Widget to display error states with retry functionality
class ErrorStateWidget extends ConsumerWidget {
  final AppException exception;
  final VoidCallback? onRetry;
  final String? customMessage;
  final bool showDetails;

  const ErrorStateWidget({
    super.key,
    required this.exception,
    this.onRetry,
    this.customMessage,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(exception.type),
              size: 64,
              color: _getErrorColor(exception.type),
            ),
            const SizedBox(height: 16),
            Text(
              customMessage ?? exception.userMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (showDetails && exception.message != exception.userMessage) ...[
              const SizedBox(height: 8),
              Text(
                exception.message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.auth:
        return Icons.lock_outline;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.serverError:
        return Icons.cloud_off;
      case ErrorType.storage:
        return Icons.folder_off;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  Color _getErrorColor(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.auth:
        return Colors.red;
      case ErrorType.permission:
        return Colors.deepOrange;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.serverError:
        return Colors.red.shade700;
      case ErrorType.storage:
        return Colors.purple;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }
}

/// Widget to handle async value states with error handling
class AsyncValueWidget<T> extends ConsumerWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final Widget Function(AppException error, VoidCallback retry)? error;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return value.when(
      data: data,
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        final errorHandler = ref.read(errorHandlerServiceProvider);
        final appException = err is AppException ? err : errorHandler.handleUnknownError(err, stack);

        if (error != null && onRetry != null) {
          return error!(appException, onRetry!);
        }

        return ErrorStateWidget(
          exception: appException,
          onRetry: onRetry,
        );
      },
    );
  }
}

/// Mixin for handling loading states in widgets
mixin LoadingStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    if (mounted && _isLoading != loading) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  Future<R> executeWithLoading<R>(Future<R> Function() operation) async {
    setLoading(true);
    try {
      return await operation();
    } finally {
      setLoading(false);
    }
  }

  Widget buildLoadingOverlay({Widget? child}) {
    return Stack(
      children: [
        if (child != null) child,
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: .3),
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
      ],
    );
  }
}

/// Widget to show network status indicator
class NetworkStatusIndicator extends ConsumerWidget {
  const NetworkStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return networkStatus.when(
      data: (status) {
        if (status == NetworkStatus.offline) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  '오프라인 상태입니다',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Error boundary widget to catch and display errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(AppException error, VoidCallback retry)? errorBuilder;
  final void Function(AppException error)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppException? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _retry);
      }

      return ErrorStateWidget(
        exception: _error!,
        onRetry: _retry,
      );
    }

    return ErrorBoundaryWrapper(
      onError: _handleError,
      child: widget.child,
    );
  }

  void _handleError(AppException error) {
    setState(() {
      _error = error;
    });
    widget.onError?.call(error);
  }

  void _retry() {
    setState(() {
      _error = null;
    });
  }
}

/// Internal wrapper to catch errors
class ErrorBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final void Function(AppException error) onError;

  const ErrorBoundaryWrapper({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  State<ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<ErrorBoundaryWrapper> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set up error handling for this widget tree
    FlutterError.onError = (details) {
      if (mounted) {
        final error = details.exception;
        if (error is AppException) {
          widget.onError(error);
        } else {
          widget.onError(UnknownException.fromError(error, details.stack));
        }
      }
    };
  }
}

/// Snackbar helper for showing errors
class ErrorSnackBar {
  static void show(
    BuildContext context,
    AppException exception, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exception.userMessage),
        backgroundColor: _getErrorColor(exception.type),
        duration: duration,
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

  static Color _getErrorColor(ErrorType errorType) {
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
}
