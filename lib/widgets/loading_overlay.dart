import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return; // Ngăn chặn hiển thị overlay nhiều lần

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Lớp nền mờ để chặn thao tác người dùng
          Positioned.fill(
            child: Container(
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(16),
            ),
          ),
          // Hiển thị animation loading
          Center(
            child: Lottie.asset(
              'assets/lottie/loading.json',
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
