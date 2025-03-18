import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../providers/send_error_log.dart';

class ErrorHandler {
  // Singleton pattern
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Thiết lập bắt lỗi trên toàn ứng dụng
  void setupErrorHandling() {
    // Bắt lỗi Flutter framework
    FlutterError.onError = (FlutterErrorDetails details) {
      _reportError(
        details.exception,
        details.stack,
        'Flutter Framework Error',
      );
      // Vẫn hiển thị lỗi gỡ lỗi trong chế độ debug
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // Bắt lỗi không được xử lý trong Zone
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportError(error, stack, 'Platform Dispatcher Error');
      return true;
    };
  }

  // Bắt lỗi từ Future
  Future<T> runWithErrorHandling<T>(Future<T> Function() asyncFunction) async {
    try {
      return await asyncFunction();
    } catch (e, stack) {
      _reportError(e, stack, 'Async Function Error');
      rethrow;
    }
  }

  // Gửi báo cáo lỗi
  void _reportError(dynamic error, StackTrace? stack, String source) {
    int errorLevel = 1;
    
    // Phân loại mức độ nghiêm trọng của lỗi
    if (error is SocketException || error is HttpException || error is TimeoutException) {
      errorLevel = 2; // Lỗi mạng - nghiêm trọng
    } else if (error is FormatException || error is TypeError) {
      errorLevel = 3; // Lỗi dữ liệu - rất nghiêm trọng
    }

    final errorMessage = '[${DateTime.now()}] $source: ${error.toString()}';
    final stackTrace = stack?.toString() ?? 'Không có thông tin stack trace';
    
    sendErrorLog(
      level: errorLevel,
      message: errorMessage,
      additionalInfo: stackTrace,
    );
  }
  
  // Bắt lỗi trong khối try-catch
  void logError(dynamic error, {StackTrace? stackTrace, String? context}) {
    _reportError(
      error, 
      stackTrace ?? StackTrace.current,
      context ?? 'Manual Error Log',
    );
  }
} 