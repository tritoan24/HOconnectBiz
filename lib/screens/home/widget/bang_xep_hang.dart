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
    final screenWidth = MediaQuery.of(context).size.width;
    final top3 = ranks.where((rank) => rank.rank <= 3).toList();
    final others = ranks.where((rank) => rank.rank > 3).toList();

    // Calculate responsive sizes
    final podiumHeight =
        screenWidth * 0.7; // Adjust podium height based on screen width
    final avatarSize = screenWidth * 0.15; // Make avatar size responsive
    final crownSize = screenWidth * 0.07; // Make crown size responsive
    final topPadding = screenWidth * 0.04; // Responsive padding

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.04, // Responsive font size
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: screenWidth * 0.04), // Responsive spacing
        Stack(
          alignment: Alignment.topCenter,
          children: [
            // Podium background
            Container(
              width: screenWidth,
              height: podiumHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Color(0xff10144D), Color(0xff3976B9)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Image.asset(
                        "assets/images/group32.png",
                        fit: BoxFit.contain,
                        width: constraints.maxWidth,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Top 3 users
            Padding(
              padding: EdgeInsets.only(
                  top: topPadding,
                  left: screenWidth * 0.04,
                  right: screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top 2 (left)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (top3.length > 1)
                          Column(
                            children: [
                              SizedBox(height: screenWidth * 0.05),
                              SvgPicture.asset(
                                "assets/icons/i_vuongniem.svg",
                                width: crownSize,
                                height: crownSize,
                              ),
                              SizedBox(height: screenWidth * 0.025),
                              buildTopItem(context, top3[1], avatarSize),
                            ],
                          )
                        else
                          SizedBox(width: avatarSize),
                      ],
                    ),
                  ),

                  // Top 1 (center, positioned higher)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (top3.isNotEmpty)
                          Column(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/i_vuongniem.svg",
                                width: crownSize *
                                    1.2, // Make top 1 crown slightly larger
                                height: crownSize * 1.2,
                              ),
                              SizedBox(height: screenWidth * 0.025),
                              buildTopItem(
                                  context,
                                  top3[0],
                                  avatarSize *
                                      1.2), // Make top 1 avatar slightly larger
                              SizedBox(height: screenWidth * 0.05),
                            ],
                          )
                        else
                          SizedBox(width: avatarSize),
                      ],
                    ),
                  ),

                  // Top 3 (right)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (top3.length > 2)
                          Column(
                            children: [
                              SizedBox(height: screenWidth * 0.05),
                              SvgPicture.asset(
                                "assets/icons/i_vuongniem.svg",
                                width: crownSize,
                                height: crownSize,
                              ),
                              SizedBox(height: screenWidth * 0.025),
                              buildTopItem(context, top3[2], avatarSize),
                            ],
                          )
                        else
                          SizedBox(width: avatarSize),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),

        // Bottom section (ranking list)
        Container(
          width: screenWidth,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Xếp hạng",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Tên doanh nghiệp",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.04),
                ...others.map((rank) => Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.02),
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
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    rank.companyName.isNotEmpty
                                        ? rank.companyName
                                        : rank.displayName,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.005),
                        if (others.indexOf(rank) < 4)
                          SizedBox(
                            height: 1,
                            width: screenWidth,
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

  Widget buildTopItem(BuildContext context, Rank rank, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderWidth = screenWidth * 0.012; // Responsive border width

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BusinessInformation(idUser: rank.id, isMe: false)));
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xffFDD949),
                width: borderWidth,
              ),
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: rank.avatarImage.isNotEmpty
                  ? Image.network(
                      rank.avatarImage,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, size: size),
                    )
                  : Icon(Icons.person, size: size),
            ),
          ),
          SizedBox(height: screenWidth * 0.025),
          SizedBox(
            width: screenWidth * 0.25, // Constrain text width
            child: Text(
              rank.companyName.isNotEmpty ? rank.companyName : rank.displayName,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
