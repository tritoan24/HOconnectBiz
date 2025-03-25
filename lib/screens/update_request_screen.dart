import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpdateRequestScreen extends StatelessWidget {
  const UpdateRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 144,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              // Illustration
              SvgPicture.asset(
                'assets/icons/update_image.svg',
                width: 250,
                height: 250,
              ),

              const SizedBox(height: 25),

              // Title
              Text(
                'Yêu cầu cập nhật',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1A1C1E),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                  'Ứng dụng đã có phiên bản mới. Vui lòng cập nhật ngay để có trải nghiệm các tính năng mới nhất!',
                  style: TextStyles.textStyleNormal12W400Grey15,
                  textAlign: TextAlign.center),

              const SizedBox(height: 32),

              // Update Button
              ElevatedButton(
                onPressed: () {
                  // Add update logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryBlue,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cập nhật ngay',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
