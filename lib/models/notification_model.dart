import 'package:clbdoanhnhansg/models/auth_model.dart';
import 'package:clbdoanhnhansg/models/posts.dart';

class NotificationModel {
  final String id;
  final String userId;
  final Author uId;
  final String message;
  final String deeplink;
  final bool read;
  final DateTime timestamp;
  final int v;
  final Posts? post;
  final String? orderCode;
  final String? userCreate;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.uId,
    required this.message,
    required this.deeplink,
    required this.read,
    required this.timestamp,
    required this.v,
    this.post,
    this.orderCode,
    this.userCreate,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        id: json['_id'],
        userId: json['userId'],
        uId: Author.fromJson(json['uId']),
        message: json['message'],
        deeplink: json['deeplink'],
        read: json['read'] ?? false,
        // Giá trị mặc định nếu không có
        timestamp: DateTime.parse(
            json['timestamp'] ?? DateTime.now().toIso8601String()),
        // Giá trị mặc định
        v: json['__v'] ?? 0,
        // Giá trị mặc định nếu không có
        post: json['data'] != null ? Posts.fromJson(json['data']) : null,
        orderCode: json['orderCode'],
        userCreate: json['userCreate']);
  }

  // Constructor cho trường hợp tạo từ dữ liệu thông báo OneSignal
  factory NotificationModel.fromNotificationData(Map<String, dynamic> data) {
    final String notificationId = data['id'] ?? '';
    final String message = data['message'] ?? '';
    final String deeplink = data['deeplink'] ?? 'dnsgapp://notification';
    
    // Tạo đối tượng Author giả
    final Author defaultAuthor = Author(
      id: '',
      displayName: '',
      avatarImage: '',
      username: '',
      level: 0,
      registerType: '0',
      coverImage: '',
      description: '',
      business: [],
      companyName: '',
      address: '',
      companyDescription: '',
      email: '',
      gender: '0',
      status: '0',
      phone: '',
      roleCode: 0,
      type: '0',
      userId: '', // Thêm userId bắt buộc
    );
    
    return NotificationModel(
      id: notificationId,
      userId: '',  // Giá trị mặc định
      uId: defaultAuthor,
      message: message,
      deeplink: deeplink,
      read: false,
      timestamp: DateTime.now(),
      v: 0,
      // Các trường khác có thể là null
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'uId': uId.toJson(),
        'message': message,
        'deeplink': deeplink,
        'read': read,
        'timestamp': timestamp.toIso8601String(),
        '__v': v,
        'data': post?.toJson(),
        'orderCode': orderCode,
        'userCreate': userCreate,
      };
}
