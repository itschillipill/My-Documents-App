import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/auth/widgets/auth_screen.dart';
import 'package:my_documents/src/features/navigation/app_navigator.dart';
import 'package:my_documents/src/presentation/onboarding_screen.dart';
import '../auth_executor.dart';

class AuthScope extends StatefulWidget {
  final Widget child;

  const AuthScope({super.key, required this.child});

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<AuthScope> {
  late final Listenable _listenable;
  late final AuthenticationExecutor authExecutor;

  @override
  void initState() {
    super.initState();
    authExecutor = context.deps.authExecutor;
    _listenable = Listenable.merge([
      authExecutor.hasPasswordNotifier,
      authExecutor.authenticatedNotifier,
    ]);

    _listenable.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _listenable.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  List<Page> _pages(BuildContext ctx) => [
    MaterialPage(child: widget.child),
    if (ctx.deps.settingsCubit.state.isFirstLaunch)
      MaterialPage(key: ValueKey('onboarding'), child: OnboardingScreen()),
    if (authExecutor.hasPassword && !authExecutor.authenticated)
      MaterialPage(
        key: const ValueKey('verify_pin'),
        child: VerifyPinScreen(
          useBiometrics:
              ctx.deps.settingsCubit.state.useBiometrics &&
              ctx.deps.settingsCubit.canUseBiometrics,
          onAuthByPIN: authExecutor.authenticateByPIN,
          onAuthByBiometrics: authExecutor.authenticateByBiometrics,
        ),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppNavigator(pages: _pages(context));
  }
}
