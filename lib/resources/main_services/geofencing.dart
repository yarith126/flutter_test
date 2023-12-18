import 'dart:async';

import 'package:flutter_demo/resources/helpers/rgb_log_helper.dart';
import 'package:geofence_service/geofence_service.dart';
// import 'package:geofence_service/models/geofence_radius_sort_type.dart';

class GeoFencing {
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();

  final _geofenceList = <Geofence>[
    Geofence(
      id: 'place_1',
      latitude: 35.103422,
      longitude: 129.036023,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_250m', length: 250),
        GeofenceRadius(id: 'radius_200m', length: 200),
      ],
    ),
    Geofence(
      id: 'place_2',
      latitude: 35.104971,
      longitude: 129.034851,
      radius: [
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_200m', length: 200),
      ],
    ),
  ];

  final _geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: true,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC,
  );

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    RGBLog.pink('geofence: ${geofence.toJson()}');
    RGBLog.pink('geofenceRadius: ${geofenceRadius.toJson()}');
    RGBLog.pink('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);
  }

  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    RGBLog.pink('prevActivity: ${prevActivity.toJson()}');
    RGBLog.pink('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  void _onLocationChanged(Location location) {
    RGBLog.pink('location: ${location.toJson()}');
  }

  void _onLocationServicesStatusChanged(bool status) {
    RGBLog.pink('isLocationServicesEnabled: $status');
  }

  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      RGBLog.pink('Undefined error: $error');
      return;
    }

    RGBLog.pink('ErrorCode: $errorCode');
  }

  start() {
    _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService.addLocationChangeListener(_onLocationChanged);
    _geofenceService.addLocationServicesStatusChangeListener(
        _onLocationServicesStatusChanged);
    _geofenceService.addActivityChangeListener(_onActivityChanged);
    _geofenceService.addStreamErrorListener(_onError);
    _geofenceService.start(_geofenceList).catchError(_onError);

    _geofenceStreamController.stream.listen((event) {
      RGBLog.green('geofence: ${event.latitude}, ${event.longitude}');
    });
  }
  stop(){
    // _geofenceStreamController.stream.ca
  }
}
