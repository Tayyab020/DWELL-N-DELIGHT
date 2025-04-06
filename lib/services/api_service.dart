import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiService {
  static Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("authToken"); // ✅ Get stored token

      final response = await http.get(
        
        Uri.parse("${dotenv.env['API_BASE_URL']}/api/auth/profile/$userId"),
        // Uri.parse('http://10.0.2.2:5000/api/auth/profile/$userId'),
        headers: {
          "Authorization": "Bearer $token", // ✅ Add token for authentication
          "Content-Type": "application/json",
        },
      );

      print("🔹 API Response: ${response.body}"); // ✅ Debugging line

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("❌ Error fetching profile: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception: $e");
      return null;
    }
  }
}
