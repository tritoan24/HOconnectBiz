import 'package:carousel_slider/carousel_slider.dart';
import 'package:clbdoanhnhansg/providers/banner_provider.dart';
import 'package:clbdoanhnhansg/providers/bo_provider.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/screens/chat/chat_list_screen.dart';
import 'package:clbdoanhnhansg/screens/home/widget/slide_view.dart';
import 'package:clbdoanhnhansg/screens/search/widget/post/post_item.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../providers/StatisticalProvider.dart';
import '../../../providers/rank_provider.dart';
import '../../../utils/transitions/custom_page_transition.dart';
import 'bang_xep_hang.dart';

class Home extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const Home({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<Home> createState() => _HomeState();
}

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Lấy các provider
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final rankProvider = Provider.of<RankProvider>(context, listen: false);
      final staticsticalProvider =
          Provider.of<StatisticalProvider>(context, listen: false);
      final bannerProvider =
          Provider.of<BannerProvider>(context, listen: false);

      // Gọi các phương thức fetch data
      staticsticalProvider.fetchStatistics(context);
      rankProvider.fetchRanksRevenue(context);
      rankProvider.fetchRankBusiness(context);

      // Tải dữ liệu banner
      bannerProvider.getListBanner(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<PostProvider>(context).listPostFeatured;
    final rankProvider = Provider.of<RankProvider>(context);
    final ranksRevenue = rankProvider.rankRevenue;
    final ranksBusiness = rankProvider.rankBusiness;
    final bannerProvider = Provider.of<BannerProvider>(context);
    final imageUrl = (bannerProvider.allImageUrls.isNotEmpty
            ? bannerProvider.allImageUrls.first
            : null) ??
        'https://doanhnghiepapp.webest.asia/public/images/banner-default.png';

    return Scaffold(
      backgroundColor: const Color(0xffF4F5F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Image.asset(
              "assets/images/logo.png",
              width: 150,
              fit: BoxFit.cover,
            ),
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
                                CustomPageTransition(
                                    page: ChatListScreen(),
                                    type: TransitionType.fade));
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
            width: double.infinity,
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 16,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 153,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => AppIcons.getError(),
                ),
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
                    onTap: () {
                      widget.onNavigateToTab(3); // Chuyển đến tab 3
                    },
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
              // Thay đổi phần CarouselSlider trong widget build
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 645, // Giữ chiều cao container
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 645,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    scrollDirection: Axis.horizontal,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index, realIndex) {
                    final post = posts[index];

                    return SingleChildScrollView(
                      // Thay đổi ở đây
                      physics: const NeverScrollableScrollPhysics(),
                      child: PostItem(
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
                        isF: true,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 90,
              )
            ],
          ),
        ),
      ),
    );
  }
}
