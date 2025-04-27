import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedPosition;
  double _currentZoom = 15.0;
  final MapController _mapController = MapController();
  bool _isLoadingLocation = false;
  bool _isLoadingSavedLocation = true;
  bool _showLocationCard = true;
  String _locationName = "Selecting location...";
// Default fallback location - Gujarat coordinates
  static const LatLng _defaultGujaratPosition = LatLng(23.0225, 72.5714);
  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(23.0225, 72.5714); // Default position
    _loadSavedLocation();
    _reverseGeocode(_selectedPosition); // Initialize location name
  }

  Future<void> _loadSavedLocation() async {
    setState(() => _isLoadingSavedLocation = true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try local storage first
      final localLocation = prefs.getString('saved_location');
      if (localLocation != null) {
        final locData = jsonDecode(localLocation);
        final position = LatLng(locData['lat'], locData['lng']);
        _updatePosition(position);
        await _reverseGeocode(position);
        return;
      }

      // Fallback to backend
      final userString = prefs.getString('user');
      if (userString != null) {
        final user = jsonDecode(userString);
        final response = await http.get(
          Uri.parse('${dotenv.env['BACKEND_URL']}/users/${user['_id']}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          if (userData['location'] != null) {
            final coords = userData['location']['coordinates'];
            final position = LatLng(coords[1], coords[0]);
            _updatePosition(position);
            await _reverseGeocode(position);
            await prefs.setString(
                'saved_location',
                jsonEncode({
                  'lat': position.latitude,
                  'lng': position.longitude,
                }));
            return; // Added return to prevent fallthrough
          }
        }
      }

      // If no saved location found anywhere
      _updatePosition(_selectedPosition); // Use Gujarat fallback
      await _reverseGeocode(_selectedPosition);
    } catch (e) {
      debugPrint('Location load error: $e');
      // Ensure we still show Gujarat if there's an error
      _updatePosition(_selectedPosition);
      await _reverseGeocode(_selectedPosition);
    } finally {
      setState(() => _isLoadingSavedLocation = false);
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _locationName = data['display_name'] ?? "Selected location";
        });
      }
    } catch (e) {
      setState(() => _locationName = "Selected location");
    }
  }

  void _updatePosition(LatLng position) {
    setState(() => _selectedPosition = position);
    _mapController.move(position, _currentZoom);
    _reverseGeocode(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _isLoadingSavedLocation
          ? _buildLoadingScreen()
          : _buildMapWithOverlays(),
      floatingActionButton: _buildFloatingControls(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(_locationName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          )),
      centerTitle: true,
      backgroundColor: Colors.deepOrange,
      elevation: 0,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveLocation,
            tooltip: 'Save Location',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
          ),
          SizedBox(height: 16),
          Text('Loading your location...',
              style: TextStyle(color: Colors.deepOrange)),
        ],
      ),
    );
  }

  Widget _buildMapWithOverlays() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedPosition,
            initialZoom: _currentZoom,
            onTap: (_, latLng) => _updatePosition(latLng),
            onPositionChanged: (camera, _) =>
                setState(() => _currentZoom = camera.zoom),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 50,
                  height: 50,
                  point: _selectedPosition,
                  child: _buildAnimatedMarker(),
                ),
              ],
            ),
          ],
        ),
        if (_showLocationCard)
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'locate_me',
              backgroundColor: Colors.deepOrange,
              child: _isLoadingLocation
                  ? CircularProgressIndicator(color: Colors.white)
                  : Icon(Icons.my_location, size: 28, color: Colors.white),
              onPressed: _getCurrentLocation,
            ),
          ),
      ],
    );
  }

  Widget _buildAnimatedMarker() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: Duration(milliseconds: 800),
      builder: (_, scale, __) {
        return Transform.translate(
          offset: Offset(0, -10), // Move up by 10 pixels
          child: Transform.scale(
            scale: scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_pin, size: 50, color: Colors.deepOrange),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationCard() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: _showLocationCard ? 20 : -200,
      left: 20,
      right: 20,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            setState(() => _showLocationCard = false);
          }
        },
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24, // Fixed height for the title row
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(_locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            )),
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_down, size: 20),
                        onPressed: () =>
                            setState(() => _showLocationCard = false),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                _buildCoordinateRow(
                  'Latitude',
                  _selectedPosition.latitude.toStringAsFixed(6),
                ),
                SizedBox(height: 8),
                _buildCoordinateRow(
                  'Longitude',
                  _selectedPosition.longitude.toStringAsFixed(6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            )),
        Text(value,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              color: Colors.deepOrange,
            )),
      ],
    );
  }

  Widget _buildFloatingControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // FloatingActionButton.small(
        //   heroTag: 'zoom_in',
        //   backgroundColor: Colors.white,
        //   child: Icon(Icons.add, color: Colors.deepOrange),
        //   onPressed: () => _updateZoom(_currentZoom + 1),
        // ),
        // SizedBox(height: 12),
        // FloatingActionButton.small(
        //   heroTag: 'zoom_out',
        //   backgroundColor: Colors.white,
        //   child: Icon(Icons.remove, color: Colors.deepOrange),
        //   onPressed: () => _updateZoom(_currentZoom - 1),
        // ),
        SizedBox(height: 12),
        if (!_showLocationCard)
          FloatingActionButton.small(
            heroTag: 'show_card',
            backgroundColor: Colors.white,
            child: Icon(Icons.keyboard_arrow_up, color: Colors.deepOrange),
            onPressed: () => setState(() => _showLocationCard = true),
          ),
      ],
    );
  }

  void _updateZoom(double newZoom) {
    setState(() => _currentZoom = newZoom.clamp(10.0, 18.0));
    _mapController.move(_selectedPosition, _currentZoom);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Location services disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions denied';
        }
      }

      final position = await Geolocator.getCurrentPosition();
      _updatePosition(LatLng(position.latitude, position.longitude));
      setState(() => _showLocationCard = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _saveLocation() async {
    debugPrint('Starting save location process');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      debugPrint('User data from shared prefs: $userString');

      if (userString == null) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        _showErrorToast('User not logged in');
        return;
      }

      final user = jsonDecode(userString);
      final userId = user['_id'];
      final backendUrl = dotenv.env['BACKEND_URL']!;
      debugPrint('Backend URL: $backendUrl');

      final response = await http
          .put(
            Uri.parse('$backendUrl/users/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'location': {
                'type': 'Point',
                'coordinates': [
                  _selectedPosition.longitude,
                  _selectedPosition.latitude,
                ],
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog

      if (response.statusCode == 200) {
        await prefs.setString(
          'saved_location',
          jsonEncode({
            'lat': _selectedPosition.latitude,
            'lng': _selectedPosition.longitude,
          }),
        );

        // Add small delay to ensure dialog is fully dismissed
        await Future.delayed(const Duration(milliseconds: 50));
        _showSuccessToast('Location saved successfully!');
      } else {
        _showErrorToast('Failed to save: ${response.statusCode}');
      }
    } on TimeoutException {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorToast('Request timed out');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorToast('Error: ${e.toString()}');
      }
    }
  }

  void _showSuccessToast(String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.hideCurrentSnackBar(); // Hide previous snackbar if any
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showErrorToast(String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.hideCurrentSnackBar(); // Hide previous snackbar if any
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
