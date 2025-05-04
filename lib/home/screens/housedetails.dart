import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../screens/landlord.dart';

import 'package:flutter_appp123/home/screens/VideoPlayerWidget.dart';

class HouseDetailPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final double price;
  final String authorId;

  const HouseDetailPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.authorId,
  });

  @override
  State<HouseDetailPage> createState() => _HouseDetailPageState();
}

class _HouseDetailPageState extends State<HouseDetailPage> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();

    // Check if it's a video by file extension
    _isVideo = widget.imageUrl.toLowerCase().endsWith('.mp4') ||
        widget.imageUrl.toLowerCase().endsWith('.mov') ||
        widget.imageUrl.toLowerCase().endsWith('.webm');

    if (_isVideo) {
      _controller = VideoPlayerController.network(widget.imageUrl)
        ..initialize().then((_) {
          setState(() {}); // Refresh when video is initialized
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _isPlaying = true;
        _controller!.play();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE9E7),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFE65100), width: 2),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.imageUrl.toLowerCase().endsWith('.mp4') ||
                          widget.imageUrl.toLowerCase().contains('video/upload')
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayerWidget(
                                url: widget.imageUrl), // Display video here
                            IconButton(
                              icon: Icon(Icons.play_arrow,
                                  color: Colors.white, size: 50),
                              onPressed: () {
                                // You can add logic to play the video or navigate to a full-screen player
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VideoPlayerWidget(url: widget.imageUrl),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : Image.network(
                          widget.imageUrl,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(widget.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text(
              "Price: PKR ${widget.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LandlordProfilePage(
                        authorId: widget.authorId,
                            imageUrl: widget.imageUrl,
                            title: widget.title,
                            description: widget.description,
                            price: widget.price,
                          )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.phone, color: Colors.white),
              label: const Text("Contact Owner",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
