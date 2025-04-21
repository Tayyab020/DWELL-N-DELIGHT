import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedLoaderScreen extends StatefulWidget {
  const AnimatedLoaderScreen({super.key});

  @override
  State<AnimatedLoaderScreen> createState() => _AnimatedLoaderScreenState();
}

class _AnimatedLoaderScreenState extends State<AnimatedLoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true); // Fade in & out
    _animation = Tween<double>(begin: 0.3, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blackish blurred background
        Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/icons/logo.png"), // optional
              fit: BoxFit.cover,
            ),
            color: Colors.black.withOpacity(0.5),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.4), // overlay
            ),
          ),
        ),

        // Center Icon Animation
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App icon
                  Image.asset(
                    'assets/icon.png', // Replace with your app icon path
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Loading...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
