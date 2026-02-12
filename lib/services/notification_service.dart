import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Laundry Notifications',
      channelDescription: 'Notifications for laundry app',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> showWashCompleteNotification(String machineId) async {
    await showNotification(
      title: 'Laundry Ready!',
      body: 'Your laundry is done on Machine $machineId. Tap to collect.',
    );
  }

  Future<void> showYourTurnNotification(String machineId) async {
    await showNotification(
      title: "You're Next!",
      body: 'Scan the QR code on Machine $machineId within 5 minutes.',
    );
  }

  Future<void> showTimeExpiredNotification() async {
    await showNotification(
      title: 'Time Expired',
      body: 'You didn\'t scan in time. You\'ve been moved to the back of the queue.',
    );
  }
}
