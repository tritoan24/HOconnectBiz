import 'package:clbdoanhnhansg/widgets/input_text.dart';
import 'package:flutter/material.dart';

import '../../../models/auth_model.dart';

class AccountForm extends StatefulWidget {
  final Author? user;
  final Function(Map<String, String>)? onDataChanged;

  const AccountForm({super.key, required this.user, this.onDataChanged});
  @override
  State<AccountForm> createState() => AccountFormState();
}

class AccountFormState extends State<AccountForm> {
  late TextEditingController _usernameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  // Add validation error state variables
  String? _phoneError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.user?.displayName ?? '');
    _descriptionController =
        TextEditingController(text: widget.user?.description ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');

    _usernameController.addListener(_notifyDataChanged);
    _descriptionController.addListener(_notifyDataChanged);
    _phoneController.addListener(() {
      _notifyDataChanged();
      validatePhone();
    });
    _emailController.addListener(() {
      _notifyDataChanged();
      validateEmail();
    });
  }

  // Phương thức để màn hình cha có thể gọi để validate số điện thoại
  bool validatePhone() {
    final phone = _phoneController.text;

    if (phone.isEmpty) {
      setState(() {
        _phoneError = null;
      });
      return true;
    } else if (!RegExp(r'^[0-9]{10,11}$').hasMatch(phone)) {
      setState(() {
        _phoneError = 'Số điện thoại phải có 10-11 chữ số';
      });
      return false;
    } else if (!phone.startsWith('0')) {
      setState(() {
        _phoneError = 'Số điện thoại phải bắt đầu bằng số 0';
      });
      return false;
    } else {
      setState(() {
        _phoneError = null;
      });
      return true;
    }
  }

  // Phương thức để màn hình cha có thể gọi để validate email
  bool validateEmail() {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _emailError = null;
      });
      return true;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Email không hợp lệ';
      });
      return false;
    } else {
      setState(() {
        _emailError = null;
      });
      return true;
    }
  }

  // Phương thức để màn hình cha có thể kiểm tra validation của cả form
  bool validateForm() {
    bool isPhoneValid = validatePhone();
    bool isEmailValid = validateEmail();
    return isPhoneValid && isEmailValid;
  }

  // Phương thức trả về các thông báo lỗi (nếu có)
  List<String> getErrorMessages() {
    List<String> errors = [];
    if (_phoneError != null) errors.add(_phoneError!);
    if (_emailError != null) errors.add(_emailError!);
    return errors;
  }

  // Hàm gửi dữ liệu qua callback
  void _notifyDataChanged() {
    if (widget.onDataChanged != null) {
      widget.onDataChanged!({
        'displayName': _usernameController.text,
        'description': _descriptionController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputText(
            title: "Tên tài khoản",
            hintText: widget.user?.username ?? "Nhập tên tài khoản",
            name: 'tenTaiKhoan',
            controller: _usernameController,
          ),
          const SizedBox(height: 16),
          InputText(
            title: "Mô tả",
            hintText: "Nhập mô tả",
            name: 'moTa',
            controller: _descriptionController,
          ),
          const SizedBox(height: 16),
          InputText(
            title: "Số điện thoại",
            hintText: "Nhập số điện thoại",
            name: 'soDienThoai',
            controller: _phoneController,
            errorText: _phoneError,
          ),
          const SizedBox(height: 16),
          InputText(
            title: "Email",
            hintText: "Nhập email",
            name: 'email',
            controller: _emailController,
            errorText: _emailError,
          ),
        ],
      ),
    );
  }
}
