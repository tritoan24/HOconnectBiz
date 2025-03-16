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

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi trong các trường nhập liệu
    identityController.addListener(_validateForm);
    nameController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi widget bị hủy
    identityController.removeListener(_validateForm);
    nameController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    confirmPasswordController.removeListener(_validateForm);

    // Giải phóng bộ nhớ
    identityController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // Kiểm tra tính hợp lệ của form
  void _validateForm() {
    final identity = identityController.text.trim();
    final name = nameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() {
      // Chỉ kiểm tra xem tất cả các trường đã được điền đủ chưa
      _isFormValid = identity.isNotEmpty &&
          name.isNotEmpty &&
          password.isNotEmpty &&
          confirmPassword.isNotEmpty;
    });
  }

  void _register() async {
    if (!_isFormValid) return;

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
    final size = MediaQuery.of(context).size;

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
        body: SafeArea(
          child: Stack(
            children: [
              // Form container
              Container(
                height: size.height,
                width: size.width,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Form content area
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              "Đăng ký",
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tạo tài khoản mới",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textGrey),
                            ),
                            const SizedBox(height: 24),

                            // Form fields
                            InputText(
                              controller: identityController,
                              title: "Email",
                              hintText: "Nhập email",
                              name: 'taiKhoan',
                              errorText: (authProvider.errorMessage ==
                                          "Tên đăng nhập không được để trống" ||
                                      authProvider.errorMessage ==
                                          "Tên đăng nhập phải là email hợp lệ")
                                  ? authProvider.errorMessage
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            InputText(
                              controller: nameController,
                              title: "Họ và tên",
                              hintText: "Nhập họ và tên",
                              name: 'displayName',
                              errorText:
                                  authProvider.errorMessage == "Có lỗi xảy ra"
                                      ? "Tên hiển thị là bắt buộc"
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            Inputpassword(
                              controller: passwordController,
                              name: 'password',
                              title: 'Mật khẩu',
                              hintText: "Nhập mật khẩu",
                              errorText: (authProvider.errorMessage ==
                                          "Mật khẩu và xác nhận mật khẩu không khớp" ||
                                      authProvider.errorMessage ==
                                          "Mật khẩu phải có ít nhất 8 ký tự")
                                  ? authProvider.errorMessage
                                  : null,
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 24),
                            // Nút đăng ký với màu sắc phụ thuộc vào trạng thái form
                            InkWell(
                              onTap: (_isFormValid && !authProvider.isLoading)
                                  ? _register
                                  : null,
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _isFormValid
                                      ? const Color(0xff006AF5)
                                      : const Color(0xffE9EBED),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    authProvider.isLoading
                                        ? "Đang đăng ký..."
                                        : "Đăng ký ngay",
                                    style: TextStyle(
                                      color: _isFormValid
                                          ? Colors.white
                                          : const Color(0xff8F9499),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer area - always at bottom
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: "Đã có tài khoản "),
                              TextSpan(
                                text: "Đăng nhập",
                                style:
                                    const TextStyle(color: Color(0xff006AF5)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => context.pop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Success message overlay
              if (authProvider.successMessage != null)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
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
}
