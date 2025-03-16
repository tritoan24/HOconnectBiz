import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/router/router.name.dart';
import '../../../widgets/inputpassword.dart';
import '../../../widgets/text_styles.dart';

class InputNewPasswordScreen extends StatefulWidget {
  final String email;
  const InputNewPasswordScreen({super.key, required this.email});

  @override
  State<InputNewPasswordScreen> createState() => _InputNewPasswordState();
}

class _InputNewPasswordState extends State<InputNewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isButtonEnabled = false;

  void _validatePasswords() {
    setState(() {
      isButtonEnabled = passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          passwordController.text == confirmPasswordController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePasswords);
    confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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

            // Tiêu đề
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tạo mật khẩu mới",
                style: TextStyles.textStyleNormal30W700,
              ),
            ),

            const SizedBox(height: 8),

            // Mô tả ngắn
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tạo mật khẩu mới của bạn",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 35),
            // Ô nhập mật khẩu mới
            Inputpassword(
              controller: passwordController,
              title: "Mật khẩu mới",
              hintText: "Nhập mật khẩu mới",
              name: 'matKhauMoi',
            ),

            const SizedBox(height: 16),

            // Ô nhập xác nhận mật khẩu
            Inputpassword(
              controller: confirmPasswordController,
              title: "Xác nhận mật khẩu",
              hintText: "Nhập lại mật khẩu",
              name: 'xacNhanMatKhau',
            ),

            const SizedBox(height: 60),

            // Nút Hoàn thành (Bị vô hiệu hóa nếu chưa nhập đúng)
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                      auth.resetpassword(
                          context,
                          widget.email,
                          passwordController.text,
                          confirmPasswordController.text);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isButtonEnabled ? Colors.blue : Colors.grey.shade300,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Hoàn thành"),
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
