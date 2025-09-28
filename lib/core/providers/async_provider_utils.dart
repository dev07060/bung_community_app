import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Async Provider의 안전한 접근을 위한 유틸리티 클래스
class AsyncProviderUtils {
  /// Async Provider의 상태를 안전하게 가져오는 헬퍼 메서드
  /// .future 프로퍼티를 사용하여 항상 안전하게 접근
  static Future<T> safeRead<T>(
    WidgetRef ref,
    AsyncNotifierProvider<AsyncNotifier<T>, T> provider,
  ) async {
    return await ref.read(provider.future);
  }

  /// Family Provider의 경우
  static Future<T> safeReadFamily<T, Arg>(
    WidgetRef ref,
    AsyncNotifierProviderFamily<FamilyAsyncNotifier<T, Arg>, T, Arg> provider,
    Arg arg,
  ) async {
    return await ref.read(provider(arg).future);
  }
}

/// WidgetRef 확장으로 더 편리한 사용
extension AsyncProviderRefExtension on WidgetRef {
  /// AsyncNotifier Provider를 안전하게 읽기
  Future<T> readAsync<T>(
    AsyncNotifierProvider<AsyncNotifier<T>, T> provider,
  ) async {
    return await read(provider.future);
  }

  /// AsyncValue를 반환하는 Provider를 안전하게 읽기 (riverpod_annotation 생성 Provider용)
  Future<T> readAsyncValue<T>(
    ProviderBase<AsyncValue<T>> provider,
  ) async {
    final asyncValue = read(provider);
    return asyncValue.when(
      data: (data) => data,
      loading: () => throw StateError('Provider is still loading'),
      error: (error, stackTrace) => throw error,
    );
  }

  /// Family Async Provider를 안전하게 읽기
  Future<T> readAsyncFamily<T, Arg>(
    AsyncNotifierProviderFamily<FamilyAsyncNotifier<T, Arg>, T, Arg> provider,
    Arg arg,
  ) async {
    return await read(provider(arg).future);
  }

  /// AsyncValue Family Provider를 안전하게 읽기
  Future<T> readAsyncValueFamily<T, Arg>(
    ProviderBase<AsyncValue<T>> Function(Arg) providerFamily,
    Arg arg,
  ) async {
    final asyncValue = read(providerFamily(arg));
    return asyncValue.when(
      data: (data) => data,
      loading: () => throw StateError('Provider is still loading'),
      error: (error, stackTrace) => throw error,
    );
  }

  /// Async Provider의 현재 상태 확인 (로딩, 에러, 데이터)
  AsyncValue<T> watchAsyncState<T>(
    AsyncNotifierProvider<AsyncNotifier<T>, T> provider,
  ) {
    return watch(provider);
  }

  /// AsyncValue Provider의 현재 상태 확인
  AsyncValue<T> watchAsyncValueState<T>(
    ProviderBase<AsyncValue<T>> provider,
  ) {
    return watch(provider);
  }

  /// Family Async Provider의 현재 상태 확인
  AsyncValue<T> watchAsyncFamilyState<T, Arg>(
    AsyncNotifierProviderFamily<FamilyAsyncNotifier<T, Arg>, T, Arg> provider,
    Arg arg,
  ) {
    return watch(provider(arg));
  }
}

/// AsyncValue를 위한 편의 확장
extension AsyncValueExtension<T> on AsyncValue<T> {
  /// 로딩 중인지 확인
  bool get isLoading => this is AsyncLoading<T>;

  /// 에러 상태인지 확인
  bool get isError => this is AsyncError<T>;

  /// 데이터가 있는지 확인
  bool get hasData => this is AsyncData<T>;

  /// 안전하게 데이터 가져오기 (null 가능)
  T? get dataOrNull => hasData ? (this as AsyncData<T>).value : null;

  /// 에러 정보 가져오기 (null 가능)
  Object? get errorOrNull => isError ? (this as AsyncError<T>).error : null;

  /// 스택 트레이스 가져오기 (null 가능)
  StackTrace? get stackTraceOrNull =>
      isError ? (this as AsyncError<T>).stackTrace : null;
}
