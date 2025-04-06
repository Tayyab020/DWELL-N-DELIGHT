import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  static const String baseUrl =
      'http://10.0.2.2:5000/api/cart'; // Use 10.0.2.2 for Android Emulator

  // Fetch cart items
  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load cart');
    }
  }

  // Add item to cart
  Future<void> addToCart(Map<String, dynamic> item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add item to cart');
    }
  }

  // Update item quantity
  Future<void> updateCartItem(String id, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart');
    }
  }

  // Remove item from cart
  Future<void> removeCartItem(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/remove/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item from cart');
    }
  }
}
