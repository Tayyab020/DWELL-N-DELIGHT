import 'package:flutter/material.dart';

class OnboardingImage extends StatelessWidget {
  const OnboardingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/page1.webp',
      width: 250, // Reduced from 172 to 100
      height: 250, // Added height to ensure proportional sizing
      fit: BoxFit.contain,
    );
  }
}
