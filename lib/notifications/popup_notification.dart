import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/notification_model.dart';
import '../../../providers/notification_provider.dart';

class NotificationPopup extends StatefulWidget {
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
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.19), // Bắt đầu từ phía trên màn hình
      end: const Offset(0.0, 0.2), // Kết thúc ở vị trí bình thường
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Hiệu ứng mượt mà
    ));

    // Bắt đầu animation
    _controller.forward();

    // Tự động dismiss sau displayDuration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (widget.onDismiss != null) widget.onDismiss!();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
    Provider.of<NotificationProvider>(context, listen: false);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false, // Cho phép thông báo xuất hiện dưới AppBar
        child: SlideTransition(
          position: _offsetAnimation,
          child: GestureDetector(
            onTap: () {
              notificationProvider.handleNotificationTap(
                  widget.notification, context);
              if (widget.onDismiss != null) widget.onDismiss!();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 32,
                                height: 32,
                                color: Colors.transparent,
                                child: const Icon(Icons.business,
                                    color: Colors.blue, size: 20),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                DateFormat('HH:mm, dd/MM/yyyy')
                                    .format(widget.notification.timestamp),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575), // Grey 600 equivalent
                                  fontFamily: 'Roboto', // Font chữ mặc định của Flutter
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Roboto', // Font chữ mặc định
                                decoration: TextDecoration.none,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "${widget.notification.uId.displayName.isNotEmpty ? widget.notification.uId.displayName : widget.notification.userCreate} ",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold, // Thay vì w700
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.notification.message,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal, // Thay vì w400
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (widget.notification.orderCode != null &&
                              widget.notification.orderCode!.isNotEmpty)
                            Row(
                              children: [
                                const Text(
                                  'Mã đơn hàng: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto', // Font chữ mặc định
                                  ),
                                ),
                                Text(
                                  widget.notification.orderCode!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto', // Font chữ mặc định
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
        ),
      ),
    );
  }
}

extension NotificationPopupExtension on BuildContext {
  Future<void> showNotificationPopup({
    required NotificationModel notification,
    Duration displayDuration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) async {
    final overlay = Overlay.of(this);
    late OverlayEntry entry;

    // Lấy chiều cao AppBar (thường là 56.0 theo mặc định Material Design)
    const double appBarHeight = kToolbarHeight;
    const double additionalOffset = 8.0;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarHeight + additionalOffset, // Lùi xuống thêm 20px
        right: 0,
        left: 0,
        child: NotificationPopup(
          notification: notification,
          displayDuration: displayDuration,
          onDismiss: () {
            entry.remove();
            if (onDismiss != null) onDismiss();
          },
        ),
      ),
    );

    overlay.insert(entry);
  }
}