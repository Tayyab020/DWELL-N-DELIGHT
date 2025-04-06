import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade400, // Divider color
            thickness: 0, // Divider thickness
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255), // Light gray text
              fontSize: 14,
              fontWeight: FontWeight.w300, // Slightly lighter font
            ),
          ),
        ),
        // Expanded(
        //   child: Divider(
        //     color: Colors.grey.shade400, // Divider color
        //     thickness: 1, // Divider thickness
        //   ),
        // ),
      ],
    );
  }
}

class SocialSignUpButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const SocialSignUpButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE65100),
          ),
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
