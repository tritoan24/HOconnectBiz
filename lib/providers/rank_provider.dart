import 'package:flutter/cupertino.dart';
import 'package:clbdoanhnhansg/repository/rank_repository.dart';

import '../models/apiresponse.dart';
import '../models/rank_model.dart';

class RankProvider with ChangeNotifier {
  final RankRepository _rankRepository = RankRepository();
  List<Rank> _ranksRevenue = []; // Doanh thu loại 1
  List<Rank> _ranksBusiness = []; // Doanh thu loại 2
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  List<Rank> get rankRevenue => _ranksRevenue;
  List<Rank> get rankBusiness => _ranksBusiness;
  String get errorMessage => _errorMessage;

  Future<void> fetchRanksRevenue(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ApiResponse response =
          await _rankRepository.getRankRevenue(context);

      if (response.isSuccess && response.data is List) {
        // Chỉ chuyển đổi dữ liệu từ API sang model, không thêm xử lý
        _ranksRevenue = (response.data as List)
            .map((json) => Rank.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = response.message ?? 'Không có dữ liệu';
        _ranksRevenue = [];
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu: $e";
      print(_errorMessage);
      _ranksRevenue = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRankBusiness(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ApiResponse response =
          await _rankRepository.getRankBusiness(context);

      if (response.isSuccess && response.data is List) {
        // Chỉ chuyển đổi dữ liệu từ API sang model, không thêm xử lý
        _ranksBusiness = (response.data as List)
            .map((json) => Rank.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = response.message ?? 'Không có dữ liệu';
        _ranksBusiness = [];
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu: $e";
      print(_errorMessage);
      _ranksBusiness = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}

