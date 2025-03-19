import 'package:flutter/material.dart';

/// Thông báo khi PostItem thay đổi trạng thái like hoặc joined
class PostItemChangedNotification extends Notification {
  final String postId;
  final bool isLiked;
  final bool? isJoined;
  final int? commentCount;
  
  PostItemChangedNotification(this.postId, this.isLiked, {this.isJoined, this.commentCount});
} 