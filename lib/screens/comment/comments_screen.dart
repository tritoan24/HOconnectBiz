import 'dart:io';

import 'package:clbdoanhnhansg/providers/comment_provider.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:clbdoanhnhansg/screens/comment/widget/comment_item.dart';
import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';
import 'package:clbdoanhnhansg/notifications/post_item_changed_notification.dart';
import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import '../../utils/router/router.name.dart';
import '../chat/widget/message_input.dart';
import '../../utils/icons/app_icons.dart';

class CommentsScreen extends StatefulWidget {
  static final formatCurrency =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  final String postId;
  final int postType;
  final String displayName;
  final String avatar_image;
  final String dateTime;
  final String title;
  final String content;
  final List<String> images;
  final List<BusinessModel> business;
  final List<ProductModel> product;
  final List<String> likes;
  final int commentCount;
  final bool isComment;
  final String idUser;
  final List<IsJoin>? isJoin;

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.postType,
    required this.displayName,
    required this.avatar_image,
    required this.dateTime,
    required this.title,
    required this.content,
    required this.images,
    required this.business,
    required this.product,
    required this.likes,
    required this.commentCount,
    required this.idUser,
    this.isComment = false,
    this.isJoin,
  });

  @override
  State<CommentsScreen> createState() => _CommentState();
}

class _CommentState extends State<CommentsScreen> {
  //lấy dữ liệu khi bắt đầu khởi tạo màn
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commentProvider =
          Provider.of<CommentProvider>(context, listen: false);
      commentProvider.getComments(widget.postId, context);
      debugPrint(
          "🔍 DEBUG CommentsScreen: Đã gọi getComments cho postId: ${widget.postId}");
    });
  }

  List<String> selectedImages = [];
  String currentMessage = '';
  bool isSubmitting = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  bool _hasChanges = false;

  // Phương thức gọi khi PostItem thay đổi trạng thái like
  void _onPostItemLikeChanged() {
    setState(() {
      _hasChanges = true;
    });
    debugPrint(
        "🔍 DEBUG CommentsScreen: Cập nhật _hasChanges = true do PostItem thay đổi trạng thái like");
  }

  Future<void> _handleCommentSubmit(
      String message, List<String> imagePaths) async {
    if (message.trim().isEmpty && imagePaths.isEmpty) return;

    // Prevent multiple submissions
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final commentProvider =
          Provider.of<CommentProvider>(context, listen: false);

      // Convert image paths to File objects if present
      List<File>? album;
      if (imagePaths.isNotEmpty) {
        album = imagePaths.map((path) => File(path)).toList();
      }

      debugPrint(
          "🔍 DEBUG CommentsScreen: Bắt đầu tạo comment cho postId: ${widget.postId}");
      await commentProvider.createComment(
        context,
        widget.postId,
        message,
        album: album,
      );

      // Clear state after successful submission
      setState(() {
        _hasChanges = true;
        selectedImages = [];
        currentMessage = '';
      });
      debugPrint("🔍 DEBUG CommentsScreen: Đã tạo comment thành công");
    } catch (e) {
      debugPrint('⚠️ ERROR CommentsScreen: Lỗi khi tạo comment: $e');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    if (_hasChanges) {
      debugPrint("🔍 DEBUG CommentsScreen: dispose() với _hasChanges = true");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    final inputHeight = 80.0;

    return Scaffold(
      backgroundColor: AppColor.backgroundColorApp,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leadingWidth: 50,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xff141415),
            ),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
        ),
        title: _buildHeader(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.only(bottom: inputHeight), // Thêm padding bottom
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostItem(
                      postId: widget.postId,
                      postType: widget.postType,
                      displayName: widget.displayName,
                      avatar_image: widget.avatar_image,
                      dateTime: widget.dateTime,
                      title: widget.title,
                      content: widget.content,
                      images: widget.images,
                      business: widget.business,
                      product: widget.product,
                      likes: widget.likes,
                      comments: widget.commentCount,
                      isComment: widget.isComment,
                      idUser: widget.idUser,
                      isJoin: widget.isJoin,
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      key: _listKey,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commentProvider.comments.length,
                      itemBuilder: (context, index) {
                        return BinhLuanItem(
                            binhLuan: commentProvider.comments[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Màu nền
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Màu đổ bóng
              blurRadius: 6, // Độ mờ
              spreadRadius: 1, // Độ lan
              offset: Offset(0, -3), // Hướng bóng (âm nghĩa là lên trên)
            ),
          ],
        ),
        child: MessageInputScreen(
          onMessageChanged: (message, images) {
            setState(() {
              selectedImages = images;
              currentMessage = message;
            });
          },
          onSubmit: _handleCommentSubmit,
          isComment: widget.isComment,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 10),
          Text(widget.displayName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40.0),
      child: Image.network(
        widget.avatar_image.isNotEmpty
            ? widget.avatar_image
            : UrlImage.errorImage,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            AppIcons.getBrokenImage(size: 40),
      ),
    );
  }
}

// Widget bao bọc PostItem để theo dõi thay đổi
class PostItemWrapper extends StatefulWidget {
  final String postId;
  final int postType;
  final String displayName;
  final String avatar_image;
  final String dateTime;
  final String title;
  final String content;
  final List<String> images;
  final List<BusinessModel> business;
  final List<ProductModel> product;
  final List<String> likes;
  final int comments;
  final bool isComment;
  final String idUser;
  final VoidCallback onChanged;

  const PostItemWrapper({
    Key? key,
    required this.postId,
    required this.postType,
    required this.displayName,
    required this.avatar_image,
    required this.dateTime,
    required this.title,
    required this.content,
    required this.images,
    required this.business,
    required this.product,
    required this.likes,
    required this.comments,
    required this.isComment,
    required this.idUser,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<PostItemWrapper> createState() => _PostItemWrapperState();
}

class _PostItemWrapperState extends State<PostItemWrapper> {
  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    return NotificationListener<PostItemChangedNotification>(
      onNotification: (notification) {
        debugPrint(
            "🔍 DEBUG PostItemWrapper: Nhận thông báo thay đổi từ PostItem");
        widget.onChanged();
        return true;
      },
      child: PostItem(
        postId: widget.postId,
        postType: widget.postType,
        displayName: widget.displayName,
        avatar_image: widget.avatar_image,
        dateTime: widget.dateTime,
        title: widget.title,
        content: widget.content,
        images: widget.images,
        business: widget.business,
        product: widget.product,
        likes: widget.likes,
        comments: widget.comments,
        isComment: widget.isComment,
        idUser: widget.idUser,
      ),
    );
  }
}
