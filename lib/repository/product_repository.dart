import 'dart:io';

import 'package:flutter/cupertino.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/apiresponse.dart';

class ProductRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse> createProduct(
    ProductModel product,
    BuildContext context, {
    List<File>? files,
  }) async {
    final Map<String, List<File>> fileFields = {
      'album': files ?? [],
    };
    final response = await _apiClient.putRequest(
      ApiEndpoints.product,
      body: product.toJson(),
      context,
      files: fileFields,
    );

    return ApiResponse.fromJson(response);
  }

  Future<ApiResponse> getListProduct(BuildContext context) async {
    print('🚀 ProductRepository: Calling getListProduct');

    final response = await _apiClient.getRequest(
      ApiEndpoints.product,
      context,
    );

    print('📥 ProductRepository: Raw API Response:');
    print(response);

    final apiResponse = ApiResponse.fromJson(response);

    print('🔄 ProductRepository: Parsed ApiResponse:');
    print('Status: ${apiResponse.isSuccess}');
    print('Message: ${apiResponse.message}');
    print('Data length: ${apiResponse.data?.length ?? 0}');

    return apiResponse;
  }

  Future<ApiResponse> editProduct(
    ProductModel product,
    BuildContext context, {
    List<File>? files,
    List<String>? deletedImages,
  }) async {
    // Create a map for the file fields
    final Map<String, List<File>> fileFields = {
      'album': files ?? [],
    };

    // Create a map for the request body
    final Map<String, dynamic> body = product.toJson();

    // Add the delete field if there are images to delete
    if (deletedImages != null && deletedImages.isNotEmpty) {
      body['delete'] = deletedImages;
    }

    // Make the API call
    final response = await _apiClient.patchRequest(
      '${ApiEndpoints.product}/${product.id}',
      body: body,
      context,
      files: fileFields,
    );

    return ApiResponse.fromJson(response);
  }

  Future<ApiResponse> editProductPin(
    ProductModel product,
    BuildContext context, {
    List<File>? files,
  }) async {
    final response = await _apiClient.patchRequest(
      ApiEndpoints.productPin,
      body: product.toJsonEditPin(),
      context,
    );

    return ApiResponse.fromJson(response);
  }

  // Add delete method
  Future<ApiResponse> deleteProduct(
      String productId, BuildContext context) async {
    final response = await _apiClient.deleteRequest(
      '${ApiEndpoints.product}/$productId',
      context,
    );
    return ApiResponse.fromJson(response);
  }

  //get list product by User ID

  Future<ApiResponse> fetchListProductByUser(
      BuildContext context, String id) async {
    final response = await _apiClient.getRequest(
      '${ApiEndpoints.productByUser}/$id',
      context,
    );
    return ApiResponse.fromJson(response);
  }
}
