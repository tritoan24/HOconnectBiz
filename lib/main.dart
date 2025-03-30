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
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'core/error/error_handler.dart';
import 'core/utils/app_logger.dart';
import 'providers/send_error_log.dart';

import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Cài đặt hướng màn hình chỉ ở chế độ đứng
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Bắt tất cả các lỗi không xử lý trong Zone
  runZonedGuarded(() async {
    // Đảm bảo binding chỉ được gọi một lần

    await initializeDateFormatting('vi', null);

    // Tải file môi trường
    await dotenv.load(fileName: ".env");

    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Thiết lập OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(AppConfig.oneSignalAppId);

    // Cấu hình thêm cho OneSignal
    OneSignal.Notifications.clearAll();
    OneSignal.User.pushSubscription.optIn();
    
    // Yêu cầu quyền thông báo cho iOS
    if (Platform.isIOS) {
      // Đợi một chút để đảm bảo ứng dụng đã khởi động hoàn toàn
      await Future.delayed(const Duration(seconds: 1));
      
      // Cấu hình cho iOS
      await OneSignal.Notifications.requestPermission(true).then((accepted) {
        print("Quyền thông báo iOS: $accepted");
      });
      
      // Đăng ký để nhận thông báo từ xa
      await OneSignal.User.pushSubscription.optIn().then((_) {
        print("Đã đăng ký nhận thông báo từ xa trên iOS");
      });
    }
    
    // Kiểm tra và yêu cầu quyền cho Android 13+
    if (Platform.isAndroid) {
      final isAndroid13Plus = await _isAndroid13OrHigher();
      if (isAndroid13Plus) {
        await OneSignal.Notifications.requestPermission(true);
      }
    }

    // Khởi tạo logger
    await AppLogger().initialize();

    // Thiết lập error handler toàn cục
    ErrorHandler().setupErrorHandling();

    // Khởi tạo socket service
    final socketService = SocketService();
    final authProvider = AuthProvider();

    // Lấy userId từ local storage
    final userId = await authProvider.getuserID();

    // Chỉ kết nối socket khi có userId
    if (userId != null) {
      socketService.initializeSocket(userId);
      socketService.connect(userId);
    }

    // Chạy ứng dụng với các providers
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => authProvider), // Sử dụng instance đã tạo
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
  }, (error, stackTrace) {
    // Xử lý lỗi không được bắt trong Zone
    sendErrorLog(
      level: 3, // Lỗi Zone rất nghiêm trọng
      message: 'Lỗi không xử lý trong Zone: ${error.toString()}',
      additionalInfo: stackTrace.toString(),
    );

    // Log lỗi critical bằng AppLogger
    AppLogger().fatal("App", "Unhandled", "Lỗi không xử lý trong Zone",
        error: error, stackTrace: stackTrace);

    print('❌ Lỗi không xử lý: $error\n$stackTrace');
  });
}

// Kiểm tra xem thiết bị có phải là Android 13 (API level 33) trở lên không
Future<bool> _isAndroid13OrHigher() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }
  return false;
}
