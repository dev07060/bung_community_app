import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/data/repositories/event_repository_impl.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/repositories/event_repository.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_providers.g.dart';

// Event Repository Provider
@riverpod
EventRepository eventRepository(EventRepositoryRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return EventRepositoryImpl(authRepository: authRepository);
}

// Channel Events Provider - 특정 채널의 벙 목록
@riverpod
class ChannelEvents extends _$ChannelEvents {
  @override
  Future<List<EventEntity>> build(String channelId) async {
    try {
      final repository = ref.watch(eventRepositoryProvider);
      final events = await repository.getChannelEvents(channelId);
      Logger.info('Loaded ${events.length} events for channel $channelId');
      return events;
    } catch (e, stackTrace) {
      Logger.error('Failed to load channel events', e, stackTrace);
      rethrow;
    }
  }

  // 벙 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(channelId));
  }

  // 새 벙 추가 (로컬 상태 업데이트)
  void addEvent(EventEntity event) {
    state.whenData((events) {
      final updatedEvents = [event, ...events];
      updatedEvents.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      state = AsyncValue.data(updatedEvents);
    });
  }

  // 벙 업데이트 (로컬 상태 업데이트)
  void updateEvent(EventEntity updatedEvent) {
    state.whenData((events) {
      final updatedEvents = events.map((event) {
        return event.id == updatedEvent.id ? updatedEvent : event;
      }).toList();
      state = AsyncValue.data(updatedEvents);
    });
  }

  // 벙 제거 (로컬 상태 업데이트)
  void removeEvent(String eventId) {
    state.whenData((events) {
      final filteredEvents = events.where((event) => event.id != eventId).toList();
      state = AsyncValue.data(filteredEvents);
    });
  }
}

// Channel Events Stream Provider - 실시간 벙 목록 업데이트
@riverpod
Stream<List<EventEntity>> channelEventsStream(ChannelEventsStreamRef ref, String channelId) {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchChannelEvents(channelId);
}

