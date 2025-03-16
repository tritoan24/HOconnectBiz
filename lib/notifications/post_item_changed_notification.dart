import 'package:flutter/material.dart';

/// Thông báo khi PostItem thay đổi trạng thái like
class PostItemChangedNotification extends Notification {
  final String postId;
  final bool isLiked;
  
  PostItemChangedNotification(this.postId, this.isLiked);
} 