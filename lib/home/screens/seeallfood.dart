import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'cartprovider.dart';
import 'fooddetails.dart';

class AllFoodsPage extends StatefulWidget {
  final VoidCallback? onPostDeleted; // Add this callback parameter

  const AllFoodsPage({super.key, this.onPostDeleted});

  @override
  State<AllFoodsPage> createState() => _AllFoodsPageState();
}

class _AllFoodsPageState extends State<AllFoodsPage> {
  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> filteredFoodItems = [];
  TextEditingController searchController = TextEditingController();
  bool isProvider = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchRentalBlogs();
    searchController.addListener(() {
      filterFoods();
    });
  }

  Future<void> fetchRentalBlogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString == null) {
        print('❌ No user data found in local storage');
        return;
      }

      final user = jsonDecode(userString);
      final role = user['role'];
      userId = user['_id'];

      setState(() {
        isProvider = role == 'provider';
      });

      String backendUrl = dotenv.env['BACKEND_URL']!;
      String endpoint = isProvider
          ? '$backendUrl/blogs/author/$userId'
          : '$backendUrl/blog/all';

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> allBlogs = responseData['blogs'];

        final filtered = allBlogs
            .where((blog) => blog['type'] == 'food')
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          foodItems = filtered;
          filteredFoodItems = filtered;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching blogs: $e");
    }
  }

  void filterFoods() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredFoodItems = foodItems
          .where((item) =>
              item['title'].toLowerCase().contains(query) ||
              item['content'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> deletePost(String postId) async {
    try {
      String backendUrl = dotenv.env['BACKEND_URL']!;
      final response = await http.delete(
        Uri.parse('$backendUrl/blog/$postId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        fetchRentalBlogs(); // Refresh the list
        if (widget.onPostDeleted != null) {
          widget.onPostDeleted!(); // Call the callback to refresh home page
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deletePost(postId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Foods',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (query) => filterFoods(),
              decoration: InputDecoration(
                hintText: "Search by title...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            filteredFoodItems.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                  ))
                : Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredFoodItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredFoodItems[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodDetailPage(
                                  itemId: item['_id'] ?? '',
                                  imageUrl: item['photoPath'] ?? '',
                                  title: item['title'] ?? '',
                                  description: item['content'] ?? '',
                                  price: (item['price'] is num)
                                      ? item['price'].toDouble()
                                      : 0.0,
                                  addToCart: (foodItem) {
                                    cartProvider.addToCart(foodItem);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "${foodItem['title']} added to cart!"),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  favorites: [],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          item['photoPath'] ?? '',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error,
                                                color: Colors.red, size: 50);
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            item['content'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Rs. ${item['price']}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.shopping_cart,
                                                  color: Colors.deepOrange,
                                                ),
                                                onPressed: () {
                                                  cartProvider.addToCart({
                                                    'title': item['title'],
                                                    'imageUrl':
                                                        item['photoPath'],
                                                    'price': item['price'],
                                                    'quantity': 1,
                                                  });

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "${item['title']} added to cart!"),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (isProvider && item['author'] == userId)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _showDeleteDialog(
                                          context, item['_id']),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.more_vert,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
