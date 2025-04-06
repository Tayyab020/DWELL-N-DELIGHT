import 'package:flutter/material.dart';
import 'widgets/status_bar.dart';
import 'widgets/get_startedbutton.dart';
import 'widgets/text.dart';
import 'widgets/lock_image.dart';
//import 'widgets/page-indicator.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusBar(),
                    ],
                  ),
                  const SizedBox(height: 106),
                  const OnboardingImage(),
                  const SizedBox(height: 17),
                  const OnboardingText(),
                  const Spacer(),

                  Go(onPressed: () {}),
                  // const PageIndicator(),
                  const SizedBox(height: 99),
                ],
              ),
            ),

            // Back icon at the top-left
            Positioned(
              top: 36, // Position closer to the top
              left: 26, // Consistent padding from the left edge
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFFE65100), // Orange color for the icon
                onPressed: () {
                  Navigator.pop(context); // Navigate to the previous screen
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
