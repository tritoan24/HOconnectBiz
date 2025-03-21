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
  final String? conversationId;
  final String? type;
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
    this.conversationId,
    this.type,
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

    // Xử lý timestamp
    DateTime parsedTimestamp = DateTime.now();
    if (json['timestamp'] != null) {
      try {
        if (json['timestamp'] is String) {
          parsedTimestamp = DateTime.parse(json['timestamp']);
        } else if (json['timestamp'] is DateTime) {
          parsedTimestamp = json['timestamp'];
        }
      } catch (e) {
        print("Lỗi xử lý timestamp: $e");
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
      timestamp: parsedTimestamp,
      conversationId: json['conversationId']?.toString(),
      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'album': album,
    };
  }

  String getFormattedTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    // Định dạng giờ:phút
    String timeStr =
        "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

    // Nếu là ngày hôm nay thì chỉ hiển thị giờ
    if (messageDate.isAtSameMomentAs(today)) {
      return timeStr;
    }
    // Nếu khác ngày thì hiển thị thêm ngày/tháng/năm
    else {
      return "$timeStr ${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }
}

enum MessageStatus {
  sending, // Đang gửi
  sent, // Đã gửi
  error // Lỗi
}
