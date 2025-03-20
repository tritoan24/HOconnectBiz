import 'dart:io';
import 'dart:math';
import 'dart:async';

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
import '../core/services/socket_service.dart';
import '../models/apiresponse.dart';
import '../repository/auth_repository.dart';
import '../utils/router/router.dart';
import '../utils/router/router.name.dart';
import '../providers/send_error_log.dart';

class AuthProvider extends BaseProvider {
  final AuthRepository _authRepository = AuthRepository();
  final socketService = SocketService();

  // Phương thức lưu token vào SharedPreferences
  Future<void> _saveToken(String token) async {
    try {
      if (token.isEmpty) {
        if (kDebugMode) {
          print("⚠️ Token trống, không lưu");
        }
        return;
      }
      
      // Lưu token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      // Xác minh token đã được lưu đúng
      final savedToken = prefs.getString('auth_token');
      if (savedToken != token) {
        throw Exception("Token lưu không khớp với token đã lưu");
      }
      
      if (kDebugMode) {
        print("💾 Đã lưu token thành công vào SharedPreferences");
        print("💾 Độ dài token: ${token.length} ký tự");
      }
    } catch (e) {
      print('Lỗi lưu token: $e');
      sendErrorLog(
        level: 2,
        message: "Lỗi khi lưu token",
        additionalInfo: e.toString(),
      );
      // Set error để hiển thị cho người dùng
      setError("Không thể lưu thông tin đăng nhập: $e");
    }
  }

  // Phương thức lưu userId vào SharedPreferences
  Future<void> _saveUserId(String id) async {
    try {
      if (id.isEmpty) {
        if (kDebugMode) {
          print("⚠️ userId trống, không lưu");
        }
        return;
      }
      
      // Lưu userId vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', id);
      
      // Xác minh userId đã được lưu đúng
      final savedUserId = prefs.getString('user_id');
      if (savedUserId != id) {
        throw Exception("UserId lưu không khớp với userId đã lưu");
      }
      
      if (kDebugMode) {
        print("🔑 Đã lưu user ID: $id vào SharedPreferences");
      }
    } catch (e) {
      print('Lỗi lưu user ID: $e');
      sendErrorLog(
        level: 2,
        message: "Lỗi khi lưu userId",
        additionalInfo: e.toString(),
      );
      // Set error để hiển thị cho người dùng
      setError("Không thể lưu ID người dùng: $e");
    }
  }

