import 'package:clbdoanhnhansg/providers/business_provider.dart';
import 'package:clbdoanhnhansg/screens/profile/widget/header_profile.dart';
import 'package:clbdoanhnhansg/screens/profile/widget/list_profiles.dart';
import 'package:clbdoanhnhansg/screens/profile/widget/member_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

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
    return Scaffold(
      backgroundColor: const Color(0x00f4f5f6),
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
        return const Column(
          children: [
            HeaderProfile(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Member(),
                          ListProfile(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

