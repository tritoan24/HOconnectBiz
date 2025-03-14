import 'package:clbdoanhnhansg/models/posts.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  // Set default category
  int _currentCategory = 1; // 1: Doanh nghiệp, 2: Bài viết

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen for tab changes to update category
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.fethPostByCategory(context, _currentCategory);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _currentCategory - 1) {
      setState(() {
        _currentCategory = _tabController.index + 1;
      });

      // Fetch data for the new category
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.fethPostByCategory(context, _currentCategory);
    }
  }

  void _performSearch() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final keyword = _searchController.text.trim();

    if (keyword.isNotEmpty) {
      postProvider.searchPost(context, _currentCategory, keyword);
    } else {
      // If search is cleared, fetch all posts for the current category
      postProvider.fethPostByCategory(context, _currentCategory);
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        appBar: AppBar(
          title: Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      hintText: "Tìm kiếm...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        postProvider.searchPost(
                            context, _currentCategory, value);
                      }
                    },
                  ),
                ),
                // Add a clear button
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _performSearch();
                      });
                    },
                    child:
                        const Icon(Icons.clear, color: Colors.grey, size: 20),
                  ),
                // Add search button
                GestureDetector(
                  onTap: _performSearch,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child:
                        Icon(Icons.search_rounded, color: AppColor.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            unselectedLabelColor: AppColor.borderColor,
            labelColor: AppColor.primaryBlue,
            indicatorColor: AppColor.primaryBlue,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            indicator: CustomTabIndicator(controller: _tabController),
            tabs: const [
              Tab(text: "Doanh nghiệp"),
              Tab(text: "Bài viết"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // First tab: Business (Category 1)
            Consumer<PostProvider>(
              builder: (context, provider, child) {
                if (_currentCategory == 1) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.posts.isEmpty) {
                    return const Center(
                        child:
                            Text('Không có doanh nghiệp nào được tìm thấy.'));
                  }
                  // Display business results using PostItem with category 1
                  return ListView.builder(
                    itemCount: provider.posts.length,
                    itemBuilder: (context, index) {
                      final post = provider.posts[index];
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
                        idUser: post.author!.id,
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: Text('Không có doanh nghiệp nào được tìm thấy.'));
                }
              },
            ),

            // Second tab: Posts (Category 2)
            Consumer<PostProvider>(
              builder: (context, provider, child) {
                if (_currentCategory == 2) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.posts.isEmpty) {
                    return const Center(
                        child: Text('Không có bài viết nào được tìm thấy.'));
                  }
                  // Display post results
                  return ListView.builder(
                    itemCount: provider.posts.length,
                    itemBuilder: (context, index) {
                      final post = provider.posts[index];
                      return PostItem(
                        postId: post.id ?? '',
                        postType: post.category ?? 2,
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
                        idUser: post.author!.id,
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: Text('Không có bài viết nào được tìm thấy.'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the CustomTabIndicator class
class CustomTabIndicator extends Decoration {
  final TabController controller;

  const CustomTabIndicator({required this.controller});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(controller: controller);
  }
}

class _CustomPainter extends BoxPainter {
  final TabController controller;

  _CustomPainter({required this.controller}) : super();

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Tính toán vị trí vẽ chỉ báo với chiều dài cố định 170px
    const double indicatorWidth = 170;
    final double tabWidth = configuration.size!.width;
    final double indicatorLeft = (tabWidth - indicatorWidth) / 2;
    final Offset indicatorOffset = Offset(
      indicatorLeft + offset.dx,
      configuration.size!.height - 5 + offset.dy,
    );

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(indicatorOffset.dx, indicatorOffset.dy, indicatorWidth, 5),
      const Radius.circular(5),
    );

    canvas.drawRRect(rrect, paint);
  }
}
