import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFFE65100);
  static const textColor = Color(0xFF161616);
  static const backgroundColor = Colors.white;

  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: primaryColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Color(0xFFFFF2DE),
  );

  static ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: const TextTheme(
          headlineLarge: headlineStyle,
          // Use headlineLarge instead of headline1
          bodyLarge: bodyTextStyle,
          // Use bodyText1 instead of bodyLarge
          labelLarge: buttonTextStyle, // Use labelLarge for button text style
        ),
      );
}
