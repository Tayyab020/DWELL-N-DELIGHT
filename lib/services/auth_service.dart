import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class AuthService {
  static const String baseUrl = "http://192.168.165.160:5000/api";

  // ✅ Sign In User & Save Token + User ID
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
        print("logging in...");
      final response = await http.post(
       Uri.parse("$baseUrl/auth/signin"),
      
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey("token") &&
            responseData.containsKey("userId")) {
          String token = responseData["token"];
          String userId = responseData["userId"];

          print("🔑 Token received: $token");
          print("🆔 User ID received: $userId");

          await _saveAuthData(token, userId);
          return responseData;
        }
      }
      print("❌ Login Failed: ${response.body}");
      return null;
    } catch (e) {
      print("❌ Error during login: $e");
      return null;
    }
  }

  // ✅ Save Token & User ID Separately for Multi-User Handling
  Future<void> _saveAuthData(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', token); // Save token
    await prefs.setString('user_id', userId); // Save userId
    await prefs.setBool('is_logged_in', true); // Save login state

    print("✅ Token & User ID saved successfully!");
  }

  // ✅ Retrieve Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ✅ Retrieve User ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // ✅ Check if User is Logged In
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // ✅ Logout & Clear Only Current User Data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token'); // Remove token
    await prefs.remove('user_id'); // Remove userId
    await prefs.setBool('is_logged_in', false); // Reset login state

    print("🚪 User logged out. Session cleared.");
  }

  // ✅ Verify if Token is Valid
  Future<bool> isTokenValid() async {
    String? token = await getToken();
    if (token == null) return false; // ❌ No token found

    try {
      final response = await http.get(
        
        // Uri.parse("${dotenv.env['API_BASE_URL']}/api/auth/verify-token"),
        Uri.parse("$baseUrl/auth/verify-token"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return true; // ✅ Token is valid
      } else {
        await logout(); // ❌ Invalid token → Log out user
        return false;
      }
    } catch (e) {
      print("❌ Error verifying token: $e");
      return false;
    }
  }

  // ✅ Handle Sign Up (Ensure No Old Session Interference)
  Future<Map<String, dynamic>?> signUpUser(
      String email, String password , String name,  mobile) async {
    try {
      await logout(); // ✅ Clear previous session before new signup

      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        
        // Uri.parse("${dotenv.env['API_BASE_URL']}/api/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey("token") &&
            responseData.containsKey("userId")) {
          String token = responseData["token"];
          String userId = responseData["userId"];

          await _saveAuthData(token, userId);
          return responseData;
        }
      }
      print("❌ Signup Failed: ${response.body}");
      return null;
    } catch (e) {
      print("❌ Error during signup: $e");
      return null;
    }
  }
}
