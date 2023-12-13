// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
// import 'package:flutter_demo/resources/helpers/rgb_log_helper.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationConfig {
//   static const notificationId = 1234;
//   static const notificationChannelId = 'attendance_notification';
//   static const notificationIcon = 'ic_bg_service_small';
//   static const AndroidNotificationDetails androidNotifDetail =
//    AndroidNotificationDetails(
//     '${NotificationConfig.notificationId}',
//     NotificationConfig.notificationChannelId,
//     icon: NotificationConfig.notificationIcon,
//     ongoing: true,
//   );
//   static const AndroidNotificationChannel androidChannel =
//       AndroidNotificationChannel(
//     notificationChannelId, // id
//     'MY FOREGROUND SERVICE', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.high, // importance must be at low or higher level
//   );
// }
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//   /// OPTIONAL, using custom notification channel id
//   // const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   //   _notificationChannelId, // id
//   //   'MY FOREGROUND SERVICE', // title
//   //   description:
//   //       'This channel is used for important notifications.', // description
//   //   importance: Importance.low, // importance must be at low or higher level
//   // );
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   if (Platform.isIOS || Platform.isAndroid) {
//     await flutterLocalNotificationsPlugin.initialize(
//       const InitializationSettings(
//         // iOS: DarwinInitializationSettings(),
//         android:
//             AndroidInitializationSettings(NotificationConfig.notificationIcon),
//       ),
//     );
//   }
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(NotificationConfig.androidChannel);
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will be executed when app is in foreground or background in separated isolate
//       onStart: onStart,
//
//       // auto start service
//       autoStart: true,
//       isForegroundMode: false,
//
//
//       // initialNotificationTitle: 'Starting',
//       // initialNotificationContent: 'Initializing',
//       // notificationChannelId: NotificationConfig.notificationChannelId,
//       // foregroundServiceNotificationId: Random().nextInt(999999),
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       autoStart: true,
//
//       // // this will be executed when app is in foreground in separated isolate
//       // onForeground: onStart,
//       //
//       // // you have to enable background fetch capability on xcode project
//       // onBackground: onIosBackground,
//     ),
//   );
// }
//
// // to ensure this is executed
// // run app from xcode, then from xcode menu, select Simulate Background Fetch
//
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//
//   // SharedPreferences preferences = await SharedPreferences.getInstance();
//   // await preferences.reload();
//   // final log = preferences.getStringList('log') ?? <String>[];
//   // log.add(DateTime.now().toIso8601String());
//   // await preferences.setStringList('log', log);
//
//   return true;
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();
//
//   // For flutter prior to version 3.0.0
//   // We have to register the plugin manually
//
//   /// OPTIONAL when use custom notification
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//     // service.setAsBackgroundService();
//     service.setAsForegroundService();
//   }
//
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//
//   // bring to foreground
//   Timer.periodic(const Duration(seconds: 10), (timer) async {
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         /// OPTIONAL for use custom notification
//         /// the notification id must be equals with AndroidConfiguration when you call configure() method.
//         flutterLocalNotificationsPlugin.show(
//           Random().nextInt(9999999),
//           'COOL SERVICE',
//           'Awesome ${DateTime.now()}',
//           const NotificationDetails(
//             android:  NotificationConfig.androidNotifDetail,
//             // android: AndroidNotificationDetails(
//             //   '${NotificationConfig.notificationId}',
//             //   NotificationConfig.notificationChannelId,
//             //   icon: NotificationConfig.notificationIcon,
//             //   ongoing: true,
//             // ),
//           ),
//         );
//         //
//         // // if you don't using custom notification, uncomment this
//         // service.setForegroundNotificationInfo(
//         //   title: "My App Service",
//         //   content: "Updated at ${DateTime.now()}",
//         // );
//         // if (await service.isForegroundService()) {
//         //   RGBLog.green('in foreground: ${DateTime.now()}');
//         // }
//         if (await service.isForegroundService()) {
//           RGBLog.green('in foreground: ${DateTime.now()}');
//           // if clocking period check
//           // run check
//           // cooldown after clocked
//         }
//       }
//     }
//
//     /// you can see this log in logcat
//     // print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
//     // flutterLocalNotificationsPlugin.show(
//     //   _notificationId,
//     //   'COOL SERVICE',
//     //   'Awesome ${DateTime.now()}',
//     //   const NotificationDetails(
//     //     android: AndroidNotificationDetails(
//     //       _notificationChannelId,
//     //       'MY FOREGROUND SERVICE',
//     //       icon: _notificationIcon,
//     //       ongoing: true,
//     //     ),
//     //   ),
//     // );
//   });
// }
