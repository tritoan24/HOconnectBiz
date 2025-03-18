import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../error/error_handler.dart';
import 'app_logger.dart';
import '../../providers/send_error_log.dart';

/// Lớp hỗ trợ gửi báo cáo lỗi và kiểm tra hệ thống báo cáo lỗi
class ErrorReporter {
  /// Kiểm tra hệ thống báo cáo lỗi
  static Future<bool> testErrorReporting() async {
    try {
      // Thử ghi log và gửi báo cáo lỗi kiểm tra
      await sendErrorLog(
        level: 1,
        message: "Kiểm tra hệ thống báo cáo lỗi",
        additionalInfo: "Đây là bản ghi kiểm tra từ ErrorReporter.testErrorReporting()",
      );
      
      // Ghi log bằng AppLogger
      AppLogger().info(
        "ErrorReporter",
        "Test",
        "Kiểm tra hệ thống log",
      );
      
      return true;
    } catch (e) {
      debugPrint("Lỗi khi kiểm tra hệ thống báo cáo: $e");
      return false;
    }
  }

  /// Báo cáo lỗi kết nối API
  static void reportApiError(
    String endpoint,
    dynamic error,
    StackTrace? stackTrace,
    {int level = 2}
  ) {
    final errorMessage = "Lỗi API: $endpoint";
    final stackStr = stackTrace?.toString() ?? "";
    
    sendErrorLog(
      level: level,
      message: errorMessage,
      additionalInfo: "${error.toString()}\n$stackStr",
    );
    
    AppLogger().error(
      "API", 
      endpoint, 
      error.toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Báo cáo lỗi xử lý dữ liệu
  static void reportDataError(
    String source,
    String message,
    dynamic error,
    StackTrace? stackTrace,
    {int level = 2}
  ) {
    sendErrorLog(
      level: level,
      message: "Lỗi dữ liệu: $source - $message",
      additionalInfo: "${error.toString()}\n${stackTrace?.toString() ?? ''}",
    );
    
    AppLogger().error(
      "Data", 
      source, 
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Báo cáo lỗi nghiêm trọng
  static void reportCritical(
    String source,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    ErrorHandler().logError(
      error,
      stackTrace: stackTrace,
      context: "$source: $message",
    );
    
    AppLogger().fatal(
      "Critical", 
      source, 
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Báo cáo hiệu suất chậm
  static void reportPerformanceIssue(
    String operation,
    int durationMs,
    {String details = ""}
  ) {
    if (durationMs > 3000) { // Báo cáo nếu > 3 giây
      final level = durationMs > 10000 ? 2 : 1; // Nghiêm trọng hơn nếu > 10 giây
      
      sendErrorLog(
        level: level,
        message: "Vấn đề hiệu suất: $operation (${durationMs}ms)",
        additionalInfo: details,
      );
      
      AppLogger().warn(
        "Performance", 
        operation, 
        "Thời gian thực hiện: ${durationMs}ms - $details"
      );
    }
  }
  
  /// Báo cáo hành vi người dùng bất thường (nếu cần)
  static void reportAbnormalUserBehavior(
    String userId,
    String behavior,
    {String details = "", int level = 1}
  ) {
    sendErrorLog(
      level: level,
      message: "Hành vi bất thường: $behavior (User: $userId)",
      additionalInfo: details,
    );
    
    AppLogger().warn(
      "UserBehavior", 
      "User_$userId", 
      "Hành vi: $behavior\n$details"
    );
  }
} 