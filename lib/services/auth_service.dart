import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiConfig {
  static final String baseUrl = "${dotenv.env['BACKEND_URL']}";
}

class AuthService {
  // static const String baseUrl = "http://192.168.165.160:5000/api";
  final url = Uri.parse('${ApiConfig.baseUrl}');

  get context => null;

  void _showAdminRedirect() async {
    // Show a message that the admin panel is only available on the web
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Admin Panel"),
          content: const Text(
              "The Admin Panel is only available on the web. Please visit the web app."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                // Redirect to the web app
                const url =
                    'https://your-web-app-url.com'; // Replace with your web app's URL
                if (await canLaunch(url)) {
                  await launch(url); // Launch the URL
                } else {
                  throw 'Could not launch $url'; // If URL can't be opened
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com', // From Google Cloud
  );

  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception("No ID token");

      String backendUrl = dotenv.env['BACKEND_URL']!;
      // Send to backend
      final response = await http.post(
        Uri.parse('$backendUrl/google'),
        body: jsonEncode({'idToken': idToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save JWT and user data in Flutter (e.g., SharedPreferences)
        //  await storage.write(key: 'token', value: data['token']);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomePage()));
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }

  // ✅ Sign In User & Save Token + User ID
  Future<Map<String, dynamic>?> loginUser(
      {required String email, required String password}) async {
    try {
      await logout();
      print("logging in...");
      final response = await http.post(
        Uri.parse("$url/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey("user") && responseData["auth"] == true) {
          // Extract the user object
          Map<String, dynamic> user = responseData["user"];

          if (user['role'] == 'admin') {
            print('User is an admin');
            _showAdminRedirect();
            return null; // Return null to prevent further processing
          }

          print('going to loginnnnnnnnnnnnnnn');
          // 🔥 Get token from cookies (Set-Cookie header)
          String? rawCookie = response.headers['set-cookie'];
          String? token;
          if (rawCookie != null) {
            final cookies = rawCookie.split(';');
            token = cookies[0]; // Extract token from cookie
          }
          print('🔑 Token from cookies: $token');
          if (token != null) {
            // Save both user object and token to local storage
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'user', jsonEncode(user)); // Save entire user object
            await prefs.setString('token', token); // Save token
          } else {
            return {"error": "Token not found in response headers"};
          }
          print('responseData: $responseData');
          return responseData;
        } else {
          return {"error": "Authentication failed or user info missing"};
        }
      } else {
        print("❌ Signup Failed: ${response.body}");
        final errorBody = jsonDecode(response.body);
        return {"error": errorBody['message'] ?? "Signup failed"};
      }
    } catch (e) {
      print("❌ Error during login: $e");
      return null;
    }
  }

  // ✅ Save Token & User ID Separately for Multi-User Handling
  Future<void> _saveAuthData(String token, user) async {
    final prefs = await SharedPreferences.getInstance();

    print('🔑 Saving token: $token');
    print('🆔 Saving user : $user');
    await prefs.setString('auth_token', token); // Save token
    await prefs.setString('user', user); // Save userId
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

    await prefs.remove('token'); // Remove token
    await prefs.remove('user'); // Remove userId
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
        Uri.parse("$url/auth/verify-token"),
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

  Future<Map<String, dynamic>> signUpUser({
    required String email,
    required String password,
    required String name,
    required String mobile,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$url/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": name,
          "phone": mobile,
          "role": role
        }),
      );

      print(response.statusCode);
      print(response.body);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": responseData['message'] ?? "Registration successful",
        };
      } else if (response.statusCode == 409) {
        return {
          "success": false,
          "error": responseData['message'] ?? "Email already registered",
        };
      } else {
        return {
          "success": false,
          "error": responseData['message'] ?? "Signup failed",
        };
      }
    } catch (e) {
      print("❌ Error during signup: $e");
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
}
  // ✅ Handle Sign Up (Ensure No Old Session Interference)
  // Future<Map<String, dynamic>?> signUpUser({
  //   required String email,
  //   required String password,
  //   required String name,
  //   required String mobile,
  //   required String role,
  // }) async {
  //   try {
  //     await logout(); // Clear previous session before new signup

  //     final response = await http.post(
  //       Uri.parse("$url/register"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "email": email,
  //         "password": password,
  //         "name": name,
  //         "phone": mobile,
  //         "role": role
  //       }),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final responseData = jsonDecode(response.body);
  //       print('responseData: $responseData');
  //       if (responseData.containsKey("user") && responseData["auth"] == true) {
  //         // Extract the user object
  //         Map<String, dynamic> user = responseData["user"];

  //         // 🔥 Get token from cookies (Set-Cookie header)
  //         String? rawCookie = response.headers['set-cookie'];
  //         String? token;
  //         if (rawCookie != null) {
  //           final cookies = rawCookie.split(';');
  //           token = cookies[0]; // Extract token from cookie
  //         }
  //         print('🔑 Token from cookies: $token');
  //         if (token != null) {
  //           // Save both user object and token to local storage
  //           final prefs = await SharedPreferences.getInstance();
  //           await prefs.setString(
  //               'user', jsonEncode(user)); // Save entire user object
  //           await prefs.setString('token', token); // Save token
  //         } else {
  //           return {"error": "Token not found in response headers"};
  //         }
  //         print('responseData: $responseData');
  //         return responseData['message'];
  //       } else {
  //         return {"error": "Authentication failed or user info missing"};
  //       }
  //     } else {
  //       print("❌ Signup Failed: ${response.body}");
  //       final errorBody = jsonDecode(response.body);
  //       return {"error": errorBody['message'] ?? "Signup failed"};
  //     }
  //   } catch (e) {
  //     print("❌ Error during signup: $e");
  //     return {"error": e.toString()};
  //   }
  // }

