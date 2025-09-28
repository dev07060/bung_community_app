import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../services/notification_service.dart';
import '../../core/enums/app_enums.dart';
import '../../core/utils/logger.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({
    required NotificationService notificationService,
    FirebaseFirestore? firestore,
  }) : _notificationService = notificationService,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> sendEventCreatedNotification(String channelId, EventEntity event) async {
    try {
      await _notificationService.sendEventCreatedNotification(channelId, event);
    } catch (e) {
      Logger.error('Failed to send event created notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendAnnouncementNotification(String channelId, String message) async {
    try {
      await _notificationService.sendAnnouncementNotification(channelId, message);
    } catch (e) {
      Logger.error('Failed to send announcement notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendSettlementNotification(String eventId, SettlementEntity settlement) async {
    try {
      await _notificationService.sendSettlementNotification(eventId, settlement);
    } catch (e) {
      Logger.error('Failed to send settlement notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendEventUpdateNotification(String eventId, String message) async {
    try {
      await _notificationService.sendEventUpdateNotification(eventId, message);
    } catch (e) {
      Logger.error('Failed to send event update notification: $e');
      rethrow;
    }
  }

  @override
  Future<List<NotificationEntity>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientIds', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationEntity.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      Logger.error('Failed to get user notifications: $e');
      return [];
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
            'status': NotificationStatus.read.name,
          });
    } catch (e) {
      Logger.error('Failed to mark notification as read: $e');
      rethrow;
    }
  }
}