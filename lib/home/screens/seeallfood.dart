import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cartprovider.dart';
import 'fooddetails.dart';

class AllFoodsPage extends StatelessWidget {
  const AllFoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context, listen: false);

    List<Map<String, dynamic>> foodItems = [
      {
        'imageUrl': 'assets/icons/biryani.png',
        'title': 'Biryani',
        'description': 'A delicious blend of spices, rice, and chicken.',
        'price': 300.0,
      },
      {
        'imageUrl': 'assets/icons/egg.png',
        'title': 'Egg Curry',
        'description':
            'A delicious curry made with boiled eggs in a spiced gravy.',
        'price': 400.0,
      },
      {
        'imageUrl': 'assets/icons/roti.jfif',
        'title': 'Daal Roti',
        'description': 'A classic combination of lentils and flatbread.',
        'price': 200.0,
      },
      {
        'imageUrl': 'assets/icons/chvl.jfif',
        'title': 'Daal Chawal',
        'description': 'A comforting meal of lentils and rice.',
        'price': 250.0,
      },
    ];

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
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: foodItems.length,
          itemBuilder: (context, index) {
            final item = foodItems[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailPage(
                      imageUrl: item['imageUrl'],
                      title: item['title'],
                      description: item['description'],
                      price: item['price'],
                      addToCart: (foodItem) {
                        cartProvider.addToCart(foodItem);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("${foodItem['title']} added to cart!"),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Image.asset(
                          item['imageUrl'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error,
                                color: Colors.red, size: 50);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rs. ${item['price']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.shopping_cart,
                                    color: Colors.deepOrange),
                                onPressed: () {
                                  cartProvider.addToCart({
                                    'title': item['title'],
                                    'imageUrl': item['imageUrl'],
                                    // Ensure correct key
                                    'price': item['price'],
                                    'quantity': 1,
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "${item['title']} added to cart!"),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.green,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
