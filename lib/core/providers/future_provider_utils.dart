import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_bung_play/core/utils/logger.dart';

/// .future 패턴을 안전하게 사용하기 위한 유틸리티 클래스
class FutureProviderUtils {
  /// FutureProvider의 .future를 안전하게 읽기
  static Future<T?> safeReadFuture<T>(
    WidgetRef ref,
    FutureProvider<T> provider, {
    String? operationName,
  }) async {
    try {
      return await ref.read(provider.future);
    } catch (error, stack) {
      final name = operationName ?? provider.toString();
      Logger.error('Error reading future provider: $name', error, stack);
      return null;
    }
  }

  /// FutureProvider Family의 .future를 안전하게 읽기
  static Future<T?> safeReadFutureFamily<T, Arg>(
    WidgetRef ref,
    FutureProvider<T> Function(Arg) providerFamily,
    Arg arg, {
    String? operationName,
  }) async {
    try {
      return await ref.read(providerFamily(arg).future);
    } catch (error, stack) {
      final name = operationName ?? providerFamily.toString();
      Logger.error('Error reading future provider family: $name', error, stack);
      return null;
    }
  }

  /// AsyncValue를 .future로 변환하여 안전하게 읽기
  static Future<T?> safeAsyncValueToFuture<T>(
    AsyncValue<T> asyncValue, {
    String? operationName,
  }) async {
    return asyncValue.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(null),
      error: (error, stack) {
        final name = operationName ?? 'AsyncValue';
        Logger.error('Error in AsyncValue: $name', error, stack);
        return Future.value(null);
      },
    );
  }

  /// 여러 FutureProvider를 병렬로 안전하게 실행
  static Future<List<T?>> safeReadMultipleFutures<T>(
    WidgetRef ref,
    List<FutureProvider<T>> providers, {
    String? operationName,
  }) async {
    try {
      final futures = providers.map((provider) => ref.read(provider.future));
      final results = await Future.wait(futures, eagerError: false);
      return results;
    } catch (error, stack) {
      final name = operationName ?? 'Multiple futures';
      Logger.error('Error reading multiple future providers: $name', error, stack);
      return List.filled(providers.length, null);
    }
  }

  /// FutureProvider를 타임아웃과 함께 안전하게 읽기
  static Future<T?> safeReadFutureWithTimeout<T>(
    WidgetRef ref,
    FutureProvider<T> provider, {
    Duration timeout = const Duration(seconds: 30),
    String? operationName,
  }) async {
    try {
      return await ref.read(provider.future).timeout(timeout);
    } catch (error, stack) {
      final name = operationName ?? provider.toString();
      Logger.error('Error reading future provider with timeout: $name', error, stack);
      return null;
    }
  }

  /// FutureProvider를 재시도 로직과 함께 안전하게 읽기
  static Future<T?> safeReadFutureWithRetry<T>(
    WidgetRef ref,
    FutureProvider<T> provider, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String? operationName,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await ref.read(provider.future);
      } catch (error, stack) {
        attempts++;
        final name = operationName ?? provider.toString();

        if (attempts >= maxRetries) {
          Logger.error('Failed to read future provider after $maxRetries attempts: $name', error, stack);
          return null;
        }

        Logger.warning('Retry attempt $attempts for future provider: $name');
        await Future.delayed(retryDelay);

        // Provider를 무효화하여 재시도
        ref.invalidate(provider);
      }
    }

    return null;
  }

  /// FutureProvider의 상태를 확인하는 헬퍼
  static bool isFutureLoading<T>(WidgetRef ref, FutureProvider<T> provider) {
    return ref.watch(provider).isLoading;
  }

  static bool hasFutureError<T>(WidgetRef ref, FutureProvider<T> provider) {
    return ref.watch(provider).hasError;
  }

  static String? getFutureErrorMessage<T>(WidgetRef ref, FutureProvider<T> provider) {
    final asyncValue = ref.watch(provider);
    return asyncValue.hasError ? asyncValue.error.toString() : null;
  }

  static T? getFutureData<T>(WidgetRef ref, FutureProvider<T> provider) {
    return ref.watch(provider).valueOrNull;
  }

  /// AsyncNotifierProvider의 .future를 안전하게 읽기
  static Future<T?> safeReadAsyncNotifierFuture<T>(
    WidgetRef ref,
    AsyncNotifierProvider<AsyncNotifier<T>, T> provider, {
    String? operationName,
  }) async {
    try {
      return await ref.read(provider.future);
    } catch (error, stack) {
      final name = operationName ?? provider.toString();
      Logger.error('Error reading async notifier future: $name', error, stack);
      return null;
    }
  }

  /// AutoDisposeFutureProvider의 .future를 안전하게 읽기
  static Future<T?> safeReadAutoDisposeFuture<T>(
    WidgetRef ref,
    AutoDisposeFutureProvider<T> provider, {
    String? operationName,
  }) async {
    try {
      return await ref.read(provider.future);
    } catch (error, stack) {
      final name = operationName ?? provider.toString();
      Logger.error('Error reading auto dispose future provider: $name', error, stack);
      return null;
    }
  }
}

/// WidgetRef 확장 - .future 패턴을 더 쉽게 사용하기 위한 확장
extension FutureProviderExtension on WidgetRef {
  /// FutureProvider의 .future를 안전하게 읽기
  Future<T?> readFutureSafe<T>(
    FutureProvider<T> provider, {
    String? operationName,
  }) {
    return FutureProviderUtils.safeReadFuture(this, provider, operationName: operationName);
  }

  /// FutureProvider Family의 .future를 안전하게 읽기
  Future<T?> readFutureFamilySafe<T, Arg>(
    FutureProvider<T> Function(Arg) providerFamily,
    Arg arg, {
    String? operationName,
  }) {
    return FutureProviderUtils.safeReadFutureFamily(this, providerFamily, arg, operationName: operationName);
  }

  /// 여러 FutureProvider를 병렬로 안전하게 실행
  Future<List<T?>> readMultipleFuturesSafe<T>(
    List<FutureProvider<T>> providers, {
    String? operationName,
  }) {
    return FutureProviderUtils.safeReadMultipleFutures(this, providers, operationName: operationName);
  }

  /// FutureProvider를 타임아웃과 함께 안전하게 읽기
  Future<T?> readFutureWithTimeoutSafe<T>(
    FutureProvider<T> provider, {
    Duration timeout = const Duration(seconds: 30),
    String? operationName,
  }) {
    return FutureProviderUtils.safeReadFutureWithTimeout(this, provider,
        timeout: timeout, operationName: operationName);
  }

  /// FutureProvider를 재시도 로직과 함께 안전하게 읽기
  Future<T?> readFutureWithRetrySafe<T>(
    FutureProvider<T> provider, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String? operationName,
  }) {
    return FutureProviderUtils.safeReadFutureWithRetry(
      this,
      provider,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      operationName: operationName,
    );
  }

  /// AsyncNotifierProvider의 .future를 안전하게 읽기
  Future<T?> readAsyncNotifierFutureSafe<T>(
    AsyncNotifierProvider<AsyncNotifier<T>, T> provider, {
    String? operationName,
  }) {
    return FutureProviderUtils.safeReadAsyncNotifierFuture(this, provider, operationName: operationName);
  }

  /// AutoDisposeFutureProvider의 .future를 안전하게 읽기
  Future<T?> readAutoDisposeFutureSafe<T>(
    AutoDisposeFutureProvider<T> provider, {
    String? operationName,
  }) {
    return FutureProviderUtils.safeReadAutoDisposeFuture(this, provider, operationName: operationName);
  }
}
