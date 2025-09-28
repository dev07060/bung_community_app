// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'7cd30c9640ca952d1bcf1772c709fc45dc47c8b3';

/// 설정 관리를 위한 Provider들
/// SharedPreferences Provider
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$pushNotificationEnabledHash() =>
    r'e182961c1ac16753d107e6caf0d46102e0c11ecb';

/// 개별 알림 설정 Provider들
///
/// Copied from [pushNotificationEnabled].
@ProviderFor(pushNotificationEnabled)
final pushNotificationEnabledProvider = AutoDisposeProvider<bool>.internal(
  pushNotificationEnabled,
  name: r'pushNotificationEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pushNotificationEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PushNotificationEnabledRef = AutoDisposeProviderRef<bool>;
String _$eventNotificationEnabledHash() =>
    r'9ec5177144de86f3e634d90ae2094b939e1b826d';

/// See also [eventNotificationEnabled].
@ProviderFor(eventNotificationEnabled)
final eventNotificationEnabledProvider = AutoDisposeProvider<bool>.internal(
  eventNotificationEnabled,
  name: r'eventNotificationEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventNotificationEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EventNotificationEnabledRef = AutoDisposeProviderRef<bool>;
String _$settlementNotificationEnabledHash() =>
    r'49de5f516dac5081dd17ac2c43f6feaacf898914';

/// See also [settlementNotificationEnabled].
@ProviderFor(settlementNotificationEnabled)
final settlementNotificationEnabledProvider =
    AutoDisposeProvider<bool>.internal(
  settlementNotificationEnabled,
  name: r'settlementNotificationEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settlementNotificationEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettlementNotificationEnabledRef = AutoDisposeProviderRef<bool>;
String _$ruleRepositoryHash() => r'46393333b98c97dd2d3f361b32f2c8b9ec778236';

/// RuleRepository Provider
///
/// Copied from [ruleRepository].
@ProviderFor(ruleRepository)
final ruleRepositoryProvider = AutoDisposeProvider<RuleRepository>.internal(
  ruleRepository,
  name: r'ruleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ruleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RuleRepositoryRef = AutoDisposeProviderRef<RuleRepository>;
String _$notificationSettingsHash() =>
    r'da1c157aa4c3e68e72acb548e1b4b9a825898584';

/// 알림 설정 관리 Provider
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
String _$userProfileHash() => r'abc1dd26633f989228f36883410a20b6df5a1632';

/// 사용자 프로필 관리 Provider
///
/// Copied from [UserProfile].
@ProviderFor(UserProfile)
final userProfileProvider = AutoDisposeAsyncNotifierProvider<UserProfile,
    Map<String, String?>>.internal(
  UserProfile.new,
  name: r'userProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserProfile = AutoDisposeAsyncNotifier<Map<String, String?>>;
String _$currentRuleHash() => r'ada5dcd6578ad28c2fe860c964112b90b1d41a4c';

/// 현재 채널의 회칙 관리 Provider
///
/// Copied from [CurrentRule].
@ProviderFor(CurrentRule)
final currentRuleProvider =
    AutoDisposeAsyncNotifierProvider<CurrentRule, RuleEntity?>.internal(
  CurrentRule.new,
  name: r'currentRuleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentRuleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentRule = AutoDisposeAsyncNotifier<RuleEntity?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
