import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/screens/manage/widget/shop/shoptab.dart';
import 'package:clbdoanhnhansg/screens/manage/widget/information/information.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/router/router.name.dart';
import '../manage/widget/post/post_tab.dart';

class BusinessInformation extends StatefulWidget {
  final bool isMe;
  final String idUser;
  const BusinessInformation(
      {super.key, final this.isMe = false, required this.idUser});

  @override
  State<BusinessInformation> createState() => _BusinessInformationState();
}

class _BusinessInformationState extends State<BusinessInformation> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Gọi fetchUser một lần khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      userProvider.fetchUserByID(context, widget.idUser);
      postProvider.fetchListPostByUser(context, widget.idUser);
      productProvider.fetchListProductByUser(context, widget.idUser);
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final productProvider =
    //       Provider.of<ProductProvider>(context, listen: false);
    //   if (productProvider.products.isEmpty) {
    //     productProvider.getListProduct(context);
    //   }
    // });
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
                    elevation: 0,
                    expandedHeight: 250.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    title: Text(
                      (userProvider.authorByID?.displayName != null)
                          ? userProvider.authorByID!.displayName.isNotEmpty
                              ? userProvider.authorByID!.displayName
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
                              child: Image.network(
                                userProvider.authorByID?.avatarImage
                                            .isNotEmpty ==
                                        true
                                    ? userProvider.authorByID!.avatarImage
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
                            ),
                            const SizedBox(height: 8),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Container(
                                  alignment: Alignment
                                      .center, // Căn giữa cả ngang và dọc
                                  child: Text(
                                    (userProvider.authorByID?.description !=
                                                null &&
                                            userProvider.authorByID!.description
                                                .isNotEmpty)
                                        ? userProvider.authorByID!.description
                                        : "Chưa có thông tin",
                                    maxLines: 2,
                                    textAlign: TextAlign
                                        .center, // Căn giữa nội dung text
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff767A7F),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "4.8",
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
                            const Text(
                              "(12 cơ hội kinh doanh)",
                              style: TextStyle(
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
              body: userProvider.isLoadingByID
                  ? const Center(child: CircularProgressIndicator())
                  : userProvider.authorByID == null
                      ? const Center(
                          child: Text('Không thể tải thông tin công ty'))
                      : const TabBarView(
                          children: [
                            InformationTab(isMe: false),
                            PostManageTab(isMe: false),
                            TabShop(
                              isLeading: false,
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
