import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final MapController _mapController = MapController();
  LatLng? _savedLocation;
  double _zoom = 13.0;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('saved_latitude');
    final lng = prefs.getDouble('saved_longitude');
    final zoom = prefs.getDouble('saved_zoom');

    if (lat != null && lng != null && zoom != null) {
      _savedLocation = LatLng(lat, lng);
      _zoom = zoom;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_savedLocation != null) {
          _mapController.move(_savedLocation!, _zoom);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map Location")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          onPositionChanged: (position, hasGesture) {
            if (hasGesture && position.zoom != null) {
              setState(() {
                _zoom = position.zoom!;
              });
            }
          },
          initialCameraFit: _savedLocation != null
              ? CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints([_savedLocation!]),
                )
              : CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints([LatLng(33.6844, 73.0479)]),
                ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
        ],
      ),
    );
  }
}
