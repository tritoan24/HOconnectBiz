import 'dart:io';

import 'package:clbdoanhnhansg/providers/comment_provider.dart';
import 'package:clbdoanhnhansg/screens/comment/widget/comment_item.dart';
import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';
import 'package:flutter/material.dart';
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
    });
  }

  List<String> selectedImages = [];
  String currentMessage = '';
  bool isSubmitting = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  bool _hasChanges = false;

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
    } catch (e) {
      print('Error submitting comment: $e');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    final inputHeight = 80.0;
    return Scaffold(
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
                      comments: commentProvider.comments.length,
                      isComment: widget.isComment,
                      idUser: widget.idUser,
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
      bottomSheet: MessageInputScreen(
        onMessageChanged: (message, images) {
          setState(() {
            selectedImages = images;
            currentMessage = message;
          });
        },
        onSubmit: _handleCommentSubmit,
        isComment: widget.isComment,
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

