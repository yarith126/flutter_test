import 'package:flutter/foundation.dart';

/// A logger that prints colorful log and report errors
@pragma("vm:entry-point")
class RGBLog {
  @pragma("vm:entry-point")
  static bool enable = true;
  @pragma("vm:entry-point")
  static bool runInReleaseMode = true;
  @pragma("vm:entry-point")
  static bool macMode = false;

  @pragma("vm:entry-point")
  static red(msg) => _logger(msg, _Log.red);

  @pragma("vm:entry-point")
  static green(msg) => _logger(msg, _Log.green);

  @pragma("vm:entry-point")
  static yellow(msg) => _logger(msg, _Log.yellow);

  @pragma("vm:entry-point")
  static blue(msg) => _logger(msg, _Log.blue);

  @pragma("vm:entry-point")
  static pink(msg) => _logger(msg, _Log.pink);

  @pragma("vm:entry-point")
  static cyan(msg) => _logger(msg, _Log.cyan);

  @pragma("vm:entry-point")
  static _logger(msg, _Log type) {
    if (!runInReleaseMode) {
      if (!kDebugMode || !enable) return;
    }
    if (RGBLog.macMode) {
      debugPrint('====================\n$msg\n====================');
      return;
    }
    if (type == _Log.red) debugPrint('\x1B[91m$msg\x1B[0m');
    if (type == _Log.green) debugPrint('\x1B[92m$msg\x1B[0m');
    if (type == _Log.yellow) debugPrint('\x1B[93m$msg\x1B[0m');
    if (type == _Log.blue) debugPrint('\x1B[94m$msg\x1B[0m');
    if (type == _Log.pink) debugPrint('\x1B[95m$msg\x1B[0m');
    if (type == _Log.cyan) debugPrint('\x1B[96m$msg\x1B[0m');
  }

  @pragma("vm:entry-point")
  static error(Object? error, [StackTrace? stackTrace, Object? location]) {
    if (!kDebugMode || !enable) return;
    // remove unnecessary last character
    if (!(stackTrace.toString() == '' || stackTrace == null)) {
      stackTrace = StackTrace.fromString(
          stackTrace.toString().substring(0, stackTrace.toString().length - 1));
    }
    String date = DateTime.now().toString();
    date = date.substring(0, date.length - 7);

    RGBLog.red('==============================================');
    debugPrint('\n\x1B[91mDate: \x1B[0m$date\n');
    if (error.toString().endsWith('\n')) {
      error = error.toString().substring(0, error.toString().length - 1);
    }
    debugPrint('\x1B[91mException: \x1B[0m$error\n');
    if (stackTrace == null || stackTrace.toString() == '') {
      debugPrint('\x1B[91mStackTrace:\x1B[0m null');
    } else {
      debugPrint('\x1B[91mStackTrace:\x1B[0m\n$stackTrace\n');
    }
    RGBLog.pink('==============================================');
  }
}

@pragma("vm:entry-point")
enum _Log { red, green, yellow, blue, pink, cyan }
