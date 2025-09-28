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

  // Status checks
  bool get isScheduled => status == EventStatus.scheduled;
  bool get isClosed => status == EventStatus.closed;
  bool get isOngoing => status == EventStatus.ongoing;
  bool get isCompleted => status == EventStatus.completed;
  bool get isCancelled => status == EventStatus.cancelled;

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

  String get displayStatus => status.displayName;
  String get participationInfo => '$totalParticipants/$maxParticipants명';
}
