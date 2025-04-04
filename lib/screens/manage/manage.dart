import 'package:clbdoanhnhansg/providers/user_provider.dart';
import 'package:clbdoanhnhansg/screens/manage/widget/information/information.dart';
import 'package:clbdoanhnhansg/screens/manage/widget/shop/shoptab.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import 'widget/post/post_tab.dart';

class QuanLyView extends StatefulWidget {
  final bool isLeading;
  final int initialTabIndex;
  const QuanLyView(
      {super.key, required this.isLeading, this.initialTabIndex = 0});

  @override
  State<QuanLyView> createState() => _QuanLyViewState();
}

class _QuanLyViewState extends State<QuanLyView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<PostProvider>(context, listen: false).fetchPostsByUser(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xfff4f5f6),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: widget.isLeading,
                    elevation: 0,
                    expandedHeight: 250.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    title: Text(
                      (userProvider.author?.displayName != null)
                          ? userProvider.author!.displayName.isNotEmpty
                              ? userProvider.author!.displayName
                              : "Chưa có thông tin"
                          : "Chưa có thông tin",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.only(
                            top: 60.0), // Khoảng cách từ đỉnh
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10), // Bo góc 10px
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    userProvider.author?.avatarImage
                                                ?.isNotEmpty ==
                                            true
                                        ? (userProvider.author?.avatarImage ??
                                            "https://i.pinimg.com/736x/3c/ae/07/3cae079ca0b9e55ec6bfc1b358c9b1e2.jpg")
                                        : "https://i.pinimg.com/736x/3c/ae/07/3cae079ca0b9e55ec6bfc1b358c9b1e2.jpg",
                                    width: 88,
                                    height: 88,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        UrlImage.errorImage,
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                )),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                (userProvider.author?.description != null)
                                    ? userProvider
                                            .author!.description.isNotEmpty
                                        ? userProvider.author!.description
                                        : "Chưa có thông tin"
                                    : "Chưa có thông tin",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff767A7F),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (userProvider.author?.boStar ?? 0.0)
                                      .toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Image.asset(
                                  "assets/images/img.png",
                                  width: 15,
                                  height: 15,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "(${userProvider.author?.totalBo} cơ hội kinh doanh)",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(text: "Thông tin"),
                          Tab(text: "Bài đăng"),
                          Tab(text: "Cửa hàng"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: userProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : userProvider.author == null
                      ? const Center(
                          child: Text('Không thể tải thông tin công ty'))
                      : const TabBarView(
                          children: [
                            InformationTab(isMe: true),
                            PostManageTab(isMe: true),
                            TabShop(
                              isLeading: true,
                            ),
                          ],
                        ),
            );
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
