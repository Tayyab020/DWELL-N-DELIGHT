import 'package:flutter/material.dart';
import 'package:flutter_appp123/sign_up/sign_up.dart';

class Get extends StatelessWidget {
  final VoidCallback onPressed;

  const Get({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUp()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE65100),
          // Button color
          foregroundColor: const Color(0xFFFFF2DE),
          // Text color
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 8,
          // Shadow effect
          shadowColor: Colors.black.withOpacity(0.7), // Shadow color
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
