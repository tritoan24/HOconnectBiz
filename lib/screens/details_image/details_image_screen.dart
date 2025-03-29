import 'package:clbdoanhnhansg/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/screens/comment/comments_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../models/is_join_model.dart';
import '../../utils/transitions/custom_page_transition.dart';

class ChiTietBaiDang extends StatefulWidget {
  final List<String> imageList;
  final int initialIndex;
  final String companyName;
  final int like;
  final int comment;
  final String dateTime;
  final String description;
  final String? postId; // Thêm postId để có thể like và comment
  final String? title; // Thêm title
  final bool isLiked; // Thêm isLiked từ màn hình trước
  final bool isBusiness;
  final List<IsJoin>? isJoin;

  final int postType;
  final bool isMe;
  final List<String> likes; // Thêm danh sách likes

  const ChiTietBaiDang({
    super.key,
    required this.imageList,
    required this.initialIndex,
    required this.companyName,
    required this.like,
    required this.comment,
    required this.dateTime,
    required this.isJoin,
    this.postType = 0,
    required this.description,
    this.postId, // Thêm postId
    this.title,
    this.isMe = false,
    this.isBusiness = false,
    this.isLiked = false, // Mặc định là false
    this.likes = const [], // Mặc định là danh sách rỗng
  });

  @override
  State<ChiTietBaiDang> createState() => _ChiTietBaiDanglScreenState();
}

class _ChiTietBaiDanglScreenState extends State<ChiTietBaiDang> {
  late PageController _pageController;
  late int _currentPage;
  final storage = const FlutterSecureStorage();
  late int likeCount;
  bool isLiked = false;
  String? idUserID;
  bool _hasChanges = false;
  bool _showFullDescription = false; // Thêm biến để kiểm soát hiển thị mô tả
  double _textContainerPosition = 60; // Vị trí mặc định của phần text

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    likeCount = widget.like;
    isLiked = widget.isLiked; // Sử dụng giá trị isLiked từ constructor
    debugPrint(
        "🔍 DEBUG ChiTietBaiDang initState: isLiked=${widget.isLiked}, likeCount=$likeCount");
    debugPrint("trạng thái isBusiness=${widget.isBusiness}");
    _loadUserIdAndStatusLikePost();
  }

  Future<void> _loadUserIdAndStatusLikePost() async {
    if (widget.postId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = await authProvider.getuserID();
    setState(() {
      idUserID = userId ?? "";
      // Kiểm tra xem người dùng hiện tại có trong danh sách likes không
      isLiked = widget.likes.contains(idUserID);
      debugPrint(
          "🔍 DEBUG ChiTietBaiDang _loadUserIdAndStatusLikePost: userId=$idUserID, isLiked=$isLiked");
    });
  }

  void _likePost(BuildContext context) {
    if (widget.postId == null) return;
    debugPrint(
        "🔍 DEBUG ChiTietBaiDang: _likePost bắt đầu cho postId: ${widget.postId}");

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final oldIsLiked = isLiked;
    final oldLikeCount = likeCount;

    // Cập nhật trạng thái local
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
      _hasChanges = true; // Đánh dấu đã có thay đổi

      // Lưu trạng thái thay đổi trong biến _hasChanges
      _hasChanges = true;
    });

    // Gọi API để cập nhật trạng thái like trên server
    postProvider.toggleLike(widget.postId!, context);
  }

  // Hàm toggle hiển thị mô tả
  void _toggleDescription() {
    setState(() {
      _showFullDescription = !_showFullDescription;
      // Điều chỉnh vị trí container text khi chuyển đổi trạng thái
      _textContainerPosition = _showFullDescription ? 10.0 : -50.0;
    });
  }

  Future<void> _navigateToComments(
      BuildContext context, bool isBusiness) async {
    if (widget.postId == null) return;

    final result = await Navigator.push(
      context,
      CustomPageTransition(
        page: CommentsScreen(
          postId: widget.postId!,
          postType: widget.postType,
          displayName: widget.companyName,
          avatar_image: "",
          dateTime: widget.dateTime,
          title: widget.title ?? "",
          content: widget.description,
          images: widget.imageList,
          business: [],
          product: [],
          likes: widget.likes,
          commentCount: widget.comment,
          isBusiness: isBusiness,
          isMe: widget.isMe,
          isJoin: widget.isJoin,
          isComment: true,
          idUser: idUserID ?? "",
        ),
        type: TransitionType.slideUp,
      ),
    );

    if (result == true) {
      // Chỉ cần cập nhật biến _hasChanges để màn hình trước biết có thay đổi
      setState(() {
        _hasChanges = true;
      });
    }
  }

  // Hàm định dạng ngày giờ để hiển thị đẹp hơn
  String _formatDateTime(String dateTime) {
    try {
      DateTime parsedDate = DateFormat("dd/MM/yyyy HH:mm").parse(dateTime);
      return DateFormat("HH:mm - dd/MM/yyyy").format(parsedDate);
    } catch (e) {
      debugPrint("Error parsing date: $e");
      return dateTime;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_hasChanges) {
      // Nếu có thay đổi, trả về true khi pop màn hình
      Navigator.pop(context, true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context, _hasChanges),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIcons.getArrowBackIos(
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              _formatDateTime(widget.dateTime),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${_currentPage + 1}/${widget.imageList.length}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Phần ảnh
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.imageList.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.imageList[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Phần Text Container - có thể di chuyển lên/xuống
          AnimatedPositioned(
            left: 0,
            right: 0,
            bottom: _textContainerPosition, // Sử dụng biến vị trí
            duration: const Duration(milliseconds: 300), // Animation mượt
            curve: Curves.easeInOut,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: _showFullDescription
                    ? screenHeight * 0.5
                    : screenHeight * 0.2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null && widget.title!.isNotEmpty) ...[
                        Text(
                          widget.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      GestureDetector(
                        onTap: _toggleDescription,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.description.split('\n').join('\n • '),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: _showFullDescription ? null : 3,
                              overflow: _showFullDescription
                                  ? null
                                  : TextOverflow.ellipsis,
                            ),
                            if (!_showFullDescription &&
                                widget.description.split('\n').length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Xem thêm...",
                                  style: TextStyle(
                                    color: Colors.blue[300],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Phần Like & Comment - luôn cố định ở dưới cùng
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const HorizontalDivider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _likePost(context),
                            child: Row(
                              children: [
                                ImageIcon(
                                  AssetImage(isLiked
                                      ? 'assets/icons/heart_on.png'
                                      : 'assets/icons/heart.png'),
                                  color: isLiked ? Colors.red : Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "$likeCount",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: widget.postId != null
                                ? () => _navigateToComments(
                                    context, widget.isBusiness)
                                : null,
                            child: Row(
                              children: [
                                const ImageIcon(
                                  AssetImage('assets/icons/comment.png'),
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${widget.comment}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
