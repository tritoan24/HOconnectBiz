import 'dart:convert';
import 'dart:io';
import 'package:clbdoanhnhansg/repository/banner_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Getter đúng cú pháp
  List<String> get allImageUrls => _banner
      .where((banner) => banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
      .map((banner) => banner.imageUrl!)
      .toList();

  // Key lưu trữ cache
  static const String _cacheKey = "cached_banners";
  static const String _cacheDateKey = "cached_banners_date";
  
  // Thời gian cache hết hạn (1 giờ)
  static const int _cacheExpiryHours = 1;

  //get list post
  Future<void> getListBanner(BuildContext context) async {
    if (_isLoading) return; // Tránh gọi đồng thời nhiều lần
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      bool hasDisplayedCache = false;

      // Luôn hiển thị dữ liệu từ cache trước nếu có
      final cachedBanners = prefs.getStringList(_cacheKey);
      if (cachedBanners != null && cachedBanners.isNotEmpty) {
        _banner = cachedBanners.map((url) => BannerModel(imageUrl: url)).toList();
        notifyListeners();
        hasDisplayedCache = true;
        
        // Đánh dấu không còn loading để UI phản hồi nhanh
        _isLoading = false;
        notifyListeners();
      }
      
      // Luôn âm thầm cập nhật từ mạng, không phụ thuộc vào thời gian cache
      final response = await _bannerRepository.getBanner(context);

      if (response.isSuccess && response.data is List) {
        final newBanners = (response.data as List)
            .map((item) => BannerModel.fromJson(item))
            .toList();
            
        // Kiểm tra xem dữ liệu mới có khác với dữ liệu cache không
        final newImageUrls = newBanners
            .where((banner) => banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
            .map((banner) => banner.imageUrl!)
            .toList();
            
        final isSameData = _areListsEqual(newImageUrls, cachedBanners ?? []);
        
        if (!isSameData) {
          // Chỉ cập nhật UI và cache nếu dữ liệu mới khác với cache
          _banner = newBanners;
          
          // Lưu vào SharedPreferences với thời gian hiện tại
          await prefs.setStringList(_cacheKey, newImageUrls);
          await prefs.setString(_cacheDateKey, DateTime.now().toIso8601String());
          
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error appropriately
      print('Error fetching banner: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Hàm hỗ trợ so sánh hai danh sách
  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    
    return true;
  }
  
  // Xóa cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheDateKey);
  }
}

