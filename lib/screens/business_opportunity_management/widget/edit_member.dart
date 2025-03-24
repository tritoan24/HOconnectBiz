import 'package:clbdoanhnhansg/models/auth_model.dart';
import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/waiting_list_approval.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:clbdoanhnhansg/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../providers/bo_provider.dart';
import '../../../providers/business_op_provider.dart';
import '../../../providers/post_provider.dart';
import '../../../utils/router/router.name.dart';
import '../../../widgets/confirmdialog.dart';
import '../../../widgets/text_styles.dart';
import 'details_post_business.dart';

class EditMember extends StatefulWidget {
  final List<IsJoin> data;
  final List<IsJoin> member;
  final AuthorBusiness author;
  const EditMember({
    super.key,
    required this.data,
    required this.member,
    required this.author,
  });

  @override
  State<EditMember> createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMember> {
  late List<IsJoin> _data;
  late List<IsJoin> _member;
  bool _hasChanges = false;
  late BusinessOpProvider businessProvider;

  @override
  void initState() {
    super.initState();
    _data = List.from(widget.data);
    _member = List.from(widget.member);

    // Initialize the business provider
    businessProvider = Provider.of<BusinessOpProvider>(context, listen: false);

    // Add listener to check for navigation changes
    businessProvider.addListener(_checkNavigation);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    businessProvider.removeListener(_checkNavigation);
    super.dispose();
  }

  // Check navigation method similar to CompanyBottomSheet
  void _checkNavigation() {
    if (businessProvider.shouldNavigate && mounted && context.mounted) {
      final String postId = businessProvider.pendingNavigationPostId;

      // Pop current screen
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Schedule navigation after the frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Clear navigation state
        businessProvider.clearNavigation();

        // Navigate to details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPostBusiness(
              idPost: postId,
              isInBusiness: true,
            ),
          ),
        );

        // Refresh post data
        Provider.of<PostProvider>(context, listen: false)
            .fetchPostsByUser(context);
      });
    }
  }

  void deleteMember(String idPost, String idMember) async {
    try {
      final boProvider = Provider.of<BoProvider>(context, listen: false);
      await boProvider.deleteBoData(context, idPost, idMember);

      // Cập nhật danh sách sau khi xóa thành công
      setState(() {
        _data.removeWhere((member) => member.id.toString() == idMember);
        _hasChanges = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thành viên thành công")),
      );
    } catch (e) {
      print("Lỗi khi xóa thành viên: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xóa thành viên thất bại: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Trả về true để cho phép thoát, đồng thời gửi tín hiệu cần refresh
        Navigator.pop(context, _hasChanges);
        return false; // Chúng ta đã tự xử lý việc pop rồi
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundColorApp,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          title: const Text('Thành viên tham gia'),
          actions: [
            GestureDetector(
              onTap: () {
                CompanyBottomSheet.show(context, isJoin: _member);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/icon_list.svg',
                        ),
                        Positioned(
                          right: -8,
                          top: -7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              "${_member.length}",
                              style: TextStyles.textStyleNormal12W400White,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chờ phê duyệt',
                      style: TextStyles.textStyleNormal12W500,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // 🟢 Hiển thị thông tin Author ở đầu danh sách
              _buildAuthorSection(),
              // 🟢 Danh sách thành viên
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _data.isEmpty
                      ? const Center(child: Text("Không có thành viên nào"))
                      : ListView.builder(
                          itemCount: _data.length,
                          itemBuilder: (context, index) {
                            final dt = _data[index];

                            return Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.grey[200],
                                    child: ClipOval(
                                      child: Image.network(
                                        dt.user?.avatarImage ?? '',
                                        fit: BoxFit.cover,
                                        width: 48,
                                        height: 48,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.network(
                                            UrlImage.errorImage,
                                            fit: BoxFit.cover,
                                            width: 48,
                                            height: 48,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    dt.user?.displayName ?? "Không có tên",
                                    style: TextStyles.textStyleNormal14W400,
                                  ),
                                  trailing: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CustomConfirmDialog(
                                                content:
                                                    "Bạn có chắc chắn muốn xóa thành viên này?",
                                                titleButtonRight: "Xóa",
                                                titleButtonLeft: "Hủy",
                                                onConfirm: () {
                                                  deleteMember(
                                                      dt.postId.toString(),
                                                      dt.id.toString());
                                                },
                                              );
                                            });
                                      },
                                      child: const Text(
                                        'Xoá',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 13),
                                const HorizontalDivider(),
                                const SizedBox(height: 13),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🟢 Widget hiển thị thông tin `Author` ở đầu trang
  Widget _buildAuthorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: Image.network(
                  widget.author.avatarImage ?? '',
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      UrlImage.errorImage,
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                    );
                  },
                ),
              ),
            ),
            title: Text(
              widget.author.companyName.toString(),
              style: TextStyles.textStyleNormal14W400,
            ),
            trailing: const Text(
              'Chủ sở hữu',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 17),
          const HorizontalDivider(),
        ],
      ),
    );
  }
}
