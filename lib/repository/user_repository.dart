import 'dart:io';

import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';
import '../models/auth_model.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Author?> fetchUser(BuildContext context) async {
    try {
      final response = await _apiClient.getRequest(
        ApiEndpoints.user,
        context,
      );

      if (response['status'] == 'success' && response['user'] != null) {
        return Author.fromJson(response['user']);
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user: $e');
      rethrow; // Ném lỗi để provider xử lý
    }
  }

  Future<ApiResponse> updateUser(
    BuildContext context,
    Map<String, dynamic> body, {
    List<File>? avatarFiles,
    List<File>? coverFiles,
  }) async {
    try {
      final Map<String, List<File>> fileFields = {
        'avatar_image': avatarFiles ?? [],
        'cover_image': coverFiles ?? [],
      };
      print('🔹 [UPDATE USER] Body: $body');
      print('🔹 [UPDATE USER] File Fields: $fileFields');

      final response = await _apiClient.patchRequest(
        ApiEndpoints.user,
        context,
        body: body,
        files: fileFields.isNotEmpty ? fileFields : null,
      );

      print('🔹 [UPDATE USER] Response: $response');
      // Xử lý response để trả về ApiResponse
      if (response['message'] == 'Cập nhật thông tin thành công') {
        return ApiResponse(
          isSuccess: true,
          message:
              response['message'] ?? 'Cập nhật thông tin người dùng thành công',
          data: response['user'] != null
              ? Author.fromJson(response['user'])
              : null,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message:
              response['message'] ?? 'Lỗi khi cập nhật thông tin người dùng',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Lỗi khi cập nhật thông tin người dùng: $e',
        data: null,
      );
    }
  }

  Future<Author?> fetchUserById(BuildContext context, String id) async {
    try {
      final response = await _apiClient.getRequest(
        '${ApiEndpoints.getUserByID}/$id',
        context,
      );

      if (response['status'] == 'success' && response['user'] != null) {
        return Author.fromJson(response['user']);
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user: $e');
      rethrow; // Ném lỗi để provider xử lý
    }
  }
}
