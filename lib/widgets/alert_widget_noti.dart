import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';

class CustomAlertNoti extends StatelessWidget {
  final String message;
  final bool isLoading;
  final Color backgroundColor;

  const CustomAlertNoti({
    Key? key,
    required this.message,
    this.isLoading = false,
    this.backgroundColor = Colors.red,
  }) : super(key: key);

  static void show(BuildContext context, String message,
      {bool isLoading = false, Color backgroundColor = Colors.red}) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => CustomAlertNoti(
        message: message,
        isLoading: isLoading,
        backgroundColor: backgroundColor,
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding.top;

    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: padding + 10, left: 20, right: 20),
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  message,
                  style: TextStyles.textStyleNormal14W500White,
                  textAlign: TextAlign.center,
                  overflow:
                      TextOverflow.ellipsis, // Thêm ellipsis nếu text quá dài
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

