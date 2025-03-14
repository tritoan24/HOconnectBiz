import 'package:flutter/cupertino.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';

class BannerRepository {
  final ApiClient _apiClient = ApiClient();
  Future<ApiResponse> getBanner(BuildContext context) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.banner,
      context,
    );
    print(response);

    final apiResponse = ApiResponse.fromJson(response);

    return apiResponse;
  }
}
