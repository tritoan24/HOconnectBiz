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

    // Đánh dấu đã xử lý trước khi điều hướng
    GlobalAppState.clearNotificationData();

    switch (type) {
      case 'inbox':
        Map<String, String>? stringMap = data.map((key, value) {
          if (value is! String) {
            return MapEntry(key, value.toString());
          }
          return MapEntry(key, value);
        });
        
        // Sử dụng GoRouter.pushReplacement để thay thế màn hình hiện tại
        context.pushReplacement(AppRoutes.tinNhan, extra: stringMap);
        break;

      case 'ordersell':
        // Lưu thông tin cần thiết vào GlobalAppState hoặc cách khác
        GlobalAppState.pendingCartNavigationType = 'sale';
        // Điều hướng về trang chủ và từ đó sẽ xử lý mở Cart
        context.go(AppRoutes.trangChu);
        break;

      case 'orderbuy':
        // Lưu thông tin cần thiết vào GlobalAppState hoặc cách khác
        GlobalAppState.pendingCartNavigationType = 'buy';
        // Điều hướng về trang chủ và từ đó sẽ xử lý mở Cart
        context.go(AppRoutes.trangChu);
        break;

      case 'post':
        // Điều hướng trực tiếp đến màn hình chi tiết post
        context.go('/comments/$id', extra: {
          'postId': id,
          'postType': 0, // Giá trị mặc định
          'displayName': 'Đang tải...',
          'avatar_image': '',
          'dateTime': DateTime.now().toString(),
          'title': '',
          'content': '',
          'images': [],
          'business': [],
          'product': [],
          'likes': [],
          'commentCount': 0,
          'isMe': true,
          'idUser': '',
          'isJoin': [],
          'isBusiness': false,
          'isComment': true,
        });
        break;

      case 'bo':
        context.go(AppRoutes.trangChu.replaceFirst(':index', '0'), 
          extra: {'showBusinessOpportunities': true});
        break;

      default:
        // Mặc định đến trang thông báo
        context.go(AppRoutes.thongBao, extra: data);
        break;
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
