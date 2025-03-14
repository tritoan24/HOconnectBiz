import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../core/base/base_provider.dart';
import '../repository/notification_repository.dart';
import '../core/services/socket_service.dart';
import 'auth_provider.dart';

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
    // Lấy userId từ AuthProvider
    final userId = await _authProvider.getuserID();

    if (userId != null) {
      // Truyền deviceId vào connect thay vì userId
      _socketService.connect(userId);

      _socketService.on('notification', (data) {
        try {
          print('ON NOTIFICATION ');
          print('DATA: $data');

          if (data['data'] != null && data['data']['data'] is List) {
            List<dynamic> notificationsList = data['data']['data'];
            print('CHECKING DATA ');
            print('notificationsList : $notificationsList');

            for (var item in notificationsList) {
              print('parsing data');

              final newNotification = NotificationModel.fromJson(item);
              print('newNotification: $newNotification ');
              _notifications.insert(0, newNotification);
            }

            notifyListeners();
          }
        } catch (e) {
          print('Error parsing new notification: $e');
        }
      });
    } else {
      print('UserId is null, cannot connect to socket');
    }

    // fetchNotifications(null);
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
