import 'package:clbdoanhnhansg/screens/cart/cart_tab.dart';
import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../core/base/base_provider.dart';
import '../repository/notification_repository.dart';
import '../core/services/socket_service.dart';
import '../screens/cart/widget/purchase_order_tab.dart';
import 'auth_provider.dart';
import '../../screens/comment/comments_screen.dart'; // Import CommentsScreen
import 'package:intl/intl.dart'; // Để định dạng dateTime

class NotificationProvider extends BaseProvider {
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  final AuthProvider _authProvider = AuthProvider();
  List<NotificationModel> _notifications = [];
  late SocketService _socketService;

  NotificationProvider() {
    _socketService = SocketService();
    _init();
  }

  List<NotificationModel> get notifications => _notifications;

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
                _notifications.insert(0, newNotification);
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
    try {
      final response = await _notificationRepository.getNotifications(context!);
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
    super.dispose();
  }
}
