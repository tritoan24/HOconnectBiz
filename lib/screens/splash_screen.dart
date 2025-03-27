import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/product_provider.dart';
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
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatusWithoutRedirect(context);

      if (authProvider.isLoggedIn) {
        // Tách riêng các API khác với fetchPostsByUser
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final postProvider = Provider.of<PostProvider>(context, listen: false);

        // Gọi các API không quan trọng - chạy song song
        final basicFutures = <Future>[];
        basicFutures.add(productProvider.getListProduct(context));
        basicFutures.add(postProvider.fetchPostsFeatured(context));

        // Chạy API quan trọng riêng để kiểm tra kết quả
        bool userPostsSuccess = false;
        try {
          await postProvider.fetchPostsByUser(context);
          userPostsSuccess = true;
        } catch (postError) {
          print('Lỗi khi lấy bài viết của người dùng: $postError');
          userPostsSuccess = false;
        }

        // Đợi các API khác hoàn thành
        await Future.wait(basicFutures);

        // Chỉ cho phép vào Home nếu fetchPostsByUser thành công
        if (mounted) {
          if (userPostsSuccess) {
            context.go(AppRoutes.trangChu);
          } else {
            // Xử lý khi API trả về status 0 - chuyển đến Login
            setState(() {
              _hasError = true;
              _errorMessage = 'Không thể lấy thông tin bài viết của bạn';
            });

            // Chuyển đến Login sau 3 giây
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) context.go(AppRoutes.login);
            });
          }
        }
      } else {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      print('Lỗi khi chuyển hướng: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Đã xảy ra lỗi: ${e.toString()}';
        });

        // Sau 3 giây nếu có lỗi, chuyển sang màn hình login
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) context.go(AppRoutes.login);
        });
      }
    }
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
            if (_hasError)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
