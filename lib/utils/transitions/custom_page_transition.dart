import 'package:flutter/material.dart';

class CustomPageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionType type;

  CustomPageTransition({required this.page, this.type = TransitionType.fade})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeAnimation = animation.drive(tween);

            switch (type) {
              case TransitionType.fade:
                return FadeTransition(opacity: fadeAnimation, child: child);
              case TransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              case TransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              case TransitionType.scale:
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
            }
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

enum TransitionType {
  fade,
  slideRight,
  slideUp,
  scale,
}