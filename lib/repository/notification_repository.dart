import 'package:clbdoanhnhansg/models/apiresponse.dart';
import 'package:flutter/cupertino.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class NotificationRepository {
  final ApiClient _apiClient = ApiClient();
  Future<ApiResponse> getNotifications(BuildContext context) async {
    try {
      final response = await _apiClient.getRequest(
        ApiEndpoints.notification,
        context,
      );

      return ApiResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}

