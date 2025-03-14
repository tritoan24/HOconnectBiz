import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/posts.dart';
import '../../utils/router/router.name.dart';

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

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
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
          body: RefreshIndicator(
            onRefresh: () async {
              await postProvider.fetchPosts(context);
            },
            child: postProvider.isLoading && posts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : posts.isEmpty
                    ? const Center(
                        child: Text("Không có bài viết nào."),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            posts.length + (postProvider.hasMorePosts ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show loading indicator at the bottom
                          if (index == posts.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: postProvider.isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : const SizedBox(),
                              ),
                            );
                          }

                          final post = posts[index];
                          return PostItem(
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
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}

