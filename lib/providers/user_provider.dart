import 'dart:io';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../core/base/base_provider.dart';
import '../models/auth_model.dart';
import '../models/business_model.dart';
import '../repository/user_repository.dart';

class UserProvider extends BaseProvider {
  final UserRepository _userRepository = UserRepository();
  Author? _user;
  Author? _userByID;

  bool _isLoading = false;
  bool _isLoadingByID = false;

  List<BusinessModel> businesses = [];

  Author? get author => _user;
  Author? get authorByID => _userByID;

  bool get isLoading => _isLoading;
  bool get isLoadingByID => _isLoadingByID;

  Future<void> fetchUser(BuildContext context,
      {bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _user = await _userRepository.fetchUser(context);
      print('User fetched successfully: ${_user?.displayName}');
    } catch (e) {
      print('Error in UserProvider: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Đã xảy ra lỗi khi lấy thông tin người dùng: $e')),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  //hàm chỉnh sửa thông tin người dùng
  Future<void> updateUser(
    BuildContext context, {
    required Map<String, dynamic> body,
    List<File>? avatarFiles,
    List<File>? coverFiles,
    bool showLoading = true,
  }) async {
    await executeApiCall<Author>(
      apiCall: () => _userRepository.updateUser(context, body,
          avatarFiles: avatarFiles, coverFiles: coverFiles),
      context: context,
      onSuccess: () async {
        await fetchUser(context, showLoading: false);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      successMessage: 'Cập nhật thông tin người dùng thành công',
    );
  }

  Future<void> fetchUserByID(BuildContext context, String idUser,
      {bool showLoading = true}) async {
    if (showLoading) {
      _isLoadingByID = true;
      notifyListeners();
    }

    try {
      _userByID = await _userRepository.fetchUserById(context, idUser);
      print('User fetched successfully: ${_userByID?.displayName}');
    } catch (e) {
      print('Error in UserProvider: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Đã xảy ra lỗi khi lấy thông tin người dùng: $e')),
      );
    }

    _isLoadingByID = false;
    notifyListeners();
  }
}
