import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../core/base/base_provider.dart';
import '../repository/business_op_repository.dart';
import 'bo_provider.dart';

class BusinessOpProvider extends BaseProvider {
  final BusinessOpRepository _businessRepo = BusinessOpRepository();

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

  // Future<void> deleteBoData(BuildContext context, String id) async {
  //   try {
  //     final ApiResponse response =
  //     await _boRepository.deleteBoData(context, id);
  //     print("id: " + id);
  //     print(response.isSuccess ? "Xóa bài viết thành công" : response.message);
  //     if (response.isSuccess) {
  //       // Xóa thành viên khỏi danh sách
  //       _lists.removeWhere((bo) => bo.id == id);
  //       notifyListeners();
  //     } else {
  //       print("Lỗi khi xóa bài viết: ${response.message}");
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  Future<void> approveBusiness(
      List<String> postIds, BuildContext context) async {
    setLoading(true);

    await executeApiCall(
      apiCall: () => _businessRepo.approveBusiness(
        context,
        postIds,
      ),
      context: context,
      successMessage: "Duyệt thành công!",
    );

    // 🔄 Cập nhật lại danh sách sau khi duyệt thành công
    final boProvider = Provider.of<BoProvider>(context, listen: false);
    await boProvider.fetchBoDataById(context, boProvider.selectedBo?.id ?? '');

    setLoading(false);
  }
}
