import 'package:flutter/material.dart';
import '../auth_executor.dart';

class AuthScope extends StatelessWidget {
  final Widget child;
  final Widget onboardingPage;
  final bool isFirstLaunch;
  final Widget Function(
    Future<bool> Function(String pin) authenticateByPIN,
    Future<bool> Function() authenticateByBiometrics,
  )
  authScreenBuilder;
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
        debugPrint('AuthScope → hasPassword: $hasPassword');

        if (isFirstLaunch) {
          return onboardingPage;
        }

        return ValueListenableBuilder<bool>(
          valueListenable: authExecutor.authenticatedNotifier,
          builder: (context, authenticated, _) {
            debugPrint('AuthScope → authenticated: $authenticated');

            if (!hasPassword) {
              return child;
            }

            if (!authenticated) {
              return authScreenBuilder(
                authExecutor.authenticateByPIN,
                authExecutor.authenticateByBiometrics,
              );
            }

            return child;
          },
        );
      },
    );
  }
}
