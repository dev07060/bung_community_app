import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/data/repositories/rule_repository_impl.dart';
import 'package:our_bung_play/domain/entities/rule_entity.dart';
import 'package:our_bung_play/domain/repositories/rule_repository.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_providers.g.dart';

/// 설정 관리를 위한 Provider들

/// SharedPreferences Provider
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

/// 알림 설정 관리 Provider
@riverpod
class NotificationSettings extends _$NotificationSettings {
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _eventNotificationsKey = 'event_notifications';
  static const String _settlementNotificationsKey = 'settlement_notifications';

  @override
  Future<Map<String, bool>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    return {
      _pushNotificationsKey: prefs.getBool(_pushNotificationsKey) ?? true,
      _eventNotificationsKey: prefs.getBool(_eventNotificationsKey) ?? true,
      _settlementNotificationsKey: prefs.getBool(_settlementNotificationsKey) ?? true,
    };
  }

  /// 특정 알림 설정 가져오기
  bool getSetting(String key) {
    final settings = state.value ?? {};
    return settings[key] ?? true;
  }

  /// 알림 설정 업데이트
  Future<void> updateSetting(String key, bool value) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setBool(key, value);

      final currentSettings = state.value ?? {};
      state = AsyncValue.data({
        ...currentSettings,
        key: value,
      });

      Logger.info('Notification setting updated: $key = $value');
    } catch (error, stackTrace) {
      Logger.error('Failed to update notification setting', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 푸시 알림 설정
  Future<void> setPushNotifications(bool enabled) async {
    await updateSetting(_pushNotificationsKey, enabled);
  }

  /// 벙 알림 설정
  Future<void> setEventNotifications(bool enabled) async {
    await updateSetting(_eventNotificationsKey, enabled);
  }

  /// 정산 알림 설정
  Future<void> setSettlementNotifications(bool enabled) async {
    await updateSetting(_settlementNotificationsKey, enabled);
  }
}

/// 개별 알림 설정 Provider들
@riverpod
bool pushNotificationEnabled(PushNotificationEnabledRef ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.when(
    data: (data) => data['push_notifications'] ?? true,
    loading: () => true,
    error: (error, stackTrace) => true,
  );
}

@riverpod
bool eventNotificationEnabled(EventNotificationEnabledRef ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.when(
    data: (data) => data['event_notifications'] ?? true,
    loading: () => true,
    error: (error, stackTrace) => true,
  );
}

@riverpod
bool settlementNotificationEnabled(SettlementNotificationEnabledRef ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.when(
    data: (data) => data['settlement_notifications'] ?? true,
    loading: () => true,
    error: (error, stackTrace) => true,
  );
}

/// 사용자 프로필 관리 Provider
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<Map<String, String?>> build() async {
    // TODO: 실제 사용자 프로필 데이터 로드
    return {
      'displayName': '사용자',
      'email': 'user@example.com',
      'photoURL': null,
    };
  }

  /// 프로필 업데이트
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final currentProfile = state.value ?? {};
      final updatedProfile = {
        ...currentProfile,
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
      };

      state = AsyncValue.data(updatedProfile);

      // TODO: 실제 프로필 업데이트 로직 구현
      Logger.info('Profile updated: $updatedProfile');
    } catch (error, stackTrace) {
      Logger.error('Failed to update profile', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// RuleRepository Provider
@riverpod
RuleRepository ruleRepository(RuleRepositoryRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RuleRepositoryImpl(authRepository: authRepository);
}

/// 현재 채널의 회칙 관리 Provider
@riverpod
class CurrentRule extends _$CurrentRule {
  @override
  Future<RuleEntity?> build() async {
    try {
      final ruleRepository = ref.read(ruleRepositoryProvider);

      // TODO: 현재 채널 ID를 가져오는 로직 필요
      // 임시로 하드코딩된 채널 ID 사용
      const channelId = 'current_channel_id';

      final rule = await ruleRepository.getChannelRule(channelId);
      return rule;
    } catch (error, stackTrace) {
      Logger.error('Failed to load rule', error, stackTrace);
      rethrow;
    }
  }

  /// 새 회칙 생성
  Future<void> createRule(String title, String content) async {
    try {
      state = const AsyncValue.loading();

      final ruleRepository = ref.read(ruleRepositoryProvider);

      // TODO: 현재 채널 ID를 가져오는 로직 필요
      const channelId = 'current_channel_id';

      final newRule = RuleEntity(
        id: '', // Firestore에서 자동 생성
        channelId: channelId,
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdRule = await ruleRepository.createRule(newRule);
      state = AsyncValue.data(createdRule);

      Logger.info('Rule created successfully: ${createdRule.id}');
    } catch (error, stackTrace) {
      Logger.error('Failed to create rule', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// 회칙 수정
  Future<void> updateRule(String ruleId, String title, String content) async {
    try {
      state = const AsyncValue.loading();

      final ruleRepository = ref.read(ruleRepositoryProvider);
      final currentRule = state.value;

      if (currentRule == null) {
        throw Exception('수정할 회칙이 없습니다.');
      }

      final updatedRule = currentRule.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );

      await ruleRepository.updateRule(updatedRule);
      state = AsyncValue.data(updatedRule);

      Logger.info('Rule updated successfully: $ruleId');
    } catch (error, stackTrace) {
      Logger.error('Failed to update rule', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// 회칙 삭제
  Future<void> deleteRule(String ruleId) async {
    try {
      state = const AsyncValue.loading();

      final ruleRepository = ref.read(ruleRepositoryProvider);
      await ruleRepository.deleteRule(ruleId);

      state = const AsyncValue.data(null);

      Logger.info('Rule deleted successfully: $ruleId');
    } catch (error, stackTrace) {
      Logger.error('Failed to delete rule', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// 회칙 새로고침
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
