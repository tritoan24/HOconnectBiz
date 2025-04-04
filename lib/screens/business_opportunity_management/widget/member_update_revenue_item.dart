import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../models/is_join_model.dart';
import '../../../utils/router/router.name.dart';
import '../../../widgets/text_styles.dart';

class UpdateRevenueForm extends StatefulWidget {
  final Function(double revenue, double deduction, int status)? onSave;
  final double? initialRevenue;
  final double? initialDeduction;
  final IsJoin? member;
  const UpdateRevenueForm({
    super.key,
    this.onSave,
    this.initialRevenue,
    this.initialDeduction,
    this.member,
  });

  @override
  State<UpdateRevenueForm> createState() => _UpdateRevenueFormState();
}

class _UpdateRevenueFormState extends State<UpdateRevenueForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _revenueController = TextEditingController();
  final TextEditingController _deductionController = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  // Thêm biến để lưu trạng thái đã chọn
  late int _currentStatus;

  // Helper method to convert status int to message
  String getStatusMessage(int status) {
    switch (status) {
      case 0:
        return 'Chưa cập nhật';
      case 1:
        return 'Đã gặp gỡ';
      case 2:
        return 'Đã ký hợp đồng';
      case 3:
        return 'Đã thanh toán';
      case 4:
        return 'Đã xoá';
      default:
        return 'Chưa cập nhật';
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial values if provided
    if (widget.initialRevenue != null) {
      _revenueController.text =
          _formatter.format(widget.initialRevenue!.toInt());
    }
    if (widget.initialDeduction != null) {
      _deductionController.text =
          _formatter.format(widget.initialDeduction!.toInt());
    }

    // Khởi tạo trạng thái từ member hoặc mặc định là 0
    _currentStatus = widget.member?.status?.toInt() ?? 0;

    _revenueController.addListener(() => _formatMoney(_revenueController));
    _deductionController.addListener(() => _formatMoney(_deductionController));
  }

  @override
  void dispose() {
    _revenueController.removeListener(() => _formatMoney(_revenueController));
    _deductionController
        .removeListener(() => _formatMoney(_deductionController));
    _revenueController.dispose();
    _deductionController.dispose();
    super.dispose();
  }

  void _formatMoney(TextEditingController controller) {
    String text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isNotEmpty) {
      String formatted = _formatter.format(int.parse(text));
      if (formatted != controller.text) {
        controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng _currentStatus để hiển thị trạng thái hiện tại
    String statusMessage = getStatusMessage(_currentStatus);

    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member info section
          if (widget.member != null) ...[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and name row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage(widget.member!.user!.avatarImage),
                        onBackgroundImageError: (_, __) {
                          // Handle error
                        },
                        child: ClipOval(
                          child: Image.network(
                            widget.member!.user!.avatarImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                UrlImage.errorImage,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.member!.user!.companyName.isEmpty
                              ? 'Chưa cập nhật'
                              : widget.member!.user!.companyName,
                          style: TextStyles.textStyleNormal14W400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Status row
                  Row(
                    children: [
                      Text(
                        "Trạng thái: ",
                        style: TextStyles.textStyleNormal14W500,
                      ),
                      _buildStatusTag(statusMessage),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Doanh thu field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Doanh thu:",
              style: TextStyles.textStyleNormal14W500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FormBuilderTextField(
              controller: _revenueController,
              name: 'doanhThu',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                hintText: 'Nhập doanh thu',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xffB9BDC1),
                    width: 1.0,
                  ),
                ),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xffB9BDC1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xffB9BDC1),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    'đ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 20, minHeight: 20),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Trích quỹ field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Trích quỹ:",
              style: TextStyles.textStyleNormal14W500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FormBuilderTextField(
              controller: _deductionController,
              name: 'trichQuy',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                hintText: 'Nhập trích quỹ',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xffB9BDC1),
                    width: 1.0,
                  ),
                ),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xffB9BDC1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xffB9BDC1),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    'đ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 20, minHeight: 20),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    // Parse values from formatted text
                    String revenueText = _revenueController.text
                        .replaceAll(RegExp(r'[^0-9]'), '');
                    String deductionText = _deductionController.text
                        .replaceAll(RegExp(r'[^0-9]'), '');

                    double revenue =
                        revenueText.isEmpty ? 0 : double.parse(revenueText);
                    double deduction =
                        deductionText.isEmpty ? 0 : double.parse(deductionText);

                    // Sử dụng _currentStatus khi gọi callback
                    if (widget.onSave != null) {
                      widget.onSave!(revenue, deduction, _currentStatus);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD6E9FF),
                  foregroundColor: Colors.blue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Lưu', style: TextStyles.textStyleNormal14W500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom StatusTag widget (derived from MemberCard)
  Widget _buildStatusTag(String statusMessage) {
    Color getColor(String message) {
      switch (message) {
        case 'Đã thanh toán':
          return Colors.green;
        case 'Đã ký hợp đồng':
          return Colors.red;
        case 'Đã gặp gỡ':
          return Colors.orange;
        case 'Đã xoá':
          return Colors.grey;
        case 'Chưa cập nhật':
        default:
          return Colors.grey;
      }
    }

    return GestureDetector(
      onTap: () {
        _showStatusBottomSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: getColor(statusMessage).withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(children: [
          Text(
            statusMessage,
            style: TextStyle(
              color: getColor(statusMessage),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          SvgPicture.asset(
            'assets/icons/edit_bo.svg',
            width: 16,
            height: 16,
            color: getColor(statusMessage),
          ),
        ]),
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context) {
    // Danh sách các trạng thái có thể chọn
    final List<Map<String, dynamic>> statusOptions = [
      {'id': 1, 'title': 'Đã gặp gỡ'},
      {'id': 2, 'title': 'Đã ký hợp đồng'},
      {'id': 3, 'title': 'Đã thanh toán'},
    ];

    // Lưu trạng thái đã chọn tạm thời
    int tempSelectedStatus = _currentStatus;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header với tiêu đề và nút đóng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),

                  // Danh sách các trạng thái
                  Expanded(
                    child: ListView.separated(
                      itemCount: statusOptions.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xffF4F5F6),
                      ),
                      itemBuilder: (context, index) {
                        final statusItem = statusOptions[index];
                        final bool isSelected =
                            tempSelectedStatus == statusItem['id'];

                        return ListTile(
                          title: Text(
                            statusItem['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          trailing: GestureDetector(
                            onTap: () {
                              setState(() {
                                tempSelectedStatus = statusItem['id'];
                              });
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              tempSelectedStatus = statusItem['id'];
                            });
                          },
                        );
                      },
                    ),
                  ),

                  // Nút lưu
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Cập nhật trạng thái và đóng modal
                        this.setState(() {
                          _currentStatus = tempSelectedStatus;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffD6E9FF),
                        foregroundColor: Colors.blue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lưu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
