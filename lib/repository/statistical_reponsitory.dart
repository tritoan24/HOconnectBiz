import 'package:flutter/cupertino.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';

class StatisticalRepository {
  final ApiClient _apiClient = ApiClient();
  Future<ApiResponse> getListStatistical(
      BuildContext context, int page, int limit) async {
    final response = await _apiClient.getRequest(
      '${ApiEndpoints.statistic}?page=$page&limit=$limit',
      context,
    );
    print(response);

    final apiResponse = ApiResponse.fromJson(response);

    return apiResponse;
  }
}
