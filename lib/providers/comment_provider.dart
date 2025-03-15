import 'dart:io';
import 'package:clbdoanhnhansg/models/comment_model.dart';
import 'package:flutter/material.dart';
import '../core/base/base_provider.dart';
import '../repository/comment_repository.dart';
import '../widgets/loading_overlay.dart';
import '../providers/post_provider.dart';
import 'package:provider/provider.dart';

class CommentProvider extends BaseProvider {
  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  final CommentRepository _commentRepository = CommentRepository();

  Future<void> createComment(
      BuildContext context, String postId, String content,
      {List<File>? album}) async {
    LoadingOverlay.show(context);

    final comment = CommentModel(
      postId: postId,
      content: content,
    );

    await executeApiCall(
      apiCall: () =>
          _commentRepository.createComment(comment, context, files: album),
      context: context,
      onSuccess: () async {
        await getComments(postId, context);
        
        // Cập nhật số lượng comment trong danh sách bài viết
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        postProvider.updatePostCommentCount(postId, _comments.length);
      },
      successMessage: 'Tạo bình luận thành công!',
    );
    LoadingOverlay.hide();
  }

  Future<void> getComments(String postId, BuildContext context) async {
    // Show loading overlay while fetching data
    LoadingOverlay.show(context);

    try {
      Map<String, dynamic> queryParams = {
        'limit': 2,
        'page': 2,
      };

      final response =
          await _commentRepository.getComments(postId, queryParams, context);

      List commentsData = response.data;
      print('Dữ liệu bình luận: $commentsData');

      _comments = commentsData
          .map((comment) => CommentModel.fromJson(comment))
          .toList();

      notifyListeners();

      print('Danh sách bình luận: $_comments');
    } catch (e) {
      // If there's an error, print it
      print('Lỗi khi lấy bình luận: $e');
    }

    // Hide loading overlay after fetching is complete
    LoadingOverlay.hide();
  }
}

