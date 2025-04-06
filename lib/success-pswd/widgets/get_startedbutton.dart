import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/home_screen.dart';

class Go extends StatelessWidget {
  final VoidCallback onPressed;

  const Go({
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
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE65100),
          foregroundColor: const Color(0xFFFFF2DE),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: const Text(
          'Go moody again',
          style: TextStyle(
            color: Color(0xFFFFF2DE),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
