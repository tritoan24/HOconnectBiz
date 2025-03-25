import 'package:clbdoanhnhansg/widgets/button_widget16.dart';
import 'package:clbdoanhnhansg/widgets/input_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../utils/Color/app_color.dart';
import '../../../utils/router/router.name.dart';
import '../../../widgets/text_styles.dart';

class InputAccountScreen extends StatefulWidget {
  final bool showAppBar;
  const InputAccountScreen({super.key, this.showAppBar = false});

  @override
  State<InputAccountScreen> createState() => _InputAccountScreenState();
}

class _InputAccountScreenState extends State<InputAccountScreen> {
  final TextEditingController accountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32, // Trừ đi padding
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: size.height *
                              0.05), // Tương đối theo chiều cao màn hình
                      Image.asset(
                        "assets/images/logo.png",
                        width: size.width * 0.4,
                        height: size.height * 0.1,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: size.height * 0.03),

                      // ✅ Căn trái tiêu đề
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Quên mật khẩu',
                          style: TextStyles.textStyleNormal30W700,
                        ),
                      ),

                      // ✅ Căn trái mô tả
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nhập email hoặc số điện thoại đã đăng ký',
                          style: TextStyles.textStyleNormal12W400Grey,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      InputText(
                        controller: accountController,
                        title: "Tài khoản",
                        hintText: "Nhập email hoặc số điện thoại",
                        name: 'taiKhoan',
                        errorText: auth.errorMessage,
                      ),

                      SizedBox(height: size.height * 0.01),

                      // ✅ Căn phải phần "Bạn đã nhớ mật khẩu" + "Đăng nhập"

                      !widget.showAppBar
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // ✅ Giữ row nhỏ để không bị kéo dãn
                                children: [
                                  Text(
                                    'Bạn đã nhớ mật khẩu?',
                                    style: TextStyles.textStyleNormal12W400Grey,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Xóa lỗi trước khi chuyển màn hình
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .clearState();
                                      context.go(AppRoutes.login);
                                    },
                                    child: const Text('Đăng nhập',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColor.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),

                      SizedBox(height: size.height * 0.05),
                      ButtonWidget16(
                        label: 'Tiếp theo',
                        onPressed: () {
                          print("Email${accountController.text}");

                          auth.sendEmailOtp(
                            context,
                            accountController.text,
                          );
                          // Không cần clearState ở đây vì đã xử lý trong sendEmailOtp
                        },
                      ),

                      // Spacer để đẩy nội dung lên khi màn hình lớn
                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: widget.showAppBar
          ? null
          : Container(
              height: 50,
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                          text: "Chưa có tài khoản?  ",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      TextSpan(
                        text: "Đăng ký ngay",
                        style: const TextStyle(
                          color: Color(0xff006AF5),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Xóa lỗi trước khi chuyển màn hình
                            Provider.of<AuthProvider>(context, listen: false)
                                .clearState();
                            context.push(AppRoutes.dangKyTaiKhoan);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
