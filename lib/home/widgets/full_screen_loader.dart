import 'package:flutter/material.dart';
import 'dart:ui';

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({
    super.key,
    this.loaderColor = Colors.deepOrange,
    this.strokeWidth = 4.0,
    this.blurAmount = 5.0,
  });

  final Color loaderColor;
  final double strokeWidth;
  final double blurAmount;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
              strokeWidth: strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}
