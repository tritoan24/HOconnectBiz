/// Cấu hình cho hệ thống báo cáo lỗi
class ErrorReportingConfig {
  /// Bật/tắt báo cáo lỗi cho từng loại
  static const bool reportNetworkErrors = true;
  static const bool reportDataErrors = true;
  static const bool reportPerformanceIssues = true;
  static const bool reportSecurityIssues = true;
  static const bool reportUserBehaviorIssues = false; // Tắt mặc định
  
  /// Ngưỡng hiệu suất (ms)
  static const int warningThresholdMs = 3000; // Cảnh báo > 3 giây
  static const int criticalThresholdMs = 8000; // Nghiêm trọng > 8 giây
  
  /// Giới hạn gửi báo cáo lỗi (để tránh spam)
  static const int maxErrorsPerHour = 50;
  static const int maxErrorsPerDay = 200;
  
  /// Mức lọc lỗi (1-3)
  /// 1: Tất cả lỗi
  /// 2: Chỉ lỗi quan trọng và nghiêm trọng
  /// 3: Chỉ lỗi nghiêm trọng
  static const int minErrorLevelToReport = 1;
  
  /// Kích hoạt/tắt các loại thông báo
  static const bool enableTelegramNotifications = true;
  static const bool enableEmailNotifications = false;
  static const bool enableInAppNotifications = false;
  
  /// Thông tin dành riêng cho từng môi trường
  static const Map<String, dynamic> environmentConfig = {
    'development': {
      'minErrorLevelToReport': 2, // Chỉ báo cáo lỗi quan trọng trở lên trong môi trường phát triển
      'enableDetailedLogging': true,
    },
    'staging': {
      'minErrorLevelToReport': 1, // Báo cáo tất cả lỗi trong môi trường staging
      'enableDetailedLogging': true,
    },
    'production': {
      'minErrorLevelToReport': 1, // Báo cáo tất cả lỗi trong môi trường production
      'enableDetailedLogging': false, // Không ghi log chi tiết trong production
    },
  };
  
  /// Chi tiết mô tả các cấp độ lỗi
  static const Map<int, String> errorLevelDescriptions = {
    1: 'Thông thường: Lỗi không ảnh hưởng đến chức năng chính',
    2: 'Quan trọng: Lỗi ảnh hưởng đến một số chức năng',
    3: 'Nghiêm trọng: Lỗi ảnh hưởng đến toàn bộ ứng dụng hoặc gây crash',
  };
} 