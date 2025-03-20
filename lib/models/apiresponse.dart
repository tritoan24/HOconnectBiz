import 'package:flutter/foundation.dart';

class ApiResponse<T> {
  final String? token;
  final String? message;
  final bool isSuccess;
  final T? data;
  final int? total;
  final String? idUser;

  ApiResponse({
    this.token,
    this.message,
    required this.isSuccess,
    this.data,
    this.total,
    this.idUser,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý trường hợp response không có định dạng mong đợi
      if (json == null) {
        return ApiResponse(
          isSuccess: false,
          message: "Response không hợp lệ",
          data: null,
        );
      }
      
      // Kiểm tra nếu response có trường status
      final bool success = json.containsKey('status') 
          ? json['status'] == 'success' || json['status'] == true || json['status'] == 1
          : false;
      
      // Kiểm tra thông điệp lỗi
      String? message;
      if (json.containsKey('message')) {
        message = json['message']?.toString();
      } else if (json.containsKey('error')) {
        message = json['error']?.toString();
      }
      
      // Xử lý dữ liệu trả về
      dynamic data;
      if (json.containsKey('data')) {
        data = json['data'];
      } else if (success && !json.containsKey('data')) {
        // Trường hợp không có trường data nhưng thành công, lấy tất cả trừ status và message
        final tempJson = Map<String, dynamic>.from(json);
        tempJson.remove('status');
        tempJson.remove('message');
        tempJson.remove('total');
        data = tempJson;
      }
      
      // Xử lý total nếu có
      int? total;
      if (json.containsKey('total') && json['total'] != null) {
        total = int.tryParse(json['total'].toString()) ?? 0;
      }
      
      // Lấy token và userID từ response nếu có
      String? token = json['token'];
      String? idUser = json['userID'] ?? json['idUser'];
      
      if (success && kDebugMode) {
        print("🔑 Đọc từ API Response - Token: ${token != null ? 'Có token' : 'Không có token'}");
        print("🔑 Đọc từ API Response - UserID: ${idUser != null ? idUser : 'Không có userID'}");
      }
      
      return ApiResponse(
        isSuccess: success,
        message: message,
        data: data,
        total: total,
        token: token,
        idUser: idUser,
      );
    } catch (e) {
      print("Lỗi khi xử lý API response: $e");
      return ApiResponse(
        isSuccess: false,
        message: "Lỗi xử lý dữ liệu: ${e.toString()}",
        data: null,
      );
    }
  }

  static ApiResponse<T> success<T>(T data,
      {String? message, String? token, String? idUser}) {
    return ApiResponse<T>(
      isSuccess: true,
      data: data,
      message: message,
      token: token,
      idUser: idUser,
    );
  }

  static ApiResponse<T> error<T>(String message,
      {T? data, String? token, String? idUser}) {
    return ApiResponse<T>(
      isSuccess: false,
      message: message,
      data: data,
      token: token,
      idUser: idUser,
    );
  }
}
