import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';

/// 벙 상세 화면 관련 상태를 참조하는 Mixin Class
mixin class EventDetailStateMixin {
  /// 현재 벙 상세 정보 가져오기
  EventEntity? getCurrentEventDetail(WidgetRef ref) {
    final eventId = ref.watch(currentEventIdProvider);
    if (eventId == null) return null;

    return ref.watch(eventProvider(eventId)).when(
          data: (event) => event,
          loading: () => null,
          error: (_, __) => null,
        );
  }

  /// 벙 상세 로딩 상태 확인
  bool isEventDetailLoading(WidgetRef ref) {
    final eventId = ref.watch(currentEventIdProvider);
    if (eventId == null) return false;

    return ref.watch(eventProvider(eventId)).isLoading;
  }

  /// 벙 상세 에러 상태 확인
  String? getEventDetailError(WidgetRef ref) {
    final eventId = ref.watch(currentEventIdProvider);
    if (eventId == null) return null;

    return ref.watch(eventProvider(eventId)).when(
          data: (_) => null,
          loading: () => null,
          error: (error, _) => error.toString(),
        );
  }

  /// 현재 사용자가 벙 참여자인지 확인
  bool isCurrentUserParticipant(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (event == null || currentUser == null) return false;

    return event.isParticipant(currentUser.id);
  }

  /// 현재 사용자가 벙 대기자인지 확인
  bool isCurrentUserWaiting(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (event == null || currentUser == null) return false;

    return event.isWaiting(currentUser.id);
  }

  /// 현재 사용자가 벙 주최자인지 확인
  bool isCurrentUserOrganizer(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (event == null || currentUser == null) return false;

    return event.isOrganizer(currentUser.id);
  }

  /// 현재 사용자가 벙에 참여할 수 있는지 확인
  bool canCurrentUserJoinEvent(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (event == null || currentUser == null) return false;

    // 이미 참여 중이거나 대기 중인 경우
    if (event.isParticipant(currentUser.id) || event.isWaiting(currentUser.id)) {
      return false;
    }

    // 취소되거나 완료된 벙
    if (event.isCancelled || event.isCompleted) {
      return false;
    }

    // 주최자는 참여할 수 없음
    if (event.isOrganizer(currentUser.id)) {
      return false;
    }

    return true;
  }

  /// 현재 사용자가 벙에서 나갈 수 있는지 확인
  bool canCurrentUserLeaveEvent(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (event == null || currentUser == null) return false;

    // 주최자는 나갈 수 없음
    if (event.isOrganizer(currentUser.id)) {
      return false;
    }

    // 참여 중이거나 대기 중인 경우만 나갈 수 있음
    return event.isParticipant(currentUser.id) || event.isWaiting(currentUser.id);
  }

  /// 현재 사용자가 벙을 관리할 수 있는지 확인
  bool canCurrentUserManageEvent(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (event == null || currentUser == null) return false;

    // 주최자만 관리 가능
    if (!event.isOrganizer(currentUser.id)) {
      return false;
    }

    // 취소되거나 완료된 벙은 관리 불가
    return !event.isCancelled && !event.isCompleted;
  }

  /// 벙 참여자 목록 가져오기 (사용자 정보 포함)
  List<String> getEventParticipants(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.participantIds ?? [];
  }

  /// 벙 대기자 목록 가져오기 (사용자 정보 포함)
  List<String> getEventWaitingList(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.waitingIds ?? [];
  }

  /// 벙 참여자 수 가져오기
  int getEventParticipantCount(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.totalParticipants ?? 0;
  }

  /// 벙 대기자 수 가져오기
  int getEventWaitingCount(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.totalWaiting ?? 0;
  }

  /// 벙 최대 인원 가져오기
  int getEventMaxParticipants(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.maxParticipants ?? 0;
  }

  /// 벙 남은 자리 수 가져오기
  int getEventAvailableSlots(WidgetRef ref, String eventId) {
    final event = ref.watch(eventProvider(eventId)).valueOrNull;
    return event?.availableSlots ?? 0;
  }

  /// 벙이 가득 찼는지 확인
  bool isEventFull(WidgetRef ref, String eventId) {
    final event = ref.watch(eventProvider(eventId)).valueOrNull;
    return event?.isFull ?? false;
  }

  /// 벙에 대기자가 있는지 확인
  bool hasEventWaitingList(WidgetRef ref, String eventId) {
    final event = ref.watch(eventProvider(eventId)).valueOrNull;
    return event?.hasWaitingList ?? false;
  }

  /// 벙이 정산이 필요한지 확인
  bool doesEventRequireSettlement(WidgetRef ref, String eventId) {
    final event = ref.watch(eventProvider(eventId)).valueOrNull;
    return event?.requiresSettlement ?? false;
  }

  /// 벙 상태 표시명 가져오기
  String getEventStatusDisplayName(WidgetRef ref, String eventId) {
    final event = ref.watch(eventProvider(eventId)).valueOrNull;
    return event?.displayStatus ?? '알 수 없음';
  }

  /// 벙 참여 정보 가져오기 (예: "5/10명")
  String getEventParticipationInfo(WidgetRef ref, String eventId) {
    final event = ref.watch(eventProvider(eventId)).valueOrNull;
    return event?.participationInfo ?? '0/0명';
  }

  /// 벙까지 남은 일수 가져오기
  int getEventDaysUntil(WidgetRef ref, String eventId) {
    final event = ref.watch(eventProvider(eventId)).valueOrNull;
    return event?.daysUntilEvent ?? 0;
  }

  /// 벙이 오늘인지 확인
  bool isEventToday(WidgetRef ref, String eventId) {
    final event = ref.watch(eventProvider(eventId)).valueOrNull;
    return event?.isToday ?? false;
  }

  /// 벙 일정 정보 가져오기
  DateTime? getEventScheduledAt(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.scheduledAt;
  }

  /// 벙 장소 정보 가져오기
  String getEventLocation(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.location ?? '';
  }

  /// 벙 제목 가져오기
  String getEventTitle(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.title ?? '';
  }

  /// 벙 설명 가져오기
  String getEventDescription(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.description ?? '';
  }

  /// 벙 주최자 ID 가져오기
  String getEventOrganizerId(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.organizerId ?? '';
  }

  /// 벙 생성일 가져오기
  DateTime? getEventCreatedAt(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.createdAt;
  }

  /// 벙 수정일 가져오기
  DateTime? getEventUpdatedAt(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    return event?.updatedAt;
  }

  /// 벙 상태별 스타일 정보 가져오기
  EventDetailStyle getEventStatusStyle(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    if (event == null) {
      return const EventDetailStyle(
        color: Colors.grey,
        backgroundColor: Colors.grey,
        text: '알 수 없음',
      );
    }

    switch (event.status) {
      case EventStatus.scheduled:
        return const EventDetailStyle(
          color: Colors.blue,
          backgroundColor: Colors.blue,
          text: '예정됨',
        );
      case EventStatus.closed:
        return const EventDetailStyle(
          color: Colors.orange,
          backgroundColor: Colors.orange,
          text: '마감됨',
        );
      case EventStatus.ongoing:
        return const EventDetailStyle(
          color: Colors.green,
          backgroundColor: Colors.green,
          text: '진행중',
        );
      case EventStatus.settlement:
        return const EventDetailStyle(
          color: Colors.purple,
          backgroundColor: Colors.purple,
          text: '정산중',
        );
      case EventStatus.completed:
        return const EventDetailStyle(
          color: Colors.grey,
          backgroundColor: Colors.grey,
          text: '완료됨',
        );
      case EventStatus.cancelled:
        return const EventDetailStyle(
          color: Colors.red,
          backgroundColor: Colors.red,
          text: '취소됨',
        );
    }
  }

  /// 현재 사용자의 벙 참여 상태 가져오기
  EventParticipationStatus getCurrentUserParticipationStatus(WidgetRef ref) {
    final event = getCurrentEventDetail(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (event == null || currentUser == null) {
      return EventParticipationStatus.notParticipating;
    }

    if (event.isOrganizer(currentUser.id)) {
      return EventParticipationStatus.organizer;
    } else if (event.isParticipant(currentUser.id)) {
      return EventParticipationStatus.participating;
    } else if (event.isWaiting(currentUser.id)) {
      return EventParticipationStatus.waiting;
    } else {
      return EventParticipationStatus.notParticipating;
    }
  }
}

/// 벙 상세 화면 스타일 정보
class EventDetailStyle {
  final Color color;
  final Color backgroundColor;
  final String text;

  const EventDetailStyle({
    required this.color,
    required this.backgroundColor,
    required this.text,
  });
}

/// 사용자의 벙 참여 상태
enum EventParticipationStatus {
  organizer, // 주최자
  participating, // 참여중
  waiting, // 대기중
  notParticipating, // 참여하지 않음
}
