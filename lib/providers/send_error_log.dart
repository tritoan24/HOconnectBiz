import 'dart:convert';
import 'dart:io';
import 'package:clbdoanhnhansg/core/network/api_endpoints.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

Future<void> sendErrorLog({
  int level = 1,
  required String message,
  String additionalInfo = "",
}) async {
  // Thu thập thông tin thiết bị và ứng dụng
  final Map<String, dynamic> deviceInfo = await _getDeviceInfo();
  final Map<String, dynamic> appInfo = await _getAppInfo();
  
  final Map<String, dynamic> errorData = {
    "level": level,
    "message": message,
    "additionalInfo": additionalInfo,
    "deviceInfo": deviceInfo,
    "appInfo": appInfo,
    "timestamp": DateTime.now().toIso8601String(),
  };

  try {
    final response = await http.put(
      Uri.parse("${ApiEndpoints.baseUrl}/log/create"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(errorData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Báo cáo lỗi thành công: ${response.statusCode}");
    } else {
      print("Lỗi khi gửi báo cáo: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Lỗi kết nối API báo cáo: $e");
  }
}

// Thu thập thông tin thiết bị
Future<Map<String, dynamic>> _getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic> deviceData = <String, dynamic>{};

  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceData = {
        'type': 'Android',
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'androidVersion': androidInfo.version.release,
        'sdkVersion': androidInfo.version.sdkInt,
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData = {
        'type': 'iOS',
        'model': iosInfo.model,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'identifierForVendor': iosInfo.identifierForVendor,
      };
    }
  } catch (e) {
    print('Lỗi khi lấy thông tin thiết bị: $e');
  }

  return deviceData;
}

// Thu thập thông tin ứng dụng
Future<Map<String, dynamic>> _getAppInfo() async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  } catch (e) {
    print('Lỗi khi lấy thông tin ứng dụng: $e');
    return {'error': 'Không thể lấy thông tin ứng dụng'};
  }
}

