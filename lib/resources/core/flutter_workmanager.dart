import 'dart:async';
import 'dart:math';

import 'package:flutter_demo/resources/config/notification_config.dart';
import 'package:flutter_demo/resources/helpers/rgb_log_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask(
    (taskName, inputData) {
      final Completer<bool> completer = Completer();
      switch (taskName) {
        case WorkManager.notifTaskKey:
          NotificationManager().show();
          break;
        case WorkManager.periodicTaskKey:
          List endDateParam = inputData!['endDate'];
          var endDate = DateTime(
            endDateParam[0] as int,
            endDateParam[1] as int,
            endDateParam[2] as int,
            endDateParam[3] as int,
            endDateParam[4] as int,
          );
          Timer.periodic(const Duration(seconds: 10), (timer) {
            RGBLog.pink('trigger 1');
            var now = DateTime.now();
            NotificationManager().show();
            RGBLog.cyan('now: $now');
            RGBLog.cyan('end: $endDate');
            RGBLog.cyan('isAfter: ${now.isAfter(endDate)}');
            if (now.isAfter(endDate)) {
              RGBLog.pink('trigger 2');
              completer.complete(true);
              timer.cancel();
            }
          });
          break;
      }
      // inputData?['accessToken'];
      RGBLog.pink('trigger 3');

      return completer.future;
    },
  );
}

class WorkManager {
  static const notifTaskKey = "com.test.test.notifKey";
  static const periodicTaskKey = "com.test.test.periodicKey";

  stop() {
    Workmanager().cancelAll();
  }

  start() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  registerNotifTask({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    var now = DateTime.now();
    // var delay = now.difference(date);
    var delay = startDate.difference(now);
    Workmanager().registerOneOffTask(
      notifTaskKey,
      notifTaskKey,
      // outOfQuotaPolicy: OutOfQuotaPolicy.run_as_non_expedited_work_request,
      // existingWorkPolicy: ExistingWorkPolicy.replace,
      // constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: delay,
      // frequency: const Duration(hours: 24),
      inputData: {
        'accessToken': 'token here',
        'endDate': endDate,
      },
    );
  }

  registerPeriodicTask({
    required DateTime startDate,
    required DateTime endDate,
    int startEarlyByMinutes = 0,
  }) {
    var now = DateTime.now();
    var delay = startDate.difference(now);
    delay -= Duration(seconds: startEarlyByMinutes);
    Workmanager().registerPeriodicTask(
      periodicTaskKey,
      periodicTaskKey,
      initialDelay: delay,
      frequency: const Duration(hours: 24),
      inputData: {
        'accessToken': 'token here',
        'endDate': [
          endDate.year,
          endDate.month,
          endDate.day,
          endDate.hour,
          endDate.minute,
        ],
      },
    );
  }
}

class NotificationManager {
  show() {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.show(
      Random().nextInt(99999),
      'COOL SERVICE',
      'Awesome ${DateTime.now()}',
      const NotificationDetails(
        android: NotificationConfig.androidNotifDetail,
      ),
    );
  }
}
