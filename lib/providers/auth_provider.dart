import 'dart:io';
import 'dart:math';

import 'package:clbdoanhnhansg/config/app_config.dart';
import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:clbdoanhnhansg/providers/product_provider.dart';
import 'package:clbdoanhnhansg/providers/rank_provider.dart';
import 'package:clbdoanhnhansg/providers/user_provider.dart';
import 'package:clbdoanhnhansg/widgets/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../core/base/base_provider.dart';
import '../core/network/api_endpoints.dart';
import '../core/services/socket_service.dart';
import '../models/apiresponse.dart';
import '../repository/auth_repository.dart';
import '../utils/router/router.dart';
import '../utils/router/router.name.dart';

class AuthProvider extends BaseProvider {
  final AuthRepository _authRepository = AuthRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final socketService = SocketService();

  // Thêm getter isLoggedIn
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Thêm phương thức getToken public
  Future<String?> getToken() async {
    return _getToken();
  }

  Future<void> _saveToken(String token) async {
    try {
      // Lưu vào FlutterSecureStorage
      await _storage.write(key: 'auth_token', value: token);

      // Lưu vào SharedPreferences như backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      print('Lỗi lưu token: $e');
      // Nếu FlutterSecureStorage lỗi, chỉ lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
  }

  Future<void> _saveUserId(String id) async {
    try {
      // Lưu vào FlutterSecureStorage
      await _storage.write(key: 'user_id', value: id);

      // Lưu vào SharedPreferences như backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', id);

      if (kDebugMode) {
        print("🔑 id user: $id");
      }
    } catch (e) {
      print('Lỗi lưu user ID: $e');
      // Nếu FlutterSecureStorage lỗi, chỉ lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', id);
    }
  }

  Future<String?> _getToken() async {
    try {
      // Thử lấy từ FlutterSecureStorage trước
      final secureToken = await _storage.read(key: 'auth_token');
      if (secureToken != null) return secureToken;

      // Nếu không có, lấy từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Lỗi đọc token: $e');
      // Nếu FlutterSecureStorage lỗi, lấy từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    }
  }

  Future<String?> getuserID() async {
    try {
      // Thử lấy từ FlutterSecureStorage trước
      final secureId = await _storage.read(key: 'user_id');
      if (secureId != null) return secureId;

      // Nếu không có, lấy từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      print('Lỗi đọc user ID: $e');
      // Nếu FlutterSecureStorage lỗi, lấy từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    }
  }

  Future<void> _clearAllData() async {
    try {
      // Xóa dữ liệu từ FlutterSecureStorage
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_id');

      // Xóa dữ liệu từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
    } catch (e) {
      print('Lỗi xóa dữ liệu: $e');
      // Nếu FlutterSecureStorage lỗi, chỉ xóa từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
    }
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    try {
      // Bắt đầu loading
      setLoading(true);
      // Record start time
      final startTime = DateTime.now();

      final token = await _getToken();

      if (token != null && token.isNotEmpty) {
        // Cập nhật trạng thái đăng nhập
        _isLoggedIn = true;
        
        // Get user ID for socket connection
        final userId = await getuserID();

        if (userId != null) {
          // Connect to socket if we have a user ID
          socketService.connect(userId);
        }

        if (!context.mounted) return;

        // Tạo danh sách các Future để theo dõi
        final futures = <Future>[];

        // Thêm các tác vụ fetch dữ liệu vào danh sách
        futures.add(Provider.of<UserProvider>(context, listen: false)
            .fetchUser(context));
        futures.add(Provider.of<ProductProvider>(context, listen: false)
            .getListProduct(context));

        final postProvider = Provider.of<PostProvider>(context, listen: false);
        final rankProvider = Provider.of<RankProvider>(context, listen: false);

        futures.add(rankProvider.fetchRanksRevenue(context));
        futures.add(rankProvider.fetchRankBusiness(context));

        futures.add(postProvider.fetchPostsFeatured(context));
        futures.add(postProvider.fetchPostsByUser(context));

        // Chờ tất cả các tác vụ hoàn thành
        await Future.wait(futures);

        // Chỉ chuyển hướng sau khi tất cả fetch data đã hoàn thành
        if (context.mounted) {
          // Xóa lỗi trước khi chuyển màn hình
          clearState();
          
          // Sửa: Chuyển hướng đến đúng route
          context.go(AppRoutes.trangChu);
        }
      } else {
        // Cập nhật trạng thái đăng nhập
        _isLoggedIn = false;
        
        // Ensure minimum 3 seconds even for login routing
        final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
        final remainingMs = 3000 - elapsedMs;
        if (remainingMs > 0) {
          await Future.delayed(Duration(milliseconds: remainingMs));
        }

        if (context.mounted) {
          clearState();
          context.go(AppRoutes.login);
        }
      }
    } catch (e) {
      // Đảm bảo cập nhật trạng thái đăng nhập khi có lỗi
      _isLoggedIn = false;
      
      setError("Lỗi điều hướng: $e");
      // Nếu có lỗi, chuyển về trang login
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    } finally {
      // Kết thúc loading trong mọi trường hợp
      setLoading(false);
    }
  }

  Future<void> login(
      BuildContext context, String username, String password) async {
    try {
      // Hiển thị loading overlay
      LoadingOverlay.show(context);

      // Đánh dấu để không ẩn LoadingOverlay nhiều lần
      bool loadingHidden = false;

      void hideLoadingOnce() {
        if (!loadingHidden) {
          LoadingOverlay.hide();
          loadingHidden = true;
        }
      }

      await executeApiCall(
        apiCall: () => _authRepository.login(username, password, context),
        context: context,
        onSuccess: () async {
          final token = user!.token!;
          final idUser = user!.idUser!;
          await _saveToken(token);
          await _saveUserId(idUser);
          
          // Cập nhật trạng thái đăng nhập
          _isLoggedIn = true;
          
          OneSignal.login(username);
          socketService.connect(idUser);

          // Tạo danh sách các Future để theo dõi
          final futures = <Future>[];
          if (!context.mounted) return;
          // Thêm các tác vụ fetch dữ liệu vào danh sách
          futures.add(Provider.of<UserProvider>(context, listen: false)
              .fetchUser(context));
          futures.add(Provider.of<ProductProvider>(context, listen: false)
              .getListProduct(context));

          final postProvider =
              Provider.of<PostProvider>(context, listen: false);
          final rankProvider =
              Provider.of<RankProvider>(context, listen: false);

          futures.add(rankProvider.fetchRanksRevenue(context));
          futures.add(rankProvider.fetchRankBusiness(context));

          futures.add(postProvider.fetchPostsFeatured(context));
          futures.add(postProvider.fetchPostsByUser(context));

          // Chờ tất cả các tác vụ hoàn thành
          await Future.wait(futures);

          if (context.mounted) {
            // Ẩn loading overlay
            hideLoadingOnce();
            // Xóa lỗi trước khi chuyển màn hình
            clearState();
            context.go(AppRoutes.trangChu);
          }
        },
      );

      // Nếu có lỗi, đảm bảo ẩn loading
      if (errorMessage != null) {
        hideLoadingOnce();
      }
    } catch (e) {
      // Đảm bảo ẩn loading trong mọi trường hợp lỗi
      LoadingOverlay.hide();
      debugPrint("Lỗi đăng nhập: $e");

      // Set error message từ exception
      setError(e.toString());
    }
  }

  Future<void> register(
    BuildContext context,
    String identity,
    String password,
    String repassword,
    String displayName,
  ) async {
    await executeApiCall(
      apiCall: () => _authRepository.register(
          identity, password, repassword, displayName, context),
      context: context,
      onSuccess: () async {
        setSuccess("Tạo tài khoản thành công!");
        clearState();

        // Kiểm tra định dạng của identity
        if (isEmail(identity)) {
          OneSignal.User.addEmail(identity);
        } else if (isPhoneNumber(identity)) {
          OneSignal.User.addSms(
              formatPhoneNumber(identity)); // Tự động thêm +84
        } else {
          debugPrint("Identity không hợp lệ: $identity"); // Log lỗi nếu cần
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            context.go(AppRoutes.login,
                extra: {"identity": identity, "password": password});
          }
        });
      },
    );
  }

// Hàm kiểm tra email
  bool isEmail(String input) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(input);
  }

// Hàm kiểm tra số điện thoại (không cần mã quốc gia)
  bool isPhoneNumber(String input) {
    final phoneRegex = RegExp(r'^[0-9]{9,11}$');
    return phoneRegex.hasMatch(input);
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

  Future<void> logout(BuildContext context) async {
    // Show loading overlay at the beginning
    LoadingOverlay.show(context);

    try {
      await executeApiCall(
        apiCall: () async {
          // Xóa dữ liệu từ cả hai storage
          await _clearAllData();
          
          // Cập nhật trạng thái đăng nhập
          _isLoggedIn = false;

          // Lấy registerType từ SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? registerType = prefs.getString('register_type');

          if (registerType == null) {
            developer.log('Không tìm thấy registerType trong storage',
                name: 'LOGOUT.ERROR');
          } else if (registerType == 'gg') {
            try {
              developer.log('Bắt đầu quá trình đăng xuất Google',
                  name: 'LOGOUT_GOOGLE');

              // Đăng xuất Google
              final GoogleSignIn googleSignIn = GoogleSignIn(
                scopes: [
                  'email',
                  'https://www.googleapis.com/auth/userinfo.profile'
                ],
                clientId: Platform.isIOS ? AppConfig.clientIdIos : null,
              );

              developer.log('Kiểm tra phiên đăng nhập hiện tại...',
                  name: 'LOGOUT_GOOGLE');
              // Kiểm tra xem có đang đăng nhập không
              final currentUser = await googleSignIn.signInSilently();

              if (currentUser != null) {
                developer.log(
                    'Tìm thấy người dùng đã đăng nhập: ${currentUser.email}',
                    name: 'LOGOUT_GOOGLE');

                try {
                  developer.log('Thực hiện disconnect()...',
                      name: 'LOGOUT_GOOGLE');
                  await googleSignIn.disconnect();
                  developer.log('Đã thực hiện disconnect thành công',
                      name: 'LOGOUT_GOOGLE');
                } catch (disconnectError) {
                  developer.log('Lỗi khi disconnect: $disconnectError',
                      name: 'LOGOUT_GOOGLE_ERROR');
                }

                try {
                  developer.log('Thực hiện signOut()...',
                      name: 'LOGOUT_GOOGLE');
                  await googleSignIn.signOut();
                  developer.log('Đã thực hiện signOut thành công',
                      name: 'LOGOUT_GOOGLE');
                } catch (signOutError) {
                  developer.log('Lỗi khi signOut: $signOutError',
                      name: 'LOGOUT_GOOGLE_ERROR');
                }

                // Đảm bảo xóa register_type
                await prefs.remove('register_type');
                developer.log('Đã xóa register_type', name: 'LOGOUT_GOOGLE');

                developer.log('Quá trình đăng xuất Google hoàn tất',
                    name: 'LOGOUT_GOOGLE');
              } else {
                developer.log('Không tìm thấy phiên đăng nhập Google hiện tại',
                    name: 'LOGOUT_GOOGLE');
              }

              // Kiểm tra lại sau khi đăng xuất
              final checkUser = await googleSignIn.signInSilently();
              developer.log(
                  'Kiểm tra sau đăng xuất: ${checkUser == null ? "Đã đăng xuất thành công" : "Vẫn còn đăng nhập"}',
                  name: 'LOGOUT_GOOGLE');
            } catch (e) {
              developer.log('Lỗi trong quá trình đăng xuất Google: $e',
                  name: 'LOGOUT_GOOGLE_ERROR', error: e);
            }
          } else if (registerType == 'fb') {
            await FacebookAuth.instance.logOut();
            developer.log('Đã đăng xuất Facebook',
                name: 'PROFILE_LOGOUT.FACEBOOK');
          }

          // Đăng xuất OneSignal
          OneSignal.logout();

          // Xóa tất cả dữ liệu từ SharedPreferences
          await prefs.clear();

          return ApiResponse(isSuccess: true, message: "Đăng xuất thành công");
        },
        context: context,
        onSuccess: () {
          clearState();
          context.go(AppRoutes.login);
        },
      );
    } catch (e) {
      developer.log('Lỗi trong quá trình đăng xuất: $e',
          name: 'LOGOUT_ERROR', error: e);
    } finally {
      // Hide loading overlay regardless of success or failure
      LoadingOverlay.hide();
    }
  }

  Future<void> sendEmailOtp(BuildContext context, String email) async {
    await executeApiCall(
      apiCall: () => _authRepository.sendOtpEmail(email, context),
      context: context,
      onSuccess: () {
        // Xóa lỗi trước khi chuyển màn hình
        clearState();
        context.go(AppRoutes.nhapMaOTP, extra: {'email': email});
      },
    );
  }

  Future<void> inputOtp(BuildContext context, String email, String code) async {
    await executeApiCall(
      apiCall: () async {
        final response = await _authRepository.inputOtp(email, code, context);
        if (kDebugMode) {
          print("dữ liệu nhập : $email - $code");
          print(
              "Kết quả xác thực mã OTP: ${response.message} - ${response.isSuccess}");
        }

        return response;
      },
      context: context,
      onSuccess: () {
        // Xóa lỗi trước khi chuyển màn hình
        clearState();
        context.go(AppRoutes.taoMatKhauMoi, extra: {"email": email});
      },
    );
  }

  Future<void> resetpassword(
    BuildContext context,
    String email,
    String password,
    String repassword,
  ) async {
    await executeApiCall(
      apiCall: () =>
          _authRepository.resetpassword(email, password, repassword, context),
      context: context,
      onSuccess: () {
        // Xóa lỗi trước khi chuyển màn hình
        clearState();
        context.go(AppRoutes.login);
      },
      successMessage: "Đặt lại mật khẩu thành công",
    );
  }

  Future<void> changePassword(
    BuildContext context,
    String password,
    String newpassword,
    String repassword,
  ) async {
    await executeApiCall(
      apiCall: () => _authRepository.changepassword(
          password, newpassword, repassword, context),
      context: context,
      onSuccess: () {
        // Xóa lỗi trước khi chuyển màn hình
        clearState();
        context.pop();
      },
      successMessage: "Đổi mật khẩu thành công",
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    const String tag = 'GOOGLE_LOGIN';
    const String registerTypeGG = 'gg';
    const String defaultImage = UrlImage.defaultAvatarImage;

    try {
      // Hiển thị loading overlay
      LoadingOverlay.show(context);

      developer.log('Bắt đầu đăng nhập Google', name: tag);
      developer.log('Kiểm tra CLIENT_IOS:', name: AppConfig.clientIdIos);

      final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
          clientId: Platform.isIOS ? AppConfig.clientIdIos : null);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        developer.log('Người dùng hủy đăng nhập', name: '$tag.CANCELLED');
        // Ẩn loading overlay nếu người dùng hủy đăng nhập
        LoadingOverlay.hide();
        return;
      }
      developer.log('Đăng nhập thành công', name: '$tag.SUCCESS');

      final userData = {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? 'User',
        'picture': googleUser.photoUrl ?? defaultImage,
      };
      developer.log('Thông tin người dùng: $userData', name: '$tag.USER_DATA');

      if (context.mounted) {
        _handleLoginSocialSuccess(context, userData, registerTypeGG);
      } else {
        // Ẩn loading overlay nếu context không còn hợp lệ
        LoadingOverlay.hide();
      }
    } catch (e) {
      developer.log('Lỗi đăng nhập Google: $e', name: '$tag.ERROR', error: e);
      // Ẩn loading overlay nếu có lỗi
      LoadingOverlay.hide();
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    const String tag = 'FB_LOGIN';
    const String registerTypeFB = 'fb';

    try {
      // Hiển thị loading overlay
      LoadingOverlay.show(context);

      developer.log('Bắt đầu đăng nhập Facebook', name: tag);
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      switch (result.status) {
        case LoginStatus.success:
          developer.log(
            'Đăng nhập thành công',
            name: '$tag.SUCCESS',
          );
          developer.log('Đang lấy thông tin người dùng...',
              name: '$tag.USER_DATA');
          final userData = await FacebookAuth.instance.getUserData(
            fields: "name,email,picture.width(200)",
          );
          developer.log('Thông tin người dùng: $userData',
              name: '$tag.USER_DATA');
          if (context.mounted) {
            _handleLoginSocialSuccess(context, userData, registerTypeFB);
          } else {
            // Ẩn loading overlay nếu context không còn hợp lệ
            LoadingOverlay.hide();
          }
          break;

        case LoginStatus.cancelled:
          developer.log('Người dùng hủy đăng nhập', name: '$tag.CANCELLED');
          _handleLoginIssue(
            message: 'Xử lý hủy đăng nhập',
            tag: '$tag.CANCELLED',
          );
          // Ẩn loading overlay nếu người dùng hủy đăng nhập
          LoadingOverlay.hide();
          break;

        case LoginStatus.failed:
          developer.log('Đăng nhập thất bại - Lỗi: ${result.message}',
              name: '$tag.FAILED');
          _handleLoginIssue(
            message: 'Xử lý thất bại: ${result.message}',
            tag: '$tag.FAILED',
          );
          // Ẩn loading overlay nếu đăng nhập thất bại
          LoadingOverlay.hide();
          break;

        default:
          developer.log('Trạng thái không xác định: ${result.status}',
              name: '$tag.UNKNOWN');
          // Ẩn loading overlay trong trường hợp không xác định
          LoadingOverlay.hide();
      }
    } catch (e) {
      developer.log('Lỗi hệ thống: $e', name: '$tag.ERROR', error: e);
      _handleLoginIssue(
        message: 'Xử lý lỗi: $e',
        tag: '$tag.ERROR',
        error: e,
      );
      // Ẩn loading overlay nếu có lỗi
      LoadingOverlay.hide();
    }
  }

  Future<void> _handleLoginSocialSuccess(BuildContext context,
      Map<String, dynamic> userData, String registerType) async {
    // Đặt tag dựa trên registerType
    final String tag =
        registerType == 'fb' ? 'FB_LOGIN.SUCCESS' : 'GG_LOGIN.SUCCESS';
    final String? id = userData['id'];
    final String? name = userData['name'];
    final String? email = userData['email'];
    String? avatarImage;

    if (registerType == 'fb') {
      avatarImage = userData['picture']?['data']?['url'];
    } else if (registerType == 'gg') {
      avatarImage = userData['picture'] as String?;
    }

    developer.log('Id: $id', name: tag);
    developer.log('Tên: $name', name: tag);
    developer.log('Email: $email', name: tag);
    developer.log('Ảnh đại diện: $avatarImage', name: tag);

    if (email != null && id != null && name != null && avatarImage != null) {
      final String randomPassword = _generateRandomPassword();

      // lưu loại đăng nhập theo phiên
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('register_type', registerType);
      if (context.mounted) {
        loginSocial(
            context, email, randomPassword, name, registerType, avatarImage);
      }
      OneSignal.User.addEmail(email);
      OneSignal.login(email);
    } else {
      // Cập nhật tag cho lỗi cũng dựa trên registerType
      final String errorTag = registerType == 'fb'
          ? 'FB_LOGIN.SUCCESS.ERROR'
          : 'GG_LOGIN.SUCCESS.ERROR';
      developer.log('Thiếu thông tin cần thiết để đăng nhập', name: errorTag);
      _handleLoginIssue(
        message: 'Không lấy được đầy đủ thông tin người dùng',
        tag: errorTag,
      );
    }
  }

  void _handleLoginIssue({
    required String message,
    required String tag,
    Object? error, // Tham số tùy chọn để log chi tiết lỗi nếu có
  }) {
    developer.log(message, name: tag, error: error);
  }

  Future<void> loginSocial(
      BuildContext context,
      String identity,
      String password,
      String displayName,
      String registerType,
      String avatarImage) async {
    try {
      // Hiển thị loading overlay
      LoadingOverlay.show(context);

      // Đánh dấu để không ẩn LoadingOverlay nhiều lần
      bool loadingHidden = false;

      void hideLoadingOnce() {
        if (!loadingHidden) {
          LoadingOverlay.hide();
          loadingHidden = true;
        }
      }

      await executeApiCall(
        apiCall: () => _authRepository.loginSocial(identity, password,
            displayName, registerType, avatarImage, context),
        context: context,
        onSuccess: () async {
          final token = user!.token!;
          final idUser = user!.idUser!;

          if (kDebugMode) {
            print("Token: $token");
            print("IdUser: $idUser");
            print("Password: $password");
          }

          await _saveToken(token);
          await _saveUserId(idUser);

          // Tạo danh sách các Future để theo dõi
          final futures = <Future>[];
          if (!context.mounted) return;
          // Thêm các tác vụ fetch dữ liệu vào danh sách
          futures.add(Provider.of<UserProvider>(context, listen: false)
              .fetchUser(context));
          futures.add(Provider.of<ProductProvider>(context, listen: false)
              .getListProduct(context));

          final postProvider =
              Provider.of<PostProvider>(context, listen: false);
          final rankProvider =
              Provider.of<RankProvider>(context, listen: false);

          futures.add(rankProvider.fetchRanksRevenue(context));
          futures.add(rankProvider.fetchRankBusiness(context));

          futures.add(postProvider.fetchPostsFeatured(context));
          futures.add(postProvider.fetchPostsByUser(context));

          // Chờ tất cả các tác vụ hoàn thành
          await Future.wait(futures);

          // Connect to socket
          OneSignal.login(identity);
          socketService.connect(idUser);

          if (context.mounted) {
            // Ẩn loading overlay
            hideLoadingOnce();
            context.go(AppRoutes.trangChu.replaceFirst(':index', '0'));
          } else {
            // Ẩn loading overlay nếu context không còn hợp lệ
            hideLoadingOnce();
            developer.log('Context không còn hợp lệ', name: 'FB_LOGIN.ERROR');
          }
        },
      );

      // Nếu có lỗi, đảm bảo ẩn loading
      if (errorMessage != null) {
        hideLoadingOnce();
      }
    } catch (e) {
      // Đảm bảo ẩn loading trong mọi trường hợp lỗi
      LoadingOverlay.hide();
      debugPrint("Lỗi đăng nhập social: $e");
    }
  }
}

// Hàm tạo mật khẩu ngẫu nhiên
String _generateRandomPassword() {
  const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
  const String numbers = '0123456789';
  const String specialChars = '@';
  const int minLength = 8;

  final Random random = Random();
  final StringBuffer password = StringBuffer();

  // Đảm bảo ít nhất 1 ký tự từ mỗi loại
  password.write(upperCase[random.nextInt(upperCase.length)]);
  password.write(lowerCase[random.nextInt(lowerCase.length)]);
  password.write(numbers[random.nextInt(numbers.length)]);
  password.write(specialChars[random.nextInt(specialChars.length)]);

  // Tạo thêm các ký tự ngẫu nhiên để đủ độ dài tối thiểu
  const String allChars = upperCase + lowerCase + numbers + specialChars;
  for (int i = password.length; i < minLength; i++) {
    password.write(allChars[random.nextInt(allChars.length)]);
  }

  // Xáo trộn mật khẩu để tăng tính ngẫu nhiên
  final List<String> passwordList = password.toString().split('');
  passwordList.shuffle(random);
  return passwordList.join();
}
