import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    return Container(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          "assets/images/logo.png",
          width: isSmallScreen ? 120 : 144,
          height: isSmallScreen ? 65 : 80,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
