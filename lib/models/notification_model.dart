import 'package:clbdoanhnhansg/models/auth_model.dart';

class NotificationModel {
  final String id;
  final String userId;
  final Author uId;
  final String message;
  final bool read;
  final DateTime timestamp;
  final int v;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.uId,
    required this.message,
    required this.read,
    required this.timestamp,
    required this.v,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      userId: json['userId'],
      uId: Author.fromJson(json['uId']),
      message: json['message'],
      read: json['read'],
      timestamp: DateTime.parse(json['timestamp']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'uId': uId.toJson(),
        'message': message,
        'read': read,
        'timestamp': timestamp.toIso8601String(),
        '__v': v,
      };
}

