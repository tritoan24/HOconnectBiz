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
                            builder: (context) => const MemberStatistics()));
                  },
                ),
                const SizedBox(height: 4),
                _buildDivider(),
                _buildMenuItem(
                  icon: "assets/icons/logout.svg",
                  title: "Đăng xuất",
                  onTap: () async {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    authProvider.logout(context);
                  },
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
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
