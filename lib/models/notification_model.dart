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
  final Posts? post; // Thêm thuộc tính Posts

  NotificationModel({
    required this.id,
    required this.userId,
    required this.uId,
    required this.message,
    required this.deeplink,
    required this.read,
    required this.timestamp,
    required this.v,
    this.post, // Thêm vào constructor
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      userId: json['userId'],
      uId: Author.fromJson(json['uId']),
      message: json['message'],
      deeplink: json['deeplink'],
      read: json['read'] ?? false, // Giá trị mặc định nếu không có
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()), // Giá trị mặc định
      v: json['__v'] ?? 0, // Giá trị mặc định nếu không có
      post: json['data'] != null ? Posts.fromJson(json['data']) : null, // Parse từ "data"
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
    'data': post?.toJson(), // Lưu lại dưới dạng "data" để khớp với socket
  };
}