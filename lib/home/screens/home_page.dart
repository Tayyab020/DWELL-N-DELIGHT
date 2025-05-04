import 'dart:convert' show json, jsonDecode, jsonEncode;

import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/MapPage.dart';
import 'package:flutter_appp123/home/screens/ProviderOrdersScreen.dart';
import 'package:flutter_appp123/home/screens/cart1.dart';
import 'package:flutter_appp123/home/screens/fav.dart';
import 'package:flutter_appp123/home/screens/fooddetails.dart';
import 'package:flutter_appp123/home/screens/housedetails.dart';
import 'package:flutter_appp123/home/screens/notification.dart';
import 'package:flutter_appp123/home/screens/seeallfood.dart';
import 'package:flutter_appp123/home/screens/seeallrentals.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../widgets/sectionheader.dart';
import '../widgets/menu.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onRefresh; // Add this callback parameter

  const HomePage({super.key, this.onRefresh});
  @override
  _HomePageState createState() => _HomePageState();

  void refreshPosts() {}
}

class _HomePageState extends State<HomePage> {
  String _locationName = "Location"; // Default text
  bool _isLoadingLocation = false;
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
    _loadSavedLocation();
  }

  Future<void> refreshPosts() async {
    await fetchBlogs();
    if (widget.onRefresh != null) {
      widget.onRefresh!(); // Call the parent's refresh callback if it exists
    }
  }

  Future<void> _loadSavedLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final user = jsonDecode(userString);

        // First try local storage
        final localLocation = prefs.getString('saved_location');
        if (localLocation != null) {
          final locData = jsonDecode(localLocation);
          await _reverseGeocode(LatLng(locData['lat'], locData['lng']));
          return;
        }

        // Fallback to backend if local not available
        if (user['location'] != null) {
          final coords = user['location']['coordinates'];
          final position = LatLng(coords[1], coords[0]);
          await _reverseGeocode(position);

          // Save to local storage for future use
          await prefs.setString(
              'saved_location',
              jsonEncode(
                  {'lat': position.latitude, 'lng': position.longitude}));
        }
      }
    } catch (e) {
      debugPrint('Error loading location: $e');
      setState(() => _locationName = "Location"); // Fallback to default
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];

        // Create a more readable address format
        String displayName = [
          address['road'],
          address['neighbourhood'],
          address['suburb'],
          address['city']
        ].where((part) => part != null).join(', ');

        setState(() {
          _locationName = displayName.isNotEmpty ? displayName : "My Location";
        });

        // Cache the name locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_location_name', _locationName);
      }
    } catch (e) {
      setState(() => _locationName = "My Location");
    }
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

  Future<bool> fetchBlogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString == null) {
        print('❌ No user data found in local storage');
        return false;
        ;
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
        return true; // Success
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error fetching blogs: $e');
      return false;
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
          title: GestureDetector(
            onTap: () async {
              final newLocation = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationPickerScreen(),
                ),
              );

              if (newLocation != null) {
                await _loadSavedLocation(); // Refresh location after returning
              }
            },
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Color(0xFFE65100)),
                  SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 150),
                    child: _isLoadingLocation
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFE65100),
                            ),
                          )
                        : Text(
                            _locationName,
                            style: TextStyle(
                              color: Color(0xFFE65100),
                              overflow: TextOverflow.ellipsis,
                              // maxLines: 1,
                            ),
                          ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Color(0xFFE65100)),
                ],
              ),
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
                icon: Icon(
                    role == 'provider'
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
      body: RefreshIndicator(
        onRefresh: refreshPosts,
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
                                builder: (context) => AllFoodsPage(
                                    onPostDeleted: refreshPosts,
                                )),
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
                              builder: (context) => AllRentalsPage(
                                  onPostDeleted: refreshPosts, 
                              ),
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
                                    // onTap: () {
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (context) => HouseDetailPage(
                                    //         imageUrl: blog['photoPath'] ?? '',
                                    //         title: blog['title'] ?? '',
                                    //         description: blog['content'] ?? '',
                                    //         price: (blog['price'] is num)
                                    //             ? blog['price'].toDouble()
                                    //             : 0.0,
                                    //       ),
                                    //     ),
                                    //   );
                                    // },
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
