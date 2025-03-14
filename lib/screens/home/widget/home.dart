import 'package:carousel_slider/carousel_slider.dart';
import 'package:clbdoanhnhansg/providers/banner_provider.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/screens/chat/chat_list_screen.dart';
import 'package:clbdoanhnhansg/screens/home/widget/slide_view.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../providers/rank_provider.dart';
import 'bang_xep_hang.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //   final bannerProvider =
      //       Provider.of<BannerProvider>(context, listen: false);
      //
      //   await bannerProvider.getListBanner(context);
      //
      //   // Cập nhật state
      //   setState(() {
      //     imageUrl = bannerProvider.allImageUrls.first;
      //   });
      //   final rankProvider = Provider.of<RankProvider>(context, listen: false);
      //
      //   await rankProvider.fetchRanksRevenue(context);
      //   await rankProvider.fetchRankBusiness(context);
      Provider.of<PostProvider>(context, listen: false).fetchPosts(context);
    });
    // final postProvider = Provider.of<PostProvider>(context, listen: false);
    // postProvider.fetchPostsFeatured(context);
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
            "assets/images/logo-clb-dnsg-up-website-385x215 1.png",
            width: 150,
          ),
        ),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.push(AppRoutes.thongBao);
                },
                child: Image.asset(
                  "assets/icons/img_1.png",
                  width: 24,
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              //icon nhan tin
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatListScreen(),
                      ));
                },
                child: Image.asset(
                  "assets/icons/img_2.png",
                  width: 24,
                ),
              ),
              const SizedBox(
                width: 24,
              ),
            ],
          )
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
                          const Icon(Icons.error),
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

