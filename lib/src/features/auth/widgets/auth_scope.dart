import 'package:flutter/material.dart';
import '../auth_executor.dart';

class AuthScope extends StatelessWidget {
  final Widget child;
  final Widget onboardingPage;
  final bool isFirstLaunch;
  final Widget Function(AuthenticationExecutor executor) authScreenBuilder;
  final AuthenticationExecutor authExecutor;

  const AuthScope({
    super.key,
    required this.child,
    required this.authScreenBuilder,
    required this.authExecutor,
    required this.onboardingPage,
    required this.isFirstLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: authExecutor.hasPasswordNotifier,
      builder: (context, hasPassword, _) {
        debugPrint("auth scope rebuild");

        if (isFirstLaunch) return onboardingPage;

        if (!hasPassword) {
          // безопасно обновляем authenticated после текущей микротаски
          if (!authExecutor.authenticated) {
            Future.microtask(() => authExecutor.authenticated = true);
          }
          return child;
        }

        return authExecutor.authenticated
            ? child
            : authScreenBuilder(authExecutor);
      },
    );
  }
}
