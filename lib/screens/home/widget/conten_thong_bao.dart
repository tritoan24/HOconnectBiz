// conten_thong_bao.dart
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/notification_model.dart';
import '../../../widgets/text_styles.dart';

class ContenThongBao extends StatelessWidget {
  final NotificationModel notification;

  const ContenThongBao({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                DateFormat('HH:mm, dd/MM/yyyy').format(notification.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4), // Khoảng cách nhỏ giữa các dòng
              SizedBox(
                width: double.infinity, // Đảm bảo chiếm toàn bộ chiều ngang
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style, // Sử dụng style mặc định
                    children: [
                      TextSpan(
                        text: "${notification.uId.displayName} ", // Tên in đậm
                        style: TextStyles.textStyleNormal14W700,
                      ),
                      TextSpan(
                        text: notification.message, // Nội dung tin nhắn
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

