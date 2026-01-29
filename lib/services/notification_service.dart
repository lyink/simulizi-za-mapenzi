import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level function for background message handler
/// This is required to be top-level to work when app is terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background notification
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Notification preferences keys
  static const String _prefKeyEnabled = 'notifications_enabled';
  static const String _prefKeyDailyTime = 'daily_notification_time';
  static const String _prefKeyWeeklyDay = 'weekly_notification_day';

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize Firebase Messaging
    await _initializeFirebaseMessaging();

    // Schedule default daily notifications if enabled
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefKeyEnabled) ?? true;
    if (enabled) {
      await scheduleDailyNotification();
    }

    _isInitialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request iOS permissions
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permissions: ${settings.authorizationStatus}');

    // Request Android 13+ notification permissions
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        // TODO: Send token to backend if you have one
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app was terminated
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Failed to initialize Firebase Messaging: $e');
      debugPrint('App will continue without push notifications');
      // Continue app execution even if FCM fails
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    // Show local notification when app is in foreground
    if (message.notification != null) {
      _showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'New Story',
        body: message.notification!.body ?? 'Check out the latest story!',
        payload: message.data['route'] ?? '/stories',
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    // Navigate to specific screen based on data
    // This will be handled by your app's navigation
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Show a local notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'love_stories_channel',
      'Love Stories',
      channelDescription: 'Notifications for new love stories',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({int hour = 18, int minute = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyDailyTime, '$hour:$minute');

    // Cancel existing daily notification
    await _localNotifications.cancel(0);

    // Schedule new daily notification
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily reading reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.zonedSchedule(
      0, // Daily notification ID
      'Time to Read! 📖',
      'Discover a beautiful love story today',
      scheduledDate,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Daily notification scheduled for ${scheduledDate.hour}:${scheduledDate.minute}');
  }

  /// Schedule weekly notification
  Future<void> scheduleWeeklyNotification({
    required int weekday, // 1 = Monday, 7 = Sunday
    int hour = 10,
    int minute = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyWeeklyDay, weekday);

    // Cancel existing weekly notification
    await _localNotifications.cancel(1);

    // Calculate next occurrence
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = _nextInstanceOfWeekday(weekday, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    const androidDetails = AndroidNotificationDetails(
      'weekly_reminder_channel',
      'Weekly Reminders',
      channelDescription: 'Weekly reading reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.zonedSchedule(
      1, // Weekly notification ID
      'New Stories Awaiting! 💕',
      'Check out this week\'s featured love stories',
      scheduledDate,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    debugPrint('Weekly notification scheduled for weekday $weekday at $hour:$minute');
  }

  /// Calculate next instance of a weekday
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Send instant notification
  Future<void> sendInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, enabled);

    if (enabled) {
      await scheduleDailyNotification();
    } else {
      await cancelAllNotifications();
    }
  }

  /// Get notification settings
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyEnabled) ?? true;
  }

  /// Get daily notification time
  Future<Map<String, int>> getDailyNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_prefKeyDailyTime) ?? '18:0';
    final parts = timeString.split(':');
    return {
      'hour': int.parse(parts[0]),
      'minute': int.parse(parts[1]),
    };
  }

  /// Get FCM token for backend
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to topic (for broadcasting to all users)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Send notification for new story
  Future<void> notifyNewStory({
    required String storyTitle,
    required String storyAuthor,
    String? storyId,
  }) async {
    await sendInstantNotification(
      title: '📚 New Story Available!',
      body: '"$storyTitle" by $storyAuthor is now available to read',
      payload: storyId != null ? 'story:$storyId' : null,
    );
  }

  /// Send batch notification for multiple new stories
  Future<void> notifyMultipleNewStories(int count) async {
    await sendInstantNotification(
      title: '🎉 $count New Stories!',
      body: 'Discover $count new love stories waiting for you',
      payload: 'stories:new',
    );
  }

  /// Schedule random reading reminder (for existing stories)
  Future<void> scheduleReadingReminder({
    int hour = 19,
    int minute = 0,
  }) async {
    // Cancel existing reading reminder
    await _localNotifications.cancel(2);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'reading_reminder_channel',
      'Reading Reminders',
      channelDescription: 'Reminders to read your favorite stories',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final messages = [
      'Time for a romantic story! 💕',
      'Discover a love story today 📖',
      'Your stories are waiting for you ❤️',
      'Dive into a beautiful tale 🌹',
      'A world of romance awaits 💫',
    ];

    final randomMessage = (messages..shuffle()).first;

    await _localNotifications.zonedSchedule(
      2, // Reading reminder ID
      'Reading Time! 📚',
      randomMessage,
      scheduledDate,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('📚 Reading reminder scheduled for ${scheduledDate.hour}:${scheduledDate.minute}');
  }

  /// Enable reading reminders for existing stories
  Future<void> enableReadingReminders({
    int hour = 19,
    int minute = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reading_reminders_enabled', true);
    await scheduleReadingReminder(hour: hour, minute: minute);
  }

  /// Disable reading reminders
  Future<void> disableReadingReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reading_reminders_enabled', false);
    await _localNotifications.cancel(2);
  }

  /// Check if reading reminders are enabled
  Future<bool> areReadingRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reading_reminders_enabled') ?? true;
  }
}
