import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/services/error_handler_service.dart';
import 'package:our_bung_play/core/services/network_service.dart';

/// Provider for the global error handler service
final errorHandlerProvider = Provider<ErrorHandlerService>((ref) {
  return ErrorHandlerService();
});

/// Provider for the network service
final networkProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

/// Provider for network status
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final networkService = ref.watch(networkProvider);
  return networkService.statusStream;
});

/// Provider to check if device is online
final isOnlineProvider = Provider<bool>((ref) {
  final networkStatus = ref.watch(networkStatusProvider);
  return networkStatus.when(
    data: (status) => status == NetworkStatus.online,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for handling global app errors
final globalErrorProvider = StateNotifierProvider<GlobalErrorNotifier, AppException?>((ref) {
  return GlobalErrorNotifier(ref.read(errorHandlerProvider));
});

/// Notifier for managing global application errors
class GlobalErrorNotifier extends StateNotifier<AppException?> {
  final ErrorHandlerService _errorHandler;

  GlobalErrorNotifier(this._errorHandler) : super(null);

  /// Handle a new error
  void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final appException =
        error is AppException ? error : _errorHandler.handleUnknownError(error, stackTrace, context: context);

    state = appException;
  }

  /// Clear the current error
  void clearError() {
    state = null;
  }

  /// Handle error with user feedback
  void handleErrorWithFeedback(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    bool showSnackBar = true,
  }) {
    final appException =
        error is AppException ? error : _errorHandler.handleUnknownError(error, stackTrace, context: context);

    // Record the error
    _errorHandler.recordError(
      appException,
      stackTrace ?? appException.stackTrace,
      context: context,
    );

    // Update state for UI to react
    state = appException;
  }
}

/// Extension for Ref to easily handle errors
extension ErrorHandlingRef on Ref {
  /// Handle error and update global error state
  void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    read(globalErrorProvider.notifier).handleError(
      error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Clear global error state
  void clearError() {
    read(globalErrorProvider.notifier).clearError();
  }
}

// /// Mixin for ConsumerWidget to easily handle errors
// mixin ErrorHandlingMixin<T extends ConsumerWidget> on ConsumerWidget {
//   void handleError(
//     WidgetRef ref,
//     dynamic error, {
//     StackTrace? stackTrace,
//     String? context,
//   }) {
//     ref.handleError(error, stackTrace: stackTrace, context: context);
//   }

//   void clearError(WidgetRef ref) {
//     ref.clearError();
//   }
// }

// /// Mixin for ConsumerStatefulWidget to easily handle errors
// mixin ErrorHandlingStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
//   void handleError(
//     dynamic error, {
//     StackTrace? stackTrace,
//     String? context,
//   }) {
//     ref.handleError(error, stackTrace: stackTrace, context: context);
//   }

//   void clearError() {
//     ref.clearError();
//   }
// }
