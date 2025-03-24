import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/widgets/button_widget16.dart';
import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/tab_outside_business.dart';
import 'package:provider/provider.dart';
import '../../../providers/bo_provider.dart';
import '../../../providers/business_op_provider.dart';
import '../../../widgets/confirmdialog.dart';
import '../../manage/widget/shop/widget/checkbox.dart';
import '../../manage/widget/shop/widget/un_checkbox.dart';
import '../../../screens/business_opportunity_management/widget/details_post_business.dart';

class CompanyBottomSheet {
  static void show(BuildContext context,
      {required List<IsJoin> isJoin, String? postId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _CompanyList(
          scrollController: scrollController,
          isJoin: isJoin,
          postId: postId ?? '',
        ),
      ),
    );
  }
}

class _CompanyList extends StatefulWidget {
  final ScrollController scrollController;
  final List<IsJoin> isJoin;
  final String postId;

  const _CompanyList({
    Key? key,
    required this.scrollController,
    required this.isJoin,
    required this.postId,
  }) : super(key: key);

  @override
  State<_CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<_CompanyList> {
  // Thay _selectedCompanyIndex bằng Set<int> để lưu nhiều chỉ số
  final Set<int> _selectedCompanyIndices = {};
  late BusinessOpProvider businessProvider;

  @override
  void initState() {
    super.initState();
    // Khởi tạo businessProvider
    businessProvider = Provider.of<BusinessOpProvider>(context, listen: false);

    // Lắng nghe sự thay đổi của businessProvider
    businessProvider.addListener(_checkNavigation);
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi widget bị hủy
    businessProvider.removeListener(_checkNavigation);
    super.dispose();
  }

  // Phương thức kiểm tra và xử lý điều hướng
  void _checkNavigation() {
    // Nếu cần điều hướng và context còn hợp lệ
    if (businessProvider.shouldNavigate && mounted && context.mounted) {
      final String postId = businessProvider.pendingNavigationPostId;

      // Đóng bottom sheet nếu đang mở
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Điều hướng đến trang chi tiết - Sử dụng push thông thường để giữ nguyên stack điều hướng
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Xóa trạng thái điều hướng sau khi đã đặt lịch điều hướng
        businessProvider.clearNavigation();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPostBusiness(
              idPost: postId,
              isInBusiness: true,
            ),
          ),
        );

        Provider.of<PostProvider>(context, listen: false)
            .fetchPostsByUser(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách các công ty chưa được chấp nhận
    final pendingCompanies =
        widget.isJoin.where((join) => join.isAccept == false).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Company list
          Expanded(
            child: pendingCompanies.isEmpty
                ? const Center(
                    child: Text("Không có công ty nào chờ phê duyệt"))
                : ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    itemCount: pendingCompanies.length,
                    itemBuilder: (context, index) {
                      final join = pendingCompanies[index];
                      final isSelected =
                          _selectedCompanyIndices.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCompanyIndices.remove(index); // Bỏ chọn
                            } else {
                              _selectedCompanyIndices.add(index); // Chọn
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                join.user?.avatarImage ?? '',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              join.user?.displayName ?? 'Không có tên',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing:
                                isSelected ? const Check() : const UnCheck(),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Confirm button
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ButtonWidget16(
              label: 'Xác nhận',
              onPressed: () {
                if (_selectedCompanyIndices.isNotEmpty) {
                  final selectedCompanies = _selectedCompanyIndices
                      .map((index) => pendingCompanies[index])
                      .toList();

                  showDialog(
                    context: context,
                    builder: (context) => CustomConfirmDialog(
                      content:
                          "Xác nhận đồng ý với việc bạn sẽ thêm các doanh nghiệp này vào nhóm chiến lược",
                      titleButtonRight: 'Xác nhận',
                      titleButtonLeft: 'Quay lại',
                      onConfirm: () async {
                        final List<String> selectedIds = selectedCompanies
                            .map((join) => join.id ?? '')
                            .where((id) => id.isNotEmpty)
                            .toList();

                        if (selectedIds.isNotEmpty) {
                          // Chỉ truyền postId khi nó không rỗng
                          final String postIdToUse = selectedCompanies
                                  .firstWhere(
                                      (join) => join.postId?.isNotEmpty == true,
                                      orElse: () => IsJoin(postId: ''))
                                  .postId ??
                              '';
                          // Gọi API duyệt doanh nghiệp
                          await businessProvider.approveBusiness(
                              selectedIds, context, postIdToUse);
                        }
                      },
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng chọn ít nhất một công ty')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
