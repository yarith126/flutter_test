import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:background_location/background_location.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';
import 'package:flutter_demo/feature/view/api_response_view.dart';
import 'package:flutter_demo/feature/view/google_maps_view.dart';

// import 'package:flutter_demo/firebase_options.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/resources/config/notification_config.dart';
import 'package:flutter_demo/resources/main_services//flutter_workmanager.dart';
import 'package:flutter_demo/resources/helpers/rgb_log_helper.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../resources/helpers/location_callback_handler.dart';
import '../../../resources/helpers/location_service_repository.dart';

// import 'package:geolocator/geolocator.dart';
// import 'package:hive_flutter/adapters.dart';
// import 'package:location/location.dart';
// import 'package:workmanager/workmanager.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    BackgroundLocator.initialize();
  }

  ReceivePort port = ReceivePort();

  // This widget is the root of your application.
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1000));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const MyHomePage(title: 'Homepage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ReceivePort? _receivePort;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissionForAndroid();
      _initForegroundTask();

      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  final txtCon1 = TextEditingController();
  final txtCon2 = TextEditingController();

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }

    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }

    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        id: 500,
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        buttons: [
          const NotificationButton(
            id: 'sendButton',
            text: 'Send',
            textColor: Colors.orange,
          ),
          const NotificationButton(
            id: 'testButton',
            text: 'Test',
            textColor: Colors.grey,
          ),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      RGBLog.pink('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      if (data is int) {
        RGBLog.pink('eventCount: $data');
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (data is DateTime) {
        RGBLog.pink('timestamp: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Menu',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                      color: Colors.red,
                      decorationColor: Colors.red,
                    ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // _enableBackgroundLocationService();
                },
                child: const Text('Enable background location service'),
              ),
              TextButton(
                onPressed: () {
                  _startForegroundTask();
                },
                child: const Text('Start foreground'),
              ),
              TextButton(
                onPressed: () {
                  _stopForegroundTask();
                },
                child: const Text('Stop foreground'),
              ),
              TextButton(
                onPressed: () {
                  _disableBackgroundLocationService();
                },
                child: const Text('Disable background location service'),
              ),
              TextButton(
                onPressed: () {
                  _geofencing();
                },
                child: const Text('Geofencing'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapSample()),
                  );
                },
                child: const Text('Google Maps Demo'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ApiResponseView()),
                  );
                },
                child: const Text('completer'),
              ),
              TextButton(
                onPressed: () {
                  final FlutterLocalNotificationsPlugin
                      flutterLocalNotificationsPlugin =
                      FlutterLocalNotificationsPlugin();
                  flutterLocalNotificationsPlugin.show(
                    Random().nextInt(99999),
                    'COOL SERVICE',
                    'Awesome ${DateTime.now()}',
                    const NotificationDetails(
                      android: NotificationConfig.androidNotifDetail,
                    ),
                  );
                },
                child: const Text('notification test'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: TextField(
                      controller: txtCon1,
                    ),
                  ),
                  Container(
                    width: 100,
                    child: TextField(
                      controller: txtCon2,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  var workManager = WorkManager();
                  workManager.start();
                  RGBLog.green('started');
                  // var date = DateTime(2023, 12, 13, 12, 33);
                  // var diff = date.difference(DateTime.now());
                  // RGBLog.green(diff);
                },
                child: const Text('start workmanager'),
              ),
              TextButton(
                onPressed: () {
                  var workManager = WorkManager();
                  workManager.stop();
                  RGBLog.green('stopped');
                  // var date = DateTime(2023, 12, 13, 12, 33);
                  // var diff = date.difference(DateTime.now());
                  // RGBLog.green(diff);
                },
                child: const Text('stop workmanager'),
              ),
              TextButton(
                onPressed: () {
                  int hour = int.parse(txtCon1.text);
                  int min = int.parse(txtCon2.text);
                  var workManager = WorkManager();
                  workManager.stop();
                  workManager.registerPeriodicTask2(
                    startDate: DateTime(2023, 12, 15, hour, min),
                    endDate: DateTime(2023, 12, 15, hour, min + 2),
                  );
                  RGBLog.green('registered');
                  var date = DateTime(2023, 12, 14, hour, min);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$date')),
                  );
                  // var date = DateTime(2023, 12, 13, 12, 33);
                  // var diff = date.difference(DateTime.now());
                  // RGBLog.green(diff);
                },
                child: const Text('register workmanager'),
              ),
              TextButton(
                onPressed: () {
                  FlutterLocalNotificationsPlugin
                      flutterLocalNotificationsPlugin =
                      FlutterLocalNotificationsPlugin();
                  flutterLocalNotificationsPlugin
                      .resolvePlatformSpecificImplementation<
                          AndroidFlutterLocalNotificationsPlugin>()
                      ?.requestNotificationsPermission()
                      .then((value) {
                    _showSnack(value);
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text('$value')),
                    // );
                  });
                },
                child: const Text('Notification permission'),
              ),
              TextButton(
                onPressed: () async {
                  // bool serviceEnabled =
                  //     await Geolocator.isLocationServiceEnabled();
                  // await GeolocatorPlatform.instance.requestPermission();
                  // var permission =
                  //     await GeolocatorPlatform.instance.checkPermission();
                  // if (permission == LocationPermission.denied) {
                  //   permission =
                  //       await GeolocatorPlatform.instance.requestPermission();
                  //   _showSnack('denied');
                  // }

                  // if (!serviceEnabled) {
                  //   GeolocatorPlatform.instance.requestPermission();
                  // }
                  // if (!serviceEnabled) {
                  //   _showSnack('Location services are disabled.');
                  // } else {
                  //   _showSnack('Enabled');
                  // }
                },
                child: const Text('Location permission'),
              ),
              TextButton(
                onPressed: () async {
                  Map<String, dynamic> data = {'countInit': 1};
                  await BackgroundLocator.initialize();
                  await BackgroundLocator.registerLocationUpdate(
                    LocationCallbackHandler.callback,
                    initCallback: LocationCallbackHandler.initCallback,
                    initDataCallback: data,
                    disposeCallback: LocationCallbackHandler.disposeCallback,
                    iosSettings: IOSSettings(
                        accuracy: LocationAccuracy.NAVIGATION,
                        distanceFilter: 0),
                    autoStop: false,
                    androidSettings: AndroidSettings(
                        accuracy: LocationAccuracy.NAVIGATION,
                        interval: 5,
                        distanceFilter: 0,
                        client: LocationClient.google,
                        androidNotificationSettings: AndroidNotificationSettings(
                            notificationChannelName: 'Location tracking',
                            notificationTitle: 'Start Location Tracking',
                            notificationMsg: 'Track location in background',
                            notificationBigMsg:
                                'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                            notificationIconColor: Colors.grey,
                            notificationTapCallback:
                                LocationCallbackHandler.notificationCallback)),
                  );
                },
                child: const Text('test'),
              ),
              Text('startupDate: ${startupDate}'),
            ],
          ),
        ),
      ),
    );
  }

  _showSnack(value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$value')),
    );
  }

  _geofencing() {
    // GeoFencing().start();
  }

  // Location location = Location();

  _disableBackgroundLocationService() async {
    // locationStream?.cancel();
    RGBLog.green('cancel');
  }

