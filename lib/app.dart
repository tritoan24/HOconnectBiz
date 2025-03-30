import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/screens/cart/cart_tab.dart';
import 'package:clbdoanhnhansg/screens/comment/comments_screen.dart';
import 'package:clbdoanhnhansg/utils/global_state.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/router/router.dart';
import 'utils/router/router.name.dart';
import 'widgets/handling_permissions.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// Khởi tạo các dịch vụ cần thiết cho ứng dụng
  Future<void> initializeServices() async {
    // Yêu cầu quyền truy cập
    if (context.mounted) {
      await PermissionService.requestPermissions(context);
    }

    // // Đợi kiểm tra trạng thái đăng nhập
    // if (context.mounted) {
    //   await Provider.of<AuthProvider>(context, listen: false)
    //       .checkLoginStatus(context);
    // }
  }

  Future<void> _initializeApp() async {
    try {
      await initializeServices();
    } catch (e) {
      print("Lỗi khởi tạo: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
    OneSignal.Notifications.addClickListener((event) {
      print("Notification clicked: ${event.notification.jsonRepresentation()}");

      // Get notification data
      Map<String, dynamic>? data = event.notification.additionalData;
      if (data == null) {
        print("No additional data in notification");
        appRouter.go(AppRoutes.thongBao);
        return;
      }

      // Store the notification data
      GlobalAppState.launchedFromNotification = true;

      // Process regardless of app state
      final String type = data['type'] ?? '';
      final String id = data['id'] ?? '';

      print(
          "Processing notification: type=$type, id=$id, app state: ${GlobalAppState.launchedFromNotification ? 'cold start' : 'running'}");

      // Handle navigation based on type using GoRouter only
      switch (type) {
        case 'inbox':
          Map<String, String> stringMap = data.map((key, value) {
            return MapEntry(key, value?.toString() ?? '');
          });

          // Navigate first, then set a cleanup timer
          appRouter.go(AppRoutes.tinNhan, extra: stringMap);

          // Clear notification after navigation is likely complete
          Future.delayed(const Duration(seconds: 10), () {
            GlobalAppState.launchedFromNotification = false;
          });
          break;

        case 'ordersell':
          print("bạn đã chạy vào đây...");
          appRouter.push('/cart', extra: {'initialTab': CartTab.SaleOrder});
          break;

        case 'orderbuy':
          print("bạn đã chạy vào đây cho đơn mua...");
          appRouter.push('/cart', extra: {'initialTab': CartTab.PurchaseOrder});
          break;
        case 'post':
          // Navigate to post detail screen with the post ID
          print("bạn đã chạy vào đây");
          handlePostNavigation(id);
          break;

        case 'bo':
          final String idPost = data['id'] ?? '';
          print("Navigating to business opportunity details: $idPost");
          appRouter.push(AppRoutes.chitietcohoi, extra: {'idPost': idPost});
          break;

        default:
          appRouter.go(AppRoutes.thongBao, extra: data);
          break;
      }
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');

      /// Display Notification, preventDefault to not display
      event.preventDefault();

      /// Do async work

      /// notification.display() to display after preventing default
      event.notification.display();
    });

    OneSignal.InAppMessages.addClickListener((event) {
      print('In App Message Clicked: $event');
    });

    OneSignal.InAppMessages.addWillDisplayListener((event) {
      print("ON WILL DISPLAY IN APP MESSAGE ${event.message.messageId}");
    });

    OneSignal.InAppMessages.addDidDisplayListener((event) {
      print("ON DID DISPLAY IN APP MESSAGE ${event.message.messageId}");
    });

    OneSignal.InAppMessages.addWillDismissListener((event) {
      print("ON WILL DISMISS IN APP MESSAGE ${event.message.messageId}");
    });
  }

  Future<void> _handleInboxNavigation(Map<String, dynamic> data) async {
    Map<String, String> stringMap =
        data.map((key, value) => MapEntry(key, value?.toString() ?? ''));

    // Sử dụng go thay vì push để tránh nhiều màn hình chồng lên nhau
    appRouter.go(AppRoutes.tinNhan, extra: stringMap);

    // Đánh dấu là đã xử lý notification
    GlobalAppState.clearNotificationData();
  }

  void _navigateToCart(BuildContext context, CartTab tab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cart(initialTab: tab),
      ),
    );
  }

  void _navigateToBusinessOpportunities() {
    appRouter.go(AppRoutes.trangChu.replaceFirst(':index', '0'),
        extra: {'showBusinessOpportunities': true});
  }

  void _navigateToNotificationScreen(Map<String, dynamic>? data) {
    appRouter.go(AppRoutes.thongBao, extra: data);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                elevation: 5,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.white,
                backgroundColor: Colors.white,
              ),
            ),
            routerConfig: appRouter,
            title: 'CLB DNSG',
          ),
        );
      },
    );
  }

  Future<void> handlePostNavigation(String id) async {
    try {
      if (!mounted) return;

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final post = await postProvider.fetchPostDetail(context, id);

      if (!mounted) return;

      if (post != null) {
        // Sử dụng go thay vì push để tránh nhiều màn hình chồng lên nhau
        appRouter.go('/comments/${post.id ?? id}', extra: {
          'postId': post.id ?? id,
          'postType': post.category ?? 0,
          'displayName': post.author?.displayName ?? 'Không xác định',
          'avatar_image': post.author?.avatarImage ?? '',
          'dateTime': post.createdAt?.toString() ?? DateTime.now().toString(),
          'title': post.title ?? '',
          'content': post.content ?? '',
          'images': post.album ?? [],
          'business': [],
          'product': [],
          'likes': post.like ?? [],
          'commentCount': post.totalComment ?? 0,
          'isMe': true,
          'idUser': post.author?.id ?? '',
          'isJoin': post.isJoin ?? [],
          'isBusiness': false,
          'isComment': true,
        });
      } else {
        print('Không tìm thấy bài đăng với ID: $id');
        // Fallback navigation với thông tin tối thiểu
        appRouter.go('/comments/$id', extra: {
          'postId': id,
          'postType': 0,
          'displayName': 'Không xác định',
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
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu bài đăng: $e');
    }
  }
}
