import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/base/base_provider.dart';
import '../repository/business_op_repository.dart';
import '../screens/business_opportunity_management/widget/details_post_business.dart';
import '../widgets/loading_overlay.dart';
import 'bo_provider.dart';

class BusinessOpProvider extends BaseProvider {
  final BusinessOpRepository _businessRepo = BusinessOpRepository();

  // Biến lưu trữ postId cần điều hướng
  String _pendingNavigationPostId = '';
  bool _shouldNavigate = false;

  // Getter để kiểm tra có nên điều hướng không
  bool get shouldNavigate => _shouldNavigate;
  String get pendingNavigationPostId => _pendingNavigationPostId;

  // Xóa trạng thái điều hướng đã sử dụng
  void clearNavigation() {
    _shouldNavigate = false;
    _pendingNavigationPostId = '';
  }

  Future<void> joinBusiness(String postId, BuildContext context) async {
    setLoading(true);

    await executeApiCall(
      apiCall: () => _businessRepo.joinBusiness(
        context,
        postId,
      ),
      context: context,
      onSuccess: () {
        notifyListeners();
      },
      successMessage: "tham gia thành công!",
    );

    setLoading(false);
  }

  Future<bool> approveBusiness(
      List<String> postIds, BuildContext context, String targetPostId) async {
    LoadingOverlay.show(context);
    setLoading(true);

    // Lưu tham chiếu đến BoProvider
    final boProvider = Provider.of<BoProvider>(context, listen: false);

    // Biến để theo dõi liệu cuộc gọi API có thành công hay không
    bool success = false;

    await executeApiCall(
      apiCall: () => _businessRepo.approveBusiness(
        context,
        postIds,
      ),
      context: context,
      successMessage: "Duyệt thành công!",
      onSuccess: () {
        success = true;
      },
    );
    print(
        "🔍 [approveBusiness] success: $success, targetPostId: $targetPostId");

    // Cập nhật dữ liệu nếu thành công
    if (success && targetPostId.isNotEmpty) {
      try {
        // Cập nhật dữ liệu
        await boProvider.fetchBoDataById(context, targetPostId);
        LoadingOverlay.hide();
        // Đặt trạng thái cần điều hướng
        _pendingNavigationPostId = targetPostId;
        _shouldNavigate = true;
        notifyListeners(); // Thông báo cho các widget đang lắng nghe
      } catch (e) {
        print("Lỗi khi fetch dữ liệu: $e");
      }
    }

    // Cập nhật lại danh sách sau khi duyệt thành công
    if (boProvider.selectedBo?.id != null &&
        boProvider.selectedBo!.id.isNotEmpty) {
      try {
        await boProvider.fetchBoDataById(context, boProvider.selectedBo!.id);
        LoadingOverlay.hide();
      } catch (e) {
        LoadingOverlay.hide();
        print("Lỗi khi fetch dữ liệu selectedBo: $e");
      }
    }

    setLoading(false);

    // Trả về kết quả thành công
    return success;
  }
}
