import 'package:clbdoanhnhansg/screens/account/fogot_password/input_account_screen.dart';
import 'package:clbdoanhnhansg/screens/account/fogot_password/input_new_password_screen.dart';
import 'package:clbdoanhnhansg/screens/account/fogot_password/input_otp_screen.dart';
import 'package:clbdoanhnhansg/screens/account/signup.dart';
import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/details_post_business.dart';
import 'package:clbdoanhnhansg/screens/chat/chat_list_screen.dart';
import 'package:clbdoanhnhansg/screens/chat/create_order.dart';
import 'package:clbdoanhnhansg/screens/home/widget/notification.dart';
import 'package:clbdoanhnhansg/screens/manage/widget/information/widget/edit_imformation.dart';
import 'package:clbdoanhnhansg/screens/post/post_screen.dart';
import 'package:clbdoanhnhansg/screens/search/search.dart';
import 'package:clbdoanhnhansg/screens/splash_screen.dart';
import 'package:clbdoanhnhansg/screens/comment/comments_screen.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:go_router/go_router.dart';

import '../../models/business_model.dart';
import '../../models/is_join_model.dart';
import '../../models/product_model.dart';
import '../../screens/account/login.dart';
import '../../screens/cart/cart_tab.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/widget/buy_product.dart';
import '../../screens/manage/manage.dart';
import '../../screens/shopping/shopping.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const SplashScreen(),
      routes: [
        GoRoute(
          path: AppRoutes.dangKyTaiKhoan,
          builder: (context, state) {
            return const Signup();
          },
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) {
            return const LoginView();
          },
        ),
        GoRoute(
          path: AppRoutes.trangChu,
          builder: (context, state) {
            return const TrangChuView();
          },
        ),
        GoRoute(
          path: AppRoutes.timKiem,
          builder: (context, state) {
            return const SearchView();
          },
        ),
        GoRoute(
          path: AppRoutes.dangTin,
          builder: (context, state) {
            return const PostScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.shopping,
          builder: (context, state) {
            return const Shopping();
          },
        ),
        GoRoute(
          path: AppRoutes.chinhSuaThongTin,
          builder: (context, state) {
            return const EditInformation();
          },
        ),
        GoRoute(
          path: AppRoutes.thongTinDoanhNghiep,
          builder: (context, state) {
            final String isLeading = state.pathParameters['isLeading']!;
            return QuanLyView(
              isLeading: isLeading == 'true' ? true : false,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.muaSanPham,
          builder: (context, state) {
            final product = state.extra as ProductModel;
            return BuyProduct(
                product: product,
                idUser: '',
                avatar_image: '',
                displayName: '');
          },
        ),
        GoRoute(
          path: AppRoutes.tinNhan,
          builder: (context, state) {
            final notificationId = state.extra as Map<String, String>?;
            return ChatListScreen(
              notificationId: notificationId,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.quenMatKhau,
          builder: (context, state) {
            return const InputAccountScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.nhapMaOTP,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final email = extra?['email'] as String? ?? '';
            final bool isShow = extra?['isShow'] as bool? ?? false;
            return InputOtpScreen(email: email, isShow: isShow);
          },
        ),
        GoRoute(
          path: AppRoutes.taoMatKhauMoi,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final email = extra?['email'] as String? ?? '';
            final bool isShow = extra?['isShow'] as bool? ?? false;
            return InputNewPasswordScreen(email: email, isShow: isShow);
          },
        ),
        GoRoute(
          path: AppRoutes.thongBao,
          builder: (context, state) {
            // Lấy dữ liệu thông báo từ extra nếu có
            final notificationData = state.extra as Map<String, dynamic>?;
            return NotificationScreen(notificationData: notificationData);
          },
        ),
        GoRoute(
          path: AppRoutes.taoDonBan,
          builder: (context, state) {
            return const CreateOrder(
              idRecive: "",
            );
          },
        ),
        GoRoute(
          path: AppRoutes.chitietcohoi,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final idPost = extra?['idPost'] as String? ?? '';
            return DetailsPostBusiness(
              idPost: idPost,
            );
          },
        ),
        GoRoute(
          path: 'cart',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final initialTab =
                extra?['initialTab'] as CartTab? ?? CartTab.SaleOrder;
            return Cart(initialTab: initialTab);
          },
        ),
        GoRoute(
          path: 'comments/:id',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return CommentsScreen(
              postId: extra['postId'] ?? '',
              postType: extra['postType'] ?? 0,
              displayName: extra['displayName'] ?? 'Không xác định',
              avatar_image: extra['avatar_image'] ?? '',
              dateTime: extra['dateTime'] ?? DateTime.now().toString(),
              title: extra['title'] ?? '',
              content: extra['content'] ?? '',
              images: List<String>.from(extra['images'] ?? []),
              business: (extra['business'] as List<dynamic>?)
                      ?.map((e) => BusinessModel.fromJson(e))
                      .toList() ??
                  [],
              product: (extra['product'] as List<dynamic>?)
                      ?.map((e) => ProductModel.fromJson(e))
                      .toList() ??
                  [],
              likes: List<String>.from(extra['likes'] ?? []),
              commentCount: extra['commentCount'] ?? 0,
              isMe: extra['isMe'] ?? true,
              idUser: extra['idUser'] ?? '',
              isJoin: (extra['isJoin'] as List<dynamic>?)
                      ?.map((e) => IsJoin.fromJson(e))
                      .toList() ??
                  [],
              isBusiness: extra['isBusiness'] ?? false,
              isComment: extra['isComment'] ?? true,
            );
          },
        ),
      ],
    ),
  ],
);
