import 'package:clbdoanhnhansg/models/posts.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';
import 'package:clbdoanhnhansg/screens/search/widget/item_business_search.dart';
import 'package:clbdoanhnhansg/providers/bo_provider.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';
import 'package:lottie/lottie.dart';

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
  int _currentCategory = 1;

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
    postProvider.fetchPosts(context);
    final boProvider = Provider.of<BoProvider>(context, listen: false);
    boProvider.fetchBusinessesSearch(context);
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
    }
  }

  void _performSearch() {
    final keyword = _searchController.text.trim();

    if (_tabController.index == 0) {
      // Tab doanh nghiệp - tìm kiếm doanh nghiệp
      final boProvider = Provider.of<BoProvider>(context, listen: false);
      boProvider.searchBusinesses(context, keyword);
    } else {
      // Tab bài viết - tìm kiếm bài viết
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (keyword.isNotEmpty) {
        postProvider.searchPostWithResults(context, keyword);
      } else {
        // If search is cleared, fetch all posts for the current category
        postProvider.fetchPosts(context);
      }
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final boProvider = Provider.of<BoProvider>(context);

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
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      hintText: "Tìm kiếm...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      icon: AppIcons.getSearch(color: Colors.grey),
                    ),
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _performSearch();
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
                      });
                      // Trả về danh sách mặc định
                      if (_tabController.index == 0) {
                        // Tab doanh nghiệp - tải lại danh sách mặc định
                        final boProvider =
                            Provider.of<BoProvider>(context, listen: false);
                        boProvider.fetchBusinessesSearch(context);
                      } else {
                        // Tab bài viết - tải lại danh sách mặc định
                        final postProvider =
                            Provider.of<PostProvider>(context, listen: false);
                        postProvider.fetchPosts(context);
                      }
                    },
                    child: AppIcons.getClear(color: Colors.grey, size: 20),
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
            // Tab 1: Doanh nghiệp
            Consumer<BoProvider>(
              builder: (context, provider, child) {
                // Kiểm tra nếu đang tìm kiếm
                if (provider.isSearching) {
                  return Center(
                    child: Lottie.asset(
                      'assets/lottie/loading.json',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  );
                }

                // Nếu có lỗi tìm kiếm
                if (provider.searchErrorMessage.isNotEmpty) {
                  return Center(child: Text(provider.searchErrorMessage));
                }

                // Hiển thị kết quả tìm kiếm nếu có
                if (provider.searchResults.isNotEmpty) {
                  return ListView.builder(
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final business = provider.searchResults[index];
                      return BusinessSearchItem(
                        business: business,
                      );
                    },
                  );
                }

                // Hiển thị danh sách doanh nghiệp mặc định từ boListOut
                if (provider.boListOut.isEmpty) {
                  return const Center(
                      child: Text('Không có doanh nghiệp nào được tìm thấy.'));
                }

                return ListView.builder(
                  itemCount: provider.boListOut.length,
                  itemBuilder: (context, index) {
                    final business = provider.boListOut[index];
                    return BusinessSearchItem(
                      business: business,
                    );
                  },
                );
              },
            ),

            // Tab 2: Bài viết (Category 2)
            Consumer<PostProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Lottie.asset(
                      'assets/lottie/loading.json',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  );
                }

                // Hiển thị kết quả tìm kiếm nếu có
                if (_searchController.text.isNotEmpty) {
                  if (provider.searchResults.isEmpty) {
                    return const Center(
                        child: Text('Không có bài viết nào phù hợp.'));
                  }

                  return ListView.builder(
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final post = provider.searchResults[index];
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
                        isJoin: post.isJoin ?? [],
                        idUser: post.author!.id,
                      );
                    },
                  );
                }

                // Hiển thị danh sách bài viết mặc định
                if (provider.posts.isEmpty) {
                  return const Center(
                      child: Text('Không có bài viết nào được tìm thấy.'));
                }

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
                      isJoin: post.isJoin ?? [],
                      idUser: post.author!.id,
                    );
                  },
                );
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
