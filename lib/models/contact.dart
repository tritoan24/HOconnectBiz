import '../utils/router/router.name.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class Contact {
  final String id;
  final String? contactId;
  final String displayName;
  final dynamic avatarImage;
  final String? username;
  final String? userId;
  final String? type;
  final LastMessage lastMessage;

  Contact({
    required this.id,
    this.contactId,
    required this.displayName,
    required this.avatarImage,
    this.username,
    this.userId,
    this.type,
    required this.lastMessage,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    // Handle avatar_image which can be a string, a list, or missing
    dynamic avatarImage;
    if (json['avatar_image'] == null ||
        json['avatar_image'] == '' ||
        json['avatar_image'] == 'Không có ảnh') {
      avatarImage = UrlImage.defaultContactImage;
    } else if (json['avatar_image'] is List) {
      // Keep as list if it's already a list
      avatarImage = json['avatar_image'];
    } else {
      // Convert to string for single avatar
      avatarImage = json['avatar_image'].toString();
    }

    // Safely parse lastMessage
    Map<String, dynamic> lastMessageJson = {};
    if (json['lastMessage'] != null &&
        json['lastMessage'] is Map<String, dynamic>) {
      lastMessageJson = json['lastMessage'];
    }

    return Contact(
      id: json['_id'] ?? '',
      contactId: json['contactId'] ?? '',
      displayName: json['displayName'] ?? 'No Name',
      avatarImage: avatarImage,
      username: json['username'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: json['type'] ?? '',
      lastMessage: LastMessage.fromJson(lastMessageJson),
    );
  }

  static List<Contact> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => Contact.fromJson(item)).toList();
  }

  String getFormattedTime() {
    try {
      // Xử lý chuỗi thời gian từ createdAt
      String dateString = lastMessage.createdAt;

      // Loại bỏ thông tin múi giờ
      if (dateString.contains('+')) {
        dateString = dateString.substring(0, dateString.indexOf('+'));
      }

      // Parse chuỗi đã chỉnh sửa
      DateTime dateTime = DateTime.parse(dateString);

      // Lấy ngày hiện tại và ngày hôm qua để so sánh
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

      // Định dạng dựa trên khoảng cách thời gian
      if (dateOnly == today) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (dateOnly == yesterday) {
        return "Hôm qua";
      } else if (now.difference(dateTime).inDays < 7) {
        // Sử dụng locale tiếng Việt cho định dạng ngày trong tuần
        // Đảm bảo bạn đã import gói intl và khởi tạo locale
        return DateFormat.EEEE('vi').format(dateTime);
      } else {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } catch (e) {
      print("Error parsing date: ${lastMessage.createdAt} - Error: $e");
      return lastMessage.createdAt;
    }
  }
}

class LastMessage {
  final String content;
  final String createdAt;

  LastMessage({required this.content, required this.createdAt});

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    String content = '';
    String createdAt = '';

    // Safely extract content
    if (json['content'] != null) {
      content = json['content'].toString();
    }

    // Safely extract createdAt
    if (json['createdAt'] != null && json['createdAt'] != "NaN:NaN") {
      createdAt = json['createdAt'].toString();
    }

    return LastMessage(
      content: content,
      createdAt: createdAt,
    );
  }
}