  // Phương thức đọc token từ SharedPreferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (kDebugMode) {
        print("🔍 Đọc token từ SharedPreferences: ${token != null ? 'Thành công' : 'Không tìm thấy'}");
      }
      return token;
    } catch (e) {
      print('Lỗi đọc token: $e');
      sendErrorLog(
        level: 1,
        message: "Lỗi khi đọc token",
        additionalInfo: e.toString(),
      );
      return null;
    }
  }

  // Phương thức đọc userId từ SharedPreferences
  Future<String?> getuserID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (kDebugMode) {
        print("🔍 Đọc user ID từ SharedPreferences: ${userId != null ? userId : 'Không tìm thấy'}");
      }
      return userId;
    } catch (e) {
      print('Lỗi đọc user ID: $e');
      sendErrorLog(
        level: 1,
        message: "Lỗi khi đọc userId",
        additionalInfo: e.toString(),
      );
      return null;
    }
  }
  
  // Xóa toàn bộ dữ liệu khi đăng xuất
  Future<void> _clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('register_type');
      
      if (kDebugMode) {
        print("🗑️ Đã xóa dữ liệu người dùng từ SharedPreferences");
      }
    } catch (e) {
      print('Lỗi xóa dữ liệu SharedPreferences: $e');
      sendErrorLog(
        level: 1,
        message: "Lỗi khi xóa dữ liệu SharedPreferences",
        additionalInfo: e.toString(),
      );
    }
    
    // Cố gắng xóa flutter_secure_storage nếu có dữ liệu cũ
    try {
      final secureStorage = FlutterSecureStorage(
        aOptions: const AndroidOptions(
          encryptedSharedPreferences: true,
          resetOnError: true,
        )
      );
      await secureStorage.deleteAll();
      
      if (kDebugMode) {
        print("🗑️ Đã xóa dữ liệu người dùng từ SecureStorage");
      }
    } catch (e) {
      // Bỏ qua lỗi, chỉ log
      if (kDebugMode) {
        print("⚠️ Không thể xóa dữ liệu từ SecureStorage: $e");
      }
    }
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    try {
      // Bắt đầu loading
      setLoading(true);
      
      final token = await _getToken();
      
      if (kDebugMode) {
        print("🔍 Kiểm tra trạng thái đăng nhập: ${token != null ? 'Có token' : 'Không có token'}");
      }
      
      // Nếu không có token, người dùng chưa đăng nhập
      if (token == null) {
        setLoading(false);
        return;
      }
      
      // Nếu có token, kiểm tra người dùng
      final userId = await getuserID();
      if (kDebugMode) {
        print("🔍 UserId từ SharedPreferences: ${userId ?? 'Không tìm thấy'}");
      }

      if (userId != null) {
        // Kết nối socket nếu có user ID
        try {
          socketService.connect(userId);
          if (kDebugMode) {
            print("🔌 Đã kết nối socket với userId: $userId");
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Lỗi kết nối socket: $e");
          }
          // Lỗi socket không nên ảnh hưởng đến trạng thái đăng nhập
        }
      }
      
      if (!context.mounted) return;
      
      try {
        // Tải thông tin người dùng
        if (kDebugMode) {
          print("🔄 Bắt đầu tải thông tin người dùng");
        }
        
        // Thiết lập timeout để tránh treo vô hạn
        final userFuture = Provider.of<UserProvider>(context, listen: false).fetchUser(context);
        await userFuture.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (kDebugMode) {
              print("⏱️ Timeout khi tải thông tin người dùng");
            }
            throw TimeoutException("Lấy thông tin người dùng quá thời gian");
          }
        );
        
        if (kDebugMode) {
          print("✅ Tải thông tin người dùng thành công");
        }
        
        if (context.mounted) {
          // Chuyển hướng đến trang chủ nếu token hợp lệ
          context.go(AppRoutes.trangChu.replaceFirst(':index', '0'));
        }
      } catch (e) {
        // Nếu có lỗi khi fetch user data, xử lý theo loại lỗi
        if (kDebugMode) {
          print("❌ Lỗi khi kiểm tra trạng thái đăng nhập: $e");
        }
        
        // Log lỗi
        sendErrorLog(
          level: 1,
          message: "Lỗi khi kiểm tra đăng nhập",
          additionalInfo: e.toString(),
        );
        
        // Kiểm tra xem có phải lỗi kết nối không
        if (e is SocketException || e is TimeoutException) {
          if (kDebugMode) {
            print("🌐 Lỗi kết nối mạng, giữ nguyên token và chuyển đến trang đăng nhập");
          }
          // Không xóa token nếu chỉ là lỗi kết nối
          // Đây là thay đổi quan trọng - không xóa token khi chỉ là lỗi mạng
          if (context.mounted) {
            // Chuyển đến trang đăng nhập nhưng giữ lại token
            context.go(AppRoutes.login);
          }
        } else {
          if (kDebugMode) {
            print("🔒 Lỗi xác thực, cần đăng nhập lại");
          }
          // Xóa token chỉ khi có lỗi xác thực
          await _clearAllData();
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        }
      }
    } catch (e, stackTrace) {
      // Xử lý lỗi không xác định
      if (kDebugMode) {
        print("❌ Lỗi không xác định trong checkLoginStatus: $e");
      }
      
      // Log lỗi
      sendErrorLog(
        level: 3, 
        message: "Unhandled Exception in AuthProvider: checkLoginStatus",
        additionalInfo: "${e.toString()}\n${stackTrace.toString()}",
      );
      
      // KHÔNG xóa token ở đây, chỉ thông báo lỗi
      // Thay đổi quan trọng - không xóa token tự động khi có lỗi
      setError("Có lỗi khi kiểm tra trạng thái đăng nhập. Vui lòng thử lại.");
    } finally {
      // Kết thúc loading
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
            context.go(AppRoutes.trangChu.replaceFirst(':index', '0'));
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
    try {
      // Xóa token authentication
      await _clearAllData();
      
      socketService.disconnect();
      
      // Đặt lại trạng thái hiện tại
      clearState();
      
      // Hiển thị thông báo thành công
      setSuccess("Đăng xuất thành công!");
      
      // Chuyển hướng về trang đăng nhập
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
      
      // Xóa thông báo trạng thái sau 2 giây
      Future.delayed(const Duration(seconds: 2), () {
        clearState();
      });
    } catch (e) {
      // Xử lý nếu có lỗi
      setError("Có lỗi xảy ra khi đăng xuất: $e");
      print("Lỗi đăng xuất: $e");
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
          if (kDebugMode) {
            print("✅ Đã ẩn loading overlay");
          }
        }
      }
      
      // Log để gỡ lỗi
      if (kDebugMode) {
        print("🔐 Bắt đầu đăng nhập social với ${registerType == 'gg' ? 'Google' : 'Facebook'}");
        print("📧 Email: $identity");
        print("👤 Tên: $displayName");
        print("🖼️ Avatar: ${avatarImage.substring(0, min(30, avatarImage.length))}...");
      }

      // Thêm timeout để tránh treo vô hạn
      final apiCallCompleter = Completer<ApiResponse>();
      
      // Set timeout cho API call
      Timer(const Duration(seconds: 30), () {
        if (!apiCallCompleter.isCompleted) {
          apiCallCompleter.completeError(
            TimeoutException("Đăng nhập mạng xã hội quá thời gian chờ (30s)")
          );
          
          if (kDebugMode) {
            print("⏱️ Timeout khi đăng nhập social");
          }
          
          sendErrorLog(
            level: 2,
            message: "Timeout khi đăng nhập social",
            additionalInfo: "identity: $identity, registerType: $registerType",
          );
          
          // Đảm bảo ẩn loading và hiển thị thông báo cho người dùng
          hideLoadingOnce();
          setError("Đăng nhập mạng xã hội thất bại, vui lòng thử lại sau");
        }
      });
      
      // Thực hiện API call trong try-catch riêng
      try {
        final response = await _authRepository.loginSocial(
            identity, password, displayName, registerType, avatarImage, context);
        if (!apiCallCompleter.isCompleted) {
          apiCallCompleter.complete(response);
        }
      } catch (apiError) {
        if (!apiCallCompleter.isCompleted) {
          apiCallCompleter.completeError(apiError);
        }
      }

      await executeApiCall(
        apiCall: () => apiCallCompleter.future,
        context: context,
        onSuccess: () async {
          if (kDebugMode) {
            print("✅ Đăng nhập social thành công");
          }
          
          // Kiểm tra user có tồn tại không
          if (user == null) {
            if (kDebugMode) {
              print("❌ Lỗi: user là null sau khi đăng nhập thành công");
            }
            
            hideLoadingOnce();
            sendErrorLog(
              level: 2,
              message: "Đăng nhập social thành công nhưng user là null",
              additionalInfo: "registerType: $registerType, identity: $identity",
            );
            
            setError("Có lỗi khi nhận thông tin người dùng, vui lòng thử lại");
            return;
          }
          
          // Kiểm tra token và userId có tồn tại không
          if (user!.token == null || user!.idUser == null) {
            if (kDebugMode) {
              print("❌ Lỗi: token hoặc idUser là null");
              print("Token: ${user!.token}");
              print("IdUser: ${user!.idUser}");
            }
            
            hideLoadingOnce();
            sendErrorLog(
              level: 2,
              message: "Đăng nhập social thành công nhưng token hoặc idUser là null",
              additionalInfo: "registerType: $registerType, identity: $identity, token: ${user!.token}, idUser: ${user!.idUser}",
            );
            
            setError("Thiếu thông tin xác thực, vui lòng thử lại");
            return;
          }
          
          final token = user!.token!;
          final idUser = user!.idUser!;

          try {
            if (kDebugMode) {
              print("🔑 Lưu token và userId");
            }
            
            await _saveToken(token);
            await _saveUserId(idUser);

            // Liên kết với OneSignal và Socket
            if (kDebugMode) {
              print("🔔 Đăng ký OneSignal và Socket");
            }
            
            OneSignal.login(identity);
            socketService.connect(idUser);
            
            if (kDebugMode) {
              print("🔄 Bắt đầu tải dữ liệu người dùng");
            }

            // Tạo danh sách các Future để theo dõi
            final futures = <Future>[];
            if (!context.mounted) {
              hideLoadingOnce();
              if (kDebugMode) {
                print("⚠️ Context không còn hợp lệ sau khi đăng nhập thành công");
              }
              return;
            }
            
            try {
              // Chỉ tải dữ liệu user và ẩn loading ngay
              await Provider.of<UserProvider>(context, listen: false)
                  .fetchUser(context)
                  .timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  if (kDebugMode) {
                    print("⏱️ Timeout khi tải dữ liệu người dùng");
                  }
                  return null;
                },
              );
              
              // Ẩn loading overlay sau khi tải dữ liệu người dùng, không đợi các dữ liệu khác
              hideLoadingOnce();
              
              if (kDebugMode) {
                print("🔄 Tải các dữ liệu khác trong nền");
              }
              
              // Tải các dữ liệu khác trong nền, không đợi
              Provider.of<ProductProvider>(context, listen: false)
                  .getListProduct(context);
                  
              final postProvider =
                  Provider.of<PostProvider>(context, listen: false);
              final rankProvider =
                  Provider.of<RankProvider>(context, listen: false);

              rankProvider.fetchRanksRevenue(context);
              rankProvider.fetchRankBusiness(context);
              postProvider.fetchPostsFeatured(context);
              postProvider.fetchPostsByUser(context);
            } catch (fetchError) {
              if (kDebugMode) {
                print("❌ Lỗi khi tải dữ liệu: $fetchError");
              }
              
              // Vẫn ẩn loading nếu có lỗi
              hideLoadingOnce();
            }

            if (context.mounted) {
              if (kDebugMode) {
                print("🚀 Chuyển hướng về trang chủ");
              }
              context.go(AppRoutes.trangChu.replaceFirst(':index', '0'));
            } else {
              if (kDebugMode) {
                print("⚠️ Context không còn hợp lệ khi chuyển màn hình");
              }
            }
          } catch (postLoginError) {
            hideLoadingOnce();
            if (kDebugMode) {
              print("❌ Lỗi sau khi đăng nhập: $postLoginError");
            }
            
            sendErrorLog(
              level: 2,
              message: "Lỗi sau khi đăng nhập social thành công",
              additionalInfo: postLoginError.toString(),
            );
            
            // Vẫn chuyển hướng về trang chủ nếu có token
            if (context.mounted) {
              context.go(AppRoutes.trangChu.replaceFirst(':index', '0'));
            }
          }
        },
      );
      
      // Xử lý nếu API call thất bại hoặc có lỗi
      if (errorMessage != null) {
        hideLoadingOnce();
        
        if (kDebugMode) {
          print("❌ Lỗi đăng nhập social: $errorMessage");
        }
        
        sendErrorLog(
          level: 2,
          message: "Lỗi khi đăng nhập social",
          additionalInfo: errorMessage.toString(),
        );
      }
    } catch (e) {
      // Đảm bảo ẩn loading trong mọi trường hợp lỗi
      LoadingOverlay.hide();
      
      if (kDebugMode) {
        print("❌ Lỗi ngoại lệ khi đăng nhập social: $e");
      }
      
      sendErrorLog(
        level: 3,
        message: "Unhandled Exception in loginSocial",
        additionalInfo: e.toString(),
      );
      
      setError("Đăng nhập mạng xã hội thất bại: ${e.toString()}");
    }
  }
}

// Hàm tạo mật khẩu ngẫu nhiên
String _generateRandomPassword() {
  const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
  const String numbers = '0123456789';
  const String specialChars = '@&#';
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
