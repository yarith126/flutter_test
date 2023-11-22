import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/feature/view/api_response_view.dart';
import 'package:flutter_demo/feature/view/google_maps_view.dart';
import 'package:flutter_demo/feature/view/one_flutter_two_apps_view.dart';
import 'package:flutter_demo/firebase_options.dart';
import 'package:hive_flutter/adapters.dart';

const platform = MethodChannel('demo_channel');

Future<int> detectDebugger() async {
  return await platform.invokeMethod('detectDebugger');
}

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('data');
  FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // runApp(const MyApp());
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const OneFlutterTwoAppsView()),
                );
              },
              child: const Text('2 Apps 1 Flutter'),
            ),
          ],
        ),
      ),
    );
  }
}
