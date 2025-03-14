import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Quản lý tất cả cấu hình ứng dụng từ file .env
class AppConfig {
  // Authentication
  static String get clientIdIos => dotenv.env['CLIENT_ID_IOS']!;
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID']!;
  static String get facebookAppId => dotenv.env['FACEBOOK_APP_ID']!;
  
  // API
  static String get apiBaseUrl => dotenv.env['API_BASE_URL']!;
  
  // Push Notifications
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID']!;
  
  // Socket
  static String get socketServerUrl => dotenv.env['SOCKET_SERVER_URL']!;
  
  // App Info
  static String get appName => dotenv.env['APP_NAME']!;
  static String get appVersion => dotenv.env['APP_VERSION']!;
  static bool get debugMode => dotenv.env['DEBUG_MODE'] == 'true';
}