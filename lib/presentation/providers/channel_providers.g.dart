// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelRepositoryHash() => r'7089936998ee8a393846d6533cc5dfdfd7ac9542';

/// See also [channelRepository].
@ProviderFor(channelRepository)
final channelRepositoryProvider =
    AutoDisposeProvider<ChannelRepository>.internal(
  channelRepository,
  name: r'channelRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$channelRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChannelRepositoryRef = AutoDisposeProviderRef<ChannelRepository>;
String _$currentChannelIdHash() => r'475d85785c0ae499e04ba5ed3d5c947efe0a4208';

/// See also [currentChannelId].
@ProviderFor(currentChannelId)
final currentChannelIdProvider = AutoDisposeProvider<String?>.internal(
  currentChannelId,
  name: r'currentChannelIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentChannelIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentChannelIdRef = AutoDisposeProviderRef<String?>;
String _$currentChannelHash() => r'f26bb95a7b34179720d37dcf08e7f60d68bb0f61';

/// See also [currentChannel].
@ProviderFor(currentChannel)
final currentChannelProvider =
    AutoDisposeFutureProvider<ChannelEntity?>.internal(
  currentChannel,
  name: r'currentChannelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentChannelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentChannelRef = AutoDisposeFutureProviderRef<ChannelEntity?>;
String _$userChannelsHash() => r'74b4af8fff7e3c96f9e59d514886ad2f92a3a8df';

/// See also [UserChannels].
@ProviderFor(UserChannels)
final userChannelsProvider = AutoDisposeAsyncNotifierProvider<UserChannels,
    List<ChannelEntity>>.internal(
  UserChannels.new,
  name: r'userChannelsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userChannelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserChannels = AutoDisposeAsyncNotifier<List<ChannelEntity>>;
String _$channelHash() => r'b43934540ddfb48a4c7a38572fb45e3bedb15533';

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

abstract class _$Channel
    extends BuildlessAutoDisposeAsyncNotifier<ChannelEntity?> {
  late final String channelId;

  FutureOr<ChannelEntity?> build(
    String channelId,
  );
}

/// See also [Channel].
@ProviderFor(Channel)
const channelProvider = ChannelFamily();

/// See also [Channel].
class ChannelFamily extends Family<AsyncValue<ChannelEntity?>> {
  /// See also [Channel].
  const ChannelFamily();

  /// See also [Channel].
  ChannelProvider call(
    String channelId,
  ) {
    return ChannelProvider(
      channelId,
    );
  }

  @override
  ChannelProvider getProviderOverride(
    covariant ChannelProvider provider,
  ) {
    return call(
      provider.channelId,
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
  String? get name => r'channelProvider';
}

/// See also [Channel].
class ChannelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Channel, ChannelEntity?> {
  /// See also [Channel].
  ChannelProvider(
    String channelId,
  ) : this._internal(
          () => Channel()..channelId = channelId,
          from: channelProvider,
          name: r'channelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelHash,
          dependencies: ChannelFamily._dependencies,
          allTransitiveDependencies: ChannelFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ChannelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelId,
  }) : super.internal();

  final String channelId;

  @override
  FutureOr<ChannelEntity?> runNotifierBuild(
    covariant Channel notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(Channel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelProvider._internal(
        () => create()..channelId = channelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channelId: channelId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Channel, ChannelEntity?>
      createElement() {
    return _ChannelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelRef on AutoDisposeAsyncNotifierProviderRef<ChannelEntity?> {
  /// The parameter `channelId` of this provider.
  String get channelId;
}

class _ChannelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Channel, ChannelEntity?>
    with ChannelRef {
  _ChannelProviderElement(super.provider);

  @override
  String get channelId => (origin as ChannelProvider).channelId;
}

String _$channelCreationHash() => r'c55f66cb7da7a9a931083ee2f638e005bd17e912';

/// See also [ChannelCreation].
@ProviderFor(ChannelCreation)
final channelCreationProvider = AutoDisposeNotifierProvider<ChannelCreation,
    AsyncValue<ChannelEntity?>>.internal(
  ChannelCreation.new,
  name: r'channelCreationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$channelCreationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChannelCreation = AutoDisposeNotifier<AsyncValue<ChannelEntity?>>;
String _$channelJoinHash() => r'3dd05718237fd10fb1b17da8c3587611d2e2c8a1';

/// See also [ChannelJoin].
@ProviderFor(ChannelJoin)
final channelJoinProvider = AutoDisposeNotifierProvider<ChannelJoin,
    AsyncValue<ChannelEntity?>>.internal(
  ChannelJoin.new,
  name: r'channelJoinProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$channelJoinHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChannelJoin = AutoDisposeNotifier<AsyncValue<ChannelEntity?>>;
String _$channelUpdateHash() => r'9dbd0139efcb65305d716e5492c57a8b89fe488c';

/// See also [ChannelUpdate].
@ProviderFor(ChannelUpdate)
final channelUpdateProvider =
    AutoDisposeNotifierProvider<ChannelUpdate, AsyncValue<bool>>.internal(
  ChannelUpdate.new,
  name: r'channelUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$channelUpdateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChannelUpdate = AutoDisposeNotifier<AsyncValue<bool>>;
String _$channelMemberManagementHash() =>
    r'03b71193f7983830f66e3238c2181cce473be97c';

/// See also [ChannelMemberManagement].
@ProviderFor(ChannelMemberManagement)
final channelMemberManagementProvider = AutoDisposeNotifierProvider<
    ChannelMemberManagement, AsyncValue<bool>>.internal(
  ChannelMemberManagement.new,
  name: r'channelMemberManagementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$channelMemberManagementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChannelMemberManagement = AutoDisposeNotifier<AsyncValue<bool>>;
String _$channelSearchHash() => r'da35e58de2fb0359d0cfe6f4f24d51c7a21e2a1c';

/// See also [ChannelSearch].
@ProviderFor(ChannelSearch)
final channelSearchProvider =
    AutoDisposeNotifierProvider<ChannelSearch, List<ChannelEntity>>.internal(
  ChannelSearch.new,
  name: r'channelSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$channelSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChannelSearch = AutoDisposeNotifier<List<ChannelEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
