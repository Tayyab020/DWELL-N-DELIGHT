import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
class LocationService {
  static const String _savedLocationKey = 'saved_location';

  // Save location to shared preferences
  static Future<void> saveLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedLocationKey, '$lat,$lng');
  }

  // Get saved location from shared preferences
  static Future<Map<String, double>?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationString = prefs.getString(_savedLocationKey);
    if (locationString != null) {
      final parts = locationString.split(',');
      return {
        'lat': double.parse(parts[0]),
        'lng': double.parse(parts[1]),
      };
    }
    return null;
  }

  // Get current location using geolocator
  static Future<Map<String, double>> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition();
    return {
      'lat': position.latitude,
      'lng': position.longitude,
    };
  }

  // Get address from coordinates
  static Future<String> getAddressFromCoordinates(
      double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown location';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Unknown location';
    }
  }
}
