import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/Color/app_color.dart';
import '../../utils/router/router.name.dart';
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
  bool _showValidationErrors = false;
  bool _fieldsNotEmpty = false;

  // Thêm biến để quản lý lỗi validation từ client
  Map<String, String?> validationErrors = {
    'email': null,
    'name': null,
    'password': null,
    'confirmPassword': null,
  };

  @override
  void initState() {
    super.initState();
    // Thêm listener để kiểm tra các trường đã nhập
    identityController.addListener(_checkFieldsNotEmpty);
    nameController.addListener(_checkFieldsNotEmpty);
    passwordController.addListener(_checkFieldsNotEmpty);
    confirmPasswordController.addListener(_checkFieldsNotEmpty);
  }

  @override
  void dispose() {
    // Hủy listener khi widget bị hủy
    identityController.removeListener(_checkFieldsNotEmpty);
    nameController.removeListener(_checkFieldsNotEmpty);
    passwordController.removeListener(_checkFieldsNotEmpty);
    confirmPasswordController.removeListener(_checkFieldsNotEmpty);
    
    // Giải phóng bộ nhớ
    identityController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    // Xóa thông báo lỗi khi màn hình được hiển thị
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearState();

    super.dispose();
  }

  // Chỉ kiểm tra xem các trường đã có giá trị chưa (không validate giá trị)
  void _checkFieldsNotEmpty() {
    setState(() {
      _fieldsNotEmpty = 
          identityController.text.trim().isNotEmpty &&
          nameController.text.trim().isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;
    });
  }

  // Kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$'
    );
    return emailRegExp.hasMatch(email);
  }

  // Kiểm tra mật khẩu mạnh
  bool _isStrongPassword(String password) {
    // Ít nhất 8 ký tự
    if (password.length < 8) return false;

    // Chứa ít nhất một chữ hoa
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    // Chứa ít nhất một chữ thường
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    // Chứa ít nhất một số
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    // Chứa ít nhất một ký tự đặc biệt
    final hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUppercase && hasLowercase && hasNumber && hasSpecialCharacters;
  }

  // Kiểm tra tính hợp lệ của form
  void _validateForm() {
    final identity = identityController.text.trim();
    final name = nameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Reset lỗi trước khi validate lại
    validationErrors = {
      'email': null,
      'name': null,
      'password': null,
      'confirmPassword': null,
    };

    // Validate email
    if (identity.isEmpty) {
      validationErrors['email'] = "Tên đăng nhập không được để trống";
    } else if (!_isValidEmail(identity)) {
      validationErrors['email'] = "Tên đăng nhập phải là email hợp lệ";
    }

    // Validate name
    if (name.isEmpty) {
      validationErrors['name'] = "Tên hiển thị là bắt buộc";
    }

    // Validate password
    if (password.isEmpty) {
      validationErrors['password'] = "Mật khẩu không được để trống";
    } else if (password.length < 8) {
      validationErrors['password'] = "Mật khẩu phải có ít nhất 8 ký tự";
    } else if (!_isStrongPassword(password)) {
      validationErrors['password'] = "Mật khẩu phải bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.";
    }

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      validationErrors['confirmPassword'] = "Xác nhận mật khẩu không được để trống";
    } else if (password != confirmPassword) {
      validationErrors['confirmPassword'] = "Mật khẩu và xác nhận mật khẩu không khớp";
    }

    setState(() {
      // Form hợp lệ khi tất cả các trường được điền và không có lỗi
      _isFormValid = identity.isNotEmpty &&
          name.isNotEmpty &&
          password.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          !validationErrors.values.any((error) => error != null);
    });
  }

  void _register() async {
    // Validate form trước khi submit
    _validateForm();
    
    setState(() {
      _showValidationErrors = true;
    });

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

  // Lấy thông báo lỗi cho từng trường
  String? getFieldError(String fieldName) {
    // Chỉ hiển thị lỗi khi đã nhấn nút đăng ký
    if (!_showValidationErrors) return null;
    
    // Đầu tiên kiểm tra lỗi từ client validation
    if (validationErrors[fieldName] != null) {
      return validationErrors[fieldName];
    }

    // Nếu không có lỗi client thì kiểm tra lỗi từ API
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.errorMessage == null) return null;

    // Kiểm tra lỗi API cho từng trường cụ thể
    if (fieldName == 'email') {
      if (authProvider.errorMessage == "Tên đăng nhập không được để trống" ||
          authProvider.errorMessage == "Tên đăng nhập phải là email hợp lệ" ||
          authProvider.errorMessage == "Email đã tồn tại") {
        return authProvider.errorMessage;
      }
    } else if (fieldName == 'name') {
      if (authProvider.errorMessage == "Có lỗi xảy ra") {
        return "Tên hiển thị là bắt buộc";
      }
    } else if (fieldName == 'password') {
      if (authProvider.errorMessage == "Mật khẩu phải bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt." ||
          authProvider.errorMessage == "Mật khẩu phải có ít nhất 8 ký tự") {
        return authProvider.errorMessage;
      }
    } else if (fieldName == 'confirmPassword') {
      if (authProvider.errorMessage == "Mật khẩu và xác nhận mật khẩu không khớp") {
        return authProvider.errorMessage;
      }
    }

    return null;
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
                              errorText: getFieldError('email'),
                            ),
                            const SizedBox(height: 16),
                            InputText(
                              controller: nameController,
                              title: "Họ và tên",
                              hintText: "Nhập họ và tên",
                              name: 'displayName',
                              errorText: getFieldError('name'),
                            ),
                            const SizedBox(height: 16),
                            Inputpassword(
                              controller: passwordController,
                              name: 'password',
                              title: 'Mật khẩu',
                              hintText: "Nhập mật khẩu",
                              errorText: getFieldError('password'),
                            ),
                            const SizedBox(height: 16),
                            Inputpassword(
                              controller: confirmPasswordController,
                              name: 'password',
                              title: 'Xác nhận mật khẩu',
                              hintText: 'Nhập lại mật khẩu',
                              errorText: getFieldError('confirmPassword'),
                            ),
                            const SizedBox(height: 24),
                            // Nút đăng ký với màu sắc phụ thuộc vào trạng thái form
                            InkWell(
                              onTap: (_fieldsNotEmpty && !authProvider.isLoading) 
                                ? _register 
                                : null,
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _fieldsNotEmpty && !authProvider.isLoading
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
                                      color: _fieldsNotEmpty && !authProvider.isLoading
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
                                  ..onTap = () => context.go(AppRoutes.login),
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