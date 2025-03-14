import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermissions(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    if (statuses[Permission.storage] != PermissionStatus.granted) {
      // Show dialog explaining why permissions are needed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Permission Required'),
          content:
              const Text('This app needs storage access to function properly.'),
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
}
