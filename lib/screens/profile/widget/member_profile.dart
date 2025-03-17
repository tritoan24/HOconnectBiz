import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/user_provider.dart';
import '../member_level.dart';

class Member extends StatefulWidget {
  final bool isProfile;
  const Member({super.key, this.isProfile = true});

  @override
  State<StatefulWidget> createState() => _MemberState();
}

class _MemberState extends State<Member> {
  // Hàm định dạng tiền VND
  String formatCurrency(double? amount) {
    if (amount == null) return '0 đ';
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final user = userProvider.author;
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: 155,
            margin: const EdgeInsets.only(left: 16, right: 16),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/backgroudmember.png"),
                fit: BoxFit.cover,
                //bo goc anh
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Changed to start
              crossAxisAlignment: CrossAxisAlignment.start, // Changed to start
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // Changed to start
                  children: [
                    //thẻ ảnh
                    Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/medal-star.svg",
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        )),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Changed to start
                      children: [
                        Text(
                          "Hội viên cấp ${user?.level}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Đã đạt doanh thu ${formatCurrency(user?.membershipPoints?.toDouble())}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    widget.isProfile
                        ? GestureDetector(
                            onTap: () {
                              // Xử lý khi nhấn chuyen sang man hinh hang hoi vien
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MemberLever()));
                            },
                            child: const Image(
                              image: AssetImage("assets/images/muitenphai.png"),
                              width: 20,
                              height: 20,
                            ),
                          )
                        : Container(),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Tính toán phần trăm hoàn thành
                      double? currentAmount = user?.membershipPoints
                          ?.toDouble(); // Số tiền hiện tại
                      double? targetAmount = user?.membershipPointsMax
                          ?.toDouble(); // Tổng số tiền cần đạt
                      double percent =
                          (currentAmount! / targetAmount!).clamp(0.0, 1.0);

                      return Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: constraints.maxWidth * percent,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(
                                    -0.5, -0.9), // Tương đương với góc 341 độ
                                end: Alignment(0.9, 0.5),
                                colors: [
                                  Color(0xFF0033FF), // #03F
                                  Color(0xFF66D1FF), // #66D1FF
                                ],
                                stops: [-0.3105, 0.9956], // -31.05% và 99.56%
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12), // Changed from width to height
                Text(
                  "Cần thêm ${formatCurrency(user?.membershipPointsNeed?.toDouble())} để trở thành Hội viên cấp 2",
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          )
        ],
      );
    });
  }
}
