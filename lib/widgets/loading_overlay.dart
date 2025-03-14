import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(BuildContext context) {
    // Không hiển thị nếu đã có overlay
    if (_isShowing) {
      print("LoadingOverlay đã đang hiển thị, bỏ qua lệnh show()");
      return;
    }

    _isShowing = true;
    
    // Tạo overlay mới
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
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Thêm debug log
    print("LoadingOverlay đang hiển thị");
    
    try {
      if (context.mounted) {
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _isShowing = false;
        print("Context không còn hợp lệ, không thể hiển thị LoadingOverlay");
      }
    } catch (e) {
      _isShowing = false;
      print("Lỗi khi hiển thị LoadingOverlay: $e");
    }
  }

  static void hide() {
    if (!_isShowing) {
      print("LoadingOverlay đã ẩn, bỏ qua lệnh hide()");
      return;
    }
    
    try {
      if (_overlayEntry != null) {
        print("LoadingOverlay đang được ẩn");
        _overlayEntry!.remove();
      }
    } catch (e) {
      print("Lỗi khi ẩn LoadingOverlay: $e");
    } finally {
      _overlayEntry = null;
      _isShowing = false;
    }
  }
}
