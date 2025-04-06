import 'package:flutter/material.dart';
import 'widgets/onboarding1_text.dart';
import 'package:flutter_appp123/Onboard_page1/widgets/onboard_page1image.dart';
import 'package:flutter_appp123/sign_up/sign_up.dart'; // Import the next page

class Onboard_page1 extends StatelessWidget {
  const Onboard_page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Design
          _buildBackground(),

          // Main content of the Onboarding page
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              child: Stack(
                children: [
                  // Skip Button Positioned at Top Right
                  Positioned(
                    top: 10,
                    right: 20,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      },
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Column with onboarding content (Separate from Stack)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 180), // Increased space from top
                  OnboardingImage(),
                  SizedBox(height: 30), // Adjusted space below image
                  OnboardingText(),
                  Spacer(),
                  SizedBox(height: 50), // Space at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// New Background Design
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.white, Colors.white],
          center: Alignment.center,
          radius: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Abstract Shape (Top Right)
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade900,
              ),
            ),
          ),
          // Abstract Shape (Bottom Left)
          Positioned(
            bottom: -90,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
