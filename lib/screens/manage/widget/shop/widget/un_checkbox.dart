import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnCheck extends StatelessWidget {
  const UnCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed Center widget
      padding: const EdgeInsets.all(4),
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xffC2C7CB),
          width: 2,
        ),
      ),
    );
  }
}
