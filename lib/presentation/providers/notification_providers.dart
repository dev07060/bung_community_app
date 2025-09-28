import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/data/repositories/notification_repository_impl.dart';
import 'package:our_bung_play/data/services/notification_handler_service.dart';
import 'package:our_bung_play/data/services/notification_service.dart';
import 'package:our_bung_play/data/services/notification_service_impl.dart';
import 'package:our_bung_play/domain/entities/notification_entity.dart';
import 'package:our_bung_play/domain/repositories/notification_repository.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

/// Notification Service Provider
@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationServiceImpl();
}

/// Notification Repository Provider
@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationRepositoryImpl(notificationService: notificationService);
}

/// FCM Token Provider
@riverpod
class FCMToken extends _$FCMToken {
  @override
  Future<String?> build() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      return await notificationService.getFCMToken();
    } catch (e) {
      Logger.error('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Refresh FCM token
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final notificationService = ref.read(notificationServiceProvider);
      return await notificationService.getFCMToken();
    });
  }
}

/// Notification Permissions Provider
@riverpod
class NotificationPermissions extends _$NotificationPermissions {
  @override
  Future<bool> build() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      return await notificationService.areNotificationsEnabled();
    } catch (e) {
      Logger.error('Failed to check notification permissions: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> request() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final granted = await notificationService.requestPermissions();

      // Update state
      state = AsyncValue.data(granted);

      return granted;
    } catch (e) {
      Logger.error('Failed to request notification permissions: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

/// User Notifications Provider
@riverpod
class UserNotifications extends _$UserNotifications {
  @override
  Future<List<NotificationEntity>> build() async {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) async {
        if (user == null) return [];

        try {
          final repository = ref.read(notificationRepositoryProvider);
          return await repository.getUserNotifications(user.id);
        } catch (e) {
          Logger.error('Failed to get user notifications: $e');
          return [];
        }
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Refresh notifications
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markNotificationAsRead(notificationId);

      // Refresh notifications
      await refresh();
    } catch (e) {
      Logger.error('Failed to mark notification as read: $e');
      rethrow;
    }
  }
}

/// Unread Notifications Count Provider
@riverpod
int unreadNotificationsCount(UnreadNotificationsCountRef ref) {
  final notifications = ref.watch(userNotificationsProvider);

  return notifications.when(
    data: (notifications) =>
        notifications.where((notification) => notification.status != NotificationStatus.read).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Notification Settings Provider
@riverpod
class NotificationSettings extends _$NotificationSettings {
  @override
  Future<Map<String, bool>> build() async {
    // Load notification settings from local storage or user preferences
    // For now, return default settings
    return {
      'eventCreated': true,
      'eventUpdated': true,
      'eventJoined': true,
      'eventCancelled': true,
      'settlementCreated': true,
      'paymentReceived': true,
      'announcement': true,
      'memberJoined': false,
      'memberLeft': false,
    };
  }

  /// Update notification setting
  Future<void> updateSetting(String key, bool value) async {
    try {
      final currentSettings = state.value ?? {};
      final updatedSettings = {...currentSettings, key: value};

      // Save to local storage or user preferences
      // For now, just update state
      state = AsyncValue.data(updatedSettings);

      Logger.info('Updated notification setting: $key = $value');
    } catch (e) {
      Logger.error('Failed to update notification setting: $e');
      rethrow;
    }
  }

  /// Check if specific notification type is enabled
  bool isEnabled(String notificationType) {
    final settings = state.value ?? {};
    return settings[notificationType] ?? true;
  }
}

/// Notification Initialization Provider
@riverpod
class NotificationInitialization extends _$NotificationInitialization {
  @override
  Future<bool> build() async {
    try {
      // Initialize notification service
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();

      // Initialize notification handler
      await NotificationHandlerService.initialize();

      Logger.info('Notification system initialized successfully');
      return true;
    } catch (e) {
      Logger.error('Failed to initialize notification system: $e');
      return false;
    }
  }

  /// Reinitialize notification system
  Future<void> reinitialize() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
      await NotificationHandlerService.initialize();
      return true;
    });
  }
}
