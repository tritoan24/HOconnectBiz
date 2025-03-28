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
  final SocketService _socketService;
  BuildContext? _lastContext;

  NotificationProvider({required SocketService socketService})
      : _socketService = socketService {
    _setupNotificationListener();
  }

  List<NotificationModel> get notifications => _notifications;

  // Phương thức để lưu trữ context cuối cùng
  void setContext(BuildContext context) {
    _lastContext = context;
  }

  void _setupNotificationListener() {
    _socketService.on('notification', (data) {
      try {
        if (data != null &&
            data['data'] != null &&
            data['data']['data'] is List) {
          final List<dynamic> notificationsList = data['data']['data'];

          for (var item in notificationsList) {
            if (item is Map<String, dynamic>) {
              final newNotification = NotificationModel.fromJson(item);
              _notifications.insert(0, newNotification);

              // // Hiển thị popup nếu có context
              // if (_lastContext != null && _lastContext!.mounted) {
              //   _lastContext!.showNotificationPopup(
              //     notification: newNotification,
              //     onDismiss: () {
              //       debugPrint('Notification dismissed: ${newNotification.id}');
              //     },
              //   );
              // }
            }
          }
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error handling notification: $e');
      }
    });
  }

  void handleNotificationTap(
      NotificationModel notification, BuildContext context) async {
    debugPrint('Handling notification tap: ${notification.deeplink}');

    if (notification.deeplink.startsWith('dnsgapp://post/')) {
      final postId = notification.deeplink.split('/').last;
      final post = notification.post;

      if (post != null) {
        final userId = await _authProvider.getuserID() ?? post.author?.id ?? '';

        // Chuyển createdAt thành String (nếu có)
        final dateFormat = DateFormat('dd/MM/yyyy');
        final dateTime = post.createdAt != null
            ? dateFormat.format(post.createdAt!)
            : DateFormat('dd/MM/yyyy').format(DateTime.now());
        if (!context.mounted) return;
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
              isJoin: post.isJoin ?? [],
            ),
          ),
        );
      } else {
        // Nếu không có post data (trường hợp trên Android), thì tải post từ API
        debugPrint('Post data is null, fetching from API for ID: $postId');
        try {
          // Giả định có một API để lấy post theo ID
          // Thay thế phần code bên dưới bằng API thực tế của bạn
          // final fetchedPost = await _postRepository.getPostById(postId);
          // Nếu bạn không có API cụ thể, có thể chuyển đến màn hình comment với ID

          // Tạm thời điều hướng với postId
          final userId = await _authProvider.getuserID() ?? '';
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentsScreen(
                postId: postId,
                postType: 0, // Giá trị mặc định
                displayName: 'Không xác định',
                avatar_image: '',
                dateTime: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                title: '',
                content: '',
                images: [],
                business: [],
                product: [],
                likes: [],
                commentCount: 0,
                idUser: userId,
              ),
            ),
          );
        } catch (e) {
          debugPrint('Error fetching post data: $e');
        }
      }
    } else if (notification.deeplink.startsWith('dnsgapp://order/')) {
      // final orderId = notification.deeplink.split('/').last;

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
      final response =
          await _notificationRepository.getNotifications(_lastContext!);
      if (response.isSuccess && response.data is List) {
        _notifications = (response.data as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  @override
  void clearState() {
    super.clearState();
    _notifications = [];
  }

  @override
  void dispose() {
    _lastContext = null;
    super.dispose();
  }
}
