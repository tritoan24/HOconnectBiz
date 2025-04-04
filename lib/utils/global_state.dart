// lib/utils/global_state.dart
class GlobalAppState {
  static bool launchedFromNotification = false;
  static bool notificationProcessed = false;
  static Map<String, dynamic>? notificationData;
  static String? pendingCartNavigationType;
  
  // Phương thức tiện ích để xử lý dữ liệu notification
  static void setNotificationData(Map<String, dynamic>? data) {
    if (data != null) {
      launchedFromNotification = true;
      notificationProcessed = false;
      notificationData = data;
    }
  }
  
  // Làm sạch dữ liệu notification sau khi xử lý
  static void clearNotificationData() {
    launchedFromNotification = false;
    notificationProcessed = true;
    notificationData = null;
  }
  
  // Kiểm tra và làm sạch pendingCartNavigation
  static String? checkAndClearPendingCartNavigation() {
    final type = pendingCartNavigationType;
    pendingCartNavigationType = null;
    return type;
  }
}
