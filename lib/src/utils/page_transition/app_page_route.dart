import 'package:flutter/material.dart';
part 'page_transition_type.dart';

class AppPageRoute {
  static PageRoute<T> build<T>({
    required Widget page,
    PageTransitionType transition = PageTransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: duration,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        switch (transition) {
          case PageTransitionType.slideFromRight:
            return SlideTransition(
              position: Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );

          case PageTransitionType.slideFromLeft:
            return SlideTransition(
              position: Tween(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );

          case PageTransitionType.slideFromBottom:
            return SlideTransition(
              position: Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );

          case PageTransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
        }
      },
    );
  }
}
