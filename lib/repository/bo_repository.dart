import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';
import '../models/rating_model.dart';

class BoRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse> getBoData(BuildContext context) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.boDataIn,
      context,
    );

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }

  Future<ApiResponse> getBoDataOut(BuildContext context) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.boDataOut,
      context,
    );

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }

  //get bo data by id
  Future<ApiResponse> getBoDataById(BuildContext context, String id) async {
    final response = await _apiClient.getRequest(
      '${ApiEndpoints.joinBusiness}/$id',
      context,
    );

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }

  //xóa bo data
  Future<ApiResponse> deleteBoData(
      BuildContext context, String idPost, idMember) async {
    final response = await _apiClient.deleteRequest(
      '${ApiEndpoints.bodeleteMember}/$idPost',
      context,
      body: {"id": idMember},
    );

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }

  //ket thuc bo
  Future<ApiResponse> endBoData(BuildContext context, String id) async {
    final response = await _apiClient.deleteRequest(
      '${ApiEndpoints.boEnd}/$id',
      context,
    );

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }

  //roi bo
  Future<ApiResponse> leaveBo(BuildContext context, String id) async {
    final response = await _apiClient.deleteRequest(
      '${ApiEndpoints.boLeave}/$id',
      context,
    );

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }

  Future<ApiResponse> createRating(
    String postId,
    List<String> picked,
    int star,
    String content,
    BuildContext context,
  ) async {
    final Map<String, dynamic> body = {
      'picked': picked,
      'star': star,
      'content': content,
    };

    final response = await _apiClient.pacthJsonRequest(
        '${ApiEndpoints.boReview}/$postId', context,
        body: body);

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }

  /// Get rating criteria for business opportunities
  Future<ApiResponse> getListRating(BuildContext context) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.boCriteria,
      context,
    );

    return ApiResponse.fromJson(response);
  }

  // update revenue
  Future<ApiResponse> updateRevenue(
    String postId,
    int status,
    int revenue,
    int deduction,
    BuildContext context,
  ) async {
    final Map<String, dynamic> body = {
      'status': status,
      'revenue': revenue,
      'deduction': deduction,
    };

    final response = await _apiClient.pacthJsonRequest(
        '${ApiEndpoints.joinBusiness}/$postId', context,
        body: body);

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }

  // Tìm kiếm doanh nghiệp
  Future<ApiResponse> searchBusinesses(BuildContext context, String keyword) async {
    final response = await _apiClient.getRequest(
      '${ApiEndpoints.baseUrl}/company?keyword=$keyword',
      context,
    );

    final apiResponse = ApiResponse.fromJson(response);
    return apiResponse;
  }
}
