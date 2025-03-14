import 'dart:convert';
import 'dart:io';
import 'package:clbdoanhnhansg/repository/banner_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:clbdoanhnhansg/repository/post_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/base/base_provider.dart';
import '../models/banner.dart';
import '../models/posts.dart';
import '../widgets/loading_overlay.dart';

class BannerProvider extends BaseProvider {
  final BannerRepository _bannerRepository = BannerRepository();
  List<BannerModel> _banner = [];
  List<BannerModel> get banner => _banner;

  // Getter đúng cú pháp
  List<String> get allImageUrls => _banner
      .where((banner) => banner.imageUrl != null)
      .map((banner) => banner.imageUrl!)
      .toList();

  //get list post
  Future<void> getListBanner(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Kiểm tra nếu đã có dữ liệu trong cache
      final cachedBanners = prefs.getStringList("cached_banners");
      if (cachedBanners != null && cachedBanners.isNotEmpty) {
        _banner =
            cachedBanners.map((url) => BannerModel(imageUrl: url)).toList();
        notifyListeners();
        return; // ✅ Dùng cache, không gọi API nữa
      }
      final response = await _bannerRepository.getBanner(context);

      if (response.isSuccess && response.data is List) {
        _banner = (response.data as List)
            .map((item) => BannerModel.fromJson(item))
            .toList();

        // Lưu vào SharedPreferences
        await prefs.setStringList("cached_banners", allImageUrls);
        notifyListeners();
      }
    } catch (e) {
      // Handle error appropriately
      print('Error fetching: $e');
    }
  }
}

