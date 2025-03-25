import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

// Widget mới có thể nhận callback khi nút được nhấn
class ConfirmButtonWithAction extends StatefulWidget {
  final VoidCallback onConfirm;

  const ConfirmButtonWithAction({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<ConfirmButtonWithAction> createState() =>
      _ConfirmButtonWithActionState();
}

class _ConfirmButtonWithActionState extends State<ConfirmButtonWithAction> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          widget.onConfirm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryBlue,
          minimumSize: const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Đã nhận được hàng',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
