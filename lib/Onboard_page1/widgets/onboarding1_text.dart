import 'package:flutter/material.dart';

class OnboardingText extends StatelessWidget {
  const OnboardingText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Search food and home',
          style: TextStyle(
            color: Color(0xFFE65100),
            fontSize: 22,
            fontFamily: 'Sen',
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 45),
        Text(
          'you can search home made food for delivery  and houses, room for rent.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF000000),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.09,
          ),
        ),
      ],
    );
  }
}
