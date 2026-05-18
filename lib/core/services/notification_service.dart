import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> showBudgetAlert({
    required double currentTotal,
    required double limit,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      AppConstants.budgetChannelId,
      AppConstants.budgetChannelName,
      channelDescription: 'Alerts when monthly expenses exceed budget',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Budget Alert',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Budget exceeded',
      'You\'ve crossed ₹${limit.toStringAsFixed(0)} this month — '
          'current spending is ₹${currentTotal.toStringAsFixed(2)}.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
