import 'package:clbdoanhnhansg/models/auth_model.dart';
import 'package:clbdoanhnhansg/screens/manage/widget/information/widget/company_imformation.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

import '../../../../providers/business_provider.dart';
import '../../../../providers/user_provider.dart';

class InformationTab extends StatefulWidget {
  final bool isMe;
  const InformationTab({super.key, required this.isMe});

  @override
  State<InformationTab> createState() => _InformationState();
}

class _InformationState extends State<InformationTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, BusinessProvider>(
      builder: (context, userProvider, businessProvider, child) {
        // Kiểm tra trạng thái loading của UserProvider
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        // if (userProvider.authorByID == null) {
        //   return const Center(
        //       child: Text('Không thể tải thông tin người dùng'));
        // }
        // // Kiểm tra nếu không có dữ liệu user
        // if (userProvider.author == null) {
        //   return const Center(
        //       child: Text('Không thể tải thông tin người dùng'));
        // }
        final Author user;
        widget.isMe == true
            ? user = userProvider.author!
            : user = userProvider.authorByID!;
        // Lọc danh sách business của user dựa trên ID
        final userBusinesses = businessProvider.business
            .where((business) => user.business.contains(business.id))
            .toList();
        print(
            '🔹 [InformationTab] User businesses: ${userBusinesses.map((e) => e.title).toList()}');

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CarInforCompany(
                          ulrIcon: 'assets/icons/ten_cong_ty.png',
                          label: 'Tên công ty',
                          value: user.companyName.isEmpty
                              ? 'Chưa cập nhật'
                              : user.companyName,
                        ),
                      ),
                      const Divider(
                        color: Color(0xffD6E9FF),
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CarInforCompany(
                          ulrIcon: 'assets/icons/chudn.png',
                          label: 'Chủ doanh nghiệp',
                          value: user.displayName ?? 'Chưa có thông tin',
                        ),
                      ),
                      const Divider(
                        color: Color(0xffD6E9FF),
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CarInforCompany(
                          ulrIcon: 'assets/icons/diachi.png',
                          label: "Địa chỉ",
                          value: user.address.isEmpty
                              ? 'Chưa cập nhật'
                              : user.address,
                        ),
                      ),
                      const Divider(
                        color: Color(0xffD6E9FF),
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CarInforCompany(
                            ulrIcon: 'assets/icons/phone.png',
                            label: "Số điện thoại",
                            value: user.phone.isEmpty
                                ? 'Chưa cập nhật'
                                : user.phone),
                      ),
                      const Divider(
                        color: Color(0xffD6E9FF),
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CarInforCompany(
                          nganhNghe: (userBusinesses.isNotEmpty)
                              ? userBusinesses.map((e) => e.title).toList()
                              : ["Chưa có ngành nghề"],
                          isNganhNghe: true,
                          ulrIcon: 'assets/icons/nganh_nghe.png',
                          label: "Ngành nghề",
                          value:
                              '', // Không cần đặt giá trị nếu đã có danh sách
                        ),
                      ),
                      const Divider(
                        color: Color(0xffD6E9FF),
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/i_mota.svg",
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              "Mô tả doanh nghiệp",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          user.companyDescription.isEmpty
                              ? ''
                              : user.companyDescription,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.left, // Căn trái chữ
                        ),
                      ),
                      const SizedBox(height: 30),
                      widget.isMe == true
                          ? GestureDetector(
                              onTap: () {
                                context.push(AppRoutes.chinhSuaThongTin);
                              },
                              child: Container(
                                height: 50,
                                width: 360,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColor.secondaryBlue,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Chỉnh sửa thông tin",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
}

