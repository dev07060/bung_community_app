import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/providers/global_providers.dart';
import 'package:our_bung_play/core/utils/logger.dart';

/// 페이지별 State Mixin Class의 기본 인터페이스
/// 각 페이지에서 사용되는 상태를 참조하는 로직을 캡슐화
mixin class PageStateMixin {
  /// 안전하게 AsyncValue를 처리하는 헬퍼 메서드
  T? safeAsyncValue<T>(AsyncValue<T> asyncValue, {T? fallback}) {
    return asyncValue.when(
      data: (data) => data,
      loading: () => fallback,
      error: (error, stack) {
        Logger.error('AsyncValue error in PageStateMixin', error, stack);
        return fallback;
      },
    );
  }

  /// AsyncValue의 로딩 상태 확인
  bool isAsyncLoading<T>(AsyncValue<T> asyncValue) {
    return asyncValue.isLoading;
  }

  /// AsyncValue의 에러 상태 확인
  bool hasAsyncError<T>(AsyncValue<T> asyncValue) {
    return asyncValue.hasError;
  }

  /// AsyncValue의 에러 메시지 가져오기
  String? getAsyncErrorMessage<T>(AsyncValue<T> asyncValue) {
    return asyncValue.hasError ? asyncValue.error.toString() : null;
  }

  /// 전역 컨테이너를 통한 Provider 접근 (WidgetRef 없는 곳에서 사용)
  T readGlobal<T>(ProviderListenable<T> provider) {
    return GlobalProviderAccess.read(provider);
  }

  /// .future 패턴을 안전하게 사용하는 헬퍼 메서드
  Future<T?> safeReadFuture<T>(WidgetRef ref, FutureProvider<T> provider) async {
    try {
      return await ref.read(provider.future);
    } catch (error, stack) {
      Logger.error('Error reading future provider', error, stack);
      return null;
    }
  }
}

/// 페이지별 Event Mixin Class의 기본 인터페이스
/// 각 페이지에서 발생하는 이벤트와 상태 변경 로직을 캡슐화
mixin class PageEventMixin {
  /// 안전한 비동기 작업 실행 헬퍼
  Future<T?> safeAsyncOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    void Function(dynamic error, StackTrace stack)? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stack) {
      final name = operationName ?? 'Unknown operation';
      Logger.error('Error in $name', error, stack);
      onError?.call(error, stack);
      return null;
    }
  }

  /// 스낵바 표시 헬퍼
  void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  /// 에러 스낵바 표시 헬퍼
  void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }

  /// 성공 스낵바 표시 헬퍼
  void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  /// 전역 컨테이너를 통한 Provider 접근 (WidgetRef 없는 곳에서 사용)
  T readGlobal<T>(ProviderListenable<T> provider) {
    return GlobalProviderAccess.read(provider);
  }

  /// 전역 컨테이너를 통한 Notifier 접근
  NotifierT readGlobalNotifier<NotifierT extends Notifier<T>, T>(
    NotifierProvider<NotifierT, T> provider,
  ) {
    return GlobalProviderAccess.readNotifier(provider);
  }

  /// .future 패턴을 안전하게 사용하는 헬퍼 메서드
  Future<T?> safeReadFuture<T>(WidgetRef ref, FutureProvider<T> provider) async {
    try {
      return await ref.read(provider.future);
    } catch (error, stack) {
      Logger.error('Error reading future provider', error, stack);
      return null;
    }
  }
}

/// 예시: 홈 페이지용 State Mixin
mixin class HomeStateMixin {
  // 홈 페이지에서 사용하는 상태들을 참조하는 메서드들

  /// 사용자의 참여 벙 목록 가져오기
  List<dynamic> getMyEvents(WidgetRef ref) {
    // TODO: 실제 Provider에서 데이터 가져오기
    return [];
  }

  /// 사용자가 개설한 벙 목록 가져오기
  List<dynamic> getMyCreatedEvents(WidgetRef ref) {
    // TODO: 실제 Provider에서 데이터 가져오기
    return [];
  }

  /// 현재 사용자 정보 가져오기
  dynamic getCurrentUser(WidgetRef ref) {
    // TODO: 실제 Provider에서 데이터 가져오기
    return null;
  }
}

/// 예시: 홈 페이지용 Event Mixin
mixin class HomeEventMixin {
  // 홈 페이지에서 발생하는 이벤트들을 처리하는 메서드들

  /// 새 벙 생성 버튼 클릭
  void onCreateEventTapped(WidgetRef ref) {
    // TODO: 벙 생성 화면으로 네비게이션
  }

  /// 벙 아이템 클릭
  void onEventTapped(WidgetRef ref, String eventId) {
    // TODO: 벙 상세 화면으로 네비게이션
  }

  /// 새로고침
  Future<void> onRefresh(WidgetRef ref) async {
    // TODO: 데이터 새로고침 로직
  }

  /// 복합 이벤트 예시: 여러 Provider에 접근하는 복잡한 로직
  Future<void> onComplexAction(WidgetRef ref) async {
    // 여러 Provider의 상태를 변경하거나 복잡한 비즈니스 로직 수행
    // 예: 사용자 상태 업데이트 + 이벤트 목록 새로고침 + 알림 전송
  }
}
