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
      // Đánh dấu rằng ứng dụng đã được mở từ thông báo
      GlobalAppState.launchedFromNotification = true;
      if (event.notification.jsonRepresentation().isNotEmpty) {
        Map<String, dynamic>? data = event.notification.additionalData;
        if (data != null) {
          GlobalAppState.notificationData = data;
          final String type = data['type'] ?? '';
          final String id = data['id'] ?? '';

          switch (type) {
            case 'inbox':
              Map<String, String>? stringMap = data.map((key, value) {
                if (value is! String) {
                  return MapEntry(key, value.toString());
                }
                return MapEntry(key, value);
              });
              // Use push instead of go to maintain navigation stack
              appRouter.push(AppRoutes.tinNhan, extra: stringMap);
              break;

            case 'ordersell':
              Map<String, String>? stringMap = data.map((key, value) {
                if (value is! String) {
                  return MapEntry(key, value.toString());
                }
                return MapEntry(key, value);
              });
              // Use push instead of go to maintain navigation stack
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Cart(initialTab: CartTab.SaleOrder),
                ),
              );
              break;

            case 'orderbuy':
              Map<String, String>? stringMap = data.map((key, value) {
                if (value is! String) {
                  return MapEntry(key, value.toString());
                }
                return MapEntry(key, value);
              });
              // Use push instead of go to maintain navigation stack
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Cart(initialTab: CartTab.PurchaseOrder),
                ),
              );
              break;

            case 'post':
              // Navigate to post detail screen with the post ID
              print("bạn đã chạy vào đây");
              handlePostNavigation(id);
              break;

            case 'bo':
              // Navigate to business opportunity screen
              appRouter.go(AppRoutes.trangChu.replaceFirst(':index', '0'),
                  extra: {'showBusinessOpportunities': true});
              break;

            default:
              // For unknown types, go to notification screen
              appRouter.go(AppRoutes.thongBao, extra: data);
              break;
          }
        } else {
          appRouter.go(AppRoutes.thongBao);
        }
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
    await appRouter.push(AppRoutes.tinNhan, extra: stringMap);
  }

  void _navigateToCart(BuildContext context, CartTab tab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cart(initialTab: tab),
      ),
    );
  }

  Future<void> _handlePostNavigation(String id) async {
    try {
      // Sử dụng context từ navigator để tránh null
      BuildContext? context =
          Navigator.of(navigatorKey.currentContext!).context;

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final post = await postProvider.fetchPostDetail(context, id);

      if (post != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommentsScreen(
              postId: post.id ?? id,
              postType: post.category ?? 0,
              displayName: post.author?.displayName ?? 'Không xác định',
              avatar_image: post.author?.avatarImage ?? '',
              dateTime: post.createdAt?.toString() ?? DateTime.now().toString(),
              title: post.title ?? '',
              content: post.content ?? '',
              images: post.album ?? [],
              business: post.business ?? [],
              product: post.product ?? [],
              likes: post.like ?? [],
              commentCount: post.totalComment ?? 0,
              isMe: true,
              idUser: post.author?.id ?? '',
              isJoin: post.isJoin ?? [],
            ),
          ),
        );
      } else {
        print('Không tìm thấy bài đăng với ID: $id');
      }
    } catch (e) {
      print('Lỗi điều hướng bài đăng: $e');
      // Có thể thêm một số xử lý khác ở đây, chẳng hạn như hiển thị Snackbar
    }
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
      // Sử dụng context từ navigator để tránh null
      BuildContext? context =
          Navigator.of(navigatorKey.currentContext!).context;

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final post = await postProvider.fetchPostDetail(context, id);

      if (post != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommentsScreen(
              postId: post.id ?? id,
              postType: post.category ?? 0,
              displayName: post.author?.displayName ?? 'Không xác định',
              avatar_image: post.author?.avatarImage ?? '',
              dateTime: post.createdAt?.toString() ?? DateTime.now().toString(),
              title: post.title ?? '',
              content: post.content ?? '',
              images: post.album ?? [],
              business: post.business ?? [],
              product: post.product ?? [],
              likes: post.like ?? [],
              commentCount: post.totalComment ?? 0,
              isMe: true,
              idUser: post.author?.id ?? '',
              isJoin: post.isJoin ?? [],
            ),
          ),
        );
      } else {
        print('Không tìm thấy bài đăng với ID: $id');
      }
    } catch (e) {
      print('Lỗi điều hướng bài đăng: $e');
    }
  }
}
