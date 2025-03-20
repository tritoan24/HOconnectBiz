import 'package:flutter/material.dart';
import '../models/statistical_model.dart';
import '../core/base/base_provider.dart';
import '../repository/statistical_reponsitory.dart';
import '../providers/send_error_log.dart';
import 'dart:io';

class StatisticalProvider extends BaseProvider {
  final StatisticalRepository _repository = StatisticalRepository();
  List<StatisticalModel> _statistics = [];
  int totalMembers = 0;
  int currentPage = 1;
  final int limit = 10;
  int _retryCount = 0;
  final int _maxRetry = 3;

  List<StatisticalModel> get statistics => _statistics;

  Future<void> fetchStatistics(BuildContext context, {int page = 1}) async {
    setLoading(true);
    try {
      debugPrint("⏳ StatisticalProvider: Đang tải dữ liệu thống kê (trang $page)...");
      final response =
          await _repository.getListStatistical(context, page, limit);
      if (response.isSuccess) {
        _statistics = (response.data as List)
            .map((item) => StatisticalModel.fromJson(item))
            .toList();
        totalMembers = response.total ?? 0;
        currentPage = page;
        debugPrint("✅ StatisticalProvider: Đã tải ${_statistics.length} bản ghi thành công");
        _retryCount = 0; // Reset retry counter on success
        notifyListeners();
      } else {
        debugPrint("❌ StatisticalProvider: Lỗi response - ${response.message}");
        setError(response.message ?? "Lỗi không xác định");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ StatisticalProvider: Lỗi kết nối - ${e.toString()}");
      
      if (e is SocketException) {
        setError("Không thể kết nối đến máy chủ. Kiểm tra kết nối internet!");
        sendErrorLog(
          level: 2,
          message: "Lỗi Provider StatisticalProvider - SocketException",
          additionalInfo: e.toString(),
        );
      } else if (e is HttpException) {
        setError("Lỗi kết nối đến máy chủ: ${e.toString()}");
        sendErrorLog(
          level: 2,
          message: "Lỗi Provider StatisticalProvider - HttpException",
          additionalInfo: e.toString(),
        );
      } else {
        setError("Lỗi kết nối: ${e.toString()}");
        sendErrorLog(
          level: 1,
          message: "Lỗi Provider StatisticalProvider",
          additionalInfo: "${e.toString()}\n${stackTrace.toString()}",
        );
      }
      
      // Tự động thử lại nếu chưa vượt quá số lần thử
      if (_retryCount < _maxRetry) {
        _retryCount++;
        debugPrint("⏳ Đang thử kết nối lại lần #$_retryCount");
        await Future.delayed(Duration(seconds: 2)); // Delay trước khi thử lại
        return fetchStatistics(context, page: page);
      }
    } finally {
      setLoading(false);
    }
  }
}
