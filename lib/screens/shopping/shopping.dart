import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../models/posts.dart';
import '../../utils/router/router.name.dart';
import '../../screens/comment/comments_screen.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Infinite scroll
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Load more posts when user scrolls near the bottom
        Provider.of<PostProvider>(context, listen: false)
            .loadMorePosts(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Phương thức để làm mới dữ liệu
  Future<void> _refreshData() async {
    try {
      // Fetch new data
      await Provider.of<PostProvider>(context, listen: false)
          .fetchPosts(context);
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi làm mới: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Thêm phương thức để kiểm tra trạng thái isJoind dựa trên isJoin và userId
  bool checkIsJoind(List<dynamic>? isJoin, String userId) {
    if (isJoin == null || isJoin.isEmpty) return false;
    // Giả định rằng isJoin là một danh sách các đối tượng có thuộc tính user.id
    // Điều này phụ thuộc vào cấu trúc dữ liệu thực tế của bạn
    return isJoin.any((join) => join.user?.id == userId);
  }

  // Phương thức điều hướng đến màn hình comment và xử lý kết quả
  void _navigateToCommentScreen(BuildContext context, Posts post) async {
    debugPrint(
        "🔍 DEBUG Shopping: Chuyển đến màn hình comment với postId: ${post.id}");

    // Lấy dữ liệu mới nhất của bài viết trước khi chuyển màn hình
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final latestPost = postProvider.getPostById(post.id ?? '') ?? post;

    // Lấy userId hiện tại
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = await authProvider.getuserID() ?? "";

    // Kiểm tra trạng thái isJoind
    final isJoind = checkIsJoind(latestPost.isJoin, userId);

    debugPrint(
        "🔍 DEBUG Shopping: Dữ liệu bài viết trước khi chuyển màn hình - likes: ${latestPost.like?.length}, comments: ${latestPost.totalComment}, isJoind: $isJoind");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          postId: latestPost.id ?? '',
          postType: latestPost.category ?? 1,
          displayName: latestPost.author?.displayName ?? '',
          avatar_image: latestPost.author?.avatarImage ?? '',
          dateTime: latestPost.createdAt != null
              ? formatDateTime(latestPost.createdAt)
              : '',
          title: latestPost.title ?? '',
          content: latestPost.content ?? '',
          images: latestPost.album ?? [],
          business: latestPost.business ?? [],
          product: latestPost.product ?? [],
          likes: latestPost.like ?? [],
          commentCount: latestPost.totalComment ?? 0,
          isComment: true,
          idUser: latestPost.author?.id ?? '',
          isJoin: latestPost.isJoin,
        ),
      ),
    );

    // Nếu có thay đổi từ màn hình comment, cập nhật UI cục bộ
    if (result == true) {
      debugPrint("🔍 DEBUG Shopping: Nhận result=true từ màn hình comment");

      // THAY ĐỔI Ở ĐÂY: Không gọi fetchPosts, thay vào đó chỉ cập nhật bài viết cụ thể
      final updatedPost = postProvider.getPostById(post.id ?? '');
      if (updatedPost != null) {
        debugPrint(
            "🔍 DEBUG Shopping: Cập nhật bài viết cục bộ với ID: ${post.id}");

        // Hiển thị thông báo ngắn để xác nhận cập nhật
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Đã cập nhật dữ liệu mới nhất"),
          duration: Duration(seconds: 1),
        ));

        // Ép Flutter refresh UI
        setState(() {});
      }
    } else {
      debugPrint("🔍 DEBUG Shopping: Không có thay đổi từ màn hình comment");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        List<Posts> posts = postProvider.posts;

        print("🔍 Có ${posts.length} bài viết trong danh sách!");

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: GestureDetector(
              onTap: () {
                context.push(AppRoutes.timKiem);
              },
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "Tìm kiếm",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: postProvider.isLoading && posts.isEmpty
              ? Center(
                  child: Lottie.asset(
                    'assets/lottie/loading.json',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: posts.isEmpty
                      ? ListView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 150),
                            Center(
                              child: Text(
                                "Không có bài viết nào.",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                                height:
                                    300), // Thêm khoảng trống để có thể cuộn
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: posts.length +
                              (postProvider.hasMorePosts ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the bottom
                            if (index == posts.length) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: postProvider.isLoadingMore
                                      ? Lottie.asset(
                                          'assets/lottie/loading.json',
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.contain,
                                        )
                                      : const SizedBox(),
                                ),
                              );
                            }

                            final post = posts[index];
                            // Tạo key duy nhất để đảm bảo widget được tạo mới khi có thay đổi
                            final uniqueKey = ValueKey(
                                "post_${post.id}_likes${post.like?.length ?? 0}_comments${post.totalComment ?? 0}");

                            return GestureDetector(
                              onTap: () =>
                                  _navigateToCommentScreen(context, post),
                              child: PostItem(
                                key: uniqueKey,
                                postId: post.id ?? '',
                                postType: post.category ?? 1,
                                displayName: post.author?.displayName ?? '',
                                avatar_image: post.author?.avatarImage ?? '',
                                dateTime: post.createdAt != null
                                    ? formatDateTime(post.createdAt)
                                    : '',
                                title: post.title ?? '',
                                content: post.content ?? '',
                                images: post.album ?? [],
                                business: post.business ?? [],
                                product: post.product ?? [],
                                likes: post.like ?? [],
                                comments: post.totalComment ?? 0,
                                isJoin: post.isJoin ?? [],
                                idUser: post.author!.id,
                              ),
                            );
                          },
                        ),
                ),
        );
      },
    );
  }
}
