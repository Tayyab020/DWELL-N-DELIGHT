import 'package:flutter/material.dart';

class OnboardingImage extends StatelessWidget {
  const OnboardingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/page2.png',
      width: 220, // Reduced from 172 to 100
      height: 220, // Added height to ensure proportional sizing
      fit: BoxFit.contain,
    );
  }
}
