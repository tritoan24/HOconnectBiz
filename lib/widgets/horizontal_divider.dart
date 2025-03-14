import 'package:flutter/material.dart';

class HorizontalDivider extends StatelessWidget {
  final double thickness;
  final Color color;

  const HorizontalDivider({
    super.key,
    this.thickness = 1.0, // Độ dày mặc định của vạch kẻ ngang
    this.color = const Color(0xFFE6E6E6), // Màu mặc định của vạch kẻ ngang
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      color: color,
    );
  }
}
