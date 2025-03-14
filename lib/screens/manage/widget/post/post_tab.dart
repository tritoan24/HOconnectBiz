import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/posts.dart';
import '../../../../providers/post_provider.dart';

class PostManageTab extends StatefulWidget {
  final bool isMe;
  const PostManageTab({super.key, required this.isMe});

  @override
  State<PostManageTab> createState() => _PostManageState();
}

class _PostManageState extends State<PostManageTab> {
  List posts = [];

  @override
  void initState() {
    super.initState();
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(builder: (context, postProvider, child) {
      final List<Posts> posts =
          widget.isMe ? postProvider.listPostMe : postProvider.listtByID;

      print(
          "🔍 Có ${posts.length} bài viết trong danh sách-----------------------!");
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            // await postProvider.fetchPostsByUser(context);
          },
          child: (widget.isMe
                  ? postProvider.isLoading
                  : postProvider.isLoadingByID)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : posts.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () async {
                        // await postProvider.fetchPostsByUser(context);
                      },
                      child: const Center(
                        child: Text(
                          "Không có bài viết nào.",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ))
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        print("🔍 Bài viết #${index + 1}: ${post.id}");
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
                          isMe: widget.isMe,
                          idUser: post.author!.id,
                        );
                      },
                    ),
        ),
      );
    });
  }
}
