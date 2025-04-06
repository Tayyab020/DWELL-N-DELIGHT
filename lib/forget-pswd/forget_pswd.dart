import 'package:flutter/material.dart';
import 'package:flutter_appp123/Otp/otp_creen.dart';
import 'widgets/password_inputfield.dart';

class ForgetPswd extends StatelessWidget {
  // Remove const from the constructor
  ForgetPswd({super.key});

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Navigate to the next screen when submit button is pressed
  void _navigateToOtpScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OtpScreen(), // Navigate to OtpScreen
      ),
    );
  }

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
                children: [
                  const SizedBox(height: 140), // To create space for the image
                  const Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Don\'t worry! It happens. Please enter the address associated with your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Sign Up button
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const PasswordInputField(
                          label: 'Email ID / Phone number ',
                          isNewPassword: true,
                        ),
                        const SizedBox(height: 28),

                        // Submit button
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OtpScreen(),
                                  ));

                              _navigateToOtpScreen(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE65100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 44, // Moved slightly lower (was 16, now 24)
              left: 26, // Consistent padding from the left edge
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
