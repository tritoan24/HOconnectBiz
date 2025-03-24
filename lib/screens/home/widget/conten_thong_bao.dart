import 'package:clbdoanhnhansg/providers/notification_provider.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/notification_model.dart';
import '../../../widgets/text_styles.dart';
import '../../../core/utils/date_time_utils.dart';

class ContenThongBao extends StatelessWidget {
  final NotificationModel notification;

  const ContenThongBao({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // Lấy NotificationProvider từ context
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    print("thời gian thông báo: ${notification.timestamp}");
    return GestureDetector(
      onTap: () {
        notificationProvider.handleNotificationTap(notification, context);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            child: ClipOval(
              child: Image.network(
                notification.uId.avatarImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    UrlImage.imageUserDefault,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTimeUtils.formatVnCommentTime(notification.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: "${notification.uId.displayName} ",
                          style: TextStyles.textStyleNormal14W700,
                        ),
                        TextSpan(
                          text: notification.message,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
