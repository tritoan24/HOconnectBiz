import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';
import '../providers/send_error_log.dart';

class StatisticalRepository {
  final ApiClient _apiClient = ApiClient();
  int _retryCount = 0;
  final int _maxRetry = 2;
  
  Future<ApiResponse> getListStatistical(
      BuildContext context, int page, int limit) async {
    try {
      final response = await _apiClient.getRequest(
        '${ApiEndpoints.statistic}?page=$page&limit=$limit',
        context,
      );
      
      debugPrint("📊 StatisticalRepository: Nhận dữ liệu thành công");
      
      // Reset retry counter on success
      _retryCount = 0;
      
      final apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e, stackTrace) {
      // Xử lý trường hợp lỗi redirect hoặc lỗi mạng
      if (e is SocketException || 
          e.toString().contains("Location header") || 
          e.toString().contains("redirect")) {
        
        debugPrint("⚠️ StatisticalRepository: Lỗi mạng hoặc redirect - ${e.toString()}");
        
        // Ghi log lỗi
        sendErrorLog(
          level: 2,
          message: "Lỗi Repository Statistical - Mạng/Redirect",
          additionalInfo: "${e.toString()}\n${stackTrace.toString()}",
        );
        
        // Tự động thử lại với số lần giới hạn
        if (_retryCount < _maxRetry) {
          _retryCount++;
          debugPrint("🔄 StatisticalRepository: Thử kết nối lại lần $_retryCount");
          await Future.delayed(Duration(seconds: 1));
          return getListStatistical(context, page, limit);
        }
      }
      
      // Log lỗi chi tiết
      sendErrorLog(
        level: 2,
        message: "Lỗi StatisticalRepository",
        additionalInfo: "${e.toString()}\n${stackTrace.toString()}",
      );
      
      // Trả về response lỗi
      return ApiResponse(
        isSuccess: false,
        message: "Không thể tải dữ liệu thống kê: ${e.toString()}",
        data: [],
        total: 0,
      );
    }
  }
}
