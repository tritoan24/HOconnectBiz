import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
      // Đợi 2 giây để hiển thị splash screen
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Đặt một timer để đảm bảo không bị kẹt ở splash screen
      Timer timeoutTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Không thể kết nối tới máy chủ. Vui lòng thử lại.';
          });
        }
      });
      
      // Kiểm tra xem đã đăng nhập chưa
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus(context);
      
      // Hủy timer vì đã xử lý xong
      timeoutTimer.cancel();
      
      if (!mounted) return;
      
      // Chuyển hướng dựa trên trạng thái đăng nhập
      if (authProvider.isLoggedIn) {
        context.go(AppRoutes.trangChu);
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
          if (mounted) {
            context.go(AppRoutes.login); 
          }
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
              width: isSmallScreen ? 120 : 144,
              height: isSmallScreen ? 65 : 80,
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
            else
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006AF5)),
              ),
          ],
        ),
      ),
    );
  }
}
