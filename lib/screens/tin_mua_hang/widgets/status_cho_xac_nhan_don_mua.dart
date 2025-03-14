import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

class StatusProcessing extends StatefulWidget {
  const StatusProcessing({super.key});

  @override
  State<StatusProcessing> createState() => _State();
}

class _State extends State<StatusProcessing> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //cho ra giữa
      padding: const EdgeInsets.all(8),
      child: const Row(
        //cách đều ở giữa
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đang chờ khách hàng xác nhận',
            style: TextStyle(
              color: AppColor.warningYellow,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColor.warningYellow,
          ),
        ],
      ),
    );
  }
}
