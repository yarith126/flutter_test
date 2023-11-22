import 'package:flutter/material.dart';
import 'package:flutter_demo/main.dart';

class DebuggerDetector extends StatefulWidget {
  const DebuggerDetector({super.key});

  @override
  State<DebuggerDetector> createState() => _DebuggerDetectorState();
}

class _DebuggerDetectorState extends State<DebuggerDetector> {
  String displayText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Text(
              'Debugger Detector',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 60,
              ),
              color: Colors.black.withOpacity(0.05),
              height: 300,
              width: 1000,
              child: Text(displayText),
            ),
            // SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onTap,
              child: const Text('Click'),
            ),
          ],
        ),
      ),
    );
  }

  _onTap() {
    String output = 'Date: ${DateTime.now()}\n\n';
    detectDebugger().then((value) {
      switch (value) {
        case 1:
          output += 'AndroidManifest tamptered\n';
        case 2:
          output += 'Android Studio debugger\n';
        case 3:
          output += 'Execution time abnormally\n';
        case 4:
          output += 'TracerPid\n';
        default:
      }
      setState(() {
        if (output != '') {
          displayText = output;
        }
      });
    });
  }
}

