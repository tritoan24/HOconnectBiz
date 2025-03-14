import 'package:flutter/cupertino.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';

class RankRepository {
  final ApiClient _apiClient = ApiClient();
  Future<ApiResponse> getRankRevenue(BuildContext context) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.rankRevenue,
      context,
    );
    print(response);

    final apiResponse = ApiResponse.fromJson(response);

    return apiResponse;
  }

  Future<ApiResponse> getRankBusiness(BuildContext context) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.rankBusiness,
      context,
    );
    print(response);

    final apiResponse = ApiResponse.fromJson(response);

    return apiResponse;
  }
}
