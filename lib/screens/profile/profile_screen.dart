import 'package:clbdoanhnhansg/providers/business_provider.dart';
import 'package:clbdoanhnhansg/screens/profile/widget/header_profile.dart';
import 'package:clbdoanhnhansg/screens/profile/widget/list_profiles.dart';
import 'package:clbdoanhnhansg/screens/profile/widget/member_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/Color/app_color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<UserProvider>(context, listen: false).fetchUser(context);
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false)
          .getListBusiness(context);
      // Provider.of<MemberShipProvider>(context, listen: false)
      //     .getListMemberShip(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kiểm tra và tải lại dữ liệu khi màn hình được rebuild (ví dụ: quay lại từ EditProfile)
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.author == null) {
      userProvider.fetchUser(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColor.backgroundColorApp,
      body: Consumer<UserProvider>(builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }
        if (userProvider.author == null) {
          return const Center(
              child: Text('Không thể tải thông tin người dùng'));
        }

        // Tính toán padding dựa trên kích thước màn hình
        final verticalPadding = height * 0.02;

        return SafeArea(
          child: Column(
            children: [
              // Header luôn chiếm 20% chiều cao màn hình
              SizedBox(
                height: height * 0.2,
                child: const HeaderProfile(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.02),
                        // Giới hạn chiều rộng tối đa cho nội dung
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: width > 600 ? 600 : width,
                            ),
                            child: const Column(
                              children: [
                                Member(),
                                SizedBox(height: 16),
                                ListProfile(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
