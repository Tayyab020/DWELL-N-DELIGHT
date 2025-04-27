import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'housedetails.dart';
import 'dart:async';

class AllRentalsPage extends StatefulWidget {
  final VoidCallback? onPostDeleted; // Callback to refresh home page

  const AllRentalsPage({super.key, this.onPostDeleted});

  @override
  State<AllRentalsPage> createState() => _AllRentalsPageState();
}

class _AllRentalsPageState extends State<AllRentalsPage> {
  List<Map<String, dynamic>> rentalItems = [];
  List<Map<String, dynamic>> displayedItems = [];
  TextEditingController searchController = TextEditingController();
  Timer? debounce;
  bool isProvider = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchRentalBlogs();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        isProvider = user['role'] == 'provider';
        userId = user['_id'];
      });
    }
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
        final decoded = jsonDecode(response.body);
        final List<dynamic> blogs = decoded['blogs'];

        final filtered = blogs
            .where((blog) => blog['type'] == 'rental')
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          rentalItems = filtered;
          displayedItems = filtered;
        });
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      String backendUrl = dotenv.env['BACKEND_URL']!;
      final response = await http.delete(
        Uri.parse('$backendUrl/blog/$postId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rental deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        fetchRentalBlogs(); // Refresh rentals list
        if (widget.onPostDeleted != null) {
          widget.onPostDeleted!(); // Refresh home page
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete rental: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting rental: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this rental?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deletePost(postId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
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
                ? const Center(
                    child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.deepOrange),
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
                            child: Stack(
                              children: [
                                Column(
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                item['title'],
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                fontSize: 12,
                                                color: Colors.grey),
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
                                if (isProvider && item['author'] == userId)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _showDeleteDialog(
                                          context, item['_id']),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.more_vert,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
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
