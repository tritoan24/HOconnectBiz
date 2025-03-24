import 'package:intl/intl.dart';

class DateTimeUtils {
  static const String timeZone = 'Asia/Ho_Chi_Minh'; // GMT+7

  /// Chuyển đổi DateTime về múi giờ GMT+7
  static DateTime toLocalTime(DateTime dateTime) {
    return dateTime.toUtc().add(const Duration(hours: 7));
  }

  /// Chuyển đổi DateTime về múi giờ GMT+7 và format theo định dạng yêu cầu
  static String formatDateTime(DateTime dateTime,
      {String format = 'dd/MM/yyyy HH:mm'}) {
    final localDateTime = toLocalTime(dateTime);
    return DateFormat(format).format(localDateTime);
  }

  /// Chuyển đổi timestamp (milliseconds) về DateTime GMT+7
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp)
        .toUtc()
        .add(const Duration(hours: 7));
  }

  /// Chuyển đổi DateTime GMT+7 về timestamp (milliseconds)
  static int toTimestamp(DateTime dateTime) {
    return dateTime.subtract(const Duration(hours: 7)).millisecondsSinceEpoch;
  }

  /// Kiểm tra xem một DateTime có phải là ngày hôm nay không (theo GMT+7)
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final date = dateTime.toUtc().add(const Duration(hours: 7));
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  /// Lấy thời gian hiện tại theo GMT+7
  static DateTime getCurrentTime() {
    return DateTime.now().toUtc().add(const Duration(hours: 7));
  }

  /// Format comment time in a user-friendly way
  static String formatVnCommentTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = getCurrentTime();
    final commentTime = dateTime.toUtc().add(const Duration(hours: 7));

    // Check if the date is in the future
    if (commentTime.isAfter(now)) {
      return DateFormat('dd/MM/yyyy HH:mm').format(commentTime);
    }

    final difference = now.difference(commentTime);

    // Just now
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    }

    // Minutes ago
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    }

    // Hours ago
    if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    }

    // Yesterday
    if (difference.inDays == 1) {
      return 'Hôm qua';
    }

    // Days ago (up to 7 days)
    if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    }

    // For older dates, show full date
    return DateFormat('dd/MM/yyyy HH:mm').format(commentTime);
  }
}
