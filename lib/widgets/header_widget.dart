import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:flutter/material.dart';

class HeaderWidget extends StatefulWidget {
  final void Function()? onPressed;
  const HeaderWidget({super.key, this.onPressed});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.backgroundColorApp,
      leading: IconButton(onPressed: widget.onPressed, icon: const Icon(Icons.arrow_back_ios)),
    );
  }
}

