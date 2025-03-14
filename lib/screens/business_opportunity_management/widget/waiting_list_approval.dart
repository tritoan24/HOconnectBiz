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

class CompanyBottomSheet {
  static void show(BuildContext context, {required List<IsJoin> isJoin}) {
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
        ),
      ),
    );
  }
}

class _CompanyList extends StatefulWidget {
  final ScrollController scrollController;
  final List<IsJoin> isJoin;

  const _CompanyList({
    Key? key,
    required this.scrollController,
    required this.isJoin,
  }) : super(key: key);

  @override
  State<_CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<_CompanyList> {
  // Thay _selectedCompanyIndex bằng Set<int> để lưu nhiều chỉ số
  final Set<int> _selectedCompanyIndices = {};

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
                                // Sửa từ Image.asset thành Image.network
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
                              join.user?.companyName ?? 'Không có tên',
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
                          final businessProvider =
                              Provider.of<BusinessOpProvider>(context,
                                  listen: false);
                          await businessProvider.approveBusiness(
                              selectedIds, context);

                          // 🛑 Đóng Dialog & BottomSheet một cách an toàn
                          if (mounted)
                            Navigator.pop(context, true); // Đóng Dialog
                          if (mounted)
                            Navigator.pop(context, true); // Đóng BottomSheet

                          // 🔄 Gọi API cập nhật danh sách mới nhất
                          final boProvider =
                              Provider.of<BoProvider>(context, listen: false);
                          await boProvider.fetchBoDataById(
                              context, boProvider.selectedBo?.id ?? '');
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

