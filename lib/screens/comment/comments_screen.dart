import 'dart:io';
import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/notifications/post_item_changed_notification.dart';
import 'package:clbdoanhnhansg/providers/comment_provider.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:clbdoanhnhansg/screens/comment/widget/comment_item.dart';
import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/business_model.dart';
import '../../models/product_model.dart';
import '../../utils/global_state.dart';
import '../../utils/icons/app_icons.dart';
import '../../utils/router/router.name.dart';
import '../chat/widget/message_input.dart';

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
  final bool isMe;
  final String idUser;
  final bool isBusiness;
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
    this.isMe = false,
    this.isBusiness = false,
    required this.idUser,
    this.isComment = false,
    this.isJoin,
  });

  @override
  State<CommentsScreen> createState() => _CommentState();
}

class _CommentState extends State<CommentsScreen> {
  //lấy dữ liệu khi bắt đầu khởi tạo màn
  bool isJoind = false; // Lưu trạng thái join
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái join dựa trên dữ liệu truyền vào
    _checkIsJoined();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commentProvider =
          Provider.of<CommentProvider>(context, listen: false);
      commentProvider.getComments(widget.postId, context).then((_) {
        _scrollToBottom();
      });
      debugPrint(
          "🔍 DEBUG CommentsScreen: Đã gọi getComments cho postId: ${widget.postId}");
      debugPrint("trạng thái business 111: ${widget.isBusiness} ");
    });
  }

  // Kiểm tra xem người dùng đã tham gia bài viết chưa
  Future<void> _checkIsJoined() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = await authProvider.getuserID() ?? "";

    // Kiểm tra xem userId có trong danh sách isJoin không
    if (widget.isJoin != null && widget.isJoin!.isNotEmpty) {
      setState(() {
        isJoind = widget.isJoin!.any((join) => join.user?.id == userId);
      });
      debugPrint("🔍 DEBUG CommentsScreen: Khởi tạo isJoind = $isJoind");
    }
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

      // Lấy post mới nhất từ PostProvider để có số lượng comment mới
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final updatedPost = postProvider.getPostById(widget.postId);
      if (updatedPost != null) {
        debugPrint(
            "🔍 DEBUG CommentsScreen: Cập nhật số lượng comment mới: ${updatedPost.totalComment}");
      }

      debugPrint("🔍 DEBUG CommentsScreen: Đã tạo comment thành công");
      // Gọi hàm cuộn xuống dưới cùng
      _scrollToBottom();
    } catch (e) {
      debugPrint('⚠️ ERROR CommentsScreen: Lỗi khi tạo comment: $e');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  //hàm cuộn xuống dưới cùng
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_hasChanges) {
      debugPrint("🔍 DEBUG CommentsScreen: dispose() với _hasChanges = true");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    final inputHeight = 80.0;

    // Lấy số lượng comment mới nhất từ PostProvider
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final updatedPost = postProvider.getPostById(widget.postId);
    final currentCommentCount =
        updatedPost?.totalComment ?? widget.commentCount;

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
            onPressed: () {
              debugPrint(
                  "🔍 DEBUG CommentsScreen: Quay lại với _hasChanges = $_hasChanges");

              // Check if we came from a notification
              if (GlobalAppState.launchedFromNotification) {
                // Navigate to home screen instead of just popping
                context.go(AppRoutes.trangChu.replaceFirst(':index', '0'));
                // Reset the flag
                GlobalAppState.launchedFromNotification = false;
              } else {
                // Normal back behavior
                if (_hasChanges) {
                  context.pop(_hasChanges);
                } else {
                  context.pop();
                }
              }
            },
          ),
        ),
        title: _buildHeader(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: inputHeight),
              children: [
                NotificationListener<PostItemChangedNotification>(
                  onNotification: (notification) {
                    if (notification.postId == widget.postId) {
                      setState(() {
                        _hasChanges = true;

                        // Cập nhật isJoind nếu thông báo có thông tin về join
                        if (notification.isJoined != null) {
                          isJoind = notification.isJoined!;
                          debugPrint(
                              "🔍 DEBUG CommentsScreen: Cập nhật isJoind = $isJoind từ thông báo");
                        }

                        // Cập nhật số lượng comment nếu có
                        if (notification.commentCount != null) {
                          debugPrint(
                              "🔍 DEBUG CommentsScreen: Cập nhật số lượng comment = ${notification.commentCount} từ thông báo");
                        }
                      });
                      debugPrint(
                          "🔍 DEBUG CommentsScreen: Cập nhật _hasChanges = true do PostItem thay đổi");
                    }
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
                    isMe: widget.isMe,
                    comments: currentCommentCount,
                    isComment: widget.isComment,
                    idUser: widget.idUser,
                    isJoin: widget.isJoin,
                  ),
                ),
                const SizedBox(height: 8),
                ...commentProvider.comments
                    .map((comment) => BinhLuanItem(binhLuan: comment))
                    .toList(),
              ],
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
        // Xử lý cả thay đổi về like và join
        if (notification.isJoined != null) {
          debugPrint(
              "🔍 DEBUG PostItemWrapper: Phát hiện thay đổi trạng thái join");
        }
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
