import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/text_styles.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

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
                'assets/icons/maintenance.svg',
                width: 250,
                height: 250,
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Ứng dụng đang bảo trì',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1A1C1E),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                  'Để nâng cao tính năng và trải nghiệm người dùng, ứng dụng sẽ tạm ngừng hoạt động trong thời gian bảo trì. Chúng tôi xin lỗi vì sự bất tiện này và cảm ơn bạn đã thông cảm!',
                  style: TextStyles.textStyleNormal12W400Grey15,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