// StreamSubscription<LocationData>? locationStream;

// _enableBackgroundLocationService() async {
//   location.enableBackgroundMode(enable: true);
//   LocationData locationData = await location.getLocation();
//   RGBLog.pink('location: ${locationData.latitude} ${locationData.longitude}');
//
//   locationStream =
//       location.onLocationChanged.listen((LocationData currentLocation) {
//     RGBLog.pink(
//         'location: ${currentLocation.latitude} ${currentLocation.longitude}');
//   });
// }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    RGBLog.pink('customData: $customData');
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: 'eventCount: $_eventCount',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
    // location.enableBackgroundMode(enable: true);
    // LocationData locationData = await location.getLocation();
    // var locationData =await Geolocator.getCurrentPosition();
  }

  // Location location = Location();

  // Future<bool> _startForegroundTask() async {
  //   // You can save data using the saveData function.
  //   await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');
  //
  //   // Register the receivePort before starting the service.
  //   if (await FlutterForegroundTask.isRunningService) {
  //     return FlutterForegroundTask.restartService();
  //   } else {
  //     return FlutterForegroundTask.startService(
  //       notificationTitle: 'Foreground Service is running',
  //       notificationText: 'Tap to return to the app',
  //       callback: startCallback,
  //     );
  //   }
  // }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    RGBLog.pink('onDestroy');
    // _startForegroundTask();
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) async {
    RGBLog.pink('onNotificationButtonPressed >> $id');
    if (id == 'sendButton') {
      Map<String, dynamic> data = {'countInit': 1};
      await BackgroundLocator.registerLocationUpdate(
          LocationCallbackHandler.callback,
          initCallback: LocationCallbackHandler.initCallback,
          initDataCallback: data,
          disposeCallback: LocationCallbackHandler.disposeCallback,
          iosSettings: IOSSettings(
              accuracy: LocationAccuracy.HIGH,
              distanceFilter: 0,
             ),
          autoStop: false,
          androidSettings: AndroidSettings(
              accuracy: LocationAccuracy.HIGH,
              interval: 5,
              distanceFilter: 0,
              client: LocationClient.google,
              androidNotificationSettings: AndroidNotificationSettings(
                  notificationChannelName: 'Location tracking',
                  notificationTitle: 'Start Location Tracking',
                  notificationMsg: 'Track location in background',
                  notificationBigMsg:
                      'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                  notificationIconColor: Colors.grey,
                  notificationTapCallback:
                      LocationCallbackHandler.notificationCallback)));
    }
    // await BackgroundLocation.setAndroidNotification(
    //   title: 'Background service is running',
    //   message: 'Background location in progress',
    //   icon: '@mipmap/ic_launcher',
    // );
    // //await BackgroundLocation.setAndroidConfiguration(1000);
    // await BackgroundLocation.startLocationService(distanceFilter: 20);
    // BackgroundLocation.getLocationUpdates((location) {
    //   RGBLog.green('''\n
    //                   Latitude:  ${location.latitude}
    //                   Longitude: ${location.longitude}
    //                   Altitude: ${location.altitude}
    //                   Accuracy: ${location.accuracy}
    //                   Bearing:  ${location.bearing}
    //                   Speed: ${location.speed}
    //                   Time: ${location.time}
    //                 ''');
    // });
    if (id == 'testButton') {
      // BackgroundLocation.stopLocationService();
      BackgroundLocator.unRegisterLocationUpdate();
    }
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/");
    _sendPort?.send('onNotificationPressed');
  }
}
