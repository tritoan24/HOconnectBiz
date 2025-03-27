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
      if (event.notification.jsonRepresentation().isNotEmpty) {
        Map<String, dynamic>? data = event.notification.additionalData;
        if (data != null) {
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
              appRouter.push(AppRoutes.tinNhan, extra: stringMap);
              break;
              
            case 'orderbuy':
              Map<String, String>? stringMap = data.map((key, value) {
                if (value is! String) {
                  return MapEntry(key, value.toString());
                }
                return MapEntry(key, value);
              });
              // Use push instead of go to maintain navigation stack
              appRouter.push(AppRoutes.tinNhan, extra: stringMap);
              break;
              
            case 'post':
              // Navigate to post detail screen with the post ID
              appRouter.go('${AppRoutes.home}${AppRoutes.postDetail.replaceFirst(':postId', id)}');
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              MaterialApp.router(
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
                //     //   builder: (context, child) {
                //     //     return Directionality(
                //     //       textDirection: TextDirection.ltr,
                //     //       child: Stack(
                //     //         children: [
                //     //           child!,
                //     //           if (authProvider.isLoading)
                //     //             Material(
                //     //               color: Colors.black54,
                //     //               child: Center(
                //     //                 child: Lottie.asset(
                //     //                   'assets/lottie/loading.json',
                //     //                   width: 70,
                //     //                   height: 70,
                //     //                   fit: BoxFit.contain,
                //     //                 ),
                //     //               ),
                //     //             )
                //     //         ],
                //     //       ),
                //     //     );
                //     //   },
                //     // ),
                //     // if (_isInitializing)
                //     //   Material(
                //     //     color: Colors.black54,
                //     //     child: Center(
                //     //       child: Lottie.asset(
                //     //         'assets/lottie/loading.json',
                //     //         width: 70,
                //     //         height: 70,
                //     //         fit: BoxFit.contain,
                //     //       ),
                //     //     ),
              ),
            ],
          ),
        );
      },
    );
  }
}
