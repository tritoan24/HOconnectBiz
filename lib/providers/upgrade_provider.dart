import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

import '../models/upgradeinfo.dart';

class UpgradeService {
  static const String apiUrl = 'https://doanhnghiepapp.webest.asia/api/upgrade';

  Future<UpgradeInfo> checkUpgrade() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Upgrade info: $data');
        return UpgradeInfo.fromJson(data);
      } else {
        throw Exception('Failed to load upgrade info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking for upgrade: $e');
    }
  }

  Future<bool> needsUpdate(UpgradeInfo upgradeInfo) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    if (Platform.isIOS) {
      return currentVersion != upgradeInfo.appStoreInfo;
    } else {
      return currentVersion != upgradeInfo.appGooglePlayInfo;
    }
  }
}
