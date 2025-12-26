import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local notification service for scheduling event reminders
/// Unlike FCM push notifications, local notifications work offline
/// and can be scheduled in advance for precise timing
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // We request via FCM
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      _isInitialized = true;
      Logger.info('Local notification service initialized');
    } catch (e) {
      Logger.error('Failed to initialize local notifications: $e');
      rethrow;
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'event_reminders',
      '벙 리마인더',
      description: '벙 시작 전 알림',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    Logger.info('Local notification tapped: ${response.payload}');
    // Navigation will be handled by the app based on payload
  }

  /// Schedule event reminder (30 minutes before event)
  Future<void> scheduleEventReminder({
    required String eventId,
    required String eventTitle,
    required DateTime scheduledAt,
    int minutesBefore = 30,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final reminderTime = scheduledAt.subtract(Duration(minutes: minutesBefore));

      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(DateTime.now())) {
        Logger.info('Reminder time is in the past, skipping: $eventId');
        return;
      }

      final notificationId = eventId.hashCode;

      await _notifications.zonedSchedule(
        notificationId,
        '벙이 곧 시작됩니다! ⏰',
        '$eventTitle - $minutesBefore분 전',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminders',
            '벙 리마인더',
            channelDescription: '벙 시작 전 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'eventId:$eventId',
      );

      Logger.info('Scheduled reminder for event $eventId at $reminderTime');
    } catch (e) {
      Logger.error('Failed to schedule event reminder: $e');
      rethrow;
    }
  }

  /// Cancel event reminder
  Future<void> cancelEventReminder(String eventId) async {
    if (!_isInitialized) await initialize();

    try {
      final notificationId = eventId.hashCode;
      await _notifications.cancel(notificationId);
      Logger.info('Cancelled reminder for event: $eventId');
    } catch (e) {
      Logger.error('Failed to cancel event reminder: $e');
      rethrow;
    }
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancelAll();
      Logger.info('Cancelled all reminders');
    } catch (e) {
      Logger.error('Failed to cancel all reminders: $e');
      rethrow;
    }
  }

  /// Show immediate notification (for testing)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminders',
            '벙 리마인더',
            channelDescription: '벙 시작 전 알림',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      Logger.error('Failed to show notification: $e');
      rethrow;
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) await initialize();
    return await _notifications.pendingNotificationRequests();
  }
}
