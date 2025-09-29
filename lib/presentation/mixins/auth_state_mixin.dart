import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers/async_provider_utils.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_providers.dart';

/// 인증 관련 상태를 참조하는 Mixin Class
mixin class AuthStateMixin {
  /// 안전하게 AsyncValue를 처리하는 헬퍼 메서드
  T? safeAsyncValue<T>(AsyncValue<T?> asyncValue, {T? fallback}) {
    return asyncValue.when(
      data: (data) => data,
      loading: () => fallback,
      error: (error, stack) {
        Logger.error('AsyncValue error in AuthStateMixin', error, stack);
        return fallback;
      },
    );
  }

  /// .future 패턴을 안전하게 사용하는 헬퍼 메서드
  Future<T?> safeReadFuture<T>(WidgetRef ref, AutoDisposeAsyncNotifierProvider<dynamic, T> provider) async {
    try {
      return await ref.read(provider.future);
    } catch (error, stack) {
      Logger.error('Error reading future provider', error, stack);
      return null;
    }
  }

  /// 현재 인증된 사용자 정보 가져오기
  UserEntity? getCurrentUser(WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.dataOrNull;
  }

  /// 사용자 인증 여부 확인
  bool isAuthenticated(WidgetRef ref) {
    return ref.watch(isAuthenticatedProvider);
  }

  /// 사용자가 관리자인지 확인
  bool isAdmin(WidgetRef ref) {
    return ref.watch(isAdminProvider);
  }

  /// 인증 로딩 상태 확인
  bool isAuthLoading(WidgetRef ref) {
    return ref.watch(isAuthLoadingProvider);
  }

  /// 인증 에러 메시지 가져오기
  String? getAuthError(WidgetRef ref) {
    return ref.watch(authErrorProvider);
  }

  /// 인증 상태 전체 가져오기 (AsyncValue)
  AsyncValue<UserEntity?> getAuthState(WidgetRef ref) {
    return ref.watch(authStateProvider);
  }

  /// 사용자 ID 가져오기
  String? getCurrentUserId(WidgetRef ref) {
    return getCurrentUser(ref)?.id;
  }

  /// 사용자 이메일 가져오기
  String? getCurrentUserEmail(WidgetRef ref) {
    return getCurrentUser(ref)?.email;
  }

  /// 사용자 표시 이름 가져오기
  String? getCurrentUserDisplayName(WidgetRef ref) {
    return getCurrentUser(ref)?.displayName;
  }

  /// 사용자 프로필 이미지 URL 가져오기
  String? getCurrentUserPhotoURL(WidgetRef ref) {
    return getCurrentUser(ref)?.photoURL;
  }

  /// 사용자 상태 확인 (활성, 제한, 차단)
  bool isUserActive(WidgetRef ref) {
    return getCurrentUser(ref)?.isActive ?? false;
  }

  bool isUserRestricted(WidgetRef ref) {
    return getCurrentUser(ref)?.isRestricted ?? false;
  }

  bool isUserBanned(WidgetRef ref) {
    return getCurrentUser(ref)?.isBanned ?? false;
  }

  /// 사용자 역할 표시명 가져오기
  String getUserRoleDisplayName(WidgetRef ref) {
    return getCurrentUser(ref)?.displayRole ?? '멤버';
  }

  /// 사용자 상태 표시명 가져오기
  String getUserStatusDisplayName(WidgetRef ref) {
    return getCurrentUser(ref)?.displayStatus ?? '활성';
  }

  /// 인증 상태에 따른 UI 상태 확인
  bool shouldShowLoginScreen(WidgetRef ref) {
    final authState = getAuthState(ref);
    return authState.when(
      data: (user) => user == null,
      loading: () => false, // 로딩 중에는 로그인 화면 표시하지 않음
      error: (error, stackTrace) => true, // 에러 시 로그인 화면 표시
    );
  }

  bool shouldShowMainScreen(WidgetRef ref) {
    final authState = getAuthState(ref);
    return authState.when(
      data: (user) => user != null && user.isActive,
      loading: () => false,
      error: (error, stackTrace) => false,
    );
  }

  bool shouldShowLoadingScreen(WidgetRef ref) {
    return isAuthLoading(ref);
  }

  bool shouldShowErrorScreen(WidgetRef ref) {
    final authState = getAuthState(ref);
    return authState.isError;
  }

  /// 사용자 권한 확인
  bool canAccessAdminFeatures(WidgetRef ref) {
    return isAuthenticated(ref) && isAdmin(ref) && isUserActive(ref);
  }

  bool canCreateEvents(WidgetRef ref) {
    return isAuthenticated(ref) && isUserActive(ref);
  }

  bool canJoinEvents(WidgetRef ref) {
    return isAuthenticated(ref) && isUserActive(ref);
  }

  bool canManageChannel(WidgetRef ref) {
    return canAccessAdminFeatures(ref);
  }

  /// 안전하게 사용자 정보 가져오기 (비동기) - AsyncNotifier 패턴 사용
  Future<UserEntity?> getCurrentUserAsync(WidgetRef ref) async {
    try {
      final asyncValue = ref.read(authStateProvider);
      return asyncValue.when(
        data: (user) => user,
        loading: () => null,
        error: (error, stack) {
          Logger.error('Error in auth state', error, stack);
          return null;
        },
      );
    } catch (error, stack) {
      Logger.error('Error reading auth state', error, stack);
      return null;
    }
  }

  /// 인증 상태를 안전하게 가져오기
  UserEntity? getCurrentUserSafe(WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return safeAsyncValue(authState);
  }
}
