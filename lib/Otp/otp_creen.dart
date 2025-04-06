import 'package:flutter/material.dart';
import 'package:flutter_appp123/reset-pswd/reset_pswd.dart';

// Import the ResetPasswordScreen
import 'widgets/otp_input.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                children: [
                  const SizedBox(height: 142),
                  const Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      children: [
                        TextSpan(text: 'A 4 digit code has been sent to '),
                        TextSpan(
                          text: '+91 9876543210 ',
                          style: TextStyle(
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 59),
                  const OtpInputField(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the Reset Password Screen after verification
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ResetPass(), // Navigate to ResetPasswordScreen
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 58,
                        vertical: 18,
                      ),
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFF2DE),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Adjust the position of the back icon
            Positioned(
              top: 40, // Lower the icon (was 20, now 40)
              left: 16,
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
