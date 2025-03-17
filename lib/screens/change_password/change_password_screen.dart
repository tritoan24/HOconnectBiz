import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
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

  void _handleSubmit(BuildContext context) async {
    if (_formKey.currentState!.saveAndValidate()) {
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
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                      errorText: authProvider.errorMessage ==
                              "Mật khẩu hiện tại không đúng"
                          ? authProvider.errorMessage
                          : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
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
                      errorText: authProvider.errorMessage ==
                              "Mật khẩu mới không hợp lệ"
                          ? authProvider.errorMessage
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Inputpassword(
                      controller: confirmPasswordController,
                      name: 'confirm_password',
                      title: 'Nhập lại mật khẩu mới',
                      hintText: "Nhập lại mật khẩu mới",
                      errorText: authProvider.errorMessage ==
                              "Mật khẩu xác nhận không khớp"
                          ? authProvider.errorMessage
                          : null,
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
