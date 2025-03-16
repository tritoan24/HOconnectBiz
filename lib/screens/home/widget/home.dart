import 'package:carousel_slider/carousel_slider.dart';
import 'package:clbdoanhnhansg/providers/banner_provider.dart';
import 'package:clbdoanhnhansg/providers/bo_provider.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/screens/chat/chat_list_screen.dart';
import 'package:clbdoanhnhansg/screens/home/widget/slide_view.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../providers/StatisticalProvider.dart';
import '../../../providers/rank_provider.dart';
import 'bang_xep_hang.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<PostProvider>(context, listen: false).fetchPosts(context);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final boProvider = Provider.of<BoProvider>(context, listen: false);
      final staticsticalProvider =
          Provider.of<StatisticalProvider>(context, listen: false);
      boProvider.fetchBoDataOut(context);
      boProvider.fetchBoData(context);

      staticsticalProvider.fetchStatistics(context);

      postProvider.fetchPosts(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<PostProvider>(context).listPostFeatured;
    final rankProvider = Provider.of<RankProvider>(context);
    final ranksRevenue = rankProvider.rankRevenue;
    final ranksBusiness = rankProvider.rankBusiness;
    final imageUrl = Provider.of<BannerProvider>(context).allImageUrls.first;
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/images/logo.png",
            width: 150,
          ),
        ),
        actions: [
          Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              final hasNewNotifications =
                  postProvider.newNotificationsCount > 0;
              final hasNewMessages = postProvider.newMessagesCount > 0;

              return Row(
                children: [
                  // Biểu tượng thông báo
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.thongBao);
                          },
                          child: SvgPicture.asset(
                            "assets/icons/noti.svg",
                          )),
                      // Hiển thị dấu chấm đỏ nếu không có ảnh riêng
                      if (hasNewNotifications)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  //icon nhan tin
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatListScreen(),
                                ));
                          },
                          child: SvgPicture.asset(
                            "assets/icons/mess.svg",
                            width: 24,
                          )),
                      // Hiển thị dấu chấm đỏ nếu không có ảnh riêng
                      if (hasNewMessages)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                ],
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            context.push(AppRoutes.timKiem);
          },
          child: Container(
            height: 40,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                AppIcons.getSearch(color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  "Tìm kiếm",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          AppIcons.getError(),
                    )
                  : Lottie.asset(
                      'assets/lottie/loading.json',
                    ),
              const SizedBox(
                height: 40,
              ),
              BangXepHang(
                ranks: ranksRevenue, // Gửi dữ liệu doanh thu loại 1
                title: "Bảng xếp hạng doanh thu tuần",
              ),
              const SizedBox(height: 40),

              // Hiển thị bảng xếp hạng doanh thu loại 2
              BangXepHang(
                ranks: ranksBusiness, // Gửi dữ liệu doanh thu loại 2
                title: "Bảng xếp hạng cơ hội kinh doanh tuần",
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tin đăng nổi bật",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Xem tất cả",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff006AF5),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 342,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index, realIndex) {
                    final post = posts[index];

                    return SlideView(
                      postId: post.id.toString(),
                      displayName: post.author?.displayName ?? '',
                      avatarImage: post.author?.avatarImage ?? '',
                      title: post.title.toString(),
                      content: post.content.toString(),
                      images: post.album ?? [],
                      product: post.product ?? [],
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
}
