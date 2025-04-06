import 'package:flutter/material.dart';

class OnboardingImage extends StatelessWidget {
  const OnboardingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/s.png',
      width: 170, // Reduced from 172 to 100
      height: 180, // Added height to ensure proportional sizing
      fit: BoxFit.contain,
    );
  }
}
