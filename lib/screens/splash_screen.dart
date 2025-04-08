import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/banner_provider.dart';
import '../providers/business_provider.dart';
import '../providers/post_provider.dart';
import '../providers/product_provider.dart';
import '../providers/upgrade_provider.dart';
import '../providers/user_provider.dart';
import '../utils/router/router.name.dart';
import '../utils/global_state.dart';
import '../screens/cart/cart_tab.dart';
import '../screens/chat/chat_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Chuyển hướng ngay lập tức
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bannerProvider =
          Provider.of<BannerProvider>(context, listen: false);
      await bannerProvider.getListBanner(context);
    });
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      if (!mounted) return;

      // First check upgrade info
      final upgradeService = UpgradeService();
      final upgradeInfo = await upgradeService.checkUpgrade();

      // Check if app is in maintenance mode
      if (upgradeInfo.maintain) {
        if (mounted) {
          context.go(AppRoutes.maintenance); // You'll need to add this route
          return;
        }
      }

      // Check if app needs update
      final needsUpdate = await upgradeService.needsUpdate(upgradeInfo);
      if (needsUpdate) {
        if (mounted) {
          context.go(AppRoutes.update); // You'll need to add this route
          return;
        }
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        // This will validate the token by making an API call
        await authProvider.checkLoginStatusWithoutRedirect(context);

        // If we get here, token is valid
        if (authProvider.isLoggedIn) {
          final productProvider =
              Provider.of<ProductProvider>(context, listen: false);
          final postProvider =
              Provider.of<PostProvider>(context, listen: false);
          final businessProvider =
              Provider.of<BusinessProvider>(context, listen: false);

          await Future.wait([
            productProvider.getListProduct(context),
            postProvider.fetchPostsFeatured(context),
            postProvider.fetchPosts(context),
            businessProvider.getListBusiness(context),
            _fetchUserPosts(postProvider),
          ], eagerError: true)
              .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('Kết nối mạng quá chậm'),
          );

          if (mounted && !GlobalAppState.launchedFromNotification) {
            context.go(AppRoutes.trangChu);
          }
        } else {
          // Not logged in, go to login screen
          if (mounted) context.go(AppRoutes.login);
        }
      } catch (tokenError) {
        // Token validation failed - explicitly handle this case
        print('Invalid token detected: $tokenError');
        await authProvider.clearAllDataIOS(); // Clear all keychain data

        if (mounted) context.go(AppRoutes.login);
        return;
      }
    } catch (e) {
      // Handle other errors
      await _handleApiError('Đã xảy ra lỗi không xác định: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// Phương thức riêng để fetch bài viết người dùng
  Future<void> _fetchUserPosts(PostProvider postProvider) async {
    try {
      await postProvider.fetchPostsByUser(context);
    } catch (postError) {
      // Log lỗi chi tiết
      debugPrint('Chi tiết lỗi lấy bài viết: $postError');
      throw Exception('Không thể lấy bài viết của bạn');
    }
  }

// Phương thức xử lý lỗi tập trung
  Future<void> _handleApiError(String errorMessage) async {
    if (!mounted) return;

    // Cập nhật trạng thái lỗi
    setState(() {
      _hasError = true;
      _errorMessage = errorMessage;
      _isLoading = false;
    });

    // Log lỗi
    debugPrint(errorMessage);

    // Chuyển đến màn hình đăng nhập sau 3 giây
    await Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              width: isSmallScreen ? 200 : 354,
              height: isSmallScreen ? 125 : 250,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
