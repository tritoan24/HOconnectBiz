import 'package:clbdoanhnhansg/widgets/button_widget16.dart';
import 'package:clbdoanhnhansg/widgets/input_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../utils/router/router.name.dart';
import '../../../widgets/text_styles.dart';

class InputAccountScreen extends StatefulWidget {
  const InputAccountScreen({super.key});

  @override
  State<InputAccountScreen> createState() => _InputAccountScreenState();
}

class _InputAccountScreenState extends State<InputAccountScreen> {
  final TextEditingController accountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Image.network(
              UrlImage.logo,
              width: 144,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/logo.png",
                  width: 144,
                  height: 80,
                  fit: BoxFit.contain,
                );
              },
            ),
            const SizedBox(height: 30),

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

            const SizedBox(height: 16),

            InputText(
              controller: accountController,
              title: "Tài khoản",
              hintText: "Nhập email hoặc số điện thoại",
              name: 'taiKhoan',
              errorText: auth.errorMessage,
            ),

            const SizedBox(height: 10),

            // ✅ Căn phải phần "Tôi đã nhớ mật khẩu" + "Đăng nhập"
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // ✅ Giữ row nhỏ để không bị kéo dãn
                children: [
                  Text(
                    'Tôi đã nhớ mật khẩu',
                    style: TextStyles.textStyleNormal12W400Grey,
                  ),
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.login);
                      Provider.of<AuthProvider>(context, listen: false)
                          .clearState();
                    },
                    child: Text(
                      'Đăng nhập',
                      style: TextStyles.textStyleNormal12W500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 46),

            ButtonWidget16(
              label: 'Tiếp theo',
              onPressed: () {
                auth.sendEmailOtp(
                  context,
                  accountController.text,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
