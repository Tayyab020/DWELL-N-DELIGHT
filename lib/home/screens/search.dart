import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(), // Background with abstract shapes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
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
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.black54),
                      hintText: 'Search here...',
                      hintStyle: const TextStyle(color: Colors.black45),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list,
                            color: Colors.black54),
                        onPressed: () {}, // Add filter functionality here
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Search Results Placeholder
                Expanded(
                  child: Center(
                    child: Text(
                      'Search results will appear here',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Background with Abstract Shapes
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
          // children: [
          //   Positioned(
          //     top: 100,
          //     right: -50,
          //     child: _abstractCircle(200),
          //   ),
          //   Positioned(
          //     bottom: -50,
          //     left: -40,
          //     child: _abstractCircle(150),
          //   ),
          // ],
          ),
    );
  }

  /// Abstract Circular Decoration
//Widget _abstractCircle(double size) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.orange.shade900.withOpacity(0.2),
//       ),
//     );
//   }
}
