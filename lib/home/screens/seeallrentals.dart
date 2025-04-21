import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'housedetails.dart';
import 'dart:async';

class AllRentalsPage extends StatefulWidget {
  const AllRentalsPage({super.key});

  @override
  State<AllRentalsPage> createState() => _AllRentalsPageState();
}

class _AllRentalsPageState extends State<AllRentalsPage> {
  List<Map<String, dynamic>> rentalItems = []; // Full list
  List<Map<String, dynamic>> displayedItems = []; // Filtered list (to display)
  TextEditingController searchController = TextEditingController();
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    fetchRentalBlogs(); // Initial fetch
  }

  Future<void> fetchRentalBlogs([String? query]) async {
    try {
      String backendUrl = dotenv.env['BACKEND_URL']!;
      String endpoint = query != null && query.isNotEmpty
          ? '$backendUrl/search?title=$query'
          : '$backendUrl/blog/all';

      final response = await http.get(Uri.parse(endpoint), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        print('📡 Response status: ${response.statusCode}');
        print('📡 Response body: ${response.body}');
        final decoded =
            jsonDecode(response.body); // This gives you a Map<String, dynamic>
        final List<dynamic> blogs =
            decoded['blogs']; // Extract the list from the "blogs" key

        final filtered = blogs
            .where((blog) => blog['type'] == 'rental')
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          rentalItems = filtered; // Update the full list
          displayedItems = filtered; // Initially display all items
        });
      } else {
        debugPrint("❌ Failed to fetch blogs");
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        // Only update the filtered list based on search query
        displayedItems = rentalItems
            .where((item) =>
                item['title'].toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    });
  }

  bool isVideo(String url) {
    return url.toLowerCase().endsWith('.mp4') ||
        url.toLowerCase().contains('.mov');
  }

  Widget _buildMediaWidget(String url) {
    return isVideo(url)
        ? VideoPreviewWidget(videoUrl: url)
        : Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
          );
  }

  @override
  void dispose() {
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
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
          ),
         
          Expanded(
            child: displayedItems.isEmpty
                ? const Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepOrange), // Change color here
                  ))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      itemCount: displayedItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final item = displayedItems[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HouseDetailPage(
                                  imageUrl: item['photoPath'] ?? '',
                                  title: item['title'] ?? '',
                                  description: item['content'] ?? '',
                                  price: (item['price'] is num)
                                      ? item['price'].toDouble()
                                      : 0.0,
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
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                        child: _buildMediaWidget(
                                            item['photoPath']),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            item['title'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['content'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rs. ${item['price']} /night',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}

class VideoPreviewWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPreviewWidget({super.key, required this.videoUrl});

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
