import 'dart:convert' show json, jsonDecode;

import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/ProviderOrdersScreen.dart';
import 'package:flutter_appp123/home/screens/cart1.dart';
import 'package:flutter_appp123/home/screens/fav.dart';
import 'package:flutter_appp123/home/screens/fooddetails.dart';
import 'package:flutter_appp123/home/screens/housedetails.dart';
import 'package:flutter_appp123/home/screens/notification.dart';
import 'package:flutter_appp123/home/screens/seeallfood.dart';
import 'package:flutter_appp123/home/screens/seeallrentals.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../widgets/sectionheader.dart';
import '../widgets/menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> favorites = [];
  List<Map<String, String>> notifications = [
    {
      'title': 'New Product Added',
      'body': 'Check out the new arrivals in our store.'
    },
    {
      'title': 'Order Shipped',
      'body': 'Your order has been shipped and is on its way!'
    },
    {
      'title': 'Sale Alert',
      'body': 'Limited time offer! Get 20% off on your next purchase.'
    },
    {
      'title': 'Order Delivered',
      'body': 'Your order has been delivered successfully!'
    },
  ];
  double totalPrice = 0.0;
  List<dynamic> blogs = [];
  String? role;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        role = user['role'];
      });
    }
  }

  Future<void> fetchBlogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString == null) {
        print('❌ No user data found in local storage');
        return;
      }
      final user = jsonDecode(userString);
      final userId = user['_id'];
      setState(() {
        role = user['role'];
      });

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
        final data = json.decode(response.body);
        print('✅ Blogs fetched: $data');

        setState(() {
          blogs = data['blogs'] ?? [];
        });
      } else {
        print('❌ Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching blogs: $e');
    }
  }

  void addToFavorites(Map<String, dynamic> item) {
    setState(() {
      if (!favorites.any((fav) => fav['title'] == item['title'])) {
        favorites.add(item);
      } else {
        favorites.removeWhere((fav) => fav['title'] == item['title']);
      }
    });
  }

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      cartItems.add(item);
      totalPrice += item['price'];
    });
  }

  void navigateToFoodDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailPage(
          itemId: item['itemId'],
          imageUrl: item['imageUrl'],
          title: item['title'],
          description: item['description'],
          price: item['price'],
          addToCart: addToCart,
          favorites: favorites,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_active_outlined,
                  color: Color(0xFFE65100)),
              onPressed: () async {
                final updatedNotifications = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationsPage(notifications: notifications),
                  ),
                );

                if (updatedNotifications != null) {
                  setState(() {
                    notifications = updatedNotifications;
                  });
                }
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Color(0xFFE65100)),
                Text('Location', style: TextStyle(color: Color(0xFFE65100))),
                Icon(Icons.arrow_drop_down, color: Color(0xFFE65100)),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: IconButton(
                icon: const Icon(Icons.favorite_border_sharp,
                    color: Color(0xFFE65100)),
                onPressed: () async {
                  final updatedFavorites = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesPage(favorites: favorites),
                    ),
                  );

                  if (updatedFavorites != null) {
                    setState(() {
                      favorites = updatedFavorites;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: IconButton(
                icon: Icon(  role == 'provider'
                        ? Icons.list_alt_outlined
                        : Icons.shopping_cart_outlined,
                    color: const Color(0xFFE65100)),
                onPressed: () async {
                  if (role == 'provider') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProviderOrdersScreen()),
                    );
                  } else if (role == 'buyer') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CartPage(
                                cartItems: cartItems,
                                totalPrice: totalPrice,
                              )),
                    );
                    if (result != null) {
                      setState(() {
                        cartItems = result['cartItems'];
                        totalPrice = result['totalPrice'];
                      });
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE65100),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search,
                                    color: Color(0xFFE65100)),
                                hintText: 'Name your mood...',
                                hintStyle:
                                    const TextStyle(color: Color(0xFFE65100)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.filter_list, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SectionHeader(
                        title: "Explore Menu",
                        color: Colors.white,
                        onSeeAllPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllFoodsPage()),
                          );
                        },
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: blogs.isNotEmpty
                              ? blogs
                                  .where((blog) => blog['type'] == 'food')
                                  .map((blog) {
                                  final price = blog['price'];
                                  return GestureDetector(
                                    onTap: () => navigateToFoodDetail({
                                      'itemId': blog['_id'],
                                      'imageUrl': blog['photoPath'],
                                      'title': blog['title'],
                                      'description': blog['content'],
                                      'price':
                                          price is num ? price.toDouble() : 0.0,
                                    }),
                                    child: MenuCard(
                                      imageUrl: blog['photoPath'],
                                      title: blog['title'],
                                      description: blog['content'],
                                      type: 'food',
                                      price:
                                          price is num ? price.toDouble() : 0.0,
                                      addToCart: addToCart,
                                      addToFavorites: addToFavorites,
                                    ),
                                  );
                                }).toList()
                              : [],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SectionHeader(
                        title: "Explore Rentals",
                        color: Colors.white,
                        onSeeAllPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllRentalsPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: blogs.isNotEmpty
                              ? blogs
                                  .where((blog) => blog['type'] == 'rental')
                                  .map((blog) {
                                  final price = blog['price'];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HouseDetailPage(
                                            imageUrl: blog['photoPath'] ?? '',
                                            title: blog['title'] ?? '',
                                            description: blog['content'] ?? '',
                                            price: (blog['price'] is num)
                                                ? blog['price'].toDouble()
                                                : 0.0,
                                          ),
                                        ),
                                      );
                                    },
                                    child: MenuCard(
                                      imageUrl: blog['photoPath'],
                                      title: blog['title'],
                                      description: blog['content'],
                                      type: 'rental',
                                      price:
                                          price is num ? price.toDouble() : 0.0,
                                      addToCart: addToCart,
                                      addToFavorites: addToFavorites,
                                    ),
                                  );
                                }).toList()
                              : [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
