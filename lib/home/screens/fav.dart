import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/cartprovider.dart';
import 'package:flutter_appp123/home/screens/fooddetails.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key, required List<Map<String, dynamic>> favorites})
      : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoritesList = [];
  bool isLoading = true;
  String errorMessage = '';

  final backendUrl = dotenv.env['BACKEND_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<String?> _getUserIdFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> user = json.decode(userJson);
      return user['_id'];
    }
    return null;
  }

  Future<void> _fetchFavorites() async {
    try {
      String? userId = await _getUserIdFromLocalStorage();
      if (userId == null) {
        setState(() {
          errorMessage = 'User ID is not available';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$backendUrl/getfav/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('print printttttttttttttttt➡️');
        print(data);
        setState(() {
          favoritesList = List<Map<String, dynamic>>.from(
            (data as List).map((item) => {
                  "id": item['_id'],
                  "title": item['itemId']?['title'] ?? 'No Title',
                  "description": item['itemId']?['content'] ?? '',
                  "image": item['itemId']?['photoPath'],
                  "price": item['itemId']?['price'] ?? 0,
                  "isBlocked": item['itemId']?['isBlocked'] ?? false,
                }),
          );
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading favorites: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Future<void> removeFavorite(int index) async {

  //   final itemToRemove = favoritesList[index];
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$backendUrl/addfavorite'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'itemId': widget.itemId,
  //         'userId': userId,
  //         'isLiked': isLiked,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         favoritesList.removeAt(index);
  //       });
  //     } else {
  //       throw Exception('Failed to remove favorite');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to remove favorite: ${e.toString()}')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : favoritesList.isEmpty
                  ? const Center(
                      child: Text(
                        "No favorites yet!",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: favoritesList.length,
                        itemBuilder: (context, index) {
                          final favorite = favoritesList[index];

                          print(
                              '❤️favoritefavoritefavoritefavoritefavoritefavoritefavoritefavoritefavoritefavoritefavoritefavorite');
                          print(favorite);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodDetailPage(
                                    itemId: favorite['id'],
                                    title: favorite['title'],
                                    description: favorite['description'],
                                    imageUrl: favorite['image'],
                                    price:
                                        (favorite['price'] as num).toDouble(),
                                    addToCart: (foodItem) {
                                      cartProvider.addToCart(foodItem);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "${foodItem['title']} added to cart!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    favorites: [], // Pass empty for now
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      child: favorite['image'] != null
                                          ? Image.network(
                                              favorite['image'],
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.image_not_supported,
                                              size: 50),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          favorite['title'] ?? "No Name",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "PKR ${(favorite['price']).toString()}",
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Align(
                                  //   alignment: Alignment.topRight,
                                  //   child: IconButton(
                                  //     icon: const Icon(Icons.favorite,
                                  //         color: Colors.red),
                                  //     onPressed: () => removeFavorite(index),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
