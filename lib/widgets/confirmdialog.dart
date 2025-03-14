import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String? content;
  final String? titleButtonRight;
  final String? titleButtonLeft;
  final VoidCallback onConfirm;

  const CustomConfirmDialog({
    super.key,
    required this.content,
    required this.titleButtonRight,
    required this.titleButtonLeft,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Bo góc mềm mại
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nội dung Dialog
            Text(content!,
                textAlign: TextAlign.center,
                style: TextStyles.textStyleNormal14W400),
            const SizedBox(height: 24),

            // Hai nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Nền xám
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      titleButtonLeft!,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff006AF5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      titleButtonRight!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

