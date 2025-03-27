import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/product_provider.dart';
import '../providers/user_provider.dart';
import '../utils/router/router.name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Chuyển hướng sau khoảng thời gian
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Delay ngắn để hiển thị splash screen
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatusWithoutRedirect(context);

      if (authProvider.isLoggedIn) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final postProvider = Provider.of<PostProvider>(context, listen: false);

        try {
          // Sử dụng Future.wait với timeout để quản lý các API song song
          await Future.wait([
            productProvider.getListProduct(context),
            postProvider.fetchPostsFeatured(context),
            _fetchUserPosts(postProvider),
          ], eagerError: true)
              .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('Kết nối mạng quá chậm'),
          );

          // Nếu tất cả API đều thành công
          if (mounted) context.go(AppRoutes.trangChu);
        } on TimeoutException catch (e) {
          await _handleApiError(
              'Kết nối mạng chậm. Vui lòng kiểm tra đường truyền.');
        } on Exception catch (e) {
          await _handleApiError('Không thể tải dữ liệu. Vui lòng thử lại.');
        }
      } else {
        // Không đăng nhập thì chuyển đến màn hình đăng nhập
        context.go(AppRoutes.login);
      }
    } catch (e) {
      // Xử lý các lỗi không mong muốn
      await _handleApiError('Đã xảy ra lỗi không xác định: ${e.toString()}');
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
