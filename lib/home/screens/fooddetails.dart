import 'dart:convert';

import 'package:flutter_appp123/home/screens/VideoPlayerWidget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/order.dart';
import 'package:provider/provider.dart';
import 'cartprovider.dart';
import 'cart1.dart';

class FoodDetailPage extends StatefulWidget {
  final String itemId;
  final String imageUrl;
  final String title;
  final String description;
  final double price;
  final Function(Map<String, dynamic>)? addToCart;

  final List<Map<String, dynamic>> favorites;

  const FoodDetailPage({
    super.key,
    required this.itemId,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.addToCart,
    required this.favorites,
  });

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  bool isLiked = false;
  bool isLoadingLikeStatus = true;
  bool isProvider = false;

  double rating = 0;
  int quantity = 1;
  List<Map<String, dynamic>> rentalItems = [];

  Future<void> fetchRentalBlogs() async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'];
      if (backendUrl == null) {
        debugPrint("❌ BACKEND_URL not found in .env");
        return;
      }

      final response = await http.get(
        Uri.parse('$backendUrl/blog/all'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> allBlogs = responseData['blogs'];

        final filtered = allBlogs
            .where((blog) => blog['type'] == 'food')
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          rentalItems = filtered;
        });

        debugPrint('✅ Rentals fetched: ${filtered.length}');
      } else {
        debugPrint(
            "❌ Failed to fetch blogs. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching blogs: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // Fetch available food rental blogs
    fetchRentalBlogs();

    // Initialize favorite status
    checkIfLiked();

    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        isProvider = user['role'] == 'provider';
      });
    }
  }

  Future<void> checkIfLiked() async {
    setState(() {
      isLoadingLikeStatus = true;
    });

    try {
      final backendUrl = dotenv.env['BACKEND_URL'];
      if (backendUrl == null) {
        debugPrint("❌ BACKEND_URL not found in .env");
        throw Exception("Backend URL not configured");
      }

      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      final userId = userString != null ? jsonDecode(userString)['_id'] : null;

      if (userId == null) {
        debugPrint("❌ User ID not found");
        throw Exception("User not authenticated");
      }

      final uri =
          Uri.parse('$backendUrl/checkfavorite').replace(queryParameters: {
        'itemId': widget.itemId,
        'userId': userId,
      });

      debugPrint('🌐 Checking favorite: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('🔍 Response status: ${response.statusCode}');
      debugPrint('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          isLiked = responseData['isLiked'] ?? false;
        });
        debugPrint('✅ Favorite status: $isLiked');
      } else {
        debugPrint("❌ Server error: ${response.body}");
        throw Exception("Failed to check favorite status");
      }
    } catch (e) {
      debugPrint("❌ Error checking favorite: $e");
      // Optionally show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error checking favorite status"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingLikeStatus = false;
      });
    }
  }

  Future<void> toggleFavorite() async {
    final previousState = isLiked;

    try {
      setState(() {
        isLiked = !isLiked; // Optimistic update
      });

      final backendUrl = dotenv.env['BACKEND_URL'];
      final prefs = await SharedPreferences.getInstance();
      final userId = jsonDecode(prefs.getString('user')!)['_id'];

      final response = await http.post(
        Uri.parse('$backendUrl/addfavorite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'itemId': widget.itemId,
          'userId': userId,
          'isLiked': isLiked,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update favorite');
      }
    } catch (e) {
      debugPrint("❌ Error toggling favorite: $e");
      setState(() {
        isLiked = previousState; // Revert on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update favorite"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void placeOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(
          title: widget.title,
          price: widget.price,
          imageUrl: widget.imageUrl,
          itemId: widget.itemId,
        ),
      ),
    );
  }

  void shareProduct() {
    Share.share(
      "Check out this amazing food item: ${widget.title} for PKR ${widget.price}\n${widget.imageUrl}",
      subject: "Delicious Food Recommendation!",
    );
  }

  void addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final Map<String, dynamic> product = {
      'title': widget.title,
      'imageUrl': widget.imageUrl,
      'price': widget.price,
      'quantity': quantity,
    };

    cartProvider.addToCart(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.title} added to cart!"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const CartPage(cartItems: [], totalPrice: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: rentalItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE9E7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFE65100), width: 2),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.imageUrl.toLowerCase().endsWith('.mp4') ||
                                widget.imageUrl.contains('video/upload')
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayerWidget(url: widget.imageUrl),
                                  IconButton(
                                    icon: Icon(Icons.play_arrow,
                                        color: Colors.white, size: 50),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VideoPlayerWidget(
                                                  url: widget.imageUrl),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : Image.network(
                                widget.imageUrl,
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Updated favorite button with loading state
                      isLoadingLikeStatus
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: toggleFavorite,
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? Colors.red
                                    : const Color(0xFFE65100),
                                size: 24,
                              ),
                            ),
                      IconButton(
                        onPressed: addToCart,
                        icon: const Icon(Icons.shopping_cart,
                            color: Color(0xFFE65100), size: 24),
                      ),
                      IconButton(
                        onPressed: shareProduct,
                        icon: const Icon(Icons.share,
                            color: Color(0xFFE65100), size: 24),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                rating = rating < 5 ? rating + 1 : 5;
                              });
                            },
                            icon: const Icon(Icons.star,
                                color: Colors.amber, size: 24),
                          ),
                          Text("$rating/5",
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(widget.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.start),
                  const SizedBox(height: 20),
                  Text(
                    "Price: PKR ${widget.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  if (!isProvider) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) quantity--;
                            });
                          },
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                        ),
                        Text('$quantity', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          icon:
                              const Icon(Icons.add_circle, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (!isProvider)
                    ElevatedButton(
                      onPressed: placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text("Place Order",
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ),
    );
  }
}
