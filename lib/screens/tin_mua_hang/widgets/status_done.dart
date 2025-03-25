import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

class StatusDone extends StatefulWidget {
  const StatusDone({super.key});

  @override
  State<StatusDone> createState() => _State();
}

class _State extends State<StatusDone> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Important: restricts the row's size
        children: [
          const Icon(
            Icons.check,
            color: AppColor.successGreen,
          ),
          const SizedBox(width: 8), // Add some spacing between icon and text
          const Text(
            'Đơn hàng hoàn tất',
            style: TextStyle(
              color: AppColor.successGreen,
            ),
          ),
        ],
      ),
    );
  }
}
