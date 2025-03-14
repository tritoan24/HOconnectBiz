import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/Color/app_color.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/input_text.dart';
import '../../widgets/inputpassword.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignUpState();
}

class _SignUpState extends State<Signup> {
  final TextEditingController identityController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _register() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.register(
      context,
      identityController.text,
      passwordController.text,
      confirmPasswordController.text,
      nameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          elevation: 0,
        ),
        backgroundColor: AppColor.backgroundColorApp,
        body: Stack(
          // 🔹 Dùng Stack để có thể đặt Positioned
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    const Text("Đăng ký",
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    const Text("Tạo tài khoản mới",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 32),
                    InputText(
                      controller: identityController,
                      title: "Email/ Số điện thoại",
                      hintText: "Nhập email hoặc số điện thoại",
                      name: 'taiKhoan',
                      errorText: (authProvider.errorMessage ==
                                  "Email hoặc số điện thoại đã tồn tại" ||
                              authProvider.errorMessage ==
                                  "Tên đăng nhập phải là email hoặc số điện thoại hợp lệ")
                          ? authProvider.errorMessage
                          : null,
                    ),
                    const SizedBox(height: 24),
                    InputText(
                      controller: nameController,
                      title: "Họ và tên",
                      hintText: "Nhập Họ và tên",
                      name: 'displayName',
                      errorText: authProvider.errorMessage == "Có lỗi xảy ra"
                          ? "Tên hiển thị là bắt buộc"
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Inputpassword(
                      controller: passwordController,
                      name: 'password',
                      title: 'Mật khẩu',
                      hintText: "Nhập mật khẩu",
                      errorText: (authProvider.errorMessage ==
                                  "Mật khẩu và xác nhận mật khẩu không khớp" ||
                              authProvider.errorMessage ==
                                  "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.")
                          ? authProvider.errorMessage
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Inputpassword(
                      controller: confirmPasswordController,
                      name: 'password',
                      title: 'Xác nhận mật khẩu',
                      hintText: 'Nhập lại mật khẩu',
                      errorText: authProvider.errorMessage ==
                              "Mật khẩu và xác nhận mật khẩu không khớp"
                          ? authProvider.errorMessage
                          : null,
                    ),
                    const SizedBox(height: 32),
                    ButtonWidget(
                      label: authProvider.isLoading
                          ? "Đang đăng ký..."
                          : "Đăng ký ngay",
                      onPressed: authProvider.isLoading ? null : _register,
                    ),
                    const SizedBox(height: 80),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: "Đã có tài khoản? "),
                            TextSpan(
                              text: "Đăng nhập",
                              style: const TextStyle(color: Color(0xff006AF5)),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.pop(),
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
            // 🔹 **Hiển thị thông báo ở góc trên nếu đăng ký thành công**
            if (authProvider.successMessage != null)
              Positioned(
                top: 20, // Khoảng cách từ trên xuống
                left: 20,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      authProvider.successMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
