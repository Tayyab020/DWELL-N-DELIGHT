import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    fetchRentalBlogs();
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
      final userId = user['_id'];

      print('User Role: $role');
      print('User ID: $userId');

      String backendUrl = dotenv.env['BACKEND_URL']!;
      String endpoint = (role == 'provider')
          ? '$backendUrl/blogs/author/$userId'
          : '$backendUrl/blog/all';

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> allBlogs = responseData['blogs'];

        setState(() {
          foodItems =
              allBlogs.map((e) => Map<String, dynamic>.from(e)).toList();
        });

        debugPrint('✅ Blogs fetched: ${foodItems.length}');
      } else {
        debugPrint(
            "❌ Failed to fetch blogs. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching blogs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                Expanded(
                  child: foodItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Search results will appear here',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: foodItems.length,
                          itemBuilder: (context, index) {
                            final blog = foodItems[index];
                            return ListTile(
                              title: Text(blog['title'] ?? 'No title'),
                              subtitle:
                                  Text(blog['price'].toString() ?? 'No price'),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          hintText: 'Search here...',
          hintStyle: const TextStyle(color: Colors.black45),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black54),
            onPressed: () {}, // Add filter functionality
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
