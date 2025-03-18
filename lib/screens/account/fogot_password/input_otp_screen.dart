import 'dart:async';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/text_styles.dart';

class InputOtpScreen extends StatefulWidget {
  final String email;
  const InputOtpScreen({super.key, required this.email});

  @override
  State<InputOtpScreen> createState() => _InputOtpScreenState();
}

class _InputOtpScreenState extends State<InputOtpScreen> {
  // Các biến của OTP
  List<String> otp = ["", "", "", ""];
  bool isButtonEnabled = false;
  int secondsRemaining = 300;
  Timer? timer;
  String otpCode = "";

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Hàm format thời gian đếm ngược
  String get formattedTime {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  // Ẩn tất cả ký tự trước '@', chỉ giữ lại 3 ký tự cuối
  String maskedEmail() {
    int atIndex = widget.email.indexOf('@');
    if (atIndex > 3) {
      String lastThreeChars = widget.email.substring(atIndex - 3, atIndex);
      return "***" + lastThreeChars + widget.email.substring(atIndex);
    }
    return widget.email;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fieldWidth = (constraints.maxWidth - 100) / 4;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32, // Trừ đi padding
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.05),
                      Center(
                        child: Image.network(
                          UrlImage.logo,
                          width: size.width * 0.4,
                          height: size.height * 0.1,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/logo.png",
                              width: size.width * 0.4,
                              height: size.height * 0.1,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      // Row chứa nút back và tiêu đề
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 30),
                              onPressed: () {
                                // Xóa lỗi trước khi quay lại
                                Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .clearState();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          // Tiêu đề
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Xác thực tài khoản',
                                style: TextStyles.textStyleNormal30W700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        padding: EdgeInsets.all(size.height * 0.025),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14141524),
                              offset: Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // OTP Input Fields
                            OtpTextField(
                              numberOfFields: 4,
                              borderColor: const Color(0xFF512DA8),
                              focusedBorderColor: Colors.blue,
                              showFieldAsBox: true,
                              fieldWidth: fieldWidth,
                              borderRadius: BorderRadius.circular(10),
                              textStyle: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                              enabledBorderColor: Colors.grey,
                              disabledBorderColor: Colors.blue,
                              onCodeChanged: (String code) {
                                setState(() {
                                  otpCode = code;
                                  isButtonEnabled = code.length == 4;
                                });
                              },
                              onSubmit: (String code) {
                                setState(() {
                                  otpCode = code;
                                  isButtonEnabled = true;
                                });
                                print("OTP nhập vào: $otpCode");
                              },
                            ),
                            SizedBox(height: size.height * 0.01),
                            // Thông báo về email
                            Text(
                              "Mã xác thực đã được gửi đến địa chỉ email",
                              style: TextStyles.textStyleNormal14W400,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              maskedEmail(),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.blue),
                              textAlign: TextAlign.center,
                            ),
                            if (auth.errorMessage != null)
                              Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    height: 1.5,
                                    fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              ),
                            // Nút gửi lại mã OTP
                            TextButton(
                              onPressed: secondsRemaining == 0
                                  ? () {
                                      setState(() {
                                        secondsRemaining = 300;
                                        startTimer();
                                      });
                                    }
                                  : null,
                              child: Text(
                                "Gửi lại mã",
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: secondsRemaining == 0
                                      ? Colors.blue
                                      : Colors.grey,
                                  color: secondsRemaining == 0
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            // Hiển thị thời gian đếm ngược
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: size.height * 0.01),
                            // Nút xác nhận OTP
                            ElevatedButton(
                              onPressed: isButtonEnabled
                                  ? () {
                                      print("Gửi OTP: $otpCode");
                                      auth.inputOtp(
                                          context, widget.email, otpCode);
                                      // Không cần clearState ở đây vì đã xử lý trong inputOtp
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isButtonEnabled
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Xác nhận"),
                            ),
                          ],
                        ),
                      ),
                      // Thêm space khi màn hình lớn
                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                  text: "Chưa có tài khoản?  ",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              TextSpan(
                text: "Đăng ký ngay",
                style: const TextStyle(
                  color: Color(0xff006AF5),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Xóa lỗi trước khi chuyển màn hình
                    Provider.of<AuthProvider>(context, listen: false)
                        .clearState();
                    context.push(AppRoutes.dangKyTaiKhoan);
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
