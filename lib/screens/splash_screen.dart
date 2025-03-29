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
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Không delay nữa, bắt đầu tải dữ liệu ngay lập tức
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

          // Kiểm tra xem ứng dụng có được mở từ notification không
          if (mounted) {
            if (GlobalAppState.launchedFromNotification && GlobalAppState.notificationData != null) {
              // Xử lý điều hướng dựa trên notification data
              _handleNotificationNavigation(GlobalAppState.notificationData!);
            } else {
              // Điều hướng mặc định nếu không có notification
              context.go(AppRoutes.trangChu);
            }
          }
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
    } finally {
      // Đảm bảo tắt trạng thái loading ngay cả khi có lỗi
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

  // Phương thức mới để xử lý điều hướng dựa trên notification
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (!mounted) return;
    
    final String type = data['type'] ?? '';
    final String id = data['id'] ?? '';
    
    print("Đang xử lý thông báo, loại: $type, ID: $id");

    switch (type) {
      case 'inbox':
        Map<String, String> stringMap = data.map((key, value) {
          if (value is! String) {
            return MapEntry(key, value.toString());
          }
          return MapEntry(key, value);
        });
        
        print("Điều hướng đến màn hình tin nhắn với dữ liệu: $stringMap");
        context.go(AppRoutes.tinNhan, extra: stringMap);
        break;
      
      case 'post':
        print("Điều hướng đến trang chủ với ID bài viết để lấy thông tin chi tiết");
        
        // Lưu ID bài viết để xử lý ở trang chủ
        context.go(AppRoutes.trangChu, extra: {'postId': id});
        break;
        
      case 'ordersell':
        print("Điều hướng đến trang chủ trước khi xem đơn hàng bán");
        context.go(AppRoutes.trangChu, extra: {'cartTab': 'sale'});
        break;
        
      case 'orderbuy':
        print("Điều hướng đến trang chủ trước khi xem đơn hàng mua");
        context.go(AppRoutes.trangChu, extra: {'cartTab': 'buy'});
        break;
        
      case 'bo':
        print("Điều hướng đến trang cơ hội kinh doanh");
        context.go(AppRoutes.trangChu, extra: {'showBusinessOpportunities': true});
        break;
        
      default:
        print("Loại thông báo không xác định, điều hướng đến trang thông báo");
        context.go(AppRoutes.thongBao, extra: data);
        break;
    }
    
    // Xóa thông tin thông báo sau khi đã xử lý
    GlobalAppState.clearNotificationData();
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
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006AF5)),
              ),
            if (_hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
