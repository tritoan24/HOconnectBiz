import 'package:clbdoanhnhansg/config/app_config.dart';
import 'package:clbdoanhnhansg/core/services/socket_service.dart';
import 'package:clbdoanhnhansg/providers/StatisticalProvider.dart';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:clbdoanhnhansg/providers/banner_provider.dart';
import 'package:clbdoanhnhansg/providers/bo_provider.dart';
import 'package:clbdoanhnhansg/providers/business_op_provider.dart';
import 'package:clbdoanhnhansg/providers/business_provider.dart';
import 'package:clbdoanhnhansg/providers/cart_provider.dart';
import 'package:clbdoanhnhansg/providers/chat_provider.dart';
import 'package:clbdoanhnhansg/providers/comment_provider.dart';
import 'package:clbdoanhnhansg/providers/membership_provider.dart';
import 'package:clbdoanhnhansg/providers/notification_provider.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/providers/product_provider.dart';
import 'package:clbdoanhnhansg/providers/rank_provider.dart';
import 'package:clbdoanhnhansg/providers/user_provider.dart';
import 'package:clbdoanhnhansg/utils/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'package:clbdoanhnhansg/config/app_config.dart';
import 'package:lottie/lottie.dart'; // Thêm import package Lottie
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(AppConfig.oneSignalAppId);
  OneSignal.Notifications.requestPermission(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BusinessOpProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RankProvider()),
        ChangeNotifierProvider(create: (_) => BoProvider()),
        ChangeNotifierProvider(create: (_) => MemberShipProvider()),
        ChangeNotifierProvider(create: (_) => StatisticalProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SocketService()),
      ],
      child: const MyApp(),
    ),
  );
}

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

  Future<void> _initializeApp() async {
    setState(() => _isInitializing = true);

    // Request permissions first
    await PermissionService.requestPermissions(context);

    // Then check login status
    if (mounted) {
      await Provider.of<AuthProvider>(context, listen: false)
          .checkLoginStatus(context);
    }

    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp.router(
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
          title: 'GoRouter Flutter Example',
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                if (_isInitializing)
                  Material(
                    color: Colors.black54,
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/loading.json',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
