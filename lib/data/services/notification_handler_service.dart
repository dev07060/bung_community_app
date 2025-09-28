import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/providers/global_providers.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';

/// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.info('Handling background message: ${message.messageId}');

  // Handle background message processing here
  await NotificationHandlerService.handleBackgroundMessage(message);
}

class NotificationHandlerService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static BuildContext? _navigatorContext;

  /// Initialize notification handling
  static Future<void> initialize() async {
    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      Logger.info('Notification handler initialized');
    } catch (e) {
      Logger.error('Failed to initialize notification handler: $e');
      rethrow;
    }
  }

  /// Set navigator context for navigation
  static void setNavigatorContext(BuildContext context) {
    _navigatorContext = context;
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      Logger.info('Received foreground message: ${message.messageId}');

      // Check if user has notifications enabled
      final isEnabled = await _areNotificationsEnabled();
      if (!isEnabled) {
        Logger.info('Notifications disabled by user, skipping');
        return;
      }

      // Show in-app notification or update UI
      await _showInAppNotification(message);

      // Update relevant providers
      await _updateProvidersForMessage(message);
    } catch (e) {
      Logger.error('Failed to handle foreground message: $e');
    }
  }

  /// Handle notification tap
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    try {
      Logger.info('Notification tapped: ${message.messageId}');

      // Navigate to relevant screen based on notification type
      await _navigateToScreen(message);

      // Update relevant providers
      await _updateProvidersForMessage(message);
    } catch (e) {
      Logger.error('Failed to handle notification tap: $e');
    }
  }

  /// Handle background message
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    try {
      Logger.info('Handling background message: ${message.messageId}');

      // Update local storage or cache if needed
      await _updateLocalDataForMessage(message);
    } catch (e) {
      Logger.error('Failed to handle background message: $e');
    }
  }

  /// Show in-app notification
  static Future<void> _showInAppNotification(RemoteMessage message) async {
    try {
      if (_navigatorContext == null) return;

      final notification = message.notification;
      if (notification == null) return;

      // Show snackbar or overlay notification
      ScaffoldMessenger.of(_navigatorContext!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (notification.body != null) Text(notification.body!, style: const TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(label: '보기', textColor: Colors.white, onPressed: () => _navigateToScreen(message)),
        ),
      );
    } catch (e) {
      Logger.error('Failed to show in-app notification: $e');
    }
  }

  /// Navigate to relevant screen based on notification data
  static Future<void> _navigateToScreen(RemoteMessage message) async {
    try {
      if (_navigatorContext == null) return;

      final data = message.data;
      final type = _getNotificationTypeFromData(data);

      switch (type) {
        case NotificationType.eventCreated:
        case NotificationType.eventUpdated:
        case NotificationType.eventJoined:
        case NotificationType.eventLeft:
          final eventId = data['eventId'];
          if (eventId != null) {
            _navigatorContext!.push('/event-detail/$eventId');
          }
          break;

        case NotificationType.eventCancelled:
          // Navigate to event list or home
          _navigatorContext!.push('/events');
          break;

        case NotificationType.settlementCreated:
        case NotificationType.paymentReceived:
          final settlementId = data['settlementId'];
          final eventId = data['eventId'];
          if (settlementId != null) {
            _navigatorContext!.push('/settlement-detail/$settlementId');
          } else if (eventId != null) {
            _navigatorContext!.push('/event-detail/$eventId');
          }
          break;

        case NotificationType.announcement:
          final channelId = data['channelId'];
          if (channelId != null) {
            _navigatorContext!.push('/channel/$channelId/announcements');
          }
          break;

        case NotificationType.memberJoined:
        case NotificationType.memberLeft:
          // Navigate to member management if user is admin
          final channelId = data['channelId'];
          if (channelId != null) {
            _navigatorContext!.push('/channel/$channelId/members');
          }
          break;
      }
    } catch (e) {
      Logger.error('Failed to navigate to screen: $e');
    }
  }

  /// Update providers based on message content
  static Future<void> _updateProvidersForMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      final type = _getNotificationTypeFromData(data);

      switch (type) {
        case NotificationType.eventCreated:
        case NotificationType.eventUpdated:
        case NotificationType.eventJoined:
        case NotificationType.eventLeft:
        case NotificationType.eventCancelled:
          // Invalidate event providers to trigger refresh
          final eventId = data['eventId'];
          if (eventId != null) {
            globalContainer.invalidate(eventProvider(eventId));
          }

          // Invalidate event lists
          globalContainer.invalidate(userEventsProvider);
          final channelId = data['channelId'];
          if (channelId != null) {
            globalContainer.invalidate(channelEventsProvider(channelId));
          }
          break;

        case NotificationType.settlementCreated:
        case NotificationType.paymentReceived:
          // Invalidate settlement providers
          final settlementId = data['settlementId'];
          final eventId = data['eventId'];

          if (settlementId != null) {
            globalContainer.invalidate(settlementProvider(settlementId));
          }

          if (eventId != null) {
            globalContainer.invalidate(eventSettlementProvider(eventId));
          }
          break;

        case NotificationType.announcement:
        case NotificationType.memberJoined:
        case NotificationType.memberLeft:
          // Invalidate channel-related providers if needed
          final channelId = data['channelId'];
          if (channelId != null) {
            // Invalidate channel providers when they exist
            Logger.info('Invalidating channel providers for: $channelId');
          }
          break;
      }
    } catch (e) {
      Logger.error('Failed to update providers for message: $e');
    }
  }

  /// Update local data for background message
  static Future<void> _updateLocalDataForMessage(RemoteMessage message) async {
    try {
      // This could involve updating local cache, Hive storage, etc.
      // For now, we'll just log the message
      Logger.info('Updating local data for message: ${message.data}');
    } catch (e) {
      Logger.error('Failed to update local data: $e');
    }
  }

  /// Check if notifications are enabled by user
  static Future<bool> _areNotificationsEnabled() async {
    try {
      // Check user preferences from providers
      final authState = GlobalProviderAccess.read(authStateProvider);

      if (authState.hasValue && authState.value != null) {
        // Check user's notification preferences
        // For now, return true if user is authenticated
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to check notification settings: $e');
      return false;
    }
  }

  /// Get notification type from message data
  static NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    if (!data.containsKey('type')) {
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
}
