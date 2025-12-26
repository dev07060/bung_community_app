import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';

part 'event_entity.freezed.dart';
part 'event_entity.g.dart';

@freezed
class EventEntity with _$EventEntity {
  const factory EventEntity({
    required String id,
    required String channelId,
    required String organizerId,
    required String title,
    required String description,
    required DateTime scheduledAt,
    required String location,
    required int maxParticipants,
    required List<String> participantIds,
    required List<String> waitingIds,
    @Default(EventStatus.scheduled) EventStatus status,
    @Default(false) bool requiresSettlement,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EventEntity;

  const EventEntity._();

  factory EventEntity.fromJson(Map<String, dynamic> json) => _$EventEntityFromJson(json);

  // Validation methods
  bool get isValid =>
      id.isNotEmpty &&
      channelId.isNotEmpty &&
      organizerId.isNotEmpty &&
      title.isNotEmpty &&
      location.isNotEmpty &&
      maxParticipants > 0 &&
      scheduledAt.isAfter(DateTime.now());

  /// 현재 시간 기준으로 계산된 상태 (Lazy Evaluation)
  /// DB에 저장된 status는 주최자의 의도(예정/마감)를 보존하고,
  /// 실제 표시는 시간 기반으로 자동 계산
  EventStatus get computedStatus {
    // 최종 상태(완료/취소)는 그대로 반환
    if (status == EventStatus.completed || status == EventStatus.cancelled) {
      return status;
    }

    // 정산 중 상태도 그대로 반환
    if (status == EventStatus.settlement) {
      return status;
    }

    final now = DateTime.now();

    // 예정 시간이 지났으면 ongoing 표시
    if (scheduledAt.isBefore(now)) {
      return EventStatus.ongoing;
    }

    // 그 외는 저장된 상태 그대로
    return status;
  }

  // Status checks (computedStatus 기반)
  bool get isScheduled => computedStatus == EventStatus.scheduled;
  bool get isClosed => computedStatus == EventStatus.closed;
  bool get isOngoing => computedStatus == EventStatus.ongoing;
  bool get isCompleted => computedStatus == EventStatus.completed;
  bool get isCancelled => computedStatus == EventStatus.cancelled;

  // Participation checks
  bool get isFull => participantIds.length >= maxParticipants;
  bool get hasWaitingList => waitingIds.isNotEmpty;
  int get availableSlots => maxParticipants - participantIds.length;
  int get totalParticipants => participantIds.length;
  int get totalWaiting => waitingIds.length;

  bool isParticipant(String userId) => participantIds.contains(userId);
  bool isWaiting(String userId) => waitingIds.contains(userId);
  bool isOrganizer(String userId) => organizerId == userId;

  // Time calculations
  Duration get timeUntilEvent => scheduledAt.difference(DateTime.now());
  int get daysUntilEvent => timeUntilEvent.inDays;
  bool get isToday =>
      scheduledAt.year == DateTime.now().year &&
      scheduledAt.month == DateTime.now().month &&
      scheduledAt.day == DateTime.now().day;

  String get displayStatus => computedStatus.displayName;
  String get participationInfo => '$totalParticipants/$maxParticipants명';
}
