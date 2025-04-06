import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/cart1.dart';
import 'package:flutter_appp123/home/screens/notification.dart';
import 'package:flutter_appp123/home/screens/fooddetails.dart';
import '../widgets/sectionheader.dart';
import '../widgets/menu.dart';
import '../screens/fav.dart';
import '../screens/housedetails.dart';
import '../screens/seeallfood.dart';
import '../screens/seeallrentals.dart';

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
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Color(0xFFE65100)),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CartPage(), // ✅ No parameters needed
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      cartItems = result['cartItems'];
                      totalPrice = result['totalPrice'];
                    });
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
                      ), // <-- Properly closed

                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: () => navigateToFoodDetail({
                                'imageUrl': 'assets/icons/biryani.png',
                                'title': 'Biryani',
                                'description':
                                    'A delicious blend of spices, rice, and chicken.',
                                'price': 300.0,
                              }),
                              child: MenuCard(
                                imageUrl: 'assets/icons/biryani.png',
                                title: 'Biryani',
                                description:
                                    'A delicious blend of spices, rice, and chicken.',
                                type: 'food',
                                price: 300.0,
                                addToCart: addToCart,
                                addToFavorites: addToFavorites,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => navigateToFoodDetail({
                                'imageUrl': 'assets/icons/egg.png',
                                'title': 'Egg Curry',
                                'description':
                                    'A delicious curry made with boiled eggs in a spiced gravy.',
                                'price': 400.0,
                              }),
                              child: MenuCard(
                                imageUrl: 'assets/icons/egg.png',
                                title: 'Egg Curry',
                                description:
                                    'A delicious curry made with boiled eggs in a spiced gravy.',
                                type: 'food',
                                price: 400.0,
                                addToCart: addToCart,
                                addToFavorites: addToFavorites,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => navigateToFoodDetail({
                                'imageUrl': 'assets/icons/roti.jfif',
                                'title': 'Daal Roti',
                                'description':
                                    'The daal is made with a blend of lentils, aromatic spices, and a tempering of ghee, garlic, and cumin, offering a perfect balance of taste and nutrition.',
                                'price': 200.0,
                              }),
                              child: MenuCard(
                                imageUrl: 'assets/icons/roti.jfif',
                                title: 'Daal Roti',
                                description:
                                    'The daal is made with a blend of lentils, aromatic spices, and a tempering of ghee, garlic, and cumin, offering a perfect balance of taste and nutrition.',
                                type: 'food',
                                price: 200.0,
                                addToCart: addToCart,
                                addToFavorites: addToFavorites,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => navigateToFoodDetail({
                                'imageUrl': 'assets/icons/chvl.jfif',
                                'title': 'Daal Chawal',
                                'description':
                                    'The daal is made with a blend of lentils, aromatic spices, and a tempering of ghee, garlic, and cumin, offering a perfect balance of taste and nutrition.',
                                'price': 250.0,
                              }),
                              child: MenuCard(
                                imageUrl: 'assets/icons/chvl.jfif',
                                title: 'Daal Chawal',
                                description:
                                    'The daal is made with a blend of lentils, aromatic spices, and a tempering of ghee, garlic, and cumin, offering a perfect balance of taste and nutrition.',
                                type: 'food',
                                price: 250.0,
                                addToCart: addToCart,
                                addToFavorites: addToFavorites,
                              ),
                            ),
                          ],
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
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HouseDetailPage(
                                      imageUrl: 'assets/icons/house1.png',
                                      title: 'Luxury Villa',
                                      description:
                                          'A beautiful luxury villa with 4 bedrooms and a pool.',
                                      price: 5000.0,
                                    ),
                                  ),
                                );
                              },
                              child: MenuCard(
                                imageUrl: 'assets/icons/house1.png',
                                title: 'Luxury Villa',
                                description:
                                    'A beautiful luxury villa with 4 bedrooms and a pool.',
                                type: 'house',
                                price: 5000.0,
                                addToCart: addToCart,
                                addToFavorites: addToFavorites,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HouseDetailPage(
                                      imageUrl: 'assets/icons/house2.png',
                                      title: 'House',
                                      description:
                                          'A luxury house with 2 bedrooms and a kitchen.',
                                      price: 4000.0,
                                    ),
                                  ),
                                );
                              },
                              child: MenuCard(
                                imageUrl: 'assets/icons/house2.png',
                                title: 'House',
                                description:
                                    'A luxury house with 2 bedrooms and a kitchen.',
                                type: 'house',
                                price: 4000.0,
                                addToCart: addToCart,
                                addToFavorites: addToFavorites,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HouseDetailPage(
                                      imageUrl: 'assets/icons/house3.png',
                                      title: 'City House',
                                      description:
                                          'A beautiful house with 3 bedrooms,kitchen and  a pool.',
                                      price: 4000.0,
                                    ),
                                  ),
                                );
                              },
                              child: MenuCard(
                                imageUrl: 'assets/icons/house3.png',
                                title: 'City house',
                                description:
                                    'A beautiful house with 3 bedrooms,kitchen and  a pool',
                                type: 'house',
                                price: 4000.0,
                                addToCart: addToCart,
                                addToFavorites: addToFavorites,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HouseDetailPage(
                                      imageUrl: 'assets/icons/house4.jpg',
                                      title: 'Desi House',
                                      description:
                                          'A beautiful village house with 4 bedrooms,kitchen,washrooms and  a garden area.',
                                      price: 7000.0,
                                    ),
                                  ),
                                );
                              },
                              child: MenuCard(
                                imageUrl: 'assets/icons/house4.jpg',
                                title: 'Desi House',
                                description:
                                    'A beautiful village house with 4 bedrooms,kitchen,washrooms and  a garden area.',
                                type: 'house',
                                price: 7000.0,
                                addToCart: addToCart,
                                addToFavorites: addToFavorites,
                              ),
                            ),
                          ],
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
