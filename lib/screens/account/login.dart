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
      //
      await bannerProvider.getListBanner(context);
      //
      //   final rankProvider = Provider.of<RankProvider>(context, listen: false);
      //
      //   await rankProvider.fetchRanksRevenue(context);
      //   await rankProvider.fetchRankBusiness(context);
    });
    // final postProvider = Provider.of<PostProvider>(context, listen: false);
    // postProvider.fetchPostsFeatured(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Nhận dữ liệu từ GoRouter
    final extra = GoRouterState.of(context).extra as Map<String, String>?;

    if (extra != null) {
      identityController.text = extra["identity"] ?? "";
      passwordController.text = extra["password"] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  // Sử dụng MainAxisSize.min để nội dung tự co giãn
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Bạn có thể sử dụng các SizedBox để tạo khoảng cách thay cho Spacer
                  children: [
                    const SizedBox(height: 70),
                    Center(
                      // child: Image.network(
                      //   UrlImage.logo,
                      //   width: 144,
                      //   height: 80,
                      //   fit: BoxFit.contain,
                      //   errorBuilder: (context, error, stackTrace) {
                      //     return Image.network(
                      //       UrlImage.errorImage,
                      //       width: 144,
                      //       height: 80,
                      //       fit: BoxFit.contain,
                      //     );
                      //   },
                      // ),
                      child: Image.asset(
                        "assets/images/logo-clb-dnsg-up-website-385x215 1.png",
                        width: 144,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 43),
                    const Text(
                      "Đăng nhập ngay",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
                    ),
                    const Text(
                      "Nhập tài khoản và mật khẩu để đăng nhập",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 15),
                    Inputpassword(
                      controller: passwordController,
                      name: 'password',
                      title: 'Mật khẩu',
                      hintText: "Nhập mật khẩu",
                      errorText: authProvider.errorMessage == "Sai mật khẩu"
                          ? authProvider.errorMessage
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () => {
                          context.push(AppRoutes.quenMatKhau),
                          Provider.of<AuthProvider>(context, listen: false)
                              .clearState()
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            "Quên mật khẩu?",
                            style: TextStyle(
                              color: Color(0xff006AF5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    ButtonWidget(
                      label: authProvider.isLoading
                          ? "Đang đăng nhập..."
                          : "Đăng nhập",
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
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 1,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xffEDF1F3),
                              ),
                            ),
                          ),
                          const Text("Hoặc đăng nhập bằng"),
                          SizedBox(
                            height: 1,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xffEDF1F3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            authProvider.signInWithGoogle(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xffE9EBED),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/i_google.svg",
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("Google"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                print("clicked Đăng nhập bằng facebook");
                                authProvider.signInWithFacebook(context);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xffE9EBED),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/i_facebook.svg",
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("Facebook"),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    // Thay thế Spacer bằng một SizedBox để tạo khoảng cách ở dưới
                    const SizedBox(height: 24),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: "Chưa có tài khoản? "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: InkWell(
                                onTap: () {
                                  context.push(AppRoutes.dangKyTaiKhoan);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    "Đăng ký ngay",
                                    style: TextStyle(
                                      color: Color(0xff006AF5),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
