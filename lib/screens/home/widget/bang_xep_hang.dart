import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../models/rank_model.dart';
import '../../business_information/business_information.dart';

class BangXepHang extends StatelessWidget {
  final List<Rank> ranks;
  final String title;

  const BangXepHang({
    super.key,
    required this.ranks,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final top3 = ranks.where((rank) => rank.rank <= 3).toList();
    final others = ranks.where((rank) => rank.rank > 3).toList();
    print('top3: $top3');
    print('others: $others');

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 274,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xff10144D), Color(0xff3976B9)],
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset("assets/images/group32.png"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Căn giữa các phần tử trong Row
                children: [
                  // Top 2 (bên trái)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Căn giữa nội dung trong Column
                      children: [
                        if (top3.length > 1)
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              SvgPicture.asset("assets/icons/i_vuongniem.svg"),
                              const SizedBox(height: 10),
                              buildTopItem(context, top3[1]),
                            ],
                          )
                        else
                          const SizedBox(
                              width: 65), // Giữ khoảng trống nếu không có top 2
                      ],
                    ),
                  ),

                  // Top 1 (giữa, nhích cao hơn)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Căn giữa nội dung trong Column
                      children: [
                        if (top3.isNotEmpty)
                          Column(
                            children: [
                              SvgPicture.asset("assets/icons/i_vuongniem.svg"),
                              const SizedBox(height: 10),
                              buildTopItem(context, top3[0]),
                              const SizedBox(height: 20),
                            ],
                          )
                        else
                          const SizedBox(
                              width: 65), // Giữ khoảng trống nếu không có top 1
                      ],
                    ),
                  ),

                  // Top 3 (bên phải)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Căn giữa nội dung trong Column
                      children: [
                        if (top3.length > 2)
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              SvgPicture.asset("assets/icons/i_vuongniem.svg"),
                              const SizedBox(height: 10),
                              buildTopItem(context, top3[2]),
                            ],
                          )
                        else
                          const SizedBox(
                              width: 65), // Giữ khoảng trống nếu không có top 3
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Xếp hạng",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Tên doanh nghiệp",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...others.map((rank) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: GestureDetector(
                            onTap: () {
                              context.push(AppRoutes.thongTinDoanhNghiep
                                  .replaceFirst(":isLeading", "true"));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Thứ hạng ${rank.rank}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  rank.companyName.isNotEmpty
                                      ? rank.companyName
                                      : rank.displayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (others.indexOf(rank) < 4)
                          SizedBox(
                            height: 1,
                            width: MediaQuery.of(context).size.width,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xffEDF1F3),
                              ),
                            ),
                          ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTopItem(BuildContext context, Rank rank) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (contex) =>
                    BusinessInformation(idUser: rank.id, isMe: false)));
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xffFDD949),
                width: 5.0,
              ),
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: rank.avatarImage.isNotEmpty
                  ? Image.network(
                      rank.avatarImage,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 65),
                    )
                  : const Icon(Icons.person, size: 65),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            rank.companyName.isNotEmpty ? rank.companyName : rank.displayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
