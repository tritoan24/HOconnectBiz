import 'package:flutter/material.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

class HorizontalDivider extends StatelessWidget {
  final double thickness;
  final Color color;

  const HorizontalDivider({
    super.key,
    this.thickness = 1.0, // Độ dày mặc định của vạch kẻ ngang
    this.color = AppColor.dividerColor, // Sử dụng màu từ AppColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      color: color,
    );
  }
}
