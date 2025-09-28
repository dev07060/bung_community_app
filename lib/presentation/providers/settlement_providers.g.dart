// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settlementRepositoryHash() =>
    r'ae850f8339aad5f29f3935bb4e664bc5484bf774';

/// See also [settlementRepository].
@ProviderFor(settlementRepository)
final settlementRepositoryProvider =
    AutoDisposeProvider<SettlementRepository>.internal(
  settlementRepository,
  name: r'settlementRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settlementRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettlementRepositoryRef = AutoDisposeProviderRef<SettlementRepository>;
String _$eventSettlementHash() => r'f0e89af09b4bb8f37eb6ea2bd23fb137712739cb';

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

/// See also [eventSettlement].
@ProviderFor(eventSettlement)
const eventSettlementProvider = EventSettlementFamily();

/// See also [eventSettlement].
class EventSettlementFamily extends Family<AsyncValue<SettlementEntity?>> {
  /// See also [eventSettlement].
  const EventSettlementFamily();

  /// See also [eventSettlement].
  EventSettlementProvider call(
    String eventId,
  ) {
    return EventSettlementProvider(
      eventId,
    );
  }

  @override
  EventSettlementProvider getProviderOverride(
    covariant EventSettlementProvider provider,
  ) {
    return call(
      provider.eventId,
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
  String? get name => r'eventSettlementProvider';
}

/// See also [eventSettlement].
class EventSettlementProvider
    extends AutoDisposeFutureProvider<SettlementEntity?> {
  /// See also [eventSettlement].
  EventSettlementProvider(
    String eventId,
  ) : this._internal(
          (ref) => eventSettlement(
            ref as EventSettlementRef,
            eventId,
          ),
          from: eventSettlementProvider,
          name: r'eventSettlementProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$eventSettlementHash,
          dependencies: EventSettlementFamily._dependencies,
          allTransitiveDependencies:
              EventSettlementFamily._allTransitiveDependencies,
          eventId: eventId,
        );

  EventSettlementProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventId,
  }) : super.internal();

  final String eventId;

  @override
  Override overrideWith(
    FutureOr<SettlementEntity?> Function(EventSettlementRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventSettlementProvider._internal(
        (ref) => create(ref as EventSettlementRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventId: eventId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SettlementEntity?> createElement() {
    return _EventSettlementProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventSettlementProvider && other.eventId == eventId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EventSettlementRef on AutoDisposeFutureProviderRef<SettlementEntity?> {
  /// The parameter `eventId` of this provider.
  String get eventId;
}

class _EventSettlementProviderElement
    extends AutoDisposeFutureProviderElement<SettlementEntity?>
    with EventSettlementRef {
  _EventSettlementProviderElement(super.provider);

  @override
  String get eventId => (origin as EventSettlementProvider).eventId;
}

String _$settlementHash() => r'7631cf3db06dd7202d2614f2ee9c7087241b3f1d';

/// See also [settlement].
@ProviderFor(settlement)
const settlementProvider = SettlementFamily();

/// See also [settlement].
class SettlementFamily extends Family<AsyncValue<SettlementEntity?>> {
  /// See also [settlement].
  const SettlementFamily();

  /// See also [settlement].
  SettlementProvider call(
    String settlementId,
  ) {
    return SettlementProvider(
      settlementId,
    );
  }

  @override
  SettlementProvider getProviderOverride(
    covariant SettlementProvider provider,
  ) {
    return call(
      provider.settlementId,
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
  String? get name => r'settlementProvider';
}

/// See also [settlement].
class SettlementProvider extends AutoDisposeFutureProvider<SettlementEntity?> {
  /// See also [settlement].
  SettlementProvider(
    String settlementId,
  ) : this._internal(
          (ref) => settlement(
            ref as SettlementRef,
            settlementId,
          ),
          from: settlementProvider,
          name: r'settlementProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$settlementHash,
          dependencies: SettlementFamily._dependencies,
          allTransitiveDependencies:
              SettlementFamily._allTransitiveDependencies,
          settlementId: settlementId,
        );

  SettlementProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.settlementId,
  }) : super.internal();

  final String settlementId;

  @override
  Override overrideWith(
    FutureOr<SettlementEntity?> Function(SettlementRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SettlementProvider._internal(
        (ref) => create(ref as SettlementRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        settlementId: settlementId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SettlementEntity?> createElement() {
    return _SettlementProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SettlementProvider && other.settlementId == settlementId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, settlementId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SettlementRef on AutoDisposeFutureProviderRef<SettlementEntity?> {
  /// The parameter `settlementId` of this provider.
  String get settlementId;
}

class _SettlementProviderElement
    extends AutoDisposeFutureProviderElement<SettlementEntity?>
    with SettlementRef {
  _SettlementProviderElement(super.provider);

  @override
  String get settlementId => (origin as SettlementProvider).settlementId;
}

String _$userSettlementsHash() => r'8c64d85db0063a0e3d5e5b9d12d47e2d45dbaaf0';

/// See also [userSettlements].
@ProviderFor(userSettlements)
const userSettlementsProvider = UserSettlementsFamily();

/// See also [userSettlements].
class UserSettlementsFamily extends Family<AsyncValue<List<SettlementEntity>>> {
  /// See also [userSettlements].
  const UserSettlementsFamily();

  /// See also [userSettlements].
  UserSettlementsProvider call(
    String userId,
  ) {
    return UserSettlementsProvider(
      userId,
    );
  }

  @override
  UserSettlementsProvider getProviderOverride(
    covariant UserSettlementsProvider provider,
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
  String? get name => r'userSettlementsProvider';
}

/// See also [userSettlements].
class UserSettlementsProvider
    extends AutoDisposeFutureProvider<List<SettlementEntity>> {
  /// See also [userSettlements].
  UserSettlementsProvider(
    String userId,
  ) : this._internal(
          (ref) => userSettlements(
            ref as UserSettlementsRef,
            userId,
          ),
          from: userSettlementsProvider,
          name: r'userSettlementsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userSettlementsHash,
          dependencies: UserSettlementsFamily._dependencies,
          allTransitiveDependencies:
              UserSettlementsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserSettlementsProvider._internal(
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
    FutureOr<List<SettlementEntity>> Function(UserSettlementsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserSettlementsProvider._internal(
        (ref) => create(ref as UserSettlementsRef),
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
  AutoDisposeFutureProviderElement<List<SettlementEntity>> createElement() {
    return _UserSettlementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserSettlementsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserSettlementsRef
    on AutoDisposeFutureProviderRef<List<SettlementEntity>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserSettlementsProviderElement
    extends AutoDisposeFutureProviderElement<List<SettlementEntity>>
    with UserSettlementsRef {
  _UserSettlementsProviderElement(super.provider);

  @override
  String get userId => (origin as UserSettlementsProvider).userId;
}

String _$organizerSettlementsHash() =>
    r'bfc39910895afd3ba2d1b9b01c4b4ca82c3edc15';

/// See also [organizerSettlements].
@ProviderFor(organizerSettlements)
const organizerSettlementsProvider = OrganizerSettlementsFamily();

/// See also [organizerSettlements].
class OrganizerSettlementsFamily
    extends Family<AsyncValue<List<SettlementEntity>>> {
  /// See also [organizerSettlements].
  const OrganizerSettlementsFamily();

  /// See also [organizerSettlements].
  OrganizerSettlementsProvider call(
    String organizerId,
  ) {
    return OrganizerSettlementsProvider(
      organizerId,
    );
  }

  @override
  OrganizerSettlementsProvider getProviderOverride(
    covariant OrganizerSettlementsProvider provider,
  ) {
    return call(
      provider.organizerId,
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
  String? get name => r'organizerSettlementsProvider';
}

/// See also [organizerSettlements].
class OrganizerSettlementsProvider
    extends AutoDisposeFutureProvider<List<SettlementEntity>> {
  /// See also [organizerSettlements].
  OrganizerSettlementsProvider(
    String organizerId,
  ) : this._internal(
          (ref) => organizerSettlements(
            ref as OrganizerSettlementsRef,
            organizerId,
          ),
          from: organizerSettlementsProvider,
          name: r'organizerSettlementsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$organizerSettlementsHash,
          dependencies: OrganizerSettlementsFamily._dependencies,
          allTransitiveDependencies:
              OrganizerSettlementsFamily._allTransitiveDependencies,
          organizerId: organizerId,
        );

  OrganizerSettlementsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.organizerId,
  }) : super.internal();

  final String organizerId;

  @override
  Override overrideWith(
    FutureOr<List<SettlementEntity>> Function(OrganizerSettlementsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrganizerSettlementsProvider._internal(
        (ref) => create(ref as OrganizerSettlementsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        organizerId: organizerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SettlementEntity>> createElement() {
    return _OrganizerSettlementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrganizerSettlementsProvider &&
        other.organizerId == organizerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, organizerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin OrganizerSettlementsRef
    on AutoDisposeFutureProviderRef<List<SettlementEntity>> {
  /// The parameter `organizerId` of this provider.
  String get organizerId;
}

class _OrganizerSettlementsProviderElement
    extends AutoDisposeFutureProviderElement<List<SettlementEntity>>
    with OrganizerSettlementsRef {
  _OrganizerSettlementsProviderElement(super.provider);

  @override
  String get organizerId =>
      (origin as OrganizerSettlementsProvider).organizerId;
}

String _$settlementActionsHash() => r'89bdb5b0e827ae2d9856e29ce0466ef5ec2bdc21';

/// See also [SettlementActions].
@ProviderFor(SettlementActions)
final settlementActionsProvider =
    AutoDisposeNotifierProvider<SettlementActions, void>.internal(
  SettlementActions.new,
  name: r'settlementActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settlementActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettlementActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
