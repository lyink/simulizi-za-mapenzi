import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by this point via main()
  final notificationService = NotificationService();
  await notificationService._showLocalNotification(
    title: message.notification?.title ?? 'Hadithi Mpya!',
    body: message.notification?.body ?? 'Kuna hadithi mpya inakungojea.',
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _newBookTopic = 'new_books';
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'new_books_channel',
    'New Books',
    description: 'Notifications for newly added books',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _localNotifications.initialize(initSettings);

    // Create notification channel for Android
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    // Subscribe to topic for new books
    await _fcm.subscribeToTopic(_newBookTopic);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Hadithi Mpya!',
        body: message.notification?.body ?? 'Kuna hadithi mpya inakungojea.',
      );
    });

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'new_books_channel',
      'New Books',
      channelDescription: 'Notifications for newly added books',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Call this when a new book is published to send notification to all subscribers
  Future<void> sendNewBookNotification({
    required String bookTitle,
    required String bookSynopsis,
  }) async {
    // This sends via FCM topic - call from admin or backend
    // For client-side trigger we show a local notification
    await _showLocalNotification(
      title: 'Hadithi Mpya: $bookTitle',
      body: bookSynopsis,
    );
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
