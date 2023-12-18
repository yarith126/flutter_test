import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/feature/view/api_response_view.dart';
import 'package:flutter_demo/feature/view/google_maps_view.dart';
import 'package:flutter_demo/firebase_options.dart';
import 'package:flutter_demo/test_app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';

import 'feature/app/view/my_app_screen.dart';

const platform = MethodChannel('demo_channel');

Future<int> detectDebugger() async {
  return await platform.invokeMethod('detectDebugger');
}

var startupDate = DateTime.now();

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('data');
  // FirebaseApp app = await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  WidgetsFlutterBinding.ensureInitialized();


  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: MyTestApp(),
  ));
}
