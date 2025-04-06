import 'package:flutter/material.dart';
import 'widgets/password_input_field.dart';
import 'widgets/custom_button.dart';
import 'package:flutter_appp123/success-pswd/success_screen.dart'; // Import the success screen

class ResetPass extends StatelessWidget {
  const ResetPass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 130), // To create space for the image
                  const Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'At least 9 characters with uppercase and lowercase letters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Form(
                        child: Column(
                          children: [
                            const PasswordInputField(
                              label: 'New Password',
                              isNewPassword: true,
                            ),
                            const SizedBox(height: 16),
                            const PasswordInputField(
                              label: 'Confirm Password',
                              isNewPassword: false,
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              text: 'Verify',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SuccessScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Back arrow icon positioned correctly
            Positioned(
              top: 24, // Padding from the top edge
              left: 16, // Padding from the left edge
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFFE65100), // Orange color for the icon
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
