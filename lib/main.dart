import 'package:clbdoanhnhansg/app.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

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

  // Khởi tạo các services
  final socketService = SocketService();
  final authProvider = AuthProvider();

  // Lấy userId từ local storage hoặc auth state
  final userId = await authProvider.getuserID();

  if (userId != null) {
    socketService.initializeSocket(userId);
    socketService.connect(userId);
  }

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
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RankProvider()),
        ChangeNotifierProvider(create: (_) => BoProvider()),
        ChangeNotifierProvider(create: (_) => MemberShipProvider()),
        ChangeNotifierProvider(create: (_) => StatisticalProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => socketService),
        ChangeNotifierProvider(
            create: (_) => NotificationProvider(socketService: socketService))
      ],
      child: const MyApp(),
    ),
  );
}
