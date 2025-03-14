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
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final user = userProvider.author;
      return Stack(
        children: [
          Container(
            height: 182,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/backgroudprofile.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              //margin trái và phải của container
              margin: const EdgeInsets.only(left: 12, right: 12, top: 70),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(20, 20, 21, 0.14),
                    blurRadius: 6, // Độ mờ của bóng
                    offset: Offset(0, 2), // Vị trí bóng
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
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          UrlImage.errorImage,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Không có tên',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        (user?.description == "")
                            ? 'Chưa cập nhật'
                            : user!.description,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

