// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'41499e3b9468dceb958ea341585f53aeb731d676';

/// AuthRepository Provider
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$currentUserHash() => r'5944af388d8e9fe899a9bb20af3eb8a601ba12f4';

/// 현재 사용자 Provider (동기)
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<UserEntity?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = AutoDisposeProviderRef<UserEntity?>;
String _$authStateStreamHash() => r'53f6a31ad7685281099bce8cece3b4ae4e803a31';

/// 인증 상태 스트림 Provider
///
/// Copied from [authStateStream].
@ProviderFor(authStateStream)
final authStateStreamProvider = AutoDisposeStreamProvider<UserEntity?>.internal(
  authStateStream,
  name: r'authStateStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateStreamRef = AutoDisposeStreamProviderRef<UserEntity?>;
String _$isAuthenticatedHash() => r'52e5d25c07fac25f27f8a8cdd5727594ab049e92';

/// 사용자 인증 여부 확인 Provider
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$isAdminHash() => r'0ae6678995aecdc78170741978b05f7a41305c86';

/// 사용자 역할 확인 Provider
///
/// Copied from [isAdmin].
@ProviderFor(isAdmin)
final isAdminProvider = AutoDisposeProvider<bool>.internal(
  isAdmin,
  name: r'isAdminProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAdminRef = AutoDisposeProviderRef<bool>;
String _$isAuthLoadingHash() => r'076419f1da1382bb1d7eb570fc3f4309d895e4b1';

/// 로딩 상태 확인 Provider
///
/// Copied from [isAuthLoading].
@ProviderFor(isAuthLoading)
final isAuthLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAuthLoading,
  name: r'isAuthLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAuthLoadingRef = AutoDisposeProviderRef<bool>;
String _$authErrorHash() => r'1fcc58e32224a5cceca96eff48bd0fa6820766b2';

/// 인증 에러 Provider
///
/// Copied from [authError].
@ProviderFor(authError)
final authErrorProvider = AutoDisposeProvider<String?>.internal(
  authError,
  name: r'authErrorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthErrorRef = AutoDisposeProviderRef<String?>;
String _$authenticatedUserHash() => r'0714b55ce1ea9c63da9c5a6309cebee721d08405';

/// 현재 인증된 사용자 Provider (비동기)
///
/// Copied from [AuthenticatedUser].
@ProviderFor(AuthenticatedUser)
final authenticatedUserProvider =
    AutoDisposeStreamNotifierProvider<AuthenticatedUser, UserEntity?>.internal(
  AuthenticatedUser.new,
  name: r'authenticatedUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authenticatedUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthenticatedUser = AutoDisposeStreamNotifier<UserEntity?>;
String _$authStateHash() => r'747fd8223e4acfe8b91d5477100e08513efafa21';

/// 로그인 상태 Provider
///
/// Copied from [AuthState].
@ProviderFor(AuthState)
final authStateProvider =
    AutoDisposeNotifierProvider<AuthState, AsyncValue<UserEntity?>>.internal(
  AuthState.new,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthState = AutoDisposeNotifier<AsyncValue<UserEntity?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
