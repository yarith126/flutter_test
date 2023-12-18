import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/resources/helpers/file_manager.dart';
import 'package:flutter_demo/resources/helpers/location_callback_handler.dart';
import 'package:flutter_demo/resources/helpers/permission_helper.dart';
import 'package:flutter_demo/resources/helpers/rgb_log_helper.dart';
import 'package:flutter_demo/resources/main_services/flutter_location.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MyTestApp extends StatefulWidget {
  @override
  _MyTestAppState createState() => _MyTestAppState();
}

class _MyTestAppState extends State<MyTestApp> {
  ReceivePort port = ReceivePort();

  late FlutterLocation location;

  @override
  void initState() {
    super.initState();
    location = FlutterLocation();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
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
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Start'),
        onPressed: () {
          // location.start();
          _startForegroundTask();
          RGBLog.green('trigger');
        },
      ),
    );
    final stop = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Stop'),
        onPressed: () {
          // location.stop();
          _stopForegroundTask();
        },
      ),
    );
    final clear = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Permission'),
        onPressed: () {
          PermissionHelper().requestLocation();
        },
      ),
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter background Locator'),
        ),
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[start, stop, clear],
            ),
          ),
        ),
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

  ReceivePort? _receivePort;

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
      // location = FlutterLocation();
      // location.start();
      startLocationService();
    }
    if (id == 'testButton') {
      // location.stop();
      BackgroundLocator.unRegisterLocationUpdate();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");
    _sendPort?.send('onNotificationPressed');
  }
}

void startLocationService() {
  BackgroundLocator.registerLocationUpdate(
    // (data){
    //   RGBLog.green(data);
    // },
    LocationCallback.callback,
    initCallback: LocationCallback.initCallback,
    disposeCallback: LocationCallback.disposeCallback,
    initDataCallback: {},
    autoStop: false,
    iosSettings: IOSSettings(
      accuracy: LocationAccuracy.HIGH,
      distanceFilter: 0,
      stopWithTerminate: false,
    ),
    androidSettings: AndroidSettings(
      accuracy: LocationAccuracy.HIGH,
      interval: 5,
      distanceFilter: 0,
      androidNotificationSettings: AndroidNotificationSettings(
        notificationChannelName: 'Location tracking',
        notificationTitle: 'Start Location Tracking',
        notificationMsg: 'Track location in background',
        notificationBigMsg:
            'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
        notificationIcon: '',
        notificationIconColor: Colors.grey,
        notificationTapCallback: LocationCallback.notificationCallback,
      ),
      client: LocationClient.android,
    ),
  );
}

class LocationCallback2 {
  static void callback(LocationDto locationDto) async {
    RGBLog.green(locationDto);
    RGBLog.green('trigger');
    print('$locationDto');
  }

//Optional
  static void initCallback(dynamic _) {
    print('Plugin initialization');
  }

  static void disposeCallback() {
    print('Plugin initialization');
  }

//Optional
  static void notificationCallback() {
    print('User clicked on the notification');
  }
}

@pragma('vm:entry-point')
class LocationCallback {
  @pragma('vm:entry-point')
  static const String _isolateName = "LocatorIsolate";

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    // final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
    // send?.send(locationDto);
    RGBLog.green(locationDto);
    RGBLog.green('trigger');
    print('$locationDto');
  }

//Optional
  @pragma('vm:entry-point')
  static void initCallback(dynamic _) {
    print('Plugin initialization');
  }

  @pragma('vm:entry-point')
  static void disposeCallback() {
    print('Plugin initialization');
  }

//Optional
  @pragma('vm:entry-point')
  static void notificationCallback() {
    print('User clicked on the notification');
  }
}
