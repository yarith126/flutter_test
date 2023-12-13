import 'dart:math';

// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/feature/view/api_response_view.dart';
import 'package:flutter_demo/feature/view/google_maps_view.dart';
import 'package:flutter_demo/firebase_options.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/resources/config/notification_config.dart';
import 'package:flutter_demo/resources/core/flutter_workmanager.dart';
import 'package:flutter_demo/resources/helpers/rgb_log_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:workmanager/workmanager.dart';

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
  }

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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  final txtCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Container(
              width: 100,
              child: TextField(
                controller: txtCon,
              ),
            ),
            TextButton(
              onPressed: () {
                int min = int.parse(txtCon.text);
                var workManager = WorkManager();
                workManager.stop();
                workManager.registerPeriodicTask(
                  startDate: DateTime(2023, 12, 13, 15, min),
                  endDate: DateTime(2023, 12, 13, 15, min + 1),
                );
                workManager.start();
                // var date = DateTime(2023, 12, 13, 12, 33);
                // var diff = date.difference(DateTime.now());
                // RGBLog.green(diff);
              },
              child: const Text('start workmanager'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$value')),
                  );
                });
              },
              child: const Text('Notification permission'),
            ),
            TextButton(
              onPressed: () {
                // var now = DateTime.now();
                // var date = DateTime(2023, 12, 13, 14, 58);
                // RGBLog.green(now.isAfter(date));
                var dur1 = Duration(seconds: 5);
                dur1 -= Duration(seconds: 1);
                // RGBLog.green(dur1);
              },
              child: const Text('test'),
            ),
            Text('startupDate: ${startupDate}'),
          ],
        ),
      ),
    );
  }
}
