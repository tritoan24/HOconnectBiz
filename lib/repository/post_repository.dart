import 'dart:io';

import 'package:clbdoanhnhansg/models/create_post.dart';
import 'package:flutter/cupertino.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/apiresponse.dart';
import '../models/posts.dart';

class PostRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse> createPostAD(CreatePost post, BuildContext context,
      {List<File>? files}) async {
    final Map<String, List<File>> fileFields = {
      'album': files ?? [],
    };
    final response = await _apiClient.putRequest(
      ApiEndpoints.post,
      body: post.toJson(),
      context,
      files: fileFields,
    );

    return ApiResponse.fromJson(response);
  }

  // toggleLikePost

  Future<ApiResponse> toggleLikePost(
      String postId, BuildContext context) async {
    final response = await _apiClient.patchRequest(
      "${ApiEndpoints.likePost}$postId",
      context,
    );

    return ApiResponse.fromJson(response);
  }
}

