import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/router/router.name.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/inputpassword.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Khởi tạo các controller riêng cho từng trường
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _showValidationErrors = false;
  Map<String, String?> validationErrors = {
    'currentPassword': null,
    'newPassword': null,
    'confirmPassword': null,
  };

  @override
  void initState() {
    super.initState();

    // Thêm listener để ẩn lỗi khi người dùng bắt đầu nhập lại
    currentPasswordController.addListener(_resetErrors);
    newPasswordController.addListener(_resetErrors);
    confirmPasswordController.addListener(_resetErrors);
  }

  @override
  void dispose() {
    // Xóa listeners
    currentPasswordController.removeListener(_resetErrors);
    newPasswordController.removeListener(_resetErrors);
    confirmPasswordController.removeListener(_resetErrors);

    // Giải phóng controllers
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    // Xóa thông báo lỗi
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearState();

    super.dispose();
  }

  // Reset lỗi khi người dùng bắt đầu nhập lại
  void _resetErrors() {
    if (_showValidationErrors) {
      setState(() {
        _showValidationErrors = false;
      });
    }
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
    final hasSpecialCharacters =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUppercase && hasLowercase && hasNumber && hasSpecialCharacters;
  }

  // Validate form
  bool _validateForm() {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() {
      _showValidationErrors = true;

      // Reset lỗi
      validationErrors = {
        'currentPassword': null,
        'newPassword': null,
        'confirmPassword': null,
      };

      // Validate mật khẩu hiện tại
      if (currentPassword.isEmpty) {
        validationErrors['currentPassword'] =
            "Mật khẩu hiện tại không được để trống";
      }

      // Validate mật khẩu mới
      if (newPassword.isEmpty) {
        validationErrors['newPassword'] = "Mật khẩu mới không được để trống";
      } else if (newPassword.length < 8) {
        validationErrors['newPassword'] = "Mật khẩu phải có ít nhất 8 ký tự";
      } else if (!_isStrongPassword(newPassword)) {
        validationErrors['newPassword'] =
            "Mật khẩu phải bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.";
      }

      // Validate xác nhận mật khẩu
      if (confirmPassword.isEmpty) {
        validationErrors['confirmPassword'] =
            "Xác nhận mật khẩu không được để trống";
      } else if (newPassword != confirmPassword) {
        validationErrors['confirmPassword'] =
            "Mật khẩu và xác nhận mật khẩu không khớp";
      }
    });

    // Form hợp lệ khi không có lỗi
    return !validationErrors.values.any((error) => error != null);
  }

  // Lấy thông báo lỗi cho từng trường
  String? getFieldError(String fieldName) {
    // Chỉ hiển thị lỗi khi đã nhấn nút lưu
    if (!_showValidationErrors) return null;

    // Lấy lỗi từ client validation
    if (validationErrors[fieldName] != null) {
      return validationErrors[fieldName];
    }

    // Lấy lỗi từ API nếu không có lỗi client
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.errorMessage == null) return null;

    // Kiểm tra lỗi API cho từng trường
    if (fieldName == 'currentPassword') {
      if (authProvider.errorMessage == "Mật khẩu hiện tại không chính xác.") {
        return authProvider.errorMessage;
      }
    } else if (fieldName == 'newPassword') {
      if (authProvider.errorMessage == "Mật khẩu mới không hợp lệ") {
        return authProvider.errorMessage;
      }
    } else if (fieldName == 'confirmPassword') {
      if (authProvider.errorMessage == "Mật khẩu xác nhận không khớp") {
        return authProvider.errorMessage;
      }
    }

    return null;
  }

  void _handleSubmit(BuildContext context) async {
    // Validate form trước khi submit
    if (_validateForm()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Gọi phương thức changepassword với dữ liệu từ controller
      await authProvider.changePassword(
        context,
        currentPasswordController.text,
        newPasswordController.text,
        confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColorApp,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Đổi mật khẩu'),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Inputpassword(
                      controller: currentPasswordController,
                      name: 'current_password',
                      title: 'Mật khẩu hiện tại',
                      hintText: "Nhập mật khẩu hiện tại",
                      errorText: getFieldError('currentPassword'),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.go(AppRoutes.quenMatKhau);
                        },
                        child: const Text(
                          'Quên mật khẩu',
                          style:
                              TextStyle(color: Color(0xFF0066FF), fontSize: 14),
                        ),
                      ),
                    ),
                    Inputpassword(
                      controller: newPasswordController,
                      name: 'new_password',
                      title: 'Mật khẩu mới',
                      hintText: "Nhập mật khẩu mới",
                      errorText: getFieldError('newPassword'),
                    ),
                    const SizedBox(height: 16),
                    Inputpassword(
                      controller: confirmPasswordController,
                      name: 'confirm_password',
                      title: 'Nhập lại mật khẩu mới',
                      hintText: "Nhập lại mật khẩu mới",
                      errorText: getFieldError('confirmPassword'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ButtonWidget(
                label: authProvider.isLoading ? "Đang lưu..." : "Lưu thông tin",
                onPressed: authProvider.isLoading
                    ? null
                    : () => _handleSubmit(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
