import 'package:clbdoanhnhansg/screens/account/fogot_password/input_account_screen.dart';
import 'package:clbdoanhnhansg/screens/account/fogot_password/input_new_password_screen.dart';
import 'package:clbdoanhnhansg/screens/account/fogot_password/input_otp_screen.dart';
import 'package:clbdoanhnhansg/screens/account/signup.dart';
import 'package:clbdoanhnhansg/screens/chat/chat_list_screen.dart';
import 'package:clbdoanhnhansg/screens/chat/create_order.dart';
import 'package:clbdoanhnhansg/screens/home/widget/notification.dart';
import 'package:clbdoanhnhansg/screens/manage/widget/information/widget/edit_imformation.dart';
import 'package:clbdoanhnhansg/screens/post/post_screen.dart';
import 'package:clbdoanhnhansg/screens/search/search.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:go_router/go_router.dart';

import '../../models/product_model.dart';
import '../../screens/account/login.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/widget/buy_product.dart';
import '../../screens/manage/manage.dart';
import '../../screens/shopping/shopping.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const LoginView(),
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
        ),GoRoute(
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
                product: product,idUser: '', avatar_image: '', displayName: '');
          },
        ),
        GoRoute(
          path: AppRoutes.tinNhan,
          builder: (context, state) {
            return ChatListScreen();
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
            final extra = state.extra as Map<String, String>?; // Lấy extra
            final email = extra?['email'] ?? ''; // Lấy email từ extra
            return InputOtpScreen(email: email); // Truyền email vào màn hình
          },
        ),
        GoRoute(
          path: AppRoutes.taoMatKhauMoi,
          builder: (context, state) {
            final Map<String, dynamic> extra =
                state.extra as Map<String, dynamic>;
            return InputNewPasswordScreen(email: extra['email']);
          },
        ),
        GoRoute(
          path: AppRoutes.thongBao,
          builder: (context, state) {
            return const NotificationScreen();
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
      ],
    ),
  ],
);
