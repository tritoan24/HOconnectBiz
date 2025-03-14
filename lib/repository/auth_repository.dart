import 'package:clbdoanhnhansg/core/network/api_endpoints.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import '../models/apiresponse.dart';
import '../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  //🔹 **Đăng Nhập**
  Future<ApiResponse> login(
      String username, String password, BuildContext context) async {
    final response = await _apiClient.postRequest(
        ApiEndpoints.login,
        {
          "identity": username,
          "password": password,
        },
        context);

    return ApiResponse.fromJson(response);
  }

  //🔹 **Đăng Ký**
  Future<ApiResponse> register(String identity, String password,
      String repassword, String displayName, BuildContext context) async {
    final response = await _apiClient.postRequest(
        ApiEndpoints.register,
        {
          "identity": identity,
          "password": password,
          "repassword": repassword,
          "displayName": displayName,
        },
        context);
    return ApiResponse.fromJson(response);
  }

  // 🔹 **Đăng xuất**
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'auth_token'); // Xóa token khỏi storage
    } catch (e) {
      throw Exception("Lỗi khi đăng xuất: ${e.toString()}");
    }
  }

  // 🔹 **Quên mật khẩu**
  Future<ApiResponse> sendOtpEmail(String email, BuildContext context) async {
    final response = await _apiClient.postRequest(
        ApiEndpoints.sendOtpEmail,
        {
          "email": email,
        },
        context);

    return ApiResponse.fromJson(response);
  }

  // 🔹 **Quên mật khẩu nhập mã**
  Future<ApiResponse> inputOtp(String email, code, BuildContext context) async {
    final response = await _apiClient.postRequest(
        ApiEndpoints.inputOtp,
        {
          "email": email,
          "code": code,
        },
        context);

    return ApiResponse.fromJson(response);
  }

  // 🔹 **Cập nhật mật khẩu mới- quên mật khẩu**
  Future<ApiResponse> resetpassword(
      String password, newpassword, repassword, BuildContext context) async {
    final response = await _apiClient.postRequest(
        ApiEndpoints.newPassForgot,
        {"password": password, "newpassword": newpassword, "repassword": repassword},
        context);

    return ApiResponse.fromJson(response);
  }
  // 🔹 **Cập nhật mật khẩu mới- đổi mật khẩu**
  Future<ApiResponse> changepassword(
      String password, newpassword, repassword, BuildContext context) async {
    final response = await _apiClient.postRequest(
        ApiEndpoints.changePassword,
        {"password": password, "newpassword": newpassword, "repassword": repassword},
        context);

    return ApiResponse.fromJson(response);
  }

  // 🔹 **Đăng nhập với mạng xã hội **
  Future<ApiResponse> loginSocial(String identity, String password,
      String displayName, String registerType,String avatarImage, BuildContext context) async {
    const String tag = 'LOGINSOCIAL_REPO';
    developer.log('identity: $identity', name: tag);
    developer.log('password: $password', name: tag);
    developer.log('displayName: $displayName', name: tag);
    developer.log('registerType: $registerType', name: tag);

    final response = await _apiClient.postRequest(
        ApiEndpoints.loginSocial,
        {
          "identity": identity,
          "password": password,
          "repassword": password,
          "displayName": displayName,
          "register_type": registerType,
          "avatar_image": avatarImage,
        },
        context);

    return ApiResponse.fromJson(response);
  }
}

