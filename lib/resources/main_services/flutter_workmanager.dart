import 'dart:async';
import 'dart:math';

import 'package:flutter_demo/resources/config/notification_config.dart';
import 'package:flutter_demo/resources/helpers/rgb_log_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(
    (taskName, inputData) async {
      RGBLog.green('trigger background task');
      final Completer<bool> completer = Completer();
      switch (taskName) {
        case WorkManager.notifTaskKey:
          NotificationManager().show();
          break;
        case WorkManager.periodicTaskKey2:
          List endDateParam = inputData!['endDate'];
          var endDate = DateTime(
            endDateParam[0] as int,
            endDateParam[1] as int,
            endDateParam[2] as int,
            endDateParam[3] as int,
            endDateParam[4] as int,
          );
          // LocationSettings locationSettings = LocationSettings(
          //   accuracy: LocationAccuracy.high,
          //   distanceFilter: 100,
          //   timeLimit: Duration(seconds: 60),
          // );
          Location location = Location();
          // location.enableBackgroundMode(enable: true);
          var locationData =
              await location.getLocation().then((locationData) {});
          RGBLog.green(
              'location: ${locationData.latitude} ${locationData.longitude}');
          //
          // location.onLocationChanged.listen((LocationData locationData) {
          //   RGBLog.green(
          //       'location: ${locationData.latitude} ${locationData.longitude}');
          // });

          // Geolocator.getPositionStream(locationSettings: locationSettings)
          //     .listen((event) {
          //   RGBLog.green('current location: $event');

          // Timer.periodic(const Duration(seconds: 10), (timer) async {
          //   RGBLog.pink('background running');
          // var start = DateTime.now();
          // Geolocator.getCurrentPosition(
          //         desiredAccuracy: LocationAccuracy.high)
          //     .timeout(const Duration(seconds: 8))
          //     .then(
          //   (value) {
          //     var end = DateTime.now();
          //     var diff = start.difference(end);
          //     RGBLog.pink('Fetching time: $diff');
          //     RGBLog.pink('Current position: $value');
          //   },
          // );
          // var now = DateTime.now();
          // NotificationManager().show();
          // RGBLog.cyan('now: $now');
          // RGBLog.cyan('end: $endDate');
          // RGBLog.cyan('isAfter: ${now.isAfter(endDate)}');
          // if (now.isAfter(endDate)) {
          //   RGBLog.pink('trigger 2');
          //   completer.complete(true);
          //   timer.cancel();
          // }
          // });
          // });
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
          Timer.periodic(const Duration(seconds: 20), (timer) {
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

      return Future.delayed(const Duration(hours: 24));
    },
  );
}

class WorkManager {
  static const notifTaskKey = "com.test.test.notifKey";
  static const periodicTaskKey = "com.test.test.periodicKey";
  static const periodicTaskKey2 = "com.test.test.periodicKey2";

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
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
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

  registerPeriodicTask2({
    required DateTime startDate,
    required DateTime endDate,
    int startEarlyByMinutes = 0,
  }) {
    var now = DateTime.now();
    var delay = startDate.difference(now);
    delay -= Duration(seconds: startEarlyByMinutes);
    Workmanager().registerPeriodicTask(
      periodicTaskKey2,
      periodicTaskKey2,
      initialDelay: delay,
      frequency: const Duration(hours: 24),
      // outOfQuotaPolicy: OutOfQuotaPolicy.drop_work_request,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
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
