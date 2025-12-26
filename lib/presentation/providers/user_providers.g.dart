// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imagePickerHash() => r'4ade97b98e4e2b1423bb08eb64f280b92f8ac945';

/// ImagePicker Provider
///
/// Copied from [imagePicker].
@ProviderFor(imagePicker)
final imagePickerProvider = AutoDisposeProvider<ImagePicker>.internal(
  imagePicker,
  name: r'imagePickerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$imagePickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ImagePickerRef = AutoDisposeProviderRef<ImagePicker>;
String _$firebaseStorageHash() => r'9ece783a064077980d64000c5d6f0b1846ff5c4c';

/// FirebaseStorage Provider
///
/// Copied from [firebaseStorage].
@ProviderFor(firebaseStorage)
final firebaseStorageProvider = AutoDisposeProvider<FirebaseStorage>.internal(
  firebaseStorage,
  name: r'firebaseStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirebaseStorageRef = AutoDisposeProviderRef<FirebaseStorage>;
String _$userHash() => r'3378ebbad45d900719cfe3c20616c6e9a258d684';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 사용자 정보 조회 Provider (ID로 조회)
///
/// Copied from [user].
@ProviderFor(user)
const userProvider = UserFamily();

/// 사용자 정보 조회 Provider (ID로 조회)
///
/// Copied from [user].
class UserFamily extends Family<AsyncValue<UserEntity?>> {
  /// 사용자 정보 조회 Provider (ID로 조회)
  ///
  /// Copied from [user].
  const UserFamily();

  /// 사용자 정보 조회 Provider (ID로 조회)
  ///
  /// Copied from [user].
  UserProvider call(
    String userId,
  ) {
    return UserProvider(
      userId,
    );
  }

  @override
  UserProvider getProviderOverride(
    covariant UserProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProvider';
}

/// 사용자 정보 조회 Provider (ID로 조회)
///
/// Copied from [user].
class UserProvider extends AutoDisposeFutureProvider<UserEntity?> {
  /// 사용자 정보 조회 Provider (ID로 조회)
  ///
  /// Copied from [user].
  UserProvider(
    String userId,
  ) : this._internal(
          (ref) => user(
            ref as UserRef,
            userId,
          ),
          from: userProvider,
          name: r'userProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$userHash,
          dependencies: UserFamily._dependencies,
          allTransitiveDependencies: UserFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<UserEntity?> Function(UserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProvider._internal(
        (ref) => create(ref as UserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserEntity?> createElement() {
    return _UserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserRef on AutoDisposeFutureProviderRef<UserEntity?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserProviderElement extends AutoDisposeFutureProviderElement<UserEntity?>
    with UserRef {
  _UserProviderElement(super.provider);

  @override
  String get userId => (origin as UserProvider).userId;
}

String _$usersHash() => r'80ec9f234a6f13dac949efeef2aebd8aeb7932f5';

/// 여러 사용자 정보 조회 Provider
///
/// Copied from [users].
@ProviderFor(users)
const usersProvider = UsersFamily();

/// 여러 사용자 정보 조회 Provider
///
/// Copied from [users].
class UsersFamily extends Family<AsyncValue<Map<String, UserEntity>>> {
  /// 여러 사용자 정보 조회 Provider
  ///
  /// Copied from [users].
  const UsersFamily();

  /// 여러 사용자 정보 조회 Provider
  ///
  /// Copied from [users].
  UsersProvider call(
    List<String> userIds,
  ) {
    return UsersProvider(
      userIds,
    );
  }

  @override
  UsersProvider getProviderOverride(
    covariant UsersProvider provider,
  ) {
    return call(
      provider.userIds,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'usersProvider';
}

/// 여러 사용자 정보 조회 Provider
///
/// Copied from [users].
class UsersProvider extends AutoDisposeFutureProvider<Map<String, UserEntity>> {
  /// 여러 사용자 정보 조회 Provider
  ///
  /// Copied from [users].
  UsersProvider(
    List<String> userIds,
  ) : this._internal(
          (ref) => users(
            ref as UsersRef,
            userIds,
          ),
          from: usersProvider,
          name: r'usersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$usersHash,
          dependencies: UsersFamily._dependencies,
          allTransitiveDependencies: UsersFamily._allTransitiveDependencies,
          userIds: userIds,
        );

  UsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userIds,
  }) : super.internal();

  final List<String> userIds;

  @override
  Override overrideWith(
    FutureOr<Map<String, UserEntity>> Function(UsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UsersProvider._internal(
        (ref) => create(ref as UsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userIds: userIds,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, UserEntity>> createElement() {
    return _UsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersProvider && other.userIds == userIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UsersRef on AutoDisposeFutureProviderRef<Map<String, UserEntity>> {
  /// The parameter `userIds` of this provider.
  List<String> get userIds;
}

class _UsersProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, UserEntity>>
    with UsersRef {
  _UsersProviderElement(super.provider);

  @override
  List<String> get userIds => (origin as UsersProvider).userIds;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
