import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/splash.png', // Add your image here
          height: 150,
          width: 150,
        ),
        const SizedBox(height: 20),
        const Text(
          "DWELL N DELIGHT",
          style: TextStyle(
            fontSize: 22,
            //fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
