import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermissions(BuildContext context) async {
    // Yêu cầu quyền storage trước
    await _requestStoragePermission(context);
    
    // Sau đó yêu cầu quyền thông báo nếu là Android
    if (Platform.isAndroid) {
      await _requestNotificationPermission(context);
    }
  }
  
  // Yêu cầu quyền storage riêng
  static Future<void> _requestStoragePermission(BuildContext context) async {
    final status = await Permission.storage.request();
    
    if (status != PermissionStatus.granted && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text('This app needs storage access to function properly.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  // Yêu cầu quyền thông báo riêng cho Android
  static Future<void> _requestNotificationPermission(BuildContext context) async {
    print("Đang yêu cầu quyền thông báo trên Android");
    final status = await Permission.notification.request();
    print("Trạng thái quyền thông báo: $status");
    
    if (status != PermissionStatus.granted && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thông báo'),
          content: const Text(
            'Ứng dụng cần quyền thông báo để gửi thông tin mới đến bạn.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Để sau'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Mở cài đặt ứng dụng để người dùng có thể cấp quyền thủ công
                await openAppSettings();
              },
              child: const Text('Mở Cài đặt'),
            ),
          ],
        ),
      );
    }
  }
  
  // Hàm công khai để yêu cầu riêng quyền thông báo bất cứ khi nào cần
  static Future<void> requestNotificationPermissionOnly(BuildContext context) async {
    if (Platform.isAndroid) {
      await _requestNotificationPermission(context);
    }
  }
}
