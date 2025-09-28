import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/notification_entity.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';

abstract class NotificationRepository {
  Future<void> sendEventCreatedNotification(String channelId, EventEntity event);
  Future<void> sendAnnouncementNotification(String channelId, String message);
  Future<void> sendSettlementNotification(String eventId, SettlementEntity settlement);
  Future<void> sendEventUpdateNotification(String eventId, String message);
  Future<List<NotificationEntity>> getUserNotifications(String userId);
  Future<void> markNotificationAsRead(String notificationId);
}
