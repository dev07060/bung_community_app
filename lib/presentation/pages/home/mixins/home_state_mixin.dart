import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/user_entity.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';

/// 홈 페이지에서 사용되는 상태를 참조하는 Mixin Class
mixin class HomeStateMixin {
  /// 사용자의 참여 벙 목록 가져오기 (참여 중이거나 대기 중인 벙)
  AsyncValue<List<EventEntity>> getMyParticipatingEvents(WidgetRef ref) {
    final userEventsAsync = ref.watch(userEventsProvider);
    return userEventsAsync.when(
      data: (events) {
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null) return const AsyncValue.data(<EventEntity>[]);

        final participatingEvents =
            events.where((event) => event.isParticipant(currentUser.id) || event.isWaiting(currentUser.id)).toList();

        // 시간순 정렬 (가까운 일정부터)
        participatingEvents.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        return AsyncValue.data(participatingEvents);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }

  /// 사용자가 개설한 벙 목록 가져오기
  AsyncValue<List<EventEntity>> getMyOrganizedEvents(WidgetRef ref) {
    final userEventsAsync = ref.watch(userEventsProvider);
    return userEventsAsync.when(
      data: (events) {
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null) return const AsyncValue.data(<EventEntity>[]);

        final organizedEvents = events.where((event) => event.isOrganizer(currentUser.id)).toList();

        // 시간순 정렬 (가까운 일정부터)
        organizedEvents.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        return AsyncValue.data(organizedEvents);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }

  /// 현재 사용자 정보 가져오기
  UserEntity? getCurrentUser(WidgetRef ref) {
    return ref.watch(currentUserProvider);
  }

  /// 전체 사용자 벙 목록 로딩 상태 확인
  bool isLoading(WidgetRef ref) {
    final userEventsAsync = ref.watch(userEventsProvider);
    return userEventsAsync.isLoading;
  }

  /// 에러 상태 확인
  String? getErrorMessage(WidgetRef ref) {
    final userEventsAsync = ref.watch(userEventsProvider);
    return userEventsAsync.hasError ? userEventsAsync.error.toString() : null;
  }

  /// 상태별 벙 필터링
  List<EventEntity> filterEventsByStatus(List<EventEntity> events, EventStatus? status) {
    if (status == null) return events;
    return events.where((event) => event.status == status).toList();
  }

  /// 예정된 벙만 필터링
  List<EventEntity> getUpcomingEvents(List<EventEntity> events) {
    return events
        .where((event) => event.status == EventStatus.scheduled || event.status == EventStatus.closed)
        .toList();
  }

  /// 완료된 벙만 필터링
  List<EventEntity> getCompletedEvents(List<EventEntity> events) {
    return events.where((event) => event.status == EventStatus.completed).toList();
  }

  /// 취소된 벙만 필터링
  List<EventEntity> getCancelledEvents(List<EventEntity> events) {
    return events.where((event) => event.status == EventStatus.cancelled).toList();
  }
}
