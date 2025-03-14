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
    return Container(
      //cho ra giữa
      padding: const EdgeInsets.all(8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check,
            color: AppColor.successGreen,
          ),
          Text(
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
