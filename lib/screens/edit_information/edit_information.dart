import 'dart:io';

import 'package:clbdoanhnhansg/screens/edit_information/widget/AccountForm.dart';
import 'package:clbdoanhnhansg/screens/edit_information/widget/AddAvatar.dart';
import 'package:clbdoanhnhansg/screens/edit_information/widget/AddBackgroud.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:clbdoanhnhansg/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/auth_model.dart';
import '../../providers/user_provider.dart';

class EditProfile extends StatefulWidget {
  final Author? user;

  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? _selectedImageAvatarPath;
  String? _selectedBackgroudPath;
  Map<String, String>? _formData;

  // Key để truy cập state của AccountForm
  final _accountFormKey = GlobalKey<AccountFormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedImageAvatarPath = widget.user?.avatarImage;
    _selectedBackgroudPath = widget.user?.coverImage;
  }

  void _handleImageAvatarSelected(String path) {
    setState(() {
      _selectedImageAvatarPath = path;
    });
  }

  void _handleImageBackgroudSelected(String path) {
    setState(() {
      _selectedBackgroudPath = path;
    });
  }

  void _handleFormDataChanged(Map<String, String> data) {
    setState(() {
      _formData = data; // Cập nhật dữ liệu từ AccountForm
    });
  }

  void _handleSubmit() async {
    if (_accountFormKey.currentState == null ||
        !_accountFormKey.currentState!.validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final avatarPath = _selectedImageAvatarPath ?? widget.user?.avatarImage;
    final backgroundPath = _selectedBackgroudPath ?? widget.user?.coverImage;
    final oldEmail = widget.user?.email ?? '';
    final oldPhone = widget.user?.phone ?? '';

    final formData = _formData ?? {
      'displayName': widget.user?.displayName ?? '',
      'description': widget.user?.description ?? '',
      'phoneNumber': widget.user?.phone ?? '',
      'email': widget.user?.email ?? '',
    };

    final newEmail = formData['email'] ?? '';
    final newPhone = formData['phoneNumber'] ?? '';

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final body = {...formData};

    List<File> avatarFiles = [];
    List<File> coverFiles = [];
    if (avatarPath != null && avatarPath.startsWith('/')) {
      avatarFiles.add(File(avatarPath));
    }
    if (backgroundPath != null && backgroundPath.startsWith('/')) {
      coverFiles.add(File(backgroundPath));
    }

    try {
      await userProvider.updateUser(
        context,
        body: body,
        avatarFiles: avatarFiles.isNotEmpty ? avatarFiles : null,
        coverFiles: coverFiles.isNotEmpty ? coverFiles : null,
      );

      if (!mounted) return;

      // Kiểm tra email thay đổi
      if (newEmail.isNotEmpty && newEmail != oldEmail) {
        if (oldEmail.isNotEmpty) {
          await OneSignal.User.removeEmail(oldEmail);
        }
        await OneSignal.User.addEmail(newEmail);
      }

      // Kiểm tra số điện thoại thay đổi
      if (newPhone.isNotEmpty && newPhone != oldPhone) {
        String formattedNewPhone = formatPhoneNumber(newPhone);
        String formattedOldPhone = formatPhoneNumber(oldPhone);

        if (formattedOldPhone.isNotEmpty) {
          await OneSignal.User.removeSms(formattedOldPhone);
        }
        await OneSignal.User.addSms(formattedNewPhone);
      }
      if(!mounted) return ;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật thông tin: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
// Hàm định dạng số điện thoại: Thêm +84 nếu chưa có mã quốc gia
  String formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }
    if (!phoneNumber.startsWith('+')) {
      return '+84$phoneNumber';
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColorApp,
        appBar: AppBar(
          title: const Text("Chỉnh sửa thông tin"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Addavatar(
                      onImageSelected: _handleImageAvatarSelected,
                      initialImage: _selectedImageAvatarPath,
                    ),
                    AddBackgroud(
                        onImageSelected: _handleImageBackgroudSelected,
                        initialImage: _selectedBackgroudPath),
                    AccountForm(
                      key: _accountFormKey, // Gán key để có thể truy cập state
                      user: widget.user,
                      onDataChanged: _handleFormDataChanged,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 20, bottom: 10, right: 16, left: 16),
                      child: ButtonWidget(
                        label: "Lưu thông tin",
                        onPressed: _handleSubmit,
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Hiển thị indicator khi đang loading
            if (_isLoading)
              Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )),
          ],
        ));
  }
}

