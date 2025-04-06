import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          // BoxShadow(
          //   color: const Color(0xFFF83C45),
          //   blurRadius: 4,
          //   offset: const Offset(0, 4),
          // ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (index) => Container(
            width: 5,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index == 0
                  ? const Color(0xFFE65100)
                  : const Color.fromARGB(255, 252, 189, 192),
              borderRadius: BorderRadius.circular(3.5),
            ),
          ),
        ),
      ),
    );
  }
}
