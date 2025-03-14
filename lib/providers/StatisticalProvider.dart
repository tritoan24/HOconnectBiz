import 'package:flutter/material.dart';
import '../models/statistical_model.dart';
import '../core/base/base_provider.dart';
import '../repository/statistical_reponsitory.dart';

class StatisticalProvider extends BaseProvider {
  final StatisticalRepository _repository = StatisticalRepository();
  List<StatisticalModel> _statistics = [];
  int totalMembers = 0;
  int currentPage = 1;
  final int limit = 10;

  List<StatisticalModel> get statistics => _statistics;

  Future<void> fetchStatistics(BuildContext context, {int page = 1}) async {
    setLoading(true);
    try {
      final response =
          await _repository.getListStatistical(context, page, limit);
      if (response.isSuccess) {
        _statistics = (response.data as List)
            .map((item) => StatisticalModel.fromJson(item))
            .toList();
        totalMembers = response.total ?? 0;
        currentPage = page;
        notifyListeners();
      } else {
        setError(response.message ?? "Lỗi không xác định");
      }
    } catch (e) {
      setError("Lỗi kết nối: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }
}
