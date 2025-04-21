import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MenuCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String type;
  final double price;
  final Function(Map<String, dynamic>) addToCart;
  final Function(Map<String, dynamic>) addToFavorites;

  const MenuCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.addToCart,
    required this.addToFavorites,
  }) : super(key: key);

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  VideoPlayerController? _videoController;
  bool isVideo = false;

  @override
  void initState() {
    super.initState();
    isVideo = widget.imageUrl.toLowerCase().endsWith(".mp4");
    if (isVideo) {
      _videoController = VideoPlayerController.network(widget.imageUrl)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      width: 200,
      height: 200,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
              width: double.infinity,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: isVideo
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_videoController != null &&
                              _videoController!.value.isInitialized)
                            VideoPlayer(_videoController!)
                          else
                            const Center(child: CircularProgressIndicator()),
                          const Center(
                            child: Icon(Icons.play_circle_fill,
                                size: 30, color: Colors.white),
                          ),
                        ],
                      )
                    : Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${widget.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
