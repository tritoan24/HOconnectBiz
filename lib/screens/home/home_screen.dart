import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:clbdoanhnhansg/screens/home/widget/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../utils/router/router.name.dart';
import '../manage/manage.dart';
import '../profile/profile_screen.dart';
import '../shopping/shopping.dart';

class TrangChuView extends StatefulWidget {
  // late int selectedIndex;
  const TrangChuView({
    super.key,
  });

  @override
  State<TrangChuView> createState() => _TrangChuViewState();
}

class _TrangChuViewState extends State<TrangChuView> {
  int selectedIndex = 0;
  final List<Widget> _pages = [
    const Home(),
    const QuanLyView(isLeading: false),
    const Center(child: Text('Assessment')),
    const Shopping(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async {
          return false; // Prevent the back button from closing the app
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF4F5F6),
          body: _pages[selectedIndex],
          bottomNavigationBar: ConvexAppBar(
            curveSize: 90,
            top: -30,
            height: 70,
            backgroundColor: Colors.white,
            color: Colors.grey,
            style: TabStyle.fixedCircle,
            activeColor: Colors.blue,
            items: [
              TabItem(
                icon: SvgPicture.asset(
                  "assets/icons/home_noselect.svg",
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/home_select.svg",
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
                title: 'Trang chủ',
              ),
              TabItem(
                icon: SvgPicture.asset(
                  "assets/icons/shopNoSelect.svg",
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/shop.svg",
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
                title: 'Quản lý',
              ),
              TabItem(
                  icon: SvgPicture.asset(
                    "assets/icons/edit.svg",
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
                  title: 'Assessment'),
              TabItem(
                icon: SvgPicture.asset(
                  "assets/icons/vector_noselect.svg",
                  fit: BoxFit.cover,
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/vector.svg",
                  fit: BoxFit.cover,
                ),
                title: 'Dạo chợ',
              ),
              TabItem(
                icon: SvgPicture.asset(
                  "assets/icons/user_noselect.svg",
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/user_select.svg",
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
                title: 'Hồ sơ',
              ),
            ],
            initialActiveIndex: selectedIndex,
            onTap: (int i) async {
              if (i == 2) {
                // Navigate to another screen
                await context.push(AppRoutes.dangTin).then((_) {
                  // Always reset to the first tab when coming back
                  setState(() {
                    selectedIndex = 0;
                  });
                });
              } else {
                setState(() {
                  selectedIndex = i;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}

