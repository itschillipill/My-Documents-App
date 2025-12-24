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
        debugPrint('AuthScope → hasPassword: $hasPassword');

        if (isFirstLaunch) {
          return onboardingPage;
        }

        return ValueListenableBuilder<bool>(
          valueListenable: authExecutor.authenticatedNotifier,
          builder: (context, authenticated, _) {
            debugPrint('AuthScope → authenticated: $authenticated');

            /// Если пароля нет — сразу пускаем
            if (!hasPassword) {
              return child;
            }

            /// Пароль есть, но пользователь ещё не ввёл его
            if (!authenticated) {
              return authScreenBuilder(authExecutor);
            }

            /// Всё ок — главная страница
            return child;
          },
        );
      },
    );
  }
}
