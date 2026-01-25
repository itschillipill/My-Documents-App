import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/auth/widgets/auth_screen.dart';
import 'package:my_documents/src/features/settings/cubit/settings_cubit.dart';
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
  late final SettingsCubit settingsCubit;

  @override
  void initState() {
    super.initState();
    final deps = context.deps;
    authExecutor = deps.authExecutor;
    settingsCubit = deps.settingsCubit;
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
    // пересобираем Navigator
    setState(() {});
  }

  List<Page> get _pages => [
    if (settingsCubit.state.isFurstLaunch)
      const MaterialPage(child: OnboardingScreen())
    else if (authExecutor.hasPassword && !authExecutor.authenticated)
      MaterialPage(
        child: VerifyPinScreen(
          useBiometrics:
              settingsCubit.state.useBiometrics &&
              settingsCubit.canUseBiometrics,
          onAuthByPIN: authExecutor.authenticateByPIN,
          onAuthByBiometrics: authExecutor.authenticateByBiometrics,
        ),
      )
    else
      MaterialPage(child: widget.child),
  ];

  @override
  Widget build(BuildContext context) {
    return Navigator(pages: _pages, onDidRemovePage: (_) {});
  }
}
