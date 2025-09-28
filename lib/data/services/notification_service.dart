import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';

abstract class NotificationService {
  /// Initialize FCM and request permissions
  Future<void> initialize();

  /// Get FCM token for current device
  Future<String?> getFCMToken();

  /// Send notification to specific users
  Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// Send notification to all channel members
  Future<void> sendNotificationToChannel({
    required String channelId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// Send event created notification
  Future<void> sendEventCreatedNotification(String channelId, EventEntity event);

  /// Send announcement notification
  Future<void> sendAnnouncementNotification(String channelId, String message);

  /// Send settlement notification
  Future<void> sendSettlementNotification(String eventId, SettlementEntity settlement);

  /// Send event update notification
  Future<void> sendEventUpdateNotification(String eventId, String message);

  /// Send event joined notification to organizer
  Future<void> sendEventJoinedNotification(String eventId, String participantName);

  /// Send event left notification to organizer
  Future<void> sendEventLeftNotification(String eventId, String participantName);

  /// Send event cancelled notification to participants
  Future<void> sendEventCancelledNotification(String eventId, String eventTitle);

  /// Send payment received notification to organizer
  Future<void> sendPaymentReceivedNotification(String settlementId, String participantName);

  /// Send rule update notification to all channel members
  Future<void> sendRuleUpdateNotification(String message);

  /// Subscribe to notification topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from notification topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Request notification permissions
  Future<bool> requestPermissions();
}
