import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationConfig {
  static const notificationId = 1234;
  static const notificationChannelId = 'attendance_notification';
  static const notificationIcon = 'ic_bg_service_small';
  static const AndroidNotificationDetails androidNotifDetail =
      AndroidNotificationDetails(
    '${NotificationConfig.notificationId}',
    NotificationConfig.notificationChannelId,
    icon: NotificationConfig.notificationIcon,
    ongoing: true,
  );
  static const AndroidNotificationChannel androidChannel =
      AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high, // importance must be at low or higher level
  );
}
