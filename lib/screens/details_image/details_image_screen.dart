// post_detail_screen.dart
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
  final List<String> likes; // Thêm danh sách likes

  const ChiTietBaiDang({
    super.key,
    required this.imageList,
    required this.initialIndex,
    required this.companyName,
    required this.like,
    required this.comment,
    required this.dateTime,
    required this.description,
    this.postId, // Thêm postId
    this.title,
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

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    likeCount = widget.like;
    isLiked = widget.isLiked; // Sử dụng giá trị isLiked từ constructor
    debugPrint("🔍 DEBUG ChiTietBaiDang initState: isLiked=${widget.isLiked}, likeCount=$likeCount");
    
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
      debugPrint("🔍 DEBUG ChiTietBaiDang _loadUserIdAndStatusLikePost: userId=$idUserID, isLiked=$isLiked");
    });
  }

  void _likePost(BuildContext context) {
    if (widget.postId == null) return;
    debugPrint("🔍 DEBUG ChiTietBaiDang: _likePost bắt đầu cho postId: ${widget.postId}");

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final oldIsLiked = isLiked;
    final oldLikeCount = likeCount;

    // Cập nhật trạng thái local
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
      _hasChanges = true; // Đánh dấu đã có thay đổi
      
      debugPrint("🔍 DEBUG ChiTietBaiDang: Trạng thái like thay đổi từ $oldIsLiked thành $isLiked");
      debugPrint("🔍 DEBUG ChiTietBaiDang: Số lượng like thay đổi từ $oldLikeCount thành $likeCount");
      
      // Lưu trạng thái thay đổi trong biến _hasChanges
      _hasChanges = true;
    });

    // Gọi API để cập nhật trạng thái like trên server
    postProvider.toggleLike(widget.postId!, context);
    debugPrint("🔍 DEBUG ChiTietBaiDang: Đã gọi postProvider.toggleLike");
  }

  Future<void> _navigateToComments(BuildContext context) async {
    if (widget.postId == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          postId: widget.postId!,
          postType: 0, // Mặc định postType = 0 nếu không có thông tin
          displayName: widget.companyName,
          avatar_image: "", // Cần truyền avatar từ màn hình trước
          dateTime: widget.dateTime,
          title: widget.title ?? "", // Sử dụng title nếu có
          content: widget.description,
          images: widget.imageList,
          business: [], // Cần truyền business từ màn hình trước
          product: [], // Cần truyền product từ màn hình trước
          likes: widget.likes, // Cần truyền danh sách likes từ màn hình trước
          commentCount: widget.comment,
          isComment: true,
          idUser: idUserID ?? "",
        ),
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

  // // Hàm chia sẻ bài viết
  // void _sharePost() {
  //   if (widget.postId == null) return;
  //
  //   String shareText = "";
  //   if (widget.title != null && widget.title!.isNotEmpty) {
  //     shareText += "${widget.title}\n\n";
  //   }
  //   shareText += "${widget.description}\n\n";
  //   shareText += "Được đăng bởi: ${widget.companyName}\n";
  //   shareText += "Vào lúc: ${_formatDateTime(widget.dateTime)}";
  //
  //   Share.share(shareText);
  // }

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
      body: Column(
        children: [
          Expanded(
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
          Container(
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  onTap: () {
                    setState(() {
                      _showFullDescription = !_showFullDescription;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.description
                            .split('\n')
                            .join('\n • '), // Thêm dấu "•" trước mỗi dòng mới
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: _showFullDescription ? null : 3,
                        overflow:
                            _showFullDescription ? null : TextOverflow.ellipsis,
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
                const SizedBox(height: 8),
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
                              ? () => _navigateToComments(context)
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
                    // Nút chia sẻ
                    // GestureDetector(
                    //   onTap: _sharePost,
                    //   child: Container(
                    //     padding: const EdgeInsets.all(8),
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue,
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         const Icon(
                    //           Icons.share,
                    //           color: Colors.white,
                    //           size: 20,
                    //         ),
                    //         const SizedBox(width: 4),
                    //         const Text(
                    //           "Chia sẻ",
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 14,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
