import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/send_error_log.dart';

/// Logger tập trung để quản lý tất cả log trong ứng dụng
class AppLogger {
  // Singleton pattern
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  // Log levels
  static const int TRACE = 0;
  static const int DEBUG = 1;
  static const int INFO = 2;
  static const int WARN = 3;
  static const int ERROR = 4;
  static const int FATAL = 5;

  bool _isInitialized = false;
  String _logDirectory = "";

  /// Khởi tạo logger
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Lấy thư mục ứng dụng để lưu log
      final directory = await getApplicationDocumentsDirectory();
      _logDirectory = "${directory.path}/CLBDoanhNhanSG";
      
      // Tạo thư mục nếu chưa tồn tại
      final logDir = Directory(_logDirectory);
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      final exportDir = Directory("$_logDirectory/Exported");
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      _isInitialized = true;
      info("AppLogger", "Logger", "Logger đã được khởi tạo thành công");
    } catch (e, stack) {
      debugPrint("❌ Lỗi khởi tạo logger: $e");
      if (!kDebugMode) {  // Chỉ gửi báo cáo lỗi trong môi trường production
        sendErrorLog(
          level: 1,
          message: "Lỗi khởi tạo logger",
          additionalInfo: "${e.toString()} - Stack: $stack",
        );
      }
    }
  }

  /// Viết log vào file
  Future<void> _writeLogToFile(String logType, String tag, String subTag, String message) async {
    if (!_isInitialized) return;
    
    try {
      final now = DateTime.now();
      final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      
      final logFile = File("$_logDirectory/$logType-$date.log");
      final logEntry = "[$time] [$tag] [$subTag] $message\n";
      
      if (!await logFile.exists()) {
        await logFile.create(recursive: true);
      }
      
      await logFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      debugPrint("❌ Lỗi ghi log: $e");
    }
  }

  /// Log debug message
  void debug(String tag, String subTag, String message) {
    debugPrint("🔍 DEBUG [$tag] $subTag: $message");
    _writeLogToFile("DEBUG", tag, subTag, message);
  }

  /// Log info message
  void info(String tag, String subTag, String message) {
    debugPrint("ℹ️ INFO [$tag] $subTag: $message");
    _writeLogToFile("INFO", tag, subTag, message);
  }

  /// Log warning message
  void warn(String tag, String subTag, String message) {
    debugPrint("⚠️ WARN [$tag] $subTag: $message");
    _writeLogToFile("WARN", tag, subTag, message);
  }

  /// Log error message
  void error(String tag, String subTag, String message, {dynamic error, StackTrace? stackTrace}) {
    final errorStr = error != null ? " - Error: $error" : "";
    final stackStr = stackTrace != null ? "\nStack: $stackTrace" : "";
    
    debugPrint("❌ ERROR [$tag] $subTag: $message$errorStr$stackStr");
    _writeLogToFile("ERROR", tag, subTag, "$message$errorStr$stackStr");
    
    // Gửi báo cáo lỗi nghiêm trọng
    if (!kDebugMode) {  // Chỉ gửi báo cáo lỗi trong môi trường production
      sendErrorLog(
        level: 2,
        message: "[$tag] $subTag: $message",
        additionalInfo: "$errorStr$stackStr",
      );
    }
  }

  /// Log critical error message
  void fatal(String tag, String subTag, String message, {dynamic error, StackTrace? stackTrace}) {
    final errorStr = error != null ? " - Error: $error" : "";
    final stackStr = stackTrace != null ? "\nStack: $stackTrace" : "";
    
    debugPrint("💀 FATAL [$tag] $subTag: $message$errorStr$stackStr");
    _writeLogToFile("FATAL", tag, subTag, "$message$errorStr$stackStr");
    
    // Gửi báo cáo lỗi nghiêm trọng
    sendErrorLog(
      level: 3,
      message: "CRITICAL: [$tag] $subTag: $message",
      additionalInfo: "$errorStr$stackStr",
    );
  }

  /// Xuất log ra file
  Future<String?> exportLogs() async {
    try {
      if (!_isInitialized) {
        return null;
      }
      
      final now = DateTime.now();
      final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final timeStr = "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      
      final exportFileName = "logs_export_$dateStr$timeStr.zip";
      final exportPath = "$_logDirectory/Exported/$exportFileName";
      
      // Mở thư mục chứa log
      final logDir = Directory(_logDirectory);
      if (!await logDir.exists()) {
        return null;
      }
      
      // Liệt kê các file log
      final entities = await logDir.list().toList();
      final logFiles = entities.whereType<File>().where((file) => file.path.endsWith('.log')).toList();
      
      if (logFiles.isEmpty) {
        debugPrint("Không có file log để xuất");
        return null;
      }
      
      // Tạo file zip để xuất các log
      // Chỉ mở file explorer tới thư mục chứa log
      final exportDir = Directory("$_logDirectory/Exported");
      return exportDir.path;
    } catch (e, stack) {
      debugPrint("❌ Lỗi khi xuất log: $e");
      sendErrorLog(
        level: 1,
        message: "Lỗi khi xuất log",
        additionalInfo: "${e.toString()} - Stack: $stack",
      );
      return null;
    }
  }

  /// Xóa log cũ
  Future<void> clearOldLogs({int daysToKeep = 7}) async {
    try {
      if (!_isInitialized) {
        return;
      }
      
      final logDir = Directory(_logDirectory);
      if (!await logDir.exists()) {
        return;
      }
      
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: daysToKeep));
      
      final entities = await logDir.list().toList();
      final logFiles = entities.whereType<File>().where((file) => file.path.endsWith('.log')).toList();
      
      for (var file in logFiles) {
        final fileName = file.path.split('/').last;
        // Phân tích ngày từ tên file (định dạng TYPE-YYYY-MM-DD.log)
        final datePart = fileName.split('-');
        if (datePart.length >= 3) {
          try {
            final year = int.parse(datePart[1]);
            final month = int.parse(datePart[2]);
            final day = int.parse(datePart[3].split('.').first);
            
            final fileDate = DateTime(year, month, day);
            if (fileDate.isBefore(cutoffDate)) {
              await file.delete();
              debugPrint("Đã xóa log cũ: ${file.path}");
            }
          } catch (e) {
            // Bỏ qua nếu không thể phân tích tên file
          }
        }
      }
      
      info("AppLogger", "ClearLogs", "Đã xóa log cũ");
    } catch (e, stack) {
      debugPrint("❌ Lỗi khi xóa log cũ: $e");
      sendErrorLog(
        level: 1,
        message: "Lỗi khi xóa log cũ",
        additionalInfo: "${e.toString()} - Stack: $stack",
      );
    }
  }
} 