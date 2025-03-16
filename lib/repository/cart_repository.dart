import 'dart:convert';

import 'package:clbdoanhnhansg/models/product_model.dart';
import 'package:flutter/cupertino.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';

class CartRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse> placeOrder(
    List<BuyProductModel> cartItems,
    String userId,
    double totalPay,
    double provisional,
    int totalProduct,
    totalDiscount,
    totalPayAfterDiscount,
    BuildContext context,
  ) async {
    // Log all individual objects before creating the payload
    print("===== DETAILED DEBUG INFO =====");
    print("CartItems count: ${cartItems.length}");

    for (var i = 0; i < cartItems.length; i++) {
      var item = cartItems[i];
      print("Item $i details:");
      print("  - id (${item.id.runtimeType}): ${item.id}");
      print("  - price (${item.price.runtimeType}): ${item.price}");
      print("  - quantity (${item.quantity.runtimeType}): ${item.quantity}");
      print("  - discount (${item.discount.runtimeType}): ${item.discount}");
      print("  - As JSON: ${json.encode(item.toJsonBuy())}");
    }

    print("userId (${userId.runtimeType}): $userId");
    print("totalPay (${totalPay.runtimeType}): $totalPay");
    print("totalPay rounded: ${totalPay.round()}");

    // Create the payload
    final orderData = {
      "product": cartItems.map((item) => item.toJsonBuy()).toList(),
      "user_receive": userId,
      "total_pay": totalPay.round(),
      "provisional": provisional.round(),
      "total_product": totalProduct,
      "total_discount": totalDiscount,
      "total_pay_after_discount": totalPayAfterDiscount,
    };

    // Print the full request data in both pretty and compact formats
    print("\n===== API REQUEST PAYLOAD =====");
    print("PRETTY JSON:");
    final prettyJson = JsonEncoder.withIndent('  ').convert(orderData);
    print(prettyJson);

    print("\nCOMPACT JSON:");
    print(json.encode(orderData));

    // Print content type and other important headers
    print("\n===== REQUEST HEADERS =====");
    print("Content-Type: application/json");

    // Send the request
    print("\n===== SENDING REQUEST TO API =====");
    print("Method: PUT");

    final response = await _apiClient.putJsonRequest(
      '/buy-many',
      context,
      body: orderData,
    );

    // Log the response
    print("\n===== API RESPONSE =====");
    print("Status Code: ${response['statusCode']}");
    print("Response Body: ${json.encode(response)}");

    return ApiResponse.fromJson(response);
  }

  //get list don ban
  Future<ApiResponse> getListOrderSale(BuildContext context) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.orderSale,
      context,
    );
    print(response);

    final apiResponse = ApiResponse.fromJson(response);

    return apiResponse;
  }

  //get list don mua
  Future<ApiResponse> getListOrderBuy(BuildContext context) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.orderBuy,
      context,
    );
    print(response);

    final apiResponse = ApiResponse.fromJson(response);

    return apiResponse;
  }

  //cập nhật trạng thái đơn hàng mua
  Future<ApiResponse> updateStatusOrderBuy(
      String orderId, int status, BuildContext context) async {
    final response = await _apiClient.pacthJsonRequest(
      '${ApiEndpoints.updateStatusCart}/$orderId',
      context,
      body: {"status_buy": status},
    );
    print(response);

    final apiResponse = ApiResponse.fromJson(response);

    return apiResponse;
  }
}
