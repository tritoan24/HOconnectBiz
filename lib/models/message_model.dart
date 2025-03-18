import 'auth_model.dart';
import 'order_model.dart';

class Message {
  final String? id;
  final Author? sender;
  final Author? receiver;
  final String content;
  final List<String> album;
  final bool read;
  final OrderModel? data;
  final DateTime timestamp;
  MessageStatus status = MessageStatus.sent;
  String? errorMessage;

  Message({
    this.id,
    this.sender,
    this.receiver,
    required this.content,
    this.album = const [],
    this.read = false,
    this.data,
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now();

  // Trong Message.fromJson
  factory Message.fromJson(Map<String, dynamic> json) {
    // Cải thiện cách xử lý dữ liệu
    List<String> albumList = [];
    if (json['album'] != null) {
      try {
        if (json['album'] is List) {
          albumList = List<String>.from(json['album']);
        } else if (json['album'] is String) {
          albumList = [json['album']];
        }
      } catch (e) {
        print("Lỗi xử lý album: $e");
      }
    }

    return Message(
      id: json['_id']?.toString(),
      sender: json['sender'] != null ? Author.fromJson(json['sender']) : null,
      receiver:
          json['receiver'] != null ? Author.fromJson(json['receiver']) : null,
      content: json['content']?.toString() ?? '',
      album: albumList,
      read: json['read'] == true,
      data: json['data'] != null ? OrderModel.fromJson(json['data']) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'album': album,
    };
  }

  String getFormattedTime() {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}

enum MessageStatus {
  sending, // Đang gửi
  sent, // Đã gửi
  error // Lỗi
}
