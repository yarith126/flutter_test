import 'dart:async';

import 'package:location/location.dart';

import '../helpers/rgb_log_helper.dart';
@pragma('vm:entry-point')
class FlutterLocation {
  @pragma('vm:entry-point')
  late Location location;

  FlutterLocation() {
    location = Location();
  }
  @pragma('vm:entry-point')
  StreamSubscription<LocationData>? locationStream;
  @pragma('vm:entry-point')
  start() async {
    location.enableBackgroundMode(enable: true);

    LocationData locationData = await location.getLocation();
    RGBLog.pink('location: ${locationData.latitude} ${locationData.longitude}');

    locationStream =
        location.onLocationChanged.listen((LocationData currentLocation) {
      RGBLog.pink(
          'location: ${currentLocation.latitude} ${currentLocation.longitude}');
    });
  }
  @pragma('vm:entry-point')
  stop() async {
    locationStream?.cancel();
    RGBLog.green('cancel');
  }
}
