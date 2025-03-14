import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmButton extends StatefulWidget {
  const ConfirmButton({super.key});

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    if (_isConfirmed) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check,
              color: Color(0xFF006AF5),
            ),
            SizedBox(width: 8),
            Text(
              'Đã nhận hàng',
              style: TextStyle(
                  color: Color(0xFF006AF5), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isConfirmed = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006AF5),
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
