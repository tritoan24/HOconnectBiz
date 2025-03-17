import 'dart:io';

import 'package:clbdoanhnhansg/models/message_model.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';
import '../models/contact.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse> sendMessageBuyNow(
      String receiverId, String productId, BuildContext context) async {
    try {
      final Map<String, dynamic> body = {
        "receiver": receiverId,
        "productId": productId,
      };

      final response = await _apiClient.postRequest(
        ApiEndpoints.chatNow,
        body,
        context,
      );

      if (response['status'] == 'success') {
        return ApiResponse.fromJson(response);
      } else {
        throw Exception('Failed to send message: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  //get list detail chat
  Future<ApiResponse> getListDetailChat(BuildContext context, String idMessage,
      {int page = 1, int limit = 15}) async {
    try {
      final response = await _apiClient.getRequest(
        '${ApiEndpoints.chatConversation}/$idMessage?page=$page&limit=$limit',
        context,
      );

      if (response['status'] == 'success') {
        return ApiResponse.fromJson(response);
      } else {
        throw Exception('Failed to get list chat: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error get list chat: $e');
    }
  }

  //get list chat
  Future<ApiResponse> getContacts(BuildContext context) async {
    try {
      final response = await _apiClient.getRequest(
        ApiEndpoints.chatList,
        context,
      );

      if (response['status'] == 'success') {
        return ApiResponse.fromJson(response);
      } else {
        throw Exception('Failed to load contacts');
      }
    } catch (e) {
      throw Exception('Error fetching contacts: $e');
    }
  }

  //send message
  Future<ApiResponse> sendMessage(
    Message message,
    String idReceiver,
    BuildContext context, {
    List<File>? files,
  }) async {
    try {
      print("🔹 Bắt đầu gửi tin nhắn...");
      print("📩 Nội dung tin nhắn: ${message.content}");
      print("👤 Người nhận ID: $idReceiver");
      print("🖼 Số lượng ảnh đính kèm: ${files?.length ?? 0}");

      final Map<String, List<File>> fileFields = {
        'album': files ?? [],
      };

      print("📡 Gửi request đến API: ${ApiEndpoints.chat}/$idReceiver");

      final response = await _apiClient.putRequest(
        '${ApiEndpoints.chat}/$idReceiver',
        context,
        body: message.toJson(),
        files: fileFields,
      );

      print("✅ Phản hồi từ server: ${response.toString()}");

      return ApiResponse.fromJson(response);
    } catch (e) {
      print("❌ Lỗi khi gửi tin nhắn: $e");
      throw Exception("Lỗi khi gửi tin nhắn: $e");
    }
  }

  //delete message
  Future<ApiResponse> deleteMessage(
      String idMessage, BuildContext context) async {
    try {
      final response = await _apiClient.deleteRequest(
        '${ApiEndpoints.chat}/$idMessage',
        context,
      );

      if (response['status'] == 'success') {
        return ApiResponse.fromJson(response);
      } else {
        throw Exception('Failed to delete message: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error delete message: $e');
    }
  }
}
