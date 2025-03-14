import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';

class BusinessOpRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse> joinBusiness(BuildContext context, String postId) async {
    final response = await _apiClient.putRequest(
      "${ApiEndpoints.joinBusiness}/$postId",
      context,
    );

    return ApiResponse.fromJson(response);
  }

  Future<ApiResponse> approveBusiness(
      BuildContext context, List<String> postIds) async {
    if (postIds.isEmpty) {
      return ApiResponse(
          isSuccess: false, message: "Không có doanh nghiệp nào để duyệt");
    }

    // Format data correctly
    final List<Map<String, dynamic>> requestData =
        postIds.map((id) => {"_id": id.trim()}).toList();

    // Log for debugging
    print("📌 Selected IDs: $postIds");
    print("📌 Sending JSON: ${jsonEncode(requestData)}");

    // Get API URL
    final String url = ApiEndpoints.baseUrl + ApiEndpoints.approveBusiness;

    // Get auth token
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');

    try {
      // Create headers
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': token,
      };

      // Log request details
      print("🔹 [API REQUEST] PATCH: $url");
      print("🔹 Headers: $headers");

      // Make direct PATCH request
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestData),
      );

      // Log response
      print(" [API RESPONSE] Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return ApiResponse.fromJson(responseData);
      } else {
        // Show error message
        print(
            " [API ERROR] Lỗi khi duyệt doanh nghiệp: ${response.statusCode}");

        return ApiResponse(
            isSuccess: false,
            message: "Lỗi khi duyệt doanh nghiệp: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exceptions
      print(" [API ERROR] Lỗi khi gọi API: $e");

      return ApiResponse(
          isSuccess: false, message: "Lỗi kết nối đến máy chủ: $e");
    }
  }
}
