import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BlogProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _foodItems = [];

  List<Map<String, dynamic>> get foodItems => _foodItems;

  Future<void> fetchRentalBlogs() async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'];
      if (backendUrl == null) {
        debugPrint("❌ BACKEND_URL not found in .env");
        return;
      }

      final response = await http.get(
        Uri.parse('$backendUrl/blog/all'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> allBlogs = responseData['blogs'];

        final filtered = allBlogs
            .where((blog) => blog['type'] == 'food')
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        _foodItems = filtered;
        notifyListeners();

        debugPrint('✅ Foods fetched: ${filtered.length}');
      } else {
        debugPrint(
            "❌ Failed to fetch blogs. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching blogs: $e");
    }
  }
}
