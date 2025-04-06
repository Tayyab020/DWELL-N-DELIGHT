import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '9:41',
      style: TextStyle(
        color: Color.fromARGB(0, 248,60,69),
        fontSize: 15,
        fontFamily: 'SF Pro Text',
        letterSpacing: -0.17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}