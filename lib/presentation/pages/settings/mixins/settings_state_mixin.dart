import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/entities/user_entity.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/settings_providers.dart';

/// 설정 화면 상태 관리 Mixin
mixin SettingsStateMixin {
  /// 현재 사용자 정보 가져오기
  UserEntity? getCurrentUser(WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) => user,
      loading: () => null,
      error: (error, stackTrace) => null,
    );
  }

  /// 사용자가 관리자인지 확인
  bool isUserAdmin(WidgetRef ref) {
    return ref.watch(isAdminProvider);
  }

  /// 알림 설정 상태 가져오기
  bool getNotificationSetting(WidgetRef ref, String settingKey) {
    switch (settingKey) {
      case 'push_notifications':
        return ref.watch(pushNotificationEnabledProvider);
      case 'event_notifications':
        return ref.watch(eventNotificationEnabledProvider);
      case 'settlement_notifications':
        return ref.watch(settlementNotificationEnabledProvider);
      default:
        return false;
    }
  }

  /// 사용자 프로필 정보 가져오기
  Map<String, String?> getUserProfile(WidgetRef ref) {
    final user = getCurrentUser(ref);
    return {
      'displayName': user?.displayName ?? '사용자',
      'email': user?.email ?? 'user@example.com',
      'photoURL': user?.photoURL,
    };
  }

  /// 로딩 상태 확인
  bool isLoading(WidgetRef ref) {
    return ref.watch(isAuthLoadingProvider);
  }

  /// 에러 메시지 가져오기
  String? getErrorMessage(WidgetRef ref) {
    return ref.watch(authErrorProvider);
  }

  /// 인증 상태 확인
  bool isAuthenticated(WidgetRef ref) {
    return ref.watch(isAuthenticatedProvider);
  }
}