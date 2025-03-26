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
        // Lấy danh sách rank từ API
        List<Rank> ranks = (response.data as List)
            .map((json) => Rank.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Xử lý lọc user trùng lặp
        Map<String, Rank> uniqueRanks = {};
        for (var rank in ranks) {
          // Nếu user chưa có trong map hoặc có rank thấp hơn, thì cập nhật
          if (!uniqueRanks.containsKey(rank.id) || uniqueRanks[rank.id]!.rank > rank.rank) {
            uniqueRanks[rank.id] = rank;
          }
        }
        
        // Chuyển map thành list và sắp xếp theo rank
        _ranksRevenue = uniqueRanks.values.toList()
          ..sort((a, b) => a.rank.compareTo(b.rank));
        
        print('Ranks Revenue fetched: ${_ranksRevenue.length} items after removing duplicates');
      } else {
        _errorMessage = response.message ?? 'Không có dữ liệu';
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu: $e";
      print(_errorMessage);
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
        // Lấy danh sách rank từ API
        List<Rank> ranks = (response.data as List)
            .map((json) => Rank.fromJson(json as Map<String, dynamic>))
            .toList();
            
        // Xử lý lọc user trùng lặp
        Map<String, Rank> uniqueRanks = {};
        for (var rank in ranks) {
          // Nếu user chưa có trong map hoặc có rank thấp hơn, thì cập nhật
          if (!uniqueRanks.containsKey(rank.id) || uniqueRanks[rank.id]!.rank > rank.rank) {
            uniqueRanks[rank.id] = rank;
          }
        }
        
        // Chuyển map thành list và sắp xếp theo rank
        _ranksBusiness = uniqueRanks.values.toList()
          ..sort((a, b) => a.rank.compareTo(b.rank));
        
        print('Ranks Business fetched: ${_ranksBusiness.length} items after removing duplicates');
      } else {
        _errorMessage = response.message ?? 'Không có dữ liệu';
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu: $e";
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }
}

