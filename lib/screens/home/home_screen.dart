import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:clbdoanhnhansg/screens/home/widget/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/router/router.name.dart';
import '../manage/manage.dart';
import '../profile/profile_screen.dart';
import '../shopping/shopping.dart';

class TrangChuView extends StatefulWidget {
  const TrangChuView({
    super.key,
  });

  @override
  State<TrangChuView> createState() => _TrangChuViewState();
}

class _TrangChuViewState extends State<TrangChuView> {
  int selectedIndex = 0;

  void handleTabChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final notificationProvider = Provider.of<NotificationProvider>(context);
    notificationProvider.setContext(context);

    // Calculate button spacing based on screen width
    final centerButtonWidth = 105.0;
    final availableWidth = screenWidth - centerButtonWidth;
    final navItemWidth = availableWidth / 4; // 4 navigation items

    final List<Widget> _pages = [
      Home(onNavigateToTab: handleTabChange),
      const QuanLyView(isLeading: false),
      const Center(child: Text('Assessment')),
      const Shopping(),
      const ProfileScreen(),
    ];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF4F5F6),
          body: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _pages[selectedIndex],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left side navigation items with flexible width
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(
                              0,
                              'Trang chủ',
                              'assets/icons/home_noselect.svg',
                              'assets/icons/home_select.svg',
                              navItemWidth,
                            ),
                            _buildNavItem(
                              1,
                              'Quản lý',
                              'assets/icons/shopNoSelect.svg',
                              'assets/icons/shop.svg',
                              navItemWidth,
                            ),
                          ],
                        ),
                      ),

                      // Center space for the floating action button
                      SizedBox(width: centerButtonWidth),

                      // Right side navigation items with flexible width
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(
                              3,
                              'Dạo chợ',
                              'assets/icons/vector_noselect.svg',
                              'assets/icons/vector.svg',
                              navItemWidth,
                            ),
                            _buildNavItem(
                              4,
                              'Hồ sơ',
                              'assets/icons/user_noselect.svg',
                              'assets/icons/user_select.svg',
                              navItemWidth,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 6,
                child: Center(
                  child: Container(
                    width: 105,
                    height: 125,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, -4),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          await context.push(AppRoutes.dangTin).then((_) {
                            setState(() {
                              selectedIndex = 0;
                            });
                          });
                        },
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color(0xFF006AF5),
                            border: Border.all(
                              color: const Color(0xFFA9C0FF),
                              width: 6,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/edit.svg',
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Đăng tin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String title,
    String inactiveIcon,
    String activeIcon,
    double maxWidth,
  ) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => handleTabChange(index),
      child: Container(
        // Constrain width to be responsive but not exceed maxWidth
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(horizontal: 4),
        height: 78,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 25,
                height: 0,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF006AF5),
                    width: 1.46471,
                  ),
                ),
              )
            else
              const SizedBox(height: 6),
            SvgPicture.asset(
              isSelected ? activeIcon : inactiveIcon,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF006AF5)
                    : const Color(0xFF9DB2CE),
                fontSize: 12,
                fontFamily: 'Roboto',
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
