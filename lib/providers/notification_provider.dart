import 'package:clbdoanhnhansg/notifications/popup_notification.dart';
import 'package:clbdoanhnhansg/screens/cart/cart_tab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/notification_model.dart';
import '../../screens/comment/comments_screen.dart';
import '../core/base/base_provider.dart';
import '../core/services/socket_service.dart';
import '../repository/notification_repository.dart';
import 'auth_provider.dart';


class NotificationProvider extends BaseProvider {
  final NotificationRepository _notificationRepository =
  NotificationRepository();
  final AuthProvider _authProvider = AuthProvider();
  List<NotificationModel> _notifications = [];
  late SocketService _socketService;
  BuildContext? _lastContext;

  NotificationProvider() {
    _socketService = SocketService();
    _init();
  }

  List<NotificationModel> get notifications => _notifications;

  // Phương thức để lưu trữ context cuối cùng
  void setContext(BuildContext context) {
    _lastContext = context;
  }

  Future<void> _init() async {
    final userId = await _authProvider.getuserID();

    if (userId != null) {
      _socketService.connect(userId);

      _socketService.on('notification', (data) {
        try {
          print('ON NOTIFICATION - Received data: $data');

          if (data != null &&
              data['data'] != null &&
              data['data']['data'] is List) {
            final List<dynamic> notificationsList = data['data']['data'];
            print('Notifications list length: ${notificationsList.length}');

            for (var item in notificationsList) {
              if (item is Map<String, dynamic>) {
                final newNotification = NotificationModel.fromJson(item);
                print(
                    'Parsed notification: ID=${newNotification.id}, Message=${newNotification.message}, Post Title=${newNotification.post?.title}');

                // Thêm thông báo vào danh sách
                _notifications.insert(0, newNotification);

                // Hiển thị popup thông báo
                _showNotificationPopup(newNotification);
              } else {
                print('Invalid notification item: $item');
              }
            }

            notifyListeners();
          } else {
            print('Invalid socket data structure: $data');
          }
        } catch (e, stackTrace) {
          print('Error parsing notification data: $e');
          print('Stack trace: $stackTrace');
        }
      });
    } else {
      print('UserId is null, cannot connect to socket');
    }
  }

  // Phương thức hiển thị popup thông báo
  void _showNotificationPopup(NotificationModel notification) {
    if (_lastContext != null && _lastContext!.mounted) {
      // Hiển thị popup thông báo
      _lastContext!.showNotificationPopup(
        notification: notification,
        onDismiss: () {
          debugPrint('Notification popup dismissed: ${notification.id}');
        },
      );
    } else {
      print('Context is null or not mounted, cannot show notification popup');
    }
  }

  void handleNotificationTap(
      NotificationModel notification, BuildContext context) async {
    if (notification.deeplink.startsWith('dnsgapp://post/')) {
      final postId = notification.deeplink.split('/').last;
      final post = notification.post;

      if (post != null) {
        // Lấy userId từ AuthProvider (giả định đây là ID người dùng hiện tại)
        final userId = await _authProvider.getuserID() ?? post.author?.id ?? '';

        // Chuyển createdAt thành String (nếu có)
        final dateFormat = DateFormat('dd/MM/yyyy');
        final dateTime = post.createdAt != null
            ? dateFormat.format(post.createdAt!)
            : DateFormat('dd/MM/yyyy').format(DateTime.now());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentsScreen(
              postId: post.id ?? postId,
              postType: post.category ?? 0,
              // Giả định category là postType
              displayName: post.author?.displayName ?? 'Không xác định',
              avatar_image: post.author?.avatarImage ?? '',
              dateTime: dateTime,
              title: post.title ?? '',
              content: post.content ?? '',
              images: post.album ?? [],
              business: post.business ?? [],
              product: post.product ?? [],
              likes: post.like ?? [],
              commentCount: post.totalComment ?? 0,
              idUser: userId,
            ),
          ),
        );
      } else {
        debugPrint('Post data is null for notification: ${notification.id}');
      }
    } else if (notification.deeplink.startsWith('dnsgapp://order/')) {
      final orderId = notification.deeplink.split('/').last;

      // Điều hướng đến màn PurchaseOrderTab với orderId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Cart(),
        ),
      );
    } else {
      debugPrint('Unhandled deeplink: ${notification.deeplink}');
    }
  }

  Future<void> fetchNotifications(BuildContext? context) async {
    if (context != null) {
      _lastContext = context;
    }

    try {
      final response = await _notificationRepository.getNotifications(_lastContext!);
      if (response.isSuccess && response.data is List) {
        _notifications = (response.data as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  void clearState() {
    super.clearState();
    _notifications = [];
  }

  @override
  void dispose() {
    print('🔴 NotificationProvider dispose() called');
    _socketService.disconnect();
    _lastContext = null;
    super.dispose();
  }
}