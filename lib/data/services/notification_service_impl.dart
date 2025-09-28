// ignore_for_file: prefer_const_declarations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/data/services/notification_service.dart';
import 'package:our_bung_play/domain/entities/channel_entity.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/notification_entity.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';

class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FirebaseFirestore _firestore;
  final Dio _dio;

  NotificationServiceImpl({
    FirebaseMessaging? firebaseMessaging,
    FirebaseFirestore? firestore,
    Dio? dio,
  })  : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _dio = dio ?? Dio();

  @override
  Future<void> initialize() async {
    try {
      // Request permissions
      await requestPermissions();

      // Get initial token
      final token = await getFCMToken();
      if (token != null) {
        Logger.info('FCM Token obtained: ${token.substring(0, 20)}...');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        Logger.info('FCM Token refreshed');
        _updateUserFCMToken(token);
      });
    } catch (e) {
      Logger.error('Failed to initialize notification service: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      Logger.error('Failed to get FCM token: $e');
      return null;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      Logger.error('Failed to request notification permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      Logger.error('Failed to check notification settings: $e');
      return false;
    }
  }

  @override
  Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get FCM tokens for users
      final tokens = await _getUserFCMTokens(userIds);

      if (tokens.isEmpty) {
        Logger.warning('No FCM tokens found for users: $userIds');
        return;
      }

      // Create notification payload
      final payload = {
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data ?? {},
        'registration_ids': tokens,
      };

      // Send via FCM HTTP API (requires server key)
      await _sendFCMMessage(payload);

      // Save notification to Firestore
      await _saveNotificationToFirestore(
        recipientIds: userIds,
        title: title,
        message: body,
        data: data ?? {},
        type: _getNotificationTypeFromData(data),
      );
    } catch (e) {
      Logger.error('Failed to send notification to users: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendNotificationToChannel({
    required String channelId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get channel members
      final channel = await _getChannel(channelId);
      if (channel == null) {
        Logger.warning('Channel not found: $channelId');
        return;
      }

      final memberIds = channel.activeMembers.map((member) => member.userId).toList();
      if (memberIds.isEmpty) {
        Logger.warning('No active members found in channel: $channelId');
        return;
      }

      // Send notification to all active members
      await sendNotificationToUsers(
        userIds: memberIds,
        title: title,
        body: body,
        data: {
          ...?data,
          'channelId': channelId,
        },
      );
    } catch (e) {
      Logger.error('Failed to send notification to channel: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendEventCreatedNotification(String channelId, EventEntity event) async {
    try {
      final title = '새로운 벙이 생성되었습니다!';
      final body = '${event.title} - ${_formatDateTime(event.scheduledAt)}';

      await sendNotificationToChannel(
        channelId: channelId,
        title: title,
        body: body,
        data: {
          'type': NotificationType.eventCreated.name,
          'eventId': event.id,
          'channelId': channelId,
        },
      );
    } catch (e) {
      Logger.error('Failed to send event created notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendAnnouncementNotification(String channelId, String message) async {
    try {
      final title = '공지사항';

      await sendNotificationToChannel(
        channelId: channelId,
        title: title,
        body: message,
        data: {
          'type': NotificationType.announcement.name,
          'channelId': channelId,
        },
      );
    } catch (e) {
      Logger.error('Failed to send announcement notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendSettlementNotification(String eventId, SettlementEntity settlement) async {
    try {
      final event = await _getEvent(eventId);
      if (event == null) {
        Logger.warning('Event not found: $eventId');
        return;
      }

      final title = '정산이 생성되었습니다';
      final body = '${event.title} - 총 ${settlement.totalAmount.toInt()}원';

      await sendNotificationToUsers(
        userIds: event.participantIds,
        title: title,
        body: body,
        data: {
          'type': NotificationType.settlementCreated.name,
          'eventId': eventId,
          'settlementId': settlement.id,
        },
      );
    } catch (e) {
      Logger.error('Failed to send settlement notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendEventUpdateNotification(String eventId, String message) async {
    try {
      final event = await _getEvent(eventId);
      if (event == null) {
        Logger.warning('Event not found: $eventId');
        return;
      }

      final title = '벙 정보가 변경되었습니다';
      final body = '${event.title} - $message';

      await sendNotificationToUsers(
        userIds: event.participantIds,
        title: title,
        body: body,
        data: {
          'type': NotificationType.eventUpdated.name,
          'eventId': eventId,
        },
      );
    } catch (e) {
      Logger.error('Failed to send event update notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendEventJoinedNotification(String eventId, String participantName) async {
    try {
      final event = await _getEvent(eventId);
      if (event == null) {
        Logger.warning('Event not found: $eventId');
        return;
      }

      final title = '새로운 참여자가 있습니다!';
      final body = '$participantName님이 ${event.title}에 참여했습니다';

      await sendNotificationToUsers(
        userIds: [event.organizerId],
        title: title,
        body: body,
        data: {
          'type': NotificationType.eventJoined.name,
          'eventId': eventId,
        },
      );
    } catch (e) {
      Logger.error('Failed to send event joined notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendEventLeftNotification(String eventId, String participantName) async {
    try {
      final event = await _getEvent(eventId);
      if (event == null) {
        Logger.warning('Event not found: $eventId');
        return;
      }

      final title = '참여 취소 알림';
      final body = '$participantName님이 ${event.title} 참여를 취소했습니다';

      await sendNotificationToUsers(
        userIds: [event.organizerId],
        title: title,
        body: body,
        data: {
          'type': NotificationType.eventLeft.name,
          'eventId': eventId,
        },
      );
    } catch (e) {
      Logger.error('Failed to send event left notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendEventCancelledNotification(String eventId, String eventTitle) async {
    try {
      final event = await _getEvent(eventId);
      if (event == null) {
        Logger.warning('Event not found: $eventId');
        return;
      }

      final title = '벙이 취소되었습니다';
      final body = '$eventTitle이(가) 취소되었습니다';

      await sendNotificationToUsers(
        userIds: event.participantIds,
        title: title,
        body: body,
        data: {
          'type': NotificationType.eventCancelled.name,
          'eventId': eventId,
        },
      );
    } catch (e) {
      Logger.error('Failed to send event cancelled notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendPaymentReceivedNotification(String settlementId, String participantName) async {
    try {
      final settlement = await _getSettlement(settlementId);
      if (settlement == null) {
        Logger.warning('Settlement not found: $settlementId');
        return;
      }

      const title = '입금 완료 알림';
      final body = '$participantName님이 입금을 완료했습니다';

      await sendNotificationToUsers(
        userIds: [settlement.organizerId],
        title: title,
        body: body,
        data: {
          'type': NotificationType.paymentReceived.name,
          'settlementId': settlementId,
        },
      );
    } catch (e) {
      Logger.error('Failed to send payment received notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendRuleUpdateNotification(String message) async {
    try {
      // TODO: Get current channel ID from context
      const channelId = 'current_channel_id';

      const title = '회칙 업데이트';

      await sendNotificationToChannel(
        channelId: channelId,
        title: title,
        body: message,
        data: {
          'type': NotificationType.announcement.name,
          'channelId': channelId,
          'category': 'rule_update',
        },
      );
    } catch (e) {
      Logger.error('Failed to send rule update notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      Logger.info('Subscribed to topic: $topic');
    } catch (e) {
      Logger.error('Failed to subscribe to topic $topic: $e');
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      Logger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      Logger.error('Failed to unsubscribe from topic $topic: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<List<String>> _getUserFCMTokens(List<String> userIds) async {
    try {
      final tokens = <String>[];

      for (final userId in userIds) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final fcmToken = userDoc.data()?['fcmToken'] as String?;
          if (fcmToken != null && fcmToken.isNotEmpty) {
            tokens.add(fcmToken);
          }
        }
      }

      return tokens;
    } catch (e) {
      Logger.error('Failed to get user FCM tokens: $e');
      return [];
    }
  }

  Future<void> _updateUserFCMToken(String token) async {
    try {
      // This would need current user ID from auth service
      // For now, we'll skip this implementation
      Logger.info('FCM token updated: ${token.substring(0, 20)}...');
    } catch (e) {
      Logger.error('Failed to update user FCM token: $e');
    }
  }

  Future<void> _sendFCMMessage(Map<String, dynamic> payload) async {
    try {
      // This would require FCM server key and HTTP API call
      // For now, we'll use Firebase Admin SDK or Cloud Functions
      // This is a placeholder for the actual implementation
      Logger.info('FCM message sent to ${payload['registration_ids']?.length ?? 0} devices');
    } catch (e) {
      Logger.error('Failed to send FCM message: $e');
      rethrow;
    }
  }

  Future<void> _saveNotificationToFirestore({
    required List<String> recipientIds,
    required String title,
    required String message,
    required Map<String, dynamic> data,
    required NotificationType type,
  }) async {
    try {
      final notification = NotificationEntity(
        id: _firestore.collection('notifications').doc().id,
        channelId: data['channelId'] ?? '',
        recipientIds: recipientIds,
        type: type,
        title: title,
        message: message,
        data: data,
        status: NotificationStatus.sent,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').doc(notification.id).set(notification.toJson());
    } catch (e) {
      Logger.error('Failed to save notification to Firestore: $e');
    }
  }

  Future<ChannelEntity?> _getChannel(String channelId) async {
    try {
      final doc = await _firestore.collection('channels').doc(channelId).get();
      if (doc.exists) {
        return ChannelEntity.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get channel: $e');
      return null;
    }
  }

  Future<EventEntity?> _getEvent(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventEntity.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get event: $e');
      return null;
    }
  }

  Future<SettlementEntity?> _getSettlement(String settlementId) async {
    try {
      final doc = await _firestore.collection('settlements').doc(settlementId).get();
      if (doc.exists) {
        return SettlementEntity.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get settlement: $e');
      return null;
    }
  }

  NotificationType _getNotificationTypeFromData(Map<String, dynamic>? data) {
    if (data == null || !data.containsKey('type')) {
      return NotificationType.announcement;
    }

    try {
      return NotificationType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => NotificationType.announcement,
      );
    } catch (e) {
      return NotificationType.announcement;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
