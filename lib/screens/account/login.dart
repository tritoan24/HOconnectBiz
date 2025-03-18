import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banner_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/rank_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/router/router.name.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/input_text.dart';
import '../../widgets/inputpassword.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController identityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bannerProvider =
          Provider.of<BannerProvider>(context, listen: false);
      await bannerProvider.getListBanner(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Nhận dữ liệu từ GoRouter
    final extra = GoRouterState.of(context).extra as Map<String, String>?;

    if (extra != null) {
      // Chỉ set giá trị khi controller trống
      if (identityController.text.isEmpty) {
        identityController.text = extra["identity"] ?? "";
      }
      if (passwordController.text.isEmpty) {
        passwordController.text = extra["password"] ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isPadding = screenSize.width > 600; // Tablet trở lên

    return Scaffold(
      backgroundColor: AppColor.backgroundColorApp,
      // Cho phép tự động điều chỉnh UI khi bàn phím hiện lên
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: FormBuilder(
          key: _formKey,
          child: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  // Phần nội dung chính có thể cuộn
                  SingleChildScrollView(
                    // Hỗ trợ tự động cuộn khi bàn phím xuất hiện
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            50, // Để lại không gian cho footer
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isPadding ? screenSize.width * 0.1 : 20.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenSize.height * 0.05),
                            Center(
                              child: Image.network(
                                UrlImage.logo,
                                width: isSmallScreen ? 120 : 144,
                                height: isSmallScreen ? 65 : 80,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/images/logo.png",
                                    width: isSmallScreen ? 120 : 144,
                                    height: isSmallScreen ? 65 : 80,
                                    fit: BoxFit.contain,
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.04),
                            Text(
                              "Đăng nhập ngay",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: isSmallScreen ? 24 : 30),
                            ),
                            Text(
                              "Nhập tài khoản và mật khẩu để đăng nhập",
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(height: screenSize.height * 0.025),
                            InputText(
                              controller: identityController,
                              title: "Tài khoản",
                              hintText: "Nhập email hoặc số điện thoại",
                              name: 'taiKhoan',
                              errorText: (authProvider.errorMessage ==
                                          "Người dùng không tồn tại" ||
                                      authProvider.errorMessage ==
                                          "Vui lòng nhập tên đăng nhập và mật khẩu")
                                  ? authProvider.errorMessage
                                  : null,
                            ),
                            SizedBox(height: screenSize.height * 0.015),
                            Inputpassword(
                              controller: passwordController,
                              name: 'password',
                              title: 'Mật khẩu',
                              hintText: "Nhập mật khẩu",
                              errorText:
                                  authProvider.errorMessage == "Sai mật khẩu"
                                      ? authProvider.errorMessage
                                      : null,
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () => {
                                  context.push(AppRoutes.quenMatKhau),
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .clearState()
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    "Quên mật khẩu?",
                                    style: TextStyle(
                                      color: AppColor.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.025),
                            ButtonWidget(
                              label: "Đăng nhập",
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () {
                                      authProvider.login(
                                        context,
                                        identityController.text,
                                        passwordController.text,
                                      );
                                    },
                            ),
                            SizedBox(height: screenSize.height * 0.025),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 1,
                                      color: AppColor.backgroundGrey,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "Hoặc đăng nhập bằng",
                                      style: TextStyle(
                                          fontSize: isSmallScreen ? 11 : 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 1,
                                      color: AppColor.backgroundGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.025),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  context,
                                  "assets/icons/i_google.svg",
                                  "Google",
                                  () => authProvider.signInWithGoogle(context),
                                  screenSize,
                                  isSmallScreen,
                                ),
                                SizedBox(width: screenSize.width * 0.04),
                                _buildSocialButton(
                                  context,
                                  "assets/icons/i_facebook.svg",
                                  "Facebook",
                                  () =>
                                      authProvider.signInWithFacebook(context),
                                  screenSize,
                                  isSmallScreen,
                                ),
                              ],
                            ),
                            // Thêm padding dưới cùng để đảm bảo không bị footer đè lên
                            SizedBox(height: 70),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Phần footer cố định ở dưới cùng
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: AppColor.backgroundColorApp,
                      padding: EdgeInsets.only(
                        bottom: 15,
                        top: 15,
                        left: isPadding ? screenSize.width * 0.1 : 20.0,
                        right: isPadding ? screenSize.width * 0.1 : 20.0,
                      ),
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Chưa có tài khoản? ",
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: InkWell(
                                  onTap: () {
                                    context.push(AppRoutes.dangKyTaiKhoan);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      "Đăng ký ngay",
                                      style: TextStyle(
                                          color: const Color(0xff006AF5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 11 : 12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String iconPath,
    String label,
    VoidCallback onTap,
    Size screenSize,
    bool isSmallScreen,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColor.borderGrey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 10 : 14.0,
            horizontal: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                fit: BoxFit.cover,
                width: isSmallScreen ? 14 : 18,
                height: isSmallScreen ? 14 : 18,
              ),
              SizedBox(width: screenSize.width * 0.02),
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
