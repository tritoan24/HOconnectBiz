// base_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/apiresponse.dart';
import '../../models/auth_model.dart';
import '../../providers/send_error_log.dart';
import 'dart:convert';

abstract class BaseProvider extends ChangeNotifier {
  ApiResponse? _response;
  Author? _author;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;

  // Source information để trace lỗi dễ dàng hơn
  String get _providerName => runtimeType.toString();

  ApiResponse? get user => _response;
  Author? get author => _author;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    errorMessage = message;
    notifyListeners();
    
    // Ghi nhận lỗi nghiêm trọng từ API response
    if (message != null && message.isNotEmpty) {
      sendErrorLog(
        level: 1,
        message: "Lỗi Provider $_providerName",
        additionalInfo: message,
      );
    }
  }

  void setSuccess(String? message) {
    successMessage = message;
    notifyListeners();
  }

  Future<void> executeApiCall<T>({
    required Future<ApiResponse> Function() apiCall,
    required BuildContext context,
    VoidCallback? onSuccess,
    String? successMessage,
    String? operationName,
  }) async {
    final operation = operationName ?? 'API Call';
    final Stopwatch stopwatch = Stopwatch()..start();
    
    setLoading(true);
    setError(null);
    setSuccess(null);

    try {
      final response = await apiCall();

      if (response.isSuccess) {
        _response = response;
        if (successMessage != null) {
          setSuccess(successMessage);
        }
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        setError(response.message);
        
        // Báo cáo lỗi từ API response
        sendErrorLog(
          level: 2,
          message: "API Response Error in $_providerName: $operation",
          additionalInfo: "Message: ${response.message}",
        );
      }
    } on SocketException catch (e, stackTrace) {
      final errorMsg = "Không thể kết nối đến máy chủ. Kiểm tra Internet!";
      setError(errorMsg);
      
      sendErrorLog(
        level: 2,
        message: "SocketException in $_providerName: $operation",
        additionalInfo: "$errorMsg\n${e.toString()}\nStack: $stackTrace",
      );
    } on HttpException catch (e, stackTrace) {
      // Parse error message từ response
      try {
        final errorData = e.toString();
        // Chuyển string thành Map
        final Map<String, dynamic> errorMap = Map<String, dynamic>.from(
          jsonDecode(errorData.replaceAll('HttpException: ', '')),
        );
        final errorMsg = errorMap['message'] as String? ?? "Lỗi phản hồi từ máy chủ";
        setError(errorMsg);
      } catch (parseError) {
        setError("Lỗi phản hồi từ máy chủ. Vui lòng thử lại.");
      }
      
      sendErrorLog(
        level: 2,
        message: "HttpException in $_providerName: $operation",
        additionalInfo: "${e.toString()}\nStack: $stackTrace",
      );
    } on TimeoutException catch (e, stackTrace) {
      final errorMsg = "Yêu cầu hết thời gian. Vui lòng thử lại sau.";
      setError(errorMsg);
      
      sendErrorLog(
        level: 2,
        message: "TimeoutException in $_providerName: $operation",
        additionalInfo: "$errorMsg\n${e.toString()}\nStack: $stackTrace",
      );
    } on FormatException catch (e, stackTrace) {
      final errorMsg = "Lỗi định dạng dữ liệu. Vui lòng liên hệ hỗ trợ.";
      setError(errorMsg);
      
      sendErrorLog(
        level: 3, // Nghiêm trọng
        message: "FormatException in $_providerName: $operation",
        additionalInfo: "$errorMsg\n${e.toString()}\nStack: $stackTrace",
      );
    } catch (e, stackTrace) {
      final errorMsg = "Đã xảy ra lỗi không xác định.";
      setError(errorMsg);
      
      sendErrorLog(
        level: 3,
        message: "Unhandled Exception in $_providerName: $operation",
        additionalInfo: "$errorMsg\n${e.toString()}\nStack: $stackTrace",
      );
    } finally {
      stopwatch.stop();
      
      // Log nếu API call quá lâu (hơn 5 giây)
      if (stopwatch.elapsedMilliseconds > 5000) {
        sendErrorLog(
          level: 1,
          message: "Slow Operation in $_providerName: $operation",
          additionalInfo: "Duration: ${stopwatch.elapsedMilliseconds}ms",
        );
      }
      
      setLoading(false);
    }
  }

  void clearState() {
    _response = null;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
