import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_demo/resources/components/expandable_fab.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _latLngOlympiaStadium = CameraPosition(
    target: LatLng(11.558169, 104.912143),
    zoom: 14.4746,
  );

  Set<Polygon> _polygon = HashSet<Polygon>();
  final List<LatLng> _pointsOlympia = const [
    LatLng(11.557952, 104.908892),
    LatLng(11.561715, 104.912050),
    LatLng(11.562125, 104.912820),
    LatLng(11.562125, 104.914207),
    // LatLng(11.560590, 104.914228),
    LatLng(11.560033, 104.914518),
    // LatLng(11.562125, 104.914207),
    LatLng(11.559781, 104.915033),
    LatLng(11.559466, 104.915205),
    LatLng(11.555890, 104.914169),
    LatLng(11.555790, 104.910770),
    LatLng(11.557275, 104.908924),
  ];

  final List<LatLng> _pointsWatPhnom = const [
    LatLng(11.557952, 104.908892),
    LatLng(11.561715, 104.912050),
    LatLng(11.562125, 104.912820),
    LatLng(11.562125, 104.914207),
    // LatLng(11.560590, 104.914228),
    LatLng(11.560033, 104.914518),
    // LatLng(11.562125, 104.914207),
    LatLng(11.559781, 104.915033),
    LatLng(11.559466, 104.915205),
    LatLng(11.555890, 104.914169),
    LatLng(11.555790, 104.910770),
    LatLng(11.557275, 104.908924),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        // indoorViewEnabled: false,
        // mapType: MapType.hybrid,
        initialCameraPosition: _latLngOlympiaStadium,
        polygons: _polygon,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: _drawAreaOlympia,
            icon: const Text('Olympia', style: TextStyle(color: Colors.white)),
          ),
          ActionButton(
            onPressed: () {},
            icon: const Text('2', style: TextStyle(color: Colors.white)),
          ),
          ActionButton(
            onPressed: () {},
            icon: const Text('3', style: TextStyle(color: Colors.white)),
          ),
          ActionButton(
            onPressed: () {},
            icon: const Text('4', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _drawAreaOlympia() async {
    setState(() {
      _polygon.add(Polygon(
        polygonId: const PolygonId('1'),
        points: _pointsOlympia,
        fillColor: Colors.red.withOpacity(0.3),
        strokeColor: Colors.red,
        // geodesic: true,
        strokeWidth: 4,
      ));
    });
  }

  Future<void> _drawWatPhnom() async {
    setState(() {
      _polygon.add(Polygon(
        polygonId: const PolygonId('2'),
        points: _pointsOlympia,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blue,
        geodesic: true,
        strokeWidth: 4,
      ));
    });
  }
}
