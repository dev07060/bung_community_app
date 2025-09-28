import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';

/// 벙 관련 상태를 참조하는 Mixin Class
mixin class EventStateMixin {
  /// 특정 채널의 벙 목록 가져오기
  List<EventEntity> getChannelEvents(WidgetRef ref, String channelId) {
    return ref.watch(channelEventsProvider(channelId)).when(
          data: (events) => events,
          loading: () => [],
          error: (_, __) => [],
        );
  }

  /// 사용자 관련 벙 목록 가져오기
  List<EventEntity> getUserEvents(WidgetRef ref) {
    return ref.watch(userEventsProvider).when(
          data: (events) => events,
          loading: () => [],
          error: (_, __) => [],
        );
  }

  /// 특정 벙 정보 가져오기
  EventEntity? getEvent(WidgetRef ref, String eventId) {
    return ref.watch(eventProvider(eventId)).when(
          data: (event) => event,
          loading: () => null,
          error: (_, __) => null,
        );
  }

  /// 사용자가 참여 중인 벙 목록 가져오기
  List<EventEntity> getParticipatingEvents(WidgetRef ref) {
    return ref.read(userEventsProvider.notifier).getParticipatingEvents();
  }

  /// 사용자가 주최한 벙 목록 가져오기
  List<EventEntity> getOrganizedEvents(WidgetRef ref) {
    return ref.read(userEventsProvider.notifier).getOrganizedEvents();
  }

  /// 벙 생성 로딩 상태 확인
  bool isEventCreating(WidgetRef ref) {
    return ref.watch(eventCreationProvider).isLoading;
  }

  /// 벙 생성 에러 메시지 가져오기
  String? getEventCreationError(WidgetRef ref) {
    return ref.watch(eventCreationProvider).when(
          data: (_) => null,
          loading: () => null,
          error: (error, _) => error.toString(),
        );
  }

  /// 벙 참여/취소 로딩 상태 확인
  bool isEventParticipationLoading(WidgetRef ref) {
    return ref.watch(eventParticipationProvider).isLoading;
  }

  /// 벙 관리 로딩 상태 확인
  bool isEventManagementLoading(WidgetRef ref) {
    return ref.watch(eventManagementProvider).isLoading;
  }

  /// 사용자가 특정 벙의 주최자인지 확인
  bool isEventOrganizer(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    if (event == null) return false;

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;

    return event.isOrganizer(currentUser.id);
  }

  /// 사용자가 특정 벙에 참여 중인지 확인
  bool isEventParticipant(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    if (event == null) return false;

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;

    return event.isParticipant(currentUser.id);
  }

  /// 사용자가 특정 벙의 대기열에 있는지 확인
  bool isEventWaiting(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    if (event == null) return false;

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;

    return event.isWaiting(currentUser.id);
  }

  /// 사용자가 특정 벙에 참여할 수 있는지 확인
  bool canJoinEvent(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    if (event == null) return false;

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;

    // Already a participant or on the waiting list
    if (event.isParticipant(currentUser.id)) {
      return false;
    }

    // Organizer can't join their own event as a participant
    if (event.isOrganizer(currentUser.id)) {
      return false;
    }

    // Can't join if the event is already ongoing, completed, or cancelled.
    // A user CAN attempt to join a 'scheduled' or 'closed' event (to get on the waiting list).
    if (event.isCompleted || event.isCancelled) {
      return false;
    }

    return true;
  }

  /// 사용자가 특정 벙에서 나갈 수 있는지 확인
  bool canLeaveEvent(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    if (event == null) return false;

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;

    // 주최자는 나갈 수 없음
    if (event.isOrganizer(currentUser.id)) {
      return false;
    }

    // 참여 중이거나 대기 중인 경우만 나갈 수 있음
    return event.isParticipant(currentUser.id) || event.isWaiting(currentUser.id);
  }

  /// 사용자가 특정 벙을 관리할 수 있는지 확인
  bool canManageEvent(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    if (event == null) return false;

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;

    // 주최자만 관리 가능
    if (!event.isOrganizer(currentUser.id)) {
      return false;
    }

    // 취소되거나 완료된 벙은 관리 불가
    return !event.isCancelled && !event.isCompleted;
  }

  /// 벙 상태 표시명 가져오기
  String getEventStatusDisplayName(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.displayStatus ?? '알 수 없음';
  }

  /// 벙 참여 정보 가져오기 (예: "5/10명")
  String getEventParticipationInfo(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.participationInfo ?? '0/0명';
  }

  /// 벙까지 남은 일수 가져오기
  int getEventDaysUntil(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.daysUntilEvent ?? 0;
  }

  /// 벙이 오늘인지 확인
  bool isEventToday(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.isToday ?? false;
  }

  /// 벙이 가득 찼는지 확인
  bool isEventFull(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.isFull ?? false;
  }

  /// 벙에 대기자가 있는지 확인
  bool hasEventWaitingList(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.hasWaitingList ?? false;
  }

  /// 벙의 사용 가능한 자리 수 가져오기
  int getEventAvailableSlots(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.availableSlots ?? 0;
  }

  /// 벙의 총 참여자 수 가져오기
  int getEventTotalParticipants(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.totalParticipants ?? 0;
  }

  /// 벙의 총 대기자 수 가져오기
  int getEventTotalWaiting(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.totalWaiting ?? 0;
  }

  /// 벙이 정산이 필요한지 확인
  bool doesEventRequireSettlement(WidgetRef ref, String eventId) {
    final event = getEvent(ref, eventId);
    return event?.requiresSettlement ?? false;
  }

  /// 상태별 벙 목록 필터링
  List<EventEntity> filterEventsByStatus(
    WidgetRef ref,
    List<EventEntity> events,
    EventStatus status,
  ) {
    return events.where((event) => event.status == status).toList();
  }

  /// 예정된 벙 목록 가져오기
  List<EventEntity> getScheduledEvents(WidgetRef ref, List<EventEntity> events) {
    return filterEventsByStatus(ref, events, EventStatus.scheduled);
  }

  /// 진행 중인 벙 목록 가져오기
  List<EventEntity> getOngoingEvents(WidgetRef ref, List<EventEntity> events) {
    return filterEventsByStatus(ref, events, EventStatus.ongoing);
  }

  /// 완료된 벙 목록 가져오기
  List<EventEntity> getCompletedEvents(WidgetRef ref, List<EventEntity> events) {
    return filterEventsByStatus(ref, events, EventStatus.completed);
  }

  /// 취소된 벙 목록 가져오기
  List<EventEntity> getCancelledEvents(WidgetRef ref, List<EventEntity> events) {
    return filterEventsByStatus(ref, events, EventStatus.cancelled);
  }

  /// 벙 목록이 비어있는지 확인
  bool hasNoEvents(WidgetRef ref, List<EventEntity> events) {
    return events.isEmpty;
  }

  /// 채널 벙 목록 로딩 상태 확인
  bool isChannelEventsLoading(WidgetRef ref, String channelId) {
    return ref.watch(channelEventsProvider(channelId)).isLoading;
  }

  /// 사용자 벙 목록 로딩 상태 확인
  bool isUserEventsLoading(WidgetRef ref) {
    return ref.watch(userEventsProvider).isLoading;
  }

  /// 채널 벙 목록 에러 상태 확인
  String? getChannelEventsError(WidgetRef ref, String channelId) {
    return ref.watch(channelEventsProvider(channelId)).when(
          data: (_) => null,
          loading: () => null,
          error: (error, _) => error.toString(),
        );
  }

  /// 사용자 벙 목록 에러 상태 확인
  String? getUserEventsError(WidgetRef ref) {
    return ref.watch(userEventsProvider).when(
          data: (_) => null,
          loading: () => null,
          error: (error, _) => error.toString(),
        );
  }

  /// 벙 검색 결과 가져오기
  List<EventEntity> getEventSearchResults(WidgetRef ref) {
    return ref.watch(eventSearchProvider);
  }

  /// 현재 선택된 벙 ID 가져오기
  String? getCurrentEventId(WidgetRef ref) {
    return ref.watch(currentEventIdProvider);
  }

  /// 현재 선택된 벙 정보 가져오기
  EventEntity? getCurrentEvent(WidgetRef ref) {
    return ref.watch(currentEventProvider).when(
          data: (event) => event,
          loading: () => null,
          error: (_, __) => null,
        );
  }
}
