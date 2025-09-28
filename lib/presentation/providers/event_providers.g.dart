// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventRepositoryHash() => r'f747e9ab95947d9411b37d4fe4bb536067273439';

/// See also [eventRepository].
@ProviderFor(eventRepository)
final eventRepositoryProvider = AutoDisposeProvider<EventRepository>.internal(
  eventRepository,
  name: r'eventRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EventRepositoryRef = AutoDisposeProviderRef<EventRepository>;
String _$channelEventsStreamHash() =>
    r'5b63f4592bbf03fbaa848a985936afa0be53ecc2';

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

/// See also [channelEventsStream].
@ProviderFor(channelEventsStream)
const channelEventsStreamProvider = ChannelEventsStreamFamily();

/// See also [channelEventsStream].
class ChannelEventsStreamFamily extends Family<AsyncValue<List<EventEntity>>> {
  /// See also [channelEventsStream].
  const ChannelEventsStreamFamily();

  /// See also [channelEventsStream].
  ChannelEventsStreamProvider call(
    String channelId,
  ) {
    return ChannelEventsStreamProvider(
      channelId,
    );
  }

  @override
  ChannelEventsStreamProvider getProviderOverride(
    covariant ChannelEventsStreamProvider provider,
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
  String? get name => r'channelEventsStreamProvider';
}

/// See also [channelEventsStream].
class ChannelEventsStreamProvider
    extends AutoDisposeStreamProvider<List<EventEntity>> {
  /// See also [channelEventsStream].
  ChannelEventsStreamProvider(
    String channelId,
  ) : this._internal(
          (ref) => channelEventsStream(
            ref as ChannelEventsStreamRef,
            channelId,
          ),
          from: channelEventsStreamProvider,
          name: r'channelEventsStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelEventsStreamHash,
          dependencies: ChannelEventsStreamFamily._dependencies,
          allTransitiveDependencies:
              ChannelEventsStreamFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ChannelEventsStreamProvider._internal(
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
  Override overrideWith(
    Stream<List<EventEntity>> Function(ChannelEventsStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChannelEventsStreamProvider._internal(
        (ref) => create(ref as ChannelEventsStreamRef),
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
  AutoDisposeStreamProviderElement<List<EventEntity>> createElement() {
    return _ChannelEventsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelEventsStreamProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelEventsStreamRef
    on AutoDisposeStreamProviderRef<List<EventEntity>> {
  /// The parameter `channelId` of this provider.
  String get channelId;
}

class _ChannelEventsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<EventEntity>>
    with ChannelEventsStreamRef {
  _ChannelEventsStreamProviderElement(super.provider);

  @override
  String get channelId => (origin as ChannelEventsStreamProvider).channelId;
}

String _$currentEventIdHash() => r'6a8e4ccd030fb494e10aad77a59f8c1606bbeb3a';

/// See also [currentEventId].
@ProviderFor(currentEventId)
final currentEventIdProvider = AutoDisposeProvider<String?>.internal(
  currentEventId,
  name: r'currentEventIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentEventIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentEventIdRef = AutoDisposeProviderRef<String?>;
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
String _$channelEventsHash() => r'6237e59f7abdc8afcd41d0606d307f10828a5880';

abstract class _$ChannelEvents
    extends BuildlessAutoDisposeAsyncNotifier<List<EventEntity>> {
  late final String channelId;

  FutureOr<List<EventEntity>> build(
    String channelId,
  );
}

/// See also [ChannelEvents].
@ProviderFor(ChannelEvents)
const channelEventsProvider = ChannelEventsFamily();

/// See also [ChannelEvents].
class ChannelEventsFamily extends Family<AsyncValue<List<EventEntity>>> {
  /// See also [ChannelEvents].
  const ChannelEventsFamily();

  /// See also [ChannelEvents].
  ChannelEventsProvider call(
    String channelId,
  ) {
    return ChannelEventsProvider(
      channelId,
    );
  }

  @override
  ChannelEventsProvider getProviderOverride(
    covariant ChannelEventsProvider provider,
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
  String? get name => r'channelEventsProvider';
}

/// See also [ChannelEvents].
class ChannelEventsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChannelEvents, List<EventEntity>> {
  /// See also [ChannelEvents].
  ChannelEventsProvider(
    String channelId,
  ) : this._internal(
          () => ChannelEvents()..channelId = channelId,
          from: channelEventsProvider,
          name: r'channelEventsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelEventsHash,
          dependencies: ChannelEventsFamily._dependencies,
          allTransitiveDependencies:
              ChannelEventsFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ChannelEventsProvider._internal(
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
  FutureOr<List<EventEntity>> runNotifierBuild(
    covariant ChannelEvents notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(ChannelEvents Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelEventsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ChannelEvents, List<EventEntity>>
      createElement() {
    return _ChannelEventsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelEventsProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelEventsRef
    on AutoDisposeAsyncNotifierProviderRef<List<EventEntity>> {
  /// The parameter `channelId` of this provider.
  String get channelId;
}

class _ChannelEventsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChannelEvents,
        List<EventEntity>> with ChannelEventsRef {
  _ChannelEventsProviderElement(super.provider);

  @override
  String get channelId => (origin as ChannelEventsProvider).channelId;
}

String _$userEventsHash() => r'1ee90f276e0df83d1f92b98a36b85caf5a0d3dfa';

/// See also [UserEvents].
@ProviderFor(UserEvents)
final userEventsProvider =
    AutoDisposeAsyncNotifierProvider<UserEvents, List<EventEntity>>.internal(
  UserEvents.new,
  name: r'userEventsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserEvents = AutoDisposeAsyncNotifier<List<EventEntity>>;
String _$eventHash() => r'b654b51bdcfcbaf9088e4067182ff79cda567e1b';

abstract class _$Event extends BuildlessAutoDisposeAsyncNotifier<EventEntity?> {
  late final String eventId;

  FutureOr<EventEntity?> build(
    String eventId,
  );
}

/// See also [Event].
@ProviderFor(Event)
const eventProvider = EventFamily();

/// See also [Event].
class EventFamily extends Family<AsyncValue<EventEntity?>> {
  /// See also [Event].
  const EventFamily();

  /// See also [Event].
  EventProvider call(
    String eventId,
  ) {
    return EventProvider(
      eventId,
    );
  }

  @override
  EventProvider getProviderOverride(
    covariant EventProvider provider,
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
  String? get name => r'eventProvider';
}

/// See also [Event].
class EventProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Event, EventEntity?> {
  /// See also [Event].
  EventProvider(
    String eventId,
  ) : this._internal(
          () => Event()..eventId = eventId,
          from: eventProvider,
          name: r'eventProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$eventHash,
          dependencies: EventFamily._dependencies,
          allTransitiveDependencies: EventFamily._allTransitiveDependencies,
          eventId: eventId,
        );

  EventProvider._internal(
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
  FutureOr<EventEntity?> runNotifierBuild(
    covariant Event notifier,
  ) {
    return notifier.build(
      eventId,
    );
  }

  @override
  Override overrideWith(Event Function() create) {
    return ProviderOverride(
      origin: this,
      override: EventProvider._internal(
        () => create()..eventId = eventId,
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
  AutoDisposeAsyncNotifierProviderElement<Event, EventEntity?> createElement() {
    return _EventProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventProvider && other.eventId == eventId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EventRef on AutoDisposeAsyncNotifierProviderRef<EventEntity?> {
  /// The parameter `eventId` of this provider.
  String get eventId;
}

class _EventProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Event, EventEntity?>
    with EventRef {
  _EventProviderElement(super.provider);

  @override
  String get eventId => (origin as EventProvider).eventId;
}

String _$eventCreationHash() => r'19b5d312f3cdf87cf8b79793adbfbb45768fb21d';

/// See also [EventCreation].
@ProviderFor(EventCreation)
final eventCreationProvider = AutoDisposeNotifierProvider<EventCreation,
    AsyncValue<EventEntity?>>.internal(
  EventCreation.new,
  name: r'eventCreationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventCreationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EventCreation = AutoDisposeNotifier<AsyncValue<EventEntity?>>;
String _$eventParticipationHash() =>
    r'dd88f3ea35f17d4517f77dc2eef68563d1b60cce';

/// See also [EventParticipation].
@ProviderFor(EventParticipation)
final eventParticipationProvider =
    AutoDisposeNotifierProvider<EventParticipation, AsyncValue<bool>>.internal(
  EventParticipation.new,
  name: r'eventParticipationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventParticipationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EventParticipation = AutoDisposeNotifier<AsyncValue<bool>>;
String _$eventManagementHash() => r'1969a6a4255912c47b9b6c0eb7a7a48e1a54591e';

/// See also [EventManagement].
@ProviderFor(EventManagement)
final eventManagementProvider =
    AutoDisposeNotifierProvider<EventManagement, AsyncValue<bool>>.internal(
  EventManagement.new,
  name: r'eventManagementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventManagementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EventManagement = AutoDisposeNotifier<AsyncValue<bool>>;
String _$eventSearchHash() => r'4218fd974eb5d7967b5801017fa80c49621b2991';

/// See also [EventSearch].
@ProviderFor(EventSearch)
final eventSearchProvider =
    AutoDisposeNotifierProvider<EventSearch, List<EventEntity>>.internal(
  EventSearch.new,
  name: r'eventSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$eventSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EventSearch = AutoDisposeNotifier<List<EventEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
