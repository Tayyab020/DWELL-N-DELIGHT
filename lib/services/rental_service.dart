import 'dart:convert';
import 'package:http/http.dart' as http;

class RentalService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Fetch all rentals from backend
  static Future<List<Map<String, dynamic>>> fetchRentals() async {
    final response = await http.get(Uri.parse('$baseUrl/rentals'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load rentals');
    }
  }
}
