import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalPrice => _cartItems.fold(
        0.0,
        (sum, item) =>
            sum +
            ((item['price'] as double? ?? 0.0) *
                (item['quantity'] as int? ?? 1)),
      );

  void addToCart(Map<String, dynamic> foodItem) {
    // Check if the item is already in the cart
    int index =
        _cartItems.indexWhere((item) => item['title'] == foodItem['title']);

    if (index != -1) {
      // If item exists, increase quantity
      _cartItems[index]['quantity'] += 1;
    } else {
      // Otherwise, add as new item
      _cartItems.add({...foodItem, 'quantity': 1});
    }

    notifyListeners(); // Notify UI to update
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(int index, int change) {
    if (index < 0 || index >= _cartItems.length) return;

    int currentQuantity = _cartItems[index]['quantity'] as int? ?? 1;
    if (currentQuantity + change > 0) {
      _cartItems[index]['quantity'] = currentQuantity + change;
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }
}
