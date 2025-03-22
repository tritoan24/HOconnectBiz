import 'package:clbdoanhnhansg/screens/account/login.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../business_opportunity_management/manage.dart';
import '../../change_password/change_password_screen.dart';
import '../../edit_information/edit_information.dart';
import '../../member_infor/membership_statistics.dart';

class ListProfile extends StatefulWidget {
  const ListProfile({super.key});

  @override
  State<ListProfile> createState() => _ListProfileState();
}

class _ListProfileState extends State<ListProfile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final user = userProvider.author;
      return Stack(
        children: [
          Column(
            children: [
              // Card chứa menu
              Container(
                // padding: const EdgeInsets.all(16), // Khoảng cách bên trong
                decoration: BoxDecoration(
                  color: Colors.white, // Màu nền
                  borderRadius: BorderRadius.circular(8), // Bo góc
                  border: Border.all(
                    color: const Color(0xFFE6E6E6), // Màu viền
                    width: 1, // Độ dày viền
                  ),
                ),
                margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    _buildMenuItem(
                      icon: "assets/icons/tag-user.svg",
                      title: "Chỉnh sửa thông tin",
                      onTap: () {
                        // Xử lý khi nhấn chuyển sang màn hình chỉnh sửa thông tin
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfile(user: user)));
                      },
                    ),
                    const SizedBox(height: 4),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: "assets/icons/status-up.svg",
                      title: "Quản lý cơ hội kinh doanh",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ManageBO()));
                      },
                    ),
                    const SizedBox(height: 4),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: "assets/icons/lock.svg",
                      title: "Đổi mật khẩu",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen()));
                      },
                    ),
                    const SizedBox(height: 4),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: "assets/icons/document.svg",
                      title: "Thống kê thành viên CLB",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MemberStatistics()));
                      },
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    authProvider.logout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.borderLightGrey, // Màu nền

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Xác nhận xóa tài khoản',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Bạn có chắc chắn muốn xóa tài khoản của mình?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hành động này không thể hoàn tác và tất cả dữ liệu của bạn sẽ bị mất.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          actionsPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          actions: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      side:
                                          const BorderSide(color: Colors.grey),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Hủy',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Đóng dialog trước
                                      final parentContext = context;
                                      // Navigator.of(context).pop();

                                      final userProvider =
                                          Provider.of<UserProvider>(
                                              parentContext,
                                              listen: false);
                                      final body = {'status': 'delete'};

                                      await userProvider.deleteAccount(
                                        parentContext,
                                        body: body,
                                        avatarFiles: null,
                                        coverFiles: null,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Xóa tài khoản',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.borderLightGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Xóa tài khoản',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 4),
            ],
          )
        ],
      );
    });
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12, // Padding theo thiết kế
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Đặt kiểu SpaceBetween
          crossAxisAlignment:
              CrossAxisAlignment.center, // Căn giữa theo trục ngang
          children: [
            Row(
              children: [
                // Icon
                SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 12), // Khoảng cách giữa icon và tiêu đề
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),

            // Arrow icon (nằm bên phải)
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFAAAAAA),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFEEEEEE),
    );
  }
}
