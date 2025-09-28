import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/enums/app_enums.dart';

part 'notification_entity.freezed.dart';
part 'notification_entity.g.dart';

@freezed
class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required String channelId,
    required List<String> recipientIds,
    required NotificationType type,
    required String title,
    required String message,
    required Map<String, dynamic> data,
    @Default(NotificationStatus.pending) NotificationStatus status,
    required DateTime createdAt,
  }) = _NotificationEntity;

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      _$NotificationEntityFromJson(json);
}