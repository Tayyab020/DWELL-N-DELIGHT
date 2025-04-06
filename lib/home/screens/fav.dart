import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favorites; // ✅ Original favorites list

  const FavoritesPage({Key? key, required this.favorites}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Map<String, dynamic>> favoritesList;

  @override
  void initState() {
    super.initState();
    favoritesList = List<
        Map<String,
            dynamic>>.from(widget.favorites.where((item) =>
        item['name'] != null &&
        item['name']
            .toString()
            .trim()
            .isNotEmpty)); // ✅ Explicitly cast to List<Map<String, dynamic>>
  }

  void removeFavorite(int index) {
    setState(() {
      final removedItem = favoritesList.removeAt(index);
      widget.favorites
          .removeWhere((item) => item['name'] == removedItem['name']);
    });
  }

  @override
  @override
  void dispose() {
    Navigator.pop(context, favoritesList); // ✅ Return updated list
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorites",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favoritesList.isEmpty
          ? const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: favoritesList.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final favorite = favoritesList[index];

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: favorite['image'] != null
                          ? Image.asset(
                              favorite['image'],
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                    ),
                    title: Text(
                      favorite['name'] ?? "No Name",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "\$${favorite['price']?.toStringAsFixed(2) ?? "0.00"}",
                      style: const TextStyle(color: Colors.green),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeFavorite(index), // ✅ Delete item
                    ),
                  ),
                );
              },
            ),
    );
  }
}
