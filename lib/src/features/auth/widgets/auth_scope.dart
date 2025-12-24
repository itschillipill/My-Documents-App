import 'package:flutter/material.dart';
import '../auth_executor.dart';

class AuthScope extends StatelessWidget {
  final Widget child;
  final Widget Function(AuthenticationExecutor executor) authScreenBuilder;
  final AuthenticationExecutor authExecutor;

  const AuthScope({
    super.key,
    required this.child,
    required this.authScreenBuilder,
    required this.authExecutor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authExecutor,
      builder: (context, _) {
        if (!authExecutor.hasPassword) {
          authExecutor.authenticated = true;
          return child;
        }
        return authExecutor.authenticated
            ? child
            : authScreenBuilder(authExecutor);
      },
    );
  }
}
