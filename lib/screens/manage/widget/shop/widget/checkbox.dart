import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Check extends StatelessWidget {
  // Changed to StatelessWidget
  const Check({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed Center widget
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xff006AF5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
