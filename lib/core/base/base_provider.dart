// base_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/apiresponse.dart';
import '../../models/auth_model.dart';
import '../../providers/send_error_log.dart';

abstract class BaseProvider extends ChangeNotifier {
  ApiResponse? _response;
  Author? _author;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;

  ApiResponse? get user => _response;
  Author? get author => _author;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    errorMessage = message;
    notifyListeners();
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
  }) async {
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
      }
    } on SocketException catch (e) {
      setError("Không thể kết nối đến máy chủ. Kiểm tra Internet!");
      sendErrorLog(
        level: 1,
        message:
            "Doanh Nghiệp Lỗi: SocketException: Không thể kết nối đến máy chủ",
        additionalInfo: e.toString(),
      );
    } on HttpException catch (e) {
      setError("Lỗi phản hồi từ máy chủ. Vui lòng thử lại.");
      sendErrorLog(
        level: 1,
        message: "Doanh Nghiệp Lỗi: HttpException: Lỗi phản hồi từ máy chủ",
        additionalInfo: e.toString(),
      );
    } catch (e) {
      setError("Doanh Nghiệp Lỗi:${e.toString()}");
      sendErrorLog(
        level: 1,
        message: "Doanh Nghiệp Lỗi: ${e.toString()}",
        additionalInfo: e.toString(),
      );
    } finally {
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
