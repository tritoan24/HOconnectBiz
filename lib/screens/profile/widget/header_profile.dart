import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';

class HeaderProfile extends StatefulWidget {
  const HeaderProfile({super.key});

  @override
  State<StatefulWidget> createState() => _HeaderProfileState();
}

class _HeaderProfileState extends State<HeaderProfile> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Tính toán các kích thước tương đối
    final headerHeight = height * 0.2;
    final avatarSize = width * 0.18;
    final containerPadding = width * 0.03;
    final containerMargin = width * 0.03;
    final borderRadius = width * 0.02;

    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final user = userProvider.author;
      return Stack(
        children: [
          // Background container
          Container(
            height: headerHeight,
            width: width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/backgroudprofile.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content container
          Positioned(
            left: containerMargin,
            right: containerMargin,
            bottom: -headerHeight * -0.10,
            child: Container(
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(20, 20, 21, 0.14),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      (user?.avatarImage.isEmpty ?? true)
                          ? "https://i.pinimg.com/736x/3c/ae/07/3cae079ca0b9e55ec6bfc1b358c9b1e2.jpg"
                          : user!.avatarImage,
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          UrlImage.errorImage,
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:
                          MainAxisSize.min, // Cho phép co dãn theo nội dung
                      children: [
                        Text(
                          user?.displayName ?? 'Không có tên',
                          style: TextStyle(
                            fontSize: width * 0.042,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                            height: height *
                                0.005), // Khoảng cách giữa tên và mô tả
                        Text(
                          (user?.description == "")
                              ? 'Chưa cập nhật'
                              : user!.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width * 0.032,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
