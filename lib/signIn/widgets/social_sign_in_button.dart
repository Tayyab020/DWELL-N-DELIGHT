import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle; // Add this parameter for text color
  final Color dividerColor;

  const DividerWithText({
    Key? key,
    required this.text,
    this.textStyle, // Allow optional text styling
    this.dividerColor = Colors.grey, // Default divider color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            color: dividerColor, // Use the divider color
            thickness: 1.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: textStyle ??
                const TextStyle(
                    color: Colors.black), // Default to black if not provided
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1.5,
          ),
        ),
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
