// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationServiceHash() =>
    r'6fa45ebbf304753d6af6a493661896d718d4af05';

/// Notification Service Provider
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider =
    AutoDisposeProvider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationServiceRef = AutoDisposeProviderRef<NotificationService>;
String _$notificationRepositoryHash() =>
    r'7e18093169a7ce23060420f485c48e9d6a512530';

/// Notification Repository Provider
///
/// Copied from [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepository>.internal(
  notificationRepository,
  name: r'notificationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationRepositoryRef
    = AutoDisposeProviderRef<NotificationRepository>;
String _$unreadNotificationsCountHash() =>
    r'c390d197754556cf68acd3e9c5ee38ecd2dec444';

/// Unread Notifications Count Provider
///
/// Copied from [unreadNotificationsCount].
@ProviderFor(unreadNotificationsCount)
final unreadNotificationsCountProvider = AutoDisposeProvider<int>.internal(
  unreadNotificationsCount,
  name: r'unreadNotificationsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnreadNotificationsCountRef = AutoDisposeProviderRef<int>;
String _$fCMTokenHash() => r'40e0fafa21ab554fa100da6f0c403e71d1a2f264';

/// FCM Token Provider
///
/// Copied from [FCMToken].
@ProviderFor(FCMToken)
final fCMTokenProvider =
    AutoDisposeAsyncNotifierProvider<FCMToken, String?>.internal(
  FCMToken.new,
  name: r'fCMTokenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fCMTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FCMToken = AutoDisposeAsyncNotifier<String?>;
String _$notificationPermissionsHash() =>
    r'e79ce49d1eef385ef9c11f59eb92c1ac4b1c04ed';

/// Notification Permissions Provider
///
/// Copied from [NotificationPermissions].
@ProviderFor(NotificationPermissions)
final notificationPermissionsProvider =
    AutoDisposeAsyncNotifierProvider<NotificationPermissions, bool>.internal(
  NotificationPermissions.new,
  name: r'notificationPermissionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationPermissionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationPermissions = AutoDisposeAsyncNotifier<bool>;
String _$userNotificationsHash() => r'c1bb8146ef3c9c7691a7307d4e5b91b4eab4134d';

/// User Notifications Provider
///
/// Copied from [UserNotifications].
@ProviderFor(UserNotifications)
final userNotificationsProvider = AutoDisposeAsyncNotifierProvider<
    UserNotifications, List<NotificationEntity>>.internal(
  UserNotifications.new,
  name: r'userNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserNotifications
    = AutoDisposeAsyncNotifier<List<NotificationEntity>>;
String _$notificationSettingsHash() =>
    r'8b440c8b5a9ffd2d6c7e0005961aa2096396ff60';

/// Notification Settings Provider
///
/// Copied from [NotificationSettings].
@ProviderFor(NotificationSettings)
final notificationSettingsProvider = AutoDisposeAsyncNotifierProvider<
    NotificationSettings, Map<String, bool>>.internal(
  NotificationSettings.new,
  name: r'notificationSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationSettings = AutoDisposeAsyncNotifier<Map<String, bool>>;
String _$notificationInitializationHash() =>
    r'aa3fafcf4666e1037cb4afcbd2a26daf24f43b26';

/// Notification Initialization Provider
///
/// Copied from [NotificationInitialization].
@ProviderFor(NotificationInitialization)
final notificationInitializationProvider =
    AutoDisposeAsyncNotifierProvider<NotificationInitialization, bool>.internal(
  NotificationInitialization.new,
  name: r'notificationInitializationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationInitializationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationInitialization = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
