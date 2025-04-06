import 'package:flutter/material.dart';
import 'widgets/onboarding3_text.dart';
import 'widgets/onboarding3_image.dart';
import 'widgets/page_indicator3.dart';
// import 'widgets/get_started_button.dart'; // Import the Get Started button if it's in another file

class Onboard_page3 extends StatelessWidget {
  const Onboard_page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ✅ Background design added to the Stack
          _buildBackground(),

          /// ✅ Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              child: Column(
                children: [
                  const SizedBox(height: 106),
                  const OnboardingImage(),
                  const SizedBox(height: 17),
                  const OnboardingText(),
                  const Spacer(),
                  Get(onPressed: () {}), // Ensure Get button is imported
                  const SizedBox(height: 50), // Adjust bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ **Background Design Function**
Widget _buildBackground() {
  return Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        colors: [Colors.white, Colors.white], // Adjust colors if needed
        center: Alignment.center,
        radius: 1.5,
      ),
    ),
    child: Stack(
      children: [
        /// ✅ Abstract Shape (Top Right)
        Positioned(
          top: -40,
          left: -80,
          child: Container(
            width: 240,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE65100), // Changed to solid color format
            ),
          ),
        ),

        /// ✅ Abstract Shape (Bottom Left)
        Positioned(
          top: -80,
          right: -40,
          child: Container(
            width: 130,
            height: 150,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE65100), // Adjust if needed
            ),
          ),
        ),
      ],
    ),
  );
}