// User Events Provider - 사용자 관련 벙 목록
@riverpod
class UserEvents extends _$UserEvents {
  @override
  Future<List<EventEntity>> build() async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      throw const AuthException('로그인이 필요합니다.');
    }

    try {
      final repository = ref.watch(eventRepositoryProvider);
      final events = await repository.getUserEvents(currentUser.id);
      Logger.info('Loaded ${events.length} events for user ${currentUser.id}');
      return events;
    } catch (e, stackTrace) {
      Logger.error('Failed to load user events', e, stackTrace);
      rethrow;
    }
  }

  // 벙 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  // 참여 중인 벙 목록 필터링
  List<EventEntity> getParticipatingEvents() {
    return state.when(
      data: (events) {
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null) return [];

        return events.where((event) => event.isParticipant(currentUser.id) || event.isWaiting(currentUser.id)).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // 주최한 벙 목록 필터링
  List<EventEntity> getOrganizedEvents() {
    return state.when(
      data: (events) {
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null) return [];

        return events.where((event) => event.isOrganizer(currentUser.id)).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }
}

// Individual Event Provider - 특정 벙 정보
@riverpod
class Event extends _$Event {
  @override
  Future<EventEntity?> build(String eventId) async {
    try {
      final repository = ref.watch(eventRepositoryProvider);
      final event = await repository.getEventById(eventId);
      Logger.info('Loaded event: $eventId');
      return event;
    } catch (e, stackTrace) {
      Logger.error('Failed to load event $eventId', e, stackTrace);
      return null;
    }
  }

  // 벙 정보 업데이트
  void updateEventData(EventEntity updatedEvent) {
    if (updatedEvent.id == eventId) {
      state = AsyncValue.data(updatedEvent);

      // 채널 벙 목록도 업데이트
      ref.read(channelEventsProvider(updatedEvent.channelId).notifier).updateEvent(updatedEvent);

      // 사용자 벙 목록도 업데이트
      ref.read(userEventsProvider.notifier).refresh();
    }
  }
}

// Event Creation State Provider - 벙 생성 상태 관리
@riverpod
class EventCreation extends _$EventCreation {
  @override
  AsyncValue<EventEntity?> build() {
    return const AsyncValue.data(null);
  }

  // 벙 생성
  Future<EventEntity?> createEvent(EventEntity event) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(eventRepositoryProvider);
      final createdEvent = await repository.createEvent(event);

      Logger.info('Event created successfully: ${createdEvent.id}');

      // 채널 벙 목록에 추가
      ref.read(channelEventsProvider(createdEvent.channelId).notifier).addEvent(createdEvent);

      // 사용자 벙 목록 새로고침
      ref.read(userEventsProvider.notifier).refresh();

      state = AsyncValue.data(createdEvent);
      return createdEvent;
    } catch (e, stackTrace) {
      Logger.error('Failed to create event', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  // 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Event Participation State Provider - 벙 참여/취소 상태 관리
@riverpod
class EventParticipation extends _$EventParticipation {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  // 벙 참여
  Future<bool> joinEvent(String eventId) async {
    state = const AsyncValue.loading();

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw const AuthException('로그인이 필요합니다.');
      }

      final repository = ref.read(eventRepositoryProvider);
      await repository.joinEvent(eventId, currentUser.id);

      Logger.info('Successfully joined event: $eventId');

      // 벙 정보 새로고침
      _refreshState(eventId);

      state = const AsyncValue.data(true);
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to join event', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // 벙 참여 취소
  Future<bool> leaveEvent(String eventId) async {
    state = const AsyncValue.loading();

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw const AuthException('로그인이 필요합니다.');
      }

      final repository = ref.read(eventRepositoryProvider);
      await repository.leaveEvent(eventId, currentUser.id);

      Logger.info('Successfully left event: $eventId');

      // 벙 정보 새로고침
      _refreshState(eventId);

      state = const AsyncValue.data(true);
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to leave event', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // 벙 대기열 참여
  Future<bool> joinWaitingList(String eventId) async {
    state = const AsyncValue.loading();

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw const AuthException('로그인이 필요합니다.');
      }

      final repository = ref.read(eventRepositoryProvider);
      await repository.joinWaitingList(eventId, currentUser.id);

      Logger.info('Successfully joined waiting list for event: $eventId');

      // 벙 정보 새로고침
      _refreshState(eventId);

      state = const AsyncValue.data(true);
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to join waiting list', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // 상태 초기화
  void reset() {
    state = const AsyncValue.data(false);
  }

  void _refreshState(eventId) {
    ref.invalidate(eventProvider(eventId));
    ref.read(userEventsProvider.notifier).refresh();
    reset();
  }
}

// Event Management State Provider - 벙 관리 상태 (주최자 전용)
@riverpod
class EventManagement extends _$EventManagement {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  // 벙 상태 업데이트
  Future<bool> updateEventStatus(String eventId, EventStatus status) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(eventRepositoryProvider);
      await repository.updateEventStatus(eventId, status);

      Logger.info('Event status updated: $eventId to ${status.name}');

      // 벙 정보 새로고침
      ref.invalidate(eventProvider(eventId));
      ref.read(userEventsProvider.notifier).refresh();

      state = const AsyncValue.data(true);
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update event status', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // 벙 마감
  Future<bool> closeEvent(String eventId) async {
    return updateEventStatus(eventId, EventStatus.closed);
  }

  // 벙 재개방
  Future<bool> reopenEvent(String eventId) async {
    return updateEventStatus(eventId, EventStatus.scheduled);
  }

  // 벙 취소
  Future<bool> cancelEvent(String eventId) async {
    return updateEventStatus(eventId, EventStatus.cancelled);
  }

  // 벙 완료 처리
  Future<bool> completeEvent(String eventId) async {
    return updateEventStatus(eventId, EventStatus.completed);
  }

  // 상태 초기화
  void reset() {
    state = const AsyncValue.data(false);
  }
}

// Event Search Provider - 벙 검색
@riverpod
class EventSearch extends _$EventSearch {
  @override
  List<EventEntity> build() {
    return [];
  }

  // 채널 내 벙 검색
  void searchInChannel(String channelId, String query) {
    final channelEventsAsync = ref.read(channelEventsProvider(channelId));
    channelEventsAsync.whenData((events) {
      if (query.isEmpty) {
        state = events;
      } else {
        final filteredEvents = events
            .where((event) =>
                event.title.toLowerCase().contains(query.toLowerCase()) ||
                event.description.toLowerCase().contains(query.toLowerCase()) ||
                event.location.toLowerCase().contains(query.toLowerCase()))
            .toList();
        state = filteredEvents;
      }
    });
  }

  // 사용자 벙 검색
  void searchUserEvents(String query) {
    final userEventsAsync = ref.read(userEventsProvider);
    userEventsAsync.whenData((events) {
      if (query.isEmpty) {
        state = events;
      } else {
        final filteredEvents = events
            .where((event) =>
                event.title.toLowerCase().contains(query.toLowerCase()) ||
                event.description.toLowerCase().contains(query.toLowerCase()) ||
                event.location.toLowerCase().contains(query.toLowerCase()))
            .toList();
        state = filteredEvents;
      }
    });
  }

  // 검색 결과 초기화
  void clear() {
    state = [];
  }
}

// Current Event Provider - 현재 선택된 벙 (ProviderScope용)
@riverpod
String? currentEventId(CurrentEventIdRef ref) {
  // ProviderScope를 통해 주입될 값
  return null;
}

// Current Event Entity Provider - 현재 선택된 벙 엔티티 (.future 패턴 최적화)
final currentEventProvider = AutoDisposeFutureProvider<EventEntity?>((ref) async {
  final eventId = ref.watch(currentEventIdProvider);
  if (eventId == null) {
    return null;
  }

  try {
    // .future 패턴을 사용하여 안전하게 데이터 가져오기
    return await ref.watch(eventProvider(eventId).future);
  } catch (e, stackTrace) {
    Logger.error('Failed to load current event', e, stackTrace);
    return null;
  }
}, dependencies: [currentEventIdProvider]);

// Event Argument Providers - ProviderScope를 통한 인자 전달
class EventArgumentProviders {
  /// 벙 ID를 ProviderScope에 주입하기 위한 오버라이드 생성
  static Override eventIdOverride(String eventId) {
    return currentEventIdProvider.overrideWith((ref) => eventId);
  }

  /// 채널 ID를 ProviderScope에 주입하기 위한 오버라이드 생성
  static Override channelIdOverride(String channelId) {
    // 채널 관련 provider에서 사용할 수 있도록
    return currentChannelIdProvider.overrideWith((ref) => channelId);
  }

  /// 벙 생성 페이지용 오버라이드들
  static List<Override> eventCreationOverrides(String channelId) {
    return [
      channelIdOverride(channelId),
      // 벙 생성 상태 초기화
      eventCreationProvider.overrideWith(() => EventCreation()),
    ];
  }

  /// 벙 상세 페이지용 오버라이드들
  static List<Override> eventDetailOverrides(String eventId) {
    return [
      eventIdOverride(eventId),
      // 벙 참여 상태 초기화
      eventParticipationProvider.overrideWith(() => EventParticipation()),
      // 벙 관리 상태 초기화
      eventManagementProvider.overrideWith(() => EventManagement()),
    ];
  }

  /// 벙 목록 페이지용 오버라이드들
  static List<Override> eventListOverrides(String channelId) {
    return [
      channelIdOverride(channelId),
      // 벙 검색 상태 초기화
      eventSearchProvider.overrideWith(() => EventSearch()),
    ];
  }

  /// 사용자 벙 목록 페이지용 오버라이드들
  static List<Override> userEventListOverrides() {
    return [
      // 벙 검색 상태 초기화
      eventSearchProvider.overrideWith(() => EventSearch()),
    ];
  }
}

// Helper provider for current channel ID (referenced from channel providers)
@riverpod
String? currentChannelId(CurrentChannelIdRef ref) {
  // ProviderScope를 통해 주입될 값
  return null;
}
