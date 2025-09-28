import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/app_exceptions.dart';
import '../utils/logger.dart';

/// Network connectivity status
enum NetworkStatus {
  online,
  offline,
  unknown,
}

/// Configuration for retry logic
class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
  });
}

/// Service for managing network connectivity and retry logic
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final AppLogger _logger = AppLogger();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<NetworkStatus> _statusController = StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.unknown;

  /// Current network status
  NetworkStatus get currentStatus => _currentStatus;

  /// Stream of network status changes
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        _logger.error('Connectivity stream error: $error');
      },
    );
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _onConnectivityChanged(results);
    } catch (error) {
      _logger.error('Failed to check connectivity: $error');
      _updateStatus(NetworkStatus.unknown);
    }
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none)) {
      _updateStatus(NetworkStatus.offline);
    } else {
      // Verify actual internet connectivity
      final hasInternet = await _verifyInternetConnection();
      _updateStatus(hasInternet ? NetworkStatus.online : NetworkStatus.offline);
    }
  }

  /// Verify actual internet connection by pinging a reliable server
  Future<bool> _verifyInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (error) {
      _logger.warning('Internet verification failed: $error');
      return false;
    }
  }

  /// Update network status and notify listeners
  void _updateStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      _logger.info('Network status changed to: ${status.name}');
    }
  }

  /// Execute a network operation with retry logic
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    RetryConfig? retryConfig,
    bool requiresNetwork = true,
  }) async {
    final config = retryConfig ?? const RetryConfig();

    // Check network requirement
    if (requiresNetwork && _currentStatus == NetworkStatus.offline) {
      throw NetworkException.noConnection();
    }

    int attempt = 0;
    Duration delay = config.initialDelay;

    while (attempt <= config.maxRetries) {
      try {
        _logger.debug('Network operation attempt ${attempt + 1}');
        return await operation();
      } catch (error) {
        attempt++;

        // Don't retry if it's not a network-related error
        if (!_shouldRetry(error) || attempt > config.maxRetries) {
          _logger.error('Network operation failed after $attempt attempts: $error');
          rethrow;
        }

        // Wait before retry with exponential backoff
        _logger.warning('Network operation failed, retrying in ${delay.inSeconds}s: $error');
        await Future.delayed(delay);

        delay = Duration(
          milliseconds: (delay.inMilliseconds * config.backoffMultiplier).round(),
        );

        if (delay > config.maxDelay) {
          delay = config.maxDelay;
        }
      }
    }

    throw const NetworkException('Max retries exceeded');
  }

  /// Determine if an error should trigger a retry
  bool _shouldRetry(dynamic error) {
    if (error is NetworkException) {
      return error.code == 'TIMEOUT' || error.code == 'NO_CONNECTION' || error.code == 'SERVER_UNAVAILABLE';
    }

    if (error is SocketException) {
      return true;
    }

    if (error is TimeoutException) {
      return true;
    }

    if (error is HttpException) {
      // Retry on server errors (5xx) but not client errors (4xx)
      final statusCode = _extractStatusCode(error.message);
      return statusCode != null && statusCode >= 500;
    }

    return false;
  }

  /// Extract HTTP status code from error message
  int? _extractStatusCode(String message) {
    final regex = RegExp(r'(\d{3})');
    final match = regex.firstMatch(message);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// Check if device is currently online
  bool get isOnline => _currentStatus == NetworkStatus.online;

  /// Check if device is currently offline
  bool get isOffline => _currentStatus == NetworkStatus.offline;

  /// Wait for network to become available
  Future<void> waitForConnection({Duration? timeout}) async {
    if (isOnline) return;

    final completer = Completer<void>();
    late StreamSubscription<NetworkStatus> subscription;

    subscription = statusStream.listen((status) {
      if (status == NetworkStatus.online) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    if (timeout != null) {
      Timer(timeout, () {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            NetworkException.timeout(),
          );
        }
      });
    }

    return completer.future;
  }
}

/// Provider for NetworkService
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

/// Provider for current network status
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final networkService = ref.watch(networkServiceProvider);
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

/// Mixin for handling network operations in widgets
mixin NetworkAwareMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Execute network operation with automatic retry and error handling
  Future<R> executeNetworkOperation<R>(
    Future<R> Function() operation, {
    RetryConfig? retryConfig,
    String? operationName,
    bool showOfflineMessage = true,
  }) async {
    final networkService = ref.read(networkServiceProvider);

    try {
      return await networkService.executeWithRetry(
        operation,
        retryConfig: retryConfig,
      );
    } catch (error) {
      if (error is NetworkException && error.code == 'NO_CONNECTION' && showOfflineMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인터넷 연결을 확인해주세요.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      rethrow;
    }
  }

  /// Show offline indicator
  Widget buildOfflineIndicator() {
    return Consumer(
      builder: (context, ref, child) {
        final isOnline = ref.watch(isOnlineProvider);

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.orange,
          child: const Text(
            '오프라인 상태입니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
