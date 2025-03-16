import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/text_styles.dart';

class NotificationPopup extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const NotificationPopup({
    super.key,
    required this.notification,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        notificationProvider.handleNotificationTap(notification, context);
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 90),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EBED),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10), // Giảm từ 12 xuống 8
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo thu nhỏ lại
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 32,
                        height: 32,
                        color: Colors.transparent,
                        child: const Icon(Icons.business,
                            color: Colors.blue, size: 20), // Giảm size icon
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Giảm từ 12 xuống 8
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('HH:mm, dd/MM/yyyy')
                                .format(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12, // Giảm từ 12 xuống 10
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), // Giảm từ 4 xuống 2
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style.copyWith(
                                decoration: TextDecoration.none,
                              ),
                          children: [
                            TextSpan(
                              text: "${notification.uId.displayName} ",
                              style: TextStyles.textStyleNormal14W700.copyWith(
                                color: Colors.black,
                                fontSize: 14,
                                // Giảm từ 14 xuống 12 (nếu TextStyles cho phép override)
                                decoration: TextDecoration.none,
                              ),
                            ),
                            TextSpan(
                              text: notification.message,
                              style: const TextStyle(
                                fontSize: 14, // Giảm từ 14 xuống 12
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2), // Giảm từ 4 xuống 2
                      if (notification.orderCode != null &&
                          notification.orderCode!.isNotEmpty)
                        Row(
                          children: [
                            const Text(
                              'Mã đơn hàng: ',
                              style: TextStyle(
                                  fontSize: 14), // Giảm từ 14 xuống 12
                            ),
                            Text(
                              notification.orderCode!,
                              style: const TextStyle(
                                fontSize: 14, // Giảm từ 14 xuống 12
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension không cần chỉnh sửa
extension NotificationPopupExtension on BuildContext {
  Future<void> showNotificationPopup({
    required NotificationModel notification,
    Duration displayDuration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) async {
    final overlay = Overlay.of(this);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        right: 0,
        left: 0,
        child: NotificationPopup(
          notification: notification,
          displayDuration: displayDuration,
          onDismiss: onDismiss,
        ),
      ),
    );

    overlay.insert(entry);

    await Future.delayed(displayDuration);

    if (ModalRoute.of(this)?.isCurrent ?? false) {
      entry.remove();
      if (onDismiss != null) onDismiss();
    }
  }
}
