import 'dart:io';
import 'package:clbdoanhnhansg/models/comment_model.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';

class CommentRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse> createComment(
    CommentModel comment,
    BuildContext context, {
    List<File>? files,
  }) async {
    final Map<String, List<File>> fileFields = {
      'album': files ?? [],
    };
    final response = await _apiClient.patchRequest(
      '${ApiEndpoints.post}/comment/${comment.postId}',
      context,
      body: comment.toJson(),
      files: fileFields,
    );

    return ApiResponse.fromJson(response);
  }

  Future<ApiResponse> getComments(String postId,
      Map<String, dynamic> queryParams, BuildContext context) async {
    try {
      final response = await _apiClient.postRequest(
        '${ApiEndpoints.commentPost}/$postId',
        queryParams,
        context,
      );

      if (response != null && response['status'] == 'success') {
        return ApiResponse.fromJson(response);
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }
}

