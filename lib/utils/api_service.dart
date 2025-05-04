import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class ApiService {
  
  static  String baseUrl  = dotenv.env['BACKEND_URL']!;
 
  static Future<Map<String, dynamic>> requestOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to request OTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to request OTP: $e');
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to reset password: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
}

class Toast {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
