import 'package:flutter/material.dart';
import 'housedetails.dart'; // Import the detail page

class AllRentalsPage extends StatelessWidget {
  const AllRentalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> rentalItems = [
      {
        'imageUrl': 'assets/icons/house1.png',
        'title': 'Luxury Villa',
        'description': 'A beautiful luxury villa with 4 bedrooms and a pool.',
        'price': 5000.0,
      },
      {
        'imageUrl': 'assets/icons/house2.png',
        'title': 'City House',
        'description': 'A modern city house with all facilities.',
        'price': 4000.0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Available Rentals',
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
            crossAxisCount: 2, // Two items per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8, // Adjust to fit the content
          ),
          itemCount: rentalItems.length,
          itemBuilder: (context, index) {
            final item = rentalItems[index];

            return GestureDetector(
              onTap: () {
                // Navigate to HouseDetailPage with rental details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HouseDetailPage(
                      imageUrl: item['imageUrl'],
                      title: item['title'],
                      description: item['description'],
                      price: item['price'],
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.asset(
                              item['imageUrl'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rs. ${item['price']} /night',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
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
