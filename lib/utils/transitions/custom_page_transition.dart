import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class CustomPageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionType type;
  final bool enableSwipeBack;

  CustomPageTransition({
    required this.page,
    this.type = TransitionType.fade,
    this.enableSwipeBack = false,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              enableSwipeBack ? _SwipeBackWidget(child: page) : page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            var curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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

class _SwipeBackWidget extends StatelessWidget {
  final Widget child;

  const _SwipeBackWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // If swiping from left to right (positive delta)
        if (details.delta.dx > 0 && details.globalPosition.dx < 50) {
          // Check if swipe started from left edge
          Navigator.of(context).pop();
        }
      },
      onHorizontalDragEnd: (details) {
        // Optional: You can also check velocity to determine if it's a swipe
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}

enum TransitionType {
  fade,
  slideRight,
  slideUp,
  scale,
}
